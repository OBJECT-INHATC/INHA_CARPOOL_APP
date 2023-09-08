import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_carpoolList.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_emptyCarpool.dart';

import '../../../../common/util/carpool.dart';
import '../../../recruit/s_recruit.dart';
import 'carpoolFilter.dart';

class Home extends StatefulWidget {
  //내 정보
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 로그인 정보
  final storage = const FlutterSecureStorage();

  // 내 위치
  late LatLng myPoint;

//Future.value([]); 는 비동기를 알려주는 것
  late Future<List<DocumentSnapshot>> carPoolList = Future.value([]);

  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";
  late String email = "";

  // 페이징 처리를 위한 변수 초기화
  int _visibleItemCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initMyPoint();
    carPoolList = _timeByFunction();
    _loadUserData();
    _refreshCarpoolList();
    // 스크롤 컨트롤러에 스크롤 감지 이벤트 추가
    _scrollController.addListener(_scrollListener);
  } //initState

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: "recruit_from_home",
          elevation: 10,
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          onPressed: () {
            Navigator.push(
              Nav.globalContext,
              MaterialPageRoute(
                builder: (context) => const RecruitPage(),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.blue,
            size: 50,
          ),
        ),
        body: Column(
          children: [
            DropdownButton<FilteringOption>(
              value: selectedFilter,
              // 아래 함수로 정의 (리팩토링)
              onChanged: _handleFilterChange,
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
                // 카풀 리스트 불러오기
                child: _buildCarpoolList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 카풀 리스트 불러오기
  Widget _buildCarpoolList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: carPoolList,
      builder: (context, snapshot) {
        // print("로딩중");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          // 카풀 에러 or 비었을 시
          return const EmptyCarpool();
        } else {
          // 카풀 리스트가 있을 경우 리스트 뷰 빌드 위젯 호출
          return CarpoolListWidget(
            snapshot: snapshot, // AsyncSnapshot을 CarpoolListWidget에 전달
            scrollController: _scrollController,
            visibleItemCount: _visibleItemCount,
            nickName: nickName, // 닉네임 전달
            uid: uid, // UID 전달
          );
        }
      },
    );
  }


  // 필터링 옵션
  void _handleFilterChange(FilteringOption? newValue) {
    setState(() {
      selectedFilter = newValue ?? FilteringOption.Time;
      carPoolList = (selectedFilter == FilteringOption.Time)
          ? _timeByFunction()
          : _nearByFunction();
    });
  }


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
}
