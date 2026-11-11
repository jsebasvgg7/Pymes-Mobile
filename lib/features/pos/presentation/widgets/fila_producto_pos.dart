import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/cantidad.dart';
import '../../../../core/format/moneda.dart';
import '../../../../core/productos/producto_inventario.dart';

class FilaProductoPos extends StatelessWidget {
  const FilaProductoPos({
    super.key,
    required this.producto,
    required this.seleccionado,
    required this.alSeleccionar,
    required this.simbolo,
    required this.decimales,
  });

  final ProductoInventario producto;
  final bool seleccionado;
  final VoidCallback alSeleccionar;
  final String simbolo;
  final int decimales;

  @override
  Widget build(BuildContext context) {
    final agotado = producto.agotado;
    final colorEstado = switch (producto.estado) {
      EstadoStock.disponible => positivo,
      EstadoStock.bajo => atencion,
      EstadoStock.agotado => negativo,
    };
    final etiquetaEstado = switch (producto.estado) {
      EstadoStock.disponible => 'Disponible',
      EstadoStock.bajo => 'Stock bajo',
      EstadoStock.agotado => 'Agotado',
    };

    return Semantics(
      button: true,
      selected: seleccionado,
      enabled: !agotado,
      label: '${producto.nombre}, $etiquetaEstado',
      child: GestureDetector(
        onTap: agotado ? null : alSeleccionar,
        child: Opacity(
          opacity: agotado ? 0.5 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: papel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: linea, width: 1),
            ),
            child: Row(
              children: [
                _CirculoSeleccion(activo: seleccionado),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Stock: ${_cantidad(producto)} ${abreviarUnidad(producto.unidadMedida, producto.cantidadActual)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: textoSecundario,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Estado: $etiquetaEstado',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorEstado,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatearMonedaConfigurada(
                    producto.precioVenta,
                    simbolo: simbolo,
                    decimales: decimales,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _cantidad(ProductoInventario producto) {
  final valor = producto.cantidadActual;
  if (!producto.permiteDecimales) return valor.round().toString();
  return formatearCantidad(valor, decimales: true);
}

class _CirculoSeleccion extends StatelessWidget {
  const _CirculoSeleccion({required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activo ? tintaPrincipal : Colors.transparent,
          border: Border.all(
            color: activo ? tintaPrincipal : linea,
            width: 1.5,
          ),
        ),
        child: activo
            ? const HugeIcon(
                icon: HugeIcons.strokeRoundedCheck,
                color: papel,
                size: 14,
              )
            : null,
      ),
    );
  }
}
