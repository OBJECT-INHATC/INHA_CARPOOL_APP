import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class MapInfo extends StatelessWidget {
  const MapInfo(
      {super.key,
      required this.title,
      required this.content,
      required this.icon});

  final String title;
  final String content;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;


    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: screenWidth * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon.icon, color: icon.color, size: icon.size),
          SizedBox(width: screenWidth * 0.015),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: screenWidth * 0.02),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              // 내부 패딩
              decoration: BoxDecoration(
                color: Colors.grey[300], // 회색 배경색
                borderRadius: BorderRadius.circular(20), // 동그란 모양 설정
              ),
              /// 주소 복사 가능하게 수정
              child: SelectableText(
                content,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // 텍스트 색상
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
