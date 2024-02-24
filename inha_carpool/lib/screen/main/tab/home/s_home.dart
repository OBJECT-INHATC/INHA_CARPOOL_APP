import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/provider/carpool/state.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_notice.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_carpool_origin.dart';

import '../../../../common/widget/LodingContainer.dart';
import '../../../../provider/carpool/carpool_notifier.dart';
import '../../../../provider/loding/loadin_notifier.dart';
import 'enum/carpoolFilter.dart';

class Home extends ConsumerStatefulWidget {
  //내 정보
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

/// 5. todo : 지도 검색기능 향상
/// 6. todo : 알림 이동 페이지 추가하기  Ex 이용기록 페이지 이동
/// 7 stream 관련

class _HomeState extends ConsumerState<Home> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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

  void loadCarpoolTimeBy() async {
    await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
  }

  @override
  void initState() {
    super.initState();
    initMyPoint(); // 내 위치 받아오기
    loadCarpoolTimeBy(); // 카풀 리스트 불러오기

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
    final carPoolListState = ref.watch(carpoolProvider);

    bool loadingState = ref.watch(loadingProvider);

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
                         */ /*   _refreshCarpoolList();*/ /*
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
        body: Stack(
          children: [
            Container(
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
                            onSubmitted: (value) async {
                              print("onSubmitted");
                              await carpoolSearch(
                                  value, context, carPoolListState);
                            },
                            controller: _searchController,
                            maxLength: 15,
                            decoration: InputDecoration(
                              counterText: "",
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
                                onTap: () async {
                                  print("onTap");
                                  await carpoolSearch(_searchController.text,
                                      context, carPoolListState);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<CarpoolFilter>(
                          value: selectedFilter,
                          // 아래 함수로 정의 (리팩토링)
                          onChanged: _handleFilterChange,
                          borderRadius: BorderRadius.circular(15),
                          items: CarpoolFilter.values.map((option) {
                            // FilteringOption.values는 enum의 모든 값들을 리스트로 가지고 있습니다.
                            return DropdownMenuItem<CarpoolFilter>(
                              value: option,
                              // DropdownMenuItem의 child는 Text 위젯입니다.
                              child: Text(
                                  option == CarpoolFilter.Time ? '시간순' : '거리순'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const Height(5),
                  Line(height: 2, color: context.appColors.divider),
                  Expanded(
                    child: RefreshIndicator(
                      color: context.appColors.logoColor,
                      onRefresh: () async {
                        /// 서버에서 최신 리스트를 시간순으로 받아옴
                        await carpoolReFresh(isSearch: false);
                      },
                      child: CarpoolList(carpoolList: carPoolListState),
                    ),
                  ),
                ],
              ),
            ),
            loadingState
                ? const LodingContainer(
                    text: '카풀을 불러오는 중입니다.',
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> carpoolSearch(String value, BuildContext context,
      List<CarpoolState> carPoolListState) async {
    // 검색 상태 변경
    ref.read(searchProvider.notifier).state = true;

    if (value.isEmpty || value == " ") {
      context.showSnackbarText(context, '검색어를 입력해주세요');
      await carpoolReFresh(isSearch: true);
    } else {
      // 로딩 상태 변경
      ref.read(loadingProvider.notifier).state = true;

      // 검색어가 없을 경우 서버에서 최신 리스트를 받아옴
      if (carPoolListState.isEmpty) {
        ref.read(searchProvider.notifier).state = false;  // 검색 상태 변경
        await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
      }

      // 검색어가 있을 경우 검색어와 일치하는 카풀만 필터링
      await ref
          .read(carpoolProvider.notifier)
          .searchCarpool(value.toLowerCase());

      if (selectedFilter == CarpoolFilter.Distance) {
        await ref.read(carpoolProvider.notifier).loadCarpoolNearBy(myPoint);
      }

      // 검색 결과가 없을 경우
      if (ref.watch(carpoolProvider).isEmpty) {
        if(!mounted) return;
        context.showSnackbarText(context, '검색 결과가 없습니다.', bgColor: Colors.red);
      } else {
        if(!mounted) return;
        context.showSnackbarText(
            context, '검색 결과 ${ref.watch(carpoolProvider).length}개가 있습니다.',
            bgColor: Colors.green);
      }

      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> carpoolReFresh({bool? isSearch}) async {
    // 검색 상태 변경
    ref.read(searchProvider.notifier).state = false;

    if (isSearch != true) {
      ref.read(loadingProvider.notifier).state = true;
    }

    await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
    if (selectedFilter == CarpoolFilter.Distance) {
      /// 거리순 정렬일시 거리순으로 정렬
      await ref.read(carpoolProvider.notifier).loadCarpoolNearBy(myPoint);
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(loadingProvider.notifier).state = false;
    });
  }

  /// 내 위치 받아오기 없으면 인하대 후문
  initMyPoint() async {
    myPoint = (await LocationHandler.getCurrentLatLng(context)) ?? const LatLng(37.4514982, 126.6570261);
  }

  // 새로고침 후 보여지는 리스트 갯수 : 5개 보다 적을시 리스트의 갯수, 이상일 시 5개
/*  carPoolList.then((list) {
  // setState(() {
  _visibleItemCount = list.length < 5 ? list.length : 5;
  });
  로딩 때 보여질 창 연결
  */

  /// 필터링 옵션
  void _handleFilterChange(CarpoolFilter? newValue) async {
    selectedFilter = newValue ?? CarpoolFilter.Time;
    (selectedFilter == CarpoolFilter.Time)
        ? await ref.read(carpoolProvider.notifier).loadCarpoolStateTimeBy()
    /// todo : 위치정보 상태관리
        : await ref.read(carpoolProvider.notifier).loadCarpoolNearBy(myPoint);
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
