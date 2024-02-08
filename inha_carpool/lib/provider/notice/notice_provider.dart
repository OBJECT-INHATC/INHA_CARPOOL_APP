import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/carpool/repository/carpool_repository.dart';
import 'package:inha_Carpool/provider/carpool/state/carpool_state.dart';
import 'package:inha_Carpool/provider/notice/repository/notice_repository.dart';
import 'package:inha_Carpool/provider/notice/state/notice_state.dart';

import '../../common/models/m_carpool.dart';
import '../../common/models/m_member.dart';
import '../auth/auth_provider.dart';

///* 공지사항을 관리하는 provider 0207 이상훈

final noticeNotifierProvider =
    StateNotifierProvider<NoticeStateNotifier, NoticeStateModel>(
  (ref) => NoticeStateNotifier(ref, repository: ref.read(noticeRepositoryProvider)),
);


class NoticeStateNotifier extends StateNotifier<NoticeStateModel> {
  final Ref _ref;
  final NoticeRepository repository;

  //생성자
  NoticeStateNotifier(this._ref, {required this.repository})
      : super(const NoticeStateModel(context: '', uri: ''));

  Future getNotice(String noticeType) async {
    try {
      NoticeStateModel noticeStateModel = await repository.getCarpoolListNoticeList(noticeType);
      state = state.copyWith(context: noticeStateModel.context, uri: noticeStateModel.uri);
    } catch (e) {
      print("NoticeStateNotifier [getNotice] 에러: $e");
    }
  }

}
