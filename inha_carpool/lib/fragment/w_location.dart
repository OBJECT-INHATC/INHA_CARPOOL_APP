import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/home/s_carpool_map.dart';

/// 채팅방에서 출-목적지 지도 위젯

class ChatLocation extends StatelessWidget {
  final String title;
  final String location;
  final LatLng point;
  final String isStart;

  const ChatLocation({
    Key? key,
    required this.title,
    required this.location,
    required this.point,
    required this.isStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SelectableText(
                    location,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    showCursor: true,
                    cursorColor: Colors.blue,
                    cursorWidth: 2.0,
                    maxLines: 2,
                    minLines: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      Nav.globalContext,
                      MaterialPageRoute(
                          builder: (context) => CarpoolMap(
                                isStart: isStart,
                                isPopUp: true,
                                startPoint: LatLng(
                                  point.latitude,
                                  point.longitude,
                                ),
                                startPointName: location,
                                endPoint: LatLng(
                                  point.latitude,
                                  point.longitude,
                                ),
                                endPointName: location,
                              )),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.map_outlined,
                      color: Colors.black,
                      size: 25,
                    ),
                  ).pOnly(bottom: 5)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
