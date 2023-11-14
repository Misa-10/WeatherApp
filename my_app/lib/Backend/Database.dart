import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database file
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'contact.db');

    // Create the database and open it
    Database database = await openDatabase(path, version: 1, onCreate: _createDb);
    return database;
  }

  Future<void> _createDb(Database db, int version) async {
    // Create the MyContacts table
    await db.execute('''
      CREATE TABLE contact(
        id INTEGER PRIMARY KEY,
        name TEXT,
        phone TEXT
      )
    ''');
  }

   Future<int> insertContact(MyContact MyContact) async {
    Database? db = await database;

    // Check if the database instance is null
    // ignore: unnecessary_null_comparison
    if (db == null) {
      // Handle the null case (e.g., throw an exception or return an error)
      throw Exception('Database is null');
    }

    // Check if a MyContact with id 1 already exists
    final existingMyContact = await db.query(
      'contact',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (existingMyContact.isNotEmpty) {
      // Delete the existing MyContact with id 1
      await db.delete('contact', where: 'id = ?', whereArgs: [1]);
    }

    // Insert the new MyContact with id 1
    return await db.insert('contact', MyContact.toMap());
  }
}

  Future<List<MyContact>> getContact() async {
  var instance = DatabaseHelper(); // Create an instance of your DatabaseHelper
  Database? db = await instance.database;

  if (db != null) {
    List<Map<String, dynamic>> maps = await db.query('contact');
    return List.generate(maps.length, (index) => MyContact.fromMap(maps[index]));
  } else {
    // Handle the case when the database is null
    return []; // Return an empty list or handle the error accordingly
  }
}


class MyContact {
  final int? id;
  final String name;
  final String phone;

  MyContact({this.id, required this.name, required this.phone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  factory MyContact.fromMap(Map<String, dynamic> map) {
    return MyContact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
    );
  }
}
