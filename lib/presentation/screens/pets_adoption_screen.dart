import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetsAdoptionScreen extends StatefulWidget {
  const PetsAdoptionScreen({Key? key}) : super(key: key);

  @override
  State<PetsAdoptionScreen> createState() => _PetsAdoptionScreenState();
}

class _PetsAdoptionScreenState extends State<PetsAdoptionScreen> {
  List<dynamic> pets = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse('http://192.168.18.97:3000/api/api/pets'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          setState(() {
            pets = data['data']['pets'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Error: ${data['message'] ?? 'Unknown error'}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'HTTP Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas en Adopción'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPets,
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin-panel');
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF9800),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error de Conexión',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadPets,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (pets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay mascotas disponibles',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPets,
      color: const Color(0xFFFF9800),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return _buildPetCard(pet);
        },
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final name = pet['name'] ?? 'Sin nombre';
    final description = pet['description'] ?? '';
    final breed = pet['breed'] ?? '';
    final age = pet['age'] ?? '';
    final gender = pet['gender'] ?? '';
    final isRisk = pet['isRisk'] ?? false;
    final isVaccinated = pet['isVaccinated'] ?? false;
    final isSterilized = pet['isSterilized'] ?? false;
    final contactName = pet['contactName'] ?? '';
    final contactPhone = pet['contactPhone'] ?? '';
    final images = pet['images'] as List<dynamic>? ?? [];
    
    // Use primary image from images array or fallback to imageUrl
    String? displayImageUrl;
    if (images.isNotEmpty) {
      final primaryImage = images.firstWhere(
        (img) => img['isPrimary'] == true,
        orElse: () => images.first,
      );
      displayImageUrl = primaryImage['url'] ?? primaryImage['imageUrl'];
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (displayImageUrl != null && displayImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                displayImageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                headers: const {
                  'User-Agent': 'PawFinder/1.0',
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $displayImageUrl - $error');
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.pets,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.pets,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isRisk ? Colors.red : const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isRisk ? 'En Riesgo' : 'Adopción',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Pet details
                if (breed.isNotEmpty || age.isNotEmpty || gender.isNotEmpty)
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      if (breed.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(breed, style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      if (age.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(age, style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      if (gender.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              gender.toLowerCase() == 'macho' ? Icons.male : Icons.female,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(gender, style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                    ],
                  ),
                
                // Health status
                if (isVaccinated || isSterilized)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (isVaccinated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Vacunado',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (isSterilized)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Esterilizado',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Contact info
                if (contactName.isNotEmpty || contactPhone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          contactName.isNotEmpty ? contactName : 'Contacto disponible',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                      if (contactPhone.isNotEmpty) ...[
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          contactPhone,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showPetDetails(pet);
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Ver Detalles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAdoptionForm(pet);
                        },
                        icon: const Icon(Icons.favorite),
                        label: Text(isRisk ? 'Ayudar' : 'Adoptar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRisk ? Colors.red : const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet['name'] ?? 'Mascota'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pet['description'] != null && pet['description'].isNotEmpty)
                Text(pet['description']),
              const SizedBox(height: 8),
              Text('Raza: ${pet['breed'] ?? 'No especificada'}'),
              Text('Edad: ${pet['age'] ?? 'No especificada'}'),
              Text('Género: ${pet['gender'] ?? 'No especificado'}'),
              if (pet['medicalHistory'] != null && pet['medicalHistory'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Historial Médico:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(pet['medicalHistory']),
              ],
              if (pet['specialNeeds'] != null && pet['specialNeeds'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Necesidades Especiales:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(pet['specialNeeds']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAdoptionForm(Map<String, dynamic> pet) {
    final personalInfoController = TextEditingController();
    final motivationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pet['isRisk'] == true ? 'Ayudar a' : 'Adoptar a'} ${pet['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: personalInfoController,
                decoration: const InputDecoration(
                  labelText: 'Información Personal',
                  hintText: 'Cuéntanos sobre ti y tu familia',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: motivationController,
                decoration: const InputDecoration(
                  labelText: 'Motivación',
                  hintText: '¿Por qué quieres adoptar esta mascota?',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (personalInfoController.text.isNotEmpty && 
                  motivationController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Solicitud enviada para ${pet['name']}'),
                    backgroundColor: const Color(0xFFFF9800),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }
}