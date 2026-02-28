import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/settings_controller.dart';

class SignupStep2 extends StatefulWidget {
  const SignupStep2({super.key});

  @override
  State<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends State<SignupStep2> {
  final _weekController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _allConditions = ['None', 'Diabetes', 'Thyroid', 'Anemia', 'High BP'];
  final List<String> _selectedConditions = [];
  String? _selectedDiet;
  String? _selectedBloodGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTimeline(2),
            const SizedBox(height: 30),
            _buildTextField(_weekController, 'Pregnancy Week', Icons.calendar_view_week_outlined, isNumber: true),
            _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, isNumber: true),
            _buildTextField(_heightController, 'Height (cm)', Icons.height_outlined, isNumber: true),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDiet,
              decoration: InputDecoration(
                labelText: 'Dietary Preference',
                prefixIcon: const Icon(Icons.restaurant_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Vegetarian', 'Non-Veg'].map((diet) {
                return DropdownMenuItem(value: diet, child: Text(diet));
              }).toList(),
              onChanged: (value) => setState(() => _selectedDiet = value),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: InputDecoration(
                labelText: SettingsController().translate('Blood Group'),
                prefixIcon: const Icon(Icons.bloodtype_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _bloodGroups.map((bg) {
                return DropdownMenuItem(value: bg, child: Text(bg));
              }).toList(),
              onChanged: (value) => setState(() => _selectedBloodGroup = value),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _allergiesController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: SettingsController().translate('Allergies / Generic Disease (Optional)'),
                prefixIcon: const Icon(Icons.warning_amber_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: SettingsController().translate('List any allergies or diseases...'),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Medical Conditions (Select Multiple)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _allConditions.map((condition) {
                final isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  selectedColor: const Color(0xFFF48FB1).withOpacity(0.3),
                  checkmarkColor: const Color(0xFFF48FB1),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        if (condition == 'None') {
                          _selectedConditions.clear();
                          _selectedConditions.add('None');
                        } else {
                          _selectedConditions.remove('None');
                          _selectedConditions.add(condition);
                        }
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_weekController.text.isEmpty ||
                      _weightController.text.isEmpty ||
                      _heightController.text.isEmpty ||
                      _selectedDiet == null ||
                      _selectedBloodGroup == null ||
                      _selectedConditions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields except Allergies are compulsory')),
                    );
                    return;
                  }
                  PatientController().saveMedicalDetails(
                    week: int.tryParse(_weekController.text) ?? 0,
                    weight: double.tryParse(_weightController.text) ?? 0.0,
                    height: double.tryParse(_heightController.text) ?? 0.0,
                    conditions: _selectedConditions,
                    diet: _selectedDiet!,
                    bloodGroup: _selectedBloodGroup!,
                    allergies: _allergiesController.text,
                  );
                  if (mounted) Navigator.pushNamed(context, '/signup3');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48FB1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(SettingsController().translate('Next'), style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: step >= 1 ? const Color(0xFFF48FB1) : Colors.grey.shade300,
          child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Expanded(child: Container(height: 2, color: step >= 2 ? const Color(0xFFF48FB1) : Colors.grey.shade300)),
        CircleAvatar(
          radius: 15,
          backgroundColor: step >= 2 ? const Color(0xFFF48FB1) : Colors.grey.shade300,
          child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Expanded(child: Container(height: 2, color: step >= 3 ? const Color(0xFFF48FB1) : Colors.grey.shade300)),
        CircleAvatar(
          radius: 15,
          backgroundColor: step >= 3 ? const Color(0xFFF48FB1) : Colors.grey.shade300,
          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: SettingsController().translate(label),
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}
