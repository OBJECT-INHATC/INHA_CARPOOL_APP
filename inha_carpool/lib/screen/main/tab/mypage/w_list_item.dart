import 'package:flutter/material.dart';

class MypageListItem extends StatelessWidget {
  const MypageListItem(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap,
      required this.color});

  final IconData icon;
  final String title;
  final Function onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () => onTap(),
    );
  }
}
