import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';


extension SnackbarContextExtension on BuildContext {
  void showSnackbarMaxmember(BuildContext context) {
    _showSnackBarWithContext(
      context,
      _SnackbarFactory.createSnackBar(context, '방이 가득 찼습니다.'),
    );
  }

  void showSnackbarText(BuildContext context, String message,
      {Color? bgColor}) {
    _showSnackBarWithContext(
      context,
      _SnackbarFactory.createSnackBar(context, message, bgColor: bgColor),
    );
  }

  ///Scaffold안에 Snackbar를 보여줍니다.
  void showSnackbar(String message, {Widget? extraButton}) {
    _showSnackBarWithContext(
      this,
      _SnackbarFactory.createSnackBar(this, message, extraButton: extraButton),
    );
  }

  ///Scaffold안에 빨간 Snackbar를 보여줍니다.
  void showErrorSnackbar(
    String message, {
    Color bgColor = AppColors.salmon,
    double bottomMargin = 0,
  }) {
    _showSnackBarWithContext(
      this,
      _SnackbarFactory.createErrorSnackBar(
        this,
        message,
        bgColor: bgColor,
        bottomMargin: bottomMargin,
      ),
    );
  }
}

void _showSnackBarWithContext(BuildContext context, SnackBar snackbar) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

class _SnackbarFactory {
  static SnackBar createSnackBar(BuildContext context, String message,
      {Color? bgColor, Widget? extraButton}) {
    Color snackbarBgColor = bgColor ?? context.appColors.snackbarBgColor;
    final width = context.screenWidth;

    return SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.transparent,
        content: Tap(
          onTap: () {
            try {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {
              //do nothing
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: snackbarBgColor,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  snackbarBgColor == Colors.red
                      ? Icons.error_outline
                      : snackbarBgColor == Colors.green
                          ? Icons.check_outlined
                          : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: width * 0.08,
                ),
                Width(width * 0.02),
                Expanded(
                  child: Text(message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.normal,
                      )),
                ),
                if (extraButton != null) extraButton,
              ],
            ),
          ),
        ));
  }

  static SnackBar createErrorSnackBar(BuildContext context, String? message,
      {Color bgColor = AppColors.salmon, double bottomMargin = 0}) {
    return SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.transparent,
        content: Tap(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.only(bottom: bottomMargin),
            child: Text("$message",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                )),
          ),
        ));
  }
}
