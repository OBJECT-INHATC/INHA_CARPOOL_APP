import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/util/carpool.dart';
import '../../../recruit/s_recruit.dart';

/// 진행 중인 카풀이 없을 때 반환할 위젯
class EmptyCarpool extends StatelessWidget {

  const EmptyCarpool({Key? key});

  @override
  Widget build(BuildContext context) {
    bool isOnUri = true;
    return FutureBuilder(
      future: FirebaseCarpool.getAdminData("mainList"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 데이터를 가져오는 데 성공한 경우
          final adminData = snapshot.data;
          if (adminData != null && adminData.exists) {
            final contextValue = adminData['context'] as String?;
            if (adminData['uri'] == "") {
              isOnUri = false;
            }
            final Uri url = Uri.parse(adminData['uri']! as String);
            if (contextValue != null && contextValue.isNotEmpty) {
              return GestureDetector(
                onTap: () async {
                  if (!await launchUrl(url) && isOnUri) {
                    throw Exception('Could not launch $url');
                  }
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      height:MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.blue[900]!,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            contextValue,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Height(MediaQuery.of(context).size.height * 0.2),
                    const Center(
                      child: Text(
                       '카풀을 등록하여\n택시 비용을 줄여 보세요!',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Height(MediaQuery.of(context).size.height * 0.03),
                    FloatingActionButton(
                      heroTag: "recruit1",
                      elevation: 10,
                      backgroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      onPressed: () {
                        Navigator.push(
                          Nav.globalContext,
                          MaterialPageRoute(
                              builder: (context) => const RecruitPage()),
                        );
                      },
                      child: '+'
                          .text
                          .size(70)
                          .color(
                        Colors.blue[200],
                        //Color.fromARGB(255, 70, 100, 192),
                      )
                          .make(),
                    ),
                  ],
                ),
              );
            }
          }
          // 데이터가 없거나 필드가 없는 경우에 대한 처리
          return Container();
        } else if (snapshot.hasError) {
          // 에러가 발생한 경우에 대한 처리
          return Container();
        } else {
          // 데이터를 로드 중인 경우의 로딩 상태 표시 등의 처리
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
