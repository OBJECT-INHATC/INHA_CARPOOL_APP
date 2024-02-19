import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/current_carpool/repository/carpool_repository.dart';
import 'package:inha_Carpool/provider/current_carpool/state/carpool_state.dart';

import '../../common/models/m_carpool.dart';
import '../../common/models/m_member.dart';
import '../auth/auth_provider.dart';

///* 참여중인 카풀의 수를 관리하는 provider 0207 이상훈

final carpoolNotifierProvider =
    StateNotifierProvider<CarpoolStateNotifier, CarPoolStateModel>(
  (ref) => CarpoolStateNotifier(ref,
      repository: ref.read(carpoolRepositoryProvider)),
);

class CarpoolStateNotifier extends StateNotifier<CarPoolStateModel> {
  final Ref _ref;
  final CarpoolRepository repository;

  //생성자
  CarpoolStateNotifier(this._ref, {required this.repository})
      : super(const CarPoolStateModel(data: [])) {
    // 생성과 함께 파이어스토어에서 데이터를 가져와서 초기화
    getCarpool(_ref.read(authProvider.notifier).state);
  }

  // 내가 참여중인 카풀리스트 상태관리로 가져오기
  Future getCarpool(MemberModel memberModel) async {
    try {
      List<CarpoolModel> carpoolList =
          await repository.getCarPoolList(memberModel);
      state = state.copyWith(data: carpoolList);
    } catch (e) {
      print("CarpoolProvider [getCarpool] 에러: $e");
    }
  }

  // 들고있는 카풀리스트에서 isChatAlarmOn을 carId로 읽어옴
  Future getAlarm(String carId) async {
    try {
      if(state.data.where((element) => element.carId == carId).isNotEmpty){
        return state.data.where((element) => element.carId == carId).first.isChatAlarmOn;
      } else {
        return false;
      }
    } catch (e) {
      print("CarpoolProvider [getAlarm] 에러: $e");
      return false; // 또는 기본값으로 적합한 값을 반환할 수 있음
    }
  }




  Future updateAlarm(String carId, bool isAlarm) async {
    try {
      await repository.updateIsChatAlarm(carId, _ref.read(authProvider).uid!, isAlarm);
    } catch (e) {
      print("CarpoolProvider [updateAlarm] 에러: $e");
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
      state = state.copyWith(
          data: state.data.where((element) => element.carId != carId).toList());
    } catch (e) {
      print("CarpoolProvider [removeCarpool] 에러: $e");
    }
  }



  void setAlarm(String carId, bool bool) async {
    try {
      final updatedData = state.data.map((e) {
        if (e.carId == carId) {
          return e.copyWith(alarm: bool);
        } else {
          return e;
        }
      }).toList();

      state = state.copyWith(data: updatedData);


      await updateAlarm(carId, bool);
    } catch (e) {
      print("CarpoolProvider [setAlarm] 에러: $e");
    }
  }
}
