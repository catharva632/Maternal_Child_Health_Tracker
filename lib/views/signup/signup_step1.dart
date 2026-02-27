import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';

class SignupStep1 extends StatefulWidget {
  const SignupStep1({super.key});

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTimeline(1),
            const SizedBox(height: 30),
            _buildTextField(_nameController, 'Name', Icons.person_outline),
            _buildTextField(_emailController, 'Email', Icons.email_outlined),
            _buildTextField(_phoneController, 'Phone', Icons.phone_outlined),
            _buildTextField(_addressController, 'Address', Icons.home_outlined),
            Row(
              children: [
                Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop_outlined, isNumber: true)),
              ],
            ),
            _buildTextField(_stateController, 'State', Icons.map_outlined),
            _buildTextField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  PatientController().savePersonalDetails(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                    city: _cityController.text,
                    pincode: _pincodeController.text,
                    state: _stateController.text,
                    password: _passwordController.text,
                  );
                  Navigator.pushNamed(context, '/signup2');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48FB1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next', style: TextStyle(fontSize: 18)),
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
        Container(width: 40, height: 2, color: step >= 2 ? const Color(0xFFF48FB1) : Colors.grey.shade300),
        CircleAvatar(
          radius: 15,
          backgroundColor: step >= 2 ? const Color(0xFFF48FB1) : Colors.grey.shade300,
          child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Container(width: 40, height: 2, color: step >= 3 ? const Color(0xFFF48FB1) : Colors.grey.shade300),
        CircleAvatar(
          radius: 15,
          backgroundColor: step >= 3 ? const Color(0xFFF48FB1) : Colors.grey.shade300,
          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
