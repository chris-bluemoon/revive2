import 'package:flutter/material.dart';

final textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintStyle: TextStyle(color: (Colors.grey[300])!),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: (Colors.grey[200])!, width: 2.0),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0)
  )
);