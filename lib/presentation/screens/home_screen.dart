import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        Uri.parse('http://10.0.2.2:3000/api/api/pets'),
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
        title: const Text('PawFinder'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPets,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              'Error',
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
              child: const Text('Retry'),
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
              'No pets found',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPets,
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
    final name = pet['name'] ?? 'Unknown';
    final description = pet['description'] ?? '';
    final breed = pet['breed'] ?? '';
    final age = pet['age'] ?? '';
    final gender = pet['gender'] ?? '';
    final isRisk = pet['isRisk'] ?? false;
    final imageUrl = pet['imageUrl'];
    final images = pet['images'] as List<dynamic>? ?? [];
    
    // Use primary image from images array or fallback to imageUrl
    String? displayImageUrl;
    if (images.isNotEmpty) {
      final primaryImage = images.firstWhere(
        (img) => img['isPrimary'] == true,
        orElse: () => images.first,
      );
      displayImageUrl = primaryImage['url'] ?? primaryImage['imageUrl'];
    } else {
      displayImageUrl = imageUrl;
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.pets,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
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
                    if (isRisk)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'En Riesgo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Adopción',
                          style: TextStyle(
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
                  Row(
                    children: [
                      if (breed.isNotEmpty) ...[
                        Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(breed, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                      ],
                      if (age.isNotEmpty) ...[
                        Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(age, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                      ],
                      if (gender.isNotEmpty) ...[
                        Icon(
                          gender.toLowerCase() == 'macho' ? Icons.male : Icons.female,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(gender, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ],
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
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to pet details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ver detalles de $name')),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Ver Detalles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to adoption form
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Adoptar a $name')),
                          );
                        },
                        icon: const Icon(Icons.favorite),
                        label: const Text('Adoptar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRisk ? Colors.orange : Colors.green,
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
}