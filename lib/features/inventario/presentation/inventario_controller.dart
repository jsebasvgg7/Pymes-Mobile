import 'package:flutter/foundation.dart';

import '../../../app/navegacion/busqueda_destinos.dart';
import '../../../core/network/api_exception.dart';
import '../data/inventario_repository.dart';
import '../../../core/productos/producto_inventario.dart';

enum EstadoInventario { cargando, listo, error }

enum FiltroStock {
  todos('Todos'),
  stockBajo('Stock bajo'),
  agotados('Sin stock');

  const FiltroStock(this.etiqueta);

  final String etiqueta;
}

enum OrdenInventario {
  nombreAsc('Nombre A-Z'),
  nombreDesc('Nombre Z-A'),
  menorStock('Menor stock'),
  mayorStock('Mayor stock');

  const OrdenInventario(this.etiqueta);

  final String etiqueta;
}

class _Entrada {
  _Entrada(this.item)
    : nombre = normalizarTexto(item.nombre),
      texto = normalizarTexto('${item.nombre} ${item.sku} ${item.categoria}');

  final ProductoInventario item;
  final String nombre;
  final String texto;
}

class InventarioController extends ChangeNotifier {
  InventarioController({
    required this._repositorio,
    required this.empresaId,
    FiltroStock filtroInicial = FiltroStock.todos,
  }) : _filtro = filtroInicial;

  final InventarioRepository _repositorio;
  final int empresaId;

  EstadoInventario _estado = EstadoInventario.cargando;
  List<_Entrada> _entradas = const [];
  List<ProductoInventario> _visibles = const [];
  List<String> _categorias = const [];
  List<String> _palabras = const [];
  String _busqueda = '';
  FiltroStock _filtro;
  String? _categoria;
  OrdenInventario _orden = OrdenInventario.nombreAsc;
  String? _error;
  bool _hayDatos = false;
  bool _liberado = false;

  EstadoInventario get estado => _estado;
  String? get error => _error;
  List<ProductoInventario> get visibles => _visibles;
  List<String> get categorias => _categorias;
  int get total => _entradas.length;
  String get busqueda => _busqueda;
  FiltroStock get filtro => _filtro;
  String? get categoria => _categoria;
  OrdenInventario get orden => _orden;

  bool get hayFiltros =>
      _palabras.isNotEmpty || _filtro != FiltroStock.todos || _categoria != null;

  Future<void> cargar() async {
    _estado = EstadoInventario.cargando;
    _error = null;
    _notificar();
    await _consultar();
  }

  Future<bool> refrescar() => _consultar();

  void buscar(String texto) {
    if (texto == _busqueda) return;
    _busqueda = texto;
    _palabras = _separarPalabras(texto);
    _aplicar();
    _notificar();
  }

  void filtrar(FiltroStock filtro) {
    if (filtro == _filtro) return;
    _filtro = filtro;
    _aplicar();
    _notificar();
  }

  void elegirCategoria(String? categoria) {
    if (categoria == _categoria) return;
    _categoria = categoria;
    _aplicar();
    _notificar();
  }

  void ordenar(OrdenInventario orden) {
    if (orden == _orden) return;
    _orden = orden;
    _aplicar();
    _notificar();
  }

  void limpiarFiltros() {
    if (!hayFiltros && _busqueda.isEmpty) return;
    _busqueda = '';
    _palabras = const [];
    _filtro = FiltroStock.todos;
    _categoria = null;
    _aplicar();
    _notificar();
  }

  Future<bool> _consultar() async {
    try {
      final lista = await _repositorio.listar(empresaId);
      _entradas = lista.map(_Entrada.new).toList();
      _categorias = _calcularCategorias();
      if (_categoria != null && !_categorias.contains(_categoria)) {
        _categoria = null;
      }
      _aplicar();
      _hayDatos = true;
      _estado = EstadoInventario.listo;
      _error = null;
      _notificar();
      return true;
    } on ApiException catch (e) {
      return _fallar(e.mensaje);
    } catch (_) {
      return _fallar('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  bool _fallar(String mensaje) {
    _error = mensaje;
    if (!_hayDatos) _estado = EstadoInventario.error;
    _notificar();
    return false;
  }

  List<String> _calcularCategorias() {
    final unicas = _entradas.map((e) => e.item.categoria).toSet().toList();
    unicas.sort((a, b) => normalizarTexto(a).compareTo(normalizarTexto(b)));
    return List.unmodifiable(unicas);
  }

  List<String> _separarPalabras(String texto) {
    return normalizarTexto(
      texto,
    ).split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  }

  void _aplicar() {
    final filtradas = _entradas.where(_cumple).toList()..sort(_comparar);
    _visibles = List.unmodifiable(filtradas.map((e) => e.item));
  }

  bool _cumple(_Entrada entrada) {
    final item = entrada.item;
    switch (_filtro) {
      case FiltroStock.todos:
        break;
      case FiltroStock.stockBajo:
        if (item.estado != EstadoStock.bajo) return false;
      case FiltroStock.agotados:
        if (item.estado != EstadoStock.agotado) return false;
    }
    if (_categoria != null && item.categoria != _categoria) return false;
    return _palabras.every(entrada.texto.contains);
  }

  int _comparar(_Entrada a, _Entrada b) {
    final porNombre = a.nombre.compareTo(b.nombre);
    final base = porNombre != 0
        ? porNombre
        : a.item.productoId.compareTo(b.item.productoId);
    switch (_orden) {
      case OrdenInventario.nombreAsc:
        return base;
      case OrdenInventario.nombreDesc:
        return -base;
      case OrdenInventario.menorStock:
        final menorPrimero = a.item.cantidadActual.compareTo(
          b.item.cantidadActual,
        );
        return menorPrimero != 0 ? menorPrimero : base;
      case OrdenInventario.mayorStock:
        final mayorPrimero = b.item.cantidadActual.compareTo(
          a.item.cantidadActual,
        );
        return mayorPrimero != 0 ? mayorPrimero : base;
    }
  }

  void _notificar() {
    if (!_liberado) notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
