// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Drink And Drive';

  @override
  String get appTagline => 'Drink and Drive Safe';

  @override
  String get heroTitle => 'Don\'t Drive Drunk.\nGet Home Safely with SafeRide.';

  @override
  String get heroSubtitle =>
      'SafeRide connects you with verified safe drivers, riders, and partner hotels — so everyone gets home safely.';

  @override
  String get letsHire => 'Let\'s Hire';

  @override
  String get register => 'Register';

  @override
  String get otherLogins => 'or other logins';

  @override
  String get support24_7 => '24/7 Support';

  @override
  String get supportHelpText => 'Need help hiring a driver? Call us anytime.';

  @override
  String callUsAt(String phone) {
    return '📞 Call us at $phone';
  }

  @override
  String get call => 'CALL';

  @override
  String get howDadWorks => 'How SafeRide Works';

  @override
  String get step1 => 'Register';

  @override
  String get step2 => 'Get Approved';

  @override
  String get step3 => 'Get Home Safe';

  @override
  String get login => 'Login';

  @override
  String get hireADriver => 'Hire a Driver';

  @override
  String get loginToHire => 'Login to hire a safe driver';

  @override
  String loginTitle(String appName) {
    return '$appName - Login';
  }

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get or => 'OR';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get keepMeLoggedIn => 'Keep me logged in';

  @override
  String get newHere => 'New here? ';

  @override
  String get loginFailed => 'Login failed';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String get createAccount => 'Create Account';

  @override
  String get selectAccountType => 'Select your account type to register';

  @override
  String get driver => 'Driver';

  @override
  String get rider => 'Rider';

  @override
  String get customer => 'Customer';

  @override
  String get hotel => 'Hotel';

  @override
  String get admin => 'Admin';

  @override
  String get iWantToDrive => 'I want to drive';

  @override
  String get iNeedARideHome => 'I need a ride home';

  @override
  String get iOwnAVehicle => 'I own a vehicle';

  @override
  String get iAmAHotelPartner => 'I\'m a hotel partner';

  @override
  String get iManageTheSystem => 'I manage the system';

  @override
  String get selectAccountTypeForGoogle =>
      'Select an account type above to continue with Google.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get registrationSubmitted =>
      'Registration submitted! Wait for admin approval.';

  @override
  String get adminRegistered => 'Admin registered!';

  @override
  String get googleSignInSuccessful => 'Google sign-in successful!';

  @override
  String get pleaseSelectAccountType =>
      'Please select your account type first.';

  @override
  String get adminMustUseEmail =>
      'Admin accounts must be registered with email & password.';

  @override
  String get accountCreatedCompleteProfile =>
      'Account created! Please complete your profile to start hiring drivers.';

  @override
  String get firstName => 'First Name *';

  @override
  String get lastName => 'Last Name *';

  @override
  String get emailAddress => 'Email Address *';

  @override
  String get phoneNumber => 'Phone Number *';

  @override
  String get nic => 'NIC *';

  @override
  String get nicNumber => 'NIC Number *';

  @override
  String get city => 'City *';

  @override
  String get passwordStar => 'Password *';

  @override
  String get required => 'Required';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get licenseDetails => 'License Details';

  @override
  String get licenseNumber => 'License Number *';

  @override
  String get licenseCategory => 'License Category';

  @override
  String get vehiclePreferences => 'Vehicle Preferences';

  @override
  String get preferredVehicle => 'Preferred Vehicle';

  @override
  String get transmission => 'Transmission';

  @override
  String get registerAsDriver => 'Register as Driver';

  @override
  String get registerAsRider => 'Register as Rider';

  @override
  String get registerAsCustomer => 'Register as Customer';

  @override
  String get registerAsHotel => 'Register as Hotel';

  @override
  String get registerAsAdmin => 'Register as Admin';

  @override
  String get adminDetails => 'Admin Details';

  @override
  String get homeAddress => 'Home Address *';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get emergencyContactName => 'Emergency Contact Name *';

  @override
  String get emergencyContactPhone => 'Emergency Contact Phone *';

  @override
  String get loginDetails => 'Login Details';

  @override
  String get address => 'Address *';

  @override
  String get contactPhone => 'Contact Phone *';

  @override
  String get contactEmail => 'Contact Email *';

  @override
  String get auto => 'Auto';

  @override
  String get manual => 'Manual';

  @override
  String get both => 'Both';

  @override
  String get lightWeight => 'Light Weight';

  @override
  String get heavy => 'Heavy';

  @override
  String get car => 'Car';

  @override
  String get van => 'Van';

  @override
  String get lorry => 'Lorry';

  @override
  String get bus => 'Bus';

  @override
  String get motorBike => 'Motor Bike';

  @override
  String get threeWheeler => 'Three Wheeler';

  @override
  String get suv => 'SUV';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get completeProfileSubtitle =>
      'Fill in your details to start hiring drivers';

  @override
  String get locationGoogleMaps => 'Location (Google Maps) *';

  @override
  String get vehicleType => 'Vehicle Type *';

  @override
  String get transmissionType => 'Transmission Type *';

  @override
  String get vehicleNumber => 'Vehicle Number *';

  @override
  String get saving => 'Saving...';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileCompleted =>
      '✅ Profile completed! You can now hire drivers.';

  @override
  String get completeYourDetails => 'Complete Your Details';

  @override
  String get completeYourDetailsSubtitle =>
      'Fill in your personal details to continue';

  @override
  String get detailsRequiredInfo =>
      'Your phone number and NIC are needed so drivers can contact you and we can confirm your identity.';

  @override
  String get emailFromGoogle => 'Email (from Google)';

  @override
  String get dateOfBirthOptional => 'Date of Birth (Optional)';

  @override
  String get saveDetails => 'Save Details';

  @override
  String get detailsSaved => '✅ Your details have been saved!';

  @override
  String get completeDetailsBanner => 'Please complete your details';

  @override
  String get completeDetailsBannerBody =>
      'Add your name, NIC and phone number before adding vehicle details.';

  @override
  String get fillDetails => 'Fill Details';

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get specialNoteOptional => 'Special Note (Optional)';

  @override
  String get saveVehicleDetails => 'Save Vehicle Details';

  @override
  String get vehicleDetailsSaved => '✅ Vehicle details saved!';

  @override
  String get myVehicle => 'My Vehicle';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get signOutOfAccount => 'Sign out of your account';

  @override
  String get addOrEditVehicle => 'Add or edit vehicle details';

  @override
  String roleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String welcomeName(String name) {
    return 'Welcome, $name 👤';
  }

  @override
  String welcomeNameAdmin(String name) {
    return 'Welcome, $name 📊';
  }

  @override
  String get customerPortal => 'Customer Portal';

  @override
  String get adminPortal => 'Admin Portal';

  @override
  String get pleaseCompleteProfile => 'Please complete your profile';

  @override
  String get addYourVehicleDetails => 'Add Your Vehicle Details';

  @override
  String get addVehicleDetailsBody =>
      'Before you can hire a SafeRide driver you need to add your vehicle & location details.\n\nA SafeRide driver will come and drive your own vehicle, so we need your vehicle type, vehicle number and pick-up location.';

  @override
  String get later => 'Later';

  @override
  String get addVehicleDetails => 'Add Vehicle Details';

  @override
  String get manageDrivers => 'Manage drivers';

  @override
  String get manageRiders => 'Manage riders';

  @override
  String get manageCustomers => 'Manage customers';

  @override
  String get manageRides => 'Manage rides';

  @override
  String get drivers => 'Drivers';

  @override
  String get riders => 'Riders';

  @override
  String get customers => 'Customers';

  @override
  String get rides => 'Rides';

  @override
  String get pendingApproval =>
      'Your account is pending admin approval.\nPlease wait for the administrator to review your registration.';

  @override
  String get requestDriver => 'Request Driver';

  @override
  String get yourDetailsAutoFilled => '👤 Your Details (Auto-filled)';

  @override
  String get pickupLocation => 'Pickup Location *';

  @override
  String get enterCurrentLocation => 'Enter your current location';

  @override
  String get dropLocation => 'Drop Location *';

  @override
  String get whereToGo => 'Where do you need to go?';

  @override
  String get pickupTime => 'Pickup Time *';

  @override
  String get specialNote => 'Special Note';

  @override
  String get anyInstructions => 'Any instructions...';

  @override
  String get requestSubmitted =>
      '✅ Request submitted! Admin will assign a driver soon.';

  @override
  String get myRides => 'My Rides';

  @override
  String get myRidesTickets => 'My Rides / Tickets';

  @override
  String get myRidesTicketsRider => 'My Rides / Tickets (Rider)';

  @override
  String get acceptTicket => '✅ Accept Ticket';

  @override
  String get cancel => '❌ Cancel';

  @override
  String get ticketAccepted => '✅ Ticket accepted!';

  @override
  String get ticketCancelled => '❌ Ticket cancelled';

  @override
  String get youAcceptedWaitingDriver =>
      '✅ You accepted — waiting for the driver to accept...';

  @override
  String get youAcceptedWaitingRider =>
      '✅ You accepted — waiting for the rider to accept...';

  @override
  String failed(String error) {
    return 'Failed: $error';
  }

  @override
  String get fareSummary => '💵 Fare Summary';

  @override
  String get baseFare => '🚦 Base Fare';

  @override
  String get distance => '📏 Distance';

  @override
  String distanceKm(String km) {
    return '📏 Distance ($km km)';
  }

  @override
  String get waiting => '⏱️ Waiting';

  @override
  String waitingMin(String min) {
    return '⏱️ Waiting ($min min)';
  }

  @override
  String get totalAmount => '💰 Total Amount';

  @override
  String get totalFare => '💰 Total Fare';

  @override
  String get rateTable => '💰 Rate Table';

  @override
  String firstKm(String km) {
    return 'First $km km';
  }

  @override
  String afterKm(String km) {
    return 'After $km km';
  }

  @override
  String get maxKmRate => 'Max KM Rate';

  @override
  String waitingFirstMin(String min) {
    return 'Waiting (1st $min min)';
  }

  @override
  String get waitingAfter => 'Waiting (after)';

  @override
  String get free => 'FREE';

  @override
  String get waitingForAdminAssign =>
      'Waiting for admin to assign driver & rider';

  @override
  String get assignedWaitingAccept =>
      'Driver & rider assigned — waiting for them to accept';

  @override
  String get scheduledBothAccepted =>
      'Scheduled — both driver & rider accepted';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get accepted => '✓ Accepted';

  @override
  String get awaiting => '⏳ Awaiting';

  @override
  String get useThis => '✅ Use This';

  @override
  String get typeLocationHint => '🔍 Type location e.g. Colombo 07';

  @override
  String get useMyCurrentLocation => '📍 Use My Current Location';

  @override
  String get mapHint =>
      '✍️ Type the location above, then tap ✅ Use This.\nOptionally tap \"Use My Current Location\" to attach GPS coordinates.';

  @override
  String get couldNotFetchLocation =>
      'Could not fetch current location. Enable location permissions.';

  @override
  String get pleaseTypeLocation => 'Please type a location.';

  @override
  String get quickSignupInfo =>
      'Quick signup in under a minute! You can complete your full profile after logging in.';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get validEmail => 'Enter a valid email';

  @override
  String get nicRequired => 'NIC is required';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get hotelName => 'Hotel Name *';

  @override
  String get hotelLicenseNumber => 'Hotel License Number *';

  @override
  String get completeYourProfile => 'Complete Your Profile';

  @override
  String get completeProfileHelpText =>
      'Please provide these details to start hiring drivers. This helps us match you with the right driver for your vehicle.';

  @override
  String welcomeNameDriver(String name) {
    return 'Welcome, $name 🚗';
  }

  @override
  String get driverPortal => 'Driver Portal';

  @override
  String get confirmedRides => 'Confirmed rides (both accepted)';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get pendingTicketsOnly => 'Pending tickets only';

  @override
  String get history => 'History';

  @override
  String get completedCancelledRides => 'Completed & cancelled rides';

  @override
  String get profile => 'Profile';

  @override
  String get myDetails => 'My details';

  @override
  String welcomeNameRider(String name) {
    return 'Welcome, $name 🙋';
  }

  @override
  String get riderPortal => 'Rider Portal';

  @override
  String get upcomingRides => 'Upcoming Rides';

  @override
  String get completed => 'Completed';

  @override
  String get rideHistory => 'Ride history';

  @override
  String get complete => 'Complete';

  @override
  String get addVehicleLocationDetails =>
      'Add your vehicle & location details to start hiring drivers.';

  @override
  String get myRidesAndFares => 'My Rides & Fares';

  @override
  String callUsLabel(String phone) {
    return 'Call Us  $phone';
  }

  @override
  String welcomePlain(String name) {
    return 'Welcome, $name';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noRideRequests => 'No ride requests yet';

  @override
  String get requestToGetStarted => 'Request a driver to get started.';

  @override
  String nameLabel(String name) {
    return 'Name: $name';
  }

  @override
  String phoneLabel(String phone) {
    return 'Phone: $phone';
  }

  @override
  String driverLabel(String name) {
    return '🚗 Driver: $name';
  }

  @override
  String get driverCancelled => '❌ Driver cancelled this ticket';

  @override
  String get driverAccepted => '✅ Driver accepted';

  @override
  String get driverNotAccepted => '⏳ Driver has not accepted yet';

  @override
  String riderLabel(String name) {
    return '🙋 Rider: $name';
  }

  @override
  String get riderCancelled => '❌ Rider cancelled this ticket';

  @override
  String get riderAccepted => '✅ Rider accepted';

  @override
  String get riderNotAccepted => '⏳ Rider has not accepted yet';

  @override
  String get latestRequestStatus => 'Latest Request Status';

  @override
  String get refresh => 'Refresh';

  @override
  String get noRideRequestsFull =>
      'No ride requests yet.\nRequest a driver to get started.';

  @override
  String get yourLatestRequestStatus =>
      'Your latest request status will appear here.';

  @override
  String get rideInProgress => 'Ride in progress';

  @override
  String get rideCompleted => 'Ride completed';

  @override
  String get rideDetailsViewOnly => 'Ride Details (View Only)';

  @override
  String rideStatus(String status) {
    return 'Ride $status';
  }

  @override
  String get done => 'Done';

  @override
  String cameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String get pickupLocationLabel => '📍 Pickup Location';

  @override
  String get dropLocationLabel => '📍 Drop Location';

  @override
  String get customerLabel => '👤 Customer';

  @override
  String get notesLabel => '📝 Notes';

  @override
  String get scheduledLabel => '🕐 Scheduled';

  @override
  String get createdLabel => '📅 Created';

  @override
  String get waitingHistory => '⏱️ Waiting History';

  @override
  String waitingN(String n) {
    return 'Waiting $n';
  }

  @override
  String get totalWaiting => 'Total Waiting';

  @override
  String waitingTimer(String n) {
    return '⏳ Waiting Timer $n';
  }

  @override
  String get odometerReadings => '🛣️ Odometer Readings';

  @override
  String get startOdometer => 'Start Odometer (required before Start)';

  @override
  String get endOdometer => 'End Odometer (required before Complete)';

  @override
  String get startOdoPhotoDone => '📸 Start Odo Photo ✓ (optional)';

  @override
  String get captureStartOdoPhoto => '📸 Capture Start Odo Photo (optional)';

  @override
  String get endOdoPhotoDone => '📸 End Odo Photo ✓ (optional)';

  @override
  String get captureEndOdoPhoto => '📸 Capture End Odo Photo (optional)';

  @override
  String get saveForPortal => '💾 Save for Portal';

  @override
  String get startRide => '▶ Start Ride';

  @override
  String get waitingBtn => '⏳ Waiting';

  @override
  String get continueRide => '▶ Continue Ride';

  @override
  String get completeRide => '✅ Complete Ride';

  @override
  String get rideCompletedLabel => 'Ride Completed';

  @override
  String get language => 'Language';
}
