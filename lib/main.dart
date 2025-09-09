import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
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
      initialRoute: '/login',
      routes: {
        ...AppRoutes.routes,
        '/landlord-login': (context) => const LandlordLoginPage(),
        '/landlord-signup': (context) => const LandlordSignUpPage(),
      },
    );
  }
}
