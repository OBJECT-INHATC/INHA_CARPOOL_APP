import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

final searchProvider = StateProvider<bool>((ref) => false);