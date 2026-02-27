import 'package:flutter/material.dart';
import '../../models/patient_model.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/settings_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settings = SettingsController();
  
  // Personal Details
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late TextEditingController _stateController;

  // Medical Details
  late TextEditingController _weekController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  final List<String> _allConditions = ['None', 'Diabetes', 'Thyroid', 'Anemia', 'High BP'];
  List<String> _selectedConditions = [];

  // Doctor Details
  late TextEditingController _doctorNameController;
  late TextEditingController _doctorPhoneController;
  late TextEditingController _hospitalNameController;
  late TextEditingController _hospitalAddressController;
  late TextEditingController _hospitalPhoneController;
  
  bool _isInit = true;
  String? _uid;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _weekController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _hospitalPhoneController.dispose();
    super.dispose();
  }

  void _initializeControllers(PatientModel patient) {
    _uid = patient.uid;
    _nameController = TextEditingController(text: patient.name);
    _emailController = TextEditingController(text: patient.email);
    _phoneController = TextEditingController(text: patient.phone);
    _addressController = TextEditingController(text: patient.address);
    _cityController = TextEditingController(text: patient.city);
    _pincodeController = TextEditingController(text: patient.pincode);
    _stateController = TextEditingController(text: patient.state);
    
    _weekController = TextEditingController(text: patient.pregnancyWeek.toString());
    _ageController = TextEditingController(text: patient.age.toString());
    _weightController = TextEditingController(text: patient.weight.toString());
    _heightController = TextEditingController(text: patient.height.toString());
    _selectedConditions = List.from(patient.medicalConditions);

    _doctorNameController = TextEditingController(text: patient.doctorName ?? '');
    _doctorPhoneController = TextEditingController(text: patient.doctorPhone ?? '');
    _hospitalNameController = TextEditingController(text: patient.hospitalName ?? '');
    _hospitalAddressController = TextEditingController(text: patient.hospitalAddress ?? '');
    _hospitalPhoneController = TextEditingController(text: patient.hospitalPhone ?? '');
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _uid != null) {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'pincode': _pincodeController.text,
        'state': _stateController.text,
        'pregnancyWeek': int.tryParse(_weekController.text) ?? 0,
        'age': int.tryParse(_ageController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'medicalConditions': _selectedConditions,
        'doctorName': _doctorNameController.text,
        'doctorPhone': _doctorPhoneController.text,
        'hospitalName': _hospitalNameController.text,
        'hospitalAddress': _hospitalAddressController.text,
        'hospitalPhone': _hospitalPhoneController.text,
      };
      await ProfileController().updateProfile(context, _uid!, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientModel?>(
      stream: PatientController().getPatientStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final patient = snapshot.data;
        if (patient == null) {
          return const Scaffold(body: Center(child: Text('No patient data found')));
        }

        if (_isInit || _uid != patient.uid) {
          _initializeControllers(patient);
          _isInit = false;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_settings.tr('Profile')),
            actions: [
              IconButton(onPressed: _saveProfile, icon: const Icon(Icons.save)),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          backgroundImage: patient.photoUrl != null 
                            ? NetworkImage(patient.photoUrl!) 
                            : null,
                          child: patient.photoUrl == null 
                            ? const Icon(Icons.person, size: 60) 
                            : null,
                        ),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () => ProfileController().uploadProfilePicture(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(_settings.tr('Personal Details')),
                  const SizedBox(height: 16),
                  _buildField(_nameController, 'Name'),
                  _buildField(_emailController, 'Email', enabled: false),
                  _buildField(_phoneController, 'Phone'),
                  _buildField(_addressController, 'Address'),
                  Row(
                    children: [
                      Expanded(child: _buildField(_cityController, 'City')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildField(_pincodeController, 'Pincode', isNumber: true)),
                    ],
                  ),
                  _buildField(_stateController, 'State'),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(_settings.tr('Medical Details')),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildField(_weekController, 'Pregnancy Week', isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildField(_ageController, 'Age', isNumber: true)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildField(_weightController, 'Weight (kg)', isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildField(_heightController, 'Height (cm)', isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Medical Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allConditions.map((condition) {
                      final isSelected = _selectedConditions.contains(condition);
                      return FilterChip(
                        label: Text(condition),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              if (condition == 'None') {
                                _selectedConditions.clear();
                              } else {
                                _selectedConditions.remove('None');
                              }
                              _selectedConditions.add(condition);
                            } else {
                              _selectedConditions.remove(condition);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                  _buildSectionHeader(_settings.tr('Doctor Details')),
                  const SizedBox(height: 16),
                  _buildField(_doctorNameController, 'Doctor Name'),
                  _buildField(_doctorPhoneController, 'Doctor Phone'),
                  _buildField(_hospitalNameController, 'Clinic/Hospital Name'),
                  _buildField(_hospitalPhoneController, 'Clinic Contact No'),
                  _buildField(_hospitalAddressController, 'Clinic Address'),
                  
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_settings.tr('Save Profile'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Container(margin: const EdgeInsets.only(top: 4), width: 40, height: 3, color: Theme.of(context).primaryColor),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: enabled ? (val) => val!.isEmpty ? 'Enter $label' : null : null,
      ),
    );
  }
}
