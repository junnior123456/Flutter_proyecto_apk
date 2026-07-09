import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Probando conectividad de red...');
  
  final urls = [
    'http://192.168.18.97:3000/api/users',
    'http://192.168.56.1:3000/api/users',
    'http://192.168.56.2:3000/api/users',
    'http://10.0.2.2:3000/api/users',
    'http://10.0.3.2:3000/api/users',
  ];
  
  for (String url in urls) {
    try {
      print('🔍 Probando: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('✅ Respuesta ${response.statusCode} de: $url');
      if (response.statusCode == 200) {
        print('📥 Datos: ${response.body.substring(0, 50)}...');
        break;
      }
    } catch (e) {
      print('❌ Error con $url: $e');
    }
  }
}