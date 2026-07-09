import 'package:flutter/material.dart';
import '../../domain/entities/pet.dart';

/// 🎴 Widget de tarjeta de mascota - Clean Architecture
/// No tiene dependencias de features, solo usa callbacks.
///
/// La tarjeta NO fija su tamaño: se adapta a la celda que la contiene (GridView)
/// o al ancho que le den. Antes tenía `width: 160, height: 240` y un margen sólo
/// a la derecha, pensados para una lista horizontal; dentro de una rejilla eso
/// descentraba las tarjetas y rompía la simetría.
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
    final scheme = Theme.of(context).colorScheme;

    // Placeholder cuando no hay imagen o falla la carga.
    Widget placeholder() => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.pets, size: 40, color: scheme.onSurfaceVariant),
        );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera de autor, estilo publicación de red social: foto + nombre
          // del perfil de quien publicó (viene de `pet.user`).
          _AuthorHeader(pet: pet),

          // La imagen ocupa el espacio sobrante de la celda.
          Expanded(
            child: GestureDetector(
              onTap: onImageTap, // ✅ Usa el callback si existe
              child: pet.imageUrl.isNotEmpty
                  ? Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => placeholder(),
                    )
                  : placeholder(),
            ),
          ),

          // Info (altura mínima: nunca desborda la celda)
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
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
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
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

/// Cabecera "posteado por": avatar del autor + su nombre. Usa `pet.ownerName`
/// (nombre del perfil, con el contacto de la publicación como respaldo).
class _AuthorHeader extends StatelessWidget {
  final Pet pet;
  const _AuthorHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image = pet.user?.image;
    final name = pet.ownerName;
    if (name.trim().isEmpty) return const SizedBox.shrink();

    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: (image != null && image.isNotEmpty)
                ? NetworkImage(image)
                : null,
            child: (image == null || image.isEmpty)
                ? Text(initial,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer))
                : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
