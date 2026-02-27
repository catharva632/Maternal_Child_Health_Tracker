import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../controllers/patient_controller.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/patient_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _pinController = TextEditingController();
  final _reportController = ReportController();
  final _settings = SettingsController();
  
  bool _isUnlocked = false;
  PatientModel? _patient;
  String? _latestMood;
  List<Map<String, dynamic>> _dietLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patient = await PatientController().getPatientStream().first;
    final mood = await _reportController.getLatestMood();
    final logs = await _reportController.getRecentDietLogs();
    setState(() {
      _patient = patient;
      _latestMood = mood;
      _dietLogs = logs;
      _isLoading = false;
    });
  }

  void _verifyPin() {
    if (_patient == null) return;
    
    if (_reportController.verifyPin(_patient!, _pinController.text)) {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_settings.tr('Invalid PIN. Access Denied.')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_settings.tr('Generate Report'))),
        body: const Center(child: Text('Patient data not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_settings.tr('Medical Report')),
        actions: [
          if (_isUnlocked)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() => _isUnlocked = false),
            ),
        ],
      ),
      body: _isUnlocked ? _buildPdfPreview() : _buildPinEntry(),
    );
  }

  Widget _buildPinEntry() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.pink),
          const SizedBox(height: 24),
          Text(
            _settings.tr('Enter Decryption PIN'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _settings.tr('PIN is: First 3 letters of name + @ + 2 digits of age'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _pinController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'e.g. Anj@25',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              prefixIcon: const Icon(Icons.password),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _verifyPin,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(_settings.tr('Verify & Open Report')),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return PdfPreview(
      build: (format) async {
        final doc = await _reportController.generateMedicalReport(_patient!, _latestMood, _dietLogs);
        return doc.save();
      },
      allowPrinting: true,
      allowSharing: true,
      canChangePageFormat: false,
      initialPageFormat: PdfPageFormat.a4,
      pdfFileName: 'Medical_Report_${_patient!.name}.pdf',
    );
  }
}
