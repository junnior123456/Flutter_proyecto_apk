import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'first_aid_screen.dart';
import 'symptom_checker_screen.dart';

/// 🐶 Asistente/bot OFFLINE para perritos.
///
/// El cliente escribe libremente ("mi perro vomita", "tiene una herida") y el
/// bot responde con consejos ya cargados, reconociendo palabras clave. No usa
/// internet: pensado para zonas rurales sin señal.
///
/// Está preparado para, en el futuro, conectarse a una IA real (Claude) cuando
/// exista una API key — bastaría con reemplazar [_botReply] por la llamada al
/// backend.
class PetChatScreen extends StatefulWidget {
  const PetChatScreen({super.key});

  @override
  State<PetChatScreen> createState() => _PetChatScreenState();
}

class _PetChatScreenState extends State<PetChatScreen> {
  static const Color _primary = Color(0xFFFF9800);

  final List<_Msg> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
      '¡Hola! 🐶 Soy tu asistente para perritos. Cuéntame qué le pasa a tu '
      'perro (por ejemplo: "vomita", "no come", "tiene una herida") y te doy '
      'consejos. Funciona sin internet.',
      isBot: true,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, isBot: false));
      _messages.add(_Msg(_botReply(text), isBot: true));
    });
    _controller.clear();
    _scrollToEnd();
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

  // Cámara / galería (funciona en móvil y web).
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: _primary),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _primary),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg('📷 Foto de mi perrito', isBot: false, image: bytes));
        _messages.add(_Msg(_photoReply(), isBot: true));
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
          'No pude acceder a la cámara o galería. Revisa los permisos del '
          'dispositivo e inténtalo de nuevo.',
          isBot: true,
        ));
      });
      _scrollToEnd();
    }
  }

  String _photoReply() {
    return 'Recibí la foto de tu perrito 🐶📷.\n\n'
        'Por ahora, sin conexión, no puedo analizar la imagen automáticamente. '
        'Mientras tanto, cuéntame qué le notas (por ejemplo dónde está la '
        'herida o qué síntoma ves) o usa el "🔍 Detector de síntomas".\n\n'
        '🔒 Tu foto queda lista para que, cuando se active el asistente con IA, '
        'se analice y te dé una orientación.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🐶 Asistente para perritos'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Accesos rápidos
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _quick('🚑 Guía completa', () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const FirstAidScreen()));
                    }),
                    _quick('🔍 Detector de síntomas', () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SymptomCheckerScreen()));
                    }),
                    _quick('🤮 Vomita', () => _send('Mi perro vomita')),
                    _quick('🍽️ No come', () => _send('No quiere comer')),
                    _quick('🩹 Herida', () => _send('Tiene una herida')),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Conversación
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) => _bubble(_messages[i]),
                ),
              ),

              // Entrada de texto
              _inputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quick(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12.5)),
        backgroundColor: Colors.white,
        side: BorderSide(color: _primary.withValues(alpha: 0.4)),
        onPressed: onTap,
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final bot = m.isBot;
    return Align(
      alignment: bot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bot ? Colors.white : _primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(bot ? 4 : 16),
            bottomRight: Radius.circular(bot ? 16 : 4),
          ),
          border: bot ? Border.all(color: Colors.grey.shade200) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              bot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (m.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  m.image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (m.image != null && m.text.isNotEmpty) const SizedBox(height: 6),
            if (m.text.isNotEmpty)
              Text(
                m.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: bot ? const Color(0xFF333333) : Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            // Botón de cámara / foto
            IconButton(
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.photo_camera, color: _primary),
              tooltip: 'Enviar foto',
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: 'Escribe lo que le pasa a tu perrito...',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _send(_controller.text),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Motor de respuestas OFFLINE (por palabras clave)
  // -------------------------------------------------------------------------

  String _botReply(String input) {
    final norm = _normalize(input);
    final tokens = norm
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.isNotEmpty)
        .toList();

    // Elige el intent con MÁS coincidencias (palabras clave, sinónimos,
    // frases y tolerancia a errores de escritura).
    _Intent? best;
    int bestScore = 0;
    for (final intent in _intents) {
      int score = 0;
      for (final kw in intent.keywords) {
        if (_matches(kw, norm, tokens)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        best = intent;
      }
    }

    if (best != null && bestScore > 0) return best.response;

    return 'Mmm, no estoy seguro de haberte entendido 🐶. Cuéntamelo con otras '
        'palabras o dime el síntoma principal — por ejemplo: "está vomitando", '
        '"tiene diarrea", "no quiere comer", "cojea de una pata", "tiene una '
        'herida", "está muy decaído" o "le salen pulgas".\n\n'
        'También puedes tocar arriba "🔍 Detector de síntomas" o "🚑 Guía '
        'completa". Si tu perrito está grave, acude al veterinario más cercano.';
  }

  /// ¿La palabra clave [kw] está en el texto? Acepta frases exactas,
  /// subcadenas y errores de escritura leves (distancia de edición).
  bool _matches(String kw, String norm, List<String> tokens) {
    if (kw.contains(' ')) return norm.contains(kw); // frase de varias palabras
    if (norm.contains(kw)) return true; // subcadena directa
    for (final t in tokens) {
      if (t.length < 4 || kw.length < 4) continue;
      final tol = kw.length <= 5 ? 1 : 2; // más tolerancia si la palabra es larga
      if (_lev(t, kw, tol) <= tol) return true;
    }
    return false;
  }

  /// Distancia de Levenshtein con corte temprano en [maxDist].
  int _lev(String a, String b, int maxDist) {
    final n = a.length, m = b.length;
    if ((n - m).abs() > maxDist) return maxDist + 1;
    var prev = List<int>.generate(m + 1, (i) => i);
    var curr = List<int>.filled(m + 1, 0);
    for (var i = 1; i <= n; i++) {
      curr[0] = i;
      var rowMin = curr[0];
      for (var j = 1; j <= m; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        var v = curr[j - 1] + 1;
        if (prev[j] + 1 < v) v = prev[j] + 1;
        if (prev[j - 1] + cost < v) v = prev[j - 1] + cost;
        curr[j] = v;
        if (v < rowMin) rowMin = v;
      }
      if (rowMin > maxDist) return maxDist + 1; // corte temprano
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[m];
  }

  /// Minúsculas y sin tildes/ñ para comparar de forma tolerante.
  String _normalize(String s) {
    s = s.toLowerCase();
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final idx = from.indexOf(ch);
      b.write(idx >= 0 ? to[idx] : ch);
    }
    return b.toString();
  }
}

class _Msg {
  final String text;
  final bool isBot;
  final Uint8List? image;
  _Msg(this.text, {required this.isBot, this.image});
}

class _Intent {
  final List<String> keywords;
  final String response;
  const _Intent(this.keywords, this.response);
}

// Emergencias primero (mayor prioridad), luego el resto.
const List<_Intent> _intents = [
  _Intent(
    ['sangre', 'sangra', 'sangrado', 'desangr'],
    '🚨 Sangrado — es urgente.\n'
        '• Presiona la zona con una gasa o tela limpia 3–5 minutos.\n'
        '• No apliques alcohol y evita que se lama.\n'
        '• Si no para o la herida es profunda, acude al veterinario de inmediato.',
  ),
  _Intent(
    ['no respira', 'respira', 'ahog', 'asfixi', 'atragant', 'agitado', 'jadea',
      'le falta el aire', 'no puede respirar', 'sofocado', 'ahogado', 'tose'],
    '🚨 Problemas para respirar / atragantamiento — emergencia.\n'
        '• Mantenlo calmado, fresco y sin moverse.\n'
        '• Si ves un objeto en la boca y puedes sacarlo sin empujarlo, hazlo.\n'
        '• Acude al veterinario cuanto antes.',
  ),
  _Intent(
    ['convuls', 'ataque', 'tiembla', 'temblor', 'espasmo'],
    '🚨 Convulsiones — mantén la calma.\n'
        '• NO lo sujetes ni metas la mano en su boca.\n'
        '• Retira objetos cercanos, baja luces y ruido.\n'
        '• Toma el tiempo que dura. Si pasa de 3 min o se repite, ve al veterinario urgente.',
  ),
  _Intent(
    ['veneno', 'intoxic', 'toxic', 'comio veneno', 'raticida', 'chocolate'],
    '🚨 Posible intoxicación — urgente.\n'
        '• Averigua qué comió y aléjalo de la sustancia.\n'
        '• NO provoques el vómito sin indicación veterinaria.\n'
        '• Guarda el empaque y llama o acude al veterinario lo antes posible.',
  ),
  _Intent(
    ['hinchad', 'inflad', 'panza dura', 'estomago hinchado', 'torsion'],
    '🚨 Panza hinchada y dura — puede ser una torsión de estómago, muy grave.\n'
        '• No le des comida ni agua.\n'
        '• No lo obligues a moverse.\n'
        '• Llévalo al veterinario de inmediato.',
  ),
  _Intent(
    ['calor', 'golpe de calor', 'insolac', 'mucho sol'],
    '🥵 Golpe de calor.\n'
        '• Llévalo a la sombra o lugar fresco enseguida.\n'
        '• Mójalo con agua fresca (no helada), sobre todo patas y cuello.\n'
        '• Ofrécele agua a sorbos. Aunque mejore, hazlo revisar por un veterinario.',
  ),
  _Intent(
    ['vomit', 'vomita', 'devuelve', 'devolviendo', 'arroja', 'guacarea',
      'buitrea', 'regurgita', 'nausea', 'basca', 'provoca', 'echa la comida'],
    '🤮 Vómito.\n'
        '• Retira la comida 6–12 h (agua sí, en poca cantidad y seguido).\n'
        '• Luego dale comida blanda: arroz con pollo hervido sin sal.\n'
        '🏥 Ve al veterinario si vomita más de 24 h, hay sangre, o es cachorro.',
  ),
  _Intent(
    ['diarrea', 'suelto', 'caca liquida', 'popo liquida', 'obra floja',
      'obra aguado', 'descompuesto', 'disenteria', 'evacua', 'aguado'],
    '💩 Diarrea.\n'
        '• Mantén agua fresca para evitar deshidratación.\n'
        '• Dieta blanda (arroz con pollo) en porciones pequeñas.\n'
        '• Evita lácteos y grasas.\n'
        '🏥 Al veterinario si dura más de 2 días, hay sangre o es cachorro.',
  ),
  _Intent(
    ['no come', 'no quiere comer', 'sin apetito', 'no come nada', 'no prueba',
      'inapetente', 'desganado', 'no tiene hambre', 'rechaza la comida',
      'no traga', 'ayuno', 'no se alimenta'],
    '🍽️ No quiere comer.\n'
        '• Verifica que al menos beba agua.\n'
        '• Ofrécele algo apetecible y tibio (pollo hervido).\n'
        '• Revisa su boca por heridas o algo atascado.\n'
        '🏥 Al veterinario si no come ni bebe por más de 24 h o está decaído.',
  ),
  _Intent(
    ['decaid', 'triste', 'sin energia', 'sin fuerzas', 'debil', 'flojo',
      'apagad', 'desanimado', 'no se levanta', 'no juega', 'echado', 'apatico',
      'cansado', 'dormido todo el dia', 'sin animo', 'aguantado'],
    '😔 Decaído / sin energía.\n'
        '• Déjalo descansar en un lugar tranquilo y abrigado.\n'
        '• Toca su nariz y orejas: si están muy calientes, puede tener fiebre.\n'
        '• Ofrécele agua.\n'
        '🏥 Al veterinario si empeora, no mejora en 24 h o tiene otros síntomas.',
  ),
  _Intent(
    ['cojea', 'cojo', 'coja', 'no camina', 'pata', 'dolor al caminar',
      'renquea', 'renguea', 'arrastra la pata', 'le duele la pata',
      'no apoya', 'patita', 'lastim la pata', 'no camina bien'],
    '🦴 Cojera / dolor al caminar.\n'
        '• Mantenlo en reposo; evita que corra o salte.\n'
        '• Revisa la pata: espinas, cortes, uñas rotas o hinchazón.\n'
        '• NO le des analgésicos de humanos (son tóxicos).\n'
        '🏥 Al veterinario si no apoya la pata o hay mucha hinchazón.',
  ),
  _Intent(
    ['herida', 'herido', 'cortad', 'se corto', 'lastim', 'raspon', 'raspadura',
      'mordid', 'lesion', 'llaga', 'ampolla', 'pupa'],
    '🩹 Herida.\n'
        '• Presiona con una gasa o tela limpia 3–5 minutos si sangra.\n'
        '• Lava lo leve con agua limpia o suero fisiológico; no uses alcohol.\n'
        '• Evita que se lama la herida.\n'
        '🏥 Al veterinario si es profunda, es mordida o no deja de sangrar.',
  ),
  _Intent(
    ['pulga', 'garrapata', 'bicho', 'parasito externo'],
    '🕷️ Pulgas / garrapatas.\n'
        '• Retira las garrapatas con pinza, jalando sin apretar el cuerpo.\n'
        '• Usa antipulgas específico para perros.\n'
        '• Limpia y revisa donde duerme.\n'
        '🏥 Al veterinario si hay muchas, la piel se infecta o está decaído.',
  ),
  _Intent(
    ['rasca', 'rascando', 'pica', 'picazon', 'comezon', 'se muerde', 'se lame',
      'alergia', 'irritada', 'ronchas', 'se restrega', 'sarna'],
    '🐾 Se rasca mucho / picazón.\n'
        '• Revisa pulgas, garrapatas o piel enrojecida.\n'
        '• Báñalo con shampoo para perros (nunca de humano).\n'
        '• Mantén limpia su cama y su entorno.\n'
        '🏥 Al veterinario si hay heridas por rascado o zonas sin pelo.',
  ),
  _Intent(
    ['ojo', 'ojos', 'lagaña', 'lagana', 'legaña'],
    '👁️ Ojos rojos / lagañas.\n'
        '• Limpia con gasa y suero fisiológico, de adentro hacia afuera.\n'
        '• No uses gotas para ojos de humanos.\n'
        '• Evita que se rasque el ojo.\n'
        '🏥 Al veterinario si hay mucho dolor o no abre el ojo.',
  ),
  _Intent(
    ['vacuna', 'vacunar', 'vacunas'],
    '💉 Vacunas.\n'
        '• Los cachorros empiezan alrededor de las 6–8 semanas.\n'
        '• Clave: parvovirus, moquillo y antirrábica; refuerzos anuales.\n'
        '• Evita sacarlo a la calle hasta completar el esquema inicial.\n'
        'Consulta el calendario con tu veterinario.',
  ),
  _Intent(
    ['come', 'comida', 'aliment', 'que le doy', 'que puede comer', 'que darle'],
    '🍖 Alimentación.\n'
        '• PELIGROSOS (no dar): chocolate, uva/pasas, cebolla, ajo, huesos cocidos.\n'
        '• Seguros con moderación: balanceado según su edad, arroz, pollo cocido sin sal.\n'
        '• Siempre agua fresca disponible.',
  ),
  _Intent(
    ['baño', 'bano', 'bañar', 'higiene', 'limpieza'],
    '🛁 Higiene.\n'
        '• Baño cada 3–4 semanas o según necesidad, con shampoo para perros.\n'
        '• Cepillado regular del pelaje.\n'
        '• Corte de uñas y limpieza de oídos con cuidado.',
  ),
  _Intent(
    ['cachorro', 'adopte', 'adopté', 'nuevo perr', 'recien', 'llego a casa'],
    '🐕 Perrito recién llegado.\n'
        '• Dale un espacio tranquilo con su cama, agua y comida.\n'
        '• Ten paciencia los primeros días; puede estar asustado.\n'
        '• Agenda una revisión veterinaria inicial y su plan de vacunas.',
  ),
  _Intent(
    ['hola', 'ola', 'buenas', 'buenos dias', 'buenas tardes', 'buenas noches',
      'que tal', 'saludos', 'hey', 'holi', 'como estas', 'ayuda', 'ayudame'],
    '¡Hola! 🐶 Cuéntame qué le pasa a tu perrito y te ayudo con consejos. '
        'Puedes escribir por ejemplo: "vomita", "no come", "tiene una herida".',
  ),
  _Intent(
    ['gracias', 'muchas gracias', 'agradec'],
    '¡Con gusto! 🐾 Cuida mucho a tu perrito. Si algo se ve grave, no dudes en '
        'acudir al veterinario. Estoy aquí si necesitas más consejos.',
  ),
];
