import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF23486A),
      appBar: AppBar(
        title: const Text('PawFinder'),
        backgroundColor: const Color(0xFF23486A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),

            // 🔶 Botón para Reportar Mascota
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB9A04),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.reportPet); // ✅ CORRECTO
              },
              child: const Text(
                '🐾 Reportar Mascota',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),

            // 🔶 Botón para ver mascotas en adopción
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB9A04),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.pets); // ✅ CORRECTO
              },
              child: const Text(
                '🏠 Ver Mascotas en Adopción',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
