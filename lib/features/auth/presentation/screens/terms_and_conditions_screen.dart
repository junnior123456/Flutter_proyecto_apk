import 'package:flutter/material.dart';

/// 📄 Pantalla de Términos y Condiciones
/// Clean Architecture - Presentation Layer
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 40,
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PawFinder',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        Text(
                          'Última actualización: Noviembre 2025',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Introducción
            _buildSection(
              title: '1. Introducción',
              content: 'Bienvenido a PawFinder. Al utilizar nuestra aplicación, aceptas cumplir con estos términos y condiciones. PawFinder es una plataforma diseñada para facilitar la adopción de mascotas y reportar animales en riesgo.',
            ),
            
            _buildSection(
              title: '2. Uso de la Aplicación',
              content: 'Al registrarte en PawFinder, te comprometes a:\n\n'
                  '• Proporcionar información veraz y actualizada\n'
                  '• Usar la plataforma de manera responsable y ética\n'
                  '• No publicar contenido ofensivo o inapropiado\n'
                  '• Respetar los derechos de otros usuarios\n'
                  '• Cumplir con las leyes locales sobre tenencia de animales',
            ),
            
            _buildSection(
              title: '3. Adopción de Mascotas',
              content: 'PawFinder actúa como intermediario entre adoptantes y dueños de mascotas. Nos comprometemos a:\n\n'
                  '• Facilitar el proceso de adopción de manera transparente\n'
                  '• Verificar la información básica de los usuarios\n'
                  '• Proporcionar un sistema de solicitudes seguro\n\n'
                  'Sin embargo, PawFinder no se hace responsable de:\n\n'
                  '• La veracidad de la información proporcionada por los usuarios\n'
                  '• El estado de salud de las mascotas\n'
                  '• Acuerdos posteriores entre adoptantes y dueños',
            ),
            
            _buildSection(
              title: '4. Privacidad y Datos Personales',
              content: 'Nos comprometemos a proteger tu información personal:\n\n'
                  '• Tus datos se almacenan de forma segura\n'
                  '• No compartimos tu información con terceros sin tu consentimiento\n'
                  '• Puedes solicitar la eliminación de tu cuenta en cualquier momento\n'
                  '• Usamos tus datos solo para mejorar el servicio',
            ),
            
            _buildSection(
              title: '5. Contenido Publicado',
              content: 'Al publicar contenido en PawFinder:\n\n'
                  '• Garantizas que tienes los derechos sobre las imágenes y textos\n'
                  '• Autorizas a PawFinder a mostrar tu contenido en la plataforma\n'
                  '• Eres responsable de la veracidad de la información\n'
                  '• PawFinder se reserva el derecho de eliminar contenido inapropiado',
            ),
            
            _buildSection(
              title: '6. Donaciones',
              content: 'Las donaciones realizadas a través de PawFinder:\n\n'
                  '• Son voluntarias y no reembolsables\n'
                  '• Se destinan al mantenimiento de la plataforma\n'
                  '• Pueden ser utilizadas para apoyar refugios de animales\n'
                  '• Se emitirá un comprobante digital de cada donación',
            ),
            
            _buildSection(
              title: '7. Reportes de Animales en Riesgo',
              content: 'Al reportar un animal en riesgo:\n\n'
                  '• Debes proporcionar información precisa sobre la ubicación\n'
                  '• Es tu responsabilidad contactar a las autoridades locales si es necesario\n'
                  '• PawFinder facilitará la comunicación entre rescatistas\n'
                  '• No nos hacemos responsables de la seguridad durante el rescate',
            ),
            
            _buildSection(
              title: '8. Limitación de Responsabilidad',
              content: 'PawFinder no se hace responsable de:\n\n'
                  '• Daños o lesiones causadas por mascotas adoptadas\n'
                  '• Pérdidas económicas derivadas del uso de la plataforma\n'
                  '• Problemas de salud de las mascotas\n'
                  '• Disputas entre usuarios\n'
                  '• Interrupciones del servicio',
            ),
            
            _buildSection(
              title: '9. Modificaciones',
              content: 'PawFinder se reserva el derecho de modificar estos términos en cualquier momento. Los cambios serán notificados a través de la aplicación y entrarán en vigor inmediatamente después de su publicación.',
            ),
            
            _buildSection(
              title: '10. Contacto',
              content: 'Si tienes preguntas sobre estos términos, puedes contactarnos a través de:\n\n'
                  '• Email: soporte@pawfinder.com\n'
                  '• Sección "Acerca de" en la aplicación',
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 40,
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Al usar PawFinder, aceptas estos términos y condiciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gracias por ayudar a las mascotas 🐾',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
