import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:sembast/sembast.dart';
import 'd_database.dart';

/// 0831 한승완
/// Local Alarm DataBase DAO - Sembast
class AlarmDao {
  static const String folderName = "alarm";

  final _alarmFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.alarmDatabase;

  /// 알림 단일 저장
  Future insert(AlarmMessage alarmMessage) async {
    await _alarmFolder.add(await _db, alarmMessage.toMap());
  }

  /// id로 알림 삭제
  Future deleteById(int id) async {
    final finder = Finder(filter: Filter.equals('id', id));
    await _alarmFolder.delete(await _db, finder: finder);
  }

  /// 일괄 삭제
  Future deleteAll() async {
    await _alarmFolder.delete(await _db);
  }

  /// 알림 리스트 반환
  Future<List<AlarmMessage>> getAllAlarms() async {
    final finder = Finder(sortOrders: [SortOrder('time')]);

    final recordSnapshots = await _alarmFolder.find(await _db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final alarmMessage = AlarmMessage.fromMap(snapshot.value, snapshot.key);
      alarmMessage.id = snapshot.key;
      return alarmMessage;
    }).toList();
  }




}