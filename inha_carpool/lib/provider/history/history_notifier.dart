import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/stateProvider/auth_provider.dart';

import '../../../../../dto/history_request_dto.dart';
import '../../../../../service/api/Api_repot.dart';

/// 이용기록을 관리하는 상태 0221 이상훈
final historyProvider =
StateNotifierProvider<HistoryStateNotifier, List<HistoryRequestDTO>>(
      (ref) => HistoryStateNotifier(ref),
);

class HistoryStateNotifier extends StateNotifier<List<HistoryRequestDTO>> {
  final Ref _ref;
  final ApiService apiService = ApiService();

  String _errorMessage = '';

  HistoryStateNotifier(this._ref) : super([]);


  Future<void> loadHistoryData() async {
    final uid = _ref.read(authProvider).uid;
    if (uid == null) {
      throw Exception('로그인 되있지 않음');
    }

    try {
      final response = await apiService.selectHistoryList(uid);

      if (response.statusCode == 200) {
        final List<dynamic> histories =
        jsonDecode(utf8.decode(response.body.runes.toList()));

        final historyList = histories
            .map((data) => HistoryRequestDTO.fromJson(data))
            .toList();

        print("카풀 이용 내역 횟수 : ${historyList.length}");

        historyList.sort((a, b) => b.startTime.compareTo(a.startTime));

        state = historyList;
        _errorMessage = '';
      } else if (response.statusCode == 204) {
        // 카풀 이용 내역이 없는 경우
        state = [];
        _errorMessage = '이용기록 없음';
      } else {
        final message =
            '이용기록 조회 실패 (status code: ${response.statusCode})';
        throw Exception(message);
      }
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    }
  }

  String get errorMessage => _errorMessage;
}
