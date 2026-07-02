import 'dart:convert';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/Services.dart';
import '../functions/CheckInternat.dart';
import 'sqldb.dart';

class SyncService {
  final SQLDB _db = SQLDB();
  final _supabase = Supabase.instance.client;

  // ---------------------------------------------------------
  // QUEUE
  // ---------------------------------------------------------

  Future<void> addToQueue(
    String table,
    String uuid,
    String operation,
    Map<String, dynamic>? data,
  ) async {
    try {
      data?["uuid"] = uuid;
      data?["updated_at"] = DateTime.now().toIso8601String();

      await _db.insert("sync_queue", {
        "table_name": table,
        "row_id": uuid,
        "operation": operation,
        "data": data != null ? jsonEncode(data) : null,
        "synced": 0,
      });
    } catch (e) {
      print("⚠️ SyncService.addToQueue error: $e");
    }
  }

  Future<void> pushQueue(String table) async {
    final unsynced = await _db.readData(
      "SELECT * FROM sync_queue WHERE synced = 0 AND table_name = ?",
      [table],
    );

    if (unsynced.isEmpty) {
      print(" $tableℹ️ لا توجد بيانات لرفعها");
      return;
    }

    print("🚀 بدء الرفع لجدول $table: ${unsynced.length} عنصر");

    for (final row in unsynced) {
      final String operation = row["operation"] as String;
      final String uuid = row["row_id"] as String;

      final data = row["data"] != null
          ? Map<String, dynamic>.from(jsonDecode(row["data"] as String))
          : <String, dynamic>{};
      data["uuid"] = uuid;

      try {
        if (operation == "delete") {
          await _supabase.from(table.toLowerCase()).update({
            'is_delete': 1,
            'updated_at': DateTime.now().toIso8601String()
          }).eq('uuid', uuid);
          await _db.update("sync_queue", {"synced": 1}, "id=${row["id"]}");
          print("✅ نجاح تعديل حالة الحذف لـ $uuid في $table");
          continue;
        }

        // Upsert data to Supabase
        await _supabase.from(table.toLowerCase()).upsert(data, onConflict: 'uuid');
        await _db.update("sync_queue", {"synced": 1}, "id=${row["id"]}");
        print("✅ نجاح رفع ${data["uuid"]}");
      } catch (e) {
        print("❌ استثناء أثناء رفع $uuid: $e");
      }
    }

    print("🏁 انتهى الرفع لجدول $table.");
  }

  // ---------------------------------------------------------
  // PULL FROM SERVER
  // ---------------------------------------------------------

  Future<void> pullFromServer(String table) async {
    try {
      // Get last sync time
      final lastSyncRow = await _db.readData(
        "SELECT last_sync FROM sync_metadata WHERE table_name='$table'",
      );
      final String lastSync = lastSyncRow.isNotEmpty
          ? lastSyncRow.first["last_sync"].toString()
          : "1970-01-01T00:00:00Z";

      final int limit = 50;
      int page = 0;
      int totalDownloaded = 0;
      bool hasMore = true;

      while (hasMore) {
        final response = await _supabase
            .from(table.toLowerCase())
            .select()
            .gt('updated_at', lastSync)
            .order('updated_at', ascending: true)
            .range(page * limit, (page + 1) * limit - 1);

        final List<dynamic> serverData = response as List<dynamic>;
        totalDownloaded += serverData.length;
        print(
            "📥 دفعة ${page + 1} ($table): تم استلام ${serverData.length} سجل");

        if (serverData.isEmpty) {
          hasMore = false;
          break;
        }

        // Handle soft deletes if applicable (assumes boolean or 1/0)
        final deletedUuids = serverData
            .where((e) =>
                e["is_delete"] == 1 ||
                e["is_delete"] == "1" ||
                e["is_delete"] == true)
            .map((e) => e["uuid"].toString())
            .toList();

        if (deletedUuids.isNotEmpty) {
          await _syncDeletedLocalRows(table, deletedUuids);
        }

        serverData.removeWhere(
          (e) =>
              e["is_delete"] == 1 ||
              e["is_delete"] == "1" ||
              e["is_delete"] == true,
        );

        await _syncServerRecords(table, serverData);

        hasMore = serverData.length == limit;
        page++;
      }

      // Update sync metadata
      final now = DateTime.now().toIso8601String();
      await _db.delete("sync_metadata", "table_name = '$table'");
      await _db.insert("sync_metadata", {
        "table_name": table,
        "user_id": 0, // Ignored now but keeping for DB constraints if any
        "last_sync": now,
      });

      print("✅ اكتملت مزامنة جدول $table");
    } catch (e) {
      print("❌ pullFromServer failed for $table: $e");
    }
  }

