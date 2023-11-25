//건의사항3차수정
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../dto/ReportRequstDTO.dart';
import '../../../../service/api/Api_repot.dart';
import '../../../dialog/d_complain_complete.dart';
import '../../../dialog/d_complain_show.dart';

class FeedBackPage extends StatefulWidget {
  final String reporter;

  FeedBackPage({required this.reporter, super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final ApiService apiService = ApiService();

  String? selectedValue;

  final _items = ['건의', '문의', '신고'];

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        // 텍스트 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              foregroundColor: Colors.black,
              shadowColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('건의하기', style: TextStyle(fontSize: 19)),
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    '저희 인하 카풀을 이용해 주셔서'.text.size(17).bold.make(),
                    '진심으로 감사드립니다.'.text.size(17).bold.make(),
                    const SizedBox(height: 12),
                    '사용하시면서 불편하셨던 점이나 개선하고자 하는 제안사항이 있다면, 아래에 자유롭게 작성해 주세요.'
                        .text
                        .size(16)
                        .make(),
                    '고객님의 소중한 의견이 저희 앱을 발전시키는 데 큰 도움이 됩니다.'.text.size(16).make(),

                    //드롭 박스
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 50,
                        color: Colors.grey[200],
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            isExpanded: true,
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                            ),
                            hint: const Text('문의 유형을 선택해주세요.'),
                            value: selectedValue,
                            items: _items
                                .map(
                                  (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                // value로 선택된 값이 들어옴
                                selectedValue = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        controller: _controller,
                        maxLines: 6, // 크기를 조절하기 위해 maxLines를 3으로 설정
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: '내용',
                          prefixIcon: const Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(width - 40, 50),
                            surfaceTintColor: Colors.transparent,
                            backgroundColor: context.appColors.appBar,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            if (_controller.text.isNotEmpty && selectedValue != null) {
                              final reportRequestDTO = ReportRequstDTO(
                                content: _controller.text,
                                carpoolId: '피드백',
                                reportedUser:'피드백',
                                reporter: widget.reporter,
                                reportType: selectedValue.toString(),
                                reportDate: DateTime.now().toString(),
                              );

                              // API 호출
                              bool isOpen =
                              await apiService.saveReport(reportRequestDTO);
                              if (isOpen) {
                                print("스프링부트 서버 성공 #############");
                                if (!mounted) return;
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                  const ComplainComplete(
                                    isReport: true,
                                  ),
                                );
                              } else {
                                print("스프링부트 서버 실패 #############");
                                if (!mounted) return;
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                    const ComplainShow(
                                        cautionText:
                                        "서버가 불안정합니다."));
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => const ComplainShow(
                                    cautionText: "분류 및 내용을 모두 입력해주세요.",
                                  ));
                            }
                          },
                          child: const Text('제출')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
