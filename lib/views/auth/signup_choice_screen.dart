import 'package:flutter/material.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup Choice')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChoiceCard(
              context,
              'Register as Patient',
              Icons.person_add_outlined,
              () => Navigator.pushNamed(context, '/signup1'),
            ),
            const SizedBox(height: 20),
            _buildChoiceCard(
              context,
              'Register as Doctor',
              Icons.person_add_alt_1_outlined,
              () => Navigator.pushNamed(context, '/doctorSignup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
