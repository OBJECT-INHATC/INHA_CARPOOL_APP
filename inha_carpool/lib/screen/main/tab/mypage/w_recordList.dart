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
        backgroundColor: Colors.white,
        leadingWidth: 56,
        leading: const Center(
          child: BackButton(
            color: Colors.black,
          ),
        ),
        title: const Text(
          "카풀 이용기록",
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _loadCarpools(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child:  CircularProgressIndicator(),
            );
          } else if(snapshot.hasError){
            return Text('Error: ${snapshot.error}');
          } else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      '카풀 이용기록이 없네요!\n카풀을 등록하여 이용해보세요.'
                          .text
                          .size(20)
                          .bold
                          .color(context.appColors.text)
                          .align(TextAlign.center)
                          .make(),
                    ],
                  ),
                ),
            );
          } else{
            List<DocumentSnapshot> myCarpools = snapshot.data!;

            return Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 40,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios_new, size: 18,),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '이용내역',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Align(
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: myCarpools.length,
                      itemBuilder: (context, i){

                        DocumentSnapshot carpool = myCarpools[i];
                        // DocumentSnapshot carpool = widget.snapshot.data![index];
                        Map<String, dynamic> carpoolData =
                        carpool.data() as Map<String, dynamic>;
                        String startPointName = carpool['startPointName'];

                        //카풀 날짜 변환
                        DateTime startTime =
                        DateTime.fromMillisecondsSinceEpoch(carpool['startTime']);

                        //날짜 형식으로 변환
                        String formattedStartTime =
                            startTime.formattedDateMyCarpool;

                        return Card(
                          color: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            // side : BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),

                            child: Row(
                              children: <Widget> [
                                Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 20,
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(bottom: 5,),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("${formattedStartTime}", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold, color: Colors.grey),),
                                                        ],
                                                      ),
                                                      Container(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.person, color: Colors.grey, size: 22),
                                                                Text('${carpoolData['admin'].split('_')[1]}',
                                                                  style: const TextStyle(
                                                                      fontSize: 15, fontWeight: FontWeight.bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                                margin: const EdgeInsets.all(7.0),
                                                                width: context.width(0.02),
                                                                // desired width
                                                                height: context.height(0.01),
                                                                // desired height
                                                                decoration: BoxDecoration(
                                                                  color: Colors.grey,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: const Center(
                                                                )),
                                                            const SizedBox(width: 5,),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text("${carpoolData['startDetailPoint']}  ",
                                                                                style: const TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold)),
                                                                            Text("${carpoolData['startPointName']}",
                                                                                style: TextStyle(
                                                                                    color: Colors.grey[600],
                                                                                    fontSize: 10,
                                                                                    fontWeight: FontWeight.bold)),
                                                                          ],
                                                                        )
                                                                    ),
                                                                    Container(
                                                                      margin:
                                                                      const EdgeInsets.only(left: 10, top:0 , bottom: 10,right: 10),
                                                                      child:
                                                                      Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.grey[600],),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                            margin: const EdgeInsets.all(7.0),
                                                                            width: context.width(0.02),
                                                                            // desired width
                                                                            height: context.height(0.01),
                                                                            // desired height
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.grey,
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child:  Center(
                                                                            )),
                                                                        const SizedBox(width: 5,),
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text("${carpoolData['endDetailPoint']}",
                                                                                style: const TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold)),
                                                                            Text("${carpoolData['endPointName']}",
                                                                                style: TextStyle(
                                                                                    color: Colors.grey[600],
                                                                                    fontSize: 10,
                                                                                    fontWeight: FontWeight.bold)),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(width: 12,),
                                                                        // IconButton(
                                                                        //   icon: const Icon(Icons.warning_rounded, size: 10,),
                                                                        //   onPressed: () {
                                                                        //     showDialog(
                                                                        //       context: context,
                                                                        //       builder: (BuildContext context) {
                                                                        //         return AlertDialog(
                                                                        //           content: ComplainDialog(),
                                                                        //         );
                                                                        //       },
                                                                        //     );
                                                                        //   },
                                                                        // )

                                                                        //신고
                                                                        GestureDetector(
                                                                          onTap: (){
                                                                            showModalBottomSheet(
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20)),
                                                                                context: context,
                                                                                builder: (BuildContext context) => Container(
                                                                                  color: Colors.white,
                                                                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                                                                    height:
                                                                                    MediaQuery.of(context).size.height * 0.35,
                                                                                    child: ComplainDialog()));
                                                                          },
                                                                          child: Icon(Icons.warning_rounded, size: 20,),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                        );

                      },
                    ),
                  ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
