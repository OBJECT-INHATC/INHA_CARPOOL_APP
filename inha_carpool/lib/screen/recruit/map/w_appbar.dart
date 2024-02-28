import 'package:flutter/material.dart';

class SearchLocationAppBar extends StatelessWidget  {
  const SearchLocationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return  AppBar(
      // 앱바 타이틀 중앙에 배치
      centerTitle: true,
      title: const Text(
        '위치 선택',
        style: TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      toolbarHeight: 45,
      // 해당 선을 내릴때만 나오게 해줘
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    );
  }
}
