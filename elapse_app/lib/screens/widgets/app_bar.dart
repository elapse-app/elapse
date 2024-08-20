import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ElapseAppBar extends StatelessWidget {
  const ElapseAppBar({
    super.key,
    required this.title,
    this.includeSettings = false,
    this.backNavigation = false,
    this.prefs,
    this.background,
  });
  final Widget title;
  final Widget? background;
  final bool includeSettings;
  final bool backNavigation;
  final SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    Widget? appBarBackground = background;
    if (includeSettings) {
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
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back,
                              color: Theme.of(context).colorScheme.onSurface),
                        )
                      : Container(),
                  Spacer(),
                  SettingsButton(),
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
                        Navigator.pop(context);
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
    return SliverAppBar.large(
      automaticallyImplyLeading: false,
      expandedHeight: 125,
      centerTitle: false,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double leftPadding = backNavigation
              ? -0.5 *
                  (constraints.maxHeight -
                      MediaQuery.of(context).padding.top -
                      125)
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
                  Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: title,
                  ),
                  backNavigation
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity((constraints.maxHeight -
                                        MediaQuery.of(context).padding.top -
                                        125) /
                                    -62),
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