  Future<List<String>> _syncDeletedLocalRows(
    String table,
    List<String> deletedUuids,
  ) async {
    if (deletedUuids.isEmpty) return [];

    List<String> foundLocally = [];

    for (final uuid in deletedUuids) {
      final row = await _db.readData("SELECT uuid FROM $table WHERE uuid = ?", [
        uuid,
      ]);

      if (row.isNotEmpty) {
        await _db.delete(table, "uuid = ?", [uuid]);
        print("🗑️ حذف محلي => $uuid");
        foundLocally.add(uuid);
      }
    }

    return foundLocally;
  }

  Future<void> _syncServerRecords(
    String table,
    List<dynamic> serverData,
  ) async {
    final columns = await getTableColumns(_db, table);

    for (var record in serverData) {
      try {
        final uuid = record["uuid"];
        if (uuid == null) continue;

        record.remove("id");

        final filtered = filterRecord(
          Map<String, dynamic>.from(record),
          columns,
        );

        final existing = await _db.readData(
          "SELECT * FROM $table WHERE uuid = ?",
          [uuid],
        );

        if (existing.isEmpty) {
          await _db.insert(table, filtered);
          print("📥 تم حفظ سجل جديد: $uuid في جدول $table");
        } else {
          final local = existing.first;

          final serverUpdated =
              DateTime.tryParse(record["updated_at"] ?? "") ?? DateTime(1970);

          final rawDate = local["updated_at"];
          final localUpdated = (rawDate != null)
              ? DateTime.tryParse(rawDate.toString()) ?? DateTime(1970)
              : DateTime(1970);

          if (serverUpdated.isAfter(localUpdated)) {
            await _db.update(table, filtered, "uuid = ?", [uuid]);
            print("🔄 تم تحديث سجل موجود: $uuid في جدول $table");
          }
        }
      } catch (e) {
        print("❌ فشل معالجة سجل في جدول $table: $e");
      }
    }
  }

  Map<String, Object?> filterRecord(
    Map<String, dynamic> record,
    Set<String> columns,
  ) {
    final lowerColumns = columns.map((e) => e.toLowerCase()).toSet();

    return Map.fromEntries(
      record.entries.where((e) {
        final key = e.key.toLowerCase();
        return lowerColumns.contains(key);
      }).map((e) {
        final originalKey = columns.firstWhere(
          (col) => col.toLowerCase() == e.key.toLowerCase(),
          orElse: () => e.key,
        );
        return MapEntry(originalKey, e.value);
      }),
    );
  }

  Future<Set<String>> getTableColumns(SQLDB db, String table) async {
    final res = await db.readData('PRAGMA table_info($table)');
    return res.map((e) => e['name'] as String).toSet();
  }

  // ---------------------------------------------------------
  // FULL SYNC
  // ---------------------------------------------------------

  Future<void> syncAll() async {
    if (!await checkInternet()) {
      print("🚫 مافيش انترنت");
      return;
    }

    print("🌐 بدء المزامنة مع Supabase…");

    // Only tables present in sqldb.dart
    final tables = [
      "Customers",
      "Categories",
      "products",
      "invoice",
      "payments",
      "InvoiceItems",
      "notes"
    ];

    for (final table in tables) {
      await pushQueue(table);
    }

    for (final table in tables) {
      await pullFromServer(table);
    }

    print("✅ كل المزامنة كملت بنجاح");

    if (Get.isRegistered<RefreshService>()) {
      Get.find<RefreshService>().fire();
    }
  }

  // ---------------------------------------------------------
  // INTERNET LISTENER
  // ---------------------------------------------------------

  void initSyncListener() {
    print("🔄 initSyncListener started…");

    Connectivity().onConnectivityChanged.listen((results) async {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        if (await checkInternet()) {
          print("🌐 الانترنت رجع — تشغيل syncAll()");
          await syncAll();
        }
      } else {
        print("📴 الانترنت انقطع");
      }
    });
  }
}
