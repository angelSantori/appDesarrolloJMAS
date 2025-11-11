// card_custom.dart (versión modificada)
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:flutter/material.dart';

class CardCustom extends StatelessWidget {
  final String folio;
  final String prioridad;
  final String estado;
  final String fecha;
  final String medio;
  final String problema;
  final String padronInfo;
  final String padronDireccion;
  final String direccion;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const CardCustom({
    super.key,
    required this.folio,
    required this.prioridad,
    required this.estado,
    required this.fecha,
    required this.medio,
    required this.problema,
    required this.padronInfo,
    required this.direccion,
    required this.onTap,
    this.width,
    this.height,
    required this.padronDireccion,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.45,
        height: height ?? 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black45,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Encabezado con color azul
            Container(
              width: double.infinity,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF2712E4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Color.fromARGB(221, 44, 44, 44),
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                child: Column(
                  children: [
                    Text(
                      folio,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black87,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildChip(prioridad, getPrioridadColor(prioridad)),
                          const SizedBox(width: 30),
                          _buildChip(estado, getEstadoColor(estado)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido de la tarjeta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información
                    _buildInfoText('Fecha: $fecha', context),
                    _buildInfoText('Medio: $medio', context),
                    _buildInfoText('Problema: $problema', context),
                    _buildInfoText('Padrón: $padronInfo', context),
                    _buildInfoText('Dirección: $padronDireccion', context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevation: 15,
        backgroundColor: color,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildInfoText(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
