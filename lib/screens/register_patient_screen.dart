import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../providers/patient_provider.dart';
import '../models/patient_model.dart';

/// Patient registration screen with form validation
/// Saves patient data locally using Hive database
class RegisterPatientScreen extends ConsumerStatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  ConsumerState<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends ConsumerState<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _villageController = TextEditingController();
  final _healthIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = AppConstants.genderOptions[1]; // Default to Female
  String _selectedPregnancyStatus = AppConstants.pregnancyStatusOptions[0]; // Default to Not Pregnant
  DateTime _lastVisitDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _villageController.dispose();
    _healthIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastVisitDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastVisitDate) {
      setState(() {
        _lastVisitDate = picked;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = Patient(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        village: _villageController.text.trim(),
        healthId: _healthIdController.text.trim(),
        pregnancyStatus: _selectedPregnancyStatus,
        lastVisitDate: _lastVisitDate,
        registrationDate: DateTime.now(),
        isSynced: false, // New patients start as unsynced
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      final success = await ref.read(patientProvider.notifier).addPatient(patient);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.successPatientSaved),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate back and refresh data
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.errorDuplicateHealthId),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePatient,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                      Icons.person_add,
                      color: AppColors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New Patient Registration',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the details below to register a new patient',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Personal Information
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter patient\'s full name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter patient\'s name';
                  }
                  if (value.trim().length < AppConstants.minNameLength) {
                    return 'Name must be at least ${AppConstants.minNameLength} characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Age and Gender Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age *',
                        prefixIcon: Icon(Icons.cake),
                        hintText: 'Age',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(value);
                        if (age == null) {
                          return 'Please enter a valid age';
                        }
                        if (age < AppConstants.minAge || age > AppConstants.maxAge) {
                          return 'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: AppConstants.genderOptions.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Village Field
              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(
                  labelText: 'Village *',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter village name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter village name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Health ID Field
              TextFormField(
                controller: _healthIdController,
                decoration: const InputDecoration(
                  labelText: 'Health ID *',
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: 'Enter 12-digit Health ID',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter Health ID';
                  }
                  if (value.trim().length != AppConstants.healthIdLength) {
                    return 'Health ID must be ${AppConstants.healthIdLength} digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Health Information
              Text(
                'Health Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pregnancy Status
              DropdownButtonFormField<String>(
                initialValue: _selectedPregnancyStatus,
                decoration: const InputDecoration(
                  labelText: 'Pregnancy Status *',
                  prefixIcon: Icon(Icons.pregnant_woman),
                ),
                items: AppConstants.pregnancyStatusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPregnancyStatus = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Last Visit Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Last Visit Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_lastVisitDate.day}/${_lastVisitDate.month}/${_lastVisitDate.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Contact Information
              Text(
                'Contact Information (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Enter phone number',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home),
                  hintText: 'Enter complete address',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Any additional notes or observations',
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          'Register Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppConstants.infoOfflineMode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
