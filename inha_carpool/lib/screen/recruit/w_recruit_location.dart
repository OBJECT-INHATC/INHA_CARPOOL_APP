import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/recruit/s_select_location.dart';

import '../../common/util/location_handler.dart';

/// 출발지/도착지 요약주소 입력 위젯
class LocationInputWidget extends StatefulWidget {
  late TextEditingController detailController;

  String labelText;
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
      required this.detailController});

  @override
  _LocationInputWidgetState createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  String get detailControllerText =>
      widget.detailController.text;

  String selectedLocation = '';

  String textContent= "";


  // bool isGestureEnabled = true;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.labelText;
  }

  @override
  Widget build(BuildContext context) {

    const int maxLength = 10;

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
                    maxLines: 2, // 최대 2줄
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      text: selectedLocation,
                      children: const [
                        TextSpan(
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
          child: TextFormField(
            inputFormatters: [
              //띄어쓰기 허용 영우+숫자+한글
              FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9ㄱ-ㅎ가-힣 ]'), allow: true)
            ],
            maxLength: 10,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              counterText: "",
              hintText: widget.detailPoint,
              suffix: Text("${textContent.length}/$maxLength"), //글자 수 카운트
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
                  textContent = widget.detailController.text;
                });
              }
          ),
        )
      ],
    );
  }
}
