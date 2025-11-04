import 'package:flutter/material.dart';
import '../constants/app_styles.dart';

/// Ejemplo de uso de todos los estilos centralizados
class StylesExamplePage extends StatelessWidget {
  const StylesExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estilos de la App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEXT STYLES
            _buildSection(
              'Estilos de Texto',
              [
                Text('Título Grande', style: AppStyles.headingLarge.copyWith(color: Colors.black)),
                Text('Título Mediano', style: AppStyles.headingMedium),
                Text('Título Pequeño', style: AppStyles.headingSmall),
                Text('Subtítulo Grande', style: AppStyles.subtitleLarge),
                Text('Subtítulo Mediano', style: AppStyles.subtitleMedium),
                Text('Subtítulo Pequeño', style: AppStyles.subtitleSmall),
                Text('Cuerpo Grande', style: AppStyles.bodyLarge),
                Text('Cuerpo Mediano', style: AppStyles.bodyMedium),
                Text('Cuerpo Pequeño', style: AppStyles.bodySmall),
                Text('Botón Grande', style: AppStyles.buttonLarge.copyWith(color: Colors.black)),
                Text('Botón Mediano', style: AppStyles.buttonMedium.copyWith(color: Colors.black)),
                const Text('Caption Normal', style: AppStyles.caption),
                const Text('Link', style: AppStyles.link),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // BUTTONS
            _buildSection(
              'Estilos de Botones',
              [
                ElevatedButton(
                  onPressed: () {},
                  style: AppStyles.primaryButtonStyle,
                  child: const Text('Botón Primario'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: AppStyles.secondaryButtonStyle,
                  child: const Text('Botón Secundario'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: AppStyles.outlineButtonStyle,
                  child: const Text('Botón Outline'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  style: AppStyles.textButtonStyle,
                  child: const Text('Botón de Texto'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: AppStyles.dangerButtonStyle,
                  child: const Text('Botón Peligro'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: AppStyles.successButtonStyle,
                  child: const Text('Botón Éxito'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // CONTAINERS
            _buildSection(
              'Contenedores',
              [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.cardDecoration,
                  child: const Center(child: Text('Card Decoration')),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.elevatedCardDecoration,
                  child: const Center(child: Text('Elevated Card Decoration')),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.primaryContainer,
                  child: const Center(child: Text('Primary Container')),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.successContainer,
                  child: const Center(child: Text('Success Container')),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.warningContainer,
                  child: const Center(child: Text('Warning Container')),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.errorContainer,
                  child: const Center(child: Text('Error Container')),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // FORM FIELDS
            _buildSection(
              'Campos de Formulario',
              [
                TextFormField(
                  decoration: AppStyles.textFieldInputDecoration(
                    labelText: 'Campo Normal',
                    hintText: 'Ingresa texto aquí',
                    prefixIcon: Icons.person,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: AppStyles.textFieldInputDecoration(
                    labelText: 'Campo con Error',
                    hintText: 'Este campo tiene error',
                    prefixIcon: Icons.email,
                    isError: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // GRADIENTS
            _buildSection(
              'Gradientes',
              [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.primaryGradient,
                  child: const Center(
                    child: Text(
                      'Gradiente Primario',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.welcomeGradient,
                  child: const Center(
                    child: Text(
                      'Gradiente de Bienvenida',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: AppStyles.authGradient,
                  child: const Center(
                    child: Text(
                      'Gradiente de Autenticación',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.headingMedium,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}