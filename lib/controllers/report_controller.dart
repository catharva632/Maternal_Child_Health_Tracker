import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';
import 'package:intl/intl.dart';

class ReportController {
  static final ReportController _instance = ReportController._internal();
  factory ReportController() => _instance;
  ReportController._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getLatestMood() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['mood'] as String?;
    }
    return 'No data';
  }

  Future<List<Map<String, dynamic>>> getRecentDietLogs() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('diet_logs')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  bool verifyPin(PatientModel patient, String enteredPin) {
    if (patient.name.length < 3) return false;
    final String expectedPin = "${patient.name.substring(0, 3)}@${patient.age.toString().padLeft(2, '0')}";
    return enteredPin == expectedPin;
  }

  Future<pw.Document> generateMedicalReport(PatientModel patient, String? latestMood, List<Map<String, dynamic>> dietLogs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader(patient),
          pw.SizedBox(height: 20),
          _buildPatientInfo(patient),
          pw.SizedBox(height: 20),
          _buildMedicalStatus(patient, latestMood),
          pw.SizedBox(height: 20),
          _buildDietLogs(dietLogs),
          pw.SizedBox(height: 20),
          _buildVaccinationSchedule(patient),
          pw.SizedBox(height: 20),
          _buildAppointments(patient),
          pw.SizedBox(height: 20),
          _buildDietPlan(patient),
          pw.SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(PatientModel patient) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('MATERNAL HEALTH REPORT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.pink)),
            pw.Text('Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}'),
          ],
        ),
        if (patient.hospitalName != null)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(patient.hospitalName!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(patient.hospitalAddress ?? ''),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildPatientInfo(PatientModel patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Patient Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.Divider(),
          pw.Row(children: [pw.Text('Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(patient.name)]),
          pw.Row(children: [pw.Text('Age: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(patient.age.toString())]),
          pw.Row(children: [pw.Text('Email: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(patient.email)]),
          pw.Row(children: [pw.Text('Phone: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(patient.phone)]),
        ],
      ),
    );
  }

  pw.Widget _buildMedicalStatus(PatientModel patient, String? latestMood) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Current Medical Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Metric', 'Value'],
          data: [
            ['Pregnancy Week', '${patient.pregnancyWeek} Weeks'],
            ['Latest Mood', latestMood ?? 'No record'],
            ['Weight', '${patient.weight} kg'],
            ['Height', '${patient.height} cm'],
            ['Conditions', patient.medicalConditions.join(', ')],
            ['Doctor', patient.doctorName ?? 'N/A'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildVaccinationSchedule(PatientModel patient) {
    if (patient.vaccinations.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Vaccination Schedule', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Vaccine', 'Date/Trimester'],
          data: patient.vaccinations.map((v) => [v['name']!, v['date'] ?? v['time']!]).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildAppointments(PatientModel patient) {
    if (patient.appointments.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Upcoming Doctor Visits', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Visit Type', 'Date'],
          data: patient.appointments.map((a) => [a['name']!, a['date']!]).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildDietLogs(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Recent Dietary Intake', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Meal Type', 'Description', 'Date'],
          data: logs.map((log) {
            final timestamp = log['timestamp'] as Timestamp?;
            final dateStr = timestamp != null ? DateFormat('dd-MM HH:mm').format(timestamp.toDate()) : 'N/A';
            return [log['mealType'] ?? 'N/A', log['description'] ?? 'N/A', dateStr];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildDietPlan(PatientModel patient) {
    if (patient.dietPlan.isEmpty) return pw.SizedBox();
    List<List<String>> dietData = [];
    patient.dietPlan.forEach((day, meals) {
      dietData.add([day, meals.values.join(', ')]);
    });

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Recommended Diet Plan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Day', 'Meals'],
          data: dietData,
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Divider(),
          pw.Text('This is a computer-generated medical report for maternal tracking purposes.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.Text('Consult your doctor for professional medical advice.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );
  }
}
