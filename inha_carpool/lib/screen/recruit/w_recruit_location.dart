import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/recruit/s_locationMap.dart';

class LocationInputWidget extends StatefulWidget {
  String labelText; // 생성자에서 받아온 문자열을 저장할 변수
  String pointText;
  final LatLng Point; // 출발지인지 도착지인지
  final ValueChanged<String> onLocationSelected;
  bool isGestureEnabled = true;

  LocationInputWidget(
      {super.key, required this.labelText,
      required this.Point,
      required this.pointText, required this.onLocationSelected}); // 생성자 추가

  @override
  _LocationInputWidgetState createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  String selectedLocation = '';
  bool isGestureEnabled = true;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.labelText;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGestureEnabled ? () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LocationInputPage(widget.Point)),
        );

        if (result != null) {
          setState(() {
            selectedLocation = getStringBetweenUnderscores(result);
            isGestureEnabled = false; // Tap 이벤트 비활성화
          });
          widget.onLocationSelected(result);
        }
      } : null, // isGestureEnabled가 false일 때는 onTap 이벤트 비활성화
      child: Container(
        margin: EdgeInsets.fromLTRB(30, 30, 30, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 13),
              child: widget.pointText.text.size(16).bold.black.make(),
            ),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
              controller: TextEditingController(text: selectedLocation),
            ),
          ],
        ),
      ),
    );
  }



  String getStringBetweenUnderscores(String input) {
    final firstUnderscoreIndex = input.indexOf('_');
    if (firstUnderscoreIndex >= 0) {
      final remainingString = input.substring(firstUnderscoreIndex + 1); // 첫 번째 '_' 이후의 문자열을 가져옴
      final secondUnderscoreIndex = remainingString.indexOf('_');
      if (secondUnderscoreIndex >= 0) {
        final stringBetweenUnderscores = remainingString.substring(0, secondUnderscoreIndex); // 첫 번째 '_'와 두 번째 '_' 사이의 문자열을 가져옴
        return stringBetweenUnderscores;
      }
    }
    return ''; // 어떤 '_'도 찾지 못하거나 두 번째 '_' 이후에 문자열이 없을 경우 빈 문자열을 리턴
  }

}
