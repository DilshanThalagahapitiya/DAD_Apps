import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../network/api_client.dart';
import '../../features/auth/providers/auth_provider.dart';

// Global key for showing snackbars/banners from anywhere without context
final GlobalKey<ScaffoldMessengerState> notificationKey = GlobalKey<ScaffoldMessengerState>();

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  Timer? _timer;
  String? _lastUserStatus;
  String? _lastRideStatus;

  // Start polling when user logs in
  void startPolling(AuthProvider auth) {
    if (_timer != null) return;
    
    // Initial fetch
    _poll(auth);
    
    // Poll every 15 seconds
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!auth.isLoggedIn) {
        stopPolling();
      } else {
        _poll(auth);
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _lastUserStatus = null;
    _lastRideStatus = null;
  }

  Future<void> _poll(AuthProvider auth) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      // Fetch sync data (user status & active ride status)
      final res = await ApiClient.instance.get('/api/auth/sync?_t=$now');
      
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final newUserStatus = data['userStatus'];
        final activeRide = data['activeRide'];
        final newRideStatus = activeRide != null ? activeRide['status'] : null;

        // Check user status change (e.g. PENDING -> APPROVED)
        if (_lastUserStatus != null && _lastUserStatus != newUserStatus) {
          if (newUserStatus == 'APPROVED') {
            _showNotification('Account Approved!', 'Your account has been approved. You can now use the app.');
            auth.restoreSession(); // Refresh auth data to unlock app
          } else if (newUserStatus == 'REJECTED') {
            _showNotification('Account Rejected', 'Your account was rejected.');
          }
        }

        // Check ride status change (e.g. ASSIGNED, ONGOING)
        if (_lastRideStatus != null && _lastRideStatus != newRideStatus && newRideStatus != null) {
          if (newRideStatus == 'ASSIGNED') {
            _showNotification('Ride Assigned!', 'A driver has been assigned to your ride.');
          } else if (newRideStatus == 'ONGOING') {
            _showNotification('Ride Started', 'Your ride is now ongoing.');
          } else if (newRideStatus == 'COMPLETED') {
            _showNotification('Ride Completed', 'Your ride has been completed successfully.');
          }
        }

        _lastUserStatus = newUserStatus;
        _lastRideStatus = newRideStatus;
      }
    } catch (e) {
      debugPrint('Notification polling error: $e');
      if (e is ApiException) {
        final msg = e.message.toLowerCase();
        // If user was deleted from admin portal or token expired
        if (msg.contains('unauthorized') || msg.contains('user not found')) {
          _showNotification('Session Expired', 'Your account has been removed or session expired.');
          auth.logout();
          stopPolling();
        }
      }
    }
  }

  void _showNotification(String title, String message) {
    // Play default system notification sound
    SystemSound.play(SystemSoundType.alert);

    // Show a top floating snackbar
    notificationKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: Colors.indigo.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
