import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';

import '../../dto/ReportRequstDTO.dart';

class ApiService {
  final String baseUrl = dotenv.env['BASE_URL']!; // API 서버의 URL

  Future<http.Response> selectReportList(String myId) async {
    final String apiUrl = '$baseUrl/report/select/$myId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(jsonDecode(utf8.decoder.convert(response.bodyBytes)));
    return response;
  }

  /// 신고 하기 (저장)__피드백 포함
  Future<bool> saveReport(ReportRequstDTO reportRequstDTO) async {
    final String apiUrl = '$baseUrl/report/save';

    // ReportRequstDTO 객체를 JSON 문자열로 변환
    final String requestBody = jsonEncode(reportRequstDTO);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
      // 성공적으로 API 요청을 보냈을 때 처리할 코드

      print('API Response: ${utf8.decode(response.body.runes.toList())}');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // 건의사항 저장
  // Future<bool> saveSuggest(ReportRequstDTO reportRequstDTO) async {
  //   const String apiUrl = '$baseUrl/report/saveSuggestion';
  //
  //   // ReportRequstDTO 객체를 JSON 문자열로 변환
  //   final String requestBody = jsonEncode(reportRequstDTO);
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: requestBody,
  //     );
  //     // 성공적으로 API 요청을 보냈을 때 처리할 코드
  //
  //     print('API Response: ${utf8.decode(response.body.runes.toList())}');
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }catch(e){
  //     print(e);
  //     return false;
  //   }
  // }


  /// 이용 내역 (저장)
  Future<http.Response> saveHistory(HistoryRequestDTO historyRequestDTO) async {
    final String apiUrl = '$baseUrl/history/save'; // API 엔드포인트 URL

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

  /// 이용 내역 조회
  Future<http.Response> selectHistoryList(String uid) async {
    final String apiUrl = '$baseUrl/history/select'; // API 엔드포인트 URL

    final Uri uri = Uri.parse(apiUrl).replace(
      // 쿼리 스트링 추가
      queryParameters: {'uid': uid},
    );

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(response.body.isEmpty);

    if (response.statusCode == 200) {
      // 성공적으로 API 요청을 보냈을 때 처리할 코드
      print('API Response: ${utf8.decode(response.body.runes.toList())}');
      return response; // API 응답을 반환
    } else if (response.statusCode == 204) {
      // API 요청이 204 상태 코드(No Content)일 경우 처리할 코드
      print('참여중인 카풀이 없습니다.');
      return response; // API 응답을 반환
    } else {
      // API 요청이 실패한 경우 처리할 코드
      print('Failed to select history: ${response.statusCode}');
      return response; // API 응답을 반환
    }
  }
}
