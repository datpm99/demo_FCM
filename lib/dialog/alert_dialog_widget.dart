import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  const AlertDialogWidget(
      {Key? key, required this.title, required this.content})
      : super(key: key);
  final String title, content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
    );
  }
}

