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

  Future<void> loadCarpoolTimeby() async {
    try {
      final response = await apiService.timeByFunction();



        final List<dynamic> carpoolTimeby =
            jsonDecode(utf8.decode(response.body.runes.toList()));
        final carpoolList =
            carpoolTimeby.map((data) => CarpoolState.fromJson(data)).toList();
        state = carpoolList;

    } catch (error) {
      rethrow;
    }
  }
}
