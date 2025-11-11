import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:flutter/material.dart';


//  Sección Información General
Widget buildInfoCardInfoGeneral(
  List<TipoProblema> allTipoProblemas,
  OrdenServicio ordenServicio,
  List<Medios> allMedios,
) {
  // Obtener nombre del tipo de problema
  final tipoProblema = allTipoProblemas.firstWhere(
    (tp) => tp.idTipoProblema == ordenServicio.idTipoProblema,
    orElse: () => TipoProblema(),
  );

  // Obtener nombre del medio
  final medioSL = allMedios.firstWhere(
    (med) => med.idMedio == ordenServicio.idMedio,
    orElse: () => Medios(),
  );

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Datos Generales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          buildInfoRow('Folio', ordenServicio.folioOS),
          buildInfoRow('Fecha', formatDate(ordenServicio.fechaOS)),
          buildInfoRow(
            'Medio',
            '${medioSL.nombreMedio ?? 'Sin Nombre'} - (${medioSL.idMedio})',
          ),
          buildInfoRow(
            'Tipo de Problema',
            '${tipoProblema.nombreTP ?? 'Sin Nombre'} - (${tipoProblema.idTipoProblema})',
          ),
          buildInfoRow('Contacto', ordenServicio.contactoOS ?? 'Sin contacto'),
          buildInfoRow(
            'Comentaio',
            ordenServicio.comentarioOS ?? 'Sin comentario',
          ),
        ],
      ),
    ),
  );
}