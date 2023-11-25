import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/register/s_agreementDetail.dart';
import 'package:inha_Carpool/screen/register/s_register.dart';
import 'package:inha_Carpool/screen/register/detailContent.dart';

/// 약관 동의 페이지
class Agreement extends StatefulWidget {
  const Agreement({Key? key}) : super(key: key);

  @override
  _AgreementState createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  bool isAllAgreed = false; // "전체 동의" 상태를 저장 변수

  // 약관 동의 목록 리스트
  final List<Map<String, dynamic>> _agreementList = [
    {'value': false, 'label': '(필수) 서비스 이용약관 동의'},
    {'value': false, 'label': '(필수) 개인정보 수집 및 이용 동의'},
    {'value': false, 'label': '(필수) 위치정보 수집 및 이용 동의'},
    // {'value': false, 'label': '(선택) 마케팅 정보 수신 동의'}, // 추후에 추가 예정
  ];

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    final bool isChecked1 = _agreementList[0]['value'];
    final bool isChecked2 = _agreementList[1]['value'];
    final bool isChecked3 = _agreementList[2]['value'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30,
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          // color: Colors.grey[200],
          height: height * 4 / 5,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                height: 70,
                child: Image(
                  image: AssetImage('assets/image/splash/logo.png'),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("약관 동의",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("필수 항목 및 선택항목 약관에 동의해 주세요."),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                width: width - 60,
                height: 100, // 높이 조절
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAllAgreed = !isAllAgreed;
                      for (var item in _agreementList) {
                        item['value'] = isAllAgreed;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 20, right: 5),
                    backgroundColor: isAllAgreed
                        ? const Color.fromARGB(255, 70, 100, 192)
                        : const Color(0xEEEEEEF5),
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '전체 동의',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Transform.scale로 체크박스 크기 조절
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            value: isAllAgreed,
                            onChanged: (value) {
                              setState(() {
                                isAllAgreed = value!;
                                for (var item in _agreementList) {
                                  item['value'] = isAllAgreed;
                                }
                              });
                            },
                            checkColor: const Color.fromARGB(255, 70, 100, 192),
                            // 클릭 시 체크표시 색상
                            activeColor: Colors.white,
                            // 클릭 시 체크박스 색상
                            // 테두리
                            side: const BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: width - 60,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: Column(
                        children: [
                          // 약관1
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Text(
                                      _agreementList[0]['label'],
                                      style: TextStyle(
                                        fontSize: width > 380 ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AgreementDetailPage(
                                        title: _agreementList[0]['label'],
                                        detail: DetailContent.serviceAgreement,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  value: isChecked1,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreementList[0]['value'] =
                                          value; // 체크박스의 상태를 변경합니다.
                                      isAllAgreed = !_agreementList.any(
                                          (agreement) => !agreement['value']);
                                    });
                                  },
                                  checkColor: Colors.white,
                                  // 클릭 시 체크표시 색상
                                  activeColor: const Color.fromARGB(
                                      255, 70, 100, 192), // 클릭 시 체크박스 색상
                                ),
                              ),
                            ],
                          ),
                          // 약관2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Text(
                                      _agreementList[1]['label'],
                                      style: TextStyle(
                                        fontSize: width > 380 ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AgreementDetailPage(
                                        title: _agreementList[1]['label'],
                                        detail: DetailContent.privacyAgreement,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  value: isChecked2,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreementList[1]['value'] =
                                          value; // 체크박스의 상태를 변경합니다.
                                      isAllAgreed = !_agreementList.any(
                                          (agreement) => !agreement['value']);
                                    });
                                  },
                                  checkColor: Colors.white,
                                  activeColor:
                                      const Color.fromARGB(255, 70, 100, 192),
                                ),
                              ),
                            ],
                          ),
                          // 약관3
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Text(
                                      _agreementList[2]['label'],
                                      style: TextStyle(
                                        fontSize: width > 380 ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AgreementDetailPage(
                                        title: _agreementList[2]['label'],
                                        detail: DetailContent.locationAgreement,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  value: isChecked3,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreementList[2]['value'] =
                                          value; // 체크박스의 상태를 변경합니다.
                                      isAllAgreed = !_agreementList.any(
                                          (agreement) => !agreement['value']);
                                    });
                                  },
                                  checkColor: Colors.white,
                                  activeColor:
                                      const Color.fromARGB(255, 70, 100, 192),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1), // 빈 공간 차지
              Container(
                margin: const EdgeInsets.only(bottom: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print("object");
                        if (isAllAgreed) {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              // secondaryAnimation: 화면 전환시 사용되는 보조 애니메이션 효과
                              // child: 화면이 전환되는 동안 표시할 위젯 의미함
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const RegisterPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0,
                                    0.0); //0ffset에서 x값 1은 오른쪽 끝, y값 1은 아래쪽 끝
                                const end = Offset.zero; //애니메이션이 부드럽게 동작하도록 명령
                                const curve =
                                    Curves.easeInOut; //애니메이션의 시작과 끝 담당
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                    position: offsetAnimation, child: child);
                              },
                            ),
                          );
                        } else {
                          context.showSnackbar('필수 약관에 동의해 주세요.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.transparent,
                        backgroundColor:
                            const Color.fromARGB(255, 70, 100, 192),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(width - 60, 60), // 버튼 크기 조정
                      ),
                      child: const Text(
                        '다음',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
