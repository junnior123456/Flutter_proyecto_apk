/// Pantalla de análisis de foto de perro con IA (visión)
/// El usuario toma o elige una foto y PawBot identifica raza, color, tamaño y señas.
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ai_service.dart';

class AnalyzePhotoScreen extends StatefulWidget {
  const AnalyzePhotoScreen({super.key});

  @override
  State<AnalyzePhotoScreen> createState() => _AnalyzePhotoScreenState();
}

class _AnalyzePhotoScreenState extends State<AnalyzePhotoScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final AiService _aiService = AiService();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  Uint8List? _bytes;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

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
        _result = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'No se pudo abrir la imagen: $e');
    }
  }

  Future<void> _analyze() async {
    if (_bytes == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });
    try {
      final mime = _image?.mimeType ?? 'image/jpeg';
      final dataUrl = 'data:$mime;base64,${base64Encode(_bytes!)}';
      final analysis = await _aiService.analyzePhoto(dataUrl);
      setState(() => _result = analysis);
    } catch (e) {
      setState(() => _error = 'Error al analizar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Identificar raza por foto'),
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
              onPressed: (_bytes == null || _isLoading) ? null : _analyze,
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
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Analizando...' : 'Identificar con IA'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _buildError(_error!),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResult(_result!),
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
          Text('🐕', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analiza a tu perro',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                    'Toma o elige una foto y PawBot identificará la raza, color, tamaño y señas particulares.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
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

  Widget _buildResult(Map<String, dynamic> r) {
    final confianza = (r['confianza'] is num) ? (r['confianza'] as num).toInt() : 0;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: _brand),
                SizedBox(width: 8),
                Text('Resultado del análisis',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 24),
            _row('🐩 Raza', r['raza']?.toString()),
            _row('🎨 Color', r['color']?.toString()),
            _row('📏 Tamaño', r['tamano']?.toString()),
            _row('🎂 Edad aprox.', r['edad_aproximada']?.toString()),
            _row('✨ Señas', r['senas_particulares']?.toString()),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Confianza: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: confianza / 100,
                    minHeight: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: confianza >= 60 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Text('$confianza%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
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
