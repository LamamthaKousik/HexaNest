import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/patient_model.dart';
import '../utils/constants.dart';

/// Provider for managing patient data with offline-first approach
class PatientNotifier extends StateNotifier<List<Patient>> {
  PatientNotifier() : super([]) {
    _loadPatients();
  }

  late Box<Patient> _patientBox;
  final Uuid _uuid = const Uuid();

  /// Initialize Hive database
  Future<void> initializeHive() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PatientAdapter());
      }
      
      // Open patient box
      _patientBox = await Hive.openBox<Patient>(AppConstants.patientsBoxName);
      _loadPatients();
    } catch (e) {
      print('Error initializing Hive: $e');
      // Initialize with empty state if Hive fails
      state = [];
    }
  }

  /// Load patients from local storage
  void _loadPatients() {
    try {
      if (Hive.isBoxOpen(AppConstants.patientsBoxName)) {
        state = _patientBox.values.toList();
      } else {
        state = [];
      }
    } catch (e) {
      print('Error loading patients: $e');
      state = [];
    }
  }

  /// Add a new patient
  Future<bool> addPatient(Patient patient) async {
    try {
      // Check for duplicate Health ID
      if (state.any((p) => p.healthId == patient.healthId)) {
        return false; // Duplicate Health ID
      }

      // Add to local storage
      await _patientBox.add(patient);
      state = [...state, patient];
      return true;
    } catch (e) {
      print('Error adding patient: $e');
      return false;
    }
  }

  /// Update an existing patient
  Future<bool> updatePatient(Patient updatedPatient) async {
    try {
      final index = state.indexWhere((p) => p.id == updatedPatient.id);
      if (index == -1) return false;

      // Update in local storage
      await _patientBox.putAt(index, updatedPatient);
      
      // Update state properly
      final updatedState = List<Patient>.from(state);
      updatedState[index] = updatedPatient;
      state = updatedState;
      return true;
    } catch (e) {
      print('Error updating patient: $e');
      return false;
    }
  }

  /// Delete a patient
  Future<bool> deletePatient(String patientId) async {
    try {
      final index = state.indexWhere((p) => p.id == patientId);
      if (index == -1) return false;

      // Remove from local storage
      await _patientBox.deleteAt(index);
      state = state.where((p) => p.id != patientId).toList();
      return true;
    } catch (e) {
      print('Error deleting patient: $e');
      return false;
    }
  }

  /// Get patient by ID
  Patient? getPatientById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get patients by sync status
  List<Patient> getPatientsBySyncStatus(bool isSynced) {
    return state.where((p) => p.isSynced == isSynced).toList();
  }

  /// Get patients by village
  List<Patient> getPatientsByVillage(String village) {
    return state.where((p) => p.village == village).toList();
  }

  /// Get patients by pregnancy status
  List<Patient> getPregnantPatients() {
    return state.where((p) => 
      p.pregnancyStatus.toLowerCase().contains('pregnant') ||
      p.pregnancyStatus.toLowerCase().contains('lactating') ||
      p.pregnancyStatus.toLowerCase().contains('post partum')
    ).toList();
  }

  /// Simulate sync process - marks all unsynced patients as synced
  Future<bool> syncAllPatients() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: AppConstants.syncDelaySeconds));
      
      // Update all unsynced patients
      final updatedState = List<Patient>.from(state);
      
      for (int i = 0; i < updatedState.length; i++) {
        if (!updatedState[i].isSynced) {
          updatedState[i] = updatedState[i].copyWith(isSynced: true);
          // Update in local storage
          await _patientBox.putAt(i, updatedState[i]);
        }
      }
      
      // Update state
      state = updatedState;
      return true;
    } catch (e) {
      print('Error syncing patients: $e');
      return false;
    }
  }

  /// Generate unique ID for new patient
  String generatePatientId() {
    return _uuid.v4();
  }

  /// Load practice data for demo mode
  Future<void> loadPracticeData() async {
    if (state.isNotEmpty) return; // Don't load if data already exists

    final practicePatients = [
      Patient(
        id: generatePatientId(),
        name: 'Priya Sharma',
        age: 28,
        gender: 'Female',
        village: 'Village A',
        healthId: 'ABHA123456789',
        pregnancyStatus: 'Pregnant (2nd Trimester)',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 7)),
        registrationDate: DateTime.now().subtract(const Duration(days: 30)),
        isSynced: true,
        phoneNumber: '9876543210',
        address: 'House No. 123, Village A',
        notes: 'Regular checkup needed',
      ),
      Patient(
        id: generatePatientId(),
        name: 'Sunita Devi',
        age: 32,
        gender: 'Female',
        village: 'Village B',
        healthId: 'ABHA987654321',
        pregnancyStatus: 'Lactating',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 3)),
        registrationDate: DateTime.now().subtract(const Duration(days: 15)),
        isSynced: false,
        phoneNumber: '9876543211',
        address: 'House No. 456, Village B',
        notes: 'Post-delivery care',
      ),
      Patient(
        id: generatePatientId(),
        name: 'Meera Singh',
        age: 25,
        gender: 'Female',
        village: 'Village A',
        healthId: 'ABHA456789123',
        pregnancyStatus: 'Not Pregnant',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
        registrationDate: DateTime.now().subtract(const Duration(days: 45)),
        isSynced: true,
        phoneNumber: '9876543212',
        address: 'House No. 789, Village A',
        notes: 'Family planning consultation',
      ),
      Patient(
        id: generatePatientId(),
        name: 'Anita Patel',
        age: 30,
        gender: 'Female',
        village: 'Village C',
        healthId: 'ABHA789123456',
        pregnancyStatus: 'Pregnant (3rd Trimester)',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 1)),
        registrationDate: DateTime.now().subtract(const Duration(days: 20)),
        isSynced: false,
        phoneNumber: '9876543213',
        address: 'House No. 321, Village C',
        notes: 'High-risk pregnancy monitoring',
      ),
      Patient(
        id: generatePatientId(),
        name: 'Kavita Yadav',
        age: 35,
        gender: 'Female',
        village: 'Rural Settlement 1',
        healthId: 'ABHA321654987',
        pregnancyStatus: 'Post Partum',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 5)),
        registrationDate: DateTime.now().subtract(const Duration(days: 10)),
        isSynced: true,
        phoneNumber: '9876543214',
        address: 'House No. 654, Rural Settlement 1',
        notes: 'Newborn care guidance',
      ),
    ];

    for (final patient in practicePatients) {
      await addPatient(patient);
    }
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    await _patientBox.clear();
    state = [];
  }

  /// Get statistics for reports
  Map<String, int> getStatistics() {
    final totalPatients = state.length;
    final syncedPatients = getPatientsBySyncStatus(true).length;
    final pendingSync = getPatientsBySyncStatus(false).length;
    final pregnantPatients = getPregnantPatients().length;
    final childrenUnder5 = state.where((p) => p.age < 5).length;

    return {
      'totalPatients': totalPatients,
      'syncedPatients': syncedPatients,
      'pendingSync': pendingSync,
      'pregnantPatients': pregnantPatients,
      'childrenUnder5': childrenUnder5,
    };
  }
}

/// Provider for patient data
final patientProvider = StateNotifierProvider<PatientNotifier, List<Patient>>((ref) {
  return PatientNotifier();
});

/// Provider for patient statistics
final patientStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.read(patientProvider.notifier);
  return notifier.getStatistics();
});

/// Provider for sync status
final syncStatusProvider = StateProvider<bool>((ref) => false);
