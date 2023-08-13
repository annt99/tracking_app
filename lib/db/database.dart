import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/tracking_location_model.dart';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();
  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path =
        join('${documentsDirectory.path}/db/', 'tracking_database.db');

    var database = await openDatabase(
      path,
      version: 1,
      readOnly: false,
      onCreate: initDb,
      onUpgrade: onUpgrade,
    );

    return database;
  }

  void initDb(Database database, int version) async {
    //user main table
    String sqlTracking =
        'CREATE TABLE IF NOT EXISTS $tableTracking (${trackingTableColumns[0]} INTEGER PRIMARY KEY,${trackingTableColumns[1]} REAL NOT NULL,${trackingTableColumns[2]} REAL NOT NULL, ${trackingTableColumns[3]} TEXT NOT NULL)';
    await database.execute(sqlTracking);
  }

  void onUpgrade(Database database, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      //await database.execute("request");
    }
  }
}
