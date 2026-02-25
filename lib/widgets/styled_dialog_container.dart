import 'package:flutter/material.dart';

class StyledDialogContainer extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final double borderRadius;

  const StyledDialogContainer({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.borderRadius = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      insetPadding: const EdgeInsets.all(20),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      content: content,
      actions: actions,
    );
  }
}
