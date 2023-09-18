import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/TopicDTO.dart';
import 'package:inha_Carpool/dto/UserDTO.dart';

import '../../common/constants.dart';

/// 0918 이상훈 - 서버 db에 Topic 정보 관련 api
class ApiTopic {
  Future<http.Response> saveTopoic(TopicRequstDTO topicRequstDTO) async {
    String apiUrl = '$LocalHoonUrl/topic/save';
    final String requestBody = jsonEncode(topicRequstDTO);

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

  Future<http.Response> deleteTopic(String uid, String carId) async {
    String apiUrl = '$LocalHoonUrl/topic/delete';

    final response = await http.delete(
      Uri.parse('$apiUrl?uid=$uid&carId=$carId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('API Response: ${utf8.decode(response.body.runes.toList())}');
    return response; // API 응답을 반환
  }
}
