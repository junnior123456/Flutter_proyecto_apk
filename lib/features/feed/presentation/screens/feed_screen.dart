/// Feed social estilo muro (P4): publicaciones con me gusta, comentar y compartir.
library;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/feed_service.dart';
import '../../../../core/config/api_config.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const Color _brand = Color(0xFFFF9800);
  final FeedService _service = FeedService();
  final ScrollController _scroll = ScrollController();

  final List<Map<String, dynamic>> _posts = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      final (list, hasMore) = await _service.getFeed(page: _page);
      if (!mounted) return;
      setState(() {
        _posts.addAll(list);
        _hasMore = hasMore;
        _page++;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'No se pudo cargar el feed.'; _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _posts.clear(); _page = 1; _hasMore = true; });
    await _loadMore();
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    final petId = post['id'] as int;
    // Actualización optimista.
    final wasLiked = post['isLiked'] == true;
    final prevCount = (post['likesCount'] as int? ?? 0);
    setState(() {
      post['isLiked'] = !wasLiked;
      post['likesCount'] = prevCount + (wasLiked ? -1 : 1);
    });
    try {
      final (isLiked, count) = await _service.toggleLike(petId);
      if (!mounted) return;
      setState(() { post['isLiked'] = isLiked; post['likesCount'] = count; });
    } catch (_) {
      if (!mounted) return;
      setState(() { post['isLiked'] = wasLiked; post['likesCount'] = prevCount; });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo actualizar el me gusta')));
    }
  }

  void _share(Map<String, dynamic> post) {
    final name = post['name'] ?? 'esta mascota';
    final uid = post['publicUid'];
    final link = uid != null
        ? '${ApiConfig.baseUrl.replaceAll('/api', '')}/api/p/$uid'
        : '';
    final risk = post['isRisk'] == true ? '🚨 ¡Ayuda! ' : '🐾 ';
    SharePlus.instance.share(
      ShareParams(
        text: '$risk$name en PawFinder'
            '${(post['breed'] ?? '').toString().isNotEmpty ? ' · ${post['breed']}' : ''}.'
            '${link.isNotEmpty ? '\nMira su ficha: $link' : ''}',
      ),
    );
  }

  Future<void> _openComments(int index) async {
    final post = _posts[index];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CommentsSheet(
        petId: post['id'] as int,
        service: _service,
        onCommentAdded: () {
          if (mounted) {
            setState(() =>
                post['commentsCount'] = (post['commentsCount'] as int? ?? 0) + 1);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📰 Feed'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _body()),
    );
  }

  Widget _body() {
    if (_posts.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posts.isEmpty && _error != null) {
      return ListView(children: [
        const SizedBox(height: 140),
        Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 12),
        Center(child: OutlinedButton(onPressed: _loadMore, child: const Text('Reintentar'))),
      ]);
    }
    if (_posts.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 140),
        Center(child: Text('Aún no hay publicaciones.')),
      ]);
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _PostCard(
          post: _posts[i],
          onLike: () => _toggleLike(i),
          onComment: () => _openComments(i),
          onShare: () => _share(_posts[i]),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  static const Color _brand = Color(0xFFFF9800);

  String _ago(String? iso) {
    if (iso == null) return '';
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'ahora';
    if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';
    if (d.inHours < 24) return 'hace ${d.inHours} h';
    if (d.inDays < 7) return 'hace ${d.inDays} d';
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = post['user'] as Map<String, dynamic>?;
    final authorName = (user != null
            ? '${user['name'] ?? ''} ${user['lastname'] ?? ''}'.trim()
            : '')
        .trim();
    final displayName = authorName.isNotEmpty
        ? authorName
        : (post['contactName']?.toString() ?? 'Usuario');
    final authorImg = user?['image']?.toString();
    final img = post['imageUrl']?.toString() ?? '';
    final liked = post['isLiked'] == true;
    final isRisk = post['isRisk'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera de autor
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _brand.withValues(alpha: 0.15),
                backgroundImage: (authorImg != null && authorImg.isNotEmpty)
                    ? NetworkImage(authorImg)
                    : null,
                child: (authorImg == null || authorImg.isEmpty)
                    ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: const TextStyle(color: _brand, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '${_ago(post['createdAt']?.toString())}'
                      '${(post['address'] ?? '').toString().isNotEmpty ? ' · ${post['address']}' : ''}',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isRisk)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('EN RIESGO',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ]),
          ),
          // Descripción
          if ((post['description'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(post['description'].toString(),
                  style: TextStyle(fontSize: 13, color: scheme.onSurface)),
            ),
          // Imagen grande
          if (img.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                img,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null
                    ? child
                    : Container(
                        color: scheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceContainerHighest,
                  height: 200,
                  child: Icon(Icons.pets, size: 48, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          // Nombre + raza + edad
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text(
              [
                post['name'],
                post['breed'],
                (post['age'] ?? '').toString().isNotEmpty ? post['age'] : null,
              ].where((e) => e != null && e.toString().isNotEmpty).join(' · '),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          // Contadores
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Text(
              '${post['likesCount'] ?? 0} me gusta · ${post['commentsCount'] ?? 0} comentarios',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          const Divider(height: 1),
          // Acciones
          Row(
            children: [
              _action(liked ? Icons.favorite : Icons.favorite_border, 'Me gusta',
                  liked ? Colors.red : scheme.onSurfaceVariant, onLike),
              _action(Icons.chat_bubble_outline, 'Comentar', scheme.onSurfaceVariant, onComment),
              _action(Icons.share_outlined, 'Compartir', scheme.onSurfaceVariant, onShare),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 13)),
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

/// Hoja inferior de comentarios. Devuelve cuántos comentarios se añadieron.
class _CommentsSheet extends StatefulWidget {
  final int petId;
  final FeedService service;
  final VoidCallback onCommentAdded;
  const _CommentsSheet({
    required this.petId,
    required this.service,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await widget.service.getComments(widget.petId);
      if (!mounted) return;
      setState(() { _comments = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final c = await widget.service.addComment(widget.petId, text);
      if (!mounted) return;
      setState(() {
        _comments = [c, ..._comments];
        _sending = false;
      });
      widget.onCommentAdded();
      _ctrl.clear();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo publicar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: scheme.onSurfaceVariant, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? Center(child: Text('Sé el primero en comentar',
                          style: TextStyle(color: scheme.onSurfaceVariant)))
                      : ListView.builder(
                          controller: controller,
                          itemCount: _comments.length,
                          itemBuilder: (_, i) => _tile(_comments[i], scheme),
                        ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario…',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: Color(0xFFFF9800)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(Map<String, dynamic> c, ColorScheme scheme) {
    final user = c['user'] as Map<String, dynamic>?;
    final name = user != null
        ? '${user['name'] ?? ''} ${user['lastname'] ?? ''}'.trim()
        : 'Usuario';
    final img = user?['image']?.toString();
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: (img != null && img.isNotEmpty) ? NetworkImage(img) : null,
        child: (img == null || img.isEmpty)
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 12, color: scheme.onPrimaryContainer))
            : null,
      ),
      title: Text(name.isEmpty ? 'Usuario' : name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(c['content']?.toString() ?? ''),
    );
  }
}
