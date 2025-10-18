import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrumitra/models/patient_model.dart';
import 'package:matrumitra/providers/patient_provider.dart';

void main() {
  group('Patient Storage Tests', () {
    testWidgets('Patient data should be stored and updated locally', (WidgetTester tester) async {
      // Create a provider container
      final container = ProviderContainer();
      
      // Get the patient notifier
      final patientNotifier = container.read(patientProvider.notifier);
      
      // Initialize Hive
      await patientNotifier.initializeHive();
      
      // Create a test patient
      final testPatient = Patient(
        id: 'test-id-1',
        name: 'Test Patient',
        age: 25,
        gender: 'Female',
        village: 'Test Village',
        healthId: 'TEST123456789',
        pregnancyStatus: 'Not Pregnant',
        lastVisitDate: DateTime.now(),
        registrationDate: DateTime.now(),
        isSynced: false,
      );
      
      // Add patient
      final addResult = await patientNotifier.addPatient(testPatient);
      expect(addResult, true);
      
      // Verify patient was added
      final patients = container.read(patientProvider);
      expect(patients.length, 1);
      expect(patients.first.name, 'Test Patient');
      expect(patients.first.isSynced, false);
      
      // Update patient
      final updatedPatient = testPatient.copyWith(
        name: 'Updated Patient',
        isSynced: true,
      );
      
      final updateResult = await patientNotifier.updatePatient(updatedPatient);
      expect(updateResult, true);
      
      // Verify patient was updated
      final updatedPatients = container.read(patientProvider);
      expect(updatedPatients.length, 1);
      expect(updatedPatients.first.name, 'Updated Patient');
      expect(updatedPatients.first.isSynced, true);
      
      // Test sync functionality
      final syncResult = await patientNotifier.syncAllPatients();
      expect(syncResult, true);
      
      // Verify all patients are synced
      final syncedPatients = container.read(patientProvider);
      expect(syncedPatients.every((p) => p.isSynced), true);
      
      // Clean up
      container.dispose();
    });
    
    testWidgets('Duplicate Health ID should be rejected', (WidgetTester tester) async {
      final container = ProviderContainer();
      final patientNotifier = container.read(patientProvider.notifier);
      
      await patientNotifier.initializeHive();
      
      // Create first patient
      final patient1 = Patient(
        id: 'test-id-1',
        name: 'Patient 1',
        age: 25,
        gender: 'Female',
        village: 'Village 1',
        healthId: 'DUPLICATE123',
        pregnancyStatus: 'Not Pregnant',
        lastVisitDate: DateTime.now(),
        registrationDate: DateTime.now(),
        isSynced: false,
      );
      
      // Create second patient with same Health ID
      final patient2 = Patient(
        id: 'test-id-2',
        name: 'Patient 2',
        age: 30,
        gender: 'Male',
        village: 'Village 2',
        healthId: 'DUPLICATE123', // Same Health ID
        pregnancyStatus: 'Not Pregnant',
        lastVisitDate: DateTime.now(),
        registrationDate: DateTime.now(),
        isSynced: false,
      );
      
      // Add first patient
      final addResult1 = await patientNotifier.addPatient(patient1);
      expect(addResult1, true);
      
      // Try to add second patient with duplicate Health ID
      final addResult2 = await patientNotifier.addPatient(patient2);
      expect(addResult2, false); // Should be rejected
      
      // Verify only one patient exists
      final patients = container.read(patientProvider);
      expect(patients.length, 1);
      expect(patients.first.name, 'Patient 1');
      
      container.dispose();
    });
  });
}
