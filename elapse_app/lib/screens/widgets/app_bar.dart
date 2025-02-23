import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/classes/Miscellaneous/remote_config.dart';

class ElapseAppBar extends StatelessWidget {
  const ElapseAppBar({
    super.key,
    required this.title,
    this.includeSettings = false,
    this.backNavigation = false,
    this.returnData,
    this.background,
    this.maxHeight = 125,
    this.backBehavior,
    this.settingsCallback,
    this.showVDAWarning = true,
  });
  final Widget title;
  final Widget? background;
  final bool includeSettings;
  final bool backNavigation;
  final Object? returnData;
  final double maxHeight;
  final bool showVDAWarning;
  final void Function()? backBehavior;
  final void Function()? settingsCallback;

  @override
  Widget build(BuildContext context) {
    final remoteConfig = FirebaseRemoteConfigService();
    final showVDAWarn =
        !remoteConfig.getBool(FirebaseRemoteConfigKeys.vdaStatusKey);
    print("PRINT showVDAWarm $showVDAWarn");
    Widget? appBarBackground = background;
    if (includeSettings && background == null) {
      appBarBackground = SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 23, right: 12, bottom: 20, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backNavigation
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pop(context, returnData);
                          },
                          child: Icon(Icons.arrow_back,
                              color: Theme.of(context).colorScheme.onSurface),
                        )
                      : Container(),
                  Spacer(),
                  SettingsButton(callback: settingsCallback),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (backNavigation && background == null) {
      appBarBackground = SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 23, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              backNavigation
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context, returnData);
                      },
                      child: Icon(Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onSurface),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    }

    late void Function() backBehaviorFunction;

    if (backBehavior == null) {
      backBehaviorFunction = () {
        Navigator.pop(context);
      };
    } else {
      backBehaviorFunction = backBehavior!;
    }
    return SliverAppBar.large(
      automaticallyImplyLeading: false,
      expandedHeight: maxHeight,
      centerTitle: false,
      
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double leftPadding = backNavigation
              ? (-0.5 *
                      (constraints.maxHeight -
                          MediaQuery.of(context).padding.top -
                          125))
                  .clamp(0, double.infinity)
              : 0;
          return FlexibleSpaceBar(
              expandedTitleScale: 1.25,
              collapseMode: CollapseMode.parallax,
              titlePadding: EdgeInsetsDirectional.only(
                start: 23,
                bottom: 16,
              ),
              title: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  showVDAWarning ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: leftPadding),
                          child: title,
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: leftPadding + 5),
                            child: showVDAWarn
                                ? IconButton(
                                    icon: const Icon(Icons.sync_problem,
                                        size: 24,
                                        color: Color.fromRGBO(0, 0, 0, 1)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18)),
                                              title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Some experiences may be limited",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        "One of our data sources, vrc-data-analysis, isn't functioning properly right now. Some features may be temporarily unavailable.",
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ]),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  )
                                : Container(height:1))
                        
                      ]) : Padding(
                          padding: EdgeInsets.only(left: leftPadding),
                          child: title,
                        ),
                  backNavigation
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pop(context, returnData);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(
                                    alpha: ((constraints.maxHeight -
                                                MediaQuery.of(context)
                                                    .padding
                                                    .top -
                                                125) /
                                            -62)
                                        .clamp(0, 1)),
                          ),
                        )
                      : Container(
                          height: 1,
                        ),
                ],
              ),
              centerTitle: false,
              background: appBarBackground);
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
