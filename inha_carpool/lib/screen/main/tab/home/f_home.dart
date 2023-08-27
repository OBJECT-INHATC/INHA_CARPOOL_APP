import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';

import '../../../../common/util/carpool.dart';
import '../../../recruit/s_recruit.dart';
import 'carpoolFilter.dart';
import 's_carpool_map.dart';

class Home extends StatefulWidget {
  //내 정보
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = FlutterSecureStorage();

  late LatLng myPoint = LatLng(0, 0);
  late Future<List<DocumentSnapshot>> carPoolList = Future.value([]);
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";
  late String email = "";

  @override
  void initState() {
    super.initState();
    initMyPoint();
    carPoolList = _timeByFunction();
    _loadUserData();
    //  carPoolList = FirebaseCarpool.getCarpoolsWithMember("hoon");
  } // Null 허용

  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";
    email = await storage.read(key: "email") ?? "";
    setState(() {
      // nickName, email, gender를 업데이트했으므로 화면을 갱신합니다.
    });
  }

  //내 위치 받아오기
  Future<void> initMyPoint() async {
    myPoint = (await Location_handler.getCurrentLatLng(context))!;
  }

  // 시간순 정렬
  Future<List<DocumentSnapshot>> _timeByFunction() async {
    List<DocumentSnapshot> carpools = await FirebaseCarpool.getCarpoolsTimeby();
    return carpools;
  }

  //거리순 정렬
  Future<List<DocumentSnapshot>> _nearByFunction() async {
    await initMyPoint();
    List<DocumentSnapshot> carpools = await FirebaseCarpool.nearByCarpool(myPoint.latitude, myPoint.longitude);
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
          child: '+'.text.color(Colors.lightBlue).size(350).make(),
        ),
        body: Column(
          children: [
            DropdownButton<FilteringOption>(
              value: selectedFilter,
              onChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue!;
                  print('현재 필터링 $selectedFilter');

                  if(selectedFilter.toString() == 'FilteringOption.Time'){
                    carPoolList = _timeByFunction();
                  }else{
                  carPoolList = _nearByFunction();
                  }
                });
              },
              items: FilteringOption.values.map((option) {
                return DropdownMenuItem<FilteringOption>(
                  value: option,
                  child: Text(option == FilteringOption.Time ? '시간순' : '거리순'),
                );
              }).toList(),
            ),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future:
                    carPoolList ?? _timeByFunction(),
                   // carPoolList == null ? FirebaseCarpool.getCarpoolsWithMember("hoon") : carPoolList,
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
                        Map<String, dynamic> carpoolData =
                            carpool.data() as Map<String, dynamic>;

                        DateTime startTime =
                            DateTime.fromMillisecondsSinceEpoch(
                                carpoolData['startTime']);
                        DateTime currentTime = DateTime.now();
                        Duration difference = startTime.difference(currentTime);

                        String formattedTime;
                        if (difference.inDays >= 365) {
                          formattedTime = '${difference.inDays ~/ 365}년 후';
                        } else if (difference.inDays >= 30) {
                          formattedTime =
                              '${difference.inDays ~/ 30}달 ${difference.inDays.remainder(30)}일 이후';
                        } else if (difference.inDays >= 1) {
                          formattedTime =
                              '${difference.inDays}일 ${difference.inHours.remainder(24)}시간 이후';
                        } else if (difference.inHours >= 1) {
                          formattedTime =
                              '${difference.inHours}시간 ${difference.inMinutes.remainder(60)}분 이후';
                        } else {
                          formattedTime = '${difference.inMinutes}분 후';
                        }
                        // 각 아이템을 빌드하는 로직
                        return GestureDetector(
                          onTap: () {
                            if(carpoolData['startPoint'].toString() == uid)
                            Nav.push(
                              CarpoolMap(
                                startPoint: LatLng(
                                    carpoolData['startPoint'].latitude,
                                    carpoolData['startPoint'].longitude),
                                startPointName: carpoolData['startPointName'],
                                startTime: formattedTime,
                                carId: carpoolData['carId'],
                                admin: carpoolData['admin'],
                              ),
                            );

                          },
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1, color: context.appColors.appBar),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('닉네임: $nickName임'),
                                Text('이메일: $email'),
                                Text('성별: $gender'),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: context.appColors.appBar,
                                      child: FittedBox(
                                          child: Text(
                                              '${carpoolData['startDetailPoint']}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20))),
                                    ),
                                    Column(
                                      children: [
                                        Text('${formattedTime}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                          child: FittedBox(
                                              child: Icon(Icons.arrow_forward,
                                                  color: Colors.black)),
                                        ),
                                        Text(
                                            '${carpoolData['nowMember']}/${carpoolData['maxMember']}명',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: context.appColors.appBar,
                                      child: FittedBox(
                                          child: Text(
                                              '${carpoolData['endDetailPoint']}',
                                              style: TextStyle(
                                                  color: Colors.white))),
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
