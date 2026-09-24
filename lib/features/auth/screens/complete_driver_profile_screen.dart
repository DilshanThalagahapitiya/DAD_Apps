// ============================================================
// Complete Driver Profile Screen (Authorization + Vehicle Prep)
// ============================================================
// Shown to a driver whose license/authorization details are still
// missing — a Google sign-up driver has a DriverProfile row with
// empty placeholder license fields. Collects:
//   - License number, category, front/back photos, expiry date(s)
//   - Preferred vehicle type, transmission, special note
//
// When `showBackButton` is false, this is a hard block (rendered by
// DriverRiderShell in place of the tabs) — there is nothing to go
// back to, and the driver can't use the app until this is saved.
// ============================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_upload.dart';
import '../providers/auth_provider.dart';

class CompleteDriverProfileScreen extends StatefulWidget {
  /// False when this screen is a hard block (nothing to return to).
  final bool showBackButton;
  const CompleteDriverProfileScreen({super.key, this.showBackButton = true});

  @override
  State<CompleteDriverProfileScreen> createState() => _CompleteDriverProfileScreenState();
}

class _CompleteDriverProfileScreenState extends State<CompleteDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNo = TextEditingController();
  final _specialNote = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _licenseCategory = 'LIGHT_WEIGHT';
  String _vehicleType = 'CAR';
  String _transmission = 'AUTO';
  DateTime? _lightExpiry;
  DateTime? _heavyExpiry;

  // Uploaded photo URLs (already on the server) vs. a freshly-picked local
  // file still being uploaded.
  String? _frontImageUrl;
  String? _backImageUrl;
  bool _uploadingFront = false;
  bool _uploadingBack = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final dp = context.read<AuthProvider>().user?.driverProfile;
    if (dp != null) {
      _licenseNo.text = (dp['licenseNumber'] as String?) ?? '';
      _specialNote.text = (dp['specialNote'] as String?) ?? '';
      _licenseCategory = (dp['licenseCategory'] as String?)?.isNotEmpty == true
          ? dp['licenseCategory'] as String
          : 'LIGHT_WEIGHT';
      _vehicleType = (dp['vehicleType'] as String?)?.isNotEmpty == true ? dp['vehicleType'] as String : 'CAR';
      _transmission = (dp['preferredGear'] as String?)?.isNotEmpty == true ? dp['preferredGear'] as String : 'AUTO';
      _lightExpiry = DateTime.tryParse((dp['licenseLightExpiryDate'] as String?) ?? '');
      _heavyExpiry = DateTime.tryParse((dp['licenseHeavyExpiryDate'] as String?) ?? '');
      final front = dp['licenseFrontImage'] as String?;
      final back = dp['licenseBackImage'] as String?;
      _frontImageUrl = (front != null && front.isNotEmpty) ? front : null;
      _backImageUrl = (back != null && back.isNotEmpty) ? back : null;
    }
  }

  @override
  void dispose() {
    _licenseNo.dispose();
    _specialNote.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload({required bool isFront}) async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo == null) return;
      setState(() {
        if (isFront) {
          _uploadingFront = true;
        } else {
          _uploadingBack = true;
        }
      });
      // iPhones capture in HEIC by default, so the photo is re-encoded to a
      // small JPEG and uploaded; we store the returned "/uploads/..." URL.
      final url = await uploadCapturedImage(photo.path);
      if (!mounted) return;
      setState(() {
        if (isFront) {
          _frontImageUrl = url;
        } else {
          _backImageUrl = url;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cameraError(e.toString())), backgroundColor: context.statusColors.danger),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingFront = false;
          _uploadingBack = false;
        });
      }
    }
  }

  Future<void> _pickExpiry({required bool isLight}) async {
    final initial = (isLight ? _lightExpiry : _heavyExpiry) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isLight) {
          _lightExpiry = picked;
        } else {
          _heavyExpiry = picked;
        }
      });
    }
  }

  bool get _needsLightExpiry => _licenseCategory == 'LIGHT_WEIGHT' || _licenseCategory == 'BOTH';
  bool get _needsHeavyExpiry => _licenseCategory == 'HEAVY' || _licenseCategory == 'BOTH';

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    final photosOk = _frontImageUrl != null && _backImageUrl != null;
    final expiryOk = (!_needsLightExpiry || _lightExpiry != null) && (!_needsHeavyExpiry || _heavyExpiry != null);
    if (!formOk || !photosOk || !expiryOk) {
      setState(() {}); // trigger rebuild so the photo/date "required" hints show
      return;
    }

    final auth = context.read<AuthProvider>();
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final successColor = context.statusColors.success;
    setState(() => _saving = true);

    try {
      final res = await ApiClient.instance.patch('/api/auth/me', {
        'driverLicenseNumber': _licenseNo.text.trim(),
        'driverLicenseCategory': _licenseCategory,
        'driverLicenseLightExpiryDate': _needsLightExpiry ? _lightExpiry!.toIso8601String() : null,
        'driverLicenseHeavyExpiryDate': _needsHeavyExpiry ? _heavyExpiry!.toIso8601String() : null,
        'driverLicenseFrontImage': _frontImageUrl,
        'driverLicenseBackImage': _backImageUrl,
        'driverVehicleType': _vehicleType,
        'driverPreferredGear': _transmission,
        'driverSpecialNote': _specialNote.text.trim().isEmpty ? null : _specialNote.text.trim(),
      });

      // Publish the updated user straight from the save response so the shell
      // can move on to the dashboard. (A separate /me request could fail
      // silently and leave this gate on screen.)
      final applied = await auth.applyUser(res['data']?['user'] as Map<String, dynamic>?);
      if (!applied) await auth.refreshUser();
      if (!mounted) return;

      final complete = auth.user?.driverProfileComplete ?? false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(complete ? l10n.driverProfileSaved : l10n.pleaseCompleteProfile),
          backgroundColor: complete ? successColor : context.statusColors.warning,
        ),
      );

      // Leave this screen only when it owns the current route (e.g. opened from
      // another screen). As the driver/rider gate it lives *inside* the shell's
      // route, where popping would throw the user back to the landing/login
      // screen instead of the dashboard — that one rebuilds by itself from the
      // AuthProvider state applied above.
      final route = ModalRoute.of(context);
      if (route != null && !route.isFirst && navigator.canPop()) {
        navigator.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.failedToSave(e.toString()))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.badge_rounded, color: scheme.primary, size: 32),
                      ),
                      const SizedBox(height: 14),
                      Text(context.l10n.completeDriverProfile,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.completeDriverProfileSubtitle,
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),

                      Text(context.l10n.licenseDetails,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _licenseNo,
                        decoration: InputDecoration(
                          labelText: context.l10n.licenseNumber,
                          prefixIcon: const Icon(Icons.card_membership_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.required : null,
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: _licenseCategory,
                        decoration: InputDecoration(
                          labelText: context.l10n.licenseCategory,
                          prefixIcon: const Icon(Icons.category_rounded),
                        ),
                        items: [
                          DropdownMenuItem(value: 'LIGHT_WEIGHT', child: Text(context.l10n.lightWeight)),
                          DropdownMenuItem(value: 'HEAVY', child: Text(context.l10n.heavy)),
                          DropdownMenuItem(value: 'BOTH', child: Text(context.l10n.both)),
                        ],
                        onChanged: (v) => setState(() => _licenseCategory = v!),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _PhotoPicker(
                              label: context.l10n.licenseFrontPhoto,
                              imageUrl: _frontImageUrl,
                              uploading: _uploadingFront,
                              showError: _frontImageUrl == null,
                              errorText: context.l10n.photoRequired,
                              onTap: _uploadingFront ? null : () => _pickAndUpload(isFront: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PhotoPicker(
                              label: context.l10n.licenseBackPhoto,
                              imageUrl: _backImageUrl,
                              uploading: _uploadingBack,
                              showError: _backImageUrl == null,
                              errorText: context.l10n.photoRequired,
                              onTap: _uploadingBack ? null : () => _pickAndUpload(isFront: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_needsLightExpiry)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DatePickerField(
                            label: context.l10n.licenseExpiryLight,
                            date: _lightExpiry,
                            errorText: _lightExpiry == null ? context.l10n.dateRequired : null,
                            onTap: () => _pickExpiry(isLight: true),
                          ),
                        ),
                      if (_needsHeavyExpiry)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DatePickerField(
                            label: context.l10n.licenseExpiryHeavy,
                            date: _heavyExpiry,
                            errorText: _heavyExpiry == null ? context.l10n.dateRequired : null,
                            onTap: () => _pickExpiry(isLight: false),
                          ),
                        ),

                      const SizedBox(height: 8),
                      Text(context.l10n.vehiclePreferences,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: _vehicleType,
                        decoration: InputDecoration(
                          labelText: context.l10n.preferredVehicle,
                          prefixIcon: const Icon(Icons.directions_car_rounded),
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
                        initialValue: _transmission,
                        decoration: InputDecoration(
                          labelText: context.l10n.transmission,
                          prefixIcon: const Icon(Icons.settings_rounded),
                        ),
                        items: [
                          DropdownMenuItem(value: 'AUTO', child: Text(context.l10n.auto)),
                          DropdownMenuItem(value: 'MANUAL', child: Text(context.l10n.manual)),
                          DropdownMenuItem(value: 'BOTH', child: Text(context.l10n.both)),
                        ],
                        onChanged: (v) => setState(() => _transmission = v!),
                      ),
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
                        label: Text(_saving ? context.l10n.saving : context.l10n.saveDriverProfile),
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

    return PopScope(
      canPop: widget.showBackButton,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.completeDriverProfile),
          automaticallyImplyLeading: false,
          leading: widget.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context, false),
                )
              : null,
        ),
        body: body,
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final bool uploading;
  final bool showError;
  final String errorText;
  final VoidCallback? onTap;

  const _PhotoPicker({
    required this.label,
    required this.imageUrl,
    required this.uploading,
    required this.showError,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(
            color: showError && !hasImage ? context.statusColors.danger : scheme.outlineVariant,
          ),
          image: (hasImage && !uploading)
              ? DecorationImage(image: _licenseImageProvider(imageUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: uploading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : hasImage
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black54,
                      child: Text(
                        context.l10n.changePhoto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_rounded, color: scheme.onSurfaceVariant, size: 26),
                      const SizedBox(height: 6),
                      Text(label,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    ],
                  ),
      ),
    );
  }
}

/// The uploaded photo is a server path like "/uploads/x.jpg" once uploaded
/// (render as NetworkImage against the API base URL); before upload
/// completes there's no local-file preview state to render, so this is
/// only ever called with an already-uploaded URL.
ImageProvider _licenseImageProvider(String url) {
  if (url.startsWith('http')) return NetworkImage(url);
  return NetworkImage('${AppConstants.baseUrl}$url');
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? errorText;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.date, required this.errorText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_rounded),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
          errorText: errorText,
        ),
        child: Text(
          date == null
              ? ''
              : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
