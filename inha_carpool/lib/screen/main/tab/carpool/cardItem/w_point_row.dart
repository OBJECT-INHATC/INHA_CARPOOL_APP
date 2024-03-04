import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class PointInfo extends StatelessWidget {

  final String detailPoint;
  final String pointName;

  final bool isStart;
  final Icon icon;

  const PointInfo({super.key, required this.detailPoint, required this.pointName, required this.icon, required this.isStart});

  @override
  Widget build(BuildContext context) {

    final screenWidth = context.screenWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Height(screenWidth * 0.01),
          Row(
            children: [
              Width(screenWidth * 0.005),
              Icon(
                icon.icon,
                color: context.appColors.logoColor,
                size: 12,
              ),
              // 아이콘과 주소들 사이 간격
              Width(screenWidth * 0.03),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  // 출발지 요약주소
                  Text(
                    detailPoint,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  // 출발지 풀주소
                  Text(
                    shortenText(
                        pointName, 20),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          (isStart) ?
            const Icon(
            Icons.arrow_downward_rounded,
            size: 18,
            color: Colors.indigo,
          ) : const SizedBox(),
        ],
      ),

    );
  }


  String shortenText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength - 5)}...';
    }
  }
}
