import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  // 검색어 필터링
  String _searchKeyword = "";
  final TextEditingController _searchKeywordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: TextField(
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
                  setState(
                        () {
                      _searchKeyword =
                          _searchKeywordController.text;
                    },
                  );
                  print("검색어: $_searchKeyword");
                },
              ),
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('검색하기'),
      ),
    );
  }
}
