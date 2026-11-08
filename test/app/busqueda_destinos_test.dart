import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/navegacion/busqueda_destinos.dart';
import 'package:pymes_erp_mobile/app/navegacion/destinos.dart';

List<String> _ids(String consulta) {
  return buscarDestinos(destinos, consulta).map((d) => d.id).toList();
}

void main() {
  group('normalizarTexto', () {
    test('quita tildes, pasa a minúsculas y recorta', () {
      expect(normalizarTexto('  Configuración Ñandú '), 'configuracion nandu');
    });
  });

  group('buscarDestinos', () {
    test('una consulta vacía devuelve todos en su orden', () {
      expect(_ids('   '), destinos.map((d) => d.id).toList());
    });

    test('ignora tildes y mayúsculas', () {
      expect(_ids('CONFIGURACIÓN'), ['configuracion']);
      expect(_ids('pronosticos'), ['pronosticos']);
    });

    test('encuentra por sinónimo', () {
      expect(_ids('vender'), ['pos']);
      expect(_ids('stock'), ['inventario']);
    });

    test('exige todas las palabras', () {
      expect(_ids('roles permisos'), ['roles']);
      expect(_ids('roles zzz'), isEmpty);
    });

    test('sin coincidencias devuelve una lista vacía', () {
      expect(_ids('zzz'), isEmpty);
    });

    test('las coincidencias en el nombre van primero', () {
      final ids = _ids('caja');
      expect(ids.first, 'caja');
      expect(ids, contains('pos'));
    });
  });
}
