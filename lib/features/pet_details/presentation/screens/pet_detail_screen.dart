import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/risk_type.dart'; // ✅ NUEVO
import '../../../../core/widgets/cached_pet_image.dart';

/// 📱 Pantalla de detalles de mascota - Clean Architecture
class PetDetailScreen extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onAdoptPressed;
  final String? actionButtonText;
  final Color? actionButtonColor;

  const PetDetailScreen({
    super.key,
    required this.pet,
    this.onAdoptPressed,
    this.actionButtonText,
    this.actionButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pet.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: pet.imageUrl.isNotEmpty
                  ? CachedPetImage(
                      imageUrl: pet.imageUrl,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, size: 100, color: Colors.grey),
                    ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de estado
                  _buildStatusBadge(),
                  
                  const SizedBox(height: 16),
                  
                  // ✅ NUEVO: Tipos de riesgo (solo si es mascota en riesgo)
                  if (pet.isRisk && pet.riskTypes.isNotEmpty) ...[
                    _buildRiskTypesSection(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Información básica
                  _buildInfoSection(
                    icon: Icons.info_outline,
                    title: 'Información Básica',
                    children: [
                      if (pet.breed.isNotEmpty)
                        _buildInfoRow('Raza', pet.breed),
                      if (pet.age.isNotEmpty)
                        _buildInfoRow('Edad', pet.age),
                      if (pet.gender.isNotEmpty)
                        _buildInfoRow('Género', pet.gender),
                      if (pet.size.isNotEmpty)
                        _buildInfoRow('Tamaño', pet.size),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descripción
                  if (pet.description.isNotEmpty) ...[
                    _buildInfoSection(
                      icon: Icons.description,
                      title: 'Descripción',
                      children: [
                        Text(
                          pet.description,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Salud
                  _buildInfoSection(
                    icon: Icons.medical_services,
                    title: 'Salud',
                    children: [
                      _buildCheckRow('Vacunado', pet.isVaccinated),
                      _buildCheckRow('Esterilizado', pet.isSterilized),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Contacto
                  if (pet.contactName.isNotEmpty || pet.contactPhone.isNotEmpty) ...[
                    _buildInfoSection(
                      icon: Icons.contact_phone,
                      title: 'Contacto',
                      children: [
                        if (pet.contactName.isNotEmpty)
                          _buildInfoRow('Nombre', pet.contactName),
                        if (pet.contactPhone.isNotEmpty)
                          _buildInfoRow('Teléfono', pet.contactPhone),
                        if (pet.contactEmail.isNotEmpty)
                          _buildInfoRow('Email', pet.contactEmail),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Ubicación
                  if (pet.address.isNotEmpty) ...[
                    _buildInfoSection(
                      icon: Icons.location_on,
                      title: 'Ubicación',
                      children: [
                        _buildInfoRow('Dirección', pet.address),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Botón de acción (si existe)
                  if (onAdoptPressed != null && actionButtonText != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: onAdoptPressed,
                        icon: Icon(
                          pet.isRisk ? Icons.check_circle : Icons.favorite,
                          size: 24,
                        ),
                        label: Text(
                          actionButtonText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionButtonColor ?? Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color color;
    IconData icon;

    if (pet.isRisk) {
      text = 'En Riesgo';
      color = Colors.red;
      icon = Icons.warning;
    } else if (pet.status == PetStatus.adopted) {
      text = 'Adoptado';
      color = Colors.blue;
      icon = Icons.check_circle;
    } else if (pet.status == PetStatus.pending) {
      text = 'Pendiente';
      color = Colors.orange;
      icon = Icons.schedule;
    } else {
      text = 'Disponible';
      color = Colors.green;
      icon = Icons.pets;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 🚨 Sección de tipos de riesgo
  Widget _buildRiskTypesSection() {
    // Agrupar tipos por categoría
    final Map<String, List<RiskType>> groupedTypes = {};
    
    for (final type in pet.riskTypes) {
      final category = type.category;
      if (!groupedTypes.containsKey(category)) {
        groupedTypes[category] = [];
      }
      groupedTypes[category]!.add(type);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.report_problem, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Situación de Riesgo',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Condiciones identificadas',
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
          const SizedBox(height: 16),
          
          // Mostrar tipos agrupados por categoría
          ...groupedTypes.entries.map((entry) {
            final categoryName = entry.key;
            final types = entry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre de categoría
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 10, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    categoryName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                
                // Lista de tipos
                ...types.map((type) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            type.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
          
          // Mensaje de ayuda
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.volunteer_activism, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta mascota necesita ayuda urgente. Tu apoyo puede salvar una vida.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
