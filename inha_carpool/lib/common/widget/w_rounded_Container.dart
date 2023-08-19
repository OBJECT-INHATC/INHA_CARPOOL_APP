import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? backgroundColor;

  const RoundedContainer({
    required this.child,
    super.key,
    this.radius = 20,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
          color: backgroundColor ?? context.appColors.roundedLaoutButtonBackground,
          borderRadius: BorderRadius.circular(radius)),
      child: child,
    );
  }
}
