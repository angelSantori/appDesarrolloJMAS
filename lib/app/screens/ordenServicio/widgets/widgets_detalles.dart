import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildRatingRow(String label, int? rating) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child:
              rating != null
                  ? buildStarRating(rating)
                  : const Text('No disponible', style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

Widget buildStarRating(int rating) {
  return Row(
    children: List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: const Color.fromARGB(255, 7, 85, 255),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
        size: 24,
      );
    }),
  );
}

Widget buildInfoRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'No disponible',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

// Agrega esta función en tu clase _DetailsOrdenServicioState
Color getEstadoTrabajoColor(String? estado) {
  if (estado == null) return Colors.grey;

  switch (estado.toLowerCase()) {
    case 'completado':
      return Colors.green;
    case 'pendiente':
      return Colors.orange;
    case 'falla':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// Prioridad Colores
Color getPrioridadColor(String? prioridad) {
  if (prioridad == null) return Colors.grey;
  switch (prioridad.toLowerCase()) {
    case 'baja':
      return Colors.blue;
    case 'media':
      return Colors.orange;
    case 'alta':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// Estado Colores
Color getEstadoColor(String? estado) {
  if (estado == null) return Colors.grey;
  switch (estado.toLowerCase()) {
    case 'pendiente':
      return Colors.orange;
    case 'requiere material':
      return Colors.green;
    case 'aprobada - a':
      return Colors.green.shade900;
    case 'completado':
      return Colors.green.shade900;
    case 'revisión':
      return Colors.purple;
    case 'devuelta':
      return Colors.red;
    case 'incompleto':
      return Colors.orange.shade700;
    case 'cerrada':
      return Colors.blue.shade900;
    case 'cancelada':
      return Colors.red.shade900;
    default:
      return Colors.grey;
  }
}

// Format Date
String formatDate(String? dateString) {
  if (dateString == null) return 'No disponible';

  final formats = [
    DateFormat('dd/MM/yyyy HH:mm:ss'),
    DateFormat('dd/MM/yyyy HH:mm'),
  ];

  for (final format in formats) {
    try {
      final date = format.parse(dateString);
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    } catch (e) {
      continue;
    }
  }

  return dateString; // Si ningún formato funcionó
}
