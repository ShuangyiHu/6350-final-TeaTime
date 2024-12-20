import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Countdown timer
class TimerCountdownWidget extends StatefulWidget {
  const TimerCountdownWidget({super.key});

  @override
  State<TimerCountdownWidget> createState() => _TimerCountdownWidgetState();
}

class _TimerCountdownWidgetState extends State<TimerCountdownWidget> {
  // State variables
  bool _showTimerAdjustments = false;
  int _hideTimerAdjustmentsDelay = 0;

  // Build the countdown timer(s)
  @override
  Widget build(BuildContext context) {
    // Determine layout based on device orientation
    bool layoutPortrait = getDeviceSize(context).isPortrait;

    // Countdown timer display adjusted for orientation
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Delay before hiding increments buttons
        if (_hideTimerAdjustmentsDelay > 0) {
          _hideTimerAdjustmentsDelay--;
          if (_hideTimerAdjustmentsDelay <= 0) {
            _showTimerAdjustments = false;
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: timerBackgroundColor,
            // Apply background colors to distinguish timers
            gradient: activeTimerCount > 0
                ? LinearGradient(
                    begin: layoutPortrait
                        ? Alignment.topCenter
                        : Alignment.centerLeft,
                    end: layoutPortrait
                        ? Alignment.bottomCenter
                        : Alignment.centerRight,
                    stops: List<double>.filled(
                      activeTimerCount,
                      !layoutPortrait && activeTimerCount > 1
                          ? timer1.timerString.length /
                              (timer1.timerString.length +
                                  timer2.timerString.length)
                          : 0.5,
                    ),
                    colors: [
                      for (TeaTimer timer in timerList)
                        if (timer.tea != null) timer.tea!.getColor(),
                    ],
                  )
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
          child: AnimatedSize(
            duration: shortAnimationDuration,
            curve: Curves.linear,
            child: activeTimerCount == 0
                ?
                // Idle timer
                _timerText()
                : Flex(
                    // Determine layout by orientation
                    direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer 1
                      AnimatedSize(
                        duration: longAnimationDuration,
                        curve: Curves.easeInOut,
                        child: timer1.isActive
                            ? _timerText(timer1)
                            : const SizedBox.shrink(),
                      ),
                      // Separator for timers with the same color
                      Visibility(
                        visible: activeTimerCount > 1 &&
                            timer1.tea?.color == timer2.tea?.color &&
                            timer1.tea?.colorShade == timer2.tea?.colorShade,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                          width: layoutPortrait ? 420.0 : 12.0,
                          height: layoutPortrait ? 12.0 : 140.0,
                          color: timerForegroundColor,
                        ),
                      ),
                      // Timer 2
                      AnimatedSize(
                        duration: longAnimationDuration,
                        curve: Curves.easeInOut,
                        child: timer2.isActive
                            ? _timerText(timer2)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _timerText([TeaTimer? timer]) {
    String text = timer?.timerString ?? formatTimer(0);
    int secs = (timer?.timerSeconds ?? 0) > 3600
        ? 60 * incrementSeconds // minute increments for longer timer
        : incrementSeconds;

    return Selector<AppProvider, bool>(
      selector: (_, provider) => provider.hideIncrements,
      builder: (context, hideIncrements, child) => Center(
        // Center aligns everything within this widget
        child: Row(
          mainAxisSize: MainAxisSize.min, // Shrink the row to fit its children
          children: [
            spacerWidget,

            // Silence button (conditionally rendered)
            timer != null && (_showTimerAdjustments || !hideIncrements)
                ? _silenceButton(timer)
                : spacerWidget,
            GestureDetector(
              // Toggle display of timer increment and mute buttons
              onTap: () => setState(() {
                _showTimerAdjustments = !_showTimerAdjustments;
                _hideTimerAdjustmentsDelay = hideTimerAdjustmentsDelay;
              }),
              // Timer text display
              child: AnimatedScale(
                scale: timer?.timerSeconds == 1 ? 1.04 : 1.0,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutExpo,
                child: Container(
                  padding: noPadding,
                  alignment: Alignment.center, // Ensure the text is centered
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    textScaler: TextScaler.noScaling,
                    style: textStyleTimer,
                  ),
                ),
              ),
            ),
            spacerWidget,
            spacerWidget,
          ],
        ),
      ),
    );
  }

  // Silence timer button
  Widget _silenceButton(TeaTimer timer) {
    return Container(
      margin: noPadding,
      child: IconButton(
        // Set the size of the icon
        iconSize: 100.0,
        // Toggle silent status for this timer
        onPressed: () {
          if (timer.tea != null) {
            setState(
              () => Provider.of<AppProvider>(context, listen: false)
                  .updateTea(timer.tea!, isSilent: !(timer.tea!.isSilent)),
            );

            // Update the notification
            sendNotification(
              timer.tea!.brewTimeRemaining,
              AppString.notification_title.translate(),
              AppString.notification_text.translate(teaName: timer.tea!.name),
              timer.notifyID,
              silent: timer.tea!.isSilent,
            );
          }
          _hideTimerAdjustmentsDelay = hideTimerAdjustmentsDelay;
        },
        // Button with speaker icon
        icon: (timer.tea?.isSilent ?? false) ? mutedIcon : unmutedIcon,
      ),
    );
  }

  // Increment timer button
  Widget _incrementButton(TeaTimer timer, int secs) {
    int buttonValue = secs.abs() > 60 ? secs.abs() ~/ 60 : secs.abs();
    String buttonValueUnit = secs.abs() > 60
        ? AppString.unit_minutes.translate()
        : AppString.unit_seconds.translate();

    return Container(
      margin: smallDefaultPadding,
      child: TextButton(
        // Increment this timer
        onPressed: () {
          if (timer.tea != null) {
            if (Provider.of<AppProvider>(context, listen: false)
                .incrementTimer(timer.tea!, secs)) {
              // If adjustment was successful, update the notification
              sendNotification(
                timer.tea!.brewTimeRemaining,
                AppString.notification_title.translate(),
                AppString.notification_text.translate(teaName: timer.tea!.name),
                timer.notifyID,
                silent: timer.tea!.isSilent,
              );
            }
          }
          _hideTimerAdjustmentsDelay = hideTimerAdjustmentsDelay;
        },
        // Button with +/- icon and increment amount
        child: Column(
          children: [
            Icon(
              secs > 0 ? incrementPlusIcon : incrementMinusIcon,
              color: timerForegroundColor,
              size: 28.0,
            ),
            Text(
              '$buttonValue$buttonValueUnit',
              style: textStyleTimerIncrement,
            ),
          ],
        ),
      ),
    );
  }
}
