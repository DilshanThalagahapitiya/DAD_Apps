// ============================================================
// Ride Edit/View Screen (Driver & Rider)
// ============================================================
// DRIVER: editable pickup/drop (search on Google map), workflow
//         buttons (Waiting/Start/Continue/Complete), waiting
//         timer + saved intervals.
// RIDER:  read-only view — no editing, no buttons. Only sees
//         details + waiting intervals + total waiting.
// ============================================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_upload.dart';
import '../../../core/widgets/fare_breakdown_card.dart';
import '../widgets/map_location_picker.dart';

class RideEditScreen extends StatefulWidget {
  final dynamic ride;
  final String role;
  const RideEditScreen({super.key, required this.ride, this.role = 'driver'});
  @override
  State<RideEditScreen> createState() => _RideEditScreenState();
}

class _RideEditScreenState extends State<RideEditScreen> {
  late TextEditingController _pickupCtrl;
  late TextEditingController _dropCtrl;
  late String _status;
  bool _waiting = false;
  int _waitingSeconds = 0;
  Timer? _timer;
  bool _saving = false;
  List<Map<String, dynamic>> _intervals = [];

  // Coordinates, captured via Google Map picker
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;

  // Odometer readings + proof images
  final TextEditingController _odoStartCtrl = TextEditingController();
  final TextEditingController _odoEndCtrl = TextEditingController();
  String? _odoStartImage;
  String? _odoEndImage;
  bool _uploadingStartOdo = false;
  bool _uploadingEndOdo = false;
  final ImagePicker _picker = ImagePicker();

  String get _endpoint =>
      widget.role == 'rider' ? '/api/rider/rides' : '/api/driver/rides';

  @override
  void initState() {
    super.initState();
    _pickupCtrl = TextEditingController(text: widget.ride['pickupLocation'] ?? '');
    _dropCtrl = TextEditingController(text: widget.ride['dropLocation'] ?? '');
    _pickupLat = widget.ride['pickupLatitude'] != null ? (widget.ride['pickupLatitude'] as num).toDouble() : null;
    _pickupLng = widget.ride['pickupLongitude'] != null ? (widget.ride['pickupLongitude'] as num).toDouble() : null;
    _dropLat = widget.ride['dropLatitude'] != null ? (widget.ride['dropLatitude'] as num).toDouble() : null;
    _dropLng = widget.ride['dropLongitude'] != null ? (widget.ride['dropLongitude'] as num).toDouble() : null;
    _odoStartCtrl.text = '${widget.ride['odoStart'] ?? ''}';
    _odoEndCtrl.text = '${widget.ride['odoEnd'] ?? ''}';
    // Only an uploaded file ("/uploads/…") can be shown in the admin portal.
    // Older builds stored the phone's own path, so treat those as "no photo
    // yet" and let the driver re-capture it.
    _odoStartImage =
        isUploadedFileUrl(widget.ride['odoStartImage'] as String?) ? widget.ride['odoStartImage'] : null;
    _odoEndImage =
        isUploadedFileUrl(widget.ride['odoEndImage'] as String?) ? widget.ride['odoEndImage'] : null;
    _status = widget.ride['status'] ?? '';

    try {
      final raw = widget.ride['waitingIntervals'];
      if (raw is String && raw.isNotEmpty) {
        _intervals = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    _waiting = widget.ride['waitingSince'] != null;
    if (_waiting) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _odoStartCtrl.dispose();
    _odoEndCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _waitingSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _waitingSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _workflowAction(String action) async {
    setState(() => _saving = true);
    try {
      final res = await ApiClient.instance.patch('$_endpoint/${widget.ride['id']}', {
        'action': action,
        'pickupLocation': _pickupCtrl.text,
        'dropLocation': _dropCtrl.text,
        'pickupLatitude': _pickupLat,
        'pickupLongitude': _pickupLng,
        'dropLatitude': _dropLat,
        'dropLongitude': _dropLng,
        'odoStart': int.tryParse(_odoStartCtrl.text),
        'odoEnd': int.tryParse(_odoEndCtrl.text),
        'odoStartImage': _odoStartImage,
        'odoEndImage': _odoEndImage,
      });
      final updated = res['data']['ride'];
      // Keep the local ride data in sync so the UI reflects the latest
      // server state (e.g. totalFare + fareBreakdown appear immediately
      // after completing the ride).
      final localRide = widget.ride;
      if (localRide is Map<String, dynamic>) {
        updated.forEach((key, value) {
          if (updated[key] != null) {
            localRide[key] = updated[key];
          }
        });
      }
      setState(() {
        _status = updated['status'] ?? _status;
        _saving = false;
        if (action == 'WAITING') {
          _waiting = true;
          _startTimer();
        }
        if (action == 'CONTINUE') {
          _waiting = false;
          _stopTimer();
          try {
            final raw = updated['waitingIntervals'];
            if (raw is String && raw.isNotEmpty) {
              _intervals = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
            }
          } catch (_) {}
        }
        if (action == 'COMPLETE' || action == 'START') {
          _waiting = false;
          _stopTimer();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? context.l10n.done)),
      );
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failed(e.toString())), backgroundColor: context.statusColors.danger),
      );
    }
  }

  // Capture the odometer proof photo and UPLOAD it, so the admin portal can
  // display it. Storing the phone's own file path (what this used to do) is
  // useless outside the device — the portal just showed a broken image.
  Future<void> _captureOdoPhoto({required bool isStart}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (photo == null) return;

      setState(() {
        if (isStart) {
          _uploadingStartOdo = true;
        } else {
          _uploadingEndOdo = true;
        }
      });

      try {
        // Re-encodes to JPEG (iPhone HEIC) and uploads; returns "/uploads/..."
        final url = await uploadCapturedImage(photo.path);
        if (!mounted) return;
        setState(() {
          if (isStart) {
            _odoStartImage = url;
          } else {
            _odoEndImage = url;
          }
        });
      } finally {
        if (mounted) {
          setState(() {
            _uploadingStartOdo = false;
            _uploadingEndOdo = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cameraError(e.toString())), backgroundColor: context.statusColors.danger),
      );
    }
  }

  void _pickOnMap({required bool isPickup}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(
          initialAddress: isPickup ? _pickupCtrl.text : _dropCtrl.text,
          initialLat: isPickup ? _pickupLat : _dropLat,
          initialLng: isPickup ? _pickupLng : _dropLng,
          onAddressChanged: (addr) {
            if (isPickup) _pickupCtrl.text = addr; else _dropCtrl.text = addr;
          },
          onCoordsChanged: (loc) {
            setState(() {
              if (isPickup) {
                _pickupLat = loc.lat;
                _pickupLng = loc.lng;
              } else {
                _dropLat = loc.lat;
                _dropLng = loc.lng;
              }
            });
          },
        ),
      ),
    );
  }

  String _fmt(int s) => '${(s ~/ 3600).toString().padLeft(2, '0')}:'
      '${((s % 3600) ~/ 60).toString().padLeft(2, '0')}:'
      '${(s % 60).toString().padLeft(2, '0')}';

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final isRider = widget.role == 'rider';
    final locked = _status == 'COMPLETED' || isRider;
    final odoS = int.tryParse(_odoStartCtrl.text);
    final odoE = int.tryParse(_odoEndCtrl.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRider ? context.l10n.rideDetailsViewOnly : context.l10n.rideStatus(_status)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text('🚗 ${ride['driver']?['fullName'] ?? 'Driver'}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('🙋 ${ride['rider']?['fullName'] ?? 'Rider'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('🚘 ${ride['vehicleType'] ?? '-'} • ⚙️ ${ride['transmission'] ?? '-'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // Pickup (read-only for rider, editable for driver)
            TextFormField(
              controller: _pickupCtrl,
              readOnly: true,
              enabled: !locked,
              decoration: InputDecoration(
                labelText: context.l10n.pickupLocationLabel,
                prefixIcon: Icon(Icons.trip_origin_rounded, color: context.statusColors.success),
              ),
            ),
            const SizedBox(height: 8),

            // DRIVER ONLY: search pickup on map — COMMENTED OUT (no GCP billing).
            // KEPT for future development once billing is enabled.
            // if (!isRider) ...[
            //   OutlinedButton.icon(
            //     onPressed: locked ? null : () => _pickOnMap(isPickup: true),
            //     icon: const Icon(Icons.map, color: Colors.indigo),
            //     label: const Text('🗺️ Search Pickup on Map'),
            //     ...
            //   ),
            // ],
            if (!isRider && _pickupLat != null && _pickupLng != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('📍 ${_pickupLat!.toStringAsFixed(6)}, ${_pickupLng!.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 12, color: context.statusColors.success, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 12),

            // Drop (read-only for rider, editable for driver)
            TextFormField(
              controller: _dropCtrl,
              readOnly: true,
              enabled: !locked,
              decoration: InputDecoration(
                labelText: context.l10n.dropLocationLabel,
                prefixIcon: Icon(Icons.flag_rounded, color: context.statusColors.danger),
              ),
            ),
            const SizedBox(height: 8),

            // DRIVER ONLY: search drop on map — COMMENTED OUT (no GCP billing).
            // KEPT for future development once billing is enabled.
            // if (!isRider) ...[
            //   OutlinedButton.icon(
            //     onPressed: locked ? null : () => _pickOnMap(isPickup: false),
            //     ...
            //   ),
            // ],
            if (!isRider && _dropLat != null && _dropLng != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('📍 ${_dropLat!.toStringAsFixed(6)}, ${_dropLng!.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 12, color: context.statusColors.danger, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 12),

            // Other details (read-only)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _detail(context.l10n.customerLabel, '${ride['customerName'] ?? '-'} • ${ride['customerNumber'] ?? ''}'),
                  _detail(context.l10n.notesLabel, '${ride['specialNote'] ?? '-'}'),
                  _detail(context.l10n.scheduledLabel, '${ride['startTime'] ?? '-'}'),
                  _detail(context.l10n.createdLabel, '${ride['createdAt'] ?? '-'}'),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Waiting history — shown to BOTH
            if (_intervals.isNotEmpty || ((ride['waitingTotal'] ?? 0) as num) > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.statusColors.warningContainer,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(children: [
                  Text(context.l10n.waitingHistory,
                      style: TextStyle(fontWeight: FontWeight.bold, color: context.statusColors.warning)),
                  const SizedBox(height: 6),
                  for (var i = 0; i < _intervals.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.l10n.waitingN('${i + 1}'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(
                            '${_fmt(int.tryParse('${_intervals[i]['seconds'] ?? 0}') ?? 0)}'
                            '  (${_intervals[i]['start']?.toString()?.substring(11, 16) ?? ''} → '
                            '${_intervals[i]['end']?.toString()?.substring(11, 16) ?? ''})',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  if (((ride['waitingTotal'] ?? 0) as num) > 0) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.l10n.totalWaiting, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(_fmt(int.tryParse('${ride['waitingTotal'] ?? 0}') ?? 0),
                            style: TextStyle(fontWeight: FontWeight.bold, color: context.statusColors.warning)),
                      ],
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 12),
            ],

            // Live waiting timer (driver only)
            if (_waiting && !isRider) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.statusColors.warningContainer,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(children: [
                  Text(context.l10n.waitingTimer('${_intervals.length + 1}'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    _fmt(_waitingSeconds),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.statusColors.warning),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
            ],

            // ---- DRIVER ONLY: ODOMETER SECTION (required for start/complete) ----
            if (!isRider) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(context.l10n.odometerReadings,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),

                    // START odometer
                    TextField(
                      controller: _odoStartCtrl,
                      keyboardType: TextInputType.number,
                      enabled: !locked,
                      decoration: InputDecoration(
                        labelText: context.l10n.startOdometer,
                        prefixIcon: Icon(Icons.speed_rounded, color: context.statusColors.success),
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: (locked || _uploadingStartOdo) ? null : () => _captureOdoPhoto(isStart: true),
                      icon: _uploadingStartOdo
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.photo_camera_rounded, color: context.statusColors.success),
                      label: Text(_odoStartImage != null
                          ? context.l10n.startOdoPhotoDone
                          : context.l10n.captureStartOdoPhoto),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.statusColors.success,
                        side: BorderSide(color: context.statusColors.success),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // END odometer
                    TextField(
                      controller: _odoEndCtrl,
                      keyboardType: TextInputType.number,
                      enabled: !locked,
                      decoration: InputDecoration(
                        labelText: context.l10n.endOdometer,
                        prefixIcon: Icon(Icons.speed_rounded, color: context.statusColors.danger),
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: (locked || _uploadingEndOdo) ? null : () => _captureOdoPhoto(isStart: false),
                      icon: _uploadingEndOdo
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.photo_camera_rounded, color: context.statusColors.danger),
                      label: Text(_odoEndImage != null
                          ? context.l10n.endOdoPhotoDone
                          : context.l10n.captureEndOdoPhoto),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.statusColors.danger,
                        side: BorderSide(color: context.statusColors.danger),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Distance preview
                    if (odoS != null && odoE != null && odoE >= odoS) ...[
                      Text('📏 Distance: ${odoE - odoS} km',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ] else if (odoS != null && odoE != null && odoE < odoS) ...[
                      Text('⚠️ End odometer must be >= Start',
                          style: TextStyle(color: context.statusColors.danger, fontSize: 12)),
                    ],

                    const SizedBox(height: 8),

                    // Save button (uploads all odo + waiting + location to portal)
                    ElevatedButton.icon(
                      onPressed: _saving || locked
                          ? null
                          : () => _workflowAction('SAVE'),
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(context.l10n.saveForPortal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // DRIVER ONLY: workflow buttons
            if (!isRider) ...[
              // BEFORE START: Waiting active → hide Waiting button, show ONLY Start Ride
              if (_status == 'UPCOMING' || _status == 'ASSIGNED') ...[
                if (_waiting) ...[
                  // Waiting timer is running pre-start → show only Start Ride (full width)
                  FilledButton(
                    onPressed: _saving ? null : () => _workflowAction('START'),
                    style: FilledButton.styleFrom(backgroundColor: context.statusColors.success),
                    child: Text(context.l10n.startRide),
                  ),
                ] else ...[
                  // Normal pre-start → show Waiting + Start Ride
                  Row(children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : () => _workflowAction('WAITING'),
                        style: FilledButton.styleFrom(backgroundColor: context.statusColors.warning),
                        child: Text(context.l10n.waitingBtn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : () => _workflowAction('START'),
                        style: FilledButton.styleFrom(backgroundColor: context.statusColors.success),
                        child: Text(context.l10n.startRide),
                      ),
                    ),
                  ]),
                ],
              ],
              if (_status == 'ONGOING') ...[
                Row(children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _workflowAction(_waiting ? 'CONTINUE' : 'WAITING'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _waiting ? context.statusColors.warning : context.statusColors.success,
                      ),
                      child: Text(_waiting ? context.l10n.continueRide : context.l10n.waitingBtn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : () => _workflowAction('COMPLETE'),
                      style: FilledButton.styleFrom(backgroundColor: context.statusColors.danger),
                      child: Text(context.l10n.completeRide),
                    ),
                  ),
                ]),
              ],
            ],

            // Completed footer (both driver & rider)
            if (_status == 'COMPLETED') ...[
              const SizedBox(height: 8),
              Center(
                child: Column(children: [
                  Icon(Icons.check_circle_rounded, color: context.statusColors.success, size: 48),
                  const SizedBox(height: 8),
                  Text(context.l10n.rideCompletedLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 12),

              // 💵 Total Fare Summary (driver & rider both see it)
              if (ride['totalFare'] != null) ...[
                (() {
                  // Try to parse the fare breakdown JSON
                  Map<String, dynamic>? b;
                  try {
                    final raw = ride['fareBreakdown'];
                    if (raw is String && raw.isNotEmpty) {
                      final decoded = jsonDecode(raw);
                      if (decoded is Map<String, dynamic>) b = decoded;
                    }
                  } catch (_) {}
                  final rows = <(String, String)>[
                    if (b != null) ...[
                      (context.l10n.baseFare, 'Rs. ${b['baseFare'] ?? 0}'),
                      (context.l10n.distanceKm('${b['distanceKm'] ?? 0}'), 'Rs. ${b['distanceCost'] ?? 0}'),
                      if ((b['waitingMin'] ?? 0) > 0)
                        (context.l10n.waitingMin('${b['waitingMin']}'), 'Rs. ${b['waitingCost'] ?? 0}'),
                    ],
                  ];
                  return FareBreakdownCard(
                    title: context.l10n.fareSummary,
                    totalLabel: context.l10n.totalFare,
                    totalFare: ride['totalFare'],
                    rows: rows,
                  );
                })(),
              ],
            ],
          ],
        ),
      ),
    );
  }
}