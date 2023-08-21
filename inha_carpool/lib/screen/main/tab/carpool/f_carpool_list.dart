import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/Colors/app_colors.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';

import '../../../../common/constants.dart';

class CarpoolList extends StatelessWidget {
  const CarpoolList({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (c, i) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatroomPage()),
              );
            },
            child: Card(
              child: Container(
                color: context.appColors.cardBackground,
                margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: Image.asset(
                              "${basePath}/splash/logo600.png",
                            ).image,
                            backgroundColor: Colors.grey.shade200,
                            maxRadius: 35,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  '07.26/16:00 주안역-인하공전'
                                      .text
                                      .size(16)
                                      .bold
                                      .make(),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  '다들 잘 오시고 계시죠?'
                                      .text
                                      .size(12)
                                      .bold
                                      .color(context.appColors.subText)
                                      .make(),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  '2023.07.26.13:01'
                                      .text
                                      .size(12)
                                      .normal
                                      .color(context.appColors.subText)
                                      .make(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(children: [
                      '15분전'
                          .text
                          .size(12)
                          .bold
                          .color(context.appColors.text)
                          .make(),
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
