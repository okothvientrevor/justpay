import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';

// Add routes for landlord login and signup pages
import 'features/auth/landlord_auth_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: EcoCardApp()));
}

class EcoCardApp extends StatelessWidget {
  const EcoCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoCard Property Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _SplashScreen(),
      routes: {
        ...AppRoutes.routes,
        '/landlord-login': (context) => const LandlordLoginPage(),
        '/landlord-signup': (context) => const LandlordSignUpPage(),
      },
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen({super.key});

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('landlord_token');
    await Future.delayed(const Duration(milliseconds: 500)); // for splash effect
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/landlord-dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/landlord-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF181F2A),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
