import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';

import '../../../../common/util/carpool.dart';
import '../../../recruit/s_recruit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late LatLng myPoint = LatLng(0, 0);
  late List<DocumentSnapshot> nearbyCarpools; // Null 허용

  @override
  void initState() {
    super.initState();
    someFunction(); // 데이터 초기화 함수 호출]
  }

  //내 위치 받아오기
  Future<void> initMyPoint() async {
    myPoint = (await Location_handler.getCurrentLatLng(context))!;
  }

  // 가까운 순 정렬
  Future<void> someFunction() async {
    await initMyPoint();
    print(myPoint.longitude);
    print(myPoint.latitude);

    nearbyCarpools = await FirebaseCarpool.getCarpoolsTimeby(
      myLatitude: myPoint.latitude, // 내 위치의 위도
      myLongitude: myPoint.longitude, // 내 위치의 경도
    );

    print(nearbyCarpools); // nearbyCarpools를 사용하여 원하는 작업 수행

  }



  //내 위치 받기

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: '+'.text.white.size(350).make(),
          backgroundColor: context.appColors.appBar,
          onPressed: () {
            Nav.push(RecruitPage());
          },
        ),

        ///검색
        body: Container(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (c, i) {
              if (i == 0) {
                return Container(
                  margin: EdgeInsets.all(5),
                  height: 30,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[400],
                      border: OutlineInputBorder(),
                      labelText: '검색',
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    someFunction();
                    //  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatroomPage()));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 700,
                    height: 100,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30), //모서리를 둥글게
                        border: Border.all(color: Colors.black12, width: 3)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.person),
                            "출발지".text.black.make(),
                            EmptyExpanded(flex: 1),
                            Text("  08.03 14:52"),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.flag_circle),
                            "도착지".text.black.make(),
                            EmptyExpanded(flex: 1),
                            Text('현재 인원'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
