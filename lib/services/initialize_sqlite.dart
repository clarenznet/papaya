import "dart:io" as io;
import "package:path/path.dart";
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SqliteDB {
  static final SqliteDB _instance = new SqliteDB.internal();

  factory SqliteDB() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }
SqliteDB.internal();

/// Initialize DB
initDb() async {
  io.Directory documentDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentDirectory.path, "myDatabase.db");
  var taskDb =
  await openDatabase(path, version: 1);
  return taskDb;
}

/// Count number of tables in DB
Future countTable() async {
  var dbClient = await db;
  var res =
  await dbClient.rawQuery("""SELECT count(*) as count FROM sqlite_master
         WHERE type = 'table' 
         AND name != 'android_metadata' 
         AND name != 'sqlite_sequence';""");
  return res[0]['count'];
}
  /// Creates user Table
  Future createUserTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE User(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        age INTEGER
      )""");
    return res;
  }


  /// An example use of transactions
  /// in sqflite
  Future test() async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.execute("DELETE FROM User");
      await txn.execute("DELETE FROM Posts");
    });
  }

  //////login sAVE

  /// Creates user Table
  Future createLoginUserTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE login(
        id TEXT PRIMARY KEY,
        fuid TEXT,
        email TEXT,
        phonenumber TEXT
      )""");
    return res;
  }



}