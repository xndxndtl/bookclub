// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
