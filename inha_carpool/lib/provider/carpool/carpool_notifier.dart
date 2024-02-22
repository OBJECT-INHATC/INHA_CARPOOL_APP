import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/api/Api_repot.dart';
import 'state.dart';

final carpoolProvider =
StateNotifierProvider<CarpoolStateNotifier, List<CarpoolState>>(
      (ref) => CarpoolStateNotifier(ref),
);

class CarpoolStateNotifier extends StateNotifier<List<CarpoolState>> {
  final Ref _ref;
  final ApiService apiService = ApiService();

  CarpoolStateNotifier(this._ref) : super([]);


}