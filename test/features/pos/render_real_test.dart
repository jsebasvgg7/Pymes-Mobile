import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/data/icono_categoria.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/ajustes_venta.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/categoria_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/cliente_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';

/// Respuestas reales de Render (empresa 1, SuperMarket V) capturadas el 11 de
/// noviembre de 2026 con un usuario de los datos simulados. Se conservan tal
/// cual para que estas pruebas fijen el contrato real del backend y no una
/// suposicion. Para volver a capturarlas:
///   curl -H "Authorization: Bearer $TOKEN" "https://pymes-erp-api.onrender.com/api/ENDPOINT"
// Categorias reales de Render (empresa 1, SuperMarket V). Traen el campo icono.
const String _categorias = r'''{"content": [{"id": 1, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Abarrotes y granos", "icono": "shopping-basket"}, {"id": 2, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Lácteos y huevos", "icono": "milk"}, {"id": 3, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Bebidas", "icono": "cup-soda"}, {"id": 4, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Carnes y embutidos", "icono": "beef"}, {"id": 5, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Frutas y verduras", "icono": "apple"}, {"id": 6, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Aseo del hogar", "icono": "spray-can"}, {"id": 7, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Cuidado personal", "icono": "sparkles"}, {"id": 8, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Snacks y dulces", "icono": "cookie"}, {"id": 9, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Panadería", "icono": "croissant"}, {"id": 10, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Mascotas", "icono": "package"}], "totalPages": 1, "totalElements": 10}''';

// Productos reales de Render: uno normal, uno agotado, uno con la cantidad
// exactamente igual al minimo (el caso del borde) y uno en litros (unidad decimal).
const String _productos = r'''{"content": [{"id": 1, "createdAt": "2025-11-02T18:30:00", "updatedAt": "2025-11-02T18:30:00", "active": true, "empresaId": 1, "categoriaId": 1, "categoriaNombre": "Abarrotes y granos", "sku": "ABA-001", "nombre": "Arroz Blanco", "descripcion": null, "unidadMedida": "KILOGRAMO", "precioVenta": 4200.0, "costo": 3650.0, "stockMinimo": 19.0, "stockActual": 59.0, "costoPromedio": 3737.38, "impuestos": []}, {"id": 19, "createdAt": "2025-11-02T18:30:00", "updatedAt": "2025-11-02T18:30:00", "active": true, "empresaId": 1, "categoriaId": 1, "categoriaNombre": "Abarrotes y granos", "sku": "ABA-019", "nombre": "Mayonesa 400 g", "descripcion": null, "unidadMedida": "UNIDAD", "precioVenta": 6400.0, "costo": 5450.0, "stockMinimo": 3.0, "stockActual": 0.0, "costoPromedio": 5520.0, "impuestos": []}, {"id": 27, "createdAt": "2025-11-02T18:30:00", "updatedAt": "2025-11-02T18:30:00", "active": true, "empresaId": 1, "categoriaId": 1, "categoriaNombre": "Abarrotes y granos", "sku": "ABA-027", "nombre": "Vinagre Blanco 500 ml", "descripcion": null, "unidadMedida": "UNIDAD", "precioVenta": 2800.0, "costo": 2300.0, "stockMinimo": 2.0, "stockActual": 2.0, "costoPromedio": 2350.0, "impuestos": []}, {"id": 49, "createdAt": "2025-11-02T18:30:00", "updatedAt": "2025-11-02T18:30:00", "active": true, "empresaId": 1, "categoriaId": 3, "categoriaNombre": "Bebidas", "sku": "BEB-007", "nombre": "Jugo de Naranja Natural", "descripcion": null, "unidadMedida": "LITRO", "precioVenta": 6500.0, "costo": 5000.0, "stockMinimo": 2.0, "stockActual": 8.0, "costoPromedio": 4986.96, "impuestos": []}], "totalPages": 1, "totalElements": 4}''';

// Formas de pago reales de Render: Efectivo, Tarjeta y Credito.
const String _formas = r'''{"content": [{"id": 1, "createdAt": "2026-11-03T13:32:18.280121", "updatedAt": "2026-11-03T13:32:18.280121", "active": true, "empresaId": 1, "nombre": "Efectivo", "tipo": "EFECTIVO"}, {"id": 2, "createdAt": "2026-11-03T13:32:18.37551", "updatedAt": "2026-11-03T13:32:18.37551", "active": true, "empresaId": 1, "nombre": "Tarjeta", "tipo": "TARJETA"}, {"id": 4, "createdAt": "2026-11-03T13:32:18.545128", "updatedAt": "2026-11-03T13:32:18.545128", "active": true, "empresaId": 1, "nombre": "Crédito", "tipo": "CREDITO"}], "totalPages": 1, "totalElements": 3}''';

// Cliente real de Render.
const String _clientes = r'''{"content": [{"id": 1, "createdAt": "2025-10-27T18:30:00", "updatedAt": "2025-10-27T18:30:00", "active": true, "empresaId": 1, "nombre": "Yesenia Cassiani Díaz", "documento": "834100699", "telefono": "3062996322", "email": null, "direccion": null}], "totalPages": 1, "totalElements": 1}''';

