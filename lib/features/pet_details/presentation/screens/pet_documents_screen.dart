/// Módulo 3 — Documentos y galería del expediente.
///
/// Los archivos son privados: cada imagen se pide con la cabecera Authorization
/// y los PDF se descargan a un temporal antes de abrirlos con el visor del sistema.
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/services/document_service.dart';

class PetDocumentsScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetDocumentsScreen({super.key, required this.petId, required this.petName});

  @override
  State<PetDocumentsScreen> createState() => _PetDocumentsScreenState();
}

class _PetDocumentsScreenState extends State<PetDocumentsScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final DocumentService _service = DocumentService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  Map<String, String> _headers = {};

  static const Map<String, String> _catLabels = {
    'radiografia': 'Radiografía',
    'analisis': 'Análisis',
    'receta': 'Receta',
    'foto': 'Foto',
    'otro': 'Otro',
  };

  bool _isImage(Map<String, dynamic> d) =>
      (d['mimeType']?.toString() ?? '').startsWith('image/');

  List<Map<String, dynamic>> get _images => _items.where(_isImage).toList();
  List<Map<String, dynamic>> get _files => _items.where((d) => !_isImage(d)).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final headers = await _service.authHeaders();
      final data = await _service.list(widget.petId);
      if (!mounted) return;
      setState(() { _headers = headers; _items = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'No se pudieron cargar los documentos.'; _loading = false; });
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ---------- Subida ----------

  Future<void> _pickAndUpload(String source) async {
    String? path;
    try {
      if (source == 'pdf') {
        // file_picker 11: `pickFiles` es estático (ya no existe `FilePicker.platform`).
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: kDocumentExtensions,
        );
        path = result?.files.single.path;
      } else {
        final picked = await ImagePicker().pickImage(
          source: source == 'camara' ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 85,
        );
        path = picked?.path;
      }
    } catch (_) {
      _toast('No se pudo abrir el selector');
      return;
    }
    if (path == null) return;

    final meta = await _askMeta(source == 'pdf' ? 'otro' : 'foto');
    if (meta == null) return;

    _toast('Subiendo…');
    try {
      await _service.upload(
        widget.petId,
        path: path,
        title: meta.$1,
        category: meta.$2,
      );
      await _load();
      _toast('Documento subido ✅');
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Pide título y categoría. Devuelve (título, categoría).
  Future<(String, String)?> _askMeta(String initialCategory) async {
    final titleCtrl = TextEditingController();
    String category = initialCategory;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Datos del documento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                maxLength: 150,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Título *'),
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: kDocumentCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(_catLabels[c] ?? c)))
                    .toList(),
                onChanged: (v) => setD(() => category = v ?? 'otro'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _brand, foregroundColor: Colors.white),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Subir'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return null;
    return (titleCtrl.text.trim(), category);
  }

  Future<void> _openSourceSheet() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(ctx, 'camara'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, 'galeria'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Subir un PDF o imagen'),
              subtitle: const Text('Desde los archivos del dispositivo'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickAndUpload(source);
  }

  // ---------- Acciones ----------

  Future<void> _delete(Map<String, dynamic> d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar el documento?'),
        content: Text('Se borrará "${d['title']}" del expediente de ${widget.petName}. '
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.remove(widget.petId, d['id'] as int);
      await _load();
      _toast('Documento eliminado');
    } catch (_) {
      _toast('No se pudo eliminar');
    }
  }

  Future<void> _openFile(Map<String, dynamic> d) async {
    _toast('Abriendo…');
    try {
      final path = await _service.downloadToTemp(widget.petId, d);
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        _toast('No hay ninguna app para abrir este archivo');
      }
    } catch (_) {
      _toast('No se pudo abrir el documento');
    }
  }

  void _viewImage(Map<String, dynamic> d) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(d['title']?.toString() ?? ''),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                _service.fileUrl(widget.petId, d['id'] as int),
                headers: _headers,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 64),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📎 Documentos · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSourceSheet,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Subir'),
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(children: [
        const SizedBox(height: 120),
        Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 12),
        Center(child: OutlinedButton(onPressed: _load, child: const Text('Reintentar'))),
      ]);
    }
    if (_items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 110),
        Icon(Icons.folder_open_outlined, size: 56, color: scheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Sin documentos.\nSube radiografías, análisis o recetas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('🔒 Solo tú y tu veterinario pueden verlos',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Icon(Icons.lock_outline, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Privados: solo tú, un administrador o tu veterinario pueden abrirlos.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
        ]),
        const SizedBox(height: 16),
        if (_images.isNotEmpty) ...[
          Text('Galería (${_images.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _images.length,
            itemBuilder: (_, i) => _thumb(_images[i]),
          ),
          const SizedBox(height: 20),
        ],
        if (_files.isNotEmpty) ...[
          Text('Documentos (${_files.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ..._files.map(_fileTile),
        ],
      ],
    );
  }

  Widget _thumb(Map<String, dynamic> d) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _viewImage(d),
      onLongPress: () => _delete(d),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: scheme.surfaceContainerHighest),
            Image.network(
              _service.fileUrl(widget.petId, d['id'] as int),
              headers: _headers,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: Colors.black.withOpacity(0.55),
                child: Text(
                  d['title']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileTile(Map<String, dynamic> d) {
    final scheme = Theme.of(context).colorScheme;
    final cat = _catLabels[d['category']?.toString()] ?? 'Otro';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.12),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
        ),
        title: Text(d['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$cat · ${_size(d['sizeBytes'] as int? ?? 0)}',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        onTap: () => _openFile(d),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
          onPressed: () => _delete(d),
        ),
      ),
    );
  }
}
