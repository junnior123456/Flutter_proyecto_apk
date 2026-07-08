import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 === PRUEBA SIMPLE DE CONECTIVIDAD ===');
  
  final urls = [
    'http://167.99.4.161/api/users',
    'http://167.99.4.161/api/users',
    'http://167.99.4.161/api/users',
    'http://167.99.4.161/api/users',
    'http://167.99.4.161/api/users',
    'http://167.99.4.161/api/users',
    'http://167.99.4.161/api/users',
  ];
  
  for (String url in urls) {
    try {
      print('🔍 Probando: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print('✅ Respuesta ${response.statusCode} de: $url');
      if (response.statusCode == 200) {
        print('📥 Datos recibidos: ${response.body.substring(0, 100)}...');
        
        // Ahora probar login
        print('🔐 Probando login con esta URL...');
        final loginUrl = url.replaceAll('/users', '/auth/login');
        final loginResponse = await http.post(
          Uri.parse(loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: '{"email":"junnior@upeu.edu.pe","password":"123456"}',
        ).timeout(Duration(seconds: 10));
        
        print('🔐 Login respuesta ${loginResponse.statusCode}: ${loginResponse.body.substring(0, 100)}...');
        break;
      }
    } catch (e) {
      print('❌ Error con $url: $e');
    }
  }
  
  print('🏁 Prueba completada');
}