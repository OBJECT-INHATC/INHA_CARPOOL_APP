import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_emptySearchedCarpool.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_carpoolList.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_emptyCarpool.dart';

import '../../../../common/util/carpool.dart';
import '../../../recruit/s_recruit.dart';
import '../carpool/chat/f_chatroom.dart';
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

  // Declare a StreamController for DateTime
  final _timeStreamController = StreamController<DateTime>.broadcast();

  // 현재 시간을 1초마다 스트림에 추가 -> init
  _HomeState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      //현재시간을 Duration으로 변환해서 add
      if (!_timeStreamController.isClosed) {
        _timeStreamController.sink.add(DateTime.now());
      }
    });
  }

  Stream<DateTime>? _timeStream;

//Future.value([]); 는 비동기를 알려주는 것
  late Future<List<DocumentSnapshot>> carPoolList = Future.value([]);

  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";
  late String email = "";

  // 페이징 처리를 위한 변수
  int _visibleItemCount = 0;
  final ScrollController _scrollController = ScrollController();
  final limit = 5; // 한번에 불러올 데이터 갯수
  bool _isLoading = false; // 추가 데이터 로딩 중을 표시할 변수

  // 검색어 필터링
  String _searchKeyword = "";
  final TextEditingController _searchKeywordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    initMyPoint(); // 내 위치 받아오기
    carPoolList = FirebaseCarpool.timeByFunction(limit, null); // 초기에 시간순 정렬
    _loadUserData(); // 유저 정보 불러오기
    _refreshCarpoolList(); // 새로고침
    _scrollController.addListener(_scrollListener); // 스크롤 컨트롤러에 스크롤 감지 이벤트 추가
    _HomeState(); // 현재 시간을 1초마다 스트림에 추가
    _subscribeToTimeStream(); // 스트림 구독
  }

  void _subscribeToTimeStream() {
    print('스트림 구독');
    _timeStream = _timeStreamController.stream;
  }

  @override
  void dispose() {
    // Dispose of the StreamController when no longer needed
    _timeStreamController.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot?> _loadFirstCarpool() async {
    String myID = uid;
    String myNickName = nickName;
    String myGender = gender;

    List<DocumentSnapshot> carpools =
        await FirebaseCarpool.getCarpoolsWithMember(myID, myNickName, myGender);

    if (carpools.isNotEmpty) {
      return carpools[0];
    }

    return null;
  }

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
            groupName: '카풀네임',
            userName: nickName,
            uid: uid,
            gender: gender,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면이 줄어들지 않음

        floatingActionButton: SizedBox(
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
                            _refreshCarpoolList();
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
        ),
        body: Container(
          decoration: const BoxDecoration(
              color: //Colors.grey[100],
                  Colors.white),
          child: Column(
            children: [
              Container(height: 5, color: Colors.white),
              Container(
                color: Colors.white,
                height: context.height(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          TextField(
                            onSubmitted: (value) {
                              setState(() {
                                _searchKeyword = value;
                              });
                            },
                            controller: _searchKeywordController,
                            decoration: InputDecoration(
                              hintText: '검색어 입력',
                              fillColor: Colors.grey[200],
                              // 배경색 설정
                              filled: true,
                              // 배경색을 활성화
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none, // 외곽선 없음
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              // 글씨의 위치를 가운데 정렬
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
                            ),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 11),
                          ),
                          Positioned(
                            // 텍스트필드에 맞춰서 위치 정렬
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchKeyword =
                                      _searchKeywordController.text;
                                });
                              },
                              icon: const Icon(Icons.search_rounded),
                            ),
                          ),
                        ],
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
              Container(height: 2, color: context.appColors.divider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshCarpoolList,
                  // 카풀 리스트 불러오기
                  child: Stack(
                    children: [
                      _buildCarpoolList(), // 카풀 리스트 빌드
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 카풀 리스트 불러오기
  Widget _buildCarpoolList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: carPoolList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          // 카풀 에러 or 비었을 시
          return const EmptyCarpool();
        } else {
          // 카풀 리스트가 있을 경우 리스트 뷰 빌드 위젯 호출

          // 검색어와 일치하는 항목만 필터링
          final filteredCarpools = snapshot.data!.where((carpool) {
            final carpoolData = carpool.data() as Map<String, dynamic>;
            final startPointName =
                carpoolData['startPointName'].toString().toLowerCase();
            final startDetailPointName =
                carpoolData['startDetailPoint'].toString().toLowerCase();
            final endPointName =
                carpoolData['endPointName'].toString().toLowerCase();
            final endDetailPointName =
                carpoolData['endDetailPoint'].toString().toLowerCase();
            final keyword = _searchKeyword.toLowerCase();

            return startPointName.contains(keyword) ||
                startDetailPointName.contains(keyword) ||
                endPointName.contains(keyword) ||
                endDetailPointName.contains(keyword) ||
                endPointName.contains(keyword);
          }).toList();

          final itemCount = _visibleItemCount <= filteredCarpools.length
              ? _visibleItemCount
              : filteredCarpools.length;

          if (filteredCarpools.isEmpty) {
            return const EmptySearchedCarpool(); // 검색 결과가 없을 경우 빈 상태 표시
          }

          return CarpoolListWidget(
            snapshot: AsyncSnapshot<List<DocumentSnapshot>>.withData(
              ConnectionState.done,
              filteredCarpools.sublist(0, itemCount),
            ),
            // AsyncSnapshot을 CarpoolListWidget에 전달
            scrollController: _scrollController,
            visibleItemCount: _visibleItemCount,
            nickName: nickName,
            // 닉네임 전달
            uid: uid,
            // uid 전달
            gender: gender, // 성별 전달
          );
        }
      },
    );
  }

  /// 유저 정보 받아오기
  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";
    email = await storage.read(key: "email") ?? "";
    setState(() {
      // nickName, email, gender를 업데이트했으므로 화면을 갱신
    });
  }

  /// 내 위치 받아오기
  Future<void> initMyPoint() async {
    myPoint = (await LocationHandler.getCurrentLatLng(context))!;
  }

  /// 새로고침 로직
  Future<void> _refreshCarpoolList() async {
    if (selectedFilter == FilteringOption.Time) {
      carPoolList = FirebaseCarpool.timeByFunction(limit, null);
    } else {
      carPoolList = _nearByFunction();
    }
    print('새로고침 완료');

    // 새로고침 후 보여지는 리스트 갯수 : 5개 보다 적을시 리스트의 갯수, 이상일 시 5개
    carPoolList.then((list) {
      // setState(() {
      _visibleItemCount = list.length < 5 ? list.length : 5;
      print('초기 리스트 갯수: $_visibleItemCount');
      // });
    });

    // 로딩과정
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  /// 필터링 옵션
  void _handleFilterChange(FilteringOption? newValue) {
    setState(() {
      selectedFilter = newValue ?? FilteringOption.Time;
      carPoolList = (selectedFilter == FilteringOption.Time)
          ? FirebaseCarpool.timeByFunction(limit, null)
          : _nearByFunction();
    });
  }

  /// 거리순 정렬
  Future<List<DocumentSnapshot>> _nearByFunction() async {
    await initMyPoint();
    List<DocumentSnapshot> carpools = await FirebaseCarpool.nearByCarpool(
        myPoint.latitude, myPoint.longitude);
    return carpools;
  }

  /// 스크롤 감지 이벤트
  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        // 맨 위에 도달했을 경우
        print('맨 위');
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
                FirebaseCarpool.timeByFunction(10, list.last)
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
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
