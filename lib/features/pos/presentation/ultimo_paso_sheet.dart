import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/format/moneda.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/ajustes_venta.dart';
import 'carrito_controller.dart';
import 'factura_dialog.dart';

Future<void> mostrarUltimoPaso(
  BuildContext context,
  CarritoController carrito,
) {
  return mostrarHojaInferior(
    context: context,
    builder: (hoja) => _UltimoPaso(hoja: hoja, carrito: carrito),
  );
}

Future<void> mostrarHojaInferior({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: papel,
    elevation: 0,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: builder,
  );
}

class _UltimoPaso extends StatefulWidget {
  const _UltimoPaso({required this.hoja, required this.carrito});

  final BuildContext hoja;
  final CarritoController carrito;

  @override
  State<_UltimoPaso> createState() => _UltimoPasoState();
}

class _UltimoPasoState extends State<_UltimoPaso> {
  late final TextEditingController _descuento = TextEditingController(
    text: widget.carrito.descuento > 0
        ? widget.carrito.descuento.round().toString()
        : '',
  );
  late final TextEditingController _recibido = TextEditingController(
    text: widget.carrito.recibido > 0
        ? widget.carrito.recibido.round().toString()
        : '',
  );

  CarritoController get carrito => widget.carrito;

  AjustesVenta get ajustes => carrito.ajustes;

  String get _simbolo => ajustes.simboloMoneda;

  int get _decimales => decimalesDeMoneda(ajustes.moneda);

  String _moneda(num valor) => formatearMonedaConfigurada(
    valor,
    simbolo: _simbolo,
    decimales: _decimales,
  );

  @override
  void initState() {
    super.initState();
    carrito.addListener(_alCambiar);
  }

  @override
  void dispose() {
    carrito.removeListener(_alCambiar);
    _descuento.dispose();
    _recibido.dispose();
    super.dispose();
  }

  void _alCambiar() {
    if (mounted) setState(() {});
  }

  void _aplicarDescuento(String texto) {
    final limpio = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) {
      carrito.cambiarDescuento(0);
      return;
    }
    final valor = double.parse(limpio);
    carrito.cambiarDescuento(valor);
    if (carrito.descuento != valor) {
      _descuento.text = carrito.descuento.round().toString();
    }
  }

  void _aplicarRecibido(String texto) {
    final limpio = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) {
      carrito.cambiarRecibido(0);
      return;
    }
    carrito.cambiarRecibido(double.parse(limpio));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Último paso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _Fila(etiqueta: 'Subtotal', valor: _moneda(carrito.subtotal)),
          const SizedBox(height: 12),
          _Fila(
            etiqueta: 'Descuento',
            control: _CampoMoneda(
              controller: _descuento,
              simbolo: _simbolo,
              decimales: _decimales,
              alCambiar: _aplicarDescuento,
            ),
          ),
          const SizedBox(height: 12),
          _Fila(
            etiqueta: 'Cliente',
            control: _Selector(
              texto: _nombreCliente(),
              opciones: widget.carrito.clientes
                  .map((c) => (valor: c.id, texto: c.nombre))
                  .toList(),
              alElegir: (valor) => carrito.elegirCliente(valor),
            ),
          ),
          const SizedBox(height: 12),
          _Fila(
            etiqueta: 'Método de pago',
            control: _Selector(
              texto: _nombreFormaPago(),
              opciones: widget.carrito.formasDePago
                  .map((f) => (valor: f.id, texto: f.nombre))
                  .toList(),
              alElegir: (valor) => carrito.elegirFormaDePago(valor),
            ),
          ),
          if (carrito.esEfectivo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: superficie,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _Fila(
                    etiqueta: 'Recibido',
                    control: _CampoMoneda(
                      controller: _recibido,
                      simbolo: _simbolo,
                      decimales: _decimales,
                      alCambiar: _aplicarRecibido,
                      fondo: papel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Fila(
                    etiqueta: 'Vuelto',
                    valor: _moneda(carrito.vuelto > 0 ? carrito.vuelto : 0),
                    colorValor: carrito.vuelto > 0 ? positivo : textoSecundario,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Divider(height: 1, color: linea),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                _moneda(carrito.total),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (carrito.faltaEfectivo) ...[
            const SizedBox(height: 10),
            Text(
              'Faltan ${_moneda(carrito.total - carrito.recibido)}',
              style: const TextStyle(fontSize: 13, color: negativo),
            ),
          ],
          if (carrito.faltaCliente) ...[
            const SizedBox(height: 10),
            const Text(
              'Elige un cliente para continuar.',
              style: TextStyle(fontSize: 13, color: negativo),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: carrito.puedeFinalizar && !carrito.enviando
                ? () => _finalizar(context)
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: carrito.enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: papel,
                    ),
                  )
                : const Text(
                    'Finalizar venta',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: tintaPrincipal,
              side: const BorderSide(color: linea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizar(BuildContext context) async {
    final empresaId = context.read<AuthController>().usuario?.empresaId;
    if (empresaId == null) return;

    final venta = await carrito.registrarVenta(empresaId);
    if (!context.mounted) return;
    if (venta == null) {
      _mostrarError(carrito.error);
      return;
    }
    Navigator.of(context).pop();
    if (context.mounted) await mostrarFactura(context, venta, carrito);
  }

  void _mostrarError(String? mensaje) {
    if (mensaje == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: tintaPrincipal,
      ),
    );
  }

  String _nombreCliente() {
    final id = carrito.clienteId;
    if (id == null) return 'Sin cliente';
    for (final cliente in carrito.clientes) {
      if (cliente.id == id) return cliente.nombre;
    }
    return 'Sin cliente';
  }

  String _nombreFormaPago() {
    final id = carrito.formaPagoId;
    if (id == null) return 'Efectivo';
    for (final forma in carrito.formasDePago) {
      if (forma.id == id) return forma.nombre;
    }
    return 'Efectivo';
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.etiqueta,
    this.valor,
    this.control,
    this.colorValor,
  });

  final String etiqueta;
  final String? valor;
  final Widget? control;
  final Color? colorValor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: textoSecundario),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child:
                control ??
                Text(
                  valor ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorValor ?? tintaPrincipal,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class _CampoMoneda extends StatelessWidget {
  const _CampoMoneda({
    required this.controller,
    required this.simbolo,
    required this.decimales,
    required this.alCambiar,
    this.fondo = superficie,
  });

  final TextEditingController controller;
  final String simbolo;
  final int decimales;
  final ValueChanged<String> alCambiar;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            simbolo,
            style: const TextStyle(fontSize: 15, color: textoSecundario),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: alCambiar,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              cursorColor: tintaPrincipal,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  const _Selector({
    required this.texto,
    required this.opciones,
    required this.alElegir,
  });

  final String texto;
  final List<({int valor, String texto})> opciones;
  final ValueChanged<int?> alElegir;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: linea),
      ),
      child: PopupMenuButton<int>(
        onSelected: alElegir,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        itemBuilder: (context) => [
          for (final opcion in opciones)
            PopupMenuItem<int>(value: opcion.valor, child: Text(opcion.texto)),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedChevronDown,
              color: textoSecundario,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
