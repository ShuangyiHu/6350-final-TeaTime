import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter/material.dart';

// Widget defining a cancel brewing button
Widget cancelButton({
  required Color color,
  required Function()? onPressed,
}) {
  // Button with "X" icon
  return InkWell(
    borderRadius: BorderRadius.circular(4.0),
    onTap: onPressed,
    child: Container(
      padding: smallDefaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancelIcon(color: color),
          smallSpacerWidget,
          Text(
            AppString.cancel_button.translate(),
            style: textStyleButtonSecondary.copyWith(color: color),
          ),
        ],
      ),
    ),
  );
}
