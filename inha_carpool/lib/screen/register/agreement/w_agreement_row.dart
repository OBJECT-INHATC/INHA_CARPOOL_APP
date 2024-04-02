
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/register/agreement/s_agreement_detail.dart';

import 't_detail_content.dart';

class AgreementRow extends StatelessWidget {
  const AgreementRow({super.key, required this.agreeTitle});

  final String agreeTitle;

  @override
  Widget build(BuildContext context) {

    final width = context.screenWidth;

    return GestureDetector(
      child: Row(
        children: [
          Text(
            agreeTitle,
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
        print('동의서 클릭 $agreeTitle ');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AgreementDetailPage(
              title: agreeTitle,
              detail: agreeTitle == '(필수) 서비스 이용약관 동의'
                  ? DetailContent.serviceAgreement
                  : agreeTitle == '(필수) 개인정보 수집 및 이용 동의'
                      ? DetailContent.privacyAgreement
                          : DetailContent.locationAgreement,
            ),
          ),
        );
      },
    );
  }
}
