import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/theme/app_colors.dart';

import '../constants/app_strings.dart';
import 'custom_menu_item.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.current;
    final navItems = <_NavItem>[
      _NavItem(
        path: AppRoutesPath.dashboard,
        label: text.dashboardNavLabel,
        icon: CupertinoIcons.square_grid_2x2,
      ),
      _NavItem(
        path: AppRoutesPath.customers,
        label: text.customersNavLabel,
        icon: CupertinoIcons.person_3,
      ),
      _NavItem(
        path: AppRoutesPath.calls,
        label: text.callNavLabel,
        icon: CupertinoIcons.phone,
      ),
      _NavItem(
        path: AppRoutesPath.appointments,
        label: 'Calendar',
        icon: CupertinoIcons.calendar,
      ),
      _NavItem(
        path: AppRoutesPath.emailFollowUps,
        label: text.emailFollowupNavLabel,
        icon: CupertinoIcons.mail,
      ),
      _NavItem(
        path: AppRoutesPath.aiSettings,
        label: text.aiSettingsNavLabel,
        icon: CupertinoIcons.sparkles,
      ),
    ];

    final currentPath = GoRouterState.of(context).uri.path;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBgColor = isDark
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: sidebarBgColor,
                borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Image.asset(
                      'assets/icons/app_logo_transparent.png',
                      height: 75,
                      width: 75,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: navItems.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = navItems[index];
                          final isSelected = item.path == currentPath;

                          return CustomMenuItem(
                            isCurrentIndex: isSelected,
                            title: item.label,
                            icon: item.icon,
                            onTap: () {
                              if (isSelected) return;
                              context.go(item.path);
                            },
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showLogoutDialog(context),
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: isDark
                                    ? context.colors.blackColor
                                        .withValues(alpha: 0.8)
                                    : Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                text.logoutLabel.toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? context.colors.blackColor
                                          .withValues(alpha: 0.8)
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SpacedText(
                      text: text.copyRight.toUpperCase(),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 10,
                      fontSize: 8,
                      color: isDark
                          ? context.colors.darkGreyColor
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50), child: child),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final strings = AppStrings.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: context.colors.errorColor,
                  size: 32,
                ),
              ),
              SizedBox(height: 20),
              Text(
                strings.logoutConfirmTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                strings.logoutConfirmMessage,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.colors.lightGreyColor,
                          ),
                          foregroundColor:
                              isDark ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          strings.logoutCancelButton,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          final preferences =
                              context.read<PreferencesService>();
                          final router = GoRouter.of(context);
                          Navigator.pop(dialogContext);
                          await preferences.clearAuthSession();
                          router.go(AppRoutesPath.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.errorColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          strings.logoutConfirmButton,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({required this.path, required this.label, required this.icon});

  final String path;
  final String label;
  final IconData icon;
}
