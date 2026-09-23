// ============================================================
// Profile Screen (Customer tab)
// ============================================================
// iOS-settings-style grouped list: avatar header, language,
// My Vehicle shortcut, logout. Replaces the old modal-bottom-
// sheet profile popup.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/landing_screen.dart';
import '../../home/screens/my_vehicle_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final scheme = Theme.of(context).colorScheme;
    final fullName = user?.fullName ?? '';
    final googlePhoto = user?.googlePhotoUrl;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(context.l10n.profile,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: (googlePhoto != null && googlePhoto.isNotEmpty)
                        ? NetworkImage(googlePhoto)
                        : null,
                    child: (googlePhoto != null && googlePhoto.isNotEmpty)
                        ? null
                        : Text(
                            fullName.isEmpty ? '?' : fullName[0].toUpperCase(),
                            style: TextStyle(fontSize: 34, color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(fullName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(context.l10n.roleLabel(auth.role),
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _Group(children: [
              _Tile(
                icon: Icons.directions_car_rounded,
                iconColor: context.statusColors.warning,
                title: context.l10n.myVehicle,
                subtitle: context.l10n.addOrEditVehicle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyVehicleScreen()),
                ),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.language_rounded,
                iconColor: scheme.primary,
                title: context.l10n.language,
                trailing: _LanguagePicker(),
              ),
            ]),
            const SizedBox(height: 20),
            _Group(children: [
              _Tile(
                icon: Icons.logout_rounded,
                iconColor: context.statusColors.danger,
                title: context.l10n.logout,
                subtitle: context.l10n.signOutOfAccount,
                titleColor: context.statusColors.danger,
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LandingScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1),
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: const RoundedRectangleBorder(),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    return DropdownButton<String>(
      value: locale.locale.languageCode,
      underline: const SizedBox(),
      items: LocaleProvider.supportedLocales
          .map((l) => DropdownMenuItem(value: l.languageCode, child: Text(l.languageCode.toUpperCase())))
          .toList(),
      onChanged: (code) {
        if (code != null) context.read<LocaleProvider>().setLocale(Locale(code));
      },
    );
  }
}