// Ajustes, caja y empresa reales de Render.
const String _ajustes = r'''{"empresaId": 1, "updatedAt": "2026-11-04T17:28:28.640616", "moneda": "COP", "simboloMoneda": "$", "formatoFecha": "DD/MM/AAAA", "clienteObligatorio": false, "diasVencimientoCredito": null, "codigoBarrasActivo": false, "stockMinimoDefecto": 0.0, "avisarStockBajo": true, "horaCierreAutomatico": "04:00", "anchoRecibo": 58, "nombreRecibo": null, "mensajePieRecibo": null}''';
const String _cajas = r'''[{"cajaId": 1, "cajaNombre": "Caja Principal", "abierta": true, "requiereCierre": true, "apertura": {"id": 733, "cajaId": 1, "cajaNombre": "Caja Principal", "estado": "ABIERTA", "usuarioAperturaId": 1, "usuarioAperturaNombre": "Don Carlos", "fechaApertura": "2026-11-10T18:51:14.154841", "efectivoInicial": 0.0, "usuarioCierreId": null, "usuarioCierreNombre": null, "fechaCierre": null, "efectivoEsperado": null, "efectivoContado": null, "diferencia": null, "tipoCierre": null, "resultado": null, "requiereCierre": true}, "efectivoSugerido": 10000.0}, {"cajaId": 2, "cajaNombre": "Caja 2", "abierta": false, "requiereCierre": false, "apertura": null, "efectivoSugerido": 316155.0}]''';
const String _empresa = r'''{"id": 1, "createdAt": "2026-11-03T13:32:16.878456", "updatedAt": "2026-11-03T13:32:16.878456", "active": true, "nombre": "SuperMarket V", "nit": "PENDIENTE", "direccion": null, "telefono": null, "email": null}''';

dynamic _decodificar(String texto) => jsonDecode(texto);

void main() {
  group('categorias de Render', () {
    test('todas traen icono y el mapeo las reconoce', () {
      final lista = CategoriaPos.listaDesdePagina(_decodificar(_categorias));
      expect(lista, hasLength(10));

      for (final categoria in lista) {
        expect(categoria.icono, isNotNull, reason: categoria.nombre);
        expect(categoria.nombre, isNotEmpty);
        expect(
          iconoCategoria(categoria.nombre, clave: categoria.icono),
          isNotEmpty,
          reason: 'sin icono para ${categoria.nombre} (${categoria.icono})',
        );
      }
    });

    test('ninguna cae en el icono generico por falta de clave', () {
      final lista = CategoriaPos.listaDesdePagina(_decodificar(_categorias));
      final generico = iconoCategoria('Sin coincidencia');

      for (final categoria in lista) {
        expect(
          iconoCategoria(categoria.nombre, clave: categoria.icono),
          isNot(generico),
          reason: '${categoria.nombre} con clave ${categoria.icono}',
        );
      }
    });
  });

  group('productos de Render', () {
    test('se leen con id, categoria, unidad y precio', () {
      final lista = ProductoInventario.listaDesdePagina(_decodificar(_productos));
      expect(lista, hasLength(4));

      for (final producto in lista) {
        expect(producto.productoId, greaterThan(0));
        expect(producto.nombre, isNotEmpty);
        expect(producto.precioVenta, greaterThan(0));
        expect(producto.unidadMedida, isNotEmpty);
        expect(producto.categoriaId, isNotNull);
      }
    });

    test('el agotado se detecta por la cantidad', () {
      final lista = ProductoInventario.listaDesdePagina(_decodificar(_productos));
      final agotado = lista.firstWhere((p) => p.agotado);

      expect(agotado.cantidadActual, lessThanOrEqualTo(0));
      expect(agotado.estado, EstadoStock.agotado);
    });

    test('la cantidad igual al minimo da stock bajo, como en la web', () {
      final lista = ProductoInventario.listaDesdePagina(_decodificar(_productos));
      final borde = lista.firstWhere((p) => p.cantidadActual == p.stockMinimo);

      expect(borde.estado, EstadoStock.bajo);
    });

    test('una unidad con decimales permite media unidad', () {
      final lista = ProductoInventario.listaDesdePagina(_decodificar(_productos));
      final litros = lista.firstWhere((p) => p.unidadMedida == 'LITRO');

      expect(litros.permiteDecimales, isTrue);
    });
  });

  group('formas de pago, clientes y ajustes de Render', () {
    test('las formas de pago traen su tipo', () {
      final lista = FormaPago.listaDesdePagina(_decodificar(_formas));
      expect(lista, hasLength(3));

      for (final forma in lista) {
        expect(forma.nombre, isNotEmpty);
      }
      expect(lista.any((f) => f.esEfectivo), isTrue);
      expect(lista.any((f) => f.esCredito), isTrue);
    });

    test('los clientes traen nombre', () {
      final lista = ClientePos.listaDesdePagina(_decodificar(_clientes));
      expect(lista, isNotEmpty);
      for (final cliente in lista) {
        expect(cliente.nombre, isNotEmpty);
      }
    });

    test('los ajustes traen moneda, simbolo y cliente obligatorio', () {
      final leido = AjustesVenta.fromJson(_decodificar(_ajustes) as Map<String, dynamic>);

      expect(leido.moneda, 'COP');
      expect(leido.simboloMoneda, r'$');
      expect(leido.clienteObligatorio, isFalse);
      expect(leido.nombreRecibo, isEmpty);
    });
  });

  group('caja y empresa de Render', () {
    test('el estado de caja dice si esta abierta', () {
      final lista = EstadoCaja.listaDesdeJson(_decodificar(_cajas));
      expect(lista, isNotEmpty);

      for (final caja in lista) {
        expect(caja.cajaNombre, isNotEmpty);
      }
      expect(lista.any((c) => c.abierta), isTrue);
    });

    test('la empresa trae el nombre para el recibo', () {
      final nombre = (_decodificar(_empresa) as Map<String, dynamic>)['nombre'] as String?;
      expect(nombre, isNotNull);
      expect(nombre!.isNotEmpty, isTrue);
    });
  });
}
