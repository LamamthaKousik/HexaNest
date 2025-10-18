import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/visit_model.dart';
import '../utils/colors.dart';

/// Service for exporting data as PDF and CSV files
/// Provides offline export functionality for reports and patient data
class ExportService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Export patient data as PDF
  static Future<String?> exportPatientsAsPDF(List<Patient> patients, List<Visit> visits) async {
    try {
      final pdf = pw.Document();
      
      // Add patient summary page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              _buildPatientSummary(patients),
              pw.SizedBox(height: 20),
              _buildPatientTable(patients),
            ];
          },
        ),
      );

      // Add detailed patient pages
      for (final patient in patients) {
        final patientVisits = visits.where((v) => v.patientId == patient.id).toList();
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return [
                _buildPDFHeader(),
                pw.SizedBox(height: 20),
                _buildPatientDetails(patient),
                pw.SizedBox(height: 20),
                _buildVisitHistory(patientVisits),
              ];
            },
          ),
        );
      }

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'matru_mitra_patients_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      print('Error exporting PDF: $e');
      return null;
    }
  }

  /// Export visit data as PDF
  static Future<String?> exportVisitsAsPDF(List<Visit> visits, List<Patient> patients) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              _buildVisitSummary(visits),
              pw.SizedBox(height: 20),
              _buildVisitTable(visits, patients),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'matru_mitra_visits_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      print('Error exporting visits PDF: $e');
      return null;
    }
  }

  /// Export patient data as CSV
  static Future<String?> exportPatientsAsCSV(List<Patient> patients) async {
    try {
      final List<List<dynamic>> csvData = [
        ['Patient ID', 'Name', 'Age', 'Gender', 'Village', 'Health ID', 'Pregnancy Status', 'Last Visit', 'Synced', 'Notes'],
      ];

      for (final patient in patients) {
        csvData.add([
          patient.id,
          patient.name,
          patient.age,
          patient.gender,
          patient.village,
          patient.healthId,
          patient.pregnancyStatus,
          patient.lastVisitDate != null ? _dateFormat.format(patient.lastVisitDate!) : '',
          patient.isSynced ? 'Yes' : 'No',
          patient.notes ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'matru_mitra_patients_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);
      
      return file.path;
    } catch (e) {
      print('Error exporting CSV: $e');
      return null;
    }
  }

  /// Export visit data as CSV
  static Future<String?> exportVisitsAsCSV(List<Visit> visits, List<Patient> patients) async {
    try {
      final List<List<dynamic>> csvData = [
        ['Visit ID', 'Patient Name', 'Visit Date', 'Symptoms', 'Blood Pressure', 'Weight', 'Height', 'BMI', 'Visit Type', 'Health Status', 'Notes'],
      ];

      for (final visit in visits) {
        final patient = patients.firstWhere((p) => p.id == visit.patientId, orElse: () => Patient(id: '', name: 'Unknown', age: 0, gender: '', village: '', healthId: ''));
        
        csvData.add([
          visit.id,
          patient.name,
          _dateFormat.format(visit.visitDate),
          visit.symptoms ?? '',
          visit.bloodPressure ?? '',
          visit.weight ?? '',
          visit.height ?? '',
          visit.bmi?.toStringAsFixed(1) ?? '',
          visit.visitType ?? '',
          visit.healthStatus ?? '',
          visit.notes ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'matru_mitra_visits_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);
      
      return file.path;
    } catch (e) {
      print('Error exporting visits CSV: $e');
      return null;
    }
  }

  /// Export comprehensive report as PDF
  static Future<String?> exportComprehensiveReport(
    List<Patient> patients, 
    List<Visit> visits,
    Map<String, int> statistics,
  ) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              _buildReportSummary(statistics),
              pw.SizedBox(height: 20),
              _buildVillageDistribution(patients),
              pw.SizedBox(height: 20),
              _buildPregnancyStatusChart(patients),
              pw.SizedBox(height: 20),
              _buildVisitTypeDistribution(visits),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'matru_mitra_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      print('Error exporting comprehensive report: $e');
      return null;
    }
  }

  /// Build PDF header
  static pw.Widget _buildPDFHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Matru Mitra',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Health Companion Report',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.blue600,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Generated on: ${_dateTimeFormat.format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build patient summary
  static pw.Widget _buildPatientSummary(List<Patient> patients) {
    final totalPatients = patients.length;
    final pregnantWomen = patients.where((p) => p.pregnancyStatus == 'Pregnant').length;
    final syncedPatients = patients.where((p) => p.isSynced).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Patients', totalPatients.toString()),
              _buildSummaryItem('Pregnant Women', pregnantWomen.toString()),
              _buildSummaryItem('Synced', syncedPatients.toString()),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary item
  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// Build patient table
  static pw.Widget _buildPatientTable(List<Patient> patients) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Age', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Gender', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Village', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...patients.map((patient) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(patient.id.substring(0, 8)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(patient.name),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(patient.age.toString()),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(patient.gender),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(patient.village),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(patient.pregnancyStatus),
            ),
          ],
        )),
      ],
    );
  }

  /// Build patient details
  static pw.Widget _buildPatientDetails(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Name: ${patient.name}'),
          pw.Text('Age: ${patient.age} years'),
          pw.Text('Gender: ${patient.gender}'),
          pw.Text('Village: ${patient.village}'),
          pw.Text('Health ID: ${patient.healthId}'),
          pw.Text('Pregnancy Status: ${patient.pregnancyStatus}'),
          pw.Text('Last Visit: ${patient.lastVisitDate != null ? _dateFormat.format(patient.lastVisitDate!) : 'Not recorded'}'),
          pw.Text('Synced: ${patient.isSynced ? 'Yes' : 'No'}'),
          if (patient.notes != null && patient.notes!.isNotEmpty)
            pw.Text('Notes: ${patient.notes}'),
        ],
      ),
    );
  }

  /// Build visit history
  static pw.Widget _buildVisitHistory(List<Visit> visits) {
    if (visits.isEmpty) {
      return pw.Text('No visits recorded for this patient.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Visit History',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...visits.map((visit) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_dateFormat.format(visit.visitDate)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(visit.visitType ?? ''),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(visit.healthStatus ?? ''),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(visit.notes ?? ''),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  /// Build visit summary
  static pw.Widget _buildVisitSummary(List<Visit> visits) {
    final totalVisits = visits.length;
    final recentVisits = visits.where((v) => 
      v.visitDate.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Visit Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Visits', totalVisits.toString()),
              _buildSummaryItem('Recent Visits', recentVisits.toString()),
            ],
          ),
        ],
      ),
    );
  }

  /// Build visit table
  static pw.Widget _buildVisitTable(List<Visit> visits, List<Patient> patients) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Patient', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...visits.map((visit) {
          final patient = patients.firstWhere((p) => p.id == visit.patientId, orElse: () => Patient(id: '', name: 'Unknown', age: 0, gender: '', village: '', healthId: ''));
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(_dateFormat.format(visit.visitDate)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(patient.name),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(visit.visitType ?? ''),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(visit.healthStatus ?? ''),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(visit.notes ?? ''),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build report summary
  static pw.Widget _buildReportSummary(Map<String, int> statistics) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Patients', statistics['totalPatients']?.toString() ?? '0'),
              _buildSummaryItem('Total Visits', statistics['totalVisits']?.toString() ?? '0'),
              _buildSummaryItem('Pregnant Women', statistics['pregnantWomen']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build village distribution
  static pw.Widget _buildVillageDistribution(List<Patient> patients) {
    final villageCounts = <String, int>{};
    for (final patient in patients) {
      villageCounts[patient.village] = (villageCounts[patient.village] ?? 0) + 1;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Patients by Village',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Village', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...villageCounts.entries.map((entry) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(entry.key),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(entry.value.toString()),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  /// Build pregnancy status chart
  static pw.Widget _buildPregnancyStatusChart(List<Patient> patients) {
    final pregnantCount = patients.where((p) => p.pregnancyStatus == 'Pregnant').length;
    final notPregnantCount = patients.length - pregnantCount;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Pregnancy Status Distribution',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Container(
              width: 100,
              height: 20,
              decoration: const pw.BoxDecoration(color: PdfColors.red),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Pregnant: $pregnantCount'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Container(
              width: 100,
              height: 20,
              decoration: const pw.BoxDecoration(color: PdfColors.blue),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Not Pregnant: $notPregnantCount'),
          ],
        ),
      ],
    );
  }

  /// Build visit type distribution
  static pw.Widget _buildVisitTypeDistribution(List<Visit> visits) {
    final visitTypeCounts = <String, int>{};
    for (final visit in visits) {
      final type = visit.visitType ?? 'Unknown';
      visitTypeCounts[type] = (visitTypeCounts[type] ?? 0) + 1;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Visit Types Distribution',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Visit Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...visitTypeCounts.entries.map((entry) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(entry.key),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(entry.value.toString()),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }
}
