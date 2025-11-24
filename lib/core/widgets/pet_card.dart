import 'package:flutter/material.dart';
import '../../domain/entities/pet.dart';

/// 🎴 Widget de tarjeta de mascota - Clean Architecture
/// No tiene dependencias de features, solo usa callbacks
class PetCard extends StatelessWidget {
  final Pet pet;
  final String buttonText;
  final VoidCallback onPressed;
  final VoidCallback? onImageTap; // ✅ Callback para navegación
  final Color? buttonColor;
  final IconData? buttonIcon;

  const PetCard({
    super.key,
    required this.pet,
    required this.buttonText,
    required this.onPressed,
    this.onImageTap, // ✅ Opcional
    this.buttonColor,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 240,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen con altura fija - Clickeable si hay callback
            GestureDetector(
              onTap: onImageTap, // ✅ Usa el callback si existe
              child: SizedBox(
                height: 140,
                child: pet.imageUrl.isNotEmpty
                    ? Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                      ),
              ),
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pet.breed.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      pet.breed,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor ?? Colors.orange,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
