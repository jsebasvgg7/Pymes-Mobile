import 'package:hugeicons/hugeicons.dart';

import '../../../app/navegacion/busqueda_destinos.dart';

/// Catálogo de iconos de categoría, con las mismas claves que la web
/// (`frontend/src/utils/categoriaIcono.ts`) para que el ícono que el usuario
/// elige en el navegador se vea igual en el móvil.
const Map<String, List<List<dynamic>>> _porClave = {
  'tag': HugeIcons.strokeRoundedTag01,
  'cup-soda': HugeIcons.strokeRoundedCupSoda,
  'croissant': HugeIcons.strokeRoundedCroissant,
  'spray-can': HugeIcons.strokeRoundedSprayCan,
  'pencil': HugeIcons.strokeRoundedPencil,
  'wrench': HugeIcons.strokeRoundedTools,
  'beef': HugeIcons.strokeRoundedBeef,
  'milk': HugeIcons.strokeRoundedMilk,
  'apple': HugeIcons.strokeRoundedApple,
  'cookie': HugeIcons.strokeRoundedCookie,
  'shopping-basket': HugeIcons.strokeRoundedShoppingBasket01,
  'shirt': HugeIcons.strokeRoundedTShirt,
  'laptop': HugeIcons.strokeRoundedLaptop,
  'house': HugeIcons.strokeRoundedHome01,
  'utensils': HugeIcons.strokeRoundedUtensils,
  'puzzle': HugeIcons.strokeRoundedPuzzle,
  'pill': HugeIcons.strokeRoundedPill,
  'sparkles': HugeIcons.strokeRoundedSparkles,
  'package': HugeIcons.strokeRoundedPackage,
  'gift': HugeIcons.strokeRoundedGift,
};

/// Reglas por palabra clave, las mismas de la web.
const List<({List<String> claves, String icono})> _reglas = [
  (
    claves: ['bebida', 'gaseosa', 'jugo', 'agua', 'cerveza', 'licor', 'cafe'],
    icono: 'cup-soda',
  ),
  (
    claves: ['pan', 'panader', 'pastel', 'reposter', 'torta'],
    icono: 'croissant',
  ),
  (claves: ['aseo', 'limpieza', 'detergente', 'higiene'], icono: 'spray-can'),
  (claves: ['papeler', 'escolar', 'oficina', 'cuaderno'], icono: 'pencil'),
  (claves: ['ferret', 'herramienta', 'tornill', 'construc'], icono: 'wrench'),
  (
    claves: ['carne', 'pollo', 'embutido', 'pescado', 'charcuter'],
    icono: 'beef',
  ),
  (claves: ['lacteo', 'leche', 'queso', 'yogur'], icono: 'milk'),
  (claves: ['fruta', 'verdura', 'hortaliza', 'legumbre'], icono: 'apple'),
  (
    claves: ['snack', 'dulce', 'galleta', 'confiter', 'golosina', 'mecato'],
    icono: 'cookie',
  ),
];

List<List<dynamic>> iconoCategoria(String nombre, {String? clave}) {
  if (clave != null) {
    final porClave = _porClave[clave];
    if (porClave != null) return porClave;
  }
  final base = normalizarTexto(nombre);
  for (final regla in _reglas) {
    if (regla.claves.any(base.contains)) {
      final encontrado = _porClave[regla.icono];
      if (encontrado != null) return encontrado;
    }
  }
  return HugeIcons.strokeRoundedTag01;
}
