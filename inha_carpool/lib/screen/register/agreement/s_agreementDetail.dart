import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';


/// 약관 상세 페이지
class AgreementDetailPage extends StatelessWidget {
  final String title;
  final String detail;

  const AgreementDetailPage(
      {super.key, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    String replaceTitle = title.replaceAll(' 동의', '');
    String newTitle = replaceTitle.replaceAll('(필수) ', '');
    String detailTitle = replaceTitle.replaceAll('(필수)', '인하카풀');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30,
        ),
        title: Text(
          newTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              width: double.infinity,
              height: 45,
              alignment: Alignment.center,
              // color: Colors.grey[200],
              child: Text(
                detailTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  detail,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(

                  surfaceTintColor: Colors.transparent,
                  backgroundColor: context.appColors.logoColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
