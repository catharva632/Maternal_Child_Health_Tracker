import 'package:flutter/material.dart';
import '../../models/patient_model.dart';
import '../../controllers/patient_controller.dart';

class PatientEditScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientEditScreen({super.key, required this.patient});

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  late List<Map<String, String>> _vaccinations;
  late List<Map<String, String>> _appointments;
  late Map<String, Map<String, String>> _dietPlan;
  final _vaccineNameController = TextEditingController();
  final _vaccineDateController = TextEditingController();
  final _appointmentDateController = TextEditingController();
  final _appointmentTimeController = TextEditingController();

  final List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    _vaccinations = List.from(widget.patient.vaccinations);
    _appointments = List.from(widget.patient.appointments);
    _dietPlan = Map.from(widget.patient.dietPlan);
    
    // Initialize diet plan for all days if empty
    for (var day in _days) {
      if (!_dietPlan.containsKey(day)) {
        _dietPlan[day] = {'Breakfast': '', 'Lunch': '', 'Dinner': ''};
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      await PatientController().updatePatientMetadata(widget.patient.uid!, {
        'vaccinations': _vaccinations,
        'appointments': _appointments,
        'dietPlan': _dietPlan,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient data updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _addVaccination() {
    if (_vaccineNameController.text.isNotEmpty && _vaccineDateController.text.isNotEmpty) {
      setState(() {
        _vaccinations.add({
          'name': _vaccineNameController.text,
          'date': _vaccineDateController.text,
        });
        _vaccineNameController.clear();
        _vaccineDateController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.patient.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Vaccination Schedule'),
            const SizedBox(height: 10),
            _buildVaccinationForm(),
            const SizedBox(height: 10),
            _buildVaccinationList(),
            const Divider(height: 40),
            _buildSectionHeader('Diet Plan (Weekly)'),
            const SizedBox(height: 10),
            _buildDietTable(),
            const Divider(height: 40),
            _buildSectionHeader('Appointments'),
            const SizedBox(height: 10),
            _buildAppointmentForm(),
            const SizedBox(height: 10),
            _buildAppointmentList(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveChanges,
                child: const Text('Update Patient Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFAD1457)),
    );
  }

  Widget _buildVaccinationForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _vaccineNameController,
              decoration: const InputDecoration(labelText: 'Vaccine Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _vaccineDateController,
              decoration: const InputDecoration(
                labelText: 'Date (e.g. 2026-03-15)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                 DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100)
                );
                if(pickedDate != null ){
                  setState(() {
                    _vaccineDateController.text = pickedDate.toString().split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addVaccination,
              icon: const Icon(Icons.add),
              label: const Text('Add to Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final v = _vaccinations[index];
        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          child: ListTile(
            title: Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Date: ${v['date']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _vaccinations.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDietTable() {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Breakfast', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Lunch', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Dinner', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _days.map((day) {
            return DataRow(cells: [
              DataCell(Text(day, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(_buildDietInput(day, 'Breakfast')),
              DataCell(_buildDietInput(day, 'Lunch')),
              DataCell(_buildDietInput(day, 'Dinner')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDietInput(String day, String meal) {
    return SizedBox(
      width: 120,
      child: TextField(
        controller: TextEditingController(text: _dietPlan[day]?[meal] ?? '')..selection = TextSelection.fromPosition(TextPosition(offset: (_dietPlan[day]?[meal] ?? '').length)),
        onChanged: (value) {
          _dietPlan[day]![meal] = value;
        },
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  void _addAppointment() {
    if (_appointmentDateController.text.isNotEmpty && _appointmentTimeController.text.isNotEmpty) {
      setState(() {
        _appointments.add({
          'date': _appointmentDateController.text,
          'time': _appointmentTimeController.text,
          'status': 'scheduled',
        });
        _appointmentDateController.clear();
        _appointmentTimeController.clear();
      });
    }
  }

  Widget _buildAppointmentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _appointmentDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Appointment Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                 DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100)
                );
                if(pickedDate != null ){
                  setState(() {
                    _appointmentDateController.text = pickedDate.toString().split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _appointmentTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Appointment Time (e.g. 10:00 AM)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                 TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                );
                if(pickedTime != null ){
                  setState(() {
                    _appointmentTimeController.text = pickedTime.format(context);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addAppointment,
              icon: const Icon(Icons.event),
              label: const Text('Schedule Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    // Sort appointments by date: upcoming first then past
    final sortedAppointments = List<Map<String, String>>.from(_appointments);
    sortedAppointments.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final a = sortedAppointments[index];
        final isUpcoming = (a['date'] ?? '').compareTo(DateTime.now().toString().split(' ')[0]) >= 0;

        return Card(
          elevation: 0,
          color: isUpcoming ? Colors.blue.shade50 : Colors.grey.shade50,
          child: ListTile(
            title: Text('Date: ${a['date']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Time: ${a['time']} | Status: ${a['status']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpcoming) 
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                       DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(a['date']!),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100)
                      );
                      if(pickedDate != null ){
                        setState(() {
                          final originalIndex = _appointments.indexWhere((element) => element == a);
                          if (originalIndex != -1) {
                            _appointments[originalIndex]['date'] = pickedDate.toString().split(' ')[0];
                          }
                        });
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _appointments.remove(a);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
