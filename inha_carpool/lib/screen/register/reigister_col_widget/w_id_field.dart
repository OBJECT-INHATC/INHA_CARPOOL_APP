import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/common.dart';

/// 학번과 학교 토글 위젯
class StudentIdInputField extends StatefulWidget {
  final bool isProfessor;
  final Function(String) onChanged;
  final Function(String) academyChanged;
  final double width;
  final TextEditingController controller;

  const StudentIdInputField({super.key,
    required this.isProfessor,
    required this.onChanged,
    required this.academyChanged,
    required this.width,
    required this.controller,
  });

  @override
  StudentIdInputFieldState createState() => StudentIdInputFieldState();
}

class StudentIdInputFieldState extends State<StudentIdInputField> {
  int selectedIndex = 0;
  late String academy;

  @override
  void initState() {
    super.initState();
    academy = "@itc.ac.kr"; // 초기값 설정
  }

  @override
  Widget build(BuildContext context) {

    final width = context.screenWidth;

    return Container(
      padding:  EdgeInsets.fromLTRB(40, width * 0.027, 40, width * 0.027),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!, // 연한 회색 테두리
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100], // 연한 회색 배경색
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: widget.isProfessor
                    ? TextInputType.emailAddress
                    : TextInputType.number,
                controller: widget.controller,
                decoration: InputDecoration(
                  suffixIcon: widget.isProfessor
                      ? null
                      : FlutterToggleTab(
                    width: widget.width * 0.075,
                    borderRadius: 20,
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: widget.width * 0.033,
                      fontWeight: FontWeight.w700,
                    ),
                    unSelectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: widget.width * 0.026,
                      fontWeight: FontWeight.w500,
                    ),
                    labels: const ["인하공전", "인하대"],
                    selectedLabelIndex: (index) {
                        setState(() {
                          if (index == 0) {
                            academy = "@itc.ac.kr";
                            selectedIndex = index;
                          } else {
                            academy = "@inha.edu";
                            selectedIndex = index;
                          }
                        });
                        widget.academyChanged(academy); // 콜백 함수 호출

                    },
                    selectedBackgroundColors:  const [Color.fromARGB(255, 70, 100, 192)],
                    unSelectedBackgroundColors: const [Colors.black],
                    isScroll: false,
                    selectedIndex: selectedIndex,

                  ),
                  labelText: null,
                  hintText: widget.isProfessor ? '교직원 학교 이메일' : '학번',
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.school,
                    color: Colors.grey,
                  ),
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
