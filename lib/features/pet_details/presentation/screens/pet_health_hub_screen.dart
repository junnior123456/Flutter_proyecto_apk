/// Módulo 3 — Hub del Expediente de Salud.
/// Agrupa las secciones del expediente para una navegación clara.
import 'package:flutter/material.dart';
import 'pet_vaccinations_screen.dart';
import 'pet_weights_screen.dart';
import 'pet_allergies_screen.dart';
import 'pet_medications_screen.dart';
import 'pet_medical_records_screen.dart';
import 'pet_profile_qr_screen.dart';
import 'pet_ai_chat_screen.dart';

class PetHealthHubScreen extends StatelessWidget {
  final int petId;
  final String petName;
  const PetHealthHubScreen({super.key, required this.petId, required this.petName});

  static const Color _brand = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final tiles = <_HubTile>[
      _HubTile('Cartilla de vacunas', 'Vacunas y próximas dosis', Icons.vaccines,
          () => PetVaccinationsScreen(petId: petId, petName: petName)),
      _HubTile('Control de peso', 'Peso actual e historial', Icons.monitor_weight_outlined,
          () => PetWeightsScreen(petId: petId, petName: petName)),
      _HubTile('Alergias', 'Alérgenos y severidad', Icons.warning_amber_rounded,
          () => PetAllergiesScreen(petId: petId, petName: petName)),
      _HubTile('Medicación', 'Tratamientos activos e historial', Icons.medication,
          () => PetMedicationsScreen(petId: petId, petName: petName)),
      _HubTile('Historia clínica', 'Consultas, cirugías y exámenes', Icons.description_outlined,
          () => PetMedicalRecordsScreen(petId: petId, petName: petName)),
      _HubTile('Datos & QR', 'Especie, microchip y código QR', Icons.qr_code_2,
          () => PetProfileQrScreen(petId: petId, petName: petName)),
      _HubTile('Preguntar a PawBot', 'IA que lee el expediente (con tu permiso)',
          Icons.smart_toy_outlined,
          () => PetAiChatScreen(petId: petId, petName: petName)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('🩺 Expediente · $petName'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _brand.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Expediente digital de salud. Toca una sección para ver o registrar información.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...tiles.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: _brand.withOpacity(0.12),
                      child: Icon(t.icon, color: _brand),
                    ),
                    title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(t.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => t.build()),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _HubTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() build;
  _HubTile(this.title, this.subtitle, this.icon, this.build);
}
