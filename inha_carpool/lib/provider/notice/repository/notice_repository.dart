import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../state/notice_state.dart';

final noticeRepositoryProvider = Provider((ref) => NoticeRepository(ref));

class NoticeRepository {
  final Ref _ref;
  final _fireStore = FirebaseFirestore.instance;

  NoticeRepository(this._ref);

  Future<NoticeStateModel> getNotice() async {
    DocumentSnapshot carpool =
        await _fireStore.collection('admin').doc("carpoolList").get();

    DocumentSnapshot main =
    await _fireStore.collection('admin').doc("mainList").get();

    return NoticeStateModel(
      carpoolContext : carpool.get('context'),
      carpoolUri : carpool.get('uri'),
      mainContext: main.get('context'),
      mainUri: main.get('uri'),
    );
  }
}
