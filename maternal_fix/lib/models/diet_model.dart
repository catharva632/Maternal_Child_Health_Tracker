class DietMeal {
  final String time;
  final String meal;
  final String suggestion;

  DietMeal({
    required this.time,
    required this.meal,
    required this.suggestion,
  });
}

class DayDiet {
  final String day;
  final List<DietMeal> meals;

  DayDiet({
    required this.day,
    required this.meals,
  });
}
