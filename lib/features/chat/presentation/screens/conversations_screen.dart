import 'package:flutter/material.dart';
import '../../../../core/services/chat_service.dart';
import 'chat_screen.dart';

/// Lista de conversaciones del usuario (tipo bandeja de Messenger).
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _service = ChatService();
  List<Map<String, dynamic>> _convs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final convs = await _service.listConversations();
    if (!mounted) return;
    setState(() {
      _convs = convs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _convs.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Center(child: Text('Aún no tienes conversaciones')),
                    ],
                  )
                : ListView.separated(
                    itemCount: _convs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = _convs[i];
                      final other = Map<String, dynamic>.from(c['other'] ?? {});
                      final nombre = [other['name'], other['lastname']]
                          .where((x) => x != null && '$x'.isNotEmpty)
                          .join(' ');
                      final unread = (c['unread'] ?? 0) as int;
                      final img = other['image'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (img != null && '$img'.isNotEmpty)
                              ? NetworkImage('$img')
                              : null,
                          child: (img == null || '$img'.isEmpty)
                              ? Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : '?')
                              : null,
                        ),
                        title: Text(nombre.isEmpty ? 'Usuario' : nombre,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          c['lastMessage'] ?? 'Conversación iniciada',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: unread > 0
                            ? CircleAvatar(
                                radius: 11,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text('$unread',
                                    style: const TextStyle(fontSize: 12, color: Colors.white)),
                              )
                            : null,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: c['id'] as int,
                                title: nombre.isEmpty ? 'Usuario' : nombre,
                              ),
                            ),
                          );
                          _load(); // refrescar no-leídos al volver
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
