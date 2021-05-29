import 'dart:io';
import 'package:sonus/logic/models/language_model.dart';
import 'package:sonus/logic/models/settings_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final _dbName = "sonus.db";
  static final _dbVersion = 1;

  DatabaseProvider._();
  static final DatabaseProvider instance = DatabaseProvider._();

  static Database _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await _init();
    }
    return _database;
  }

  _init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path,
        version: _dbVersion, onCreate: _onCreate, onConfigure: _onConfigure);
  }

  Future<dynamic> _onConfigure(Database db) async {
    return await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<dynamic> _onCreate(Database db, int version) async {
    
    // languages table
    await db.execute('''
      CREATE TABLE languages(
        id INTEGER PRIMARY KEY,
        name TEXT,
        language_code TEXT
      )
    ''');

    // settings table
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY,
        theme INTEGER, 
        language INTEGER,
        speech_recognition INTEGER,
        text_to_speech INTEGER,
        FOREIGN KEY (language) REFERENCES languages (id)
      )
    ''');

    // phrases table
    await db.execute('''
      CREATE TABLE phrases(
        id INTEGER PRIMARY KEY,
        value TEXT
      )
    ''');


    // records groups table
    await db.execute('''
      CREATE TABLE records_groups(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // records table 
    await db.execute('''
      CREATE TABLE records(
        id INTEGER PRIMARY KEY,
        record TEXT,
        group_id INTEGER,
        FOREIGN KEY (group_id) REFERENCES records_groups (id)
      )
    ''');
    
    await db.rawInsert('''
      INSERT INTO languages(id, name, language_code) VALUES(1, 'English', 'en');
    ''');
    await db.rawInsert('''
      INSERT INTO languages(id, name, language_code) VALUES(2, 'Русский', 'ru');
    ''');

    await db.insert("settings", SettingsModel(id: 1, language: 2, theme: 0, speechRecognition: 1, textToSpeech: 1).toMap());
  }
}
