import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/cantidad.dart';
import '../../../../core/format/moneda.dart';
import '../../../../core/productos/producto_inventario.dart';
import 'insignia_stock.dart';

class TarjetaProducto extends StatelessWidget {
  const TarjetaProducto({super.key, required this.item});

  final ProductoInventario item;

  @override
  Widget build(BuildContext context) {
    final decimales = item.permiteDecimales;
    final cantidad = formatearCantidad(
      item.cantidadActual,
      decimales: decimales,
    );
    final unidad = abreviarUnidad(item.unidadMedida, item.cantidadActual);
    final minimo = formatearCantidad(item.stockMinimo, decimales: decimales);
    final detalle = item.sku.isEmpty
        ? item.categoria
        : '${item.sku} · ${item.categoria}';

    return Semantics(
      container: true,
      excludeSemantics: true,
      label:
          '${item.nombre}, $cantidad $unidad, ${etiquetaEstadoStock(item.estado)}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: papel,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: tintaPrincipal.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: cantidad,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' $unidad',
                            style: const TextStyle(
                              fontSize: 12,
                              color: textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatearMoneda(item.precioVenta),
                      style: const TextStyle(
                        fontSize: 12,
                        color: textoSecundario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InsigniaStock(estado: item.estado),
                const Spacer(),
                Text(
                  'Mínimo $minimo',
                  style: const TextStyle(fontSize: 12, color: textoSecundario),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
