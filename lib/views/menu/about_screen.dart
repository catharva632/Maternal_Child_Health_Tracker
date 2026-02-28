import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            const SizedBox(height: 16),
            const Text(
              'M.O.M (Maternal Operational Monitoring)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'A smart pregnancy care companion designed to help expecting mothers track their health, baby milestones, and stay connected with healthcare providers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
