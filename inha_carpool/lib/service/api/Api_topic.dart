import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/TopicDTO.dart';

import '../../common/constants.dart';

/// 0918 이상훈 - 서버 db에 Topic 정보 관련 api -> bool 타입 반환
class ApiTopic {

  Future<bool> saveTopoic(TopicRequstDTO topicRequstDTO) async {
    String apiUrl = '$baseUrl/topic/save';
    final String requestBody = jsonEncode(topicRequstDTO);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
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

  Future<bool> deleteTopic(String uid, String carId) async {
    String apiUrl = '$baseUrl/topic/delete';

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl?uid=$uid&carId=$carId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('API Response: ${utf8.decode(response.body.runes.toList())}');
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
}
