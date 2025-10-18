import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/visit_model.dart';
import '../providers/visit_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_card.dart';

/// Visit records screen for managing patient visits
/// Allows adding, viewing, and editing visit records
class VisitRecordsScreen extends ConsumerStatefulWidget {
  final Patient patient;
  final Visit? editVisit;

  const VisitRecordsScreen({
    super.key,
    required this.patient,
    this.editVisit,
  });

  @override
  ConsumerState<VisitRecordsScreen> createState() => _VisitRecordsScreenState();
}

class _VisitRecordsScreenState extends ConsumerState<VisitRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  final _prescribedMedicinesController = TextEditingController();
  final _ashaWorkerNotesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _nextVisitDate;
  String? _selectedVisitType;
  String? _selectedHealthStatus;
  bool _isLoading = false;

  final List<String> _visitTypes = [
    'Routine Checkup',
    'Pregnancy Checkup',
    'Immunization',
    'Emergency Visit',
    'Follow-up Visit',
    'Health Counseling',
  ];

  final List<String> _healthStatuses = [
    'Healthy',
    'Needs Attention',
    'Critical',
    'Stable',
    'Improving',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editVisit != null) {
      _populateFormWithVisit(widget.editVisit!);
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    _prescribedMedicinesController.dispose();
    _ashaWorkerNotesController.dispose();
    super.dispose();
  }

  /// Populate form with existing visit data
  void _populateFormWithVisit(Visit visit) {
    _symptomsController.text = visit.symptoms ?? '';
    _bloodPressureController.text = visit.bloodPressure ?? '';
    _weightController.text = visit.weight?.toString() ?? '';
    _heightController.text = visit.height?.toString() ?? '';
    _notesController.text = visit.notes ?? '';
    _prescribedMedicinesController.text = visit.prescribedMedicines ?? '';
    _ashaWorkerNotesController.text = visit.ashaWorkerNotes ?? '';
    _selectedDate = visit.visitDate;
    _nextVisitDate = visit.nextVisitDate;
    _selectedVisitType = visit.visitType;
    _selectedHealthStatus = visit.healthStatus;
  }

  @override
  Widget build(BuildContext context) {
    final visits = ref.watch(visitsByPatientProvider(widget.patient.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.editVisit != null ? 'Edit Visit' : 'Add Visit',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfoCard(),
            const SizedBox(height: AppConstants.padding),
            _buildVisitForm(),
            const SizedBox(height: AppConstants.padding),
            _buildVisitHistoryCard(visits),
          ],
        ),
      ),
      floatingActionButton: widget.editVisit == null
          ? FloatingActionButton(
              onPressed: _saveVisit,
              backgroundColor: AppColors.primaryRed,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save, color: Colors.white),
            )
          : null,
      bottomNavigationBar: widget.editVisit != null
          ? Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateVisit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Update Visit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  /// Build patient info card
  Widget _buildPatientInfoCard() {
    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
            child: Text(
              widget.patient.name.isNotEmpty ? widget.patient.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 20,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        ],
      ),
    );
  }

  /// Build visit form
  Widget _buildVisitForm() {
    return CustomCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visit Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Visit Type',
              _selectedVisitType,
              _visitTypes,
              (value) => setState(() => _selectedVisitType = value),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Health Status',
              _selectedHealthStatus,
              _healthStatuses,
              (value) => setState(() => _selectedHealthStatus = value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Symptoms',
              _symptomsController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Blood Pressure',
                    _bloodPressureController,
                    hintText: '120/80',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Weight (kg)',
                    _weightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Height (cm)',
              _heightController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Prescribed Medicines',
              _prescribedMedicinesController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Notes',
              _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'ASHA Worker Notes',
              _ashaWorkerNotesController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildNextVisitDateField(),
            if (_weightController.text.isNotEmpty && _heightController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildBMICard(),
            ],
          ],
        ),
      ),
    );
  }

  /// Build date field
  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primaryRed),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMM yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// Build dropdown field
  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  /// Build text field
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
      ),
      onChanged: (value) {
        if (label == 'Weight (kg)' || label == 'Height (cm)') {
          setState(() {}); // Trigger BMI calculation
        }
      },
    );
  }

  /// Build next visit date field
  Widget _buildNextVisitDateField() {
    return InkWell(
      onTap: _selectNextVisitDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.event, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Text(
              _nextVisitDate != null
                  ? DateFormat('dd MMM yyyy').format(_nextVisitDate!)
                  : 'Select Next Visit Date (Optional)',
              style: TextStyle(
                fontSize: 16,
                color: _nextVisitDate != null ? Colors.black : Colors.grey[600],
              ),
            ),
            const Spacer(),
            if (_nextVisitDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => setState(() => _nextVisitDate = null),
              ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// Build BMI card
  Widget _buildBMICard() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    
    if (weight == null || height == null || height <= 0) {
      return const SizedBox.shrink();
    }

    final bmi = weight / ((height / 100) * (height / 100));
    String category;
    Color categoryColor;

    if (bmi < 18.5) {
      category = 'Underweight';
      categoryColor = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal';
      categoryColor = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      categoryColor = Colors.orange;
    } else {
      category = 'Obese';
      categoryColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.monitor_weight, color: categoryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI: ${bmi.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
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
          const Text(
            'Visit History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                    'No visits recorded yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...visits.map((visit) => _buildVisitTile(visit)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (visit.healthStatus != null) ...[
            const SizedBox(height: 8),
            Text(
              'Status: ${visit.healthStatus}',
              style: TextStyle(
                fontSize: 12,
                color: _getHealthStatusColor(visit.healthStatus!),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              visit.notes!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Select visit date
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  /// Select next visit date
  Future<void> _selectNextVisitDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextVisitDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _nextVisitDate = date);
    }
  }

  /// Save new visit
  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final visit = Visit(
        id: ref.read(visitProvider.notifier).generateVisitId(),
        patientId: widget.patient.id,
        visitDate: _selectedDate,
        symptoms: _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
        bloodPressure: _bloodPressureController.text.trim().isEmpty ? null : _bloodPressureController.text.trim(),
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        visitType: _selectedVisitType,
        healthStatus: _selectedHealthStatus,
        prescribedMedicines: _prescribedMedicinesController.text.trim().isEmpty ? null : _prescribedMedicinesController.text.trim(),
        nextVisitDate: _nextVisitDate,
        ashaWorkerNotes: _ashaWorkerNotesController.text.trim().isEmpty ? null : _ashaWorkerNotesController.text.trim(),
      );

      final success = await ref.read(visitProvider.notifier).addVisit(visit);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit added successfully'),
            backgroundColor: AppColors.synced,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Update existing visit
  Future<void> _updateVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedVisit = widget.editVisit!.copyWith(
        visitDate: _selectedDate,
        symptoms: _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
        bloodPressure: _bloodPressureController.text.trim().isEmpty ? null : _bloodPressureController.text.trim(),
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        visitType: _selectedVisitType,
        healthStatus: _selectedHealthStatus,
        prescribedMedicines: _prescribedMedicinesController.text.trim().isEmpty ? null : _prescribedMedicinesController.text.trim(),
        nextVisitDate: _nextVisitDate,
        ashaWorkerNotes: _ashaWorkerNotesController.text.trim().isEmpty ? null : _ashaWorkerNotesController.text.trim(),
      );

      final success = await ref.read(visitProvider.notifier).updateVisit(updatedVisit);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit updated successfully'),
            backgroundColor: AppColors.synced,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
  Color _getHealthStatusColor(String status) {
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
}
