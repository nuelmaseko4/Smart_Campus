import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < destinations.length; i++)
                _NavItem(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  onTap: () {
                    if (i != selectedIndex) {
                      HapticFeedback.selectionClick();
                      onDestinationSelected(i);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [Colors.orange.shade800, Colors.orange.shade400],
                  )
                : null,
            borderRadius: BorderRadius.circular(26),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.orange.shade400.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.1 : 1.0,
                duration: _duration,
                curve: Curves.easeOutBack,
                child: IconTheme(
                  data: IconThemeData(
                    size: 24,
                    color: selected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                  child: icon,
                ),
              ),
              AnimatedSize(
                duration: _duration,
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          destination.label,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
