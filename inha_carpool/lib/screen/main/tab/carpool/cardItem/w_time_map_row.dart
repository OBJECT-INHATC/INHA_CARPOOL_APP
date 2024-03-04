import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';

import '../../../map/s_carpool_map.dart';
import '../../home/enum/map_type.dart';

class TimeAndMapInfo extends StatelessWidget {
   const TimeAndMapInfo({
    super.key,
    required this.formattedStartTime,
    required this.carpoolData,
    required this.formattedForMap,
     required this.colorTemp,

  });
  final Color colorTemp;
  final String formattedStartTime;
  final CarpoolModel carpoolData;
  final String formattedForMap;

   String getImagePath(Color color) {
     if (color == Colors.red) {
       return 'assets/image/icon/redMap.png';
     } else if (color == Colors.grey) {
       return 'assets/image/icon/greyMap.png';
     } else if (color == Colors.black) {
       return 'assets/image/icon/blackMap.png';
     }
     return 'assets/image/icon/map.png'; // 기본 이미지
   }


  @override
  Widget build(BuildContext context) {

     final screenWidth = context.screenWidth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ // 왼쪽에 날짜 위젯 배치
        Padding(
            padding: const EdgeInsets.only(
                left: 15, top: 15),
            child: Row(
              children: [
                Icon(
                  Icons
                      .calendar_today_outlined,
                  color: colorTemp,
                  size: 18,
                ),
                Width(screenWidth * 0.01),
                formattedStartTime
                    .text
                    .bold
                    .color(colorTemp)
                    .size(13)
                    .make(),
              ],
            )
        ),
        const Spacer(),

        // 지도
        GestureDetector(
          onTap: () {
            Navigator.push(
              Nav.globalContext,
              PageRouteBuilder(
                //아래에서 위로 올라오는 효과
                pageBuilder: (context,
                    animation,
                    secondaryAnimation) =>
                    CarpoolMap(
                      mapType: MapCategory.all,
                      isMember: true,
                      startPoint: carpoolData.startPoint!,
                      startPointName: carpoolData.startPointName!,
                      endPoint: carpoolData.endPoint!,
                      endPointName: carpoolData.endPointName!,
                      startTimeString:
                      formattedForMap,
                      carId: carpoolData.carId!,
                      admin: carpoolData.admin!,
                      roomGender:
                      carpoolData.gender!,
                    ),
                transitionsBuilder: (context,
                    animation,
                    secondaryAnimation,
                    child) {
                  const begin =
                  Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve =
                      Curves.easeInOut;
                  var tween = Tween(
                      begin: begin,
                      end: end)
                      .chain(CurveTween(
                      curve: curve));
                  var offsetAnimation =
                  animation.drive(tween);
                  return SlideTransition(
                      position:
                      offsetAnimation,
                      child: child);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(
                right: 55, bottom: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                getImagePath(colorTemp),
                width: 30,
                height: 45,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
