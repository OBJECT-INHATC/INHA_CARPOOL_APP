import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/carpool/repository/carpool_repository.dart';
import 'package:inha_Carpool/provider/carpool/state/carpool_state.dart';

import '../../common/models/m_carpool.dart';
import '../../common/models/m_member.dart';
import '../auth/auth_provider.dart';
/// 참여중인 카풀의 수를 관리하는 provider 0207 이상훈

final participatingCarpoolProvider =
    StateNotifierProvider<CarpoolProvider, CarPoolStateBase>(
  (ref) {
    final carpoolRepository = ref.read(carpoolRepositoryProvider);
    return CarpoolProvider(ref, repository: carpoolRepository);
  },
);


class CarpoolProvider
    extends StateNotifier<CarPoolStateBase> {
  final Ref _ref;
  final CarpoolRepository repository;
  CarpoolModel? carpoolModel;

  CarpoolProvider(this._ref, {required this.repository})
      : super(CarPoolStateLoading()){
    getCarpool(_ref.read(authProvider.notifier).state);
  }

  Future getCarpool(MemberModel memberModel) async {
    try {
      List<CarpoolModel> carpoolList = await repository.getCarPoolList(memberModel);
      state = CarPoolState(data: carpoolList);

      print('state' + state.toString());
    } catch (e) {
      state = CarPoolStateError(error: e.toString());
    }
  }

  //가지고 있는 리스트 수 반환
  int get carpoolListLength {
    if (state is CarPoolState) {
      return (state as CarPoolState).data.length;
    } else {
      return 0;
    }
  }


}