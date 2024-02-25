import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHandler {

  static Future<void> getCurrentLocation(
      BuildContext context,
      Function(LatLng) onLocationReceived,
      ) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showLocationPermissionSnackBar(context);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    onLocationReceived(LatLng(position.latitude, position.longitude));
  }




  // 기존 함수
  static Future<LatLng?> getCurrentLatLng(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showLocationPermissionSnackBar(context);
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }


  static Future<LatLng?> getCurrentLocationTest(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showLocationPermissionSnackBar(context);
        return const LatLng(37.4514982, 126.6570261);
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  static void showLocationPermissionSnackBar(BuildContext context) {
    SnackBar snackBar = SnackBar(
      content: const Text("위치 권한이 필요한 서비스입니다."),
      action: SnackBarAction(
        label: "설정으로 이동",
        onPressed: () {
          AppSettings.openAppSettings();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 위도 경도를 제외한 주소의 값을 가져옴
  static String getStringBetweenUnderscores(String input) {
    final firstUnderscoreIndex = input.indexOf('_');
    if (firstUnderscoreIndex >= 0) {
      final remainingString =
      input.substring(firstUnderscoreIndex + 1); // 첫 번째 '_' 이후의 문자열을 가져옴
      final secondUnderscoreIndex = remainingString.indexOf('_');
      if (secondUnderscoreIndex >= 0) {
        final stringBetweenUnderscores = remainingString.substring(
            0, secondUnderscoreIndex); // 첫 번째 '_'와 두 번째 '_' 사이의 문자열을 가져옴
        return stringBetweenUnderscores;
      }
    }
    return ''; // 어떤 '_'도 찾지 못하거나 두 번째 '_' 이후에 문자열이 없을 경우 빈 문자열을 리턴
  }

  static double parseDoubleBeforeUnderscore(String input) {
    final indexOfUnderscore = input.indexOf('_');
    if (indexOfUnderscore >= 0) {
      final doublePart = input.substring(0, indexOfUnderscore);
      return double.tryParse(doublePart) ?? 0.0; // 문자열을 더블로 파싱하고 실패하면 0.0을 리턴
    }
    return 0.0; // '_'가 없을 경우에는 0.0을 리턴
  }

  static double getDoubleAfterSecondUnderscore(String input) {
    final firstUnderscoreIndex = input.indexOf('_');
    if (firstUnderscoreIndex >= 0) {
      final remainingString =
      input.substring(firstUnderscoreIndex + 1); // 첫 번째 '_' 이후의 문자열을 가져옴
      final secondUnderscoreIndex = remainingString.indexOf('_');
      if (secondUnderscoreIndex >= 0) {
        final doubleString = remainingString
            .substring(secondUnderscoreIndex + 1); // 두 번째 '_' 이후의 문자열을 가져옴
        return double.tryParse(doubleString) ??
            0.0; // 문자열을 더블로 변환하고 실패할 경우 0.0을 리턴
      }
    }
    return 0.0; // 어떤 '_'도 찾지 못하거나 두 번째 '_' 이후에 문자열이 없을 경우 0.0을 리턴
  }




}
