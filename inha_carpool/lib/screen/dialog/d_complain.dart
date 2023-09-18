import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'd_complainAlert.dart';

class ComplainDialog extends StatefulWidget {
  const ComplainDialog({super.key});



  @override
  State<ComplainDialog> createState() => _ComplainDialogState();
}

class _ComplainDialogState extends State<ComplainDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 5),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new),
              ),
              Text(
                '신고하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.clear),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Colors.grey,
        ),
        Container(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            shrinkWrap: true,
            // itemCount: context.watch<States>().name.length,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                color: Colors.grey[200],
                child: ListTile(
                  leading: Icon(Icons.account_circle_rounded, size: 48),
                  iconColor: Colors.deepPurple,
                  title:
                  Text('민지', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing:
                  Icon(Icons.priority_high, color: Colors.red, size: 18),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                       // return ComplainAlert(userName: userName);
                        return Placeholder();
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


