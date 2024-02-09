import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';

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


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.04),
      child: Row(
        children: [
          // 이미지 아이콘 추가
           Icon(Icons.account_circle, size: width * 0.2, color: Colors.white),
          Width(width * 0.025),
          Text(
             "${state.userName!} 님",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Width(width * 0.04),
          Text(
            '#${state.nickName!}',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
