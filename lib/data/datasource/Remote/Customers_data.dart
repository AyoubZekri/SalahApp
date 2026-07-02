import 'package:Saleh/core/class/Crud.dart';
import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';

class CustomersData {
  Crud crud;
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  CustomersData(this.crud);

  viewdata() async {
    try {
      final result = await _db.readData(
        "SELECT * FROM Customers ORDER BY created_at DESC",
      );
      return result;
    } catch (e) {
      print("❌ CustomersData.viewdata error: $e");
      return [];
    }
  }

  Future<bool> Adddata(String username, String phoneNumper) async {
    final String uuid = Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "username": username,
        "phone_numper": phoneNumper,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("Customers", data);

      if (result > 0) {
        await _syncService.addToQueue("Customers", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ CustomersData.Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updatecustomer(String uuid, String username, String phoneNumper) async {
    try {
      final data = {
        "username": username,
        "phone_numper": phoneNumper,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("Customers", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("Customers", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ CustomersData.Updatecustomer error: $e");
      return false;
    }
  }

  Future<bool> deletecustomer(String uuid) async {
    try {
      final result = await _db.delete(
        "Customers",
        "uuid = ?",
        [uuid],
      );

      if (result <= 0) return false;

      await _syncService.addToQueue("Customers", uuid, "delete", {
        "uuid": uuid,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print("❌ CustomersData.deletecustomer error: $e");
      return false;
    }
  }
}
