import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/carpool/repository/carpool_repository.dart';
import 'package:inha_Carpool/provider/carpool/state/carpool_state.dart';

import '../../common/models/m_carpool.dart';
import '../../common/models/m_member.dart';
import '../auth/auth_provider.dart';

///* 참여중인 카풀의 수를 관리하는 provider 0207 이상훈

final participatingCarpoolProvider =
    StateNotifierProvider<CarpoolStateNotifier, CarPoolStateModel>(
  (ref) => CarpoolStateNotifier(ref, repository: ref.read(carpoolRepositoryProvider)),
);


class CarpoolStateNotifier extends StateNotifier<CarPoolStateModel> {
  final Ref _ref;
  final CarpoolRepository repository;

  //생성자
  CarpoolStateNotifier(this._ref, {required this.repository})
      : super(CarPoolStateModel(data: const [])) {
    // 생성과 함께 파이어스토어에서 데이터를 가져와서 초기화
    getCarpool(_ref.read(authProvider.notifier).state);
  }

  // 내가 참여중인 카풀리스트 상태관리로 가져오기
  Future getCarpool(MemberModel memberModel) async {
    try {
      List<CarpoolModel> carpoolList = await repository.getCarPoolList(memberModel);
      state = state.copyWith(data: carpoolList);
    } catch (e) {
      print("CarpoolProvider [getCarpool] 에러: $e");
    }
  }

  // 생성하거나 참여한 카풀리스트를 상태관리에 추가
  Future addCarpool(CarpoolModel carpoolModel) async {
    try {
      state = state.copyWith(data: [...state.data, carpoolModel]);
    } catch (e) {
      print("CarpoolProvider [addCarpool] 에러: $e");
    }
  }

  // 방에서 나간 카풀을 상태관리에서 제거
  Future removeCarpool(String carId) async {
    try {
      state = state.copyWith(data: state.data.where((element) => element.carId != carId).toList());
    } catch (e) {
      print("CarpoolProvider [removeCarpool] 에러: $e");
    }
  }
}
