import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';

class PatientEditScreen extends StatefulWidget {
  final PatientModel patient;
  const PatientEditScreen({super.key, required this.patient});

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _weekController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _allergiesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _weekController = TextEditingController(text: widget.patient.pregnancyWeek.toString());
    _weightController = TextEditingController(text: widget.patient.weight.toString());
    _heightController = TextEditingController(text: widget.patient.height.toString());
    _cityController = TextEditingController(text: widget.patient.city);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _bloodGroupController = TextEditingController(text: widget.patient.bloodGroup ?? '');
    _allergiesController = TextEditingController(text: widget.patient.allergies ?? '');
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    try {
      final updates = {
        'name': _nameController.text,
        'pregnancyWeek': int.tryParse(_weekController.text) ?? widget.patient.pregnancyWeek,
        'weight': double.tryParse(_weightController.text) ?? widget.patient.weight,
        'height': double.tryParse(_heightController.text) ?? widget.patient.height,
        'city': _cityController.text,
        'phone': _phoneController.text,
        'bloodGroup': _bloodGroupController.text,
        'allergies': _allergiesController.text,
      };
      
      await PatientController().updatePatientMetadata(widget.patient.uid!, updates);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.patient.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField(_nameController, 'Name', Icons.person_outline),
            _buildField(_phoneController, 'Phone', Icons.phone_outlined, isNumber: true),
            _buildField(_weekController, 'Pregnancy Week', Icons.calendar_view_week_outlined, isNumber: true),
            _buildField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, isNumber: true),
            _buildField(_heightController, 'Height (cm)', Icons.height_outlined, isNumber: true),
            _buildField(_cityController, 'City', Icons.location_city_outlined),
            _buildField(_bloodGroupController, 'Blood Group', Icons.bloodtype_outlined),
            _buildField(_allergiesController, 'Allergies / Generic Disease', Icons.warning_amber_outlined, maxLines: 3),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                  : const Text('Update Profile', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
