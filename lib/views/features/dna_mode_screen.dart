import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/gamification_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/patient_model.dart';

class DnaModeScreen extends StatefulWidget {
  const DnaModeScreen({super.key});

  @override
  State<DnaModeScreen> createState() => _DnaModeScreenState();
}

class _DnaModeScreenState extends State<DnaModeScreen> {
  String? _diet;
  bool? _isWorking;
  bool? _isHighRisk;
  bool? _isFirstBaby;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SettingsController().tr('Pregnancy DNA Mode'))),
      body: StreamBuilder<PatientModel?>(
        stream: PatientController().getPatientStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final patient = snapshot.data;
          // Pre-fill if data already exists
          if (patient != null && _diet == null) {
            _diet = patient.diet;
            _isWorking = patient.isWorkingProfessional;
            _isHighRisk = patient.isHighRisk;
            _isFirstBaby = patient.isFirstBaby;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntro(),
                const SizedBox(height: 32),
                _buildQuestionCard(
                  title: SettingsController().tr("1. Diet Preference"),
                  options: [SettingsController().tr("Vegetarian"), SettingsController().tr("Non-Veg")],
                  selectedValue: _diet == null ? null : SettingsController().tr(_diet!),
                  onChanged: (val) {
                    if (val == SettingsController().tr("Vegetarian")) setState(() => _diet = "Vegetarian");
                    if (val == SettingsController().tr("Non-Veg")) setState(() => _diet = "Non-Veg");
                  },
                ),
                _buildQuestionCard(
                  title: SettingsController().tr("2. Are you a working professional?"),
                  options: [SettingsController().tr("Yes"), SettingsController().tr("No")],
                  selectedValue: _isWorking == null ? null : (_isWorking! ? SettingsController().tr("Yes") : SettingsController().tr("No")),
                  onChanged: (val) => setState(() => _isWorking = val == SettingsController().tr("Yes")),
                ),
                _buildQuestionCard(
                  title: SettingsController().tr("3. Is this a high-risk pregnancy?"),
                  options: [SettingsController().tr("Yes"), SettingsController().tr("No")],
                  selectedValue: _isHighRisk == null ? null : (_isHighRisk! ? SettingsController().tr("Yes") : SettingsController().tr("No")),
                  onChanged: (val) => setState(() => _isHighRisk = val == SettingsController().tr("Yes")),
                ),
                _buildQuestionCard(
                  title: SettingsController().tr("4. Is this your first baby?"),
                  options: [SettingsController().tr("Yes"), SettingsController().tr("No")],
                  selectedValue: _isFirstBaby == null ? null : (_isFirstBaby! ? SettingsController().tr("Yes") : SettingsController().tr("No")),
                  onChanged: (val) => setState(() => _isFirstBaby = val == SettingsController().tr("Yes")),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveDnaProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(SettingsController().tr("Generate My Personalized Path"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    SettingsController().tr("This helps us tailor your milestones and tips."),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SettingsController().tr("Let's create your Personalized Pregnancy Path"),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          SettingsController().tr("Every pregnancy is unique. Answer these quick questions to unlock a plan that works for you."),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: options.map((opt) {
                final isSelected = selectedValue == opt;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => onChanged(opt),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
                        foregroundColor: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(opt),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDnaProfile() async {
    if (_diet == null || _isWorking == null || _isHighRisk == null || _isFirstBaby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SettingsController().tr("Please answer all questions"))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await PatientController().updateDnaProfile(
        diet: _diet!,
        isWorking: _isWorking!,
        isHighRisk: _isHighRisk!,
        isFirstBaby: _isFirstBaby!,
      );
      await GamificationController().unlockBadge('dna_dna');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SettingsController().tr("Profile Updated! Your path is being personalized."))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update Failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
