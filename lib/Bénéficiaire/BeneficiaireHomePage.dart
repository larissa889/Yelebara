import 'package:flutter/material.dart';
import 'package:yelebara_mobile/widgets/YelebaraLogo.dart';

class BeneficiaireHomePage extends StatelessWidget {
  const BeneficiaireHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const YelebaraLogo(asTitle: true, size: 28),
        centerTitle: true,
      ),
      body: const Center(child: Text('Bienvenue, Bénéficiaire')),
    );
  }
}


