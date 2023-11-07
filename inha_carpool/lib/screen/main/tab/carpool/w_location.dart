import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatLocation extends StatelessWidget {
  final String title;
  final String location;
  final LatLng Point;


  const ChatLocation({
    Key? key,
    required this.title,
    required this.location, required this.Point,
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
                  onTap: (){
                    print("위치 보기");
                    print("위도경도 -> ${Point.latitude}, ${Point.longitude}");
                    ///todo : 위치 보기 기능 구현
                  },
                  child: const Icon(
                    Icons.map_outlined,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
