import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';

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
  // 필터링 옵션
  final storage = FlutterSecureStorage();

  late LatLng myPoint = LatLng(0, 0);

  late Future<List<DocumentSnapshot>> carPoolList = Future.value([]);

  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";
  late String email = "";

  // 페이징 처리를 위한 변수 초기화
  int _visibleItemCount = 0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initMyPoint();
    carPoolList = _timeByFunction();
    _loadUserData();
    _refreshCarpoolList();
    // 스크롤 컨트롤러에 스크롤 감지 이벤트 추가
    _scrollController.addListener(_scrollListener);
    //  carPoolList = FirebaseCarpool.getCarpoolsWithMember("hoon");
  } // Null 허용

  // 유저 정보 받아오기
  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";
    email = await storage.read(key: "email") ?? "";
    setState(() {
      // nickName, email, gender를 업데이트했으므로 화면을 갱신
    });
  }

  // 내 위치 받아오기
  Future<void> initMyPoint() async {
    myPoint = (await Location_handler.getCurrentLatLng(context))!;
  }

  // 시간순 정렬
  Future<List<DocumentSnapshot>> _timeByFunction() async {
    List<DocumentSnapshot> carpools = await FirebaseCarpool.getCarpoolsTimeby();
    return carpools;
  }

  // 거리순 정렬
  Future<List<DocumentSnapshot>> _nearByFunction() async {
    await initMyPoint();
    List<DocumentSnapshot> carpools = await FirebaseCarpool.nearByCarpool(
        myPoint.latitude, myPoint.longitude);
    return carpools;
  }

  // 새로고침 로직
  Future<void> _refreshCarpoolList() async {
    if (selectedFilter == FilteringOption.Time) {
      carPoolList = _timeByFunction();
    } else {
      carPoolList = _nearByFunction();
    }
    print('새로고침 완료');

    // 새로고침 후 보여지는 리스트 갯수 : 5개 보다 적을시 리스트의 갯수, 이상일 시 5개
    carPoolList.then((list) {
      setState(() {
        _visibleItemCount = list.length < 5 ? list.length : 5;
        print('초기 리스트 갯수: $_visibleItemCount');
      });
    });

    // 로딩과정
    await Future.delayed(const Duration(seconds: 1));

    setState(() {});
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        // 맨 위에 도달했을 경우
        print('맨 위');
      } else if (_scrollController.position.extentAfter == 0) {
        // 맨 아래에 도달했을 경우
        ///딜레이가 없어서 처음에 다 로드해오는 것처럼 보였음.
        Future.delayed(const Duration(seconds: 1), () {
          // 500 밀리초(0.5초) 딜레이 후 데이터 로드
          setState(() {
            carPoolList.then((list) {
              _visibleItemCount = (_visibleItemCount + 5).clamp(0, list.length);
              print('리스트 갯수: $_visibleItemCount');
            });
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: "recruit_from_home",
          elevation: 4,
          backgroundColor: Colors.white,
          onPressed: () {
            Nav.push(RecruitPage());
          },
          child: '+'.text.size(50).color(context.appColors.appBar).make(),
        ),
        body: Column(
          children: [
            DropdownButton<FilteringOption>(
              value: selectedFilter,
              onChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue!;

                  print('현재 필터링 $selectedFilter');
                  // 필터링 옵션에 따라서 carPoolList를 변경
                  if (selectedFilter.toString() == 'FilteringOption.Time') {
                    carPoolList = _timeByFunction();
                  } else {
                    carPoolList = _nearByFunction();
                  }
                });
              },
              items: FilteringOption.values.map((option) {
                // FilteringOption.values는 enum의 모든 값들을 리스트로 가지고 있습니다.
                return DropdownMenuItem<FilteringOption>(
                  value: option,
                  // DropdownMenuItem의 child는 Text 위젯입니다.
                  child: Text(option == FilteringOption.Time ? '시간순' : '거리순'),
                );
              }).toList(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshCarpoolList,
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: carPoolList ?? _timeByFunction(),
                  // carPoolList == null ? FirebaseCarpool.getCarpoolsWithMember("hoon") : carPoolList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print("로딩중");
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const SafeArea(
                        child: Center(
                          child: Text(
                            '진행중인 카풀이 없습니다!\n카풀을 등록해보세요!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text(
                        '진행중인 카풀이 없습니다!\n카풀을 등록해보세요!',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ));
                    } else {
                      return ListView.builder(
                        // 항상 스크롤이 가능하게 만들어서 리스트 갯수가 적을 때도 새로고침 가능하게 만듦
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount: _visibleItemCount,
                        itemBuilder: (context, index) {
                          DocumentSnapshot carpool = snapshot.data![index];
                          Map<String, dynamic> carpoolData =
                              carpool.data() as Map<String, dynamic>;

                          DateTime startTime =
                              DateTime.fromMillisecondsSinceEpoch(
                                  carpoolData['startTime']);
                          DateTime currentTime = DateTime.now();
                          Duration difference =
                              startTime.difference(currentTime);

                          String formattedTime;
                          if (difference.inDays >= 365) {
                            formattedTime = '${difference.inDays ~/ 365}년 후';
                          } else if (difference.inDays >= 30) {
                            formattedTime = '${difference.inDays ~/ 30}달 후';
                          } else if (difference.inDays >= 1) {
                            formattedTime = '${difference.inDays}일 후';
                          } else if (difference.inHours >= 1) {
                            formattedTime = '${difference.inHours}시간 후';
                          } else {
                            formattedTime = '${difference.inMinutes}분 후';
                          }

                          Color borderColor;
                          if (carpoolData['gender'] == '남자') {
                            borderColor =
                                context.appColors.appBar; // 남자일 때 보더 색
                          } else if (carpoolData['gender'] == '여자') {
                            borderColor = Colors.red; // 여자일 때 보더 색
                          } else {
                            borderColor = Colors.grey; // 무관일 때 보더 색
                          }

                          // 각 아이템을 빌드하는 로직
                          return GestureDetector(
                            onTap: () {
                              print(carpoolData['maxMember'].toString());
                              print(carpoolData['nowMember'].toString());

                              int nowMember = carpoolData['nowMember'];
                              int maxMember = carpoolData['maxMember'];

                              String currentUser = '${uid}_$nickName';
                              if (carpoolData['members']
                                  .contains(currentUser)) {
                                // 이미 참여한 경우
                                if (carpoolData['admin'] == currentUser) {
                                  // 방장인 경우
                                  Nav.push(

                                      /// 김영재 TODO : 이거 MasterPage 삭제되어서 로직 변경해야함 일단 같은 채팅으로 이동하게 했음
                                      ChatroomPage(
                                    carId: carpoolData['carId'],
                                    groupName: '카풀 네임',
                                    userName: nickName,
                                    uid: uid,
                                  ));
                                  print('현재 유저: $currentUser');
                                  print(carpoolData['members']);
                                } else {
                                  Nav.push(ChatroomPage(
                                    carId: carpoolData['carId'],
                                    groupName: '카풀 네임',
                                    userName: nickName,
                                    uid: uid,
                                  ));
                                }
                              } else {
                                // 참여하기로
                                if (nowMember < maxMember) {
                                  // 현재 인원이 최대 인원보다 작을 때
                                  Nav.push(
                                    CarpoolMap(
                                      startPoint: LatLng(
                                          carpoolData['startPoint'].latitude,
                                          carpoolData['startPoint'].longitude),
                                      startPointName:
                                          carpoolData['startPointName'],
                                      startTime: formattedTime,
                                      carId: carpoolData['carId'],
                                      admin: carpoolData['admin'],
                                    ),
                                  );
                                } else {
                                  context.showSnackbarMaxmember(context);
                                }
                              }
                            },
                            child: Card(
                              color: carpoolData['gender'] == '무관'
                                  ? Colors.grey[300]
                                  : carpoolData['gender'] == '남자'
                                  ? Colors.blue[200]
                                  : Colors.red[200],
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 2, color: borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Container(
                                      width: context.width(0.889),
                                      // desired width
                                      padding: const EdgeInsets.all(8.0),
                                      margin: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            // POINT
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),

                                      child: Row(children: [
                                        //방장 정보 가져오기
                                        Icon(Icons.person,
                                            color: Colors.grey, size: 25),
                                        Text(
                                            '${carpoolData['admin'].split('_')[1]}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(width: 5),
                                        //방장 평점

                                      ]),
                                    ),
                                  ]),
                                  Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,

                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    width: 40,
                                                    // desired width
                                                    height: 30,
                                                    // desired height
                                                    decoration: BoxDecoration(

                                                      color: Colors.blue[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(8.0),
                                                    child: Center(
                                                        child: Text('출발',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white,
                                                                fontSize: 13)))),
                                                SizedBox(width: 5),
                                                Text(
                                                    "${carpoolData['startDetailPoint']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(width: 5),
                                                Text(
                                                    "${carpoolData['startPointName']}",
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 13,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                              ],
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(children: [
                                                  Icon(Icons
                                                      .arrow_drop_down_outlined),
                                                  Icon(Icons
                                                      .arrow_drop_down_outlined),
                                                ])),
                                            Row(
                                              children: [
                                                Container(
                                                    width: 40,
                                                    // desired width
                                                    height: 30,
                                                    // desired height
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(8.0),
                                                    child: Center(
                                                        child: Text('도착',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white,
                                                                fontSize: 13)))),
                                                SizedBox(width: 5),
                                                Text(
                                                    "${carpoolData['endDetailPoint']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(width: 5),
                                                Text(
                                                    "${carpoolData['endPointName']}",
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 13,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(children: [
                                        Container(
                                          width: context.width(0.889),
                                          // desired width
                                          padding: const EdgeInsets.all(8.0),
                                          margin: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                // POINT
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),

                                          child: Column(children: [
                                            Row(
                                              children: [
                                                Icon(Icons
                                                    .calendar_today_outlined),
                                                Text(
                                                    '${startTime.month}월 ${startTime.day}일 ${startTime.hour}시 ${startTime.minute}분 출발',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons
                                                    .directions_car_outlined),
                                                Text(
                                                    '${carpoolData['nowMember']}/${carpoolData['maxMember']}명',
                                                    style: const TextStyle(
                                                        fontSize: 16)),
                                              ],
                                            ),
                                            //방 생성시 설정했던 성별 표시
                                            Row(
                                              children: [
                                                Icon(Icons
                                                    .perm_identity_outlined),
                                                Text((carpoolData['gender'])),
                                              ],
                                            ),
                                            Text(formattedTime,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                        ),
                                      ]),
                                    ],
                                  ),
                                  const SizedBox(height: 10)
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
            ),
          ],
        ),
      ),
    );
  }
}
