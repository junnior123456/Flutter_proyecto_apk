/// Pantalla de recomendación de perros con IA
/// El usuario responde preguntas y la IA recomienda qué perro adoptar
import 'package:flutter/material.dart';
import '../../../../core/services/ai_service.dart';

class DogRecommendationScreen extends StatefulWidget {
  const DogRecommendationScreen({super.key});

  @override
  State<DogRecommendationScreen> createState() => _DogRecommendationScreenState();
}

class _DogRecommendationScreenState extends State<DogRecommendationScreen> {
  final AiService _aiService = AiService();
  bool _isLoading = false;
  String? _recommendation;

  // Respuestas del formulario
  String _livingSpace = 'apartment';
  bool _hasChildren = false;
  bool _hasOtherPets = false;
  String _activityLevel = 'medium';
  String _experience = 'none';
  double _hoursAlone = 4;
  String _budget = 'medium';
  bool _allergies = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 ¿Qué perro te conviene?'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: _recommendation != null
          ? _buildResult()
          : _buildForm(),
    );
  }

  /// Formulario de preguntas para recomendar el perro ideal
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('🐕', style: TextStyle(fontSize: 32)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Encuentra tu perro ideal',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Responde estas preguntas y PawBot te recomendará el perro perfecto para ti en Tarapoto',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pregunta 1: Tipo de vivienda
          _buildQuestion(
            '🏠 ¿Dónde vives?',
            DropdownButton<String>(
              value: _livingSpace,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'apartment', child: Text('Departamento/Apartamento')),
                DropdownMenuItem(value: 'house_small', child: Text('Casa pequeña con patio')),
                DropdownMenuItem(value: 'house_large', child: Text('Casa grande con jardín')),
              ],
              onChanged: (v) => setState(() => _livingSpace = v!),
            ),
          ),

          // Pregunta 2: Niños
          _buildQuestion(
            '👶 ¿Tienes niños en casa?',
            SwitchListTile(
              value: _hasChildren,
              onChanged: (v) => setState(() => _hasChildren = v),
              title: Text(_hasChildren ? 'Sí, tengo niños' : 'No tengo niños'),
              activeColor: const Color(0xFF6C63FF),
            ),
          ),

          // Pregunta 3: Otras mascotas
          _buildQuestion(
            '🐾 ¿Tienes otras mascotas?',
            SwitchListTile(
              value: _hasOtherPets,
              onChanged: (v) => setState(() => _hasOtherPets = v),
              title: Text(_hasOtherPets ? 'Sí, tengo otras mascotas' : 'No tengo otras mascotas'),
              activeColor: const Color(0xFF6C63FF),
            ),
          ),

          // Pregunta 4: Nivel de actividad
          _buildQuestion(
            '🏃 ¿Cuál es tu nivel de actividad física?',
            Column(
              children: [
                _buildRadioOption('low', 'Bajo (prefiero estar en casa)', _activityLevel,
                    (v) => setState(() => _activityLevel = v!)),
                _buildRadioOption('medium', 'Medio (caminatas ocasionales)', _activityLevel,
                    (v) => setState(() => _activityLevel = v!)),
                _buildRadioOption('high', 'Alto (deportista, salgo mucho)', _activityLevel,
                    (v) => setState(() => _activityLevel = v!)),
              ],
            ),
          ),

          // Pregunta 5: Experiencia
          _buildQuestion(
            '📚 ¿Tienes experiencia con perros?',
            Column(
              children: [
                _buildRadioOption('none', 'Sin experiencia (primera vez)', _experience,
                    (v) => setState(() => _experience = v!)),
                _buildRadioOption('some', 'Algo de experiencia', _experience,
                    (v) => setState(() => _experience = v!)),
                _buildRadioOption('experienced', 'Muy experimentado', _experience,
                    (v) => setState(() => _experience = v!)),
              ],
            ),
          ),

          // Pregunta 6: Horas solo
          _buildQuestion(
            '⏰ ¿Cuántas horas estaría solo el perro? (${_hoursAlone.round()}h/día)',
            Slider(
              value: _hoursAlone,
              min: 0, max: 12, divisions: 12,
              activeColor: const Color(0xFF6C63FF),
              label: '${_hoursAlone.round()} horas',
              onChanged: (v) => setState(() => _hoursAlone = v),
            ),
          ),

          // Pregunta 7: Presupuesto
          _buildQuestion(
            '💰 ¿Cuál es tu presupuesto mensual para el perro?',
            Column(
              children: [
                _buildRadioOption('low', 'Bajo (S/. 50-100/mes)', _budget,
                    (v) => setState(() => _budget = v!)),
                _buildRadioOption('medium', 'Medio (S/. 100-200/mes)', _budget,
                    (v) => setState(() => _budget = v!)),
                _buildRadioOption('high', 'Alto (S/. 200+/mes)', _budget,
                    (v) => setState(() => _budget = v!)),
              ],
            ),
          ),

          // Pregunta 8: Alergias
          _buildQuestion(
            '🤧 ¿Tienes alergias al pelo de perro?',
            SwitchListTile(
              value: _allergies,
              onChanged: (v) => setState(() => _allergies = v),
              title: Text(_allergies ? 'Sí, tengo alergias' : 'No tengo alergias'),
              activeColor: const Color(0xFF6C63FF),
            ),
          ),

          const SizedBox(height: 24),

          // Botón de recomendar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getRecommendation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('PawBot está analizando...'),
                      ],
                    )
                  : const Text('🐕 ¡Recomiéndame un perro!', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Muestra el resultado de la recomendación
  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header de resultado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Text('🎉', style: TextStyle(fontSize: 32)),
                SizedBox(width: 12),
                Expanded(
                  child: Text('¡PawBot encontró el perro ideal para ti!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recomendación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: Text(_recommendation!, style: const TextStyle(fontSize: 14, height: 1.6)),
          ),
          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _recommendation = null),
                  child: const Text('🔄 Volver a intentar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                  child: const Text('🐕 Ver perros', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          child,
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value, String label, String groupValue, Function(String?) onChanged) {
    return RadioListTile<String>(
      value: value, groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      activeColor: const Color(0xFF6C63FF),
      dense: true,
    );
  }

  /// Llama a la IA para obtener la recomendación
  Future<void> _getRecommendation() async {
    setState(() => _isLoading = true);
    try {
      final response = await _aiService.recommendDog({
        'livingSpace': _livingSpace,
        'hasChildren': _hasChildren,
        'hasOtherPets': _hasOtherPets,
        'activityLevel': _activityLevel,
        'experience': _experience,
        'hoursAlone': _hoursAlone.round(),
        'budget': _budget,
        'allergies': _allergies,
      });
      setState(() {
        _recommendation = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener recomendación. Intenta de nuevo.')),
        );
      }
    }
  }
}
