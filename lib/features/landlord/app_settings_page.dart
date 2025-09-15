import 'package:flutter/material.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings & Notifications')),
      body: const Center(child: Text('App Settings & Notifications Page')),
    );
  }
}
