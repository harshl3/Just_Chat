import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.greenAccent.withOpacity(.8),
        behavior: SnackBarBehavior.floating,
        // duration: Duration(seconds: 2),
      ),
    );
  }

  static void showProgressBar(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
    );
  }
}
