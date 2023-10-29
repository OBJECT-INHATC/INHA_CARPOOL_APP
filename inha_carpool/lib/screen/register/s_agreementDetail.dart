import 'package:flutter/material.dart';

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
          ],
        ),
      ),
    );
  }
}
