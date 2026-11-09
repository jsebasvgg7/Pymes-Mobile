import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/shell/avatar_usuario.dart';
import 'package:pymes_erp_mobile/app/shell/patron_avatar.dart';

void main() {
  test('el hash es estable y conocido', () {
    expect(hashSemilla(''), 0x811C9DC5);
    expect(hashSemilla('a'), 0xE40C292C);
  });

  test('la misma semilla da siempre el mismo patrón', () {
    expect(patronAvatar('don@correo.com'), patronAvatar('don@correo.com'));
  });

  test('ignora mayúsculas y espacios en los bordes', () {
    expect(patronAvatar('  Don@Correo.com '), patronAvatar('don@correo.com'));
  });

  test('semillas distintas dan patrones distintos', () {
    final semillas = [
      'ana@correo.com',
      'luis@correo.com',
      'sofia@correo.com',
      'don@correo.com',
      'maria@correo.com',
    ];
    final patrones = semillas.map((s) => patronAvatar(s).toString()).toSet();
    expect(patrones.length, semillas.length);
  });

  test('el patrón es de 5 x 5, simétrico y con valores de 0 a 2', () {
    final patron = patronAvatar('simetria@correo.com');
    expect(patron.length, 5);
    for (final fila in patron) {
      expect(fila.length, 5);
      expect(fila[0], fila[4]);
      expect(fila[1], fila[3]);
      for (final valor in fila) {
        expect(valor, inInclusiveRange(0, 2));
      }
    }
  });

  test('nunca queda vacío', () {
    for (var i = 0; i < 200; i++) {
      final llenas = patronAvatar('usuario$i').expand((f) => f).where((v) => v != 0);
      expect(llenas, isNotEmpty);
    }
  });

  testWidgets('sin nombre ni semilla muestra el signo de pregunta', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AvatarUsuario(username: ''))),
      ),
    );
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('con nombre dibuja el patrón y no la inicial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AvatarUsuario(username: 'Don', semilla: 'don@correo.com'),
          ),
        ),
      ),
    );
    expect(find.text('D'), findsNothing);
    expect(find.text('?'), findsNothing);
  });
}
