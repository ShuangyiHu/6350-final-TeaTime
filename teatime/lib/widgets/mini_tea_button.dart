import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/themes.dart';

import 'package:flutter/material.dart';

// Preview of a tea button with color and theme
Widget miniTeaButton({
  required Color? color,
  required IconData icon,
  bool isActive = false,
  bool darkTheme = false,
}) {
  return Theme(
    data: darkTheme ? darkThemeData : lightThemeData,
    child: Card(
      elevation: 1.0,
      margin: noPadding,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: isActive ? color : null),
        child: Container(
          margin: largeDefaultPadding,
          child: Icon(
            icon,
            color: isActive ? timerActiveColor : color,
            size: 28.0,
          ),
        ),
      ),
    ),
  );
}
