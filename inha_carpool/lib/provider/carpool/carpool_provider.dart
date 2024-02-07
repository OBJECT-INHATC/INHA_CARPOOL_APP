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
    return CarpoolProvider(ref, repository: carpoolRepository);
  },
);


@immutable
class CarPoolState {
  final List<CarpoolModel> data;

  CarPoolState({required this.data});

  CarPoolState copyWith({List<CarpoolModel>? data}) {
    return CarPoolState(data: data ?? this.data);
  }
}

class CarpoolProvider extends StateNotifier<CarPoolState> {
  final Ref _ref;
  final CarpoolRepository repository;
  CarpoolModel? carpoolModel;

  CarpoolProvider(this._ref, {required this.repository})
      : super(CarPoolState(data: [])) {
    getCarpool(_ref.read(authProvider.notifier).state);
  }

  Future getCarpool(MemberModel memberModel) async {
    try {
      print(
          "====================================getCarpool start==========================");
      List<CarpoolModel> carpoolList = await repository.getCarPoolList(memberModel);
      state = state.copyWith(data: carpoolList);
    } catch (e) {}
  }

  //가지고 있는 리스트 수 반환
  int get carpoolListLength {
    if (state is CarPoolState) {
      print("================================================================");
      print("레파에서 조회한 참여중인 카풀수: ${state.data.length}");
      return (state).data.length;
    } else {
      return 0;
    }
  }
}
