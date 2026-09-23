// ============================================================
// Signup Screen - Role Selection + Role-Based Registration Forms
// ============================================================
// Allows users to select their account type and fill the appropriate
// registration form. Supported roles: Driver, Rider, Customer, Hotel, Admin.
// Also supports Google Sign-In, but an account type must be selected
// BEFORE Google sign-in is allowed to start.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/auth/google_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

// Import role-specific form widgets
import '../widgets/driver_signup_form.dart';
import '../widgets/rider_signup_form.dart';
import '../widgets/customer_signup_form.dart';
import '../widgets/admin_signup_form.dart';

enum _RoleOption { driver, rider, customer, hotel, admin }

class SignupScreen extends StatefulWidget {
  final String? initialRole; // e.g. "customer" to pre-select customer signup
  const SignupScreen({super.key, this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  _RoleOption? _selectedRole;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select role if initialRole is provided (e.g. from customer login)
    if (widget.initialRole == 'customer') {
      _selectedRole = _RoleOption.customer;
    }
  }

  Future<void> _googleSignIn() async {
    // Account type / user role must be selected before Google sign-in.
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseSelectAccountType),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    // Admin accounts are created through the email/password form only.
    if (_selectedRole == _RoleOption.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminMustUseEmail),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    setState(() => _googleLoading = true);
    try {
      // Role was validated above - map the selection to the API role string.
      String role = 'CUSTOMER';
      if (_selectedRole == _RoleOption.driver) {
        role = 'DRIVER';
      } else if (_selectedRole == _RoleOption.rider) {
        role = 'RIDER';
      } else if (_selectedRole == _RoleOption.hotel) {
        role = 'HOTEL';
      }

      final account = await GoogleAuthService.instance.signIn();
      if (account == null) {
        // User cancelled Google sign-in
        return;
      }
      final idToken = await GoogleAuthService.instance.getIdToken();
      if (idToken == null) {
        throw Exception('Could not obtain Google ID token');
      }

      final success = await auth.googleSignIn(idToken, role: role);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.googleSignInSuccessful),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartupScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? context.l10n.googleSignInFailed(''))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.googleSignInFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(children: [
      AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelector(foregroundColor: Colors.white),
          ),
        ],
      ),
      Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  context.l10n.createAccount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.selectAccountType,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Role Selection Cards (account type must be chosen before Google)
                _RoleCard(
                  icon: Icons.directions_car_rounded,
                  title: context.l10n.driver,
                  subtitle: context.l10n.iWantToDrive,
                  selected: _selectedRole == _RoleOption.driver,
                  onTap: () => setState(() => _selectedRole = _RoleOption.driver),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.person_pin_rounded,
                  title: context.l10n.rider,
                  subtitle: context.l10n.iNeedARideHome,
                  selected: _selectedRole == _RoleOption.rider,
                  onTap: () => setState(() => _selectedRole = _RoleOption.rider),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.local_taxi_rounded,
                  title: context.l10n.customer,
                  subtitle: context.l10n.iOwnAVehicle,
                  selected: _selectedRole == _RoleOption.customer,
                  onTap: () => setState(() => _selectedRole = _RoleOption.customer),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.hotel_rounded,
                  title: context.l10n.hotel,
                  subtitle: context.l10n.iAmAHotelPartner,
                  selected: _selectedRole == _RoleOption.hotel,
                  onTap: () => setState(() => _selectedRole = _RoleOption.hotel),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.admin_panel_settings_rounded,
                  title: context.l10n.admin,
                  subtitle: context.l10n.iManageTheSystem,
                  selected: _selectedRole == _RoleOption.admin,
                  onTap: () => setState(() => _selectedRole = _RoleOption.admin),
                ),
                const SizedBox(height: 24),

                // Google Sign-In Button — requires an account type to be selected first
                OutlinedButton.icon(
                  onPressed: (_googleLoading || _selectedRole == null)
                      ? null
                      : _googleSignIn,
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
                if (_selectedRole == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.selectAccountTypeForGoogle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

                // Dynamic Role Form — email & password registration for the selected role
                if (_selectedRole != null) ...[
                  _buildRoleForm(),
                ],

                const SizedBox(height: 16),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.l10n.alreadyHaveAccount,
                        style: TextStyle(color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(context.l10n.login,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      )),
          ]),
        ),
      ),
    );
  }

  Widget _buildRoleForm() {
    switch (_selectedRole) {
      case _RoleOption.driver:
        return const DriverSignupForm();
      case _RoleOption.rider:
        return const RiderSignupForm();
      case _RoleOption.customer:
        return const CustomerSignupForm();
      case _RoleOption.hotel:
        return const HotelSignupForm();
      case _RoleOption.admin:
        return const AdminSignupForm();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ============================================================
// Hotel Signup Form
// ============================================================
class HotelSignupForm extends StatefulWidget {
  const HotelSignupForm({super.key});
  @override
  State<HotelSignupForm> createState() => _HotelSignupFormState();
}

class _HotelSignupFormState extends State<HotelSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _hotelName = TextEditingController();
  final _license = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _hotelName.dispose();
    _license.dispose();
    _address.dispose();
    _city.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signup({
      'role': 'HOTEL',
      'hotelName': _hotelName.text.trim(),
      'hotelLicenseNumber': _license.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
      'contactPhone': _phone.text.trim(),
      'contactEmail': _email.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'phone': _phone.text.trim(),
    });
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.registrationSubmitted)),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartupScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? context.l10n.registrationFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_hotelName, context.l10n.hotelName, Icons.hotel),
          const SizedBox(height: 12),
          _field(_license, context.l10n.hotelLicenseNumber, Icons.badge_outlined),
          const SizedBox(height: 12),
          _field(_address, context.l10n.address, Icons.location_on_outlined),
          const SizedBox(height: 12),
          _field(_city, context.l10n.city, Icons.location_city),
          const SizedBox(height: 12),
          _field(_phone, context.l10n.contactPhone, Icons.phone, number: true),
          const SizedBox(height: 12),
          _field(_email, context.l10n.contactEmail, Icons.email, email: true),
          const SizedBox(height: 12),
          _field(_password, context.l10n.passwordStar, Icons.lock, obscure: true),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: Text(context.l10n.registerAsHotel),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false, bool email = false, bool number = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: email
          ? TextInputType.emailAddress
          : number
              ? TextInputType.phone
              : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (v) => (v == null || v.isEmpty) ? context.l10n.required : null,
    );
  }
}

// ============================================================
// Role Selection Card
// ============================================================
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card - 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.grey.shade50,
          border: Border.all(
            color: selected ? scheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.card - 4),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? scheme.primary : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? scheme.primary : Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}