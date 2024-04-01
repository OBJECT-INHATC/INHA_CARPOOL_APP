import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiJuso {
  static const _baseUrl = 'https://business.juso.go.kr/addrlink/addrLinkApi.do';
  final String? _naverClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
  final String? _naverClientSecret = dotenv.env['NAVER_MAP_CLIENT_SECRET'];
  final String _naverHost =
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';

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
          return jusoList
              .map((juso) => '${juso['roadAddr']}, ${juso['bdNm']}')
              .toList();
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

  Future<List<String>> getAddressesByLatLon(double lat, double lon) async {
    String? uri =
        '$_naverHost?&coords=$lon,$lat&orders=admcode,legalcode,addr,roadaddr&output=json';
    List<Map<String, dynamic>> addressList = [];

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': _naverClientId!,
        'X-NCP-APIGW-API-KEY': _naverClientSecret!,
      },
    );

    final responseJson = json.decode(response.body);

    if (responseJson['results'] != null && responseJson['results'].length > 0) {
      final addressResults = responseJson['results'];

      for (var result in addressResults) {
        Map<String, dynamic> addressInfo = {};

        if (result['region'] != null || result['land'] != null) {
          final region = result['region'];
          final land = result['land'];

          // 주소 정보 추출
          String area1 = region['area1']['name'];
          String area2 = region['area2']['name'];

          // 추출한 정보를 Map에 저장
          addressInfo['area1'] = area1;
          addressInfo['area2'] = area2;

          // 도로명 주소가 있는 경우
          if (land != null) {
            String? landName = land['name'];
            String? landNumber1 = land['number1'];
            String? landNumber2 = land['number2'];
            String? addition0 = land['addition0']['value'];

            // 추출한 정보를 Map에 저장
            if (landName != null) {
              addressInfo['name'] = landName;
            }
            if (landNumber1 != null) {
              addressInfo['number1'] = landNumber1;
            }
            if (landNumber2 != null) {
              addressInfo['number2'] = landNumber2;
            }
            if (addition0 != null) {
              addressInfo['addition0'] = addition0;
            }
          }

          // 리스트에 주소 정보 추가
        }
        addressList.add(addressInfo);
      }


      /// 첫 번째 결과를 사용하여 _address 변수에 상세 주소 설정
      if (addressList.isNotEmpty) {
        String address =
            '${addressList[0]['area1']} ${addressList[0]['area2']}';

        // 추가 상세 주소 정보가 있는 경우 추가
        String? landName = addressList[addressList.length - 1]['name'];
        String? landNumber1 = addressList[addressList.length - 1]['number1'];
        String? landNumber2 = addressList[addressList.length - 1]['number2'];
        String? addition0 = addressList[addressList.length - 1]['addition0'];

        if (landName != null && landName.isNotEmpty) {
          address += ' $landName';
        }
        if (landNumber1 != null && landNumber1.isNotEmpty) {
          address += ' $landNumber1';
        }
        if (landNumber2 != null && landNumber2.isNotEmpty) {
          address += '-$landNumber2';
        }
        if (addition0 != null && addition0.isNotEmpty) {
          address += ' $addition0';
        }

        print('--------------------------------------');
        print("API 호출로 리턴하는 주소 : $address");
        print('--------------------------------------');
        return [address];

        /// 주소 정보가 없을 때
      } else {
        return [];
      }
      /// 주소 정보가 없을 때
    } else {
      return [];
    }
  }
}
