import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../providers/patient_provider.dart';
import '../widgets/custom_card.dart';
import '../models/patient_model.dart';

/// Patient list screen showing all registered patients
/// Displays sync status and allows filtering
class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'All',
    'Synced',
    'Pending Sync',
    'Pregnant Women',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Ensure Hive is initialized
      await ref.read(patientProvider.notifier).initializeHive();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Patient> _getFilteredPatients(List<Patient> patients) {
    List<Patient> filtered = patients;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((patient) {
        return patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               patient.village.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               patient.healthId.contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case 'Synced':
        filtered = filtered.where((p) => p.isSynced).toList();
        break;
      case 'Pending Sync':
        filtered = filtered.where((p) => !p.isSynced).toList();
        break;
      case 'Pregnant Women':
        filtered = filtered.where((p) => 
          p.pregnancyStatus.toLowerCase().contains('pregnant') ||
          p.pregnancyStatus.toLowerCase().contains('lactating') ||
          p.pregnancyStatus.toLowerCase().contains('post partum')
        ).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientProvider);
    final filteredPatients = _getFilteredPatients(patients);
    
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Patient List'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Handle potential null or empty patients list
    if (patients.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Patient List'),
        ),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        actions: [
          // Filter Dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == option ? Icons.check : Icons.radio_button_unchecked,
                      color: _selectedFilter == option ? AppColors.primaryRed : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((option) {
                      final isSelected = _selectedFilter == option;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = option;
                            });
                          },
                          selectedColor: AppColors.primaryRed.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primaryRed,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Patient Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: Text(
              '${filteredPatients.length} patient${filteredPatients.length != 1 ? 's' : ''} found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Patient List
          Expanded(
            child: filteredPatients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return PatientCard(
                        name: patient.name,
                        village: patient.village,
                        healthId: patient.healthId,
                        pregnancyStatus: patient.pregnancyStatus,
                        isSynced: patient.isSynced,
                        lastVisit: patient.lastVisitDate,
                        onTap: () => _showPatientDetails(patient),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'No patients found'
                : 'No patients registered yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search or filter'
                : 'Tap the + button to register your first patient',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadius),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                      backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                    child: Text(
                      patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.village,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: patient.isSynced ? AppColors.synced : AppColors.pendingSync,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      patient.isSynced ? 'Synced' : 'Pending',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Health ID', patient.healthId, Icons.credit_card),
                    _buildDetailRow('Age', '${patient.age} years', Icons.cake),
                    _buildDetailRow('Gender', patient.gender, Icons.wc),
                    _buildDetailRow('Pregnancy Status', patient.pregnancyStatus, Icons.pregnant_woman),
                    _buildDetailRow('Last Visit', _formatDate(patient.lastVisitDate), Icons.calendar_today),
                    _buildDetailRow('Registration Date', _formatDate(patient.registrationDate), Icons.person_add),
                    
                    if (patient.phoneNumber != null)
                      _buildDetailRow('Phone', patient.phoneNumber!, Icons.phone),
                    
                    if (patient.address != null)
                      _buildDetailRow('Address', patient.address!, Icons.home),
                    
                    if (patient.notes != null)
                      _buildDetailRow('Notes', patient.notes!, Icons.note),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
