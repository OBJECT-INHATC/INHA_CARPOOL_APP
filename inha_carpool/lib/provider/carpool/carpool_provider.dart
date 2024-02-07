import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/carpool/repository/carpool_repository.dart';
import 'package:inha_Carpool/provider/carpool/state/carpool_state.dart';
import 'package:meta/meta.dart';

import '../../common/models/m_carpool.dart';
import '../../common/models/m_member.dart';
import '../auth/auth_provider.dart';

/// 참여중인 카풀의 수를 관리하는 provider 0207 이상훈

final participatingCarpoolProvider =
    StateNotifierProvider<CarpoolProvider, CarPoolState>(
  (ref) {
    final carpoolRepository = ref.read(carpoolRepositoryProvider);
    final provider = CarpoolProvider(ref, repository: carpoolRepository);
    provider.getCarpool(ref.read(authProvider.notifier).state); // 초기 상태 설정

    return provider;
  },
);

class CarpoolProvider extends StateNotifier<CarPoolState> {
  final Ref _ref;
  final CarpoolRepository repository;


  CarpoolProvider(this._ref, {required this.repository})
      : super(CarPoolState(data: [])) {
    getCarpool(_ref.read(authProvider.notifier).state);
  }

  Future getCarpool(MemberModel memberModel) async {

    print("GetCarpool: ${memberModel.uid}");
    print("GetCarpool: ${memberModel.nickName}");
    print("GetCarpool: ${memberModel.userName}");
    print("GetCarpool: ${memberModel.email}");

    try {
      List<CarpoolModel> carpoolList = await repository.getCarPoolList(memberModel);
      state = state.copyWith(data: carpoolList);
    } catch (e) {
      print("CarpoolProvider [getCarpool] 에러: $e");
    }
  }

  // 카풀리스트를 추가
  Future addCarpool(CarpoolModel carpoolModel) async {
    try {
      state = state.copyWith(data: [...state.data, carpoolModel]);
    } catch (e) {
      print("CarpoolProvider [addCarpool] 에러: $e");
    }
  }

  //카풀 리스트에서 제거
  Future removeCarpool(String carId) async {
    try {
      state = state.copyWith(data: state.data.where((element) => element.carId != carId).toList());
    } catch (e) {
      print("CarpoolProvider [removeCarpool] 에러: $e");
    }
  }


}
