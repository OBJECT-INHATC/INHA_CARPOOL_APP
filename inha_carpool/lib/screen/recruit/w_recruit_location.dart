import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/recruit/s_select_location.dart';

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
      children: [
        // 출발지, 도착지
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
                    Location_handler.getStringBetweenUnderscores(result);
                // isGestureEnabled = false; // Tap 이벤트 비활성화
              });
              widget.onLocationSelected(result);
            }
          }, // isGestureEnabled가 false일 때는 onTap 이벤트 비활성화
          child: Container(

            margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      widget.pointText.text.size(16).bold.black.make(),
                      const SizedBox(width: 10),
                    ],
                  ),


                ),
                /*---*/
                // Container(
                //   color: Colors.white,
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         selectedLocation,
                //         style: const TextStyle(color: Colors.black, fontSize: 15),
                //       ),
                //       const Icon(
                //         Icons.arrow_forward_ios,
                //         color: Colors.black,
                //         size: 15,)
                //     ],
                //   ),
                // )
                Container(
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
                            style: TextStyle(color: Colors.black, fontSize: 15),
                            text: selectedLocation,
                            children: [
                              TextSpan(
                                //text: "...", // 초과될 경우 '...' 표시
                                style: TextStyle(fontSize: 12), // 초과될 경우 글자 크기(작게)
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 15,
                      ),
                    ],
                  ),
                )

              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: TextField(
            decoration: InputDecoration(


              filled: true,
              fillColor: Colors.white,
              hintText: widget.detailPoint,
              labelStyle: const TextStyle(color: Colors.black, fontSize: 13),
              border: UnderlineInputBorder(

                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 13),
            controller: widget.detailController,
          ),
        )
      ],
    );
  }
}
