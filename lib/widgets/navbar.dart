import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final Function(int) onPageChanged;

  const CustomBottomNavBar({
    Key? key,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 0;

  // List of navigation items with their details
  final List<_NavItemData> _navItems = [
    _NavItemData(
      icon: Icons.home_rounded,
      label: 'Home',
      route: '/home',
    ),
    _NavItemData(
      icon: Icons.restaurant_rounded,
      label: 'Resto',
      route: '/restaurants',
    ),
    _NavItemData(
      icon: Icons.favorite_rounded,
      label: 'Favorit',
      route: '/favorites',
    ),
    _NavItemData(
      icon: Icons.star_rounded,
      label: 'Review',
      route: '/reviews',
    ),
    _NavItemData(
      icon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              return _buildNavItem(
                index: index,
                icon: item.icon,
                label: item.label,
                isSelected: _currentIndex == index,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Update local state
        setState(() {
          _currentIndex = index;
        });

        // Call the callback to notify parent
        widget.onPageChanged(index);

        // Optional: Navigate using the predefined route
        Navigator.pushNamed(context, _navItems[index].route);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF94C973).withOpacity(0.1) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? const Color(0xFF94C973) 
                : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? const Color(0xFF94C973) 
                  : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected 
                  ? FontWeight.w600 
                  : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to define navigation item properties
class _NavItemData {
  final IconData icon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
