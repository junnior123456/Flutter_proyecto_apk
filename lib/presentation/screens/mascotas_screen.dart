import 'package:flutter/material.dart';

class MascotasScreen extends StatelessWidget {
  const MascotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23486A),
        title: const Text("Mascotas"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔸 Dar en Adopción
            _buildSection(
              context: context,
              title: "Dar en Adopción",
              onAddPressed: () {
                // TODO: Abrir formulario de adopción
              },
              child: _buildEmptyMessage(
                "Aquí aparecerán los perritos en adopción.",
              ),
            ),
            const SizedBox(height: 24),

            // 🔻 Perritos en Riesgo
            _buildSection(
              context: context,
              title: "Perritos en Riesgo",
              onAddPressed: () {
                // TODO: Abrir formulario de reporte en riesgo
              },
              child: _buildEmptyMessage(
                "Aquí aparecerán los perritos en riesgo.",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required VoidCallback onAddPressed,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + botón ➕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onAddPressed,
                icon: const Icon(
                  Icons.add_circle,
                  color: Color(0xFFDB9A04),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String text) {
    return Column(
      children: [
        const Icon(Icons.pets, size: 50, color: Colors.grey),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
