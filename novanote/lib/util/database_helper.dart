import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/note.dart';

class DatabaseHelper {
  static late DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static late Database _database; // Singleton Database

  String notesTable = "notes_table";
  String colId = "id";
  String colTitle = "title";
  String colPriority = "priority";
  String colContent = "content";
  String colSecret = "secret";
  String colDate = "date";

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}notes.db";
    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $notesTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$colTitle TEXT, $colPriority INTEGER, $colContent TEXT, $colSecret INTEGER, $colDate TEXT)");
  }

  // Fetch operation: Get all note map objects from the database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    var result = await db.query(notesTable, orderBy: "$colPriority ASC");
    return result;
  }

  // Insert operation: Insert a note object to the database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(notesTable, note.toMap());
    return result;
  }

  //Update operation: Update a note object and save it to the database
  Future<int> updateNote(Note note) async {
    Database db = await database;
    var result = await db.update(notesTable, note.toMap(),
        where: "$colId = ?", whereArgs: [note.id]);
    return result;
  }

  //Delete operation: Delete a note object from the database
  Future<int> deleteNote(Note note) async {
    Database db = await database;
    var result =
        await db.delete(notesTable, where: "$colId = ?", whereArgs: [note.id]);
    return result;
  }

  // Get number of note objects in the database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> numberResult =
        await db.rawQuery("SELECT COUNT(*) FROM $notesTable");
    int result = Sqflite.firstIntValue(numberResult) ?? 0;
    return result;
  }
}
