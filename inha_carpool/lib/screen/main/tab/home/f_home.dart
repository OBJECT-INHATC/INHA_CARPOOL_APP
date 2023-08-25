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
      child: Column(
        children: [
          Container(
            height: 60,
            width: double.infinity, // 가로 길이를 화면 전체 너비로 설정
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              labelText: '검색',
            ),
          ),
        ),
          Expanded(
            child: ListView.builder(
            itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder( // 보더를 설정하는 부분
                side: BorderSide(width: 1, color: context.appColors.appBar), // 전체를 감싸는 보더
                borderRadius: BorderRadius.circular(10),
                ),//
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: context.appColors.appBar,
                            child: FittedBox(child: Text('출발지', style: TextStyle(color: Colors.white, fontSize: 20))),
                          ),
                          Column(

                            children: [
                              Text('출발시간', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: FittedBox(child: Icon(Icons.arrow_forward, color: Colors.black)),
                              ),
                              Text('현재인원', style: TextStyle(fontSize: 16)),

                            ],
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: context.appColors.appBar,
                            child: FittedBox(child: Text('도착지', style: TextStyle(color: Colors.white))),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),


      ),
    );
  }
}
