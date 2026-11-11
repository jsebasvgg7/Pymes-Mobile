import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../data/models/movimiento_caja.dart';
import 'caja_controller.dart';
import 'monto_caja.dart';
import 'widgets/campo_monto_caja.dart';
import 'widgets/selector_forma_pago.dart';

class MovimientoHoja extends StatefulWidget {
  const MovimientoHoja({super.key, required this.controlador});

  final CajaController controlador;

  @override
  State<MovimientoHoja> createState() => _MovimientoHojaState();
}

class _MovimientoHojaState extends State<MovimientoHoja> {
  TipoMovimientoCaja _tipo = TipoMovimientoCaja.ingreso;
  int? _formaPagoId;
  final _controladorMonto = TextEditingController();
  final _controladorDescripcion = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final formas = widget.controlador.formasPago;
    if (formas.isNotEmpty) {
      _formaPagoId = formas.first.id;
    }
  }

  @override
  void dispose() {
    _controladorMonto.dispose();
    _controladorDescripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final monto = montoDesdeTexto(_controladorMonto.text);
    if (monto == null || monto <= 0 || _formaPagoId == null || _enviando) {
      setState(() {
        _error = 'Ingresa un monto y una forma de pago válidos.';
      });
      return;
    }
    final descripcion = _controladorDescripcion.text.trim();
    if (descripcion.isEmpty) {
      setState(() {
        _error = 'Ingresa una descripción.';
      });
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    final exito = await widget.controlador.registrarMovimiento(
      tipo: _tipo,
      formaPagoId: _formaPagoId!,
      monto: monto,
      descripcion: descripcion,
      tipoReferencia: _tipo == TipoMovimientoCaja.egreso
          ? TipoReferenciaMovimientoCaja.gasto
          : TipoReferenciaMovimientoCaja.ajuste,
    );
    if (!mounted) return;
    if (exito) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _enviando = false;
      _error =
          widget.controlador.errorAccion ??
          'No se pudo registrar el movimiento.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final formas = widget.controlador.formasPago;
    final vistaInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: vistaInsets + const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD7D9DE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nuevo movimiento',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tintaPrincipal,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OpcionTipo(
                  texto: 'Ingreso',
                  seleccionado: _tipo == TipoMovimientoCaja.ingreso,
                  onTap: () =>
                      setState(() => _tipo = TipoMovimientoCaja.ingreso),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OpcionTipo(
                  texto: 'Egreso',
                  seleccionado: _tipo == TipoMovimientoCaja.egreso,
                  onTap: () =>
                      setState(() => _tipo = TipoMovimientoCaja.egreso),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CampoMontoCaja(
            controlador: _controladorMonto,
            etiqueta: 'Monto',
            autofoco: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'Forma de pago',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          SelectorFormaPago(
            formas: formas,
            seleccionadaId: _formaPagoId,
            alSeleccionar: (id) => setState(() => _formaPagoId = id),
          ),
          const SizedBox(height: 16),
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controladorDescripcion,
            maxLength: 80,
            decoration: InputDecoration(
              filled: true,
              fillColor: superficie,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: linea),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: linea),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: tintaPrincipal),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              counterText: '',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(fontSize: 13, color: negativo),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _enviando ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tintaPrincipal,
                    side: const BorderSide(color: linea),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _enviando ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: tintaPrincipal,
                    foregroundColor: papel,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: papel,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpcionTipo extends StatelessWidget {
  const _OpcionTipo({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? tintaPrincipal : superficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: seleccionado ? tintaPrincipal : linea),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: seleccionado ? papel : tintaPrincipal,
          ),
        ),
      ),
    );
  }
}

Future<void> mostrarNuevoMovimiento(
  BuildContext context,
  CajaController controlador,
) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!controlador.abierta) return;
  await controlador.cargarFormasPago();
  if (!context.mounted) return;
  final resultado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: papel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => MovimientoHoja(controlador: controlador),
  );
  if (resultado == true && context.mounted) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Movimiento registrado'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
