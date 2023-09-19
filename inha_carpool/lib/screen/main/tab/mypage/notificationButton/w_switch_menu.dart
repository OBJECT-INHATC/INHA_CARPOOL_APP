import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../../common/widget/w_empty_expanded.dart';
import 'w_os_switch.dart';

class Switchmenu extends StatelessWidget {
  final String title;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const Switchmenu(this.title, this.isOn, {super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    IconData iconData = title == "채팅 알림" ? Icons.chat : Icons.notifications;

    return Row(
      children: [
        Icon(iconData).pOnly(right: 15),
        title.text.size(17).make(),
        const EmptyExpanded(),
        OsSwitch(value: isOn, onChanged: onChanged,),

      ],
    ).p20();
  }
}
