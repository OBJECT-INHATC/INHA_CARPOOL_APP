import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class ChatLocation extends StatelessWidget {
  final String title;
  final String location;

  const ChatLocation({
    Key? key,
    required this.title,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 2,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      text: location,
                      children: const [
                        TextSpan(
                          text: "...더 보기",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
