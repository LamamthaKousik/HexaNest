import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/visit_model.dart';
import '../providers/patient_provider.dart';
import '../providers/visit_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_card.dart';
import 'visit_records_screen.dart';
import 'register_patient_screen.dart';

/// Patient details screen showing comprehensive patient information
/// Includes visit history, health indicators, and quick actions
class PatientDetailsScreen extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  @override
  ConsumerState<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Initialize providers if needed
      await ref.read(visitProvider.notifier).initializeHive();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visits = ref.watch(visitsByPatientProvider(widget.patient.id));
    final patientStats = _calculatePatientStats(visits);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.patient.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editPatient(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfoCard(),
                  const SizedBox(height: AppConstants.padding),
                  _buildHealthIndicatorsCard(patientStats),
                  const SizedBox(height: AppConstants.padding),
                  _buildQuickActionsCard(),
                  const SizedBox(height: AppConstants.padding),
                  _buildVisitHistoryCard(visits),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addVisit(context),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Build patient information card
  Widget _buildPatientInfoCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                child: Text(
                  widget.patient.name.isNotEmpty ? widget.patient.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.patient.age} years • ${widget.patient.gender}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.patient.village,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.patient.pregnancyStatus == 'Pregnant'
                      ? AppColors.primaryRed.withValues(alpha: 0.1)
                      : AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.patient.pregnancyStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.patient.pregnancyStatus == 'Pregnant'
                        ? AppColors.primaryRed
                        : AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('Health ID', widget.patient.healthId),
          _buildInfoRow(
            'Last Visit',
            widget.patient.lastVisitDate != null
                ? DateFormat('dd MMM yyyy').format(widget.patient.lastVisitDate!)
                : 'Not recorded',
          ),
          _buildInfoRow(
            'Sync Status',
            widget.patient.isSynced ? 'Synced' : 'Pending',
            valueColor: widget.patient.isSynced ? AppColors.synced : AppColors.pendingSync,
          ),
          if (widget.patient.notes != null && widget.patient.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.patient.notes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build health indicators card
  Widget _buildHealthIndicatorsCard(Map<String, dynamic> stats) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorItem(
                  'Total Visits',
                  stats['totalVisits'].toString(),
                  Icons.medical_services,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIndicatorItem(
                  'Last BMI',
                  stats['lastBMI'] != null ? stats['lastBMI'].toStringAsFixed(1) : 'N/A',
                  Icons.monitor_weight,
                  AppColors.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorItem(
                  'Health Status',
                  stats['lastHealthStatus'] ?? 'Unknown',
                  Icons.favorite,
                  _getHealthStatusColor(stats['lastHealthStatus']),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIndicatorItem(
                  'Days Since Last Visit',
                  stats['daysSinceLastVisit'].toString(),
                  Icons.calendar_today,
                  AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build quick actions card
  Widget _buildQuickActionsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add Visit',
                  Icons.add_circle,
                  AppColors.primaryRed,
                  () => _addVisit(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'View History',
                  Icons.history,
                  AppColors.primaryBlue,
                  () => _viewVisitHistory(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Edit Patient',
                  Icons.edit,
                  AppColors.primaryBlue,
                  () => _editPatient(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Sync Data',
                  Icons.sync,
                  AppColors.synced,
                  () => _syncPatient(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build visit history card
  Widget _buildVisitHistoryCard(List<Visit> visits) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Visits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (visits.isNotEmpty)
                TextButton(
                  onPressed: () => _viewVisitHistory(context),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (visits.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No visits recorded',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a visit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ...visits.take(3).map((visit) => _buildVisitTile(visit)),
        ],
      ),
    );
  }

  /// Build visit tile
  Widget _buildVisitTile(Visit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getVisitTypeColor(visit.visitType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getVisitTypeIcon(visit.visitType),
              color: _getVisitTypeColor(visit.visitType),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.visitType ?? 'Visit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(visit.visitDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (visit.healthStatus != null)
                  Text(
                    visit.healthStatus!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getHealthStatusColor(visit.healthStatus!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (visit.bmi != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'BMI: ${visit.bmi!.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Build indicator item
  Widget _buildIndicatorItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate patient statistics
  Map<String, dynamic> _calculatePatientStats(List<Visit> visits) {
    final totalVisits = visits.length;
    final lastVisit = visits.isNotEmpty ? visits.first : null;
    final lastBMI = lastVisit?.bmi;
    final lastHealthStatus = lastVisit?.healthStatus;
    
    int daysSinceLastVisit = 0;
    if (widget.patient.lastVisitDate != null) {
      daysSinceLastVisit = DateTime.now().difference(widget.patient.lastVisitDate!).inDays;
    }

    return {
      'totalVisits': totalVisits,
      'lastBMI': lastBMI,
      'lastHealthStatus': lastHealthStatus,
      'daysSinceLastVisit': daysSinceLastVisit,
    };
  }

  /// Get visit type color
  Color _getVisitTypeColor(String? visitType) {
    switch (visitType) {
      case 'Pregnancy Checkup':
        return AppColors.primaryRed;
      case 'Immunization':
        return AppColors.primaryBlue;
      case 'Emergency Visit':
        return Colors.orange;
      case 'Routine Checkup':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get visit type icon
  IconData _getVisitTypeIcon(String? visitType) {
    switch (visitType) {
      case 'Pregnancy Checkup':
        return Icons.pregnant_woman;
      case 'Immunization':
        return Icons.vaccines;
      case 'Emergency Visit':
        return Icons.emergency;
      case 'Routine Checkup':
        return Icons.medical_services;
      default:
        return Icons.medical_services;
    }
  }

  /// Get health status color
  Color _getHealthStatusColor(String? status) {
    switch (status) {
      case 'Healthy':
        return Colors.green;
      case 'Needs Attention':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      case 'Stable':
        return Colors.blue;
      case 'Improving':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Navigate to add visit screen
  void _addVisit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitRecordsScreen(patient: widget.patient),
      ),
    ).then((_) {
      // Refresh data when returning
      _loadData();
    });
  }

  /// Navigate to visit history screen
  void _viewVisitHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitRecordsScreen(patient: widget.patient),
      ),
    );
  }

  /// Navigate to edit patient screen
  void _editPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPatientScreen(),
      ),
    ).then((_) {
      // Refresh data when returning
      _loadData();
    });
  }

  /// Sync patient data
  void _syncPatient(BuildContext context) async {
    try {
      // Simulate sync process
      await Future.delayed(const Duration(seconds: 1));
      
      // Update patient sync status
      final updatedPatient = widget.patient.copyWith(isSynced: true);
      await ref.read(patientProvider.notifier).updatePatient(updatedPatient);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient data synced successfully'),
            backgroundColor: AppColors.synced,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
