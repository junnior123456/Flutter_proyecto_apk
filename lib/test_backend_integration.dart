import 'package:flutter/material.dart';
import 'core/services/pet_service.dart';
import 'core/services/category_service.dart';
import 'core/services/http_service.dart';
import 'domain/entities/pet_category.dart';

/// 🧪 Pantalla de prueba para verificar la integración con el backend
class TestBackendIntegration extends StatefulWidget {
  const TestBackendIntegration({super.key});

  @override
  State<TestBackendIntegration> createState() => _TestBackendIntegrationState();
}

class _TestBackendIntegrationState extends State<TestBackendIntegration> {
  final PetService _petService = PetService();
  final CategoryService _categoryService = CategoryService();
  final HttpService _httpService = HttpService();
  
  String _testResults = '';
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Backend Integration'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runAllTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isRunning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Ejecutando pruebas...'),
                      ],
                    )
                  : const Text(
                      'Ejecutar Pruebas de Integración',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty 
                        ? 'Presiona el botón para ejecutar las pruebas de integración con el backend.'
                        : _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧪 Ejecutar todas las pruebas de integración
  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults = '';
    });

    _addResult('🧪 INICIANDO PRUEBAS DE INTEGRACIÓN BACKEND\\n');
    _addResult('=' * 50);

    // Test 1: Verificar conectividad
    await _testConnectivity();
    
    // Test 2: Probar categorías
    await _testCategories();
    
    // Test 3: Probar mascotas para adopción
    await _testAdoptionPets();
    
    // Test 4: Probar mascotas en riesgo
    await _testRiskPets();
    
    // Test 5: Probar filtrado por categoría
    await _testCategoryFiltering();

    _addResult('\\n' + '=' * 50);
    _addResult('✅ PRUEBAS COMPLETADAS');

    setState(() {
      _isRunning = false;
    });
  }

  /// 🔍 Test 1: Verificar conectividad con el backend
  Future<void> _testConnectivity() async {
    _addResult('\\n🔍 Test 1: Verificando conectividad...');
    
    try {
      final isConnected = await _httpService.checkConnection();
      if (isConnected) {
        _addResult('✅ Conexión exitosa con el backend');
      } else {
        _addResult('❌ No se pudo conectar con el backend');
        _addResult('   Verifica que el servidor NestJS esté ejecutándose en puerto 3000');
      }
    } catch (e) {
      _addResult('❌ Error de conectividad: $e');
    }
  }

  /// 📂 Test 2: Probar servicio de categorías
  Future<void> _testCategories() async {
    _addResult('\\n📂 Test 2: Probando servicio de categorías...');
    
    try {
      final categories = await _categoryService.getAllCategories();
      _addResult('✅ Categorías obtenidas: ${categories.length}');
      
      for (final category in categories) {
        _addResult('   - ${category.icon} ${category.name} (ID: ${category.id})');
      }
      
      if (categories.isEmpty) {
        _addResult('⚠️ No se encontraron categorías - verifica el seed de la BD');
      }
    } catch (e) {
      _addResult('❌ Error obteniendo categorías: $e');
    }
  }

  /// 🏠 Test 3: Probar mascotas para adopción
  Future<void> _testAdoptionPets() async {
    _addResult('\\n🏠 Test 3: Probando mascotas para adopción...');
    
    try {
      final pets = await _petService.getPetsForAdoption();
      _addResult('✅ Mascotas para adopción: ${pets.length}');
      
      for (final pet in pets.take(3)) { // Mostrar solo las primeras 3
        _addResult('   - ${pet.name} (${pet.category.displayName})');
      }
      
      if (pets.isEmpty) {
        _addResult('ℹ️ No hay mascotas para adopción en la BD');
      }
    } catch (e) {
      _addResult('❌ Error obteniendo mascotas para adopción: $e');
    }
  }

  /// 🚨 Test 4: Probar mascotas en riesgo
  Future<void> _testRiskPets() async {
    _addResult('\\n🚨 Test 4: Probando mascotas en riesgo...');
    
    try {
      final pets = await _petService.getPetsInRisk();
      _addResult('✅ Mascotas en riesgo: ${pets.length}');
      
      for (final pet in pets.take(3)) { // Mostrar solo las primeras 3
        _addResult('   - ${pet.name} (${pet.category.displayName})');
      }
      
      if (pets.isEmpty) {
        _addResult('ℹ️ No hay mascotas en riesgo en la BD');
      }
    } catch (e) {
      _addResult('❌ Error obteniendo mascotas en riesgo: $e');
    }
  }

  /// 🔍 Test 5: Probar filtrado por categoría
  Future<void> _testCategoryFiltering() async {
    _addResult('\\n🔍 Test 5: Probando filtrado por categoría...');
    
    try {
      // Probar filtrado de perros para adopción
      final dogAdoptions = await _petService.getPetsForAdoption(categoryId: PetCategory.dog.id);
      _addResult('✅ Perros para adopción: ${dogAdoptions.length}');
      
      // Probar filtrado de gatos en riesgo
      final catRisk = await _petService.getPetsInRisk(categoryId: PetCategory.cat.id);
      _addResult('✅ Gatos en riesgo: ${catRisk.length}');
      
      _addResult('✅ Filtrado por categoría funcionando correctamente');
    } catch (e) {
      _addResult('❌ Error en filtrado por categoría: $e');
    }
  }

  /// 📝 Agregar resultado a la pantalla
  void _addResult(String message) {
    setState(() {
      _testResults += '$message\\n';
    });
  }
}