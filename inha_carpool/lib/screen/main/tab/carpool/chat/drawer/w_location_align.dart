import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../home/enum/map_type.dart';
import '../w_map_icon.dart';

class LocationAlign extends StatelessWidget {
  const LocationAlign(
      {super.key,
      required this.startPoint,
      required this.endPoint,
      required this.startPointLnt,
      required this.endPointLnt});

  final String startPoint;
  final String endPoint;
  final LatLng startPointLnt;
  final LatLng endPointLnt;

  @override
  Widget build(BuildContext context) {

    final screenHeight = context.width(1);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
        child: Column(
          children: [
            ChatLocation(
              title: '출발지',
              location: startPoint,
              point: startPointLnt,
              mapCategory: MapCategory.start,
            ),
            const Line(height: 1),
            ChatLocation(
              title: '도착지',
              location: endPoint,
              point: endPointLnt,
              mapCategory: MapCategory.end,
            ),
          ],
        ),
      ),
    );
  }
}
