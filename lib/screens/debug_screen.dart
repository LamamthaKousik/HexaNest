import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';
import '../utils/colors.dart';

/// Debug screen to help identify issues with patient data
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientProvider);
    final stats = ref.watch(patientStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Data Debug',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total Patients: ${stats['totalPatients'] ?? 0}'),
                    Text('Synced Patients: ${stats['syncedPatients'] ?? 0}'),
                    Text('Pending Sync: ${stats['pendingSync'] ?? 0}'),
                    Text('Pregnant Women: ${stats['pregnantPatients'] ?? 0}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient List (${patients.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (patients.isEmpty)
                      const Text('No patients found')
                    else
                      ...patients.map((patient) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                              child: Text(
                                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.name.isNotEmpty ? patient.name : 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${patient.village} - ${patient.healthId}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: patient.isSynced ? AppColors.synced : AppColors.pendingSync,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                patient.isSynced ? 'Synced' : 'Pending',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(patientProvider.notifier).initializeHive();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hive initialized successfully'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error initializing Hive: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    child: const Text('Initialize Hive'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(patientProvider.notifier).loadPracticeData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Practice data loaded'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error loading practice data: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    child: const Text('Load Practice Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
