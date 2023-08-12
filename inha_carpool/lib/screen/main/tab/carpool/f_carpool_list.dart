import 'package:flutter/material.dart';
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
                                  const Text("07.26/16:00 주안역-인하공전",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    "다들 잘 오시고 계시죠?",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  const Text(
                                    "2023.07.26.13:01",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Column(children: [
                      Text(
                        "15분전",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Icon(
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
