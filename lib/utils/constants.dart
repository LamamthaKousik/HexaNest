/// Constants used throughout the Matru Mitra app
class AppConstants {
  // App Information
  static const String appName = 'Matru Mitra';
  static const String appTagline = 'Empowering ASHA Workers Digitally';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String patientsBoxName = 'patients';
  static const String settingsBoxName = 'settings';
  
  // Authentication (Dummy credentials for demo)
  static const String demoEmail = 'asha@matrumitra.com';
  static const String demoPassword = 'asha123';
  
  // Sync Simulation
  static const int syncDelaySeconds = 2;
  static const int splashDelaySeconds = 2;
  
  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minAge = 0;
  static const int maxAge = 120;
  static const int healthIdLength = 12;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Practice Mode
  static const List<String> practiceVillages = [
    'Village A',
    'Village B', 
    'Village C',
    'Rural Settlement 1',
    'Rural Settlement 2',
  ];
  
  static const List<String> practiceNames = [
    'Priya Sharma',
    'Sunita Devi',
    'Meera Singh',
    'Anita Patel',
    'Kavita Yadav',
    'Rekha Kumar',
    'Sushila Gupta',
    'Geeta Singh',
    'Kamala Devi',
    'Laxmi Sharma',
  ];
  
  // Health ID Prefixes (for demo)
  static const List<String> healthIdPrefixes = [
    'ABHA',
    'NHA',
    'UID',
  ];
  
  // Pregnancy Status Options
  static const List<String> pregnancyStatusOptions = [
    'Not Pregnant',
    'Pregnant (1st Trimester)',
    'Pregnant (2nd Trimester)', 
    'Pregnant (3rd Trimester)',
    'Lactating',
    'Post Partum',
  ];
  
  // Gender Options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
  ];
  
  // Report Types
  static const List<String> reportTypes = [
    'Total Patients',
    'Synced Patients',
    'Pending Sync',
    'Pregnant Women',
    'Children Under 5',
    'Immunization Due',
  ];
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection. Data saved locally.';
  static const String errorValidation = 'Please check your input and try again.';
  static const String errorDuplicateHealthId = 'Health ID already exists.';
  
  // Success Messages
  static const String successPatientSaved = 'Patient saved successfully!';
  static const String successDataSynced = 'All data synced successfully!';
  static const String successLogin = 'Login successful!';
  
  // Info Messages
  static const String infoOfflineMode = 'Working in offline mode. Data will sync when connected.';
  static const String infoPracticeMode = 'Practice mode enabled. Demo data loaded.';
}
