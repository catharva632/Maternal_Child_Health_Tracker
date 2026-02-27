import 'package:flutter/material.dart';
import '../../controllers/exercise_controller.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';
import '../../models/diet_model.dart';
import '../../widgets/exercise_card.dart';

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
            title: const Text('Exercise & Diet Plan'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFF48FB1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFF48FB1),
              tabs: const [
                Tab(text: 'Exercises', icon: Icon(Icons.fitness_center)),
                Tab(text: 'Diet Plan', icon: Icon(Icons.restaurant_menu)),
              ],
            ),
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExercisesTab(exercises),
                    _buildDietTab(),
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

  Widget _buildDietTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDietHeader(),
          const SizedBox(height: 24),
          const Text(
            'Weekly Nutrition Roadmap',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDietTable(),
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
              children: const [
                Text(
                  'Healthy Eating Tip',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  'Drink at least 8-10 glasses of water daily to stay hydrated.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietTable() {
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
          columns: const [
            DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Breakfast', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Lunch', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Dinner', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: weeklyDiet.map((dayDiet) {
            return DataRow(cells: [
              DataCell(Text(dayDiet.day, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(_buildMealCell(dayDiet.meals[0])),
              DataCell(_buildMealCell(dayDiet.meals[1])),
              DataCell(_buildMealCell(dayDiet.meals[2])),
            ]);
          }).toList(),
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
