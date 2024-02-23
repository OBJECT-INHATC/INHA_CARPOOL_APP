
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../service/sv_carpool.dart';
import 'state.dart';

final carpoolProvider =
    StateNotifierProvider<CarpoolStateNotifier, List<CarpoolState>>(
  (ref) => CarpoolStateNotifier(ref),
);

class CarpoolStateNotifier extends StateNotifier<List<CarpoolState>> {
  final Ref _ref;
  final CarpoolService apiService = CarpoolService();

  CarpoolStateNotifier(this._ref) : super([]);

  /// 시간순으로 서버 통해서 새로 조회 (새로고침 및 앱 처음 실행시만)
  Future<void> loadCarpoolTimeBy() async {
    try {
       state = await apiService.timeByFunction(5, null);
    } catch (error) {

      rethrow;
    }
  }

  /// 거리순으로 기존 상태 새로고침
  Future<void> loadCarpoolNearBy(LatLng myPoint) async {
    print("거리순 조회");
    try {
      List<CarpoolState> carpools = [];

      for(int i = 0; i < state.length; i++){
        state[i].distance = _calculateDistance(myPoint, state[i].startPoint);
        carpools.add(state[i]);
      }
      carpools.sort((a, b) => a.distance!.compareTo(b.distance!));

      state = carpools;

    } catch (error) {
      rethrow;
    }
  }

  /// 시간순으로 기존 상태 새로고침
  Future<void> loadCarpoolStateTimeBy() async {
    try {
      List<CarpoolState> carpools = [];

      for(int i = 0; i < state.length; i++){
        carpools.add(state[i]);
      }

      carpools.sort((a, b) => a.startTime!.compareTo(b.startTime!));

      state = carpools;

    } catch (error) {
      rethrow;
    }
  }

  /// 거리 계산
  double _calculateDistance(
      LatLng myLatLng,
      LatLng startLatLng,
      ) {
    double distanceInMeters = Geolocator.distanceBetween(
        myLatLng.latitude,
        myLatLng.longitude,
        startLatLng.latitude,
        startLatLng.longitude
    );

    return distanceInMeters / 1000;
  }
}
