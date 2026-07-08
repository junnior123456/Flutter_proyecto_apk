/// Pantalla principal del asistente IA PawBot
/// Permite al usuario chatear con la IA sobre perros en Tarapoto
import 'package:flutter/material.dart';
import '../../../../core/services/ai_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lista de mensajes en el chat
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Modo actual del chat
  String _currentMode = 'general';

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida
    _messages.add(ChatMessage(
      text: '🐕 ¡Hola! Soy **PawBot**, tu asistente de adopción de perros en Tarapoto.\n\n'
          'Puedo ayudarte con:\n'
          '🔍 **Recomendar** qué perro adoptar\n'
          '❤️ **Cuidado** de tu perro adoptado\n'
          '🏥 **Veterinarias** en Tarapoto\n'
          '💬 **Preguntas** generales sobre perros\n\n'
          '¿En qué te puedo ayudar hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🐕 PawBot'),
            SizedBox(width: 8),
            Text('IA', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          // Botón para cambiar modo
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (mode) => setState(() => _currentMode = mode),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'general', child: Text('💬 Chat General')),
              const PopupMenuItem(value: 'recommend', child: Text('🔍 Recomendar Perro')),
              const PopupMenuItem(value: 'care', child: Text('❤️ Cuidado del Perro')),
              const PopupMenuItem(value: 'vet', child: Text('🏥 Veterinarias')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chips de modo rápido
          _buildModeChips(),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('PawBot está pensando...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          // Input de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Chips para cambiar rápidamente el modo del chat
  Widget _buildModeChips() {
    final modes = [
      {'key': 'general', 'label': '💬 General', 'color': Colors.blue},
      {'key': 'recommend', 'label': '🔍 Recomendar', 'color': Colors.green},
      {'key': 'care', 'label': '❤️ Cuidado', 'color': Colors.orange},
      {'key': 'vet', 'label': '🏥 Veterinaria', 'color': Colors.red},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: modes.map((mode) {
          final isSelected = _currentMode == mode['key'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(mode['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                  )),
              selected: isSelected,
              selectedColor: mode['color'] as Color,
              onSelected: (_) => setState(() => _currentMode = mode['key'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Construye un mensaje del chat
  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del bot
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF6C63FF),
              child: Text('🐕', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],

          // Burbuja del mensaje
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Avatar del usuario
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  /// Input para escribir mensajes
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _getHintText(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: const Color(0xFF6C63FF),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Texto de ayuda según el modo actual
  String _getHintText() {
    switch (_currentMode) {
      case 'recommend': return 'Cuéntame sobre tu estilo de vida...';
      case 'care': return 'Pregunta sobre el cuidado de tu perro...';
      case 'vet': return 'Describe el problema de tu perro...';
      default: return 'Escribe tu pregunta sobre perros...';
    }
  }

  /// Envía el mensaje y obtiene respuesta de la IA
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      String response;

      // Llamar al endpoint según el modo
      switch (_currentMode) {
        case 'recommend':
          response = await _aiService.generalChat(
            'Quiero adoptar un perro. $text. Dame recomendaciones específicas para Tarapoto.',
          );
          break;
        case 'care':
          response = await _aiService.trackDogCare(text);
          break;
        case 'vet':
          response = await _aiService.referToVet(text);
          break;
        default:
          response = await _aiService.generalChat(text);
      }

      // Agregar respuesta de la IA
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '😔 Lo siento, hubo un error. Por favor intenta de nuevo.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Modelo de mensaje del chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}
