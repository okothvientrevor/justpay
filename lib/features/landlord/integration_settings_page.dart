import 'package:flutter/material.dart';

class IntegrationSettingsPage extends StatelessWidget {
  const IntegrationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integration Settings')),
      body: const Center(child: Text('Integration Settings Page')),
    );
  }
}
