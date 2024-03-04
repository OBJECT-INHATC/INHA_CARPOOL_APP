import 'package:inha_Carpool/common/models/m_chat.dart';
import 'package:sembast/sembast.dart';
import 'd_database.dart';

/// Local Chat DataBase DAO - Sembast
class ChatDao {
  static const String folderName = "chat";

  final _chatFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.chatDatabase;

  /// 채팅 메시지 단일 저장
  Future insert(ChatMessage chatMessage) async {
    await _chatFolder.add(await _db, chatMessage.toMap());
  }

  /// 채팅 메시지 저장
  Future saveChatMessages(List<ChatMessage> newMessages) async {
    final existingMessages = await getChatbyCarIdSortedByTime(newMessages.first.carId);

    for (var newMessage in newMessages) {
      if (!existingMessages.contains(newMessage)) {
        insert(newMessage);
        existingMessages.add(newMessage); // 기존 리스트에도 추가
      }
    }
  }

  /// 채팅 메시지 삭제
  Future delete(ChatMessage chatMessage) async {
    final finder = Finder(filter: Filter.byKey(chatMessage.id));
    await _chatFolder.delete(await _db, finder: finder);
  }

  /// 채팅 메시지 전체 삭제
  Future deleteAll() async {
    await _chatFolder.delete(await _db);
  }

  /// 그룹 아이디 - 채팅 메시지 삭제
  Future deleteByCarId(String carId) async {
    final finder = Finder(filter: Filter.equals('carId', carId));
    await _chatFolder.delete(await _db, finder: finder);
  }

  /// 그룹 아이디 - 채팅 메시지 리스트 반환
  Future<List<ChatMessage>> getChatbyCarIdSortedByTime(String carId) async {
    final finder = Finder(filter: Filter.equals('carId', carId), sortOrders: [SortOrder('time')]);

    final recordSnapshots = await _chatFolder.find(await _db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final chatMessage = ChatMessage.fromMap(snapshot.value, carId);
      chatMessage.id = snapshot.key;
      return chatMessage;
    }).toList();

  }

  Future<void> getCheckMSG(String carId) async {
    final finder = Finder(filter: Filter.equals('carId', carId));

    final recordSnapshots = await _chatFolder.find(await _db, finder: finder);

    print(recordSnapshots.length);

    for (var snapshot in recordSnapshots) {
      final chatMessage = ChatMessage.fromMap(snapshot.value, carId);
      chatMessage.id = snapshot.key;
      // 각 ChatMessage의 필드를 프린트합니다.
      print('Message: ${chatMessage.message}');
    }
  }




  /// 그룹 아이디 - 채팅 메시지 리스트 반환
  Future<List<ChatMessage>> getChatByCarId(String carId) async {
    final finder = Finder(filter: Filter.equals('carId', carId));

    final recordSnapshots = await _chatFolder.find(await _db, finder: finder);

    print(recordSnapshots.length);

    return recordSnapshots.map((snapshot) {
      final chatMessage = ChatMessage.fromMap(snapshot.value, carId);
      chatMessage.id = snapshot.key;
      return chatMessage;
    }).toList();


    ///로컬채팅 시간과 가장 최근 시간을 비교해서
  }

}