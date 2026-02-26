import 'package:flutter/material.dart';

/// Home Config Management Page
class HomeConfigManagementPage extends StatefulWidget {
  const HomeConfigManagementPage({super.key});

  @override
  State<HomeConfigManagementPage> createState() =>
      _HomeConfigManagementPageState();
}

class _HomeConfigManagementPageState extends State<HomeConfigManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Config Management')),
      body: const Center(child: Text('Home Config Management Page')),
    );
  }
}
