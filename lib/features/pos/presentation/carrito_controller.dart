import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/format/cantidad.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/productos/producto_inventario.dart';
import '../data/icono_categoria.dart';
import '../data/models/ajustes_venta.dart';
import '../data/models/cliente_pos.dart';
import '../data/models/forma_pago.dart';
import '../data/models/venta_creada.dart';
import '../data/pos_repository.dart';

class LineaCarrito {
  const LineaCarrito({required this.producto, required this.cantidad});

  final ProductoInventario producto;
  final num cantidad;

  num get totalLinea => CarritoController.redondearMoneda(
    (cantidad * producto.precioVenta).toDouble(),
  );

  LineaCarrito copyWith({num? cantidad}) =>
      LineaCarrito(producto: producto, cantidad: cantidad ?? this.cantidad);
}

enum EstadoVenta { vacio, listo, error }

class CarritoController extends ChangeNotifier {
  CarritoController({
    required this.ajustes,
    this._repositorio,
    this.iconosCategoria = const {},
  });

  static const double _pasoDecimal = 0.5;
  static const int _maxDecimales = 3;

  final AjustesVenta ajustes;
  final Map<int, String> iconosCategoria;
  final PosRepository? _repositorio;

  final List<LineaCarrito> _lineas = [];
  final Map<int, ProductoInventario> _productos = {};

  int? _clienteId;
  int? _formaPagoId;
  num _descuento = 0;
  num _recibido = 0;
  EstadoVenta _estado = EstadoVenta.vacio;
  String? _error;
  VentaCreada? _ventaRegistrada;
  bool _enviando = false;

  List<LineaCarrito> get lineas => List.unmodifiable(_lineas);

  int? get clienteId => _clienteId;

  int? get formaPagoId => _formaPagoId;

  num get descuento => _descuento;

  num get recibido => _recibido;

  EstadoVenta get estado => _estado;

  String? get error => _error;

  VentaCreada? get ventaRegistrada => _ventaRegistrada;

  bool get enviando => _enviando;

  bool get vacio => _lineas.isEmpty;

  bool get esEfectivo => _formaPago?.esEfectivo ?? false;

  bool get esCredito => _formaPago?.esCredito ?? false;

  FormaPago? get _formaPago {
    if (_formaPagoId == null) return null;
    for (final forma in _formasPago) {
      if (forma.id == _formaPagoId) return forma;
    }
    return null;
  }

  List<FormaPago> _formasPago = const [];
  List<ClientePos> _clientes = const [];

  List<FormaPago> get formasDePago => _formasPago;

  List<ClientePos> get clientes => _clientes;

  num get subtotal {
    var total = 0.0;
    for (final linea in _lineas) {
      total += linea.totalLinea.toDouble();
    }
    return CarritoController.redondearMoneda(total);
  }

  num get total =>
      CarritoController.redondearMoneda((subtotal - _descuento).toDouble());

  num get vuelto {
    if (!esEfectivo) return 0;
    return CarritoController.redondearMoneda((_recibido - total).toDouble());
  }

  bool get faltaEfectivo => esEfectivo && _recibido > 0 && _recibido < total;

  bool get clienteObligatorio =>
      esCredito || (ajustes.clienteObligatorio && _lineas.isNotEmpty);

  bool get faltaCliente => clienteObligatorio && _clienteId == null;

  bool get puedeFinalizar =>
      _lineas.isNotEmpty &&
      _formaPagoId != null &&
      !faltaCliente &&
      !faltaEfectivo &&
      !_lineas.any((linea) => !cantidadValida(linea.cantidad, linea.producto));

  int get cantidadProductos => _lineas.length;

  num get unidadesTotales {
    var total = 0.0;
    for (final linea in _lineas) {
      total += linea.producto.permiteDecimales ? 1 : linea.cantidad;
    }
    return total;
  }

  bool llegoAlTope(LineaCarrito linea) => linea.cantidad >= linea.producto.cantidadActual;

  num precioUnitario(LineaCarrito linea) => linea.producto.precioVenta;

