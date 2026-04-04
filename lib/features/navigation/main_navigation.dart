import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../home/home_screen.dart';
import '../cards/cards_screen.dart';
import '../send_money/send_amount_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  late AnimationController _hideNavAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _hideNavAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Initially visible
    );
  }

  @override
  void dispose() {
    _hideNavAnimation.dispose();
    super.dispose();
  }

  // Moving screens into a method to ensure they rebuild with the correct language context
  List<Widget> _getScreens() => [
    const HomeScreen(key: ValueKey('home')),
    const HistoryScreen(key: ValueKey('history')),
    const SendAmountScreen(key: ValueKey('send')),
    const CardsScreen(key: ValueKey('cards')),
    const ProfileScreen(key: ValueKey('profile')),
  ];

  void _onItemTapped(int index, AppState state) {
    state.setNavIndex(index);
    // Ensure nav is visible when switching tabs
    if (!_isVisible) {
      _hideNavAnimation.forward();
      _isVisible = true;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta != null) {
        if (notification.scrollDelta! > 10 && _isVisible) {
          // Scrolling down, hide nav
          _hideNavAnimation.reverse();
          _isVisible = false;
        } else if (notification.scrollDelta! < -10 && !_isVisible) {
          // Scrolling up, show nav
          _hideNavAnimation.forward();
          _isVisible = true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final theme = Theme.of(context);
    final state = AppState();
    final screens = _getScreens();

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Row(
          children: [
            if (isDesktop || (isLandscape && !ResponsiveBreakpoints.of(context).isMobile))
              _buildSidebar(context, state, theme),
              
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: Stack(
                  children: [
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                        return FadeThroughTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          child: child,
                        );
                      },
                      child: screens[state.selectedNavIndex],
                    ),
                    
                    if (!isDesktop && !(isLandscape && !ResponsiveBreakpoints.of(context).isMobile))
                      _buildMobileBottomNav(context, state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppState state, ThemeData theme) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Text("MurtaaxPay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  _buildSidebarItem(0, state.translate("Home", "Hoyga"), FontAwesomeIcons.house, state),
                  _buildSidebarItem(1, state.translate("History", "Taariikhda"), FontAwesomeIcons.clockRotateLeft, state),
                  _buildSidebarItem(2, state.translate("Send", "Diris"), FontAwesomeIcons.paperPlane, state),
                  _buildSidebarItem(3, state.translate("Cards", "Kaadhadhka"), FontAwesomeIcons.creditCard, state),
                  _buildSidebarItem(4, state.translate("Profile", "Profile-ka"), FontAwesomeIcons.user, state),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SwitchListTile.adaptive(
              title: const Text("Dark Mode", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: state.themeMode == ThemeMode.dark,
              activeThumbColor: AppColors.accentTeal,
              onChanged: (v) => state.toggleTheme(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon, AppState state) {
    bool isSelected = state.selectedNavIndex == index;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _onItemTapped(index, state),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              FaIcon(icon, size: 18, color: isSelected ? AppColors.accentTeal : AppColors.grey),
              const SizedBox(width: 16),
              Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? AppColors.accentTeal : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav(BuildContext context, AppState state) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // In landscape mode on mobile, we might want to hide the bottom nav or make it smaller
    if (isLandscape && ResponsiveBreakpoints.of(context).isMobile) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0, right: 0, bottom: (isLandscape ? 8 : 24) + bottomPadding,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 2), // Hide further down
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _hideNavAnimation,
          curve: Curves.easeInOut,
        )),
        child: Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryDark, 
                borderRadius: BorderRadius.circular(35), 
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.3), 
                    blurRadius: 20, 
                    offset: const Offset(0, 10)
                  )
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, FontAwesomeIcons.house, state),
                  _buildNavItem(1, FontAwesomeIcons.clockRotateLeft, state),
                  _buildCenterButton(state),
                  _buildNavItem(3, FontAwesomeIcons.creditCard, state),
                  _buildNavItem(4, FontAwesomeIcons.user, state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, AppState state) {
    bool isSelected = state.selectedNavIndex == index;
    return IconButton(
      onPressed: () => _onItemTapped(index, state),
      icon: FaIcon(icon, color: isSelected ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.5), size: 20),
    );
  }

  Widget _buildCenterButton(AppState state) {
    return GestureDetector(
      onTap: () => _onItemTapped(2, state),
      child: Container(
        height: 50, width: 50,
        decoration: const BoxDecoration(gradient: AppColors.accentGradient, shape: BoxShape.circle),
        child: const Icon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 20),
      ),
    );
  }
}

