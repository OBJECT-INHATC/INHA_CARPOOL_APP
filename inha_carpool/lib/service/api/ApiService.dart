import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';

import '../../common/constants.dart';
import '../../dto/ReportRequstDTO.dart';

class ApiService {

  /// 신고 하기 (저장)
  Future<http.Response> saveReport(ReportRequstDTO reportRequstDTO) async {
    const String apiUrl = '$baseUrl/report/save'; // API 엔드포인트 URL

    // ReportRequstDTO 객체를 JSON 문자열로 변환
    final String requestBody = jsonEncode(reportRequstDTO);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );


    if (response.statusCode == 200) {
      // 성공적으로 API 요청을 보냈을 때 처리할 코드

      print('API Response: ${utf8.decode(response.body.runes.toList())}');
      return response; // API 응답을 반환

    } else {
      // API 요청이 실패한 경우 처리할 코드
      print('Failed to save report: ${response.statusCode}');
      return response; // API 응답을 반환
    }

  }


  /// 이용 내역 (저장)
  Future<http.Response> saveHistory(HistoryRequestDTO historyRequestDTO) async {
    const String apiUrl = '$baseUrl/history/save'; // API 엔드포인트 URL

    // HistoryRequestDTO 객체를 JSON 문자열로 변환
    final String requestBody = jsonEncode(historyRequestDTO);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      // 성공적으로 API 요청을 보냈을 때 처리할 코드

      print('API Response: ${utf8.decode(response.body.runes.toList())}');
      return response; // API 응답을 반환

    } else {
      // API 요청이 실패한 경우 처리할 코드
      print('Failed to save report: ${response.statusCode}');
      return response; // API 응답을 반환
    }

  }
}