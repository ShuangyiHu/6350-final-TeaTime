import 'package:flutter/material.dart';

/// Separator builder for select lists, typically used between items.
/// Provides a visually styled divider.
Widget separatorBuilder(BuildContext context, int index) {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.0), // Adds horizontal padding
    child: listDivider,
  );
}

/// Dummy separator for placeholder use, providing an empty container.
/// Use this when no actual separator is needed.
Widget separatorDummy(BuildContext context, int index) {
  return const SizedBox.shrink(); // A widget that takes up no space.
}

/// Standard list divider used across the app.
/// Includes a default thickness and indents to fit common design patterns.
const Divider listDivider = Divider(
  thickness: 1.0, // Thickness of the line
  indent: 12.0, // Left padding
  endIndent: 12.0, // Right padding
  color: Colors.grey, // (Optional) Adjust divider color here
);
