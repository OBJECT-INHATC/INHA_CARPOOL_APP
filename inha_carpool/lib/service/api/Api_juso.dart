import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class ApiJuso {
  static const _baseUrl = 'https://business.juso.go.kr/addrlink/addrLinkApi.do';

  Future<List<String>> getAddresses(String query, String apiKey) async {
    try {
      final url = Uri.parse(_baseUrl);
      final params = {
        'confmKey': apiKey,
        'keyword': query,
        'resultType': 'json',
      };

      final response = await http.post(url, body: params, headers: {
        'content-type': 'application/x-www-form-urlencoded',
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final jusoList = json['results']['juso'] as List;

        if (jusoList.isNotEmpty) {
          return jusoList.map((juso) => '${juso['roadAddr']}, ${juso['bdNm']}').toList();
        } else {
          return [];
        }
      } else {
        log('Error: Status code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching addresses: $e');
      return [];
    }
  }
}
