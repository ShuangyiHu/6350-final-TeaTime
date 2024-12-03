import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/prefs_page.dart';
import 'package:cuppa_mobile/widgets/tea_button_list.dart';
import 'package:cuppa_mobile/widgets/teacup.dart';
import 'package:cuppa_mobile/widgets/timer_countdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Cuppa Timer page
class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  // Build Timer page
  @override
  Widget build(BuildContext context) {
    // Determine layout based on device orientation
    bool layoutPortrait = getDeviceSize(context).isPortrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrefsWidget()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Flex(
                direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Countdown timers
                  Expanded(
                    flex: layoutPortrait ? 4 : 3,
                    child: Container(
                      padding: layoutPortrait
                          ? wideTimerLayoutPadding
                          : narrowTimerLayoutPadding,
                      alignment: layoutPortrait
                          ? Alignment.center
                          : Alignment.centerRight,
                      child: const FittedBox(
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center,
                        child: TimerCountdownWidget(),
                      ),
                    ),
                  ),
                  // Teacup
                  Selector<AppProvider, bool>(
                    selector: (_, provider) => provider.stackedView,
                    builder: (context, stackedView, child) {
                      return Expanded(
                        flex: layoutPortrait && !stackedView ? 5 : 3,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: getDeviceSize(context).height * 0.45,
                          ),
                          padding: layoutPortrait
                              ? narrowTimerLayoutPadding
                              : wideTimerLayoutPadding,
                          alignment: layoutPortrait
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: teacup(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tea brew start buttons
            const TeaButtonList(),
          ],
        ),
      ),
    );
  }
}
