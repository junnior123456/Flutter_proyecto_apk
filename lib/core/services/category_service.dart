import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  /// 📋 Obtener todas las categorías desde el backend
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/categories');
      final response = await http
          .get(url, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo categorías: $e');
      // Retornar categorías por defecto si falla la conexión
      return _getDefaultCategories();
    }
  }

  /// 📊 Obtener categorías con conteo de mascotas
  Future<List<Map<String, dynamic>>> getCategoriesWithCount() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/categories/stats/count');
      final response = await http
          .get(url, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Error al obtener estadísticas: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return _getDefaultCategories();
    }
  }

  /// 🔍 Obtener categoría por ID
  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/categories/$id');
      final response = await http
          .get(url, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo categoría: $e');
      return null;
    }
  }

  /// 📋 Categorías por defecto (fallback)
  List<Map<String, dynamic>> _getDefaultCategories() {
    return [
      {
        'id': 1,
        'name': 'Perros',
        'emoji': '🐕',
        'description': 'Perros de todas las razas',
      },
      {
        'id': 2,
        'name': 'Gatos',
        'emoji': '🐱',
        'description': 'Gatos domésticos',
      },
      {
        'id': 3,
        'name': 'Aves',
        'emoji': '🐦',
        'description': 'Aves domésticas',
      },
      {
        'id': 4,
        'name': 'Conejos',
        'emoji': '🐰',
        'description': 'Conejos domésticos',
      },
      {
        'id': 5,
        'name': 'Otros',
        'emoji': '🐹',
        'description': 'Otras mascotas',
      },
    ];
  }

  /// 🔄 Sincronizar categorías locales con backend
  Future<void> syncCategories() async {
    try {
      final backendCategories = await getCategories();
      print(
        '✅ Categorías sincronizadas: ${backendCategories.length} encontradas',
      );
    } catch (e) {
      print('⚠️ No se pudieron sincronizar las categorías: $e');
    }
  }
}
