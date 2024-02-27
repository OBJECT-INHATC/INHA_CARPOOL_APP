import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/m_carpool.dart';
import '../stateProvider/auth_provider.dart';
import 'repository/doing_carpool_repository.dart';

///* 참여중인 카풀의 수를 관리하는 provider 0207 이상훈///

final floatingProvider = StateProvider((ref) => CarpoolModel());

final doingProvider =
    StateNotifierProvider<CarpoolStateNotifier, List<CarpoolModel>>(
  (ref) => CarpoolStateNotifier(ref,
      repository: ref.read(carpoolRepositoryProvider)),
);

class CarpoolStateNotifier extends StateNotifier<List<CarpoolModel>> {
  final Ref _ref;
  final DoingCarpoolRepository repository;

  //생성자
  CarpoolStateNotifier(this._ref, {required this.repository})
      : super(<CarpoolModel>[]);


  // 내가 참여중인 카풀리스트 상태관리로 가져오기
  Future getCarpool() async {
    try {
      List<CarpoolModel> carpoolList =
          await repository.getCarPoolList(_ref.read(authProvider));
      state = carpoolList;

      if (state.isNotEmpty) {
        /// 첫번째 값 별도 저장
        _ref.read(floatingProvider.notifier).state =
            await getNearest();
      }else{
        _ref.read(floatingProvider.notifier).state = CarpoolModel();
      }
    } catch (e) {
      print("CarpoolProvider [getCarpool] 에러: $e");
    }
  }

  // 생성하거나 참여한 카풀리스트를 상태관리에 추가
  Future addCarpool(CarpoolModel carpoolModel) async {

    try {
      // 새로운 carpoolModel을 맨 앞에 추가 -> 상태를 잃으면 새로고침되기 때문에 가장 최근에 참여한 카풀이 상단에 일시적 위치
      state.insert(0, carpoolModel);

      if (state.length == 1) {
        _ref.read(floatingProvider.notifier).state = carpoolModel;
      } else {

        _ref.read(floatingProvider.notifier).state =
        await getNearest();
      }
    } catch (e) {
      print("CarpoolProvider [addCarpool] 에러: $e");
    }
  }

  Future<CarpoolModel> getNearest() async {
    try {
      final now = DateTime.now();
      List<CarpoolModel> carpoolList = state;

      // Check for single element and return directly
      if (carpoolList.length == 1) {
        return carpoolList.first;
      }

      if (carpoolList.isNotEmpty) {
        // Find the nearest carpool among the top 2 (if applicable)

        CarpoolModel? nearestCarpool;
        Duration? minDiff;

        for (var carpool in carpoolList) {
          try {
            final startTime = DateTime.fromMillisecondsSinceEpoch(carpool.startTime!);
            // 현재 시간보다 미래인 경우만 처리
            if (startTime.isAfter(now)) {
              final diff = startTime.difference(now);
              if (minDiff == null || diff.inSeconds < minDiff.inSeconds) {
                minDiff = diff;
                nearestCarpool = carpool;
              }
            }
          } catch (e) {
            print("Error converting startTime for carpool: $e");
          }
        }

        if (nearestCarpool == null) {
          return CarpoolModel();
        }


        print("변경된 nearestCarpool: ${nearestCarpool.startDetailPoint}");
        return nearestCarpool;
      } else {
        print("GetNearestCarpool: No active carpools found.");
        return CarpoolModel();
      }
    } catch (e) {
      print("CarpoolProvider [getNearestCarpool] error: $e");
      return CarpoolModel();
    }
  }




  // 들고있는 카풀리스트에서 isChatAlarmOn을 carId로 읽어옴
  Future getAlarm(String carId) async {
    try {
      if (state.where((element) => element.carId == carId).isNotEmpty) {
        return state.where((element) => element.carId == carId).first.isChatAlarmOn;

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
      await repository.updateIsChatAlarm(
          carId, _ref.read(authProvider).uid!, isAlarm);
    } catch (e) {
      print("CarpoolProvider [updateAlarm] 에러: $e");
    }
  }


  // 방에서 나간 카풀을 상태관리에서 제거
  Future removeCarpool(String carId) async {
    try {
      state = state.where((element) => element.carId != carId).toList();

      _ref.read(floatingProvider.notifier).state =
          await getNearest();

    } catch (e) {
      print("CarpoolProvider [removeCarpool] 에러: $e");
    }
  }

  void setAlarm(String carId, bool bool) async {
    try {
      final updatedData = state.map((e) {
        if (e.carId == carId) {
          return e.copyWith(alarm: bool);
        } else {
          return e;
        }
      }).toList();

      state = updatedData;

      await updateAlarm(carId, bool);
    } catch (e) {
      print("CarpoolProvider [setAlarm] 에러: $e");
    }
  }
}
