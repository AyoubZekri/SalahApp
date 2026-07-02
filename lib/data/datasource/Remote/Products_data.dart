import 'package:Saleh/core/class/Crud.dart';
import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';

class ProductsData {
  Crud crud;
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  ProductsData(this.crud);

  viewdata() async {
    try {
      final result = await _db.readData(
        '''
        SELECT p.*, c.name AS category_name 
        FROM products p 
        LEFT JOIN Categories c ON p.cat_uuid = c.uuid 
        ORDER BY p.created_at DESC
        '''
      );
      return result;
    } catch (e) {
      print("❌ ProductsData.viewdata error: $e");
      return [];
    }
  }

  Future<bool> Adddata(String name, double price, String catUuid, String gender) async {
    final String uuid = Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "cat_uuid": catUuid,
        "name": name,
        "price": price,
        "Gender": gender,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("products", data);

      if (result > 0) {
        await _syncService.addToQueue("products", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ ProductsData.Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updateproduct(String uuid, String name, double price, String catUuid, String gender) async {
    try {
      final data = {
        "cat_uuid": catUuid,
        "name": name,
        "price": price,
        "Gender": gender,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("products", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("products", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ ProductsData.Updateproduct error: $e");
      return false;
    }
  }

  Future<bool> deleteproduct(String uuid) async {
    try {
      final result = await _db.delete(
        "products",
        "uuid = ?",
        [uuid],
      );

      if (result <= 0) return false;

      await _syncService.addToQueue("products", uuid, "delete", {
        "uuid": uuid,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print("❌ ProductsData.deleteproduct error: $e");
      return false;
    }
  }
}
