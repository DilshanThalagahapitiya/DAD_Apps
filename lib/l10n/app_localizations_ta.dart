// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'Drink And Drive';

  @override
  String get appTagline => 'பாதுகாப்பாக பயணிக்கவும்';

  @override
  String get heroTitle =>
      'குடித்துவிட்டு வாகனம் ஓட்டாதீர்கள்.\nSafeRide உடன் பாதுகாப்பாக வீடு செல்லுங்கள்.';

  @override
  String get heroSubtitle =>
      'SafeRide உங்களை சரிபார்க்கப்பட்ட பாதுகாப்பான ஓட்டுநர்கள், பயணிகள் மற்றும் கூட்டாளர் ஹோட்டல்களுடன் இணைக்கிறது — அனைவரும் பாதுகாப்பாக வீடு செல்ல.';

  @override
  String get letsHire => 'ஓட்டுநரை அமர்த்துவோம்';

  @override
  String get register => 'பதிவு செய்யுங்கள்';

  @override
  String get otherLogins => 'அல்லது பிற உள்நுழைவுகள்';

  @override
  String get support24_7 => '24/7 ஆதரவு';

  @override
  String get supportHelpText =>
      'ஓட்டுநரை அமர்த்த உதவி தேவையா? எந்த நேரத்திலும் எங்களை அழைக்கவும்.';

  @override
  String callUsAt(String phone) {
    return '📞 எங்களை அழைக்கவும் $phone';
  }

  @override
  String get call => 'அழைக்கவும்';

  @override
  String get howDadWorks => 'SafeRide எவ்வாறு செயல்படுகிறது';

  @override
  String get step1 => 'பதிவு செய்யுங்கள்';

  @override
  String get step2 => 'அனுமதி பெறுங்கள்';

  @override
  String get step3 => 'பாதுகாப்பாக வீடு செல்லுங்கள்';

  @override
  String get login => 'உள்நுழைய';

  @override
  String get hireADriver => 'ஓட்டுநரை அமர்த்துங்கள்';

  @override
  String get loginToHire => 'பாதுகாப்பான ஓட்டுநரை அமர்த்த உள்நுழையவும்';

  @override
  String loginTitle(String appName) {
    return '$appName - உள்நுழைவு';
  }

  @override
  String get continueWithGoogle => 'Google உடன் தொடரவும்';

  @override
  String get signingIn => 'உள்நுழைகிறது...';

  @override
  String get or => 'அல்லது';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get pleaseEnterEmail => 'உங்கள் மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get pleaseEnterPassword => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get keepMeLoggedIn => 'என்னை உள்நுழைந்த நிலையில் வைத்திரு';

  @override
  String get newHere => 'புதியவரா? ';

  @override
  String get loginFailed => 'உள்நுழைவு தோல்வியடைந்தது';

  @override
  String googleSignInFailed(String error) {
    return 'Google உள்நுழைவு தோல்வியடைந்தது: $error';
  }

  @override
  String get unknownError => 'அறியப்படாத பிழை';

  @override
  String get createAccount => 'கணக்கை உருவாக்கு';

  @override
  String get selectAccountType =>
      'பதிவு செய்ய உங்கள் கணக்கு வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get driver => 'ஓட்டுநர்';

  @override
  String get rider => 'பயணி';

  @override
  String get customer => 'வாடிக்கையாளர்';

  @override
  String get hotel => 'ஹோட்டல்';

  @override
  String get admin => 'நிர்வாகி';

  @override
  String get iWantToDrive => 'நான் வாகனம் ஓட்ட விரும்புகிறேன்';

  @override
  String get iNeedARideHome => 'வீடு செல்ல வாகனம் தேவை';

  @override
  String get iOwnAVehicle => 'எனக்கு ஒரு வாகனம் உள்ளது';

  @override
  String get iAmAHotelPartner => 'நான் ஹோட்டல் கூட்டாளர்';

  @override
  String get iManageTheSystem => 'நான் கணினியை நிர்வகிக்கிறேன்';

  @override
  String get selectAccountTypeForGoogle =>
      'Google உடன் தொடர மேலே ஒரு கணக்கு வகையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get alreadyHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get registrationFailed => 'பதிவு தோல்வியடைந்தது';

  @override
  String get registrationSubmitted =>
      'பதிவு சமர்ப்பிக்கப்பட்டது! நிர்வாகி அனுமதிக்காக காத்திருங்கள்.';

  @override
  String get adminRegistered => 'நிர்வாகி பதிவு செய்யப்பட்டார்!';

  @override
  String get googleSignInSuccessful => 'Google உள்நுழைவு வெற்றி!';

  @override
  String get pleaseSelectAccountType =>
      'முதலில் உங்கள் கணக்கு வகையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get adminMustUseEmail =>
      'நிர்வாகி கணக்குகள் மின்னஞ்சல் மற்றும் கடவுச்சொல்லுடன் பதிவு செய்யப்பட வேண்டும்.';

  @override
  String get accountCreatedCompleteProfile =>
      'கணக்கு உருவாக்கப்பட்டது! ஓட்டுநர்களை அமர்த்த உங்கள் சுயவிவரத்தை முடிக்கவும்.';

  @override
  String get firstName => 'முதல் பெயர் *';

  @override
  String get lastName => 'கடைசி பெயர் *';

  @override
  String get emailAddress => 'மின்னஞ்சல் முகவரி *';

  @override
  String get phoneNumber => 'தொலைபேசி எண் *';

  @override
  String get nic => 'தே.அ.அ. *';

  @override
  String get nicNumber => 'தே.அ.அ. எண் *';

  @override
  String get city => 'நகரம் *';

  @override
  String get passwordStar => 'கடவுச்சொல் *';

  @override
  String get required => 'தேவை';

  @override
  String get personalDetails => 'தனிப்பட்ட விவரங்கள்';

  @override
  String get licenseDetails => 'உரிம விவரங்கள்';

  @override
  String get licenseNumber => 'உரிம எண் *';

  @override
  String get licenseCategory => 'உரிம வகை';

  @override
  String get vehiclePreferences => 'வாகன விருப்பங்கள்';

  @override
  String get preferredVehicle => 'விருப்பமான வாகனம்';

  @override
  String get transmission => 'கியர் முறை';

  @override
  String get registerAsDriver => 'ஓட்டுநராக பதிவு செய்யுங்கள்';

  @override
  String get registerAsRider => 'பயணியாக பதிவு செய்யுங்கள்';

  @override
  String get registerAsCustomer => 'வாடிக்கையாளராக பதிவு செய்யுங்கள்';

  @override
  String get registerAsHotel => 'ஹோட்டலாக பதிவு செய்யுங்கள்';

  @override
  String get registerAsAdmin => 'நிர்வாகியாக பதிவு செய்யுங்கள்';

  @override
  String get adminDetails => 'நிர்வாகி விவரங்கள்';

  @override
  String get homeAddress => 'வீட்டு முகவரி *';

  @override
  String get emergencyContact => 'அவசர தொடர்பு';

  @override
  String get emergencyContactName => 'அவசர தொடர்பு பெயர் *';

  @override
  String get emergencyContactPhone => 'அவசர தொடர்பு தொலைபேசி *';

  @override
  String get loginDetails => 'உள்நுழைவு விவரங்கள்';

  @override
  String get address => 'முகவரி *';

  @override
  String get contactPhone => 'தொடர்பு தொலைபேசி *';

  @override
  String get contactEmail => 'தொடர்பு மின்னஞ்சல் *';

  @override
  String get auto => 'ஆட்டோ';

  @override
  String get manual => 'மேனுவல்';

  @override
  String get both => 'இரண்டும்';

  @override
  String get lightWeight => 'இலகு';

  @override
  String get heavy => 'கனமான';

  @override
  String get car => 'கார்';

  @override
  String get van => 'வேன்';

  @override
  String get lorry => 'லாரி';

  @override
  String get bus => 'பஸ்';

  @override
  String get motorBike => 'மோட்டார் சைக்கிள்';

  @override
  String get threeWheeler => 'மூன்று சக்கர வாகனம்';

  @override
  String get suv => 'SUV';

  @override
  String get completeProfile => 'சுயவிவரத்தை முடிக்கவும்';

  @override
  String get completeProfileSubtitle =>
      'ஓட்டுநர்களை அமர்த்த உங்கள் விவரங்களை நிரப்பவும்';

  @override
  String get locationGoogleMaps => 'இடம் (Google Maps) *';

  @override
  String get vehicleType => 'வாகன வகை *';

  @override
  String get transmissionType => 'கியர் வகை *';

  @override
  String get vehicleNumber => 'வாகன எண் *';

  @override
  String get saving => 'சேமிக்கிறது...';

  @override
  String get saveProfile => 'சுயவிவரத்தை சேமி';

  @override
  String get profileCompleted =>
      '✅ சுயவிவரம் முடிந்தது! இப்போது ஓட்டுநர்களை அமர்த்தலாம்.';

  @override
  String failedToSave(String error) {
    return 'சேமிக்க தோல்வி: $error';
  }

  @override
  String get specialNoteOptional => 'சிறப்பு குறிப்பு (விருப்பம்)';

  @override
  String get saveVehicleDetails => 'வாகன விவரங்களை சேமி';

  @override
  String get vehicleDetailsSaved => '✅ வாகன விவரங்கள் சேமிக்கப்பட்டன!';

  @override
  String get myVehicle => 'எனது வாகனம்';

  @override
  String get dashboard => 'டாஷ்போர்டு';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get signOutOfAccount => 'உங்கள் கணக்கிலிருந்து வெளியேறு';

  @override
  String get addOrEditVehicle => 'வாகன விவரங்களைச் சேர் அல்லது திருத்து';

  @override
  String roleLabel(String role) {
    return 'பங்கு: $role';
  }

  @override
  String welcomeName(String name) {
    return 'வரவேற்கிறோம், $name 👤';
  }

  @override
  String welcomeNameAdmin(String name) {
    return 'வரவேற்கிறோம், $name 📊';
  }

  @override
  String get customerPortal => 'வாடிக்கையாளர் போர்டல்';

  @override
  String get adminPortal => 'நிர்வாகி போர்டல்';

  @override
  String get pleaseCompleteProfile => 'உங்கள் சுயவிவரத்தை முடிக்கவும்';

  @override
  String get addYourVehicleDetails => 'உங்கள் வாகன விவரங்களைச் சேர்க்கவும்';

  @override
  String get addVehicleDetailsBody =>
      'SafeRide ஓட்டுநரை அமர்த்துவதற்கு முன் உங்கள் வாகன மற்றும் இட விவரங்களைச் சேர்க்க வேண்டும்.\n\nSafeRide ஓட்டுநர் வந்து உங்கள் சொந்த வாகனத்தை ஓட்டுவார், எனவே உங்கள் வாகன வகை, வாகன எண் மற்றும் ஏற்றும் இடம் எங்களுக்குத் தேவை.';

  @override
  String get later => 'பின்னர்';

  @override
  String get addVehicleDetails => 'வாகன விவரங்களைச் சேர்';

  @override
  String get manageDrivers => 'ஓட்டுநர்களை நிர்வகி';

  @override
  String get manageRiders => 'பயணிகளை நிர்வகி';

  @override
  String get manageCustomers => 'வாடிக்கையாளர்களை நிர்வகி';

  @override
  String get manageRides => 'பயணங்களை நிர்வகி';

  @override
  String get drivers => 'ஓட்டுநர்கள்';

  @override
  String get riders => 'பயணிகள்';

  @override
  String get customers => 'வாடிக்கையாளர்கள்';

  @override
  String get rides => 'பயணங்கள்';

  @override
  String get pendingApproval =>
      'உங்கள் கணக்கு நிர்வாகி அனுமதிக்காக காத்திருக்கிறது.\nஉங்கள் பதிவை நிர்வாகி மதிப்பாய்வு செய்யும் வரை காத்திருங்கள்.';

  @override
  String get requestDriver => 'ஓட்டுநரைக் கோரவும்';

  @override
  String get yourDetailsAutoFilled =>
      '👤 உங்கள் விவரங்கள் (தானாக நிரப்பப்பட்டவை)';

  @override
  String get pickupLocation => 'ஏற்றும் இடம் *';

  @override
  String get enterCurrentLocation => 'உங்கள் தற்போதைய இடத்தை உள்ளிடவும்';

  @override
  String get dropLocation => 'இறக்கும் இடம் *';

  @override
  String get whereToGo => 'நீங்கள் எங்கு செல்ல வேண்டும்?';

  @override
  String get pickupTime => 'ஏற்றும் நேரம் *';

  @override
  String get specialNote => 'சிறப்பு குறிப்பு';

  @override
  String get anyInstructions => 'ஏதேனும் அறிவுறுத்தல்கள்...';

  @override
  String get requestSubmitted =>
      '✅ கோரிக்கை சமர்ப்பிக்கப்பட்டது! நிர்வாகி விரைவில் ஓட்டுநரை நியமிப்பார்.';

  @override
  String get myRides => 'எனது பயணங்கள்';

  @override
  String get myRidesTickets => 'எனது பயணங்கள் / டிக்கெட்டுகள்';

  @override
  String get myRidesTicketsRider => 'எனது பயணங்கள் / டிக்கெட்டுகள் (பயணி)';

  @override
  String get acceptTicket => '✅ டிக்கெட்டை ஏற்கவும்';

  @override
  String get cancel => '❌ ரத்து செய்';

  @override
  String get ticketAccepted => '✅ டிக்கெட் ஏற்கப்பட்டது!';

  @override
  String get ticketCancelled => '❌ டிக்கெட் ரத்து செய்யப்பட்டது';

  @override
  String get youAcceptedWaitingDriver =>
      '✅ நீங்கள் ஏற்றுக்கொண்டீர்கள் — ஓட்டுநர் ஏற்கும் வரை காத்திருக்கிறது...';

  @override
  String get youAcceptedWaitingRider =>
      '✅ நீங்கள் ஏற்றுக்கொண்டீர்கள் — பயணி ஏற்கும் வரை காத்திருக்கிறது...';

  @override
  String failed(String error) {
    return 'தோல்வி: $error';
  }

  @override
  String get fareSummary => '💵 கட்டண சுருக்கம்';

  @override
  String get baseFare => '🚦 அடிப்படை கட்டணம்';

  @override
  String get distance => '📏 தூரம்';

  @override
  String distanceKm(String km) {
    return '📏 தூரம் ($km கி.மீ.)';
  }

  @override
  String get waiting => '⏱️ காத்திருப்பு';

  @override
  String waitingMin(String min) {
    return '⏱️ காத்திருப்பு ($min நிமிடம்)';
  }

  @override
  String get totalAmount => '💰 மொத்த தொகை';

  @override
  String get totalFare => '💰 மொத்த கட்டணம்';

  @override
  String get rateTable => '💰 கட்டண அட்டவணை';

  @override
  String firstKm(String km) {
    return 'முதல் $km கி.மீ.';
  }

  @override
  String afterKm(String km) {
    return '$km கி.மீ.க்குப் பிறகு';
  }

  @override
  String get maxKmRate => 'அதிகபட்ச கி.மீ. கட்டணம்';

  @override
  String waitingFirstMin(String min) {
    return 'காத்திருப்பு (முதல் $min நிமிடம்)';
  }

  @override
  String get waitingAfter => 'காத்திருப்பு (பிறகு)';

  @override
  String get free => 'இலவசம்';

  @override
  String get waitingForAdminAssign =>
      'ஓட்டுநர் மற்றும் பயணியை நியமிக்க நிர்வாகிக்காக காத்திருக்கிறது';

  @override
  String get assignedWaitingAccept =>
      'ஓட்டுநர் மற்றும் பயணி நியமிக்கப்பட்டனர் — அவர்கள் ஏற்கும் வரை காத்திருக்கிறது';

  @override
  String get scheduledBothAccepted =>
      'திட்டமிடப்பட்டது — ஓட்டுநர் மற்றும் பயணி இருவரும் ஏற்றனர்';

  @override
  String get cancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get accepted => '✓ ஏற்கப்பட்டது';

  @override
  String get awaiting => '⏳ காத்திருக்கிறது';

  @override
  String get useThis => '✅ இதைப் பயன்படுத்து';

  @override
  String get typeLocationHint =>
      '🔍 இடத்தைத் தட்டச்சு செய்யவும் எ.கா. கொழும்பு 07';

  @override
  String get useMyCurrentLocation => '📍 எனது தற்போதைய இடத்தைப் பயன்படுத்து';

  @override
  String get mapHint =>
      '✍️ மேலே இடத்தைத் தட்டச்சு செய்து, பின்னர் ✅ இதைப் பயன்படுத்து என்பதைத் தட்டவும்.\nவிரும்பினால் GPS ஒருங்கிணைப்புகளை இணைக்க \"எனது தற்போதைய இடத்தைப் பயன்படுத்து\" என்பதைத் தட்டவும்.';

  @override
  String get couldNotFetchLocation =>
      'தற்போதைய இடத்தைப் பெற முடியவில்லை. இருப்பிட அனுமதிகளை இயக்கவும்.';

  @override
  String get pleaseTypeLocation =>
      'தயவுசெய்து ஒரு இடத்தைத் தட்டச்சு செய்யவும்.';

  @override
  String get quickSignupInfo =>
      'ஒரு நிமிடத்திற்குள் விரைவு பதிவு! உள்நுழைந்த பிறகு உங்கள் முழு சுயவிவரத்தையும் முடிக்கலாம்.';

  @override
  String get firstNameRequired => 'முதல் பெயர் தேவை';

  @override
  String get emailRequired => 'மின்னஞ்சல் தேவை';

  @override
  String get validEmail => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get nicRequired => 'தே.அ.அ. தேவை';

  @override
  String get phoneRequired => 'தொலைபேசி எண் தேவை';

  @override
  String get hotelName => 'ஹோட்டல் பெயர் *';

  @override
  String get hotelLicenseNumber => 'ஹோட்டல் உரிம எண் *';

  @override
  String get completeYourProfile => 'உங்கள் சுயவிவரத்தை முடிக்கவும்';

  @override
  String get completeProfileHelpText =>
      'ஓட்டுநர்களை அமர்த்தத் தொடங்க இந்த விவரங்களை வழங்கவும். உங்கள் வாகனத்திற்கு சரியான ஓட்டுநரை பொருத்த இது உதவும்.';

  @override
  String welcomeNameDriver(String name) {
    return 'வரவேற்கிறோம், $name 🚗';
  }

  @override
  String get driverPortal => 'ஓட்டுநர் போர்டல்';

  @override
  String get confirmedRides =>
      'உறுதிப்படுத்தப்பட்ட பயணங்கள் (இருவரும் ஏற்றனர்)';

  @override
  String get upcoming => 'வரவிருக்கும்';

  @override
  String get pendingTicketsOnly => 'நிலுவை டிக்கெட்டுகள் மட்டும்';

  @override
  String get history => 'வரலாறு';

  @override
  String get completedCancelledRides =>
      'முடிந்த மற்றும் ரத்து செய்யப்பட்ட பயணங்கள்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get myDetails => 'எனது விவரங்கள்';

  @override
  String welcomeNameRider(String name) {
    return 'வரவேற்கிறோம், $name 🙋';
  }

  @override
  String get riderPortal => 'பயணி போர்டல்';

  @override
  String get upcomingRides => 'வரவிருக்கும் பயணங்கள்';

  @override
  String get completed => 'முடிந்தவை';

  @override
  String get rideHistory => 'பயண வரலாறு';

  @override
  String get complete => 'முடிக்கவும்';

  @override
  String get addVehicleLocationDetails =>
      'ஓட்டுநர்களை அமர்த்தத் தொடங்க உங்கள் வாகன மற்றும் இட விவரங்களைச் சேர்க்கவும்.';

  @override
  String get myRidesAndFares => 'எனது பயணங்கள் & கட்டணங்கள்';

  @override
  String callUsLabel(String phone) {
    return 'எங்களை அழைக்கவும்  $phone';
  }

  @override
  String welcomePlain(String name) {
    return 'வரவேற்கிறோம், $name';
  }

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get noRideRequests => 'இன்னும் பயண கோரிக்கைகள் இல்லை';

  @override
  String get requestToGetStarted => 'தொடங்க ஓட்டுநரைக் கோரவும்.';

  @override
  String nameLabel(String name) {
    return 'பெயர்: $name';
  }

  @override
  String phoneLabel(String phone) {
    return 'தொலைபேசி: $phone';
  }

  @override
  String driverLabel(String name) {
    return '🚗 ஓட்டுநர்: $name';
  }

  @override
  String get driverCancelled => '❌ ஓட்டுநர் இந்த டிக்கெட்டை ரத்து செய்தார்';

  @override
  String get driverAccepted => '✅ ஓட்டுநர் ஏற்றார்';

  @override
  String get driverNotAccepted => '⏳ ஓட்டுநர் இன்னும் ஏற்கவில்லை';

  @override
  String riderLabel(String name) {
    return '🙋 பயணி: $name';
  }

  @override
  String get riderCancelled => '❌ பயணி இந்த டிக்கெட்டை ரத்து செய்தார்';

  @override
  String get riderAccepted => '✅ பயணி ஏற்றார்';

  @override
  String get riderNotAccepted => '⏳ பயணி இன்னும் ஏற்கவில்லை';

  @override
  String get latestRequestStatus => 'சமீபத்திய கோரிக்கை நிலை';

  @override
  String get refresh => 'புதுப்பிக்கவும்';

  @override
  String get noRideRequestsFull =>
      'இன்னும் பயண கோரிக்கைகள் இல்லை.\nதொடங்க ஓட்டுநரைக் கோரவும்.';

  @override
  String get yourLatestRequestStatus =>
      'உங்கள் சமீபத்திய கோரிக்கை நிலை இங்கே தோன்றும்.';

  @override
  String get rideInProgress => 'பயணம் நடைபெறுகிறது';

  @override
  String get rideCompleted => 'பயணம் முடிந்தது';

  @override
  String get rideDetailsViewOnly => 'பயண விவரங்கள் (பார்வை மட்டும்)';

  @override
  String rideStatus(String status) {
    return 'பயணம் $status';
  }

  @override
  String get done => 'முடிந்தது';

  @override
  String cameraError(String error) {
    return 'கேமரா பிழை: $error';
  }

  @override
  String get pickupLocationLabel => '📍 ஏற்றும் இடம்';

  @override
  String get dropLocationLabel => '📍 இறக்கும் இடம்';

  @override
  String get customerLabel => '👤 வாடிக்கையாளர்';

  @override
  String get notesLabel => '📝 குறிப்புகள்';

  @override
  String get scheduledLabel => '🕐 திட்டமிடப்பட்டது';

  @override
  String get createdLabel => '📅 உருவாக்கப்பட்டது';

  @override
  String get waitingHistory => '⏱️ காத்திருப்பு வரலாறு';

  @override
  String waitingN(String n) {
    return 'காத்திருப்பு $n';
  }

  @override
  String get totalWaiting => 'மொத்த காத்திருப்பு';

  @override
  String waitingTimer(String n) {
    return '⏳ காத்திருப்பு நேரம் $n';
  }

  @override
  String get odometerReadings => '🛣️ ஓடோமீட்டர் அளவீடுகள்';

  @override
  String get startOdometer => 'தொடக்க ஓடோமீட்டர் (தொடங்கும் முன் தேவை)';

  @override
  String get endOdometer => 'முடிவு ஓடோமீட்டர் (முடிக்கும் முன் தேவை)';

  @override
  String get startOdoPhotoDone => '📸 தொடக்க ஓடோ புகைப்படம் ✓ (விருப்பம்)';

  @override
  String get captureStartOdoPhoto => '📸 தொடக்க ஓடோ புகைப்படம் எடு (விருப்பம்)';

  @override
  String get endOdoPhotoDone => '📸 முடிவு ஓடோ புகைப்படம் ✓ (விருப்பம்)';

  @override
  String get captureEndOdoPhoto => '📸 முடிவு ஓடோ புகைப்படம் எடு (விருப்பம்)';

  @override
  String get saveForPortal => '💾 போர்ட்டலுக்கு சேமி';

  @override
  String get startRide => '▶ பயணத்தைத் தொடங்கு';

  @override
  String get waitingBtn => '⏳ காத்திருப்பு';

  @override
  String get continueRide => '▶ பயணத்தைத் தொடர்';

  @override
  String get completeRide => '✅ பயணத்தை முடிக்கவும்';

  @override
  String get rideCompletedLabel => 'பயணம் முடிந்தது';

  @override
  String get language => 'மொழி';
}
