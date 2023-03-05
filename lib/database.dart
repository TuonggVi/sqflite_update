import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        lotId TEXT,
        itemName TEXT,
        purchaseOrderNumber TEXT,
        quantity TEXT,
        sublotSize TEXT,
        location TEXT,
      )
      """);
    // create new table
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'items.db',
      version:1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
        
      },
      // onUpgrade: (sql.Database database, int oldVersion, int newVersion) async {
      //   // In this case, oldVersion is 1, newVersion is 2
      //   if (oldVersion == 1) {
      //     await database.execute("""AFTER TABLE items(
      //   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      //   title TEXT,
      //   description TEXT,
      //   createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      // )
      // """);

      //     await database.execute("""CREATE TABLE newitems(
      //   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      //   title TEXT,
      //   detail TEXT,
      //   description TEXT,
      //   createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      // )
      // """); // create new Table;
      //   }
      //   ;
      // },
    );
  }
  

  // Create new item (journal)
  static Future<int> createItem(
      String lotId, 
      String? itemName, 
      String? purchaseOrderNumber, 
      String? quantity, 
      String? sublotSize, 
      String? location) async {
    final db = await SQLHelper.db();

    final data = {
      
      'lotId': lotId, 
      'itemName': itemName, 
      'purchaseOrderNumber': purchaseOrderNumber,
      'quantity': quantity, 
      'sublotSize': sublotSize, 
      'location': location,
    };
    final item = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return item;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, 
      String lotId, 
      String? itemName, 
      String? purchaseOrderNumber,
      String? quantity, 
      String? sublotSize, 
      String? location
      ) async {
    final db = await SQLHelper.db();

    final data = {
      'lotId': lotId,
      'itemName': itemName,
      'purchaseOrderNumber': purchaseOrderNumber,
      'quantity': quantity,
      'sublotSize': sublotSize,
      'location': location,
      
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
