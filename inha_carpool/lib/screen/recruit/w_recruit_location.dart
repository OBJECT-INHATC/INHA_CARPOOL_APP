import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/recruit/s_locationMap.dart';

class LocationInputWidget extends StatefulWidget {
  String labelText; // 생성자에서 받아온 문자열을 저장할 변수
  String pointText;
  final LatLng Point; // 출발지인지 도착지인지

  LocationInputWidget(
      {super.key, required this.labelText,
      required this.Point,
      required this.pointText}); // 생성자 추가

  @override
  _LocationInputWidgetState createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  String selectedLocation = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LocationInputPage(widget.Point)),
        );

        if (result != null) {
          setState(() {
            widget.labelText = '';
            selectedLocation = result;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(30, 30, 30, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 13), // 여분의 여백 추가
              child: widget.pointText.text.size(16).bold.black.make(),
            ),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                labelText: widget.labelText, // 생성자에서 받아온 문자열 사용
                labelStyle: TextStyle(color: Colors.black), // labelText의 색상 설정
              ),
              style: TextStyle(color: Colors.black), // selectedLocation의 글자색 설정
              controller: TextEditingController(text: selectedLocation),
            ),
          ],
        ),
      ),
    );
  }
}
