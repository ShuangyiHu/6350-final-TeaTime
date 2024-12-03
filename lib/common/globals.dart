import 'package:cuppa_mobile/common/constants.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:region_settings/region_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global navigator
final navigatorKey = GlobalKey<NavigatorState>();

// Shared preferences
late SharedPreferences sharedPrefs;
int nextTeaID = 0;

// Device info
late RegionSettings regionSettings;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: unknownString,
  packageName: unknownString,
  version: unknownString,
  buildNumber: unknownString,
);

// Quick actions
const QuickActions quickActions = QuickActions();

// App store review prompt
Function checkReviewPrompt = () {};
