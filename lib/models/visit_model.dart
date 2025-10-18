import 'package:hive/hive.dart';

part 'visit_model.g.dart';

/// Visit model for tracking patient visits and health records
/// Stores visit data locally for offline access
@HiveType(typeId: 1)
class Visit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String patientId;

  @HiveField(2)
  DateTime visitDate;

  @HiveField(3)
  String? symptoms;

  @HiveField(4)
  String? bloodPressure;

  @HiveField(5)
  double? weight;

  @HiveField(6)
  double? height;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? visitType;

  @HiveField(9)
  String? healthStatus;

  @HiveField(10)
  String? prescribedMedicines;

  @HiveField(11)
  DateTime? nextVisitDate;

  @HiveField(12)
  String? ashaWorkerNotes;

  Visit({
    required this.id,
    required this.patientId,
    required this.visitDate,
    this.symptoms,
    this.bloodPressure,
    this.weight,
    this.height,
    this.notes,
    this.visitType,
    this.healthStatus,
    this.prescribedMedicines,
    this.nextVisitDate,
    this.ashaWorkerNotes,
  });

  /// Create a copy of the visit with updated fields
  Visit copyWith({
    String? id,
    String? patientId,
    DateTime? visitDate,
    String? symptoms,
    String? bloodPressure,
    double? weight,
    double? height,
    String? notes,
    String? visitType,
    String? healthStatus,
    String? prescribedMedicines,
    DateTime? nextVisitDate,
    String? ashaWorkerNotes,
  }) {
    return Visit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitDate: visitDate ?? this.visitDate,
      symptoms: symptoms ?? this.symptoms,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      notes: notes ?? this.notes,
      visitType: visitType ?? this.visitType,
      healthStatus: healthStatus ?? this.healthStatus,
      prescribedMedicines: prescribedMedicines ?? this.prescribedMedicines,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      ashaWorkerNotes: ashaWorkerNotes ?? this.ashaWorkerNotes,
    );
  }

  /// Calculate BMI if weight and height are available
  double? get bmi {
    if (weight != null && height != null && height! > 0) {
      return weight! / ((height! / 100) * (height! / 100));
    }
    return null;
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Convert visit to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'visitDate': visitDate.toIso8601String(),
      'symptoms': symptoms,
      'bloodPressure': bloodPressure,
      'weight': weight,
      'height': height,
      'notes': notes,
      'visitType': visitType,
      'healthStatus': healthStatus,
      'prescribedMedicines': prescribedMedicines,
      'nextVisitDate': nextVisitDate?.toIso8601String(),
      'ashaWorkerNotes': ashaWorkerNotes,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
    };
  }

  /// Create visit from JSON
  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      visitDate: DateTime.parse(json['visitDate']),
      symptoms: json['symptoms'],
      bloodPressure: json['bloodPressure'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      notes: json['notes'],
      visitType: json['visitType'],
      healthStatus: json['healthStatus'],
      prescribedMedicines: json['prescribedMedicines'],
      nextVisitDate: json['nextVisitDate'] != null 
          ? DateTime.parse(json['nextVisitDate']) 
          : null,
      ashaWorkerNotes: json['ashaWorkerNotes'],
    );
  }

  @override
  String toString() {
    return 'Visit(id: $id, patientId: $patientId, visitDate: $visitDate, visitType: $visitType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Visit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Visit types for categorization
enum VisitType {
  routine('Routine Checkup'),
  pregnancy('Pregnancy Checkup'),
  immunization('Immunization'),
  emergency('Emergency Visit'),
  followUp('Follow-up Visit'),
  counseling('Health Counseling');

  const VisitType(this.displayName);
  final String displayName;
}

/// Health status indicators
enum HealthStatus {
  healthy('Healthy'),
  needsAttention('Needs Attention'),
  critical('Critical'),
  stable('Stable'),
  improving('Improving');

  const HealthStatus(this.displayName);
  final String displayName;
}
