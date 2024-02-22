import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/api/Api_repot.dart';
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

  Future<List<CarpoolState>> loadCarpoolTimeby() async {
    try {
       state = await apiService.timeByFunction(5, null);

      print("State.lenth : ${state.length}");

      return state;

    } catch (error) {

      rethrow;
    }
  }
}
