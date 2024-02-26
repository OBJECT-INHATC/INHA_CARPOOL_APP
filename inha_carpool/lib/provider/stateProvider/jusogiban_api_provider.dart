import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 주소 기반 산업 서비스 api key는 90일마다 리셋되므로 서버 or 파베에서 제공하는 것으로 대체

final jusoKeyProvider = StateProvider<String>((ref) => 'jusogiban_api_key');


