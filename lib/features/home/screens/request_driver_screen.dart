// ============================================================
// Request Driver Screen (Customer)
// ============================================================
// Customer requests a driver: enters pickup/drop/time.
// Customer details auto-filled from their profile.
// Request appears in admin portal as PENDING_REQUEST.
// ============================================================

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';

class RequestDriverScreen extends StatefulWidget {
  const RequestDriverScreen({super.key});
  @override
  State<RequestDriverScreen> createState() => _RequestDriverScreenState();
}

class _RequestDriverScreenState extends State<RequestDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selectedTime = DateTime.now().add(const Duration(hours: 1));
  bool _submitting = false;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final api = ApiClient.instance;
      final response = await api.post('/api/rides/request', {
        'pickupLocation': _pickupCtrl.text.trim(),
        'dropLocation': _dropCtrl.text.trim(),
        'startTime': _selectedTime.toIso8601String(),
        'specialNote': _noteCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Request submitted! Admin will assign a driver soon.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failed(e.toString())), backgroundColor: Colors.red),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.indigo, title: Text(context.l10n.requestDriver)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer info card (auto-filled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.yourDetailsAutoFilled,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(context.l10n.nameLabel(user?.fullName ?? '-'),
                        style: const TextStyle(fontSize: 13)),
                    Text(context.l10n.phoneLabel(user?.phone ?? '-'),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _pickupCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.pickupLocation,
                  hintText: context.l10n.enterCurrentLocation,
                  prefixIcon: const Icon(Icons.trip_origin),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? context.l10n.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dropCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.dropLocation,
                  hintText: context.l10n.whereToGo,
                  prefixIcon: const Icon(Icons.flag),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? context.l10n.required : null,
              ),
              const SizedBox(height: 12),

              // Pickup time picker
              InkWell(
                onTap: () async {
                  final time = await showDatePicker(
                    context: context,
                    initialDate: _selectedTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (time != null) {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedTime),
                    );
                    if (t != null) {
                      setState(() {
                        _selectedTime = DateTime(
                          time.year, time.month, time.day, t.hour, t.minute);
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.l10n.pickupTime,
                    prefixIcon: const Icon(Icons.schedule),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedTime.toLocal().toString().replaceRange(16, 19, ''),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.l10n.specialNote,
                  hintText: context.l10n.anyInstructions,
                  prefixIcon: const Icon(Icons.notes),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(context.l10n.requestDriver, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}