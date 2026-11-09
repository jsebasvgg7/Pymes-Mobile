import 'package:hugeicons/hugeicons.dart';

import 'destino.dart';

const String rutaInventarioStockBajo = '/inventario?filtro=stock-bajo';

const List<Destino> destinos = [
  Destino(
    id: 'inicio',
    nombre: 'Inicio',
    icono: HugeIcons.strokeRoundedHome01,
    grupo: GrupoDestino.barra,
    ruta: '/',
    sinonimos: ['dashboard', 'resumen', 'panel', 'principal'],
  ),
  Destino(
    id: 'pos',
    nombre: 'Ventas (POS)',
    icono: HugeIcons.strokeRoundedComputer,
    grupo: GrupoDestino.barra,
    sinonimos: [
      'vender',
      'venta',
      'pos',
      'cobrar',
      'facturar',
      'caja registradora',
    ],
  ),
  Destino(
    id: 'inventario',
    nombre: 'Inventario',
    icono: HugeIcons.strokeRoundedPackage,
    grupo: GrupoDestino.barra,
    ruta: '/inventario',
    sinonimos: ['stock', 'existencias', 'ajuste', 'bodega'],
  ),
  Destino(
    id: 'caja',
    nombre: 'Caja',
    icono: HugeIcons.strokeRoundedWallet01,
    grupo: GrupoDestino.barra,
    sinonimos: ['efectivo', 'dinero', 'apertura', 'cierre', 'gasto'],
  ),
  Destino(
    id: 'pronosticos',
    nombre: 'Pronósticos',
    icono: HugeIcons.strokeRoundedAnalyticsUp,
    grupo: GrupoDestino.operacion,
    sinonimos: ['demanda', 'proyeccion', 'prediccion', 'tendencia', 'reponer'],
  ),
  Destino(
    id: 'compras',
    nombre: 'Compras',
    icono: HugeIcons.strokeRoundedShoppingCart01,
    grupo: GrupoDestino.operacion,
    sinonimos: ['comprar', 'surtir', 'abastecer'],
  ),
  Destino(
    id: 'productos',
    nombre: 'Productos',
    icono: HugeIcons.strokeRoundedPackage,
    grupo: GrupoDestino.catalogo,
    sinonimos: ['articulos', 'sku', 'precio', 'costo'],
  ),
  Destino(
    id: 'categorias',
    nombre: 'Categorías',
    icono: HugeIcons.strokeRoundedTag01,
    grupo: GrupoDestino.catalogo,
    sinonimos: ['grupos', 'clasificar'],
  ),
  Destino(
    id: 'clientes',
    nombre: 'Clientes',
    icono: HugeIcons.strokeRoundedUserGroup,
    grupo: GrupoDestino.catalogo,
    sinonimos: ['fiado', 'credito', 'deuda', 'abono', 'cuentas por cobrar'],
  ),
  Destino(
    id: 'proveedores',
    nombre: 'Proveedores',
    icono: HugeIcons.strokeRoundedDeliveryTruck01,
    grupo: GrupoDestino.catalogo,
    sinonimos: ['distribuidor', 'surtidor'],
  ),
  Destino(
    id: 'reportes',
    nombre: 'Reportes',
    icono: HugeIcons.strokeRoundedFile02,
    grupo: GrupoDestino.administracion,
    sinonimos: ['csv', 'exportar', 'informe', 'historial'],
  ),
  Destino(
    id: 'usuarios',
    nombre: 'Usuarios',
    icono: HugeIcons.strokeRoundedUserSettings01,
    grupo: GrupoDestino.administracion,
    sinonimos: ['empleados', 'cuentas', 'personal'],
  ),
  Destino(
    id: 'roles',
    nombre: 'Roles y Permisos',
    icono: HugeIcons.strokeRoundedShield01,
    grupo: GrupoDestino.administracion,
    sinonimos: ['accesos', 'modulos', 'seguridad'],
  ),
  Destino(
    id: 'configuracion',
    nombre: 'Configuración',
    icono: HugeIcons.strokeRoundedSettings01,
    grupo: GrupoDestino.administracion,
    sinonimos: ['ajustes', 'moneda', 'recibo', 'empresa'],
  ),
];

List<Destino> destinosDe(GrupoDestino grupo) {
  return destinos.where((d) => d.grupo == grupo).toList();
}

Destino? destinoPorId(String id) {
  for (final d in destinos) {
    if (d.id == id) {
      return d;
    }
  }
  return null;
}

Destino? destinoPorRuta(String ruta) {
  for (final d in destinos) {
    if (d.ruta == ruta) {
      return d;
    }
  }
  return null;
}
