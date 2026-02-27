import 'package:flutter/material.dart';
import '../../controllers/exercise_controller.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/patient_model.dart';
import '../../models/diet_model.dart';
import '../../widgets/exercise_card.dart';
import '../../controllers/diet_log_controller.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<DayDiet> weeklyDiet = [
    DayDiet(day: 'Mon', meals: [
      DietMeal(time: 'Breakfast', meal: 'Oatmeal with fruit', suggestion: 'Rich in fiber'),
      DietMeal(time: 'Lunch', meal: 'Grilled chicken salad', suggestion: 'High protein'),
      DietMeal(time: 'Dinner', meal: 'Baked salmon & veg', suggestion: 'Omega-3 rich'),
    ]),
    DayDiet(day: 'Tue', meals: [
      DietMeal(time: 'Breakfast', meal: 'Greek yogurt & nuts', suggestion: 'Calcium boost'),
      DietMeal(time: 'Lunch', meal: 'Quinoa bowl with eggs', suggestion: 'Complete protein'),
      DietMeal(time: 'Dinner', meal: 'Lentil soup & roti', suggestion: 'Iron & folate'),
    ]),
    DayDiet(day: 'Wed', meals: [
      DietMeal(time: 'Breakfast', meal: 'Smoothie with spinach', suggestion: 'Green power'),
      DietMeal(time: 'Lunch', meal: 'Whole grain sandwich', suggestion: 'Fuel for day'),
      DietMeal(time: 'Dinner', meal: 'Stir-fry tofu', suggestion: 'Plant protein'),
    ]),
    DayDiet(day: 'Thu', meals: [
      DietMeal(time: 'Breakfast', meal: 'Poha with peanuts', suggestion: 'Light & tasty'),
      DietMeal(time: 'Lunch', meal: 'Fish curry & rice', suggestion: 'Healthy fats'),
      DietMeal(time: 'Dinner', meal: 'Vegetable khichdi', suggestion: 'Easy digestion'),
    ]),
    DayDiet(day: 'Fri', meals: [
      DietMeal(time: 'Breakfast', meal: 'Boiled eggs & toast', suggestion: 'Morning protein'),
      DietMeal(time: 'Lunch', meal: 'Chickpea salad wrap', suggestion: 'Zinc & fiber'),
      DietMeal(time: 'Dinner', meal: 'Grilled panner & veg', suggestion: 'Calcium rich'),
    ]),
    DayDiet(day: 'Sat', meals: [
      DietMeal(time: 'Breakfast', meal: 'Fruit salad & seeds', suggestion: 'Antioxidants'),
      DietMeal(time: 'Lunch', meal: 'Mutton stew (lean)', suggestion: 'B12 source'),
      DietMeal(time: 'Dinner', meal: 'Pasta with veggies', suggestion: 'Comfort meal'),
    ]),
    DayDiet(day: 'Sun', meals: [
      DietMeal(time: 'Breakfast', meal: 'Pancakes with honey', suggestion: 'Treatment day'),
      DietMeal(time: 'Lunch', meal: 'Paneer tikka & salad', suggestion: 'Protein packed'),
      DietMeal(time: 'Dinner', meal: 'Milk & light snack', suggestion: 'Better sleep'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientModel?>(
      stream: PatientController().getPatientStream(),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        final exercises = ExerciseController().getExercises(patient?.pregnancyWeek ?? 0);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(SettingsController().tr('Exercise & Diet Plan')),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFF48FB1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFF48FB1),
              tabs: [
                Tab(text: SettingsController().tr('Exercises'), icon: const Icon(Icons.fitness_center)),
                Tab(text: SettingsController().tr('Diet Plan'), icon: const Icon(Icons.restaurant_menu)),
              ],
            ),
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExercisesTab(exercises),
                    _buildDietTab(patient),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildExercisesTab(List<dynamic> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return ExerciseCard(
          exercise: exercises[index],
          onTap: () => Navigator.pushNamed(context, '/exerciseDetail', arguments: exercises[index]),
        );
      },
    );
  }

  void _showLogMealDialog() {
    final mealController = TextEditingController();
    String selectedMealType = 'Breakfast';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(SettingsController().tr('Log Today\'s Meal')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedMealType,
                isExpanded: true,
                onChanged: (val) => setDialogState(() => selectedMealType = val!),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mealController,
                decoration: InputDecoration(
                  hintText: SettingsController().tr('What did you eat?'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(SettingsController().tr('Cancel'))),
            ElevatedButton(
              onPressed: () async {
                if (mealController.text.isNotEmpty) {
                  await DietLogController().logMeal(selectedMealType, mealController.text);
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(SettingsController().tr('Meal logged successfully!'))),
                  );
                }
              },
              child: Text(SettingsController().tr('Log Meal')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietTab(PatientModel? patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDietHeader(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SettingsController().tr('Weekly Nutrition Roadmap'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showLogMealDialog,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(SettingsController().tr('Log Meal')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48FB1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDietTable(patient),
        ],
      ),
    );
  }

  Widget _buildDietHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAD1457), Color(0xFFD81B60)], // Professional Deep Pink to Crimson
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF48FB1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SettingsController().tr('Healthy Eating Tip'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  SettingsController().tr('Drink at least 8-10 glasses of water daily to stay hydrated.'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietTable(PatientModel? patient) {
    final Map<String, Map<String, String>> dietData = patient?.dietPlan ?? {};
    final bool hasCustomDiet = dietData.isNotEmpty;

    final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final List<String> shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFCE4EC).withOpacity(0.3)),
          columns: [
            DataColumn(label: Text(SettingsController().tr('Day'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(SettingsController().tr('Breakfast'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(SettingsController().tr('Lunch'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(SettingsController().tr('Dinner'), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(7, (index) {
            final day = days[index];
            final shortDay = shortDays[index];
            
            if (hasCustomDiet && dietData.containsKey(day)) {
              final meals = dietData[day]!;
              return DataRow(cells: [
                DataCell(Text(SettingsController().tr(shortDay), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(meals['Breakfast'] ?? '-', style: const TextStyle(fontSize: 13))),
                DataCell(Text(meals['Lunch'] ?? '-', style: const TextStyle(fontSize: 13))),
                DataCell(Text(meals['Dinner'] ?? '-', style: const TextStyle(fontSize: 13))),
              ]);
            } else {
              // Fallback to default weeklyDiet
              final dayDiet = weeklyDiet[index];
              return DataRow(cells: [
                DataCell(Text(dayDiet.day, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(_buildMealCell(dayDiet.meals[0])),
                DataCell(_buildMealCell(dayDiet.meals[1])),
                DataCell(_buildMealCell(dayDiet.meals[2])),
              ]);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildMealCell(DietMeal meal) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(meal.meal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(meal.suggestion, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
