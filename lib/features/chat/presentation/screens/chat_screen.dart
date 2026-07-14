import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/auth_service.dart';

/// Pantalla de conversación con sondeo cada 3 s para traer mensajes nuevos.
class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String title;
  const ChatScreen({super.key, required this.conversationId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = ChatService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  int _lastId = 0;
  int? _myId;
  Timer? _timer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final me = await AuthService().getCurrentUser();
    _myId = int.tryParse('${me?['id']}');
    await _cargarInicial();
    await _service.markRead(widget.conversationId);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _sondear());
  }

  Future<void> _cargarInicial() async {
    final msgs = await _service.getMessages(widget.conversationId);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      if (msgs.isNotEmpty) _lastId = msgs.last['id'] as int;
    });
    _bajar();
  }

  Future<void> _sondear() async {
    final nuevos = await _service.getMessages(widget.conversationId, afterId: _lastId);
    if (!mounted || nuevos.isEmpty) return;
    setState(() {
      _messages.addAll(nuevos);
      _lastId = nuevos.last['id'] as int;
    });
    _bajar();
    await _service.markRead(widget.conversationId);
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    final msg = await _service.sendMessage(widget.conversationId, texto);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (msg != null) {
        _messages.add(msg);
        _lastId = msg['id'] as int;
      }
    });
    _bajar();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Escribe el primer mensaje 👋'))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final mio = int.tryParse('${m['senderId']}') == _myId;
                      return Align(
                        alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: mio ? primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${m['body']}',
                            style: TextStyle(
                                color: mio ? Colors.white : null),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        hintText: 'Mensaje…',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: _sending ? null : _enviar,
                    icon: const Icon(Icons.send),
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
