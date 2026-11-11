import 'package:flutter/foundation.dart';

import '../../../core/productos/producto_inventario.dart';
import '../data/models/ajustes_venta.dart';
import '../data/models/categoria_pos.dart';
import '../data/models/estado_caja.dart';
import '../data/pos_repository.dart';
import 'carrito_controller.dart';

enum EstadoPos { cargando, listo, error }

class PosController extends ChangeNotifier {
  PosController({required this._repositorio, required this.empresaId});

  final PosRepository _repositorio;
  final int empresaId;

  EstadoPos _estado = EstadoPos.cargando;
  String? _error;
  List<ProductoInventario> _productos = const [];
  List<CategoriaPos> _categorias = const [];
  List<EstadoCaja> _cajas = const [];
  AjustesVenta _ajustes = const AjustesVenta();
  String _nombreEmpresa = '';
  CarritoController? _carrito;
  String _busqueda = '';
  int? _categoriaElegida;

  EstadoPos get estado => _estado;

  String? get error => _error;

  List<ProductoInventario> get productos => _productos;

  List<CategoriaPos> get categorias => _categorias;

  List<EstadoCaja> get cajas => _cajas;

  AjustesVenta get ajustes => _ajustes;

  String get nombreEmpresa => _nombreEmpresa;

  String get busqueda => _busqueda;

  int? get categoriaElegida => _categoriaElegida;

  CarritoController get carrito {
    final existente = _carrito;
    if (existente != null) return existente;
    final nuevo = CarritoController(
      ajustes: _ajustes,
      repositorio: _repositorio,
      iconosCategoria: _iconosCategoria,
    );
    _carrito = nuevo;
    return nuevo;
  }

  Map<int, String> get _iconosCategoria => {
    for (final categoria in _categorias)
      if (categoria.icono != null && categoria.icono!.isNotEmpty)
        categoria.id: categoria.icono!,
  };

  bool get hayCajaAbierta => _cajas.any((caja) => caja.abierta);

  bool get sinCajaAbierta => _cajas.isNotEmpty && !hayCajaAbierta;

  List<ProductoInventario> get productosVisibles {
    final palabras = _busqueda
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    final filtrados = _productos.where((producto) {
      if (_categoriaElegida != null &&
          producto.categoriaId != _categoriaElegida) {
        return false;
      }
      if (palabras.isEmpty) return true;
      final texto = '${producto.nombre} ${producto.sku} ${producto.categoria}'
          .toLowerCase();
      return palabras.every(texto.contains);
    }).toList();
    filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));
    return filtrados;
  }

  List<CategoriaPos> get categoriasVisibles {
    final usadas = <int>{};
    for (final producto in _productos) {
      final id = producto.categoriaId;
      if (id != null) usadas.add(id);
    }
    final visibles = _categorias
        .where((categoria) => usadas.contains(categoria.id))
        .toList();
    visibles.sort((a, b) => a.nombre.compareTo(b.nombre));
    return visibles;
  }

  Future<void> cargar() async {
    _estado = EstadoPos.cargando;
    _error = null;
    _notificar();
    try {
      final productos = await _repositorio.productos(empresaId);
      final categorias = await _repositorio.categorias(empresaId);
      final formas = await _repositorio.formasDePago(empresaId);
      final clientes = await _repositorio.clientes(empresaId);
      final ajustes = await _repositorio.ajustes(empresaId);
      final cajas = await _repositorio.estadoDeCajas(empresaId);
      final empresa = await _repositorio.nombreEmpresa(empresaId);

      _productos = productos;
      _categorias = categorias;
      _ajustes = ajustes;
      _cajas = cajas;
      _nombreEmpresa = empresa;
      _carrito = CarritoController(
        ajustes: ajustes,
        repositorio: _repositorio,
        iconosCategoria: _iconosCategoria,
      )
        ..cargarFormasDePago(formas)
        ..cargarClientes(clientes);
      _estado = EstadoPos.listo;
    } catch (e) {
      _error = 'No pudimos cargar el punto de venta. Revisa tu conexión.';
      _estado = EstadoPos.error;
    }
    _notificar();
  }

  void buscar(String texto) {
    if (_busqueda == texto) return;
    _busqueda = texto;
    _notificar();
  }

  void elegirCategoria(int? categoriaId) {
    if (_categoriaElegida == categoriaId) return;
    _categoriaElegida = categoriaId;
    _notificar();
  }

  bool _liberado = false;

  void _notificar() {
    if (!_liberado) notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    _carrito?.dispose();
    super.dispose();
  }
}
