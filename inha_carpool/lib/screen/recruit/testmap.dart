import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/service/api/Api_juso.dart';

import '../../provider/stateProvider/jusogiban_api_provider.dart';

class TestMap extends ConsumerStatefulWidget {
  final LatLng point;
  final String naverHost =
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';

  const TestMap(this.point, {super.key});

  @override
  ConsumerState<TestMap> createState() => _TestMapState();
}

class _TestMapState extends ConsumerState<TestMap> {
  // 검색창 컨트롤러
  late final TextEditingController _searchController;

  // 주소 검색 결과를 저장할 리스트
  List<String> _addressList = [];

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;
    final width = context.screenWidth;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '위치 선택',
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          toolbarHeight: 45,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white),
      body: Column(
        children: [
          /// 검색창
          searchContainer(height),

        ],
      ),
    );
  }

  /// 상단 검색 창
  Widget searchContainer(double height) {
    return Container(
      height: height * 0.05,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        onSubmitted: (value) async {
          await selectNearLocation(value);
        },
        controller: _searchController,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () async {
              await selectNearLocation(_searchController.text);
            },
            icon: const Icon(Icons.search),
          ),
          hintText: '장소 검색',
          fillColor: Colors.grey[300],
          // 배경색 설정
          filled: true,
          // 배경색을 활성화
          border: const OutlineInputBorder(
            borderSide: BorderSide.none, // 외곽선 없음
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          // 글씨의 위치를 가운데 정렬
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ),
    );
  }


  /// 지정한 위치의 지명을 가져오는 메서드 (검색기능)
  Future<void> selectNearLocation(String jusoTrim) async {
    jusoTrim = jusoTrim.trim();
    if (_searchController.text.length < 2 || jusoTrim.isEmpty) {
      context.showSnackbarText(context, '2글자 이상 입력해주세요.', bgColor: Colors.red);
      setState(() {
    //    infoText = '2글자 이상 입력해주세요.';/**/
        _addressList.clear();
      });
      return;
    }
    _addressList = await ApiJuso().getAddresses(jusoTrim, ref.read(jusoKeyProvider));
    print("--------------------------------------");
    print("selectNearLocation 실행 juso : $jusoTrim");
    print("--------------------------------------");
    print("주소 리스트 : $_addressList");
    print("--------------------------------------");

  }
}


