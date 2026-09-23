// ============================================================
// Login Screen
// ============================================================
// User login with email + password or Google Sign-In.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/auth/google_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../main.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isCustomerMode;
  const LoginScreen({super.key, this.isCustomerMode = false});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _keepLoggedIn = true; // Keep me logged in — default ON for all roles
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _googleSignIn() async {
    debugPrint('🟢 [LoginScreen] _googleSignIn called');
    if (mounted) {
      setState(() => _googleLoading = true);
    }
    try {
      final account = await GoogleAuthService.instance.signIn();
      if (account == null) {
        debugPrint('⚠️ [LoginScreen] User cancelled Google sign-in');
        return;
      }
      debugPrint('🟢 [LoginScreen] Google account: ${account.email}');

      final idToken = await GoogleAuthService.instance.getIdToken();
      if (idToken == null) {
        debugPrint('❌ [LoginScreen] ID token is null');
        throw Exception('Could not obtain Google ID token');
      }
      debugPrint('🟢 [LoginScreen] Got ID token (${idToken.length} chars), sending to backend...');

      final auth = context.read<AuthProvider>();
      final success = await auth.googleSignIn(idToken, role: 'CUSTOMER');
      debugPrint('🟢 [LoginScreen] Backend result: success=$success');
      if (!mounted) return;
      if (success) {
        debugPrint('✅ [LoginScreen] Google sign-in successful, navigating to Home');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartupScreen()),
          (route) => false,
        );
      } else {
        debugPrint('❌ [LoginScreen] Backend rejected: ${auth.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.googleSignInFailed(auth.error ?? context.l10n.unknownError)),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stack) {
      debugPrint('❌ [LoginScreen] EXCEPTION during Google sign-in: $e');
      debugPrint('❌ [LoginScreen] Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.googleSignInFailed(e.toString())),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      keepLoggedIn: _keepLoggedIn,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartupScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? context.l10n.loginFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primary, Color.lerp(scheme.primary, Colors.black, 0.55)!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              Expanded(
                child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sheet),
              ),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'D',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        widget.isCustomerMode
                            ? context.l10n.hireADriver
                            : context.l10n.loginTitle(AppConstants.appName),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isCustomerMode
                            ? context.l10n.loginToHire
                            : context.l10n.appTagline,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 28),

                      // Google Sign-In Button
                      OutlinedButton.icon(
                        onPressed: _googleLoading ? null : _googleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                        ),
                        icon: _googleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.g_mobiledata,
                                color: Colors.red, size: 30),
                        label: Text(
                          _googleLoading ? context.l10n.signingIn : context.l10n.continueWithGoogle,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(context.l10n.or,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? context.l10n.pleaseEnterEmail
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: context.l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? context.l10n.pleaseEnterPassword
                            : null,
                      ),
                      const SizedBox(height: 8),

                      // Keep me logged in (applies to all roles)
                      // Wrapped in its own (transparent) Material so the tile
                      // paints its background/ink on a Material surface instead
                      // of the white Container above it - otherwise Flutter
                      // reports "ListTile background color or ink splashes may
                      // be invisible".
                      Material(
                        type: MaterialType.transparency,
                        child: CheckboxListTile(
                          value: _keepLoggedIn,
                          onChanged: (v) =>
                              setState(() => _keepLoggedIn = v ?? true),
                          title: Text(context.l10n.keepMeLoggedIn,
                              style: const TextStyle(fontSize: 14)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Login button
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(context.l10n.login, style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 16),

                      // Sign up link — customers go directly to customer signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.l10n.newHere,
                              style: TextStyle(color: Colors.grey.shade600)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SignupScreen(
                                      initialRole: widget.isCustomerMode ? 'customer' : null,
                                    )),
                              );
                            },
                            child: Text(context.l10n.register,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}