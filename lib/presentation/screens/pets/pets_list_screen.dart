import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/pets/pets_bloc.dart';
import '../../../application/bloc/pets/pets_event.dart';
import '../../../application/bloc/pets/pets_state.dart';

class PetsListScreen extends StatefulWidget {
  const PetsListScreen({Key? key}) : super(key: key);

  @override
  State<PetsListScreen> createState() => _PetsListScreenState();
}

class _PetsListScreenState extends State<PetsListScreen> {
  late PetsBloc _petsBloc;

  @override
  void initState() {
    super.initState();
    _petsBloc = PetsBloc();
    // Disparar evento para cargar mascotas al abrir la pantalla
    _petsBloc.add(FetchPets());
  }

  @override
  void dispose() {
    _petsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas Disponibles'),
        elevation: 0,
      ),
      body: BlocProvider<PetsBloc>.value(
        value: _petsBloc,
        child: BlocBuilder<PetsBloc, PetsState>(
          builder: (context, state) {
            if (state is PetsInitial) {
              return const Center(child: Text('Presiona el botón para cargar mascotas'));
            } else if (state is PetsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PetsLoaded) {
              final pets = state.pets;
              if (pets.isEmpty) {
                return const Center(child: Text('No hay mascotas disponibles'));
              }
              return ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: pet.imageUrl.isNotEmpty
                          ? Image.network(
                              pet.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.pets);
                              },
                            )
                          : const Icon(Icons.pets),
                      title: Text(pet.name),
                      subtitle: Text(pet.breed.isEmpty ? 'Sin raza especificada' : pet.breed),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detalles de ${pet.name}')),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is PetsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<PetsBloc>().add(FetchPets()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Estado desconocido'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _petsBloc.add(RefreshPets()),
        tooltip: 'Refrescar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
