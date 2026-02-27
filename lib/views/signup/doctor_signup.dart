import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class DoctorSignup extends StatefulWidget {
  const DoctorSignup({super.key});

  @override
  State<DoctorSignup> createState() => _DoctorSignupState();
}

class _DoctorSignupState extends State<DoctorSignup> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _clinicController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Signup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildField(_nameController, 'Doctor Name', Icons.person_outline),
            _buildField(_emailController, 'Mail ID', Icons.email_outlined),
            _buildField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
            _buildField(_clinicController, 'Clinic Name', Icons.local_hospital_outlined),
            _buildField(_specializationController, 'Specialization', Icons.badge_outlined),
            _buildField(_phoneController, 'Phone No', Icons.phone_outlined),
            _buildField(_addressController, 'Clinic Address', Icons.location_on_outlined),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => AuthController().registerDoctor(
                  context: context,
                  name: _nameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  clinicName: _clinicController.text,
                  specialization: _specializationController.text,
                  phone: _phoneController.text,
                  address: _addressController.text,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48FB1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Signup', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
