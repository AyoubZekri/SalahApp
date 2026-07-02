import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLDB {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> intialDb() async {
    String dataBais = await getDatabasesPath();
    String path = join(dataBais, 'Saleh.db');

    // Deleting the database to completely reset it from zero (scratch)
    // await deleteDatabase(path);
    // print("🗑️ Database Saleh.db deleted successfully for a fresh reset from zero.");

    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onUpgrade: _onUpgrade,
    );

    return mydb;
  }

  Future<void> _onUpgrade(Database db, int oldversion, int newVersion) async {
    print("_onUpgrade: from v$oldversion to v$newVersion ===============");
  }

  Future<void> _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    /// Customers Table
    batch.execute('''
      CREATE TABLE Customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        username TEXT,
        phone_numper TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// Categories Table
    batch.execute('''
      CREATE TABLE Categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        name TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// products Table
    batch.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        cat_uuid TEXT,
        name TEXT,
        price REAL,
        Gender TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// invoice Table
    batch.execute('''
      CREATE TABLE invoice(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        Customers_uuid TEXT,
        type TEXT,
        numper TEXT,
        date TEXT,
        Payment_price TEXT,
        discount TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// payments Table
    batch.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        invoice_uuid TEXT,
        Payment_price TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// InvoiceItems Table
    batch.execute('''
      CREATE TABLE InvoiceItems(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        invoice_uuid TEXT,
        product_uuid TEXT,
        product_name TEXT,
        unit_price REAL,
        quantity REAL,
        type TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// notes Table
    batch.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Title TEXT,
        content TEXT,
        uuid TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    /// sync_queue Table
    batch.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT,
        row_id TEXT,
        operation TEXT,
        data TEXT,
        synced INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    /// sync_metadata Table
    batch.execute('''
      CREATE TABLE sync_metadata(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT,
        user_id INTEGER,
        last_sync TEXT
      )
    ''');

    await batch.commit();
    print(
        'Database and all tables created successfully from scratch (zero) ======================\n');
  }

  // CRUD METHODS =============================================

  Future<List<Map<String, Object?>>> readData(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    Database? mydb = await db;
    return await mydb!.rawQuery(sql, arguments);
  }

  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    return await mydb!.rawInsert(sql);
  }

  Future<int> updateData(String sql, List list) async {
    Database? mydb = await db;
    return await mydb!.rawUpdate(sql);
  }

  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    return await mydb!.rawDelete(sql);
  }

  Future<void> mydeleteDatebase() async {
    String dataBais = await getDatabasesPath();
    String path = join(dataBais, 'Saleh.db');
    await deleteDatabase(path);
  }

  Future<List<Map>> read(String table) async {
    Database? mydb = await db;
    return await mydb!.query(table);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    Database? mydb = await db;
    return await mydb!.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values,
    String? where, [
    List<Object?>? whereArgs,
  ]) async {
    Database? mydb = await db;
    return await mydb!.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table,
    String? where, [
    List<Object?>? whereArgs,
  ]) async {
    Database? mydb = await db;
    return await mydb!.delete(table, where: where, whereArgs: whereArgs);
  }
}
