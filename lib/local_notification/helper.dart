import 'package:flutter/material.dart';

class Helper {
  final BuildContext context;

  Helper(this.context);

  static void navigateNamed(BuildContext context, String name) async {
    Navigator.pushNamed(context, name);
  }
}
