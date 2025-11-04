import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Probando conectividad desde Dart...');
  
  final urls = [
    'http://192.168.56.1:3000/api/users',
    'http://10.0.2.2:3000/api/users',
    'http://localhost:3000/api/users',
    'http://127.0.0.1:3000/api/users',
  ];
  
  for (String url in urls) {
    try {
      print('🔍 Probando: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        print('✅ Éxito con: $url');
        print('📥 Respuesta: ${response.body.substring(0, 100)}...');
        break;
      } else {
        print('❌ Error ${response.statusCode} con: $url');
      }
    } catch (e) {
      print('❌ Excepción con $url: $e');
    }
  }
}