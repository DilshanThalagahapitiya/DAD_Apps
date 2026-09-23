// ============================================================
// MapLocationPicker — Location entry (no Google Maps dependency)
// - Driver can TYPE the pickup/drop location
// - "Use Current Location" button fills coords via geolocator
// - On "Use This": always returns the typed address
// - If a location is set, also returns coords for routing
// ============================================================

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';

class MapLocationPicker extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<({double lat, double lng})>? onCoordsChanged;
  final bool enabled;
  const MapLocationPicker({
    super.key,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
    required this.onAddressChanged,
    this.onCoordsChanged,
    this.enabled = true,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  ({double lat, double lng})? _selected;
  ({double lat, double lng})? _currentLocation;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialAddress ?? '';
    final lat = widget.initialLat;
    final lng = widget.initialLng;
    if (lat != null && lng != null) _selected = (lat: lat, lng: lng);
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Try to auto-get current location (works if permission granted)
  Future<void> _fetchCurrentLocation() async {
    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      if (mounted) {
        setState(() {
          _currentLocation = (lat: position.latitude, lng: position.longitude);
        });
      }
    } catch (_) {}
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) {
      await _fetchCurrentLocation();
      if (_currentLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotFetchLocation)),
        );
        return;
      }
    }
    setState(() {
      _selected = _currentLocation;
      _searchCtrl.text =
          '${_currentLocation!.lat.toStringAsFixed(6)}, ${_currentLocation!.lng.toStringAsFixed(6)}';
    });
  }

  // Returns the typed address (coords only if current location was used)
  void _confirm() {
    final text = _searchCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseTypeLocation)),
      );
      return;
    }
    widget.onAddressChanged(text);

    if (_selected != null && widget.onCoordsChanged != null) {
      widget.onCoordsChanged!((lat: _selected!.lat, lng: _selected!.lng));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: context.l10n.typeLocationHint,
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: widget.enabled ? _confirm : null,
            child: Text(context.l10n.useThis, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Use current location (geolocator, no Google Maps)
            OutlinedButton.icon(
              onPressed: widget.enabled ? _goToCurrentLocation : null,
              icon: Icon(Icons.my_location_rounded, color: scheme.primary),
              label: Text(context.l10n.useMyCurrentLocation),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            // Hint card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Text(
                context.l10n.mapHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}