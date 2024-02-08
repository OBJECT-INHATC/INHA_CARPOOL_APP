import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../state/notice_state.dart';

final noticeRepositoryProvider = Provider((ref) => NoticeRepository(ref));

class NoticeRepository {
  final Ref _ref;
  final _fireStore = FirebaseFirestore.instance;

  NoticeRepository(this._ref);

  Future<NoticeStateModel> getCarpoolListNoticeList(String noticeType) async {
    DocumentSnapshot documentSnapshot =
        await _fireStore.collection('admin').doc(noticeType).get();

    return NoticeStateModel(
      context: documentSnapshot.get('context'),
      uri: documentSnapshot.get('uri'),
    );
  }
}
