class Mascota {
  final String id;
  final String nombre;
  final String tipo; // perro, gato, etc.
  final String raza;
  final String edad;
  final String descripcion;
  final String foto; // URL de la foto
  final String estado; // riesgo, adopcion, fuera_riesgo
  final String dueno;
  final String telefono;
  final String ubicacion;
  final bool adoptable;
  final String? riesgoCategoria; // Ej: perdido, maltratado, enfermo, etc

  Mascota({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.raza,
    required this.edad,
    required this.descripcion,
    required this.foto,
    required this.estado,
    required this.dueno,
    required this.telefono,
    required this.ubicacion,
    required this.adoptable,
    this.riesgoCategoria,
  });
}
