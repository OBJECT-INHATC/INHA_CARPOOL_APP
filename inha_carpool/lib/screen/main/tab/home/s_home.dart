import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/provider/auth/auth_provider.dart';
import 'package:inha_Carpool/provider/carpool/state.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_notice.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_carpool_origin.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_emptySearchedCarpool.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_carpoolList.dart';

import '../../../../provider/carpool/carpool_notifier.dart';
import '../../../../service/sv_carpool.dart';
import '../../../../common/widget/empty_list.dart';
import '../../../recruit/s_recruit.dart';
import '../carpool/chat/s_chatroom.dart';
import '../carpool/s_carpool.dart';
import 'enum/carpoolFilter.dart';

class Home extends ConsumerStatefulWidget {
  //내 정보
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchKeywordController = TextEditingController();

/*  final _timeStreamController = StreamController<DateTime>.broadcast();
  Stream<DateTime>? _timeStream;*/

  // 현재 시간을 1초마다 스트림에 추가 -> init
/*  _HomeState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      //현재시간을 Duration으로 변환해서 add
      if (!_timeStreamController.isClosed) {
        _timeStreamController.sink.add(DateTime.now());
      }
    });
  }*/

  // 내 위치
  late LatLng myPoint;


  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";
  late String email = "";

  // 페이징 처리를 위한 변수
  int _visibleItemCount = 0;
  final limit = 5; // 한번에 불러올 데이터 갯수
  bool _isLoading = false;

  // 검색어 필터링
  late List<CarpoolState> carPoolList = [];

  void getCarpoolList() async {
    await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
    print("홈에서 조회한 진행중인 카플 리스트 수 : ${carPoolList.length}");
   }


  @override
  void initState() {
    super.initState();
    initMyPoint(); // 내 위치 받아오기
    getCarpoolList(); // 카풀 리스트 불러오기


    _loadUserData(); // 유저 정보 불러오기
   // _scrollController.addListener(_scrollListener); // 스크롤 컨트롤러에 스크롤 감지 이벤트 추가
  //  _HomeState(); // 현재 시간을 1초마다 스트림에 추가
   // _subscribeToTimeStream(); // 스트림 구독
  }

/*
  void _subscribeToTimeStream() {
    print('스트림 구독');
    _timeStream = _timeStreamController.stream;
  }
*/

  @override
  void dispose() {
    // Dispose of the StreamController when no longer needed
    //_timeStreamController.close();
    _scrollController.dispose();
    super.dispose();
  }

/*  Future<DocumentSnapshot?> _loadFirstCarpool() async {

    List<DocumentSnapshot> carpools =
        await CarpoolService().getCarpoolsWithMember(uid, nickName, gender);

    if (carpools.isNotEmpty) {
      return carpools[0];
    }

    return null;
  }*/

/*
  void _handleFloatingActionButton() async {
    DocumentSnapshot? firstCarpool = await _loadFirstCarpool();

    if (firstCarpool != null) {
      Map<String, dynamic> carpoolData =
          firstCarpool.data() as Map<String, dynamic>;
      if (!mounted) return;
      Navigator.push(
        Nav.globalContext,
        MaterialPageRoute(
          builder: (context) => ChatroomPage(
            carId: carpoolData['carId'],
          ),
        ),
      );
    } else {
      SnackBar snackBar = SnackBar(
        content: const Text('아직 카풀이 없습니다.'),
        action: SnackBarAction(
          label: '카풀 생성',
          onPressed: () {
            Navigator.push(
              Nav.globalContext,
              MaterialPageRoute(
                builder: (context) => const RecruitPage(),
              ),
            );
          },
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    final double height = context.screenHeight;
    carPoolList = ref.watch(carpoolProvider);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면이 줄어들지 않음

      /*  floatingActionButton: SizedBox(
          width: context.width(0.9),
          height: context.height(0.07),
          child: FutureBuilder<DocumentSnapshot?>(
            future: _loadFirstCarpool(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 데이터 로딩 중
                return const SizedBox.shrink(); // 아무 것도 표시 하지 않음
              } else if (snapshot.hasError) {
                // 에러가 발생한 경우 에러 메시지 표시
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                // 데이터가 없는 경우 혹은 null인 경우 로딩 중으로 표시
                return const SizedBox.shrink();
              } else {
                Map<String, dynamic> carpoolData =
                    snapshot.data!.data() as Map<String, dynamic>;
                DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
                    carpoolData['startTime']);
                // 해당 startTime을 몇월 몇일 몇시로 변경
                // 데이터가 있는 경우 플로팅 액션 버튼 생성

                // 오늘 날짜가 아닐 경우 플로팅 액션 버튼 생성하지 않음
                if (startTime.year != DateTime.now().year ||
                    startTime.month != DateTime.now().month) {
                  return const SizedBox.shrink();
                } else if (startTime.day - DateTime.now().day < 2) {
                  return FloatingActionButton(
                    elevation: 3,
                    mini: false,
                    backgroundColor: Colors.grey[800],
                    splashColor: Colors.transparent,
                    // 클릭 모션 효과 삭제
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black38, width: 1),
                    ),
                    onPressed: () {
                      // Handle button press here and update the stream data
                      _handleFloatingActionButton();
                    },
                    child: StreamBuilder<DateTime>(
                      stream: _timeStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final data = snapshot.data;
                          Duration diff = startTime.difference(data!);
                          // diff가 0초일 경우 페이지 새로고침
                          if (diff.inSeconds <= 0) {
                         *//*   _refreshCarpoolList();*//*
                            // return SizedBox.shrink(); // 혹은 다른 UI 요소
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: context.width(0.05)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '🚕 카풀이 ${formatDuration(diff)} 후에 출발 예정이에요',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${carpoolData['startDetailPoint']} - ${carpoolData['endDetailPoint']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ],
                              ),
                              SizedBox(width: context.width(0.05)),
                            ],
                          );
                        }
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }
            },
          ),
        ),*/
        body: Container(
          decoration: const BoxDecoration(
              color: //Colors.grey[100],
                  Colors.white),
          child: Column(
            children: [
              const Height(5),
              /// 광고 및 공지사항 위젯
              NoticeBox(height * 0.25, "main"),
              Container(
                color: Colors.white,
                height: context.height(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) {
                          print("검색어: ${_searchKeywordController.text}");
                        },
                        controller: _searchKeywordController,
                        decoration: InputDecoration(
                          hintText: '검색어 입력',
                          fillColor: Colors.grey[200],
                          // 배경색 설정
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20.0),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          suffixIcon: GestureDetector(
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                            onTap: () {
                              ///todo 메소드 구현 필요
                              print("검색어: ${_searchKeywordController.text}");
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<FilteringOption>(
                      value: selectedFilter,
                      // 아래 함수로 정의 (리팩토링)
                      onChanged: _handleFilterChange,
                      borderRadius: BorderRadius.circular(15),
                      items: FilteringOption.values.map((option) {
                        // FilteringOption.values는 enum의 모든 값들을 리스트로 가지고 있습니다.
                        return DropdownMenuItem<FilteringOption>(
                          value: option,
                          // DropdownMenuItem의 child는 Text 위젯입니다.
                          child: Text(
                              option == FilteringOption.Time ? '시간순' : '거리순'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Height(5),
              Line(height: 2, color: context.appColors.divider),
              Expanded(
                child: Stack(
                  children: [
                    /// 카풀 리스트 반환
                    CarpoolListO(
                      carpoolList: carPoolList,
                      scrollController: _scrollController,
                    ), // 카풀 리스트 빌드
                    if (_isLoading) // 인디케이터를 표시하는 조건
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 12,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  /// 유저 정보 받아오기
  Future<void> _loadUserData() async {
    nickName = ref.read(authProvider).nickName!;
    uid = ref.read(authProvider).uid!;
    gender = ref.read(authProvider).gender!;
    email = ref.read(authProvider).email!;
  }

  /// 내 위치 받아오기
  Future<void> initMyPoint() async {
    myPoint = (await LocationHandler.getCurrentLatLng(context))!;
  }

 /* /// 새로고침 로직
  Future<void> _refreshCarpoolList() async {
    if (selectedFilter == FilteringOption.Time) {
      carPoolList = ref.read(carpoolProvider.notifier).loadCarpoolTimeby() as List<CarpoolState>;
    } else {
      carPoolList = _nearByFunction();
    }
    // 새로고침 후 보여지는 리스트 갯수 : 5개 보다 적을시 리스트의 갯수, 이상일 시 5개
    carPoolList.then((list) {
      // setState(() {
      _visibleItemCount = list.length < 5 ? list.length : 5;
    });

    // 로딩과정
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }*/

  /// 필터링 옵션
  void _handleFilterChange(FilteringOption? newValue) async {
      selectedFilter = newValue ?? FilteringOption.Time;

          (selectedFilter == FilteringOption.Time)
          ? await ref.read(carpoolProvider.notifier).loadCarpoolStateNearBy()
          : await ref.read(carpoolProvider.notifier).loadCarpoolNearBy(myPoint);
  }

/*
  /// 거리순 정렬
  Future<List<DocumentSnapshot>> _nearByFunction() async {
    await initMyPoint();
    List<DocumentSnapshot> carpools = await CarpoolService().nearByCarpool(
        myPoint.latitude, myPoint.longitude);
    return carpools;
  }
*/

/*  /// 스크롤 감지 이벤트
  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        // 맨 위에 도달했을 경우
      } else if (_scrollController.position.extentAfter == 0 && !_isLoading) {
        // 추가 데이터를 로드할 조건: 맨 아래에 도달하고 로딩 중이 아닐 때
        setState(() {
          _isLoading = true; // 데이터 로드 중에 인디케이터를 표시
        });
        Future.delayed(const Duration(seconds: 1), () {
          carPoolList.then((list) {
            if (list.isNotEmpty) {
              // 시간순일 때
              if (selectedFilter == FilteringOption.Time) {
                CarpoolService().timeByFunction(10, list.last)
                    .then((newCarpools) {
                  if (newCarpools.isEmpty) {
                    // 추가적으로 로드할 카풀이 없을 때
                    context.showSnackbar('카풀이 더 이상 없습니다!');
                    _isLoading = false;
                  }
                  list.addAll(newCarpools);
                  _visibleItemCount =
                      (_visibleItemCount + 5).clamp(0, list.length);
                  print('스크롤 후 리스트 갯수(timeBy): $_visibleItemCount');

                  setState(() {
                    _isLoading = false; // 데이터 로드가 완료되면 인디케이터를 숨김
                  });
                });
                // (거리순은 페이징 최적화 보류. 현재는 모든 리스트를 가져와서 정렬 후 5개씩 보여주는 방식)
              } else if (selectedFilter == FilteringOption.Distance) {
                _visibleItemCount =
                    (_visibleItemCount + 5).clamp(0, list.length);
                print('스크롤 후 리스트 갯수(nearBy): $_visibleItemCount');

                setState(() {
                  _isLoading = false; // 데이터 로드가 완료되면 인디케이터를 숨김
                });
              }
            }
          });
        });
      }
    }
  }*/

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
