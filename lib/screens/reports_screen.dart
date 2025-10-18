import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../providers/patient_provider.dart';
import '../widgets/custom_card.dart';

/// Reports screen showing statistics and charts
/// Displays patient data insights and sync status
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(patientStatsProvider);
    final patients = ref.watch(patientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(patientStatsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.analytics,
                    color: AppColors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Health Data Analytics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comprehensive insights into patient data',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Key Statistics
            Text(
              'Key Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  title: 'Total Patients',
                  value: '${stats['totalPatients'] ?? 0}',
                  icon: Icons.people,
                  color: AppColors.primaryRed,
                  subtitle: 'Registered patients',
                ),
                
                StatCard(
                  title: 'Synced Data',
                  value: '${stats['syncedPatients'] ?? 0}',
                  icon: Icons.cloud_done,
                  color: AppColors.synced,
                  subtitle: '${stats['totalPatients']! > 0 ? ((stats['syncedPatients']! / stats['totalPatients']! * 100).round()) : 0}% synced',
                ),
                
                StatCard(
                  title: 'Pending Sync',
                  value: '${stats['pendingSync'] ?? 0}',
                  icon: Icons.cloud_off,
                  color: AppColors.pendingSync,
                  subtitle: 'Awaiting sync',
                ),
                
                StatCard(
                  title: 'Pregnant Women',
                  value: '${stats['pregnantPatients'] ?? 0}',
                  icon: Icons.pregnant_woman,
                  color: AppColors.primaryBlue,
                  subtitle: 'Maternal care',
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Sync Status Chart
            if (stats['totalPatients']! > 0) ...[
              Text(
                'Sync Status Distribution',
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
                    Text(
                      'Data Synchronization',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: stats['syncedPatients']!.toDouble(),
                              title: 'Synced\n${stats['syncedPatients']}',
                              color: AppColors.synced,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: stats['pendingSync']!.toDouble(),
                              title: 'Pending\n${stats['pendingSync']}',
                              color: AppColors.pendingSync,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
            
            // Pregnancy Status Chart
            if (stats['pregnantPatients']! > 0) ...[
              Text(
                'Pregnancy Status Distribution',
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
                    Text(
                      'Maternal Health Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(patients),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  );
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Pregnant', style: style);
                                    case 1:
                                      return const Text('Lactating', style: style);
                                    case 2:
                                      return const Text('Post Partum', style: style);
                                    case 3:
                                      return const Text('Not Pregnant', style: style);
                                    default:
                                      return const Text('', style: style);
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _getPregnancyBarGroups(patients),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
            
            // Village Distribution
            if (patients.isNotEmpty) ...[
              Text(
                'Village Distribution',
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
                    Text(
                      'Patients by Village',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._getVillageDistribution(patients).entries.map((entry) {
                      final percentage = (entry.value / patients.length * 100).round();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.value} patients',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: entry.value / patients.length,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryRed,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percentage%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Summary Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.summarize,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This report shows the current status of your patient database. '
                    '${stats['totalPatients']} patients are registered, with '
                    '${stats['syncedPatients']} successfully synced to the server. '
                    '${stats['pregnantPatients']} patients require maternal care attention.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<dynamic> patients) {
    final pregnancyCounts = _getPregnancyCounts(patients);
    final maxCount = pregnancyCounts.values.fold(0, (a, b) => a > b ? a : b);
    return (maxCount + 1).toDouble();
  }

  Map<String, int> _getPregnancyCounts(List<dynamic> patients) {
    final counts = <String, int>{
      'Pregnant': 0,
      'Lactating': 0,
      'Post Partum': 0,
      'Not Pregnant': 0,
    };

    for (final patient in patients) {
      final status = patient.pregnancyStatus.toLowerCase();
      if (status.contains('pregnant')) {
        counts['Pregnant'] = counts['Pregnant']! + 1;
      } else if (status.contains('lactating')) {
        counts['Lactating'] = counts['Lactating']! + 1;
      } else if (status.contains('post partum')) {
        counts['Post Partum'] = counts['Post Partum']! + 1;
      } else {
        counts['Not Pregnant'] = counts['Not Pregnant']! + 1;
      }
    }

    return counts;
  }

  List<BarChartGroupData> _getPregnancyBarGroups(List<dynamic> patients) {
    final counts = _getPregnancyCounts(patients);
    
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: counts['Pregnant']!.toDouble(),
            color: AppColors.primaryRed,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: counts['Lactating']!.toDouble(),
            color: AppColors.primaryBlue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: counts['Post Partum']!.toDouble(),
            color: AppColors.success,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: counts['Not Pregnant']!.toDouble(),
            color: AppColors.warning,
            width: 20,
          ),
        ],
      ),
    ];
  }

  Map<String, int> _getVillageDistribution(List<dynamic> patients) {
    final distribution = <String, int>{};
    
    for (final patient in patients) {
      distribution[patient.village] = (distribution[patient.village] ?? 0) + 1;
    }
    
    // Sort by count descending
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries);
  }
}
