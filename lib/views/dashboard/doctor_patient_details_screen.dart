import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/patient_model.dart';
import 'package:intl/intl.dart';

class DoctorPatientDetailsScreen extends StatefulWidget {
  final PatientModel patient;
  const DoctorPatientDetailsScreen({super.key, required this.patient});

  @override
  State<DoctorPatientDetailsScreen> createState() => _DoctorPatientDetailsScreenState();
}

class _DoctorPatientDetailsScreenState extends State<DoctorPatientDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PatientModel _patient;
  bool _isLoading = false;

  // Diet Plan State
  final List<String> _days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
  late Map<String, Map<String, TextEditingController>> _dietControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _patient = widget.patient;
    _initDietControllers();
  }

  void _initDietControllers() {
    _dietControllers = {};
    for (var day in _days) {
      _dietControllers[day] = {};
      for (var meal in _mealTypes) {
        String initialValue = _patient.dietPlan[day]?[meal] ?? '';
        _dietControllers[day]![meal] = TextEditingController(text: initialValue);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var day in _dietControllers.values) {
      for (var controller in day.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _updatePatientData(Map<String, dynamic> updates) async {
    setState(() => _isLoading = true);
    try {
      await PatientController().updatePatientMetadata(_patient.uid!, updates);
      // Update local state if needed (or refetch if using a stream)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveDietPlan() {
    final Map<String, Map<String, String>> newDietPlan = {};
    for (var day in _days) {
      newDietPlan[day] = {};
      for (var meal in _mealTypes) {
        newDietPlan[day]![meal] = _dietControllers[day]![meal]!.text;
      }
    }
    _updatePatientData({'dietPlan': newDietPlan});
  }

  void _addVaccination() {
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vaccination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Vaccine Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date (e.g. 2024-04-20)'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                final List<Map<String, String>> updatedVaccinations = List.from(_patient.vaccinations);
                updatedVaccinations.add({
                  'name': nameController.text,
                  'date': dateController.text,
                });
                _updatePatientData({'vaccinations': updatedVaccinations});
                setState(() {
                   _patient.vaccinations = updatedVaccinations;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
            Tab(text: 'Vaccinations', icon: Icon(Icons.vaccines_outlined)),
            Tab(text: 'Diet Plan', icon: Icon(Icons.restaurant_menu_outlined)),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildVaccinationTab(),
              _buildDietTab(),
            ],
          ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Personal Details', [
            _buildInfoRow('Age', '${_patient.age} years'),
            _buildInfoRow('Pregnancy Week', '${_patient.pregnancyWeek} weeks'),
            _buildInfoRow('Blood Group', _patient.bloodGroup ?? 'N/A'),
            _buildInfoRow('Allergies', _patient.allergies ?? 'None'),
          ]),
          const SizedBox(height: 20),
          _buildInfoCard('Vitals', [
            _buildInfoRow('Weight', '${_patient.weight} kg'),
            _buildInfoRow('Height', '${_patient.height} cm'),
          ]),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile', arguments: _patient),
              icon: const Icon(Icons.edit_note),
              label: const Text('Edit Detailed Profile'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVaccinationTab() {
    return Column(
      children: [
        Expanded(
          child: _patient.vaccinations.isEmpty
              ? const Center(child: Text('No vaccinations recorded.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _patient.vaccinations.length,
                  itemBuilder: (context, index) {
                    final vaccine = _patient.vaccinations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(vaccine['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Date: ${vaccine['date']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            final List<Map<String, String>> updated = List.from(_patient.vaccinations);
                            updated.removeAt(index);
                            _updatePatientData({'vaccinations': updated});
                            setState(() => _patient.vaccinations = updated);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _addVaccination,
              icon: const Icon(Icons.add),
              label: const Text('Add New Vaccination'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('7-Day Exercise & Diet Program', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Enter diet details manually for each day.', 
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                _buildDietTableGrid(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _saveDietPlan,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Update Patient Diet Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietTableGrid() {
    return Column(
      children: _days.map((day) {
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16
                )),
                const SizedBox(height: 12),
                Row(
                  children: _mealTypes.map((meal) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _dietControllers[day]![meal],
                          decoration: InputDecoration(
                            labelText: meal,
                            labelStyle: const TextStyle(fontSize: 12),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(8),
                          ),
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
