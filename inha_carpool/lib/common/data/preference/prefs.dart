
import '../../theme/custom_theme.dart';
import 'item/nullable_preference_item.dart';

class Prefs {
  static final appTheme = NullablePreferenceItem<CustomTheme>('appTheme');
}
