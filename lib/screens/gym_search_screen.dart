import 'package:flutter/material.dart';

class GymSearchScreen extends StatelessWidget {
  const GymSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Search')),
      body: const Center(child: Text('Gym Search Screen')),
    );
  }
}
