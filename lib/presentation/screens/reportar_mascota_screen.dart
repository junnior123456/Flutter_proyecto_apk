import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/mascota.dart';
import '../../application/bloc/mascota_bloc.dart';
import '../../application/bloc/mascota_event.dart';

class ReportarMascotaScreen extends StatefulWidget {
  const ReportarMascotaScreen({super.key});

  @override
  State<ReportarMascotaScreen> createState() => _ReportarMascotaScreenState();
}

class _ReportarMascotaScreenState extends State<ReportarMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fotoController = TextEditingController();
  final _duenoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  
  String _estadoSeleccionado = 'riesgo';
  final List<String> _estados = ['riesgo', 'adopcion', 'fuera_riesgo'];
  final List<String> _tipos = ['Perro', 'Gato', 'Ave', 'Conejo', 'Otro'];
  String? _riesgoCategoriaSeleccionada;
  final List<String> _categoriasRiesgo = ['Perdido', 'Maltratado', 'Enfermo', 'Abandonado', 'Otro'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Mascota'),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de la Mascota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la mascota *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de mascota *',
                  border: OutlineInputBorder(),
                ),
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  _tipoController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona el tipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Raza
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Edad
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(
                  labelText: 'Edad aproximada',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 2 años, 6 meses',
                ),
              ),
              const SizedBox(height: 16),

              // Estado
              DropdownButtonFormField<String>(
                initialValue: _estadoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Estado *',
                  border: OutlineInputBorder(),
                ),
                items: _estados.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _estadoSeleccionado = value ?? 'riesgo';
                    if (_estadoSeleccionado != 'riesgo') {
                      _riesgoCategoriaSeleccionada = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Categoría de riesgo (solo si estado es 'riesgo')
              if (_estadoSeleccionado == 'riesgo') ...[
                DropdownButtonFormField<String>(
                  value: _riesgoCategoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría de riesgo',
                    border: OutlineInputBorder(),
                  ),
                  items: _categoriasRiesgo.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _riesgoCategoriaSeleccionada = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona la categoría de riesgo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Descripción
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  border: OutlineInputBorder(),
                  hintText: 'Describe características físicas, comportamiento, etc.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL de foto
              TextFormField(
                controller: _fotoController,
                decoration: const InputDecoration(
                  labelText: 'URL de la foto',
                  border: OutlineInputBorder(),
                  hintText: 'https://ejemplo.com/foto.jpg',
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Información de Contacto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Dueño
              TextFormField(
                controller: _duenoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del contacto *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de contacto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  border: OutlineInputBorder(),
                  hintText: '+51 999 999 999',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ubicación
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación *',
                  border: OutlineInputBorder(),
                  hintText: 'Distrito, referencia',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la ubicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón de enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Reportar Mascota',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final mascota = Mascota(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text.trim(),
        tipo: _tipoController.text.trim(),
        raza: _razaController.text.trim().isEmpty 
            ? 'Desconocida' 
            : _razaController.text.trim(),
        edad: _edadController.text.trim().isEmpty 
            ? 'No especificada' 
            : _edadController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        foto: _fotoController.text.trim(),
        estado: _estadoSeleccionado,
        dueno: _duenoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        ubicacion: _ubicacionController.text.trim(),
        adoptable: _estadoSeleccionado == 'adopcion',
        riesgoCategoria: _estadoSeleccionado == 'riesgo' ? _riesgoCategoriaSeleccionada : null,
      );

      context.read<MascotaBloc>().add(AddMascotaEvent(mascota));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mascota reportada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _razaController.dispose();
    _edadController.dispose();
    _descripcionController.dispose();
    _fotoController.dispose();
    _duenoController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}