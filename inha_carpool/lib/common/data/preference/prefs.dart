
import '../../theme/custom_theme.dart';
import 'item/nullable_preference_item.dart';
import 'item/rx_preference_item.dart';
import 'item/rxn_preference_item.dart';

class Prefs {
  static final appTheme = NullablePreferenceItem<CustomTheme>('appTheme');
  static final isPushOnRx = RxPreferenceItem<bool, RxBool>('isPushOnRx', true);
  static final isAdPushOnRx = RxPreferenceItem<bool, RxBool>('isAdPushOnRx', true);
  static final isSchoolPushOnRx = RxPreferenceItem<bool, RxBool>('isSchoolPushOnRx', true);
  static final chatRoomOnRx = RxPreferenceItem<bool, RxBool>('chatRoomOnRx', true);
  static final chatRoomCarIdRx = RxPreferenceItem<String, RxString>('chatRoomCarIdRx', "carId");


}
