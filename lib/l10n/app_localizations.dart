import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Drink And Drive'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Drink and Drive Safe'**
  String get appTagline;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Drive Drunk.\nGet Home Safely with SafeRide.'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SafeRide connects you with verified safe drivers, riders, and partner hotels — so everyone gets home safely.'**
  String get heroSubtitle;

  /// No description provided for @letsHire.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Hire'**
  String get letsHire;

  /// No description provided for @customerLoginRegisterHint.
  ///
  /// In en, this message translates to:
  /// **'Customer login / register from here'**
  String get customerLoginRegisterHint;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @otherLogins.
  ///
  /// In en, this message translates to:
  /// **'or other logins'**
  String get otherLogins;

  /// No description provided for @loginFromHere.
  ///
  /// In en, this message translates to:
  /// **'Log in from here'**
  String get loginFromHere;

  /// No description provided for @support24_7.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support24_7;

  /// No description provided for @supportHelpText.
  ///
  /// In en, this message translates to:
  /// **'Need help hiring a driver? Call us anytime.'**
  String get supportHelpText;

  /// No description provided for @callUsAt.
  ///
  /// In en, this message translates to:
  /// **'📞 Call us at {phone}'**
  String callUsAt(String phone);

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'CALL'**
  String get call;

  /// No description provided for @howDadWorks.
  ///
  /// In en, this message translates to:
  /// **'How SafeRide Works'**
  String get howDadWorks;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Get Approved'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Get Home Safe'**
  String get step3;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @hireADriver.
  ///
  /// In en, this message translates to:
  /// **'Hire a Driver'**
  String get hireADriver;

  /// No description provided for @loginToHire.
  ///
  /// In en, this message translates to:
  /// **'Login to hire a safe driver'**
  String get loginToHire;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'{appName} - Login'**
  String loginTitle(String appName);

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @keepMeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Keep me logged in'**
  String get keepMeLoggedIn;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get newHere;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select your account type to register'**
  String get selectAccountType;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @rider.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @iWantToDrive.
  ///
  /// In en, this message translates to:
  /// **'I am a Driver'**
  String get iWantToDrive;

  /// No description provided for @iNeedARideHome.
  ///
  /// In en, this message translates to:
  /// **'I am a Rider'**
  String get iNeedARideHome;

  /// No description provided for @iOwnAVehicle.
  ///
  /// In en, this message translates to:
  /// **'I want Driver'**
  String get iOwnAVehicle;

  /// No description provided for @iAmAHotelPartner.
  ///
  /// In en, this message translates to:
  /// **'I\'m a hotel partner'**
  String get iAmAHotelPartner;

  /// No description provided for @iManageTheSystem.
  ///
  /// In en, this message translates to:
  /// **'I manage the system'**
  String get iManageTheSystem;

  /// No description provided for @selectAccountTypeForGoogle.
  ///
  /// In en, this message translates to:
  /// **'Select an account type above to continue with Google.'**
  String get selectAccountTypeForGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @registrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Registration submitted! Wait for admin approval.'**
  String get registrationSubmitted;

  /// No description provided for @adminRegistered.
  ///
  /// In en, this message translates to:
  /// **'Admin registered!'**
  String get adminRegistered;

  /// No description provided for @googleSignInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in successful!'**
  String get googleSignInSuccessful;

  /// No description provided for @pleaseSelectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Please select your account type first.'**
  String get pleaseSelectAccountType;

  /// No description provided for @adminMustUseEmail.
  ///
  /// In en, this message translates to:
  /// **'Admin accounts must be registered with email & password.'**
  String get adminMustUseEmail;

  /// No description provided for @accountCreatedCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please complete your profile to start hiring drivers.'**
  String get accountCreatedCompleteProfile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name *'**
  String get lastName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneNumber;

  /// No description provided for @nic.
  ///
  /// In en, this message translates to:
  /// **'NIC *'**
  String get nic;

  /// No description provided for @nicNumber.
  ///
  /// In en, this message translates to:
  /// **'NIC Number *'**
  String get nicNumber;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get city;

  /// No description provided for @passwordStar.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordStar;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @licenseDetails.
  ///
  /// In en, this message translates to:
  /// **'License Details'**
  String get licenseDetails;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number *'**
  String get licenseNumber;

  /// No description provided for @licenseCategory.
  ///
  /// In en, this message translates to:
  /// **'License Category'**
  String get licenseCategory;

  /// No description provided for @vehiclePreferences.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Preferences'**
  String get vehiclePreferences;

  /// No description provided for @preferredVehicle.
  ///
  /// In en, this message translates to:
  /// **'Preferred Vehicle'**
  String get preferredVehicle;

  /// No description provided for @transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// No description provided for @registerAsDriver.
  ///
  /// In en, this message translates to:
  /// **'Register as Driver'**
  String get registerAsDriver;

  /// No description provided for @registerAsRider.
  ///
  /// In en, this message translates to:
  /// **'Register as Rider'**
  String get registerAsRider;

  /// No description provided for @registerAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Register as Customer'**
  String get registerAsCustomer;

  /// No description provided for @registerAsHotel.
  ///
  /// In en, this message translates to:
  /// **'Register as Hotel'**
  String get registerAsHotel;

  /// No description provided for @registerAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Register as Admin'**
  String get registerAsAdmin;

  /// No description provided for @adminDetails.
  ///
  /// In en, this message translates to:
  /// **'Admin Details'**
  String get adminDetails;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address *'**
  String get homeAddress;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @emergencyContactName.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Name *'**
  String get emergencyContactName;

  /// No description provided for @emergencyContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Phone *'**
  String get emergencyContactPhone;

  /// No description provided for @loginDetails.
  ///
  /// In en, this message translates to:
  /// **'Login Details'**
  String get loginDetails;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address *'**
  String get address;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone *'**
  String get contactPhone;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email *'**
  String get contactEmail;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @lightWeight.
  ///
  /// In en, this message translates to:
  /// **'Light Weight'**
  String get lightWeight;

  /// No description provided for @heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavy;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @van.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// No description provided for @lorry.
  ///
  /// In en, this message translates to:
  /// **'Lorry'**
  String get lorry;

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @motorBike.
  ///
  /// In en, this message translates to:
  /// **'Motor Bike'**
  String get motorBike;

  /// No description provided for @threeWheeler.
  ///
  /// In en, this message translates to:
  /// **'Three Wheeler'**
  String get threeWheeler;

  /// No description provided for @suv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get suv;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to start hiring drivers'**
  String get completeProfileSubtitle;

  /// No description provided for @locationGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Location (Google Maps) *'**
  String get locationGoogleMaps;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type *'**
  String get vehicleType;

  /// No description provided for @transmissionType.
  ///
  /// In en, this message translates to:
  /// **'Transmission Type *'**
  String get transmissionType;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number *'**
  String get vehicleNumber;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileCompleted.
  ///
  /// In en, this message translates to:
  /// **'✅ Profile completed! You can now hire drivers.'**
  String get profileCompleted;

  /// No description provided for @completeYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Details'**
  String get completeYourDetails;

  /// No description provided for @completeYourDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your personal details to continue'**
  String get completeYourDetailsSubtitle;

  /// No description provided for @detailsRequiredInfo.
  ///
  /// In en, this message translates to:
  /// **'Your phone number and NIC are needed so drivers can contact you and we can confirm your identity.'**
  String get detailsRequiredInfo;

  /// No description provided for @detailsRequiredInfoStaff.
  ///
  /// In en, this message translates to:
  /// **'Your phone number and NIC are needed so customers/riders can contact you and we can confirm your identity.'**
  String get detailsRequiredInfoStaff;

  /// No description provided for @emailFromGoogle.
  ///
  /// In en, this message translates to:
  /// **'Email (from Google)'**
  String get emailFromGoogle;

  /// No description provided for @dateOfBirthOptional.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (Optional)'**
  String get dateOfBirthOptional;

  /// No description provided for @saveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get saveDetails;

  /// No description provided for @detailsSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Your details have been saved!'**
  String get detailsSaved;

  /// No description provided for @completeDetailsBanner.
  ///
  /// In en, this message translates to:
  /// **'Please complete your details'**
  String get completeDetailsBanner;

  /// No description provided for @completeDetailsBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Add your name, NIC and phone number before adding vehicle details.'**
  String get completeDetailsBannerBody;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill Details'**
  String get fillDetails;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @specialNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Special Note (Optional)'**
  String get specialNoteOptional;

  /// No description provided for @saveVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Vehicle Details'**
  String get saveVehicleDetails;

  /// No description provided for @vehicleDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Vehicle details saved!'**
  String get vehicleDetailsSaved;

  /// No description provided for @completeDriverProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Driver Profile'**
  String get completeDriverProfile;

  /// No description provided for @completeDriverProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your license and vehicle details to start receiving rides'**
  String get completeDriverProfileSubtitle;

  /// No description provided for @licenseFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'License Front Photo'**
  String get licenseFrontPhoto;

  /// No description provided for @licenseBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'License Back Photo'**
  String get licenseBackPhoto;

  /// No description provided for @licenseExpiryLight.
  ///
  /// In en, this message translates to:
  /// **'Light License Expiry Date'**
  String get licenseExpiryLight;

  /// No description provided for @licenseExpiryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy License Expiry Date'**
  String get licenseExpiryHeavy;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @photoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload this photo'**
  String get photoRequired;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get dateRequired;

  /// No description provided for @saveDriverProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Driver Profile'**
  String get saveDriverProfile;

  /// No description provided for @driverProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Driver profile saved!'**
  String get driverProfileSaved;

  /// No description provided for @myVehicle.
  ///
  /// In en, this message translates to:
  /// **'My Vehicle'**
  String get myVehicle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signOutOfAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutOfAccount;

  /// No description provided for @addOrEditVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add or edit vehicle details'**
  String get addOrEditVehicle;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(String role);

  /// No description provided for @welcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 👤'**
  String welcomeName(String name);

  /// No description provided for @welcomeNameAdmin.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 📊'**
  String welcomeNameAdmin(String name);

  /// No description provided for @customerPortal.
  ///
  /// In en, this message translates to:
  /// **'Customer Portal'**
  String get customerPortal;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @pleaseCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile'**
  String get pleaseCompleteProfile;

  /// No description provided for @addYourVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Your Vehicle Details'**
  String get addYourVehicleDetails;

  /// No description provided for @addVehicleDetailsBody.
  ///
  /// In en, this message translates to:
  /// **'Before you can hire a SafeRide driver you need to add your vehicle & location details.\n\nA SafeRide driver will come and drive your own vehicle, so we need your vehicle type, vehicle number and pick-up location.'**
  String get addVehicleDetailsBody;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @addVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle Details'**
  String get addVehicleDetails;

  /// No description provided for @manageDrivers.
  ///
  /// In en, this message translates to:
  /// **'Manage drivers'**
  String get manageDrivers;

  /// No description provided for @manageRiders.
  ///
  /// In en, this message translates to:
  /// **'Manage riders'**
  String get manageRiders;

  /// No description provided for @manageCustomers.
  ///
  /// In en, this message translates to:
  /// **'Manage customers'**
  String get manageCustomers;

  /// No description provided for @manageRides.
  ///
  /// In en, this message translates to:
  /// **'Manage rides'**
  String get manageRides;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @riders.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get riders;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @rides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get rides;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending admin approval.\nPlease wait for the administrator to review your registration.'**
  String get pendingApproval;

  /// No description provided for @requestDriver.
  ///
  /// In en, this message translates to:
  /// **'Request Driver'**
  String get requestDriver;

  /// No description provided for @yourDetailsAutoFilled.
  ///
  /// In en, this message translates to:
  /// **'👤 Your Details (Auto-filled)'**
  String get yourDetailsAutoFilled;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location *'**
  String get pickupLocation;

  /// No description provided for @enterCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter your current location'**
  String get enterCurrentLocation;

  /// No description provided for @dropLocation.
  ///
  /// In en, this message translates to:
  /// **'Drop Location *'**
  String get dropLocation;

  /// No description provided for @whereToGo.
  ///
  /// In en, this message translates to:
  /// **'Where do you need to go?'**
  String get whereToGo;

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup Time *'**
  String get pickupTime;

  /// No description provided for @specialNote.
  ///
  /// In en, this message translates to:
  /// **'Special Note'**
  String get specialNote;

  /// No description provided for @anyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Any instructions...'**
  String get anyInstructions;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'✅ Request submitted! Admin will assign a driver soon.'**
  String get requestSubmitted;

  /// No description provided for @myRides.
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get myRides;

  /// No description provided for @myRidesTickets.
  ///
  /// In en, this message translates to:
  /// **'My Rides / Tickets'**
  String get myRidesTickets;

  /// No description provided for @myRidesTicketsRider.
  ///
  /// In en, this message translates to:
  /// **'My Rides / Tickets (Rider)'**
  String get myRidesTicketsRider;

  /// No description provided for @acceptTicket.
  ///
  /// In en, this message translates to:
  /// **'✅ Accept Ticket'**
  String get acceptTicket;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'❌ Cancel'**
  String get cancel;

  /// No description provided for @ticketAccepted.
  ///
  /// In en, this message translates to:
  /// **'✅ Ticket accepted!'**
  String get ticketAccepted;

  /// No description provided for @ticketCancelled.
  ///
  /// In en, this message translates to:
  /// **'❌ Ticket cancelled'**
  String get ticketCancelled;

  /// No description provided for @youAcceptedWaitingDriver.
  ///
  /// In en, this message translates to:
  /// **'✅ You accepted — waiting for the driver to accept...'**
  String get youAcceptedWaitingDriver;

  /// No description provided for @youAcceptedWaitingRider.
  ///
  /// In en, this message translates to:
  /// **'✅ You accepted — waiting for the rider to accept...'**
  String get youAcceptedWaitingRider;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failed(String error);

  /// No description provided for @fareSummary.
  ///
  /// In en, this message translates to:
  /// **'💵 Fare Summary'**
  String get fareSummary;

  /// No description provided for @baseFare.
  ///
  /// In en, this message translates to:
  /// **'🚦 Base Fare'**
  String get baseFare;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'📏 Distance'**
  String get distance;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'📏 Distance ({km} km)'**
  String distanceKm(String km);

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Waiting'**
  String get waiting;

  /// No description provided for @waitingMin.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Waiting ({min} min)'**
  String waitingMin(String min);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'💰 Total Amount'**
  String get totalAmount;

  /// No description provided for @totalFare.
  ///
  /// In en, this message translates to:
  /// **'💰 Total Fare'**
  String get totalFare;

  /// No description provided for @rateTable.
  ///
  /// In en, this message translates to:
  /// **'💰 Rate Table'**
  String get rateTable;

  /// No description provided for @firstKm.
  ///
  /// In en, this message translates to:
  /// **'First {km} km'**
  String firstKm(String km);

  /// No description provided for @afterKm.
  ///
  /// In en, this message translates to:
  /// **'After {km} km'**
  String afterKm(String km);

  /// No description provided for @maxKmRate.
  ///
  /// In en, this message translates to:
  /// **'Max KM Rate'**
  String get maxKmRate;

  /// No description provided for @waitingFirstMin.
  ///
  /// In en, this message translates to:
  /// **'Waiting (1st {min} min)'**
  String waitingFirstMin(String min);

  /// No description provided for @waitingAfter.
  ///
  /// In en, this message translates to:
  /// **'Waiting (after)'**
  String get waitingAfter;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @waitingForAdminAssign.
  ///
  /// In en, this message translates to:
  /// **'Waiting for admin to assign driver & rider'**
  String get waitingForAdminAssign;

  /// No description provided for @assignedWaitingAccept.
  ///
  /// In en, this message translates to:
  /// **'Driver & rider assigned — waiting for them to accept'**
  String get assignedWaitingAccept;

  /// No description provided for @scheduledBothAccepted.
  ///
  /// In en, this message translates to:
  /// **'Scheduled — both driver & rider accepted'**
  String get scheduledBothAccepted;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'✓ Accepted'**
  String get accepted;

  /// No description provided for @awaiting.
  ///
  /// In en, this message translates to:
  /// **'⏳ Awaiting'**
  String get awaiting;

  /// No description provided for @useThis.
  ///
  /// In en, this message translates to:
  /// **'✅ Use This'**
  String get useThis;

  /// No description provided for @typeLocationHint.
  ///
  /// In en, this message translates to:
  /// **'🔍 Type location e.g. Colombo 07'**
  String get typeLocationHint;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'📍 Use My Current Location'**
  String get useMyCurrentLocation;

  /// No description provided for @mapHint.
  ///
  /// In en, this message translates to:
  /// **'✍️ Type the location above, then tap ✅ Use This.\nOptionally tap \"Use My Current Location\" to attach GPS coordinates.'**
  String get mapHint;

  /// No description provided for @couldNotFetchLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch current location. Enable location permissions.'**
  String get couldNotFetchLocation;

  /// No description provided for @pleaseTypeLocation.
  ///
  /// In en, this message translates to:
  /// **'Please type a location.'**
  String get pleaseTypeLocation;

  /// No description provided for @quickSignupInfo.
  ///
  /// In en, this message translates to:
  /// **'Quick signup in under a minute! You can complete your full profile after logging in.'**
  String get quickSignupInfo;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmail;

  /// No description provided for @nicRequired.
  ///
  /// In en, this message translates to:
  /// **'NIC is required'**
  String get nicRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @hotelName.
  ///
  /// In en, this message translates to:
  /// **'Hotel Name *'**
  String get hotelName;

  /// No description provided for @hotelLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Hotel License Number *'**
  String get hotelLicenseNumber;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @completeProfileHelpText.
  ///
  /// In en, this message translates to:
  /// **'Please provide these details to start hiring drivers. This helps us match you with the right driver for your vehicle.'**
  String get completeProfileHelpText;

  /// No description provided for @welcomeNameDriver.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 🚗'**
  String welcomeNameDriver(String name);

  /// No description provided for @driverPortal.
  ///
  /// In en, this message translates to:
  /// **'Driver Portal'**
  String get driverPortal;

  /// No description provided for @confirmedRides.
  ///
  /// In en, this message translates to:
  /// **'Confirmed rides (both accepted)'**
  String get confirmedRides;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @pendingTicketsOnly.
  ///
  /// In en, this message translates to:
  /// **'Pending tickets only'**
  String get pendingTicketsOnly;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @completedCancelledRides.
  ///
  /// In en, this message translates to:
  /// **'Completed & cancelled rides'**
  String get completedCancelledRides;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myDetails.
  ///
  /// In en, this message translates to:
  /// **'My details'**
  String get myDetails;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @welcomeNameRider.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 🙋'**
  String welcomeNameRider(String name);

  /// No description provided for @riderPortal.
  ///
  /// In en, this message translates to:
  /// **'Rider Portal'**
  String get riderPortal;

  /// No description provided for @upcomingRides.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Rides'**
  String get upcomingRides;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride history'**
  String get rideHistory;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @addVehicleLocationDetails.
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle & location details to start hiring drivers.'**
  String get addVehicleLocationDetails;

  /// No description provided for @myRidesAndFares.
  ///
  /// In en, this message translates to:
  /// **'My Rides & Fares'**
  String get myRidesAndFares;

  /// No description provided for @callUsLabel.
  ///
  /// In en, this message translates to:
  /// **'Call Us  {phone}'**
  String callUsLabel(String phone);

  /// No description provided for @welcomePlain.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomePlain(String name);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noRideRequests.
  ///
  /// In en, this message translates to:
  /// **'No ride requests yet'**
  String get noRideRequests;

  /// No description provided for @requestToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Request a driver to get started.'**
  String get requestToGetStarted;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String nameLabel(String name);

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(String phone);

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'🚗 Driver: {name}'**
  String driverLabel(String name);

  /// No description provided for @driverCancelled.
  ///
  /// In en, this message translates to:
  /// **'❌ Driver cancelled this ticket'**
  String get driverCancelled;

  /// No description provided for @driverAccepted.
  ///
  /// In en, this message translates to:
  /// **'✅ Driver accepted'**
  String get driverAccepted;

  /// No description provided for @driverNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'⏳ Driver has not accepted yet'**
  String get driverNotAccepted;

  /// No description provided for @riderLabel.
  ///
  /// In en, this message translates to:
  /// **'🙋 Rider: {name}'**
  String riderLabel(String name);

  /// No description provided for @riderCancelled.
  ///
  /// In en, this message translates to:
  /// **'❌ Rider cancelled this ticket'**
  String get riderCancelled;

  /// No description provided for @riderAccepted.
  ///
  /// In en, this message translates to:
  /// **'✅ Rider accepted'**
  String get riderAccepted;

  /// No description provided for @riderNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'⏳ Rider has not accepted yet'**
  String get riderNotAccepted;

  /// No description provided for @latestRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Latest Request Status'**
  String get latestRequestStatus;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noRideRequestsFull.
  ///
  /// In en, this message translates to:
  /// **'No ride requests yet.\nRequest a driver to get started.'**
  String get noRideRequestsFull;

  /// No description provided for @yourLatestRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Your latest request status will appear here.'**
  String get yourLatestRequestStatus;

  /// No description provided for @rideInProgress.
  ///
  /// In en, this message translates to:
  /// **'Ride in progress'**
  String get rideInProgress;

  /// No description provided for @rideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ride completed'**
  String get rideCompleted;

  /// No description provided for @rideDetailsViewOnly.
  ///
  /// In en, this message translates to:
  /// **'Ride Details (View Only)'**
  String get rideDetailsViewOnly;

  /// No description provided for @rideStatus.
  ///
  /// In en, this message translates to:
  /// **'Ride {status}'**
  String rideStatus(String status);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(String error);

  /// No description provided for @pickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'📍 Pickup Location'**
  String get pickupLocationLabel;

  /// No description provided for @dropLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'📍 Drop Location'**
  String get dropLocationLabel;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'👤 Customer'**
  String get customerLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'📝 Notes'**
  String get notesLabel;

  /// No description provided for @scheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'🕐 Scheduled'**
  String get scheduledLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'📅 Created'**
  String get createdLabel;

  /// No description provided for @waitingHistory.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Waiting History'**
  String get waitingHistory;

  /// No description provided for @waitingN.
  ///
  /// In en, this message translates to:
  /// **'Waiting {n}'**
  String waitingN(String n);

  /// No description provided for @totalWaiting.
  ///
  /// In en, this message translates to:
  /// **'Total Waiting'**
  String get totalWaiting;

  /// No description provided for @waitingTimer.
  ///
  /// In en, this message translates to:
  /// **'⏳ Waiting Timer {n}'**
  String waitingTimer(String n);

  /// No description provided for @odometerReadings.
  ///
  /// In en, this message translates to:
  /// **'🛣️ Odometer Readings'**
  String get odometerReadings;

  /// No description provided for @startOdometer.
  ///
  /// In en, this message translates to:
  /// **'Start Odometer (required before Start)'**
  String get startOdometer;

  /// No description provided for @endOdometer.
  ///
  /// In en, this message translates to:
  /// **'End Odometer (required before Complete)'**
  String get endOdometer;

  /// No description provided for @startOdoPhotoDone.
  ///
  /// In en, this message translates to:
  /// **'📸 Start Odo Photo ✓ (optional)'**
  String get startOdoPhotoDone;

  /// No description provided for @captureStartOdoPhoto.
  ///
  /// In en, this message translates to:
  /// **'📸 Capture Start Odo Photo (optional)'**
  String get captureStartOdoPhoto;

  /// No description provided for @endOdoPhotoDone.
  ///
  /// In en, this message translates to:
  /// **'📸 End Odo Photo ✓ (optional)'**
  String get endOdoPhotoDone;

  /// No description provided for @captureEndOdoPhoto.
  ///
  /// In en, this message translates to:
  /// **'📸 Capture End Odo Photo (optional)'**
  String get captureEndOdoPhoto;

  /// No description provided for @saveForPortal.
  ///
  /// In en, this message translates to:
  /// **'💾 Save for Portal'**
  String get saveForPortal;

  /// No description provided for @startRide.
  ///
  /// In en, this message translates to:
  /// **'▶ Start Ride'**
  String get startRide;

  /// No description provided for @waitingBtn.
  ///
  /// In en, this message translates to:
  /// **'⏳ Waiting'**
  String get waitingBtn;

  /// No description provided for @continueRide.
  ///
  /// In en, this message translates to:
  /// **'▶ Continue Ride'**
  String get continueRide;

  /// No description provided for @completeRide.
  ///
  /// In en, this message translates to:
  /// **'✅ Complete Ride'**
  String get completeRide;

  /// No description provided for @rideCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get rideCompletedLabel;

  /// No description provided for @myEarnings.
  ///
  /// In en, this message translates to:
  /// **'My Earnings'**
  String get myEarnings;

  /// No description provided for @ridesCount.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get ridesCount;

  /// No description provided for @earningsShareLabel.
  ///
  /// In en, this message translates to:
  /// **'{pct}% share'**
  String earningsShareLabel(String pct);

  /// No description provided for @earningsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load earnings'**
  String get earningsLoadFailed;

  /// No description provided for @iAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms & Conditions'**
  String get iAgreeToTerms;

  /// No description provided for @termsRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions to continue'**
  String get termsRequiredError;

  /// No description provided for @viewFullTerms.
  ///
  /// In en, this message translates to:
  /// **'View full terms'**
  String get viewFullTerms;

  /// No description provided for @termsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String termsVersionLabel(String version);

  /// No description provided for @termsUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String termsUpdatedLabel(String date);

  /// No description provided for @termsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the Terms & Conditions'**
  String get termsLoadFailed;

  /// No description provided for @termsAcceptanceRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions required'**
  String get termsAcceptanceRequiredTitle;

  /// No description provided for @termsAcceptanceRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Please review and accept the Terms & Conditions to continue using the app.'**
  String get termsAcceptanceRequiredBody;

  /// No description provided for @iAgreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'I agree & continue'**
  String get iAgreeAndContinue;

  /// No description provided for @termsUpdatedPleaseReview.
  ///
  /// In en, this message translates to:
  /// **'The Terms & Conditions were updated. Please review the latest version and accept it.'**
  String get termsUpdatedPleaseReview;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
