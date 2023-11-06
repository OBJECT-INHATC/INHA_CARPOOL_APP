import 'package:inha_Carpool/common/data/preference/prefs.dart';
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
  Future deleteById(String aid) async {
    final finder = Finder(filter: Filter.equals('aid', aid));
    await _alarmFolder.delete(await _db, finder: finder);
  }

  /// 로컬 디비 일괄 삭제
  Future deleteAll() async {
    await _alarmFolder.delete(await _db);
  }

  /// 알림 리스트 반환 + 시간 정렬 [ 최근 ~> 과거 ]
  Future<List<AlarmMessage>> getAllAlarms() async {
    final finder = Finder(sortOrders: [SortOrder('time')]);

    final recordSnapshots = await _alarmFolder.find(await _db, finder: finder);

    final alarmList = recordSnapshots.map((snapshot) {
      final alarmMessage = AlarmMessage.fromMap(snapshot.value);
      return alarmMessage;
    }).toList();

    return alarmList.reversed.toList(); // 리스트를 역순으로 반환
  }


  /// 알림 리스트에 알림이 존재하는지 확인
  Future<bool> checkAlarms() async {
    print('알람 체크');
    Prefs.chatRoomCarIdRx.set("");
    final recordSnapshots = await _alarmFolder.find(await _db);
    if(recordSnapshots.isEmpty) {
      return false;
    } else {
      return true;
    }
  }


}