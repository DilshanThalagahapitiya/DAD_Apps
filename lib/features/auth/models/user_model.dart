// ============================================================
// User Model
// ============================================================
// Represents a user in the SafeRide system.
// ============================================================

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? initials;
  final String? dob;
  final String? nic;
  final String phone;
  final String role;
  final String status;
  final String? tempPassword;
  final bool mustChangePassword;
  final Map<String, dynamic>? customerProfile;
  final Map<String, dynamic>? driverProfile;
  final String? googlePhotoUrl;
  /// True when the backend says this user still has to accept the currently
  /// published Terms & Conditions (staffed by login / signup / /api/auth/me).
  /// The app blocks the dashboard until it is false.
  final bool termsAcceptanceRequired;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName,
    this.lastName,
    this.initials,
    this.dob,
    this.nic,
    required this.phone,
    required this.role,
    required this.status,
    this.tempPassword,
    this.mustChangePassword = false,
    this.customerProfile,
    this.driverProfile,
    this.googlePhotoUrl,
    this.termsAcceptanceRequired = false,
  });

  /// Returns true if the customer's profile is complete:
  /// Has location, vehicle type, vehicle number, and an email.
  /// Used to show the "Complete Your Profile" notification.
  bool get profileComplete {
    if (role != 'CUSTOMER') return true;
    final cp = customerProfile;
    if (cp == null) return false;
    final location = (cp['location'] as String?)?.trim() ?? '';
    final vehicleType = (cp['vehicleType'] as String?)?.trim() ?? '';
    final vehicleNumber = (cp['vehicleNumber'] as String?)?.trim() ?? '';
    final emailOk = email.trim().isNotEmpty && !email.startsWith('user_');
    return location.isNotEmpty && vehicleType.isNotEmpty && vehicleNumber.isNotEmpty && emailOk;
  }

  /// Returns true if this user's personal details are complete:
  /// a name, an NIC number and a phone number.
  /// Google sign-up creates accounts without a phone number or NIC, so this
  /// is false right after signing in with Google - the app must show the
  /// "Complete Your Details" screen before the user can use the app.
  /// Applies to Customer, Driver and Rider (the roles that sign up via
  /// Google) — Admin/Hotel accounts don't go through this gate.
  bool get userDetailsComplete {
    if (role != 'CUSTOMER' && role != 'DRIVER' && role != 'RIDER') return true;
    final nameOk =
        fullName.trim().isNotEmpty || (firstName ?? '').trim().isNotEmpty;
    final phoneOk = phone.trim().isNotEmpty;
    final nicOk = (nic ?? '').trim().isNotEmpty;
    return nameOk && phoneOk && nicOk;
  }

  /// Returns true if the driver's authorization (license) and vehicle
  /// preparation details are complete: license number, front/back license
  /// photos, preferred vehicle type, and an expiry date matching the
  /// selected license category. A Google sign-up driver has a DriverProfile
  /// row with empty placeholder values, so this is false until the driver
  /// fills in the "Complete Your Driver Profile" screen.
  bool get driverProfileComplete {
    if (role != 'DRIVER') return true;
    final dp = driverProfile;
    if (dp == null) return false;
    final licenseNumber = (dp['licenseNumber'] as String?)?.trim() ?? '';
    final licenseFront = (dp['licenseFrontImage'] as String?)?.trim() ?? '';
    final licenseBack = (dp['licenseBackImage'] as String?)?.trim() ?? '';
    final vehicleType = (dp['vehicleType'] as String?)?.trim() ?? '';
    final category = (dp['licenseCategory'] as String?)?.trim() ?? '';
    final lightExpiry = (dp['licenseLightExpiryDate'] as String?)?.trim() ?? '';
    final heavyExpiry = (dp['licenseHeavyExpiryDate'] as String?)?.trim() ?? '';

    final expiryOk = switch (category) {
      'HEAVY' => heavyExpiry.isNotEmpty,
      'BOTH' => lightExpiry.isNotEmpty && heavyExpiry.isNotEmpty,
      _ => lightExpiry.isNotEmpty, // LIGHT_WEIGHT (and any other/default)
    };

    return licenseNumber.isNotEmpty &&
        licenseFront.isNotEmpty &&
        licenseBack.isNotEmpty &&
        vehicleType.isNotEmpty &&
        expiryOk;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      initials: json['initials'],
      dob: json['dob'],
      nic: json['nic'],
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      tempPassword: json['tempPassword'],
      mustChangePassword: json['mustChangePassword'] ?? false,
      customerProfile: json['customerProfile'] as Map<String, dynamic>?,
      driverProfile: json['driverProfile'] as Map<String, dynamic>?,
      googlePhotoUrl: json['googlePhotoUrl'],
      termsAcceptanceRequired: json['termsAcceptanceRequired'] ?? false,
    );
  }
}

/// Copy UserModel with modified fields (for preserving google photo URL)
extension UserModelCopy on UserModel {
  UserModel copyWith({
    String? googlePhotoUrl,
    bool? termsAcceptanceRequired,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      initials: initials,
      dob: dob,
      nic: nic,
      phone: phone,
      role: role,
      status: status,
      tempPassword: tempPassword,
      mustChangePassword: mustChangePassword,
      customerProfile: customerProfile,
      driverProfile: driverProfile,
      googlePhotoUrl: googlePhotoUrl ?? this.googlePhotoUrl,
      termsAcceptanceRequired: termsAcceptanceRequired ?? this.termsAcceptanceRequired,
    );
  }
}

class AuthResult {
  final UserModel user;
  final String token;
  final String? tempPassword;

  AuthResult({required this.user, required this.token, this.tempPassword});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      user: UserModel.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      tempPassword: json['tempPassword'],
    );
  }
}