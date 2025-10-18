import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../providers/patient_provider.dart';
import '../widgets/custom_card.dart';
import 'register_patient_screen.dart';
import 'patient_list_screen.dart';
import 'reports_screen.dart';

/// Dashboard screen with main navigation and sync status
/// Shows overview of patient data and quick actions
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientProvider);
    final stats = ref.watch(patientStatsProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Sync Status Indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: syncStatus ? AppColors.synced : AppColors.pendingSync,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  syncStatus ? Icons.cloud_done : Icons.cloud_off,
                  color: AppColors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  syncStatus ? 'Synced' : 'Offline',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your patient records efficiently',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Stats
              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Stats Grid - Responsive layout
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Wide screen - 4 columns
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Total Patients',
                                value: '${stats['totalPatients'] ?? 0}',
                                icon: Icons.people,
                                color: AppColors.primaryRed,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatCard(
                                title: 'Synced',
                                value: '${stats['syncedPatients'] ?? 0}',
                                icon: Icons.cloud_done,
                                color: AppColors.synced,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Pending Sync',
                                value: '${stats['pendingSync'] ?? 0}',
                                icon: Icons.cloud_off,
                                color: AppColors.pendingSync,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatCard(
                                title: 'Pregnant Women',
                                value: '${stats['pregnantPatients'] ?? 0}',
                                icon: Icons.pregnant_woman,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Narrow screen - 2 columns
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Total Patients',
                                value: '${stats['totalPatients'] ?? 0}',
                                icon: Icons.people,
                                color: AppColors.primaryRed,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatCard(
                                title: 'Synced',
                                value: '${stats['syncedPatients'] ?? 0}',
                                icon: Icons.cloud_done,
                                color: AppColors.synced,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Pending Sync',
                                value: '${stats['pendingSync'] ?? 0}',
                                icon: Icons.cloud_off,
                                color: AppColors.pendingSync,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatCard(
                                title: 'Pregnant Women',
                                value: '${stats['pregnantPatients'] ?? 0}',
                                icon: Icons.pregnant_woman,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // Main Actions Grid
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Responsive Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      DashboardCard(
                        title: 'Register Patient',
                        subtitle: 'Add new patient record',
                        icon: Icons.person_add,
                        iconColor: AppColors.primaryRed,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPatientScreen(),
                            ),
                          );
                          // Refresh data if a patient was added
                          if (result == true) {
                            _refreshData();
                          }
                        },
                      ),
                      
                      DashboardCard(
                        title: 'Patient List',
                        subtitle: 'View all patients',
                        icon: Icons.list_alt,
                        iconColor: AppColors.primaryBlue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PatientListScreen(),
                            ),
                          );
                        },
                        trailing: (stats['totalPatients'] ?? 0) > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${stats['totalPatients']}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      
                      DashboardCard(
                        title: 'Reports',
                        subtitle: 'View statistics',
                        icon: Icons.analytics,
                        iconColor: AppColors.success,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ReportsScreen(),
                            ),
                          );
                        },
                      ),
                      
                      DashboardCard(
                        title: 'Sync Data',
                        subtitle: _isSyncing ? 'Syncing...' : 'Sync with server',
                        icon: _isSyncing ? Icons.sync : Icons.sync_alt,
                        iconColor: _isSyncing ? AppColors.warning : AppColors.info,
                        onTap: _isSyncing ? null : _syncData,
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activity (if any patients exist)
              if (patients.isNotEmpty) ...[
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.history,
                            color: AppColors.primaryRed,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last 3 Patients',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...patients.take(3).map((patient) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                              child: Text(
                                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    patient.village,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
              ],
              
              const SizedBox(height: 100), // Extra space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RegisterPatientScreen(),
            ),
          );
          // Refresh data if a patient was added
          if (result == true) {
            _refreshData();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Patient'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Simulate sync process
      final success = await ref.read(patientProvider.notifier).syncAllPatients();
      
      if (success) {
        ref.read(syncStatusProvider.notifier).state = true;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.successDataSynced),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync error. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _refreshData() async {
    // Refresh patient data
    ref.invalidate(patientProvider);
    ref.invalidate(patientStatsProvider);
    
    // Also refresh the provider state
    await ref.read(patientProvider.notifier).initializeHive();
  }
}
