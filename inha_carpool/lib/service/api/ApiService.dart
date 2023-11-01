import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';

import '../../common/constants.dart';
import '../../dto/ReportRequstDTO.dart';

class ApiService {


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

  /// 신고 하기 (저장)
  Future<http.Response> saveReport(ReportRequstDTO reportRequstDTO) async {
    const String apiUrl = '$baseUrl/report/save';

    // ReportRequstDTO 객체를 JSON 문자열로 변환
    final String requestBody = jsonEncode(reportRequstDTO);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );
    // 성공적으로 API 요청을 보냈을 때 처리할 코드

    print('API Response: ${utf8.decode(response.body.runes.toList())}');
    return response; // API 응답을 반환
  }


  /// 이용 내역 (저장)
  Future<http.Response> saveHistory(HistoryResponsetDTO historyRequestDTO) async {
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

  /// 이용 내역 조회
  Future<http.Response> selectHistoryList(String uid, String nickName) async {
    String apiUrl = '$baseUrl/history/select'; // API 엔드포인트 URL

    print(apiUrl);
    final Uri uri = Uri.parse(apiUrl).replace( // 쿼리 스트링 추가
      queryParameters: {
        'uid': uid,
        'nickName': nickName,
      },
    );

    print(uri);
    print(uid + "_" + nickName);

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // 성공적으로 API 요청을 보냈을 때 처리할 코드

      print('API Response: ${utf8.decode(response.body.runes.toList())}');
      return response; // API 응답을 반환

    } else {
      // API 요청이 실패한 경우 처리할 코드
      print(response.body);
      print('Failed to select report: ${response.statusCode}');
      return response; // API 응답을 반환
    }

  }

}
