import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:home_widget/home_widget.dart';
import 'controllers/theme_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/sos_controller.dart';
import 'models/patient_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/auth/welcome_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_choice_screen.dart';
import 'views/signup/signup_step1.dart';
import 'views/signup/signup_step2.dart';
import 'views/signup/signup_step3.dart';
import 'views/signup/doctor_signup.dart';
import 'views/signup/select_doctor_screen.dart';
import 'views/dashboard/patient_dashboard.dart';
import 'views/dashboard/doctor_dashboard.dart';
import 'views/features/milestones_screen.dart';
import 'views/features/hospital_schedule_screen.dart';
import 'views/features/llm_screen.dart';
import 'views/features/exercise_screen.dart';
import 'views/features/exercise_detail_screen.dart';
import 'views/features/emergency_map_screen.dart';
import 'views/menu/settings_screen.dart';
import 'views/menu/report_screen.dart';
import 'views/menu/about_screen.dart';
import 'views/menu/contacts_screen.dart';
import 'views/menu/profile_screen.dart';
import 'views/features/dna_mode_screen.dart';
import 'views/features/weekly_development_detail_screen.dart';
import 'views/features/mood_tracker_screen.dart';
import 'views/features/badges_screen.dart';
import 'views/features/cultural_wisdom_screen.dart';

import 'views/auth/auth_wrapper.dart';

// Debug flag to bypass authentication flow for testing Mood Tracker
const bool kBypassAuth = false;

@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri?.host == 'sos_action') {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final patient = PatientModel.fromMap(doc.data()!);
        await SOSController().startSOS(patient);
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Register background callback for home widget
  HomeWidget.registerBackgroundCallback(homeWidgetBackgroundCallback);
  
  runApp(const MaternalHealthTrackerApp());
}

class MaternalHealthTrackerApp extends StatefulWidget {
  const MaternalHealthTrackerApp({super.key});

  @override
  State<MaternalHealthTrackerApp> createState() => _MaternalHealthTrackerAppState();
}

class _MaternalHealthTrackerAppState extends State<MaternalHealthTrackerApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _handleInitialLaunch();
    _setupHomeWidgetListener();
  }

  void _handleInitialLaunch() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleWidgetAction(uri);
    }
  }

  void _setupHomeWidgetListener() {
    HomeWidget.widgetClicked.listen(_handleWidgetAction);
  }

  void _handleWidgetAction(Uri? uri) {
    if (uri?.host == 'sos_action') {
      // Small delay to ensure navigator is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigatorKey.currentState?.pushNamed('/emergencyMap');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController().themeMode,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: SettingsController().language,
          builder: (context, lang, child) {
            return MaterialApp(
              key: ValueKey(lang), // Force rebuild of the entire app on language change
              navigatorKey: _navigatorKey,
              title: 'Maternal Child Health Tracker',
              themeMode: themeMode,
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              home: const AuthWrapper(),
              routes: _getRoutes(),
            );
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF48FB1),
        primary: const Color(0xFFF48FB1),
        secondary: const Color(0xFFFCE4EC),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: Colors.white,
        surfaceTintColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF48FB1),
        brightness: Brightness.dark,
        primary: const Color(0xFFF48FB1),
        secondary: const Color(0xFF303030),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: Colors.grey.shade900,
        surfaceTintColor: Colors.black,
      ),
    );
  }

  Map<String, WidgetBuilder> _getRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/signupChoice': (context) => const SignupChoiceScreen(),
      '/signup1': (context) => const SignupStep1(),
      '/signup2': (context) => const SignupStep2(),
      '/signup3': (context) => const SignupStep3(),
      '/doctorSignup': (context) => const DoctorSignup(),
      '/selectDoctor': (context) => const SelectDoctorScreen(),
      '/dashboard': (context) => const PatientDashboard(),
      '/doctorDashboard': (context) => const DoctorDashboard(),
      '/milestones': (context) => const MilestonesScreen(),
      '/dnaMode': (context) => const DnaModeScreen(),
      '/weeklyDevelopment': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return WeeklyDevelopmentDetailScreen(week: args['week'] ?? 0);
      },
      '/moodTracker': (context) => const MoodTrackerScreen(),
      '/badges': (context) => const BadgesScreen(),
      '/culturalWisdom': (context) => const CulturalWisdomScreen(),
      '/hospital': (context) => const HospitalScheduleScreen(),
      '/chatbot': (context) => const LlmScreen(),
      '/exercise': (context) => const ExerciseScreen(),
      '/exerciseDetail': (context) => const ExerciseDetailScreen(),
      '/emergencyMap': (context) => EmergencyMapScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/report': (context) => const ReportScreen(),
      '/about': (context) => const AboutScreen(),
      '/contacts': (context) => const ContactsScreen(),
      '/profile': (context) => const ProfileScreen(),
    };
  }
}
