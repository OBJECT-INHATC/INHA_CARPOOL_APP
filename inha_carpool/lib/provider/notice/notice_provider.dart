import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/notice/repository/notice_repository.dart';
import 'package:inha_Carpool/provider/notice/state/notice_state.dart';



///* 공지사항을 관리하는 provider 0207 이상훈

final noticeNotifierProvider =
    StateNotifierProvider<NoticeStateNotifier, NoticeStateModel>(
  (ref) =>
      NoticeStateNotifier(ref, repository: ref.read(noticeRepositoryProvider)),
);

class NoticeStateNotifier extends StateNotifier<NoticeStateModel> {
  final Ref _ref;
  final NoticeRepository repository;

  //생성자
  NoticeStateNotifier(this._ref, {required this.repository})
      : super(const NoticeStateModel(
            carpoolContext: "", carpoolUri: "", mainContext: "", mainUri: "")){
    // 생성과 함께 파이어스토어에서 데이터를 가져와서 초기화
    getNotice();
  }

  Future getNotice() async {
    try {
      NoticeStateModel noticeStateModel = await repository.getNotice();
      state = state.copyWith(
          carpoolContext: noticeStateModel.carpoolContext,
          carpoolUri: noticeStateModel.carpoolUri,
          mainContext: noticeStateModel.mainContext,
          mainUri: noticeStateModel.mainUri);
    } catch (e) {
      print("NoticeStateNotifier [getNotice] 에러: $e");
    }
  }
}