  String unidad(LineaCarrito linea) =>
      abreviarUnidad(linea.producto.unidadMedida, linea.producto.cantidadActual);

  bool puedeSubir(LineaCarrito linea) => !llegoAlTope(linea);

  List<List<dynamic>> iconoDe(ProductoInventario producto) {
    final id = producto.categoriaId;
    return iconoCategoria(
      producto.categoria.toString(),
      clave: id == null ? null : iconosCategoria[id],
    );
  }

  void cargarFormasDePago(List<FormaPago> formas) {
    _formasPago = formas.where((forma) => forma.activo).toList();
    if (_formaPagoId != null) return;
    for (final forma in _formasPago) {
      if (forma.esEfectivo) {
        _formaPagoId = forma.id;
        return;
      }
    }
    if (_formasPago.isNotEmpty) _formaPagoId = _formasPago.first.id;
  }

  void cargarClientes(List<ClientePos> clientes) {
    _clientes = clientes.where((cliente) => cliente.activo).toList();
  }

  void registrarProductos(List<ProductoInventario> productos) {
    _productos
      ..clear()
      ..addEntries(
        productos.map((producto) => MapEntry(producto.productoId, producto)),
      );
  }

  ProductoInventario? productoPorId(int productoId) => _productos[productoId];

  bool estaSeleccionado(int productoId) =>
      _lineas.any((linea) => linea.producto.productoId == productoId);

  bool agregar(ProductoInventario producto) {
    if (producto.agotado) return false;
    final paso = pasoDe(producto);
    final existente = _buscar(producto.productoId);
    if (existente == null) {
      final cantidad = math.min(paso, producto.cantidadActual);
      if (cantidad <= 0) return false;
      _lineas.add(LineaCarrito(producto: producto, cantidad: cantidad));
    } else {
      final cantidad = math.min(
        existente.cantidad + paso,
        producto.cantidadActual,
      );
      _quitar(producto.productoId);
      _lineas.add(LineaCarrito(producto: producto, cantidad: cantidad));
    }
    _estado = EstadoVenta.listo;
    _notificar();
    return true;
  }

  bool quitar(int productoId) {
    final antes = _lineas.length;
    _quitar(productoId);
    if (_lineas.length == antes) return false;
    if (_lineas.isEmpty) _estado = EstadoVenta.vacio;
    _notificar();
    return true;
  }

  void _quitar(int productoId) {
    _lineas.removeWhere((linea) => linea.producto.productoId == productoId);
  }

  bool cambiarCantidad(int productoId, num cantidad) {
    final linea = _buscar(productoId);
    if (linea == null) return false;
    final tope = linea.producto.cantidadActual;
    final nueva = redondearCantidad(cantidad.clamp(0, tope).toDouble());
    if (nueva == linea.cantidad) return false;
    if (nueva <= 0) {
      _quitar(productoId);
    } else {
      _lineas[_lineas.indexOf(linea)] = linea.copyWith(cantidad: nueva);
    }
    _notificar();
    return true;
  }

  bool subirCantidad(int productoId) {
    final linea = _buscar(productoId);
    if (linea == null) return false;
    return cambiarCantidad(productoId, linea.cantidad + pasoDe(linea.producto));
  }

  bool bajarCantidad(int productoId) {
    final linea = _buscar(productoId);
    if (linea == null) return false;
    final paso = pasoDe(linea.producto);
    if (!puedeBajar(linea)) return false;
    return cambiarCantidad(productoId, linea.cantidad - paso);
  }

  bool puedeBajar(LineaCarrito linea) {
    final paso = pasoDe(linea.producto);
    return linea.producto.permiteDecimales
        ? linea.cantidad - paso > 0
        : linea.cantidad - paso >= 1;
  }

  void elegirFormaDePago(int? formaPagoId) {
    if (_formaPagoId == formaPagoId) return;
    _formaPagoId = formaPagoId;
    if (!esEfectivo) _recibido = 0;
    _notificar();
  }

  void elegirCliente(int? clienteId) {
    if (_clienteId == clienteId) return;
    _clienteId = clienteId;
    _notificar();
  }

  void cambiarDescuento(num valor) {
    final nuevo = CarritoController.redondearMoneda(
      valor.clamp(0, subtotal).toDouble(),
    );
    if (nuevo == _descuento) return;
    _descuento = nuevo;
    _notificar();
  }

  void cambiarRecibido(num valor) {
    if (valor < 0) return;
    final nuevo = CarritoController.redondearMoneda(valor.toDouble());
    if (nuevo == _recibido) return;
    _recibido = nuevo;
    _notificar();
  }

  void limpiar() {
    _lineas.clear();
    _clienteId = null;
    _formaPagoId = null;
    _descuento = 0;
    _recibido = 0;
    _error = null;
    _estado = EstadoVenta.vacio;
    _notificar();
  }

  void marcarError(String mensaje) {
    _error = mensaje;
    _estado = EstadoVenta.error;
    _notificar();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    _estado = _lineas.isEmpty ? EstadoVenta.vacio : EstadoVenta.listo;
    _notificar();
  }

  Future<VentaCreada?> registrarVenta(int empresaId) async {
    final repositorio = _repositorio;
    final formaPagoId = _formaPagoId;
    if (repositorio == null || formaPagoId == null) return null;
    if (_enviando) return null;

    _enviando = true;
    _error = null;
    _notificar();
    try {
      final venta = await repositorio.crearVenta(
        empresaId: empresaId,
        formaPagoId: formaPagoId,
        clienteId: _clienteId,
        descuento: _descuento,
        lineas: _lineas
            .map(
              (linea) => LineaVenta(
                productoId: linea.producto.productoId,
                descripcion: linea.producto.nombre,
                cantidad: linea.cantidad,
                precioUnitario: linea.producto.precioVenta,
              ),
            )
            .toList(),
      );
      _ventaRegistrada = venta;
      _enviando = false;
      _estado = EstadoVenta.listo;
      _notificar();
      return venta;
    } on ApiException catch (e) {
      _enviando = false;
      _error = e.mensaje;
      _estado = EstadoVenta.error;
      _notificar();
      return null;
    } catch (_) {
      _enviando = false;
      _error = 'No pudimos registrar la venta. Revisa las ventas antes de intentar de nuevo.';
      _estado = EstadoVenta.error;
      _notificar();
      return null;
    }
  }

  Future<bool> anularVenta() async {
    final repositorio = _repositorio;
    final venta = _ventaRegistrada;
    if (repositorio == null || venta == null) return false;

    _enviando = true;
    _error = null;
    _notificar();
    try {
      final anulada = await repositorio.anularVenta(venta.id);
      _ventaRegistrada = anulada;
      _enviando = false;
      _estado = EstadoVenta.listo;
      _notificar();
      return true;
    } on ApiException catch (e) {
      _enviando = false;
      _error = e.mensaje;
      _estado = EstadoVenta.error;
      _notificar();
      return false;
    } catch (_) {
      _enviando = false;
      _error = 'No pudimos anular la venta.';
      _estado = EstadoVenta.error;
      _notificar();
      return false;
    }
  }

  void nuevaVenta() {
    _ventaRegistrada = null;
    limpiar();
  }

  LineaCarrito? _buscar(int productoId) {
    for (final linea in _lineas) {
      if (linea.producto.productoId == productoId) return linea;
    }
    return null;
  }

  bool _liberado = false;

  void _notificar() {
    if (!_liberado) notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }

  static double pasoDe(ProductoInventario producto) =>
      producto.permiteDecimales ? _pasoDecimal : 1;

  static bool cantidadValida(num cantidad, ProductoInventario producto) =>
      producto.permiteDecimales ? cantidad > 0 : cantidad >= 1;

  static double redondearCantidad(double cantidad) {
    final factor = math.pow(10, _maxDecimales).toDouble();
    return (cantidad * factor).round() / factor;
  }

  static double redondearMoneda(double valor) {
    return (valor * 100).roundToDouble() / 100;
  }
}
