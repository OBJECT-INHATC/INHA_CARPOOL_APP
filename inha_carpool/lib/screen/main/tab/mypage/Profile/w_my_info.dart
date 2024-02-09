import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../../common/widget/w_custom_png.dart';
import '../../../../../provider/auth/auth_provider.dart';

class AuthInfoRow extends ConsumerStatefulWidget {
  const AuthInfoRow({super.key});

  @override
  ConsumerState<AuthInfoRow> createState() => _AuthInfoState();
}

class _AuthInfoState extends ConsumerState<AuthInfoRow> {

  @override
  Widget build(BuildContext context) {

    final  state = ref.watch(authProvider);
    final width = context.screenWidth;


    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          children: [
            Height(width * 0.06),

            state.nickName!.text.size(10).make(),

            Height(width * 0.03),
            // 사람 이미지 아이콘
            const Icon(Icons.account_circle, size: 70, color: Colors.white,),

          ],
        ),
        Spacer(),

        CustomPng(
          fileDirectory: 'splash',
          fileName: 'school_logo',
          height: width * 0.15,
          width: width * 0.3,
        ),
        // 이미지 아이콘 추가


      ],
    );
  }
}
