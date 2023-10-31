import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/datetime_extension.dart';

import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/screen/dialog/d_complain.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/screen/recruit/s_recruit.dart';

import 'package:inha_Carpool/service/sv_firestore.dart';

import 'package:inha_Carpool/screen/main/tab/carpool/f_carpool_list.dart';

class RecordList extends StatefulWidget {
  const RecordList({super.key});

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final storage = const FlutterSecureStorage();
  late String nickName = ""; // Initialize with a default value
  late String uid = "";
  late String gender = "";

  // static Future<List<DocumentSnapshot>> getCarpoolsWithMemberAndPastTime(String myID, String myNickName, int currentTime) async {
  //   CollectionReference carpoolCollection = _firestore.collection('carpool');
  //   QuerySnapshot querySnapshot = await carpoolCollection.get();

  static Future<List<DocumentSnapshot>> getCarpoolsWithMemberAndPastTime(String memberID, String memberName, int currentTime
      ) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('carpool')
        .where('members', arrayContains: '${memberID}_$memberName')
        .get();

    List<DocumentSnapshot> pastCarpools = [];

    // 현재 시간 가져옴
    DateTime currentTime = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      if (doc['members'].contains(memberID) || doc['admin'].contains(memberName)) {
        DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

        // 현재 시간보다 과거의 시간인 경우만 추가
        if (startTime.isBefore(currentTime)) {
          pastCarpools.add(doc);
        }
      }
    });

    //이용기록 리스트 정렬
    pastCarpools.sort((a, b) {
      DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
      DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);

      return startTimeB.compareTo(startTimeA); // 최근의 것부터 정렬
    });

    return pastCarpools;
  }



  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  // User data retrieval
  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";

    setState(() {
      // Update the state to trigger a UI refresh
    });
  }

  // 카풀 컬렉션 이름 추출
  // String getName(String res) {
  //   return res.substring(res.indexOf("_") + 1);
  // }
  String getName(String res) {
    int start = res.indexOf("_") + 1;
    int end = res.lastIndexOf("_");
    return res.substring(start, end);
  }

  // Retrieve carpools and apply FutureBuilder
  Future<List<DocumentSnapshot>> _loadCarpools() async {
    String myID = uid;
    String myNickName = nickName;
    print(myID);

    //현재시간 가져오기
    DateTime currentTime = DateTime.now();

    List<DocumentSnapshot> carpools =
    await _RecordListState.getCarpoolsWithMemberAndPastTime(myID, myNickName,currentTime.microsecondsSinceEpoch);

    // for (DocumentSnapshot carpool in carpools) {
    //   int numberOfMembers = carpool['members'].length;
    //   print("Number of Members in the carpool: $numberOfMembers");
    // }
    //
    // return carpools;

    return carpools;

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
        },//builder
      ),
    );//FutureBuilder<List<DocumentSnapshot>>
  }
}
