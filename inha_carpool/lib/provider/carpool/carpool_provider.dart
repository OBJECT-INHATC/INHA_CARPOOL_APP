import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/m_member.dart';
/// 참여중인 카풀의 수를 관리하는 provider 0207 이상훈
final authProvider = StateProvider<int>((ref) => 0);
