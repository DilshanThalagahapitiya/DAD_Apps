// ============================================================
// Rider Signup Form
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../legal/providers/terms_provider.dart';
import '../../legal/widgets/terms_acceptance_field.dart';
import '../providers/auth_provider.dart';
import '../../../main.dart';

class RiderSignupForm extends StatefulWidget {
  /// Mirrors the Terms & Conditions tick up to the signup screen so
  /// Google sign-in can require it as well.
  final ValueChanged<bool>? onTermsChanged;

  const RiderSignupForm({super.key, this.onTermsChanged});
  @override
  State<RiderSignupForm> createState() => _RiderSignupFormState();
}

class _RiderSignupFormState extends State<RiderSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _fName = TextEditingController();
  final _lName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _nic = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _licenseNo = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _password = TextEditingController();

  // Terms & Conditions consent (required before the account can be created)
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  /// Blocks the signup until the Terms & Conditions have been accepted.
  bool _termsAccepted() {
    if (_agreedToTerms) return true;
    setState(() => _showTermsError = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.termsRequiredError),
        backgroundColor: context.statusColors.danger,
      ),
    );
    return false;
  }

  @override
  void dispose() {
    _fName.dispose(); _lName.dispose(); _email.dispose(); _phone.dispose();
    _nic.dispose(); _city.dispose(); _address.dispose(); _licenseNo.dispose();
    _emergencyName.dispose(); _emergencyPhone.dispose(); _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted()) return;
    final auth = context.read<AuthProvider>();
    final data = {
      'role': 'RIDER',
      'email': _email.text.trim(),
      'password': _password.text,
      'firstName': _fName.text.trim(),
      'lastName': _lName.text.trim(),
      'phone': _phone.text.trim(),
      'nic': _nic.text.trim(),
      'city': _city.text.trim(),
      'address': _address.text.trim(),
      'riderLicenseNumber': _licenseNo.text.trim(),
      'emergencyContactName': _emergencyName.text.trim(),
      'emergencyContactPhone': _emergencyPhone.text.trim(),
      // Consent recorded server-side against the version shown to the user
      'termsVersion': context.read<TermsProvider>().version,
      // Language the terms were actually read in (the viewer's pick, else
      // the app language)
      'termsLanguage':
          context.read<TermsProvider>().languageFor(Localizations.localeOf(context)),
    };
    final success = await auth.signup(data);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration submitted! Wait for admin approval.')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartupScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed')),
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
          _section(context.l10n.personalDetails, [
            _field(_fName, context.l10n.firstName, Icons.person_rounded),
            _field(_lName, context.l10n.lastName, Icons.person_outline),
            _field(_email, context.l10n.emailAddress, Icons.email, email: true),
            _field(_phone, context.l10n.phoneNumber, Icons.phone_rounded, number: true),
            _field(_nic, context.l10n.nic, Icons.badge_outlined),
            _field(_address, context.l10n.homeAddress, Icons.home_rounded),
            _field(_city, context.l10n.city, Icons.location_city),
            _field(_licenseNo, context.l10n.licenseNumber, Icons.card_membership),
          ]),
          _section(context.l10n.emergencyContact, [
            _field(_emergencyName, context.l10n.emergencyContactName, Icons.contact_emergency),
            _field(_emergencyPhone, context.l10n.emergencyContactPhone, Icons.phone_in_talk, number: true),
          ]),
          _section(context.l10n.loginDetails, [
            _field(_password, context.l10n.passwordStar, Icons.lock_rounded, obscure: true),
          ]),
          const SizedBox(height: 8),

          // ---- Terms & Conditions (must be accepted to register) ----
          TermsAcceptanceField(
            onChanged: (agreed) {
              setState(() {
                _agreedToTerms = agreed;
                if (agreed) _showTermsError = false;
              });
              // Mirror the tick up to the signup screen (used by Google sign-in)
              widget.onTermsChanged?.call(agreed);
            },
            showError: _showTermsError,
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _submit,
            child: Text(context.l10n.registerAsRider),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> fields) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          ...fields,
        ],
      );

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false, bool email = false, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
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
        validator: (v) => v == null || v.isEmpty ? context.l10n.required : null,
      ),
    );
  }
}