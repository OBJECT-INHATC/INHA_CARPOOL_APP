import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 초기값 인하대후문
final positionProvider = StateProvider<LatLng>((ref) => const LatLng(37.5665, 126.9780));

