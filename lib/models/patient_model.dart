import 'package:hive/hive.dart';

part 'patient_model.g.dart';

/// Patient model for Matru Mitra EHR system
/// Represents patient data stored locally and synced to server
@HiveType(typeId: 0)
class Patient extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender;

  @HiveField(4)
  String village;

  @HiveField(5)
  String healthId;

  @HiveField(6)
  String pregnancyStatus;

  @HiveField(7)
  DateTime lastVisitDate;

  @HiveField(8)
  DateTime registrationDate;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  String? phoneNumber;

  @HiveField(12)
  String? address;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.village,
    required this.healthId,
    required this.pregnancyStatus,
    required this.lastVisitDate,
    required this.registrationDate,
    this.isSynced = false,
    this.notes,
    this.phoneNumber,
    this.address,
  });

  /// Create a copy of the patient with updated fields
  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? village,
    String? healthId,
    String? pregnancyStatus,
    DateTime? lastVisitDate,
    DateTime? registrationDate,
    bool? isSynced,
    String? notes,
    String? phoneNumber,
    String? address,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      village: village ?? this.village,
      healthId: healthId ?? this.healthId,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      registrationDate: registrationDate ?? this.registrationDate,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }

  /// Convert patient to JSON for API calls (when sync is implemented)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'village': village,
      'healthId': healthId,
      'pregnancyStatus': pregnancyStatus,
      'lastVisitDate': lastVisitDate.toIso8601String(),
      'registrationDate': registrationDate.toIso8601String(),
      'isSynced': isSynced,
      'notes': notes,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  /// Create patient from JSON (for future API integration)
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      village: json['village'] ?? '',
      healthId: json['healthId'] ?? '',
      pregnancyStatus: json['pregnancyStatus'] ?? '',
      lastVisitDate: DateTime.parse(json['lastVisitDate']),
      registrationDate: DateTime.parse(json['registrationDate']),
      isSynced: json['isSynced'] ?? false,
      notes: json['notes'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $name, age: $age, gender: $gender, village: $village, healthId: $healthId, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum for pregnancy status
enum PregnancyStatus {
  notPregnant('Not Pregnant'),
  pregnant('Pregnant'),
  lactating('Lactating'),
  postPartum('Post Partum');

  const PregnancyStatus(this.displayName);
  final String displayName;
}

/// Enum for gender
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.displayName);
  final String displayName;
}
