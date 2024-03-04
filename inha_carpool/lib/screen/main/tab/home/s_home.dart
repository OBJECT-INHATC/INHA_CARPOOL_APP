import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/provider/stateProvider/latlng_provider.dart';
import 'package:inha_Carpool/provider/carpool/state.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_notice.dart';
import 'package:inha_Carpool/screen/main/tab/home/w_carpool_origin.dart';

import '../../../../common/widget/loding_container.dart';
import '../../../../provider/carpool/carpool_notifier.dart';
import '../../../../provider/stateProvider/loading_provider.dart';
import 'enum/carpool_filter.dart';
import 'timer/w_timer.dart';

class Home extends ConsumerStatefulWidget {
  //내 정보
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}


class _HomeState extends ConsumerState<Home> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late LatLng myPosition;

  void loadPoint() async {
    myPosition = ref.read(positionProvider);
    /// 조회를 줄일순 없나?
    await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
  }

  @override
  void initState() {
    super.initState();
    loadPoint(); // 카풀 리스트 불러오기
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = context.screenHeight;
    final carPoolListState = ref.watch(carpoolProvider);
    bool loadingState = ref.watch(loadingProvider);


    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면이 줄어들지 않음
        floatingActionButton:  const CarpoolCountDown(),
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
                                  option == CarpoolFilter.time ? '시간순' : '거리순'),
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

    print("검색전 searchProvider : ${ref.read(searchProvider)}");

    // 검색 상태 변경
    ref.read(searchProvider.notifier).state = true;
    ref.read(loadingProvider.notifier).state = true;


    if (value.isEmpty || value == " ") {
      context.showSnackbarText(context, '검색어를 입력해주세요');
      await carpoolReFresh(isSearch: true);
    } else {
      // 로딩 상태 변경

      // 검색어가 없을 경우 서버에서 최신 리스트를 받아옴
      if (carPoolListState.isEmpty) {
      //  ref.read(searchProvider.notifier).state = false; // 검색 상태 변경
        await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
      }

      // 검색어가 있을 경우 검색어와 일치하는 카풀만 필터링
      await ref
          .read(carpoolProvider.notifier)
          .searchCarpool(value.toLowerCase());

      if (selectedFilter == CarpoolFilter.distance) {
        await ref.read(carpoolProvider.notifier).loadCarpoolNearBy(myPosition);
      }

      // 검색 결과가 없을 경우
      if (ref.watch(carpoolProvider).isEmpty) {
        if (!mounted) return;
        context.showSnackbarText(context, '검색 결과가 없습니다.', bgColor: Colors.red);
      } else {
        if (!mounted) return;
        context.showSnackbarText(
            context, '검색 결과 ${ref.watch(carpoolProvider).length}개가 있습니다.',
            bgColor: Colors.green);
      }

      ref.read(loadingProvider.notifier).state = false;
    }
    print("검색후 searchProvider : ${ref.read(searchProvider)}");

  }

  Future<void> carpoolReFresh({bool? isSearch}) async {
    // 검색 상태 변경
    ref.read(searchProvider.notifier).state = false;

    if (isSearch != true) {
      ref.read(loadingProvider.notifier).state = true;
    }

    await ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
    if (selectedFilter == CarpoolFilter.distance) {
      /// 거리순 정렬일시 거리순으로 정렬
      await ref.read(carpoolProvider.notifier).loadCarpoolNearBy(myPosition);
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(loadingProvider.notifier).state = false;
    });
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
    selectedFilter = newValue ?? CarpoolFilter.time;
    (selectedFilter == CarpoolFilter.time)
        ? await ref.read(carpoolProvider.notifier).loadCarpoolStateTimeBy()
        : await ref
            .read(carpoolProvider.notifier)
            .loadCarpoolNearBy(myPosition);
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
