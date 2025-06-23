import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';

class BlackButton extends StatelessWidget {
  const BlackButton(this.text, this.length, this.callback, {super.key});

  final String text;
  final double length;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: OutlinedButton.styleFrom(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      side: const BorderSide(width: 1.0, color: Colors.black),
      ),
      onPressed: callback,
      child: StyledBody(text, color: Colors.white,),
    );
  }
}