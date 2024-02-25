import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 카풀 이용횟수 관리
final yellowCountProvider = StateProvider<int>((ref) => 0);