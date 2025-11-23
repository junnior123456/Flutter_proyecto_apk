# 🏗️ Integración de BLoC en Flutter - PawFinder

## Fase C: Estado Management con BLoC Pattern

### 📋 Estado Actual

#### ✅ Completado
- **PetsBloc**: Creado con eventos (FetchPets, RefreshPets) y estados (PetsInitial, PetsLoading, PetsLoaded, PetsError)
- **PetsListScreen**: Pantalla de ejemplo que usa PetsBloc
- **Estructura de carpetas**: `/lib/application/bloc/` lista para otros módulos
- **Integración con servicio**: PetsBloc usa PetService existente

#### 🔄 Pendiente
1. Crear BLoCs para módulos adicionales:
   - **AdoptionBloc**: Gestión de solicitudes de adopción
   - **CommentsBloc**: Gestión de comentarios
   - **NotificationsBloc**: Gestión de notificaciones
   - **UserBloc**: Gestión de perfil de usuario
   - **AuthBloc**: Gestión de autenticación

2. Integrar BLoCs en pantallas existentes
3. Reemplazar Direct Service Calls con BloC Selectors/Builders

---

## 🎯 Arquitectura BLoC en PawFinder

### Estructura de Carpetas
```
lib/
├── application/
│   └── bloc/
│       ├── pets/
│       │   ├── pets_bloc.dart
│       │   ├── pets_event.dart
│       │   └── pets_state.dart
│       ├── adoption/          ← Próximo
│       │   ├── adoption_bloc.dart
│       │   ├── adoption_event.dart
│       │   └── adoption_state.dart
│       ├── comments/          ← Próximo
│       ├── notifications/     ← Próximo
│       ├── user/              ← Próximo
│       └── auth/              ← Próximo
└── presentation/
    └── screens/
        ├── pets/
        │   ├── pets_list_screen.dart    ← Usa PetsBloc
        │   └── pet_detail_screen.dart   ← Próximo
        ├── adoption/
        └── auth/
```

### Patrón Base: Event-Driven State Management

```dart
// 1. EVENTOS (user actions)
abstract class PetsEvent extends Equatable {}
class FetchPets extends PetsEvent {}
class RefreshPets extends PetsEvent {}

// 2. ESTADOS (UI states)
abstract class PetsState extends Equatable {}
class PetsInitial extends PetsState {}
class PetsLoading extends PetsState {}
class PetsLoaded extends PetsState {
  final List<Pet> pets;
  PetsLoaded(this.pets);
}
class PetsError extends PetsState {
  final String message;
  PetsError(this.message);
}

// 3. BLoC (business logic)
class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final PetService petService;
  
  PetsBloc({required this.petService}) : super(PetsInitial()) {
    on<FetchPets>(_onFetchPets);
    on<RefreshPets>(_onRefreshPets);
  }
  
  Future<void> _onFetchPets(FetchPets event, Emitter<PetsState> emit) async {
    emit(PetsLoading());
    try {
      final pets = await petService.getAllPets();
      emit(PetsLoaded(pets));
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }
}

// 4. UI (widgets)
BlocBuilder<PetsBloc, PetsState>(
  builder: (context, state) {
    if (state is PetsLoaded) {
      return ListView(children: state.pets.map(...));
    } else if (state is PetsError) {
      return ErrorWidget(message: state.message);
    }
    return LoadingWidget();
  },
)
```

---

## 🚀 Pasos para Crear un Nuevo BLoC

### Paso 1: Crear Event Dart File
```dart
// lib/application/bloc/adoption/adoption_event.dart
import 'package:equatable/equatable.dart';

abstract class AdoptionEvent extends Equatable {
  const AdoptionEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchAdoptionRequests extends AdoptionEvent {
  const FetchAdoptionRequests({this.userId});
  final int? userId;
  
  @override
  List<Object?> get props => [userId];
}

class CreateAdoptionRequest extends AdoptionEvent {
  const CreateAdoptionRequest({
    required this.petId,
    required this.adopterId,
    required this.notes,
  });
  final int petId;
  final int adopterId;
  final String notes;
  
  @override
  List<Object?> get props => [petId, adopterId, notes];
}

class UpdateAdoptionStatus extends AdoptionEvent {
  const UpdateAdoptionStatus({
    required this.requestId,
    required this.status,
  });
  final int requestId;
  final String status;
  
  @override
  List<Object?> get props => [requestId, status];
}
```

### Paso 2: Crear State Dart File
```dart
// lib/application/bloc/adoption/adoption_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/models/adoption_request.dart';

abstract class AdoptionState extends Equatable {
  const AdoptionState();
  
  @override
  List<Object?> get props => [];
}

class AdoptionInitial extends AdoptionState {
  const AdoptionInitial();
}

class AdoptionLoading extends AdoptionState {
  const AdoptionLoading();
}

class AdoptionLoaded extends AdoptionState {
  const AdoptionLoaded(this.requests);
  final List<AdoptionRequest> requests;
  
  @override
  List<Object?> get props => [requests];
}

class AdoptionCreated extends AdoptionState {
  const AdoptionCreated(this.request);
  final AdoptionRequest request;
  
  @override
  List<Object?> get props => [request];
}

class AdoptionUpdated extends AdoptionState {
  const AdoptionUpdated(this.request);
  final AdoptionRequest request;
  
  @override
  List<Object?> get props => [request];
}

class AdoptionError extends AdoptionState {
  const AdoptionError(this.message);
  final String message;
  
  @override
  List<Object?> get props => [message];
}
```

### Paso 3: Crear BLoC Dart File
```dart
// lib/application/bloc/adoption/adoption_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/adoption_service.dart';
import 'adoption_event.dart';
import 'adoption_state.dart';

class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final AdoptionService adoptionService;
  
  AdoptionBloc({required this.adoptionService}) 
    : super(const AdoptionInitial()) {
    on<FetchAdoptionRequests>(_onFetchRequests);
    on<CreateAdoptionRequest>(_onCreateRequest);
    on<UpdateAdoptionStatus>(_onUpdateStatus);
  }
  
  Future<void> _onFetchRequests(
    FetchAdoptionRequests event,
    Emitter<AdoptionState> emit,
  ) async {
    emit(const AdoptionLoading());
    try {
      final requests = event.userId != null
          ? await adoptionService.getRequestsByUser(event.userId!)
          : await adoptionService.getAllRequests();
      emit(AdoptionLoaded(requests));
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }
  
  Future<void> _onCreateRequest(
    CreateAdoptionRequest event,
    Emitter<AdoptionState> emit,
  ) async {
    try {
      final request = await adoptionService.createRequest(
        petId: event.petId,
        adopterId: event.adopterId,
        notes: event.notes,
      );
      emit(AdoptionCreated(request));
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }
  
  Future<void> _onUpdateStatus(
    UpdateAdoptionStatus event,
    Emitter<AdoptionState> emit,
  ) async {
    try {
      final request = await adoptionService.updateStatus(
        requestId: event.requestId,
        status: event.status,
      );
      emit(AdoptionUpdated(request));
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }
}
```

---

## 🎨 Integración en UI (Pantallas)

### Opción A: BlocBuilder (Simple - Recomendado para listas)
```dart
BlocBuilder<PetsBloc, PetsState>(
  builder: (context, state) {
    if (state is PetsLoading) return LoadingWidget();
    if (state is PetsLoaded) return PetsList(pets: state.pets);
    if (state is PetsError) return ErrorWidget(error: state.message);
    return const SizedBox.shrink();
  },
)
```

### Opción B: BlocListener (Con efectos secundarios)
```dart
BlocListener<PetsBloc, PetsState>(
  listener: (context, state) {
    if (state is PetsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: BlocBuilder<PetsBloc, PetsState>(
    builder: (context, state) {
      // Renderizar UI según estado
    },
  ),
)
```

