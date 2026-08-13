// Smoke test de PawFinder.
//
// El test generado por defecto buscaba el texto "Mascotas en Tarapoto" y un
// FAB de la UI original; la app evolucionó y ese texto ya no existe, por lo
// que fallaba. Este smoke test verifica lo esencial y estable: que la app
// arranca y construye su MaterialApp sin lanzar excepciones en el primer frame.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prototipe1/mascota_app.dart';

void main() {
  testWidgets('La app arranca y construye un MaterialApp', (WidgetTester tester) async {
    // Construye la app y dispara un frame.
    await tester.pumpWidget(const MascotasApp());

    // La app debe montar su MaterialApp (arranca sin romperse).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
