import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// 0828 서은율, 한승완
/// Local Chat DataBase - Sembast Singleton
class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._();

  static AppDatabase get instance => _singleton;

  Completer<Database>? _chatDbOpenCompleter;
  Completer<Database>? _alarmDbOpenCompleter;

  AppDatabase._();

  Future<Database> get chatDatabase async {
    if (_chatDbOpenCompleter == null) {
      _chatDbOpenCompleter = Completer();
      await _openDatabase();
    }
    return _chatDbOpenCompleter!.future;
  }

  Future _openDatabase() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'chat.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);
    _chatDbOpenCompleter!.complete(database);
  }

  Future<Database> get alarmDatabase async {
    if (_alarmDbOpenCompleter == null) {
      _alarmDbOpenCompleter = Completer();
      await _openAlarmDatabase();
    }
    return _alarmDbOpenCompleter!.future;
  }

  Future _openAlarmDatabase() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final alarmDbPath = join(appDocumentDir.path, 'alarm.db');

    final alarmDatabase = await databaseFactoryIo.openDatabase(alarmDbPath);
    _alarmDbOpenCompleter!.complete(alarmDatabase);
  }
}