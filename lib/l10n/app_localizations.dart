import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
    Locale('ru')
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDate;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics on'**
  String get biometrics;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @errorPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password'**
  String get errorPassword;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecords;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get testResult;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MedTrack'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Your medical records. Anytime.\nAnywhere.'**
  String get appSlogan;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerDoctor.
  ///
  /// In en, this message translates to:
  /// **'Register as a Doctor'**
  String get registerDoctor;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get tests;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'PATIENT'**
  String get patient;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'AGE'**
  String get age;

  /// No description provided for @blood.
  ///
  /// In en, this message translates to:
  /// **'BLOOD'**
  String get blood;

  /// No description provided for @idnp.
  ///
  /// In en, this message translates to:
  /// **'IDNP'**
  String get idnp;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivity;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get notLoggedIn;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your records'**
  String get signInSubtitle;

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

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordMin;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Biometrics'**
  String get biometricLogin;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Scan fingerprint to login'**
  String get biometricReason;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric not available'**
  String get biometricNotAvailable;

  /// No description provided for @biometricError.
  ///
  /// In en, this message translates to:
  /// **'Biometric error'**
  String get biometricError;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first'**
  String get enterEmailFirst;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get resetEmailSent;

  /// No description provided for @resetEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send email'**
  String get resetEmailFailed;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorLoadUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user data'**
  String get errorLoadUser;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpSubtitle;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @enterIdnp.
  ///
  /// In en, this message translates to:
  /// **'Enter IDNP'**
  String get enterIdnp;

  /// No description provided for @idnpLength.
  ///
  /// In en, this message translates to:
  /// **'IDNP must be 13 digits'**
  String get idnpLength;

  /// No description provided for @onlyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Only numbers allowed'**
  String get onlyNumbers;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocation;

  /// No description provided for @bloodTypeOptional.
  ///
  /// In en, this message translates to:
  /// **'Blood Type (optional)'**
  String get bloodTypeOptional;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @confirmData.
  ///
  /// In en, this message translates to:
  /// **'Confirm Data'**
  String get confirmData;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @isCorrect.
  ///
  /// In en, this message translates to:
  /// **'Is this correct?'**
  String get isCorrect;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @doctorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Doctor Registration'**
  String get doctorRegistration;

  /// No description provided for @professionalAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your professional account'**
  String get professionalAccount;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Dr. Full Name'**
  String get doctorName;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get license;

  /// No description provided for @enterSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Enter specialization'**
  String get enterSpecialization;

  /// No description provided for @enterLicense.
  ///
  /// In en, this message translates to:
  /// **'Enter license'**
  String get enterLicense;

  /// No description provided for @createDoctorAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Doctor Account'**
  String get createDoctorAccount;

  /// No description provided for @doctorCreated.
  ///
  /// In en, this message translates to:
  /// **'Doctor account created'**
  String get doctorCreated;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get accountCreatedTitle;

  /// No description provided for @accountCreatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully created.'**
  String get accountCreatedSubtitle;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @testResults.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get testResults;

  /// No description provided for @noTests.
  ///
  /// In en, this message translates to:
  /// **'No tests found'**
  String get noTests;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @doctorPortal.
  ///
  /// In en, this message translates to:
  /// **'Doctor Portal'**
  String get doctorPortal;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @patientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Patient not found'**
  String get patientNotFound;

  /// No description provided for @searchPatientFirst.
  ///
  /// In en, this message translates to:
  /// **'Search patient first'**
  String get searchPatientFirst;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'{type} uploaded successfully'**
  String uploadSuccess(Object type);

  /// No description provided for @recentPatients.
  ///
  /// In en, this message translates to:
  /// **'Recent Patients'**
  String get recentPatients;

  /// No description provided for @chooseDocType.
  ///
  /// In en, this message translates to:
  /// **'Choose Document Type'**
  String get chooseDocType;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @biometricsOn.
  ///
  /// In en, this message translates to:
  /// **'Biometrics on'**
  String get biometricsOn;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @writeManually.
  ///
  /// In en, this message translates to:
  /// **'Write manually'**
  String get writeManually;

  /// No description provided for @attachDocument.
  ///
  /// In en, this message translates to:
  /// **'Attach document'**
  String get attachDocument;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get medicationName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get success;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification email to:'**
  String get verifyEmailMessage;

  /// No description provided for @verificationSentAgain.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again'**
  String get verificationSentAgain;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @checkEmailSpam.
  ///
  /// In en, this message translates to:
  /// **'Check your email (Spam/Promotions too)'**
  String get checkEmailSpam;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @iVerified.
  ///
  /// In en, this message translates to:
  /// **'I verified'**
  String get iVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email is not verified yet'**
  String get emailNotVerified;

  /// No description provided for @activityDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'New diagnosis added'**
  String get activityDiagnosis;

  /// No description provided for @activityTest.
  ///
  /// In en, this message translates to:
  /// **'New test result added'**
  String get activityTest;

  /// No description provided for @activityMedication.
  ///
  /// In en, this message translates to:
  /// **'New medication added'**
  String get activityMedication;

  /// No description provided for @activityFile.
  ///
  /// In en, this message translates to:
  /// **'New file added'**
  String get activityFile;

  /// No description provided for @loginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get loginFirst;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ro', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ro': return AppLocalizationsRo();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
