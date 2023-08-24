import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/recruit/s_select_location.dart';

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
            selectedLocation = location_handler.getStringBetweenUnderscores(result);
            isGestureEnabled = false; // Tap 이벤트 비활성화
          });
          widget.onLocationSelected(result);
        }
      } : null, // isGestureEnabled가 false일 때는 onTap 이벤트 비활성화
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 13),
              child: widget.pointText.text.size(16).bold.black.make(),
            ),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                labelStyle: const TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              controller: TextEditingController(text: selectedLocation),
            ),
          ],
        ),
      ),
    );
  }





}
