/// Módulo 3 — IA contextual: PawBot responde sobre el expediente de UNA mascota.
/// Sin consentimiento responde genérico y ofrece activarlo (no bloquea el chat).
import 'package:flutter/material.dart';
import '../../../../core/services/pet_ai_service.dart';

class _Msg {
  final String text;
  final bool isUser;
  final bool usedRecord;
  _Msg(this.text, this.isUser, {this.usedRecord = false});
}

class PetAiChatScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetAiChatScreen({super.key, required this.petId, required this.petName});

  @override
  State<PetAiChatScreen> createState() => _PetAiChatScreenState();
}

class _PetAiChatScreenState extends State<PetAiChatScreen> {
  static const Color _brand = Color(0xFF6C63FF);

  final PetAiService _service = PetAiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_Msg> _messages = [];
  bool _sending = false;
  bool? _consent; // null mientras carga
  bool _togglingConsent = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
      '¡Hola! Soy PawBot 🐶 Pregúntame lo que quieras sobre ${widget.petName}.',
      false,
    ));
    _loadConsent();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadConsent() async {
    try {
      final c = await _service.getConsent(widget.petId);
      if (mounted) setState(() => _consent = c);
    } catch (_) {
      if (mounted) setState(() => _consent = false);
    }
  }

  Future<void> _setConsent(bool enabled) async {
    setState(() => _togglingConsent = true);
    try {
      final result = await _service.setConsent(widget.petId, enabled);
      if (!mounted) return;
      setState(() => _consent = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result
              ? 'PawBot ya puede leer el expediente de ${widget.petName}'
              : 'PawBot ya no tiene acceso al expediente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _togglingConsent = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Turnos previos para que PawBot recuerde el hilo (últimos 10).
  List<Map<String, String>> _history() {
    final turns = _messages
        .where((m) => m.text.trim().isNotEmpty)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();
    return turns.length > 10 ? turns.sublist(turns.length - 10) : turns;
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final history = _history(); // antes de añadir el mensaje actual
    setState(() {
      _messages.add(_Msg(text, true));
      _sending = true;
      _controller.clear();
    });
    _scrollToEnd();

    try {
      final reply = await _service.petChat(widget.petId, text, history: history);
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(reply.response, false, usedRecord: reply.usedRecord));
        if (reply.consentRequired) _consent = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(_Msg('😔 $e', false)));
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  /// Aviso que aparece SOLO si falta el consentimiento.
  Widget _consentBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.amber, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Respuestas personalizadas',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Activa el acceso al expediente y PawBot podrá responder sobre '
                  'las vacunas, el peso, las alergias y la medicación de ${widget.petName}.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _togglingConsent
              ? const SizedBox(
                  width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton(
                  onPressed: () => _setConsent(true),
                  style: TextButton.styleFrom(foregroundColor: _brand),
                  child: const Text('Activar'),
                ),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          // Burbuja del bot: color del tema, para que el modo oscuro funcione.
          color: m.isUser ? _brand : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              m.text,
              style: TextStyle(
                color: m.isUser ? Colors.white : scheme.onSurface,
                fontSize: 14.5,
              ),
            ),
            if (!m.isUser && m.usedRecord) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_shared_outlined, size: 13, color: _brand),
                  const SizedBox(width: 4),
                  Text(
                    'Basado en el expediente',
                    style: TextStyle(
                        fontSize: 10.5, color: _brand, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤖 PawBot · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        actions: [
          if (_consent == true)
            IconButton(
              tooltip: 'Revocar acceso al expediente',
              icon: const Icon(Icons.lock_open),
              onPressed: _togglingConsent ? null : () => _setConsent(false),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_consent == false) _consentBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('🐶 Pensando...', style: TextStyle(color: Colors.grey)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Pregunta sobre ${widget.petName}...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _brand,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sending ? null : _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
