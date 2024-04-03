import 'package:flutter_dotenv/flutter_dotenv.dart';

export 'theme/color/abs_theme_colors.dart';
export 'theme/shadows/abs_theme_shadows.dart';

const basePath = 'assets/image';

String? baseUrl = dotenv.env['BASE_URL']; // API 서버의 URL 영재

const String version = '© 컴퓨터시스템공학과 Object ver 2.0.1';





