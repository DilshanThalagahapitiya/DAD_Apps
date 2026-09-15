// ============================================================
// Driver Signup Form
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../providers/auth_provider.dart';
import '../../../features/home/screens/home_screen.dart';

class DriverSignupForm extends StatefulWidget {
  const DriverSignupForm({super.key});
  @override
  State<DriverSignupForm> createState() => _DriverSignupFormState();
}

class _DriverSignupFormState extends State<DriverSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _fName = TextEditingController();
  final _lName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _nic = TextEditingController();
  final _city = TextEditingController();
  final _licenseNo = TextEditingController();
  final _password = TextEditingController();
  String _licenseCategory = 'LIGHT_WEIGHT';
  String _vehicleType = 'CAR';
  String _transmission = 'AUTO';

  @override
  void dispose() {
    _fName.dispose(); _lName.dispose(); _email.dispose(); _phone.dispose();
    _nic.dispose(); _city.dispose(); _licenseNo.dispose(); _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final data = {
      'role': 'DRIVER',
      'email': _email.text.trim(),
      'password': _password.text,
      'firstName': _fName.text.trim(),
      'lastName': _lName.text.trim(),
      'phone': _phone.text.trim(),
      'nic': _nic.text.trim(),
      'city': _city.text.trim(),
      'licenseNumber': _licenseNo.text.trim(),
      'licenseCategory': _licenseCategory,
      'licenseLightExpiryDate': '2030-12-31',
      'licenseFrontImage': '/uploads/front.jpg',
      'licenseBackImage': '/uploads/back.jpg',
      'vehicleType': _vehicleType,
      'preferredGear': _transmission,
      'address': _city.text.trim(),
    };
    final success = await auth.signup(data);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration submitted! Wait for admin approval.')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
          _sectionTitle(context.l10n.personalDetails),
          _field(_fName, context.l10n.firstName, Icons.person),
          _field(_lName, context.l10n.lastName, Icons.person_outline),
          _field(_email, context.l10n.emailAddress, Icons.email, email: true),
          _field(_phone, context.l10n.phoneNumber, Icons.phone, number: true),
          _field(_nic, context.l10n.nic, Icons.badge_outlined),
          _field(_city, context.l10n.city, Icons.location_city),
          const SizedBox(height: 12),
          _sectionTitle(context.l10n.licenseDetails),
          _field(_licenseNo, context.l10n.licenseNumber, Icons.card_membership),
          DropdownButtonFormField<String>(
            value: _licenseCategory,
            decoration: InputDecoration(
              labelText: context.l10n.licenseCategory,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'LIGHT_WEIGHT', child: Text(context.l10n.lightWeight)),
              DropdownMenuItem(value: 'HEAVY', child: Text(context.l10n.heavy)),
              DropdownMenuItem(value: 'BOTH', child: Text(context.l10n.both)),
            ],
            onChanged: (v) => setState(() => _licenseCategory = v!),
          ),
          const SizedBox(height: 12),
          _sectionTitle(context.l10n.vehiclePreferences),
          DropdownButtonFormField<String>(
            value: _vehicleType,
            decoration: InputDecoration(
              labelText: context.l10n.preferredVehicle,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'CAR', child: Text(context.l10n.car)),
              DropdownMenuItem(value: 'VAN', child: Text(context.l10n.van)),
              DropdownMenuItem(value: 'LORRY', child: Text(context.l10n.lorry)),
              DropdownMenuItem(value: 'BUS', child: Text(context.l10n.bus)),
              DropdownMenuItem(value: 'BIKE', child: Text(context.l10n.motorBike)),
              DropdownMenuItem(value: 'TUKTUK', child: Text(context.l10n.threeWheeler)),
              DropdownMenuItem(value: 'SUV', child: Text(context.l10n.suv)),
            ],
            onChanged: (v) => setState(() => _vehicleType = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _transmission,
            decoration: InputDecoration(
              labelText: context.l10n.transmission,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'AUTO', child: Text(context.l10n.auto)),
              DropdownMenuItem(value: 'MANUAL', child: Text(context.l10n.manual)),
              DropdownMenuItem(value: 'BOTH', child: Text(context.l10n.both)),
            ],
            onChanged: (v) => setState(() => _transmission = v!),
          ),
          const SizedBox(height: 12),
          _field(_password, context.l10n.passwordStar, Icons.lock, obscure: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.indigo,
            ),
            child: Text(context.l10n.registerAsDriver),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? context.l10n.required : null,
      ),
    );
  }
}