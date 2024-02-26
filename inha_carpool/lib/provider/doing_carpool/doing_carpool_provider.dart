import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/m_carpool.dart';
import '../stateProvider/auth_provider.dart';
import 'repository/doing_carpool_repository.dart';
import 'state/doing_carpool_state.dart';

///* 참여중인 카풀의 수를 관리하는 provider 0207 이상훈///

final doingFirstStateProvider = StateProvider((ref) => CarpoolModel());

final doingCarpoolNotifierProvider =
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
      print("getCarpool");
      List<CarpoolModel> carpoolList =
          await repository.getCarPoolList(_ref.read(authProvider));
      state = carpoolList;

      if (state.isNotEmpty) {
        /// 첫번째 값 별도 저장
        _ref.read(doingFirstStateProvider.notifier).state =
            await getNearestCarpool();
      }
    } catch (e) {
      print("CarpoolProvider [getCarpool] 에러: $e");
    }
  }

  Future<CarpoolModel> getNearestCarpool() async {
    try {
      final now = DateTime.now();
       List<CarpoolModel> carpoolList = state;
      if (carpoolList.length == 1) {
        return carpoolList.first;
      }

      if (carpoolList.isNotEmpty) {
        return carpoolList.reduce((a, b) {
          final aDiff =
              now.difference(DateTime.fromMillisecondsSinceEpoch(a.startTime!));
          final bDiff =
              now.difference(DateTime.fromMillisecondsSinceEpoch(b.startTime!));

          return aDiff.abs() < bDiff.abs() ? a : b;
        });
      } else {
        print("GetNearestCarpool : 참여중인 카풀이 없습니다.");
        return CarpoolModel();
      }
    } catch (e) {
      print("CarpoolProvider [getNearestCarpool] 에러: $e");
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

  // 생성하거나 참여한 카풀리스트를 상태관리에 추가
  Future addCarpool(CarpoolModel carpoolModel) async {
    try {
      // 새로운 carpoolModel을 맨 앞에 추가
      state.insert(0, carpoolModel);
      if (state.length == 1) {
        _ref.read(doingFirstStateProvider.notifier).state = carpoolModel;
      } else {
        _ref.read(doingFirstStateProvider.notifier).state =
            await getNearestCarpool();
      }
    } catch (e) {
      print("CarpoolProvider [addCarpool] 에러: $e");
    }
  }

  // 방에서 나간 카풀을 상태관리에서 제거
  Future removeCarpool(String carId) async {
    try {
      state = state.where((element) => element.carId != carId).toList();

      _ref.read(doingFirstStateProvider.notifier).state =
          await getNearestCarpool();

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
