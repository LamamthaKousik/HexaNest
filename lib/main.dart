import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'models/patient_model.dart';
import 'models/visit_model.dart';

/// Main entry point for Matru Mitra app
/// Initializes Hive database and sets up the app theme
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters (guarded)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PatientAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(VisitAdapter());
  }

  runApp(const ProviderScope(child: MatruMitraApp()));
}

/// Main app widget with Material 3 design and custom theme
class MatruMitraApp extends StatelessWidget {
  const MatruMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
