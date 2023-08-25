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
   late Future<List<DocumentSnapshot>> nearbyCarpoolsl;

  @override
  void initState() {
    super.initState();
    nearbyCarpoolsl = someFunction();
  } // Null 허용




  //내 위치 받아오기
  Future<void> initMyPoint() async {
    myPoint = (await Location_handler.getCurrentLatLng(context))!;
    print(myPoint);
  }

  // 시간순 정렬
  Future<List<DocumentSnapshot>> someFunction() async {
    List<DocumentSnapshot> carpools = await FirebaseCarpool.getCarpoolsTimeby(
    );
    return carpools;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            Nav.push(RecruitPage());
          },
          child: '+'.text.color(context.appColors.appBar).size(350).make(),
        ),
        body: Column(
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
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: someFunction(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print("로딩중");
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot carpool = snapshot.data![index];
                        // 각 아이템을 빌드하는 로직
                        return GestureDetector(
                          onTap: () {
                            // 아이템 클릭 시 동작
                            someFunction();
                          },
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: context.appColors.appBar),
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                SizedBox(height: 10)
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
