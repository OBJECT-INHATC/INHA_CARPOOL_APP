import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/UserDTO.dart';

import '../../common/constants.dart';
import '../../dto/ReportRequstDTO.dart';

/// 0918 이상훈 - 서버 db에 유저 정보 관련 api
class ApiUser {
  //유저 닉네임 업데이트
  ///TOdo: 지윤이가 고치면 이거 추가하기 (닉네임 중복체크)
  /// 신고 하기 (저장)
  Future<http.Response> updateUserNickname(
      String myUid, String newNickName) async {
    final String apiUrl = '$baseUrl/user/update/$myUid/$newNickName';

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(jsonDecode(utf8.decoder.convert(response.bodyBytes)));
    return response;
  }

  Future<http.Response> saveUser(UserRequstDTO userDTO) async {
     String apiUrl = '$baseUrl/user/save';
    final String requestBody = jsonEncode(userDTO);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',  
      },
      body: requestBody,
    );
    print('API Response: ${utf8.decode(response.body.runes.toList())}');
    return response; // API 응답을 반환
  }

  Future<List<String>> getAllCarIdsForUser(String userId) async {
    String apiUrl = '$baseUrl/user/selectList/$userId';

    final response = await http.get(Uri.parse(apiUrl));
    final List<String> carIds = List<String>.from(json.decode(response.body));
    print('API Response: ${utf8.decode(response.body.runes.toList())}');

    return carIds; // API 응답을 반환


  }
}