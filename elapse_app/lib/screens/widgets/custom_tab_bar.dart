import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key, required this.tabs, required this.onPressed, this.disabledTabs, this.initIndex = 0});
  final List<String> tabs;
  final List<bool>? disabledTabs;
  final void Function(int value) onPressed;
  final int initIndex;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initIndex;
    while (widget.disabledTabs != null && widget.disabledTabs![selectedItem]) {
      selectedItem++;
      if (selectedItem >= widget.disabledTabs!.length) {
        selectedItem = 0;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverHeaderDelegate(
        minHeight: 55.0,
        maxHeight: 55.0,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              color: Theme.of(context).colorScheme.primary,
              height: 55,
            ),
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.tabs.map(
                  (e) {
                    bool isSelected = selectedItem == widget.tabs.indexOf(e);
                    return IntrinsicWidth(
                      child: TextButton(
                        onPressed: widget.disabledTabs == null || !widget.disabledTabs![widget.tabs.indexOf(e)]
                            ? () {
                                setState(() {
                                  selectedItem = widget.tabs.indexOf(e);
                                });
                                widget.onPressed(selectedItem);
                              }
                            : null,
                        child: Column(
                          children: [
                            Spacer(),
                            Text(
                              e,
                              style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.secondary
                                      : widget.disabledTabs == null || !widget.disabledTabs![widget.tabs.indexOf(e)]
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            Spacer(),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.surfaceDim),
          ],
        ),
      ),
    );
  }
}

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight || oldDelegate.maxHeight != maxHeight || oldDelegate.child != child;
  }
}
