import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/UserDTO.dart';

import '../../common/constants.dart';

/// 0918 이상훈 - 서버 db에 유저 정보 관련 api
class ApiUser {
  //유저 닉네임 업데이트
  /// 신고 하기 (저장)
  Future<bool> updateUserNickname(
      String myUid, String newNickName) async {
    final String apiUrl = '$baseUrl/user/update/$myUid/$newNickName';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(jsonDecode(utf8.decoder.convert(response.bodyBytes)));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> saveUser(UserRequstDTO userDTO) async {
     String apiUrl = '$baseUrl/user/save';
    final String requestBody = jsonEncode(userDTO);
    try{
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
      if(response.statusCode == 200) {
        return true;
      } else {
        print("에러 코드 ${response.statusCode}");
        return false;
      }
    } catch(e) {
      print(e);
      return false;
    }

  }

  Future<List<String>> getAllCarIdsForUser(String userId) async {
    String apiUrl = '$baseUrl/user/selectList/$userId';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final List<String> carIds = List<String>.from(json.decode(response.body));
      print('API Response: ${utf8.decode(response.body.runes.toList())}');
      return carIds; // API 응답을 반환
    } catch (e) {
      print(e);
      return List<String>.empty();
    }
  }
}
