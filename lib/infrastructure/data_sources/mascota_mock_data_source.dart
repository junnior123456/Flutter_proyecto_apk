import '../../domain/entities/mascota.dart';

class MascotaMockDataSource {
  final List<Mascota> _mascotas = [
    Mascota(
      id: '1',
      nombre: 'Firulais',
      tipo: 'Perro',
      raza: 'Labrador',
      edad: '3 años',
      descripcion: 'Perro juguetón, color marrón. Muy sociable y cariñoso.',
      foto: 'https://example.com/firulais.jpg',
      estado: 'adopcion',
      dueno: 'María García',
      telefono: '+51 942 123 456',
      ubicacion: 'Morales, Tarapoto',
      adoptable: true,
      riesgoCategoria: null,
    ),
    Mascota(
      id: '2',
      nombre: 'Mishi',
      tipo: 'Gato',
      raza: 'Siamés',
      edad: '2 años',
      descripcion: 'Gato blanco, ojos azules. Se perdió el 20 de septiembre.',
      foto: 'https://example.com/mishi.jpg',
      estado: 'riesgo',
      dueno: 'Carlos Pérez',
      telefono: '+51 965 789 123',
      ubicacion: 'La Banda de Shilcayo, Tarapoto',
      adoptable: false,
      riesgoCategoria: 'Perdido',
    ),
    Mascota(
      id: '3',
      nombre: 'Rocky',
      tipo: 'Perro',
      raza: 'Pastor Alemán',
      edad: '5 años',
      descripcion: 'Perro guardián muy inteligente. Busca familia responsable.',
      foto: 'https://example.com/rocky.jpg',
      estado: 'adopcion',
      dueno: 'Ana Rodríguez',
      telefono: '+51 987 456 789',
      ubicacion: 'Tarapoto Centro',
      adoptable: true,
      riesgoCategoria: null,
    ),
  ];

  List<Mascota> getMascotas() => _mascotas;

  void addMascota(Mascota mascota) {
    _mascotas.add(mascota);
  }

  void reportarMascotaEnRiesgo(String id, String categoria) {
    final index = _mascotas.indexWhere((m) => m.id == id);
    if (index != -1) {
      final mascota = _mascotas[index];
      _mascotas[index] = Mascota(
        id: mascota.id,
        nombre: mascota.nombre,
        tipo: mascota.tipo,
        raza: mascota.raza,
        edad: mascota.edad,
        descripcion: mascota.descripcion,
        foto: mascota.foto,
        estado: 'riesgo',
        dueno: mascota.dueno,
        telefono: mascota.telefono,
        ubicacion: mascota.ubicacion,
        adoptable: mascota.adoptable,
        riesgoCategoria: categoria,
      );
    }
  }

  void marcarMascotaFueraDeRiesgo(String id) {
    final index = _mascotas.indexWhere((m) => m.id == id);
    if (index != -1) {
      final mascota = _mascotas[index];
      _mascotas[index] = Mascota(
        id: mascota.id,
        nombre: mascota.nombre,
        tipo: mascota.tipo,
        raza: mascota.raza,
        edad: mascota.edad,
        descripcion: mascota.descripcion,
        foto: mascota.foto,
        estado: 'fuera_riesgo',
        dueno: mascota.dueno,
        telefono: mascota.telefono,
        ubicacion: mascota.ubicacion,
        adoptable: mascota.adoptable,
        riesgoCategoria: null,
      );
    }
  }
}
