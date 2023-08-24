import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';

import '../../../recruit/s_recruit.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: '+'.text.white.size(350).make(),
          backgroundColor: context.appColors.appBar,
          onPressed: () {
           Nav.push(RecruitPage());
          },
        ),



        body : Container(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (c, i) {
              if (i == 0) {
                return Container(
                  margin: EdgeInsets.all(5),
                  height: 30,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[400],
                      border: OutlineInputBorder(),
                      labelText: '검색',
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap:(){
                  //  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatroomPage()));

                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 700,
                    height: 100,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30), //모서리를 둥글게
                        border: Border.all(color: Colors.black12, width: 3)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.person),
                            "출발지".text.black.make(),
                            EmptyExpanded(flex: 1),
                            Text("  08.03 14:52"),

                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.flag_circle),
                            "도착지".text.black.make(),
                            EmptyExpanded(flex: 1),
                            Text('현재 인원'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}