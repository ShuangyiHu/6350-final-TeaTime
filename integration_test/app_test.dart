/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    app_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa integration tests

import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/cuppa_app.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/widgets/tea_brew_time_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_name_dialog.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('end-to-end tea timer test', ($) async {
    // Test timer setings
    const int timerSeconds = 15;
    const String timerName = 'Test Tea';

    // Run app
    await initializeApp();
    await $.pumpWidgetAndSettle(const CuppaApp());

    // Tap through tutorials
    for (var _ in tutorialSteps.keys) {
      await $.native.tapAt(const Offset(0.5, 0.5));
      await $.pumpAndSettle();
    }

    // Navigate to Prefs page
    await $.tap(
      find.byIcon(
        getPlatformSettingsIcon().icon!,
        skipOffstage: false,
      ),
    );
    expect(find.text(AppString.prefs_title.translate()), findsOneWidget);

    // Delete all teas
    final Finder removeButton = find.byIcon(getPlatformRemoveAllIcon().icon!);
    await $.scrollUntilVisible(finder: removeButton);
    await $.tap(removeButton);
    expect(find.text(AppString.confirm_delete.translate()), findsOneWidget);
    await $.tap(find.text(AppString.yes_button.translate()));

    // Add a test tea
    await $.tap(find.byIcon(addIcon.icon!));
    await $.tap(find.text(Presets.presetList[0].key.translate()));

    // Edit test tea name
    await $.tap(find.text(Presets.presetList[0].localizedName));
    expect(find.byType(TeaNameDialog), findsOneWidget);
    await $.tap(find.byIcon(clearIcon.icon!));
    await $(Platform.isIOS ? CupertinoTextFormFieldRow : TextFormField)
        .at(0)
        .enterText(timerName);
    await $.tap(find.text(AppString.ok_button.translate()));
    if (Platform.isAndroid) {
      // Dismiss soft keyboard
      await $.native.pressBack();
      await $.pumpAndSettle();
    }
    expect(find.text(timerName), findsOneWidget);

    // Edit test tea brew time
    await $.tap(find.text(formatTimer(Presets.presetList[0].brewTime)));
    expect(find.byType(TeaBrewTimeDialog), findsOneWidget);
    for (int i = 0; i < (Presets.presetList[0].brewTime / timerSeconds); i++) {
      await $.tap(
        find.byIcon(incrementDownIcon),
        settlePolicy: SettlePolicy.noSettle,
      );
    }
    await $.tap(find.text(AppString.ok_button.translate()));
    expect(find.text(formatTimer(timerSeconds)), findsOneWidget);

    // Enable stats collection
    if ($(navBarSettingsIcon.icon!).exists) {
      await $.tap($(navBarSettingsIcon.icon!));
    }
    final Finder statsSwitch = find.text(AppString.stats_enable.translate());
    await $.scrollUntilVisible(finder: statsSwitch);
    await $.tap(statsSwitch);
    expect(
      find.text(AppString.stats_confirm_enable.translate()),
      findsOneWidget,
    );
    await $.tap(find.text(AppString.yes_button.translate()));

    // Navigate to Stats page and validate report
    await $.tap(
      find.byIcon(
        getPlatformStatsIcon().icon!,
        skipOffstage: false,
      ),
    );
    expect(find.text(AppString.stats_header.translate()), findsOneWidget);
    expect(find.text(formatTimer(0)), findsOneWidget);

    // Navigate back to Timer page
    if (Platform.isIOS) {
      await $.tap(find.text(AppString.prefs_title.translate()));
      await $.tap(find.text(AppString.done_button.translate()));
    } else {
      await $.native.pressBack();
      await $.native.pressBack();
    }
    await $.pumpAndSettle();
    expect(find.text(formatTimer(0)), findsOneWidget);

    // Start timer and allow permission
    await $.tap(find.text(timerName));
    await $.native.tap(
      Selector(text: 'Allow'),
      appId: Platform.isIOS ? 'com.apple.springboard' : null,
    );

    // Check for notification after timer duration
    await Future.delayed(const Duration(seconds: timerSeconds));
    await $.native.openNotifications();
    bool didNotify = false;
    for (var notification in await $.native.getNotifications()) {
      if (notification.content.contains(timerName)) {
        didNotify = true;
      }
    }
    expect(didNotify, true);
    await $.native.closeNotifications();
    expect(find.text(timerName), findsOneWidget);

    // Navigate to Stats page and re-validate report
    await $.tap(
      find.byIcon(
        getPlatformSettingsIcon().icon!,
        skipOffstage: false,
      ),
    );
    await $.tap(
      find.byIcon(
        getPlatformStatsIcon().icon!,
        skipOffstage: false,
      ),
    );
    expect(find.text(AppString.stats_title.translate()), findsOneWidget);
    expect(find.text(timerName), findsNWidgets(2));
    expect(find.text(formatTimer(timerSeconds)), findsOneWidget);
  });
}
