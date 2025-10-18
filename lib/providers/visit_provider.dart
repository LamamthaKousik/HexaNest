import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/visit_model.dart';

/// Provider for managing visit data with offline-first approach
class VisitNotifier extends StateNotifier<List<Visit>> {
  VisitNotifier() : super([]) {
    _loadVisits();
  }

  late Box<Visit> _visitBox;
  final Uuid _uuid = const Uuid();

  /// Initialize Hive database for visits
  Future<void> initializeHive() async {
    try {
      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(VisitAdapter());
      }
      
      // Open visit box
      _visitBox = await Hive.openBox<Visit>('visits');
      _loadVisits();
    } catch (e) {
      print('Error initializing visit Hive: $e');
      state = [];
    }
  }

  /// Load visits from local storage
  void _loadVisits() {
    try {
      if (Hive.isBoxOpen('visits')) {
        state = _visitBox.values.toList();
      } else {
        state = [];
      }
    } catch (e) {
      print('Error loading visits: $e');
      state = [];
    }
  }

  /// Add a new visit
  Future<bool> addVisit(Visit visit) async {
    try {
      // Add to local storage
      await _visitBox.add(visit);
      state = [...state, visit];
      return true;
    } catch (e) {
      print('Error adding visit: $e');
      return false;
    }
  }

  /// Update an existing visit
  Future<bool> updateVisit(Visit updatedVisit) async {
    try {
      final index = state.indexWhere((v) => v.id == updatedVisit.id);
      if (index == -1) return false;

      // Update in local storage
      await _visitBox.putAt(index, updatedVisit);
      
      // Update state properly
      final updatedState = List<Visit>.from(state);
      updatedState[index] = updatedVisit;
      state = updatedState;
      return true;
    } catch (e) {
      print('Error updating visit: $e');
      return false;
    }
  }

  /// Delete a visit
  Future<bool> deleteVisit(String visitId) async {
    try {
      final index = state.indexWhere((v) => v.id == visitId);
      if (index == -1) return false;

      // Remove from local storage
      await _visitBox.deleteAt(index);
      state = state.where((v) => v.id != visitId).toList();
      return true;
    } catch (e) {
      print('Error deleting visit: $e');
      return false;
    }
  }

  /// Get visits by patient ID
  List<Visit> getVisitsByPatientId(String patientId) {
    return state.where((v) => v.patientId == patientId).toList();
  }

  /// Get visits by date range
  List<Visit> getVisitsByDateRange(DateTime startDate, DateTime endDate) {
    return state.where((v) => 
      v.visitDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
      v.visitDate.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  /// Get visits by visit type
  List<Visit> getVisitsByType(String visitType) {
    return state.where((v) => v.visitType == visitType).toList();
  }

  /// Get recent visits (last 30 days)
  List<Visit> getRecentVisits() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return state.where((v) => v.visitDate.isAfter(thirtyDaysAgo)).toList();
  }

  /// Get upcoming visits (next 7 days)
  List<Visit> getUpcomingVisits() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return state.where((v) => 
      v.nextVisitDate != null &&
      v.nextVisitDate!.isAfter(now) &&
      v.nextVisitDate!.isBefore(nextWeek)
    ).toList();
  }

  /// Generate unique ID for new visit
  String generateVisitId() {
    return _uuid.v4();
  }

  /// Get visit statistics
  Map<String, int> getVisitStatistics() {
    final totalVisits = state.length;
    final recentVisits = getRecentVisits().length;
    final upcomingVisits = getUpcomingVisits().length;
    final pregnancyVisits = getVisitsByType('Pregnancy Checkup').length;
    final immunizationVisits = getVisitsByType('Immunization').length;

    return {
      'totalVisits': totalVisits,
      'recentVisits': recentVisits,
      'upcomingVisits': upcomingVisits,
      'pregnancyVisits': pregnancyVisits,
      'immunizationVisits': immunizationVisits,
    };
  }

  /// Load practice visit data for demo mode
  Future<void> loadPracticeVisitData() async {
    if (state.isNotEmpty) return; // Don't load if data already exists

    final practiceVisits = [
      Visit(
        id: generateVisitId(),
        patientId: 'practice-patient-1',
        visitDate: DateTime.now().subtract(const Duration(days: 5)),
        symptoms: 'Mild headache, fatigue',
        bloodPressure: '120/80',
        weight: 65.0,
        height: 165.0,
        notes: 'Patient feeling better, advised rest',
        visitType: 'Routine Checkup',
        healthStatus: 'Stable',
        prescribedMedicines: 'Paracetamol 500mg',
        nextVisitDate: DateTime.now().add(const Duration(days: 14)),
        ashaWorkerNotes: 'Regular follow-up needed',
      ),
      Visit(
        id: generateVisitId(),
        patientId: 'practice-patient-2',
        visitDate: DateTime.now().subtract(const Duration(days: 2)),
        symptoms: 'Pregnancy checkup',
        bloodPressure: '110/70',
        weight: 58.0,
        height: 155.0,
        notes: 'Pregnancy progressing normally',
        visitType: 'Pregnancy Checkup',
        healthStatus: 'Healthy',
        prescribedMedicines: 'Folic acid, Iron supplements',
        nextVisitDate: DateTime.now().add(const Duration(days: 7)),
        ashaWorkerNotes: 'Monitor weight gain',
      ),
      Visit(
        id: generateVisitId(),
        patientId: 'practice-patient-3',
        visitDate: DateTime.now().subtract(const Duration(days: 1)),
        symptoms: 'Child immunization',
        bloodPressure: null,
        weight: 8.5,
        height: 70.0,
        notes: 'BCG vaccination administered',
        visitType: 'Immunization',
        healthStatus: 'Healthy',
        prescribedMedicines: null,
        nextVisitDate: DateTime.now().add(const Duration(days: 30)),
        ashaWorkerNotes: 'Next vaccination due in 1 month',
      ),
    ];

    for (final visit in practiceVisits) {
      await addVisit(visit);
    }
  }

  /// Clear all visit data
  Future<void> clearAllData() async {
    await _visitBox.clear();
    state = [];
  }
}

/// Provider for visit data
final visitProvider = StateNotifierProvider<VisitNotifier, List<Visit>>((ref) {
  return VisitNotifier();
});

/// Provider for visit statistics
final visitStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.read(visitProvider.notifier);
  return notifier.getVisitStatistics();
});

/// Provider for visits by patient ID
final visitsByPatientProvider = Provider.family<List<Visit>, String>((ref, patientId) {
  final visits = ref.watch(visitProvider);
  return visits.where((v) => v.patientId == patientId).toList();
});
