import 'package:flutter/material.dart';

/// 🔍 Detector de síntomas OFFLINE.
///
/// La persona selecciona los síntomas que observa en su perrito y la app
/// muestra consejos ya cargados y un nivel de urgencia. No usa internet:
/// pensado para zonas rurales sin señal.
///
/// ⚠️ Es orientación informativa, NO un diagnóstico veterinario.
class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final Set<int> _selected = <int>{};

  static const Color _primary = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    // Urgencia general = la más alta entre los síntomas elegidos.
    _Urgency? peak;
    for (final i in _selected) {
      final u = _symptoms[i].urgency;
      if (peak == null || u.level > peak.level) peak = u;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🔍 Detector de síntomas'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Marca los síntomas que ves en tu perrito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Funciona sin internet. Es una guía de orientación, no reemplaza al veterinario.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
              ),
              const SizedBox(height: 14),

              // Chips de síntomas seleccionables
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_symptoms.length, (i) {
                  final s = _symptoms[i];
                  final sel = _selected.contains(i);
                  return FilterChip(
                    selected: sel,
                    showCheckmark: false,
                    label: Text('${s.emoji}  ${s.name}'),
                    labelStyle: TextStyle(
                      fontSize: 13.5,
                      color: sel ? Colors.white : const Color(0xFF444444),
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: s.urgency.color,
                    side: BorderSide(
                      color: sel ? s.urgency.color : Colors.grey.shade300,
                    ),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selected.add(i);
                        } else {
                          _selected.remove(i);
                        }
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              if (_selected.isEmpty)
                _emptyHint()
              else ...[
                if (peak != null) _peakBanner(peak),
                const SizedBox(height: 12),
                ...(_selected.toList()..sort((a, b) =>
                        _symptoms[b].urgency.level - _symptoms[a].urgency.level))
                    .map((i) => _adviceCard(_symptoms[i])),
                const SizedBox(height: 8),
                _multiSymptomNote(),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(_selected.clear),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpiar selección'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyHint() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('🐶', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            'Selecciona uno o más síntomas para ver los consejos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _peakBanner(_Urgency u) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: u.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(u.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  u.subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceCard(_Symptom s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: s.urgency.color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: s.urgency.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.urgency.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: s.urgency.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Qué hacer:',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...s.advice.map((a) => _bullet(a, const Color(0xFF333333))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏥 ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(
                    'Al veterinario si: ${s.vetIf}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Color(0xFF8D5A00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, height: 1.35, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _multiSymptomNote() {
    if (_selected.length < 2) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: const Text(
        '⚠️ Tu perrito tiene varios síntomas a la vez. Eso aumenta la urgencia — '
        'lo más seguro es que lo revise un veterinario lo antes posible.',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: Color(0xFFB71C1C),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modelo y datos (todo local / offline)
// ---------------------------------------------------------------------------

enum _Urgency {
  baja(
    1,
    'Leve',
    Color(0xFF43A047),
    '🟢',
    'Cuidado en casa',
    'Puedes atenderlo en casa y observar cómo evoluciona.',
  ),
  media(
    2,
    'Vigilar',
    Color(0xFFF57C00),
    '🟠',
    'Vigila de cerca',
    'Atiende en casa y, si no mejora pronto, acude al veterinario.',
  ),
  alta(
    3,
    'Urgente',
    Color(0xFFE53935),
    '🚨',
    'Acude al veterinario cuanto antes',
    'Uno o más síntomas son de emergencia. No esperes.',
  );

  const _Urgency(
    this.level,
    this.tag,
    this.color,
    this.icon,
    this.headline,
    this.subtitle,
  );

  final int level;
  final String tag;
  final Color color;
  final String icon;
  final String headline;
  final String subtitle;
}

class _Symptom {
  final String emoji;
  final String name;
  final _Urgency urgency;
  final List<String> advice;
  final String vetIf;

  const _Symptom({
    required this.emoji,
    required this.name,
    required this.urgency,
    required this.advice,
    required this.vetIf,
  });
}

const List<_Symptom> _symptoms = [
  _Symptom(
    emoji: '🤮',
    name: 'Vómito',
    urgency: _Urgency.media,
    advice: [
      'Retira la comida por 6–12 horas (el agua sí, en poca cantidad y seguido).',
      'Al reintroducir, dale comida blanda: arroz cocido con pollo hervido sin sal.',
      'Observa el color y con qué frecuencia vomita.',
    ],
    vetIf: 'vomita más de 24 h, sale sangre, está muy decaído o es un cachorro.',
  ),
  _Symptom(
    emoji: '🩸',
    name: 'Vómito o heces con sangre',
    urgency: _Urgency.alta,
    advice: [
      'No le des comida ni medicamentos por tu cuenta.',
      'Mantenlo tranquilo e hidratado con pequeños sorbos de agua.',
      'Anota cuántas veces y cuánta sangre para informar al veterinario.',
    ],
    vetIf: 'siempre: es una señal de alarma, acude de inmediato.',
  ),
  _Symptom(
    emoji: '💩',
    name: 'Diarrea',
    urgency: _Urgency.media,
    advice: [
      'Mantén agua fresca disponible para evitar deshidratación.',
      'Dieta blanda (arroz con pollo) en porciones pequeñas.',
      'Evita darle lácteos, grasas o restos de comida.',
    ],
    vetIf: 'dura más de 2 días, hay sangre, o es cachorro/perro pequeño.',
  ),
  _Symptom(
    emoji: '🍽️',
    name: 'No come / sin apetito',
    urgency: _Urgency.media,
    advice: [
      'Verifica si al menos bebe agua.',
      'Ofrécele algo apetecible y tibio (pollo hervido).',
      'Revisa su boca por si hay heridas o algo atascado.',
    ],
    vetIf: 'no come ni bebe por más de 24 h, o está decaído.',
  ),
  _Symptom(
    emoji: '😔',
    name: 'Decaído / sin energía',
    urgency: _Urgency.media,
    advice: [
      'Déjalo descansar en un lugar tranquilo y abrigado.',
      'Toca su nariz y orejas: si están muy calientes puede tener fiebre.',
      'Ofrécele agua y observa si mejora en unas horas.',
    ],
    vetIf: 'empeora, no mejora en 24 h o se suma a otros síntomas.',
  ),
  _Symptom(
    emoji: '🦴',
    name: 'Cojea / dolor al caminar',
    urgency: _Urgency.media,
    advice: [
      'Mantenlo en reposo; evita que corra o salte.',
      'Revisa la pata: espinas, cortes, uñas rotas o hinchazón.',
      'No le des analgésicos humanos (son tóxicos para perros).',
    ],
    vetIf: 'no apoya la pata, hay mucha hinchazón o el dolor no baja.',
  ),
  _Symptom(
    emoji: '🩹',
    name: 'Herida / sangrado',
    urgency: _Urgency.alta,
    advice: [
      'Presiona con una gasa o tela limpia 3–5 minutos.',
      'No apliques alcohol; evita que se lama la herida.',
      'Si es leve, lava con agua limpia o suero fisiológico.',
    ],
    vetIf: 'el sangrado no para, la herida es profunda o hay mordida.',
  ),
  _Symptom(
    emoji: '😮‍💨',
    name: 'Dificultad para respirar',
    urgency: _Urgency.alta,
    advice: [
      'Mantenlo calmado y en un lugar fresco y ventilado.',
      'No lo estreses ni lo hagas moverse.',
      'Revisa que nada le obstruya la nariz o la boca.',
    ],
    vetIf: 'siempre: es una emergencia, acude de inmediato.',
  ),
  _Symptom(
    emoji: '⚡',
    name: 'Convulsiones / temblores',
    urgency: _Urgency.alta,
    advice: [
      'No lo sujetes ni metas la mano en su boca.',
      'Retira objetos cercanos y baja luces y ruido.',
      'Toma el tiempo que dura el episodio.',
    ],
    vetIf: 'dura más de 3 min, se repite, o es la primera vez: urgente.',
  ),
  _Symptom(
    emoji: '🎈',
    name: 'Panza hinchada y dura',
    urgency: _Urgency.alta,
    advice: [
      'No le des de comer ni beber.',
      'No lo obligues a moverse.',
      'Puede ser una torsión de estómago (muy grave).',
    ],
    vetIf: 'siempre y de inmediato: es una urgencia que pone en riesgo su vida.',
  ),
  _Symptom(
    emoji: '🥵',
    name: 'Golpe de calor',
    urgency: _Urgency.alta,
    advice: [
      'Llévalo a la sombra o lugar fresco enseguida.',
      'Mójalo con agua fresca (no helada), sobre todo patas y cuello.',
      'Ofrécele agua en pequeñas cantidades.',
    ],
    vetIf: 'siempre, aunque parezca recuperarse: acude al veterinario.',
  ),
  _Symptom(
    emoji: '☠️',
    name: 'Posible intoxicación',
    urgency: _Urgency.alta,
    advice: [
      'Aleja al perro de la sustancia y averigua qué comió.',
      'NO provoques el vómito sin indicación veterinaria.',
      'Guarda el empaque o resto para mostrarlo al veterinario.',
    ],
    vetIf: 'siempre: llama o acude al veterinario lo antes posible.',
  ),
  _Symptom(
    emoji: '👁️',
    name: 'Ojos rojos / lagañas',
    urgency: _Urgency.media,
    advice: [
      'Limpia con una gasa y suero fisiológico, de adentro hacia afuera.',
      'No uses gotas para ojos de humanos.',
      'Evita que se rasque el ojo.',
    ],
    vetIf: 'hay mucho dolor, no abre el ojo o empeora en 1–2 días.',
  ),
  _Symptom(
    emoji: '🐾',
    name: 'Se rasca mucho / picazón',
    urgency: _Urgency.baja,
    advice: [
      'Revisa si tiene pulgas, garrapatas o piel enrojecida.',
      'Báñalo con shampoo para perros (nunca de humano).',
      'Mantén limpia su cama y su entorno.',
    ],
    vetIf: 'hay heridas por rascado, zonas sin pelo o no mejora.',
  ),
  _Symptom(
    emoji: '🕷️',
    name: 'Pulgas / garrapatas',
    urgency: _Urgency.baja,
    advice: [
      'Retira las garrapatas con una pinza, jalando sin apretar el cuerpo.',
      'Usa antipulgas específico para perros.',
      'Limpia y revisa el ambiente donde duerme.',
    ],
    vetIf: 'hay muchas, la piel se infecta, o el perro está decaído.',
  ),
];
