import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';

import 'package:flutter/material.dart';

// Sliver app bar page header
Widget pageHeader(
  BuildContext context, {
  Widget? leading,
  required String title,
  Widget? action,
}) {
  return SliverAppBar(
    elevation: 1,
    pinned: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
    shadowColor: Theme.of(context).shadowColor,
    automaticallyImplyLeading: false,
    titleSpacing: 0.0,
    leading: leading,
    title: Container(
      margin: headerPadding,
      alignment: Alignment.centerLeft,
      child: FittedBox(
        child: Text(
          title,
          style: textStyleHeader.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      ),
    ),
    actions: action != null ? [action] : null,
  );
}