### Opción C: BlocSelector (Performance - Seleccionar parte del estado)
```dart
BlocSelector<PetsBloc, PetsState, List<Pet>>(
  selector: (state) {
    return state is PetsLoaded ? state.pets : [];
  },
  builder: (context, pets) {
    return PetsList(pets: pets);
  },
)
```

---

## 📦 Integración en main.dart

### Opción 1: BlocProvider Global (Recomendado)
```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PetsBloc()),
        BlocProvider(create: (context) => AdoptionBloc()),
        BlocProvider(create: (context) => NotificationsBloc()),
        BlocProvider(create: (context) => CommentsBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MaterialApp(
        title: 'PawFinder',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const PetsListScreen(),
      ),
    );
  }
}
```

### Opción 2: BlocProvider Scopeado (Por pantalla)
```dart
class AdoptionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdoptionBloc()..add(const FetchAdoptionRequests()),
      child: Scaffold(
        body: BlocBuilder<AdoptionBloc, AdoptionState>(
          builder: (context, state) {
            // Render UI
          },
        ),
      ),
    );
  }
}
```

---

## ✅ Checklist para cada BLoC

- [ ] Crear `<feature>_event.dart` con todos los eventos (FetchAll, Create, Update, Delete)
- [ ] Crear `<feature>_state.dart` con estados correspondientes
- [ ] Crear `<feature>_bloc.dart` con handlers para cada evento
- [ ] Registrar el BLoC en `main.dart` con BlocProvider
- [ ] Actualizar pantallas existentes para usar BlocBuilder/BlocListener
- [ ] Pruebas unitarias para eventos/estados del BLoC
- [ ] Verificar que los errores se emiten correctamente

---

## 🧪 Testing de BLoC

```dart
void main() {
  group('PetsBloc', () {
    late PetsBloc petsBloc;
    late MockPetService mockPetService;

    setUp(() {
      mockPetService = MockPetService();
      petsBloc = PetsBloc(petService: mockPetService);
    });

    tearDown(() => petsBloc.close());

    test('emit [PetsLoading, PetsLoaded] when FetchPets is added', () {
      // Arrange
      final mockPets = [
        Pet(id: 1, name: 'Fluffy', breed: 'Golden Retriever'),
      ];
      when(mockPetService.getAllPets()).thenAnswer((_) async => mockPets);

      // Act & Assert
      expect(
        petsBloc.stream,
        emitsInOrder([
          PetsLoading(),
          PetsLoaded(mockPets),
        ]),
      );
      petsBloc.add(FetchPets());
    });
  });
}
```

---

## 🔗 Próximos Pasos

1. **Crear BLoCs para módulos restantes**:
   - AdoptionBloc (solicitudes de adopción)
   - CommentsBloc (comentarios en mascotas)
   - NotificationsBloc (notificaciones del usuario)
   - UserBloc (perfil y preferencias)

2. **Integrar en pantallas existentes**:
   - Reemplazar `PetService.getAllPets()` con `context.read<PetsBloc>().add(FetchPets())`
   - Usar `BlocBuilder` para renderizar listas
   - Usar `BlocListener` para mostrar SnackBars/Diálogos

3. **Agregar validación y manejo de errores**:
   - Validar inputs en eventos
   - Mostrar mensajes de error descriptivos
   - Implementar reintentos automáticos

4. **Testing exhaustivo**:
   - Unit tests para cada BLoC
   - Widget tests para pantallas con BloC
   - Mock services para aislamiento

---

## 📚 Referencias

- **Flutter BLoC Library**: https://pub.dev/packages/flutter_bloc
- **Equatable Package**: https://pub.dev/packages/equatable
- **BLoC Pattern Best Practices**: https://bloclibrary.dev/#/
