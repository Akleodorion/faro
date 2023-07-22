import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

// récupère la base de donnée Faro stockée localement.
Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'faro.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_login(email TEXT, password TEXT, token TEXT)',
      );
    },
    version: 2,
    onUpgrade: (db, oldVersion, newVersion) {
      return db.execute('alter TABLE user_login ADD COLUMN checked TEXT');
    },
  );
  return db;
}

class LoggedStatusNotifier extends StateNotifier<Map<String, String>> {
  LoggedStatusNotifier() : super({});

  // charge la base de donnée et récupère les logs de connexions si ils existent.
  Future<void> loadUserLoginData() async {
    final db = await getDatabase();
    final userLoginData = await db.query('user_login');

    if (userLoginData.isEmpty) {
      final logins = {
        'email': "",
        'password': "",
        'token': "",
        'checked': "false",
      };
      state = logins;
    } else {
      final Map<String, String> logins = {
        'email': userLoginData[0]["email"] as String,
        'password': userLoginData[0]["password"] as String,
        'token': userLoginData[0]["token"] as String,
        'checked': userLoginData[0]["checked"] as String,
      };
      state = logins;
    }
    print(state);
  }

  // Modifie les informations de login de l'utilisateurs si elles sont différentes de la dernière fois.
  void appendUserLoginData(
      String email, String password, String token, String isChecked) async {
    final db = await getDatabase();
    final userLoginData = await db.query('user_login');

    // si l'email entrée est = au state alors pas besoin de modifier.
    if (state["email"] == email && userLoginData[0]['checked'] == isChecked) {
      return;
    }

    final Map<String, String> updatedValue = {
      'email': email,
      'password': password,
      'token': token,
      'checked': isChecked,
    };
    print(updatedValue);

    if (isChecked == 'false') {
      updatedValue['email'] = '';
      updatedValue['password'] = '';
    }

    state = updatedValue;

    if (userLoginData.isEmpty) {
      await db.insert('user_login', updatedValue);
    } else {
      await db.update('user_login', updatedValue);
    }
  }
}

final loggedStatusProvider =
    StateNotifierProvider<LoggedStatusNotifier, Map<String, String>>((ref) {
  return LoggedStatusNotifier();
});
