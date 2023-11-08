import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/recruit/s_select_location.dart';

import '../../common/util/location_handler.dart';

class LocationInputWidget extends StatefulWidget {
  late TextEditingController detailController;

  String labelText; // 생성자에서 받아온 문자열을 저장할 변수
  String pointText;
  final LatLng Point; // 출발지인지 도착지인지
  final String detailPoint; // 요약 주소
  final ValueChanged<String> onLocationSelected;

  LocationInputWidget(
      {super.key,
      required this.labelText,
      required this.Point,
      required this.pointText,
      required this.onLocationSelected,
      required this.detailPoint,
      required this.detailController}); // 생성자 추가

  @override
  _LocationInputWidgetState createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  String get detailControllerText =>
      widget.detailController.text; // 변수에 접근 가능한 메서드 추가

  String selectedLocation = '';

  // bool isGestureEnabled = true;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.labelText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            children: [
              widget.pointText.text.size(16).bold.black.make(),
              const SizedBox(width: 10),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LocationInput(widget.Point)),
            );
            // result가 null이 아니면 setState로 selectedLocation을 변경
            if (result != null) {
              setState(() {
                selectedLocation =
                    LocationHandler.getStringBetweenUnderscores(result);
                // isGestureEnabled = false; // Tap 이벤트 비활성화
              });
              widget.onLocationSelected(result);
            }
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    //overflow: TextOverflow.ellipsis,
                    maxLines: 2, // 최대 2줄
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      text: selectedLocation,
                      children: const [
                        TextSpan(
                          //text: "...", // 초과될 경우 '...' 표시
                          style: TextStyle(fontSize: 12), // 초과될 경우 글자 크기(작게)
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: TextField(
            maxLength: 10,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              counterText: "",
              hintText: widget.detailPoint,
              suffix: Text("${widget.detailController.text.length}/10"), //글자 수 카운트
              labelStyle: const TextStyle(color: Colors.black, fontSize: 13),
              border: UnderlineInputBorder(

                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 13),
            controller: widget.detailController,
              onChanged: (text) {
                // 글자수 업뎃
                setState(() {
                  widget.detailController.text = text;
                });
              }
          ),
        )
      ],
    );
  }
}
