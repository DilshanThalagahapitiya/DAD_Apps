// ============================================================
// Complete User Details Screen
// ============================================================
// Shown right after a Google sign-in (or any login) when the user's
// PERSONAL details are still missing - a Google account is created with
// no phone number and no NIC. Used by Customer, Driver and Rider.
//
// For Customer it's pushed as a dismissible step before the "Add Your
// Vehicle Details" popup. For Driver/Rider it's rendered directly in
// place of DriverRiderShell (showBackButton: false) as a hard block —
// there is nothing to go back to, and the account can't be used until
// these details are saved.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class CompleteUserDetailsScreen extends StatefulWidget {
  /// False when this screen is a hard block (Driver/Rider) with nothing to
  /// return to — hides the back button and disables the system back gesture.
  final bool showBackButton;
  const CompleteUserDetailsScreen({super.key, this.showBackButton = true});
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
    final successColor = context.statusColors.success;
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

      final res = await ApiClient.instance.patch('/api/auth/me', body);

      // Publish the updated user straight from the save response so the caller
      // (DriverRiderShell / CustomerShell) can move on to the dashboard.
      final applied = await auth.applyUser(res['data']?['user'] as Map<String, dynamic>?);
      if (!applied) await auth.refreshUser(); // fall back to a full refresh

      if (!mounted) return;
      final complete = auth.user?.userDetailsComplete ?? false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(complete ? l10n.detailsSaved : l10n.pleaseCompleteProfile),
          backgroundColor: complete ? successColor : context.statusColors.warning,
        ),
      );

      // Only pop when this screen owns the current route (pushed from the
      // customer dashboard). As the driver/rider gate it lives *inside* the
      // shell's route, where popping would drop the user back to the
      // landing/login screen instead of the dashboard — that one rebuilds by
      // itself from the AuthProvider state applied above.
      final route = ModalRoute.of(context);
      if (route != null && !route.isFirst && navigator.canPop()) {
        navigator.pop(true);
      }
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
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: widget.showBackButton,
      child: Scaffold(
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
        automaticallyImplyLeading: false,
        title: Text(context.l10n.completeYourDetails,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context, false),
              )
            : null,
      ),
      Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.person_pin_circle_rounded,
                      size: 48, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.completeYourDetailsSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    context,
                    user?.role == 'CUSTOMER'
                        ? context.l10n.detailsRequiredInfo
                        : context.l10n.detailsRequiredInfoStaff,
                  ),
                  const SizedBox(height: 20),

                  // First name
                  TextFormField(
                    controller: _firstName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.firstName,
                      prefixIcon: const Icon(Icons.person_rounded),
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
                      prefixIcon: const Icon(Icons.person_outline_rounded),
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
                      prefixIcon: const Icon(Icons.email_rounded),
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
                      prefixIcon: const Icon(Icons.phone_rounded),
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
                        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
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
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_saving ? context.l10n.saving : context.l10n.saveDetails),
                  ),
                ],
              ),
            ),
          ),
      )),
          ]),
        ),
      ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: scheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

