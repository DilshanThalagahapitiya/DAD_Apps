// ============================================================
// Complete User Details Screen (Customer)
// ============================================================
// Shown right after a Google sign-in (or any login) when the user's
// PERSONAL details are still missing - a Google account is created with
// no phone number and no NIC.
//
// This step comes BEFORE the "Add Your Vehicle Details" popup, so the
// customer must fill their own details first.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../providers/auth_provider.dart';

class CompleteUserDetailsScreen extends StatefulWidget {
  const CompleteUserDetailsScreen({super.key});
  @override
  State<CompleteUserDetailsScreen> createState() =>
      _CompleteUserDetailsScreenState();
}

class _CompleteUserDetailsScreenState extends State<CompleteUserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _nic = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _dob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with the details we already have (from Google / server).
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final nameParts = user.fullName.trim().split(' ');
      _firstName.text =
          (user.firstName ?? '').isNotEmpty ? user.firstName! : nameParts.first;
      _lastName.text = (user.lastName ?? '').isNotEmpty
          ? user.lastName!
          : (nameParts.length > 1 ? nameParts.skip(1).join(' ') : '');
      _nic.text = user.nic ?? '';
      _phone.text = user.phone;
      _dob = DateTime.tryParse(user.dob ?? '');
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nic.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    try {
      final body = <String, dynamic>{
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'nic': _nic.text.trim(),
        'phone': _phone.text.trim(),
      };
      if (_dob != null) {
        body['dob'] = _dob!.toIso8601String();
      }

      await ApiClient.instance.patch('/api/auth/me', body);

      // Refresh so userDetailsComplete / profileComplete are up to date.
      await auth.refreshUser();

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.detailsSaved),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.failedToSave(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.completeYourDetails,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_pin_circle,
                      size: 48, color: Colors.indigo),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.completeYourDetailsSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  _infoCard(context.l10n.detailsRequiredInfo),
                  const SizedBox(height: 20),

                  // First name
                  TextFormField(
                    controller: _firstName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.firstName,
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.firstNameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Last name
                  TextFormField(
                    controller: _lastName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.lastName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.required
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Email comes from Google - read only
                  TextFormField(
                    initialValue: user?.email ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: context.l10n.emailFromGoogle,
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // NIC
                  TextFormField(
                    controller: _nic,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: context.l10n.nicNumber,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.nicRequired
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: context.l10n.phoneNumber,
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.phoneRequired
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Date of birth (optional)
                  InkWell(
                    onTap: _saving ? null : _pickDob,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.dateOfBirthOptional,
                        prefixIcon: const Icon(Icons.cake_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(
                        _dob == null ? '' : _formatDate(_dob!),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
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
                      _saving ? context.l10n.saving : context.l10n.saveDetails,
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

  Widget _infoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.indigo, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

