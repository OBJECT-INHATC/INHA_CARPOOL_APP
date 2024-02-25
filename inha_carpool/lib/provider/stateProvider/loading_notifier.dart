import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로딩중을 위한 상태관리
final loadingProvider = StateProvider<bool>((ref) => false);

/// 검색중인지 확인 상태관리
final searchProvider = StateProvider<bool>((ref) => false);