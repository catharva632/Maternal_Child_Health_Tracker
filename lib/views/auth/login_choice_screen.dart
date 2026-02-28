import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Signup Choice')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.05),
              Image.asset('assets/images/logo.png', height: size.height * 0.12),
              SizedBox(height: size.height * 0.05),
              SizedBox(height: size.height * 0.05),
            _buildChoiceCard(
              context,
              'Continue with Google',
              Icons.contact_mail_outlined,
              () => AuthController().signInWithGoogle(context),
              isGoogle: true,
            ),
            const SizedBox(height: 20),
            _buildChoiceCard(
              context,
              'Login as Patient',
              Icons.person_outline,
              () => Navigator.pushNamed(context, '/patientLogin'),
            ),
            const SizedBox(height: 20),
            _buildChoiceCard(
              context,
              'Login as Doctor',
              Icons.medical_services_outlined,
              () => Navigator.pushNamed(context, '/doctorLogin'),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildChoiceCard(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isGoogle = false}) {
    return Card(
      elevation: 4,
      color: isGoogle ? Colors.white : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Row(
            children: [
              isGoogle 
                ? const Icon(Icons.g_mobiledata, size: 40, color: Colors.blue)
                : Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
