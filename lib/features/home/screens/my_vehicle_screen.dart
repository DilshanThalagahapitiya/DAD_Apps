// ============================================================
// My Vehicle Screen (Customer)
// ============================================================
// Allows customers to add or edit their vehicle details
// at any time. Pre-populates with existing data.
// When `embedded` is true, this screen renders as a tab inside
// CustomerShell (no Scaffold/AppBar of its own). When pushed
// directly (e.g. from Profile), it renders its own app bar with
// a back button.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class MyVehicleScreen extends StatefulWidget {
  final bool embedded;
  const MyVehicleScreen({super.key, this.embedded = false});
  @override
  State<MyVehicleScreen> createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  final _vehicleType = TextEditingController();
  final _vehicleNumber = TextEditingController();
  final _specialNote = TextEditingController();
  String _transmission = 'AUTO';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing customer profile data
    final user = context.read<AuthProvider>().user;
    final cp = user?.customerProfile;
    if (cp != null) {
      _location.text = cp['location'] as String? ?? '';
      _vehicleType.text = cp['vehicleType'] as String? ?? '';
      _vehicleNumber.text = cp['vehicleNumber'] as String? ?? '';
      _transmission = cp['transmission'] as String? ?? 'AUTO';
      _specialNote.text = cp['specialNote'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _location.dispose();
    _vehicleType.dispose();
    _vehicleNumber.dispose();
    _specialNote.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ApiClient.instance.patch('/api/auth/me', {
        'customerLocation': _location.text.trim(),
        'customerVehicleType': _vehicleType.text.trim(),
        'customerTransmission': _transmission,
        'customerVehicleNumber': _vehicleNumber.text.trim(),
        'customerSpecialNote': _specialNote.text.trim().isEmpty
            ? null
            : _specialNote.text.trim(),
      });

      // Refresh user data so the profileComplete flag updates
      final auth = context.read<AuthProvider>();
      await auth.refreshUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.vehicleDetailsSaved),
          backgroundColor: context.statusColors.success,
        ),
      );
      if (!widget.embedded) Navigator.pop(context);
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
    final scheme = Theme.of(context).colorScheme;
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, widget.embedded ? 12 : 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.embedded)
              Text(context.l10n.myVehicle,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            if (widget.embedded) const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: context.statusColors.warningContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.directions_car_rounded, color: context.statusColors.warning, size: 32),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add or edit your vehicle details. You can update these at any time.',
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),

                      _field(_location, context.l10n.locationGoogleMaps, Icons.map_rounded),
                      const SizedBox(height: 12),

                      _field(_vehicleType, context.l10n.vehicleType, Icons.directions_car_rounded),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: _transmission,
                        decoration: InputDecoration(
                          labelText: context.l10n.transmissionType,
                          prefixIcon: const Icon(Icons.settings_rounded),
                        ),
                        items: [
                          DropdownMenuItem(value: 'AUTO', child: Text(context.l10n.auto)),
                          DropdownMenuItem(value: 'MANUAL', child: Text(context.l10n.manual)),
                        ],
                        onChanged: (v) => setState(() => _transmission = v!),
                      ),
                      const SizedBox(height: 12),

                      _field(_vehicleNumber, context.l10n.vehicleNumber, Icons.confirmation_number_rounded),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _specialNote,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: context.l10n.specialNoteOptional,
                          prefixIcon: const Icon(Icons.notes_rounded),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 22),

                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_saving ? context.l10n.saving : context.l10n.saveVehicleDetails),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myVehicle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: body,
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (v) => (v == null || v.isEmpty) ? context.l10n.required : null,
    );
  }
}
