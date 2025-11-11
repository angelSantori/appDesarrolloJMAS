import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:flutter/material.dart';

//  Sección Estatus
Widget buildStatusSection(OrdenServicio ordenServicio) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de la Orden de Servicio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(
                    ordenServicio.prioridadOS ?? 'No disponible',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  backgroundColor: getPrioridadColor(ordenServicio.prioridadOS),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                const SizedBox(width: 20),
                Chip(
                  label: Text(
                    ordenServicio.estadoOS ?? 'No disponible',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  backgroundColor: getEstadoColor(ordenServicio.estadoOS),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                color:
                    ordenServicio.materialOS == null
                        ? Colors.grey.shade600
                        : ordenServicio.materialOS == true
                        ? Colors.orange
                        : Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                ordenServicio.materialOS == null
                    ? 'S/A'
                    : ordenServicio.materialOS == true
                    ? 'Requiere material'
                    : 'No requiere material',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      ordenServicio.materialOS == null
                          ? Colors.grey.shade600
                          : ordenServicio.materialOS == true
                          ? Colors.orange
                          : Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
