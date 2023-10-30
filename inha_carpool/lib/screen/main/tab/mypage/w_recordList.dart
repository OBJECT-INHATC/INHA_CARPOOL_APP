import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';
import 'package:inha_Carpool/service/api/ApiService.dart';

class RecordList extends StatefulWidget {
  final String uid;
  final String nickName;

  const RecordList({Key? key, required this.uid, required this.nickName}) : super(key: key);

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final ApiService apiService = ApiService();
  late Future<http.Response> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = apiService.selectHistoryList(widget.uid, widget.nickName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text('이용 기록 내역'),
      ),
      body: FutureBuilder<http.Response>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.statusCode != 200) {
            return Center(child: Text('Failed to fetch history.'));
          } else {
            final List<dynamic> histories = jsonDecode(utf8.decoder.convert(snapshot.data!.bodyBytes));

            if (histories.isEmpty) {
              return Center(child: Text('No records found.'));
            }

            return ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                return ListTile(
                  title: Text('History: ${history['carPoolId']}'),
                  subtitle: Text('Admin: ${history['admin']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
