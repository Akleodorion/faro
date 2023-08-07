import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

// récupère la base de donnée locale avec les UserLoginInfo.
Future<Database> getDatabase() async {
  // récupère le path de la DB
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'faro.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_login(email TEXT, password TEXT, token TEXT)',
      );
    },
    onUpgrade: (db, oldVersion, newVersion) {
      return db.execute('alter TABLE user_login ADD COLUMN checked TEXT');
    },
    version: 2,
  );
  return db;
}

void appendUserLoginData(
    String email, String password, String token, String isChecked) async {
  final db = await getDatabase();
  final userLoginData = await db.query('user_login');

  final Map<String, String> updatedValue = {
    'email': email,
    'password': password,
    'token': token,
    'checked': isChecked,
  };

  if (userLoginData.isEmpty) {
    await db.insert('user_login', updatedValue);
  } else {
    await db.update('user_login', updatedValue);
  }
}
