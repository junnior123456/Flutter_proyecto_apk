/// Pantalla de match de mascotas con IA (visión)
/// El usuario toma/elige la foto de un perro y PawBot la compara contra las
/// mascotas registradas para encontrar las más parecidas (ranking por similitud).
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../domain/entities/pet.dart';

class PetMatchScreen extends StatefulWidget {
  const PetMatchScreen({super.key});

  @override
  State<PetMatchScreen> createState() => _PetMatchScreenState();
}

class _PetMatchScreenState extends State<PetMatchScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  static const int _maxCandidates = 6; // el backend también limita a 6

  final AiService _aiService = AiService();
  final PetService _petService = PetService();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  Uint8List? _bytes;
  bool _isLoading = false;
  String? _status;
  String? _error;
  List<_MatchRow> _results = [];

  Future<void> _pick(ImageSource source) async {
    try {
      final img = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (img == null) return;
      final bytes = await img.readAsBytes();
      setState(() {
        _image = img;
        _bytes = bytes;
        _results = [];
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'No se pudo abrir la imagen: $e');
    }
  }

  Future<void> _search() async {
    if (_bytes == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
      _status = 'Cargando mascotas registradas...';
    });
    try {
      final pets = await _petService.getAllPets();
      // Solo candidatos con foto accesible por URL
      final candidatesPets = pets
          .where((p) => p.imageUrl.isNotEmpty && p.imageUrl.startsWith('http'))
          .take(_maxCandidates)
          .toList();

      if (candidatesPets.isEmpty) {
        setState(() {
          _error = 'No hay mascotas con foto para comparar.';
          _isLoading = false;
        });
        return;
      }

      setState(() => _status =
          'Comparando con ${candidatesPets.length} mascota(s) con IA...');

      final mime = _image?.mimeType ?? 'image/jpeg';
      final dataUrl = 'data:$mime;base64,${base64Encode(_bytes!)}';
      final candidates = candidatesPets
          .map((p) => {'id': p.id, 'imageUrl': p.imageUrl})
          .toList();

      final matches = await _aiService.matchPets(dataUrl, candidates);

      final byId = {for (final p in candidatesPets) p.id: p};
      final rows = <_MatchRow>[];
      for (final m in matches) {
        final pet = byId[m['candidateId']];
        if (pet == null) continue;
        rows.add(_MatchRow(
          pet: pet,
          score: (m['score'] is num) ? (m['score'] as num).toInt() : 0,
          reason: m['reason']?.toString() ?? '',
        ));
      }
      setState(() {
        _results = rows;
        _status = null;
      });
    } catch (e) {
      setState(() => _error = 'Error en la búsqueda: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐕 Buscar coincidencias'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildImagePreview(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_bytes == null || _isLoading) ? null : _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Buscando...' : 'Buscar coincidencias'),
            ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              _buildError(_error!),
            ],
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Resultados (mayor a menor parecido):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._results.map(_buildMatchCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _brand.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text('🔎', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Viste este perro?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                    'Sube su foto y PawBot la comparará con las mascotas registradas para encontrar coincidencias.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: _bytes != null
          ? Image.memory(_bytes!, fit: BoxFit.cover)
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Sin foto seleccionada',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
    );
  }

  Widget _buildMatchCard(_MatchRow row) {
    final color = row.score >= 70
        ? Colors.green
        : (row.score >= 40 ? Colors.orange : Colors.grey);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                row.pet.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.pets, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(row.pet.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${row.score}%',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (row.pet.breed.isNotEmpty)
                    Text(row.pet.breed,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(row.reason, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _MatchRow {
  final Pet pet;
  final int score;
  final String reason;
  _MatchRow({required this.pet, required this.score, required this.reason});
}
