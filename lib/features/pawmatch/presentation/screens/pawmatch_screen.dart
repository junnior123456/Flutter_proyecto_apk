import 'package:flutter/material.dart';
import '../../../../core/services/pawmatch_service.dart';

/// PawMatch — evalúa la compatibilidad entre un adoptante y un perfil de perro
/// con el árbol de decisión del backend (POST /api/ai/pawmatch).
class PawMatchScreen extends StatefulWidget {
  const PawMatchScreen({super.key});

  @override
  State<PawMatchScreen> createState() => _PawMatchScreenState();
}

class _PawMatchScreenState extends State<PawMatchScreen> {
  final _service = PawmatchService();

  // Categóricas (0..2)
  int _tipoVivienda = 0;
  int _experiencia = 0;
  int _actividad = 1;
  int _tamano = 1;
  int _energia = 1;
  // Numéricas
  double _horasSolo = 6;
  double _ninos = 0;
  double _presupuesto = 200;
  double _edadPerro = 3;

  bool _cargando = false;
  Map<String, dynamic>? _resultado;

  static const _vivienda = ['Apartamento', 'Casa sin jardín', 'Casa con jardín'];
  static const _experiencias = ['Sin experiencia', 'Básica', 'Avanzada'];
  static const _actividades = ['Sedentario', 'Moderado', 'Muy activo'];
  static const _tamanos = ['Pequeño', 'Mediano', 'Grande'];
  static const _energias = ['Baja', 'Media', 'Alta'];

  Future<void> _evaluar() async {
    setState(() {
      _cargando = true;
      _resultado = null;
    });
    try {
      final data = await _service.predecir({
        'tipo_vivienda': _tipoVivienda,
        'horas_solo_dia': _horasSolo,
        'ninos_en_casa': _ninos.round(),
        'experiencia_previa': _experiencia,
        'nivel_actividad': _actividad,
        'presupuesto_mensual': _presupuesto,
        'tamano_perro': _tamano,
        'energia_perro': _energia,
        'edad_perro_anos': _edadPerro,
      });
      if (!mounted) return;
      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo evaluar. Intenta de nuevo.')),
        );
      } else {
        setState(() => _resultado = data);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Color _hex(String h) =>
      Color(int.parse('FF${h.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compatibilidad PawMatch'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Evalúa qué tan compatible es un adoptante con un perfil de perro. '
            'El modelo estima la probabilidad de una adopción exitosa y el riesgo '
            'de abandono, y te dice qué factores pesaron más.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          _seccion('Sobre el adoptante'),
          _dropdown('Tipo de vivienda', _vivienda, _tipoVivienda, (v) => setState(() => _tipoVivienda = v)),
          _dropdown('Experiencia previa', _experiencias, _experiencia, (v) => setState(() => _experiencia = v)),
          _dropdown('Nivel de actividad', _actividades, _actividad, (v) => setState(() => _actividad = v)),
          _slider('Horas que el perro pasaría solo', _horasSolo, 0, 16, 16, (v) => setState(() => _horasSolo = v), suffix: 'h'),
          _slider('Niños en casa', _ninos, 0, 6, 6, (v) => setState(() => _ninos = v)),
          _slider('Presupuesto mensual', _presupuesto, 0, 1000, 20, (v) => setState(() => _presupuesto = v), prefix: 'S/ '),

          const SizedBox(height: 8),
          _seccion('Sobre el perro'),
          _dropdown('Tamaño', _tamanos, _tamano, (v) => setState(() => _tamano = v)),
          _dropdown('Energía', _energias, _energia, (v) => setState(() => _energia = v)),
          _slider('Edad del perro', _edadPerro, 0, 20, 40, (v) => setState(() => _edadPerro = v), suffix: 'años'),

          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _cargando ? null : _evaluar,
            icon: _cargando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.favorite),
            label: Text(_cargando ? 'Evaluando…' : 'Evaluar compatibilidad'),
          ),

          if (_resultado != null) ...[
            const SizedBox(height: 24),
            _vistaResultado(_resultado!),
          ],
        ],
      ),
    );
  }

  Widget _seccion(String t) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _dropdown(String label, List<String> opciones, int valor, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: valor,
            items: [
              for (var i = 0; i < opciones.length; i++)
                DropdownMenuItem(value: i, child: Text(opciones[i])),
            ],
            onChanged: (v) => onChanged(v ?? 0),
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, double valor, double min, double max, int divisions,
      ValueChanged<double> onChanged, {String prefix = '', String suffix = ''}) {
    final texto = valor == valor.roundToDouble() ? valor.toInt().toString() : valor.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$prefix$texto${suffix.isNotEmpty ? ' $suffix' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: valor,
            min: min,
            max: max,
            divisions: divisions,
            label: '$prefix$texto',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _vistaResultado(Map<String, dynamic> r) {
    final riesgo = Map<String, dynamic>.from(r['riesgo'] as Map);
    final color = _hex(riesgo['color'] as String);
    final factores = (r['factores'] as List?) ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(riesgo['emoji'] as String? ?? '', style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['etiqueta'] as String? ?? '',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                      Text('Riesgo ${riesgo['nivel']} · ${riesgo['porcentaje_exito']}% de éxito',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ((riesgo['porcentaje_exito'] as num?)?.toDouble() ?? 0) / 100,
                minHeight: 10,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 12),
            Text(riesgo['mensaje'] as String? ?? ''),
            if (factores.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Factores que más pesaron',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final f in factores)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        (f['impacto'] == 'positivo') ? Icons.add_circle : Icons.remove_circle,
                        size: 18,
                        color: (f['impacto'] == 'positivo') ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f['factor'] as String? ?? '')),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Text('Orientativo: no sustituye la evaluación de un refugio o veterinario.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
