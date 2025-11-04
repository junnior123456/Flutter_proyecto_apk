import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/http_service.dart';
import '../../core/services/auth_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _result = '';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Verificando conexión...';
    });

    try {
      final isConnected = await _httpService.checkConnection();
      setState(() {
        _isConnected = isConnected;
        _result = isConnected 
          ? '✅ Conectado al backend correctamente'
          : '❌ No se pudo conectar al backend';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _result = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUsers() async {
    setState(() {
      _isLoading = true;
      _result = 'Obteniendo usuarios...';
    });

    try {
      final response = await _httpService.get('/users');
      if (response.statusCode == 200) {
        final users = jsonDecode(response.body);
        setState(() {
          _result = '✅ Usuarios obtenidos:\n${jsonEncode(users)}';
        });
      } else {
        setState(() {
          _result = '❌ Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRoles() async {
    setState(() {
      _isLoading = true;
      _result = 'Obteniendo roles...';
    });

    try {
      final response = await _httpService.get('/roles');
      if (response.statusCode == 200) {
        final roles = jsonDecode(response.body);
        setState(() {
          _result = '✅ Roles obtenidos:\n${jsonEncode(roles)}';
        });
      } else {
        setState(() {
          _result = '❌ Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Probando login directo...';
    });

    try {
      // Prueba directa sin usar AuthService
      print('🧪 Iniciando prueba de login directo');
      
      final urls = [
        'http://192.168.18.97:3000/api/auth/login',
        'http://192.168.56.1:3000/api/auth/login',
        'http://10.0.2.2:3000/api/auth/login',
      ];
      
      for (String url in urls) {
        try {
          print('🔍 Probando login en: $url');
          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': 'junnior@upeu.edu.pe',
              'password': '123456',
            }),
          ).timeout(const Duration(seconds: 10));
          
          print('📡 Respuesta: ${response.statusCode}');
          print('📥 Body: ${response.body}');
          
          if (response.statusCode == 201) {
            final data = jsonDecode(response.body);
            setState(() {
              _result = '✅ Login exitoso con $url:\n${jsonEncode(data)}';
            });
            return;
          }
        } catch (e) {
          print('❌ Error con $url: $e');
        }
      }
      
      setState(() {
        _result = '❌ No se pudo conectar con ninguna URL de login';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error general en login: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDirectConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Probando conexión directa...';
    });

    try {
      final result = await _httpService.testDirectConnection();
      setState(() {
        _result = '🧪 Prueba directa:\n${jsonEncode(result)}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error en prueba directa: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de API'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado de conexión
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : Icons.error,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'Backend Conectado' : 'Backend Desconectado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botones de prueba
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('Verificar Conexión'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testUsers,
              icon: const Icon(Icons.people),
              label: const Text('Probar /api/users'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testRoles,
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Probar /api/roles'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testLogin,
              icon: const Icon(Icons.login),
              label: const Text('Probar Login'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDirectConnection,
              icon: const Icon(Icons.network_check),
              label: const Text('Prueba Directa'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
            
            const SizedBox(height: 20),
            
            // Resultado
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Cargando...'),
                          ],
                        ),
                      )
                    : Text(
                        _result,
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
}