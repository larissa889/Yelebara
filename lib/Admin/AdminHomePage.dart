import 'package:flutter/material.dart';
import 'package:yelebara_mobile/widgets/YelebaraLogo.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const YelebaraLogo(asTitle: true, size: 28),
        centerTitle: true,
      ),
      body: const Center(child: Text('Bienvenue, Admin')),
    );
  }
}


