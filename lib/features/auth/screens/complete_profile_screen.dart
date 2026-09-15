// ============================================================
// Complete Profile Screen (Customer)
// ============================================================
// Shown to customers who registered with only first name, NIC,
// and phone. Lets them complete their full profile:
//   - Last name
//   - Email
//   - Location (Google Maps)
//   - Vehicle type
//   - Transmission
//   - Vehicle number
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _location = TextEditingController();
  final _vehicleType = TextEditingController();
  final _vehicleNumber = TextEditingController();
  String _transmission = 'AUTO';
  bool _saving = false;

  @override
  void dispose() {
    _lastName.dispose();
    _email.dispose();
    _location.dispose();
    _vehicleType.dispose();
    _vehicleNumber.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ApiClient.instance.patch('/api/auth/me', {
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'customerLocation': _location.text.trim(),
        'customerVehicleType': _vehicleType.text.trim(),
        'customerTransmission': _transmission,
        'customerVehicleNumber': _vehicleNumber.text.trim(),
      });

      // Update the locally cached user via the auth provider
      final auth = context.read<AuthProvider>();
      await auth.refreshUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile completed! You can now hire drivers.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failedToSave(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.completeProfile,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fact_check_outlined,
                      color: Colors.indigo, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.completeYourProfile,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.completeProfileHelpText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Last name
                  _field(_lastName, context.l10n.lastName, Icons.person_outline),
                  const SizedBox(height: 12),

                  // Email
                  _field(_email, context.l10n.emailAddress, Icons.email,
                      email: true),
                  const SizedBox(height: 12),

                  // Location
                  _field(_location, context.l10n.locationGoogleMaps, Icons.map),
                  const SizedBox(height: 12),

                  // Vehicle type
                  _field(_vehicleType, context.l10n.vehicleType, Icons.directions_car),
                  const SizedBox(height: 12),

                  // Transmission
                  DropdownButtonFormField<String>(
                    initialValue: _transmission,
                    decoration: InputDecoration(
                      labelText: context.l10n.transmissionType,
                      prefixIcon: const Icon(Icons.settings),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'AUTO', child: Text(context.l10n.auto)),
                      DropdownMenuItem(value: 'MANUAL', child: Text(context.l10n.manual)),
                    ],
                    onChanged: (v) => setState(() => _transmission = v!),
                  ),
                  const SizedBox(height: 12),

                  // Vehicle number
                  _field(_vehicleNumber, context.l10n.vehicleNumber, Icons.confirmation_number),
                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      _saving ? context.l10n.saving : context.l10n.saveProfile,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool email = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.isEmpty) ? context.l10n.required : null,
    );
  }
}