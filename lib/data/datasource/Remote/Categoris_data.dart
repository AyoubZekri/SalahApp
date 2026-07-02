import 'dart:io';
import 'package:Saleh/core/class/Crud.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class CategorisData {
  Crud crud;
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  CategorisData(this.crud);

  viewdata() async {
    try {
      final result = await _db.readData(
        "SELECT id, uuid, name AS categoris_name, created_at, updated_at FROM Categories ORDER BY created_at ASC",
      );

      return result;
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  /// ✅ إضافة فئة جديدة
  Future<bool> Adddata(String name) async {
    final String uuid = Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "name": name,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("Categories", data);

      if (result > 0) {
        await _syncService.addToQueue("Categories", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  /// ✅ تعديل فئة
  Future<bool> Updatecat(
    String uuid,
    String name,
  ) async {
    try {
      final data = {
        "name": name,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("Categories", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("Categories", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Updatecat error: $e");
      return false;
    }
  }

  /// ✅ حذف فئة
  Future<bool> deletecat(String uuid) async {
    try {
      // 1️⃣ جلب الفئة للتأكد من وجودها وغير محذوفة
      final cat = await _db.readData(
        "SELECT id FROM Categories WHERE uuid = ?",
        [uuid],
      );

      if (cat.isEmpty) return false;

      final result = await _db.delete(
        "Categories",
        "uuid = ?",
        [uuid],
      );

      if (result <= 0) return false;

      // 3️⃣ Sync الفئة
      await _syncService.addToQueue("Categories", uuid, "delete", {
        "uuid": uuid,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // // 4️⃣ جلب كل المنتجات التابعة للفئة
      // final products = await _db.readData(
      //   "SELECT uuid, product_quantity FROM products WHERE categoris_uuid = ? AND user_id = ?",
      //   [uuid, id],
      // );

      // for (var p in products) {
      //   final productUuid = p["uuid"] as String;
      //   int remainingQty = int.tryParse(p["product_quantity"].toString()) ?? 0;

      //   // 5️⃣ جلب كل سطور البيع من type_sales = 3 (stock) من الأخير للأول
      //   final stockRows = await _db.readData(
      //     '''
      // SELECT uuid, quantity
      // FROM sales
      // WHERE product_uuid = ?
      //   AND user_id = ?
      //   AND type_sales = 3
      // ORDER BY created_at DESC
      // ''',
      //     [productUuid, id],
      //   );

      //   for (final row in stockRows) {
      //     if (remainingQty <= 0) break;

      //     final stockUuid = row["uuid"] as String;
      //     final stockQty = int.tryParse(row["quantity"].toString()) ?? 0;

      //     if (stockQty > remainingQty) {
      //       final newQty = stockQty - remainingQty;

      //       await _db.update(
      //         "sales",
      //         {
      //           "quantity": newQty,
      //           "updated_at": DateTime.now().toIso8601String(),
      //         },
      //         "uuid = ?",
      //         [stockUuid],
      //       );

      //       await _syncService.addToQueue("sales", stockUuid, "update", {
      //         "uuid": stockUuid,
      //         "quantity": newQty,
      //         "updated_at": DateTime.now().toIso8601String(),
      //       });

      //       remainingQty = 0;
      //     } else {
      //       // حذف السطر
      //       await _db.delete("sales", "uuid = ?", [stockUuid]);

      //       await _syncService.addToQueue("sales", stockUuid, "update", {
      //         "uuid": stockUuid,
      //         "is_delete": 1,
      //         "updated_at": DateTime.now().toIso8601String(),
      //       });

      //       remainingQty -= stockQty;
      //     }
      //   }

      //   // 6️⃣ حذف المنتج نفسه
      //   await _db.update(
      //     "products",
      //     {
      //       "uuid": productUuid,
      //       "is_delete": 1,
      //       "updated_at": DateTime.now().toIso8601String(),
      //     },
      //     "uuid = ? AND user_id = ?",
      //     [productUuid, id],
      //   );

      //   await _syncService.addToQueue("products", productUuid, "update", {
      //     "uuid": productUuid,
      //     "is_delete": 1,
      //     "updated_at": DateTime.now().toIso8601String(),
      //   });
      // }

      return true;
    } catch (e, st) {
      print("❌ deletecat error: $e");
      print(st);
      return false;
    }
  }
}
