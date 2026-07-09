import 'package:flutter/material.dart';

import 'symptom_checker_screen.dart';

/// Guía de primeros auxilios y cuidado para perros.
///
/// Contenido informativo y educativo. NO reemplaza la atención de un
/// médico veterinario. Ante cualquier emergencia, acude a un profesional.
class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  static const Color _primary = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🐶 Primeros auxilios y cuidados'),
      ),
      body: Center(
        child: ConstrainedBox(
          // Responsive: ancho máximo cómodo en tablet, completo en celular
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _disclaimer(),
              const SizedBox(height: 16),
              _symptomButton(context),
              const SizedBox(height: 16),
              ..._categories.map((c) => _buildCategory(context, c)),
              const SizedBox(height: 24),
              _emergencyFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta guía es informativa y no reemplaza al veterinario. '
              'Ante una urgencia, contacta o acude a un profesional lo antes posible.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _symptomButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SymptomCheckerScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detector de síntomas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Marca lo que ves en tu perrito y recibe consejos (offline)',
                      style: TextStyle(color: Colors.white, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, _Category cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        // Quita las líneas divisorias por defecto del ExpansionTile
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: cat.color.withValues(alpha: 0.15),
            child: Text(cat.emoji, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(
            cat.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            cat.subtitle,
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children:
              cat.items.map((it) => _buildItem(context, it, cat.color)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _Item item, Color color) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 6),
          ...item.steps.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: scheme.onSurface,
                      ),
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

  Widget _emergencyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text('🚨', style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text(
            'En una emergencia grave',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Mantén la calma, evita que el perro se mueva demasiado y '
            'llévalo de inmediato a la clínica veterinaria más cercana. '
            'Ten a mano el teléfono de tu veterinario de confianza.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contenido
// ---------------------------------------------------------------------------

class _Category {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<_Item> items;
  const _Category({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.items,
  });
}

class _Item {
  final String title;
  final List<String> steps;
  const _Item(this.title, this.steps);
}

const List<_Category> _categories = [
  _Category(
    emoji: '🚑',
    title: 'Emergencias',
    subtitle: 'Qué hacer en los primeros minutos',
    color: Color(0xFFE53935),
    items: [
      _Item('Atragantamiento', [
        'Abre con cuidado el hocico y mira si ves el objeto; retíralo solo si puedes sujetarlo sin empujarlo más adentro.',
        'En perros pequeños: sostenlo boca abajo y da palmadas firmes entre los omóplatos.',
        'En perros grandes: aprieta hacia adentro y arriba justo debajo de las costillas (maniobra tipo Heimlich).',
        'Si no respira, acude al veterinario de inmediato.',
      ]),
      _Item('Herida o sangrado', [
        'Presiona la herida con una gasa o tela limpia durante 3–5 minutos.',
        'No retires la tela si se empapa; coloca otra encima.',
        'Evita que lama la herida y no apliques alcohol directamente.',
        'Si el sangrado no cede, trasládalo al veterinario.',
      ]),
      _Item('Intoxicación / envenenamiento', [
        'Aleja al perro de la sustancia e identifica qué comió (guarda el empaque).',
        'NO provoques el vómito sin indicación veterinaria: puede ser peligroso.',
        'Chocolate, uvas/pasas, cebolla, ajo, xilitol y medicamentos humanos son tóxicos.',
        'Llama al veterinario lo antes posible con la información del tóxico.',
      ]),
      _Item('Golpe de calor', [
        'Llévalo a la sombra o lugar fresco de inmediato.',
        'Moja su cuerpo con agua fresca (no helada), sobre todo patas, ingles y cuello.',
        'Ofrécele agua en pequeñas cantidades.',
        'Es una urgencia: acude al veterinario aunque parezca recuperarse.',
      ]),
      _Item('Convulsiones', [
        'No lo sujetes ni metas la mano en su boca.',
        'Retira objetos cercanos para que no se lastime y baja las luces/ruido.',
        'Toma el tiempo que dura la convulsión.',
        'Si dura más de 3 minutos o se repite, ve al veterinario urgente.',
      ]),
    ],
  ),
  _Category(
    emoji: '🩺',
    title: 'Salud y prevención',
    subtitle: 'Vacunas, desparasitación y señales de alerta',
    color: Color(0xFF1E88E5),
    items: [
      _Item('Vacunas', [
        'Los cachorros inician su plan de vacunas alrededor de las 6–8 semanas.',
        'Vacunas clave: parvovirus, moquillo y antirrábica.',
        'Refuerzos anuales según indique tu veterinario.',
        'Evita sacarlo a la calle hasta completar el esquema inicial.',
      ]),
      _Item('Desparasitación', [
        'Desparasitación interna periódica (según edad y peso).',
        'Control de pulgas y garrapatas (externa) con productos adecuados.',
        'Consulta la frecuencia con tu veterinario.',
      ]),
      _Item('Señales de alerta: ir al veterinario', [
        'Vómitos o diarrea persistentes, sangre en heces u orina.',
        'No come ni bebe por más de 24 horas.',
        'Dificultad para respirar, encías pálidas o azuladas.',
        'Decaimiento fuerte, temblores o dolor evidente.',
      ]),
    ],
  ),
  _Category(
    emoji: '🍖',
    title: 'Alimentación',
    subtitle: 'Qué sí y qué no puede comer',
    color: Color(0xFF43A047),
    items: [
      _Item('Alimentos PELIGROSOS (evitar)', [
        'Chocolate, café y cafeína.',
        'Uvas y pasas.',
        'Cebolla, ajo y poro.',
        'Xilitol (endulzante), alcohol y masa cruda.',
        'Huesos cocidos (se astillan).',
      ]),
      _Item('Alimentos seguros con moderación', [
        'Alimento balanceado adecuado a su edad y tamaño.',
        'Zanahoria, manzana sin semillas, arroz cocido.',
        'Carne o pollo cocido sin sal ni condimentos.',
        'Siempre agua fresca y limpia disponible.',
      ]),
      _Item('Cantidad y horarios', [
        'Cachorros: 3–4 comidas pequeñas al día.',
        'Adultos: 1–2 comidas al día en horarios fijos.',
        'Evita el sobrepeso: mide las porciones.',
      ]),
    ],
  ),
  _Category(
    emoji: '🐕',
    title: 'Crianza y bienestar',
    subtitle: 'Para tu nuevo mejor amigo',
    color: Color(0xFF8E24AA),
    items: [
      _Item('Recién adoptado', [
        'Dale un espacio tranquilo con su cama, agua y comida.',
        'Ten paciencia: los primeros días puede estar asustado.',
        'Preséntale la casa poco a poco y con calma.',
        'Agenda una revisión veterinaria inicial.',
      ]),
      _Item('Higiene', [
        'Baño cada 3–4 semanas o según necesidad, con shampoo para perros.',
        'Cepillado regular del pelaje.',
        'Corte de uñas y limpieza de oídos con cuidado.',
        'Cepillado de dientes para prevenir sarro.',
      ]),
      _Item('Ejercicio y socialización', [
        'Paseos diarios acordes a su energía y edad.',
        'Juegos que estimulen su mente (juguetes, olfato).',
        'Socialización positiva con personas y otros perros.',
        'El refuerzo positivo (premios) funciona mejor que el castigo.',
      ]),
    ],
  ),
];
