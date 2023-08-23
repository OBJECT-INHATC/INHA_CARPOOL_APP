import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/recruit/s_locationInput.dart';

class LocationInputWidget extends StatefulWidget {
  final String labelText; // 생성자에서 받아온 문자열을 저장할 변수

  LocationInputWidget({required this.labelText}); // 생성자 추가

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
          MaterialPageRoute(builder: (context) => LocationInputPage()),
        );

        if (result != null) {
          setState(() {
            selectedLocation = result;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(30, 30, 30, 10),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            labelText: widget.labelText, // 생성자에서 받아온 문자열 사용
          ),
          controller: TextEditingController(text: selectedLocation),
        ),
      ),
    );
  }
}
