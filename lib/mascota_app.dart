import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/mascota_bloc_providers.dart';
import '../presentation/screens/mascotas_list_screen.dart';

class MascotasApp extends StatelessWidget {
  const MascotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: mascotaBlocProviders,
      child: MaterialApp(
  title: 'PawFinder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.orange,
          ),
        ),
        home: const MascotasListScreen(),
      ),
    );
  }
}