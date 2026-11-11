import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/cantidad.dart';
import '../../../../core/productos/producto_inventario.dart';
import '../../../../core/format/moneda.dart';
import '../carrito_controller.dart';

class TarjetaLineaCarrito extends StatelessWidget {
  const TarjetaLineaCarrito({
    super.key,
    required this.item,
    required this.carrito,
  });

  final LineaCarrito item;
  final CarritoController carrito;

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    final decimales = producto.permiteDecimales;
    final simbolo = carrito.ajustes.simboloMoneda;
    final decimalesMoneda = decimalesDeMoneda(carrito.ajustes.moneda);
    String moneda(num valor) => formatearMonedaConfigurada(
      valor,
      simbolo: simbolo,
      decimales: decimalesMoneda,
    );
    final stock =
        'Stock: ${formatearCantidad(producto.cantidadActual, decimales: decimales)} ${abreviarUnidad(producto.unidadMedida, producto.cantidadActual)}';
    final detalle = item.cantidad == 1
        ? stock
        : '$stock · ${moneda(producto.precioVenta)} / ${abreviarUnidad(producto.unidadMedida, 1)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: linea, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 96),
        child: Row(
          children: [
            _IconoProducto(icono: carrito.iconoDe(producto)),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 8, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          moneda(item.totalLinea),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          detalle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textoSecundario,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ControlCantidad(item: item, carrito: carrito),
                        const Spacer(),
                        _BotonQuitar(
                          nombre: producto.nombre,
                          alTocar: () => carrito.quitar(producto.productoId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconoProducto extends StatelessWidget {
  const _IconoProducto({required this.icono});

  final List<List<dynamic>> icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: linea, width: 1),
      ),
      child: HugeIcon(icon: icono, color: tintaPrincipal, size: 32),
    );
  }
}

class _BotonQuitar extends StatelessWidget {
  const _BotonQuitar({required this.nombre, required this.alTocar});

  final String nombre;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Quitar $nombre',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: alTocar,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: 36,
          height: 32,
          child: Align(
            alignment: Alignment.centerRight,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: negativo,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlCantidad extends StatelessWidget {
  const _ControlCantidad({required this.item, required this.carrito});

  final LineaCarrito item;
  final CarritoController carrito;

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Boton(
          etiqueta: 'Restar',
          icono: HugeIcons.strokeRoundedMinus,
          habilitado: carrito.puedeBajar(item),
          alTocar: () => carrito.bajarCantidad(producto.productoId),
        ),
        _CantidadEditable(item: item, carrito: carrito),
        _Boton(
          etiqueta: 'Sumar',
          icono: HugeIcons.strokeRoundedPlus,
          habilitado: carrito.puedeSubir(item),
          alTocar: () => carrito.subirCantidad(producto.productoId),
        ),
      ],
    );
  }
}

class _CantidadEditable extends StatelessWidget {
  const _CantidadEditable({required this.item, required this.carrito});

  final LineaCarrito item;
  final CarritoController carrito;

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    final decimales = producto.permiteDecimales;
    final cantidad = formatearCantidad(item.cantidad, decimales: decimales);

    return Semantics(
      button: true,
      label: 'Editar cantidad de ${producto.nombre}',
      value: cantidad,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _editar(context),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: decimales ? 58 : 46,
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cantidad,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedPencil,
                color: textoSecundario,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context) async {
    final cantidad = await showDialog<num>(
      context: context,
      builder: (_) =>
          _DialogoCantidad(producto: item.producto, cantidad: item.cantidad),
    );
    if (cantidad != null) {
      carrito.cambiarCantidad(item.producto.productoId, cantidad);
    }
  }
}

class _DialogoCantidad extends StatefulWidget {
  const _DialogoCantidad({required this.producto, required this.cantidad});

  final ProductoInventario producto;
  final num cantidad;

  @override
  State<_DialogoCantidad> createState() => _DialogoCantidadState();
}

class _DialogoCantidadState extends State<_DialogoCantidad> {
  late final TextEditingController _campo = TextEditingController(
    text: _textoInicial,
  );
  final FocusNode _foco = FocusNode();
  String? _error;

  bool get _decimales => widget.producto.permiteDecimales;

  String get _unidad => abreviarUnidad(
    widget.producto.unidadMedida,
    widget.producto.cantidadActual,
  );

  String get _maximo =>
      formatearCantidad(widget.producto.cantidadActual, decimales: _decimales);

  String get _textoInicial {
    if (!_decimales) return widget.cantidad.round().toString();
    final texto = widget.cantidad.toString();
    final limpio = texto.endsWith('.0')
        ? texto.substring(0, texto.length - 2)
        : texto;
    return limpio.replaceAll('.', ',');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _foco.requestFocus();
      _campo.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _campo.text.length,
      );
    });
  }

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _aplicar() {
    final texto = _campo.text.trim().replaceAll(',', '.');
    final valor = double.tryParse(texto);
    if (valor == null || valor <= 0) {
      setState(() => _error = 'Escribe una cantidad mayor que cero.');
      return;
    }
    if (!_decimales && valor != valor.roundToDouble()) {
      setState(() => _error = 'Este producto se vende por unidades completas.');
      return;
    }
    final redondeada = CarritoController.redondearCantidad(valor);
    if (redondeada <= 0) {
      setState(() => _error = 'La cantidad mínima es 0,001.');
      return;
    }
    if (redondeada > widget.producto.cantidadActual) {
      setState(() => _error = 'El máximo disponible es $_maximo $_unidad.');
      return;
    }
    Navigator.of(context).pop(redondeada);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: papel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Cantidad',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.producto.nombre,
            style: const TextStyle(fontSize: 14, color: textoSecundario),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _campo,
            focusNode: _foco,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(decimal: _decimales),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              _decimales
                  ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                  : FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            onChanged: (_) {
              if (_error == null) return;
              setState(() => _error = null);
            },
            onSubmitted: (_) => _aplicar(),
            decoration: InputDecoration(
              suffixText: _unidad,
              helperText: 'Máximo: $_maximo $_unidad',
              errorText: _error,
              errorMaxLines: 2,
              filled: true,
              fillColor: superficie,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: linea),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: linea),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: tintaPrincipal, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _aplicar, child: const Text('Aplicar')),
      ],
    );
  }
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.etiqueta,
    required this.icono,
    required this.habilitado,
    required this.alTocar,
  });

  final String etiqueta;
  final List<List<dynamic>> icono;
  final bool habilitado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: habilitado,
      label: etiqueta,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: habilitado ? alTocar : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: habilitado ? tintaPrincipal : superficie,
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: icono,
            color: habilitado ? papel : textoSecundario,
            size: 14,
          ),
        ),
      ),
    );
  }
}
