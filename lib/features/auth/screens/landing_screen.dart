// ============================================================
// Landing Screen
// ============================================================
// Shows the SafeRide welcome/landing page when not logged in.
// - "Let's Hire" button → navigates to customer login
// - "Register" button → navigates to role-selection registration screen
// - Shows admin-updatable support phone number
// - "or other logins" link → normal login screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/language_selector.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _contactPhone = '0763003678';
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _fetchAppSettings();
  }

  Future<void> _fetchAppSettings() async {
    try {
      final res = await ApiClient.instance.get('/api/rates', auth: false);
      final rate = res['data']?['rate'] as Map<String, dynamic>?;
      final phone = rate?['contactPhone'] as String?;
      final logo = rate?['appLogoUrl'] as String?;
      if (!mounted) return;
      setState(() {
        if (phone != null && phone.isNotEmpty) _contactPhone = phone;
        if (logo != null && logo.isNotEmpty) _logoUrl = logo;
      });
    } catch (_) {
      // Fall back to defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: LanguageSelector(
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: _logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: '${AppConstants.baseUrl}$_logoUrl',
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Text(
                            'D',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        )
                      : const Text(
                          'D',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Hero Message
              Text(
                context.l10n.heroTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.heroSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // LET'S HIRE button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to customer login mode
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(isCustomerMode: true),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_car, color: Colors.white, size: 28),
                label: Text(
                  context.l10n.letsHire,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
              ),
              const SizedBox(height: 12),

              // REGISTER button → opens role-selection registration screen
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 22),
                label: Text(
                  context.l10n.register,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // or other logins
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to normal login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(isCustomerMode: false),
                      ),
                    );
                  },
                  child: Text(
                    context.l10n.otherLogins,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 24/7 Support phone card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.headset_mic, color: Colors.green, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.support24_7,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.supportHelpText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        // Show phone in a snackbar (no url_launcher dependency)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.callUsAt(_contactPhone)),
                            action: SnackBarAction(label: context.l10n.call, onPressed: () {}),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _contactPhone,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // How it works mini section
              Text(
                context.l10n.howDadWorks,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),

              // 3 steps
              Row(
                children: [
                  Expanded(
                    child: _StepCard(number: '1', label: context.l10n.step1, color: Colors.orange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StepCard(number: '2', label: context.l10n.step2, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StepCard(number: '3', label: context.l10n.step3, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Step Card for "How SafeRide Works" section
// ============================================================
class _StepCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _StepCard({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}