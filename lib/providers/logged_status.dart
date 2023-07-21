import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'faro.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_login(email TEXT, password TEXT, token TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class LoggedStatusNotifier extends StateNotifier<Map<String, String>> {
  LoggedStatusNotifier() : super({});

  Future<void> loadUserLoginData() async {
    final db = await _getDatabase();
    final userLoginData = await db.query('user_login');

    if (userLoginData.isEmpty) {
      final logins = {
        'email': "",
        'password': "",
        'token': "",
      };
      state = logins;
    } else {
      final Map<String, String> logins = {
        'email': userLoginData[0]["email"] as String,
        'password': userLoginData[0]["password"] as String,
        'token': userLoginData[0]["token"] as String,
      };
      state = logins;
    }
  }

  void appendUserLoginData(String email, String password, String token) async {
    final db = await _getDatabase();
    final userLoginData = await db.query('user_login');
    final Map<String, String> updatedValue = {
      'email': email,
      'password': password,
      'token': token,
    };

    if (userLoginData.isEmpty) {
      await db.insert('user_login', updatedValue);
    } else {
      await db.update('user_login', updatedValue);
    }

    state = updatedValue;
  }
}

final loggedStatusProvider =
    StateNotifierProvider<LoggedStatusNotifier, Map<String, String>>((ref) {
  return LoggedStatusNotifier();
});
