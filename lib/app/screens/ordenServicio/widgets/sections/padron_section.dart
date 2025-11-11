import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:flutter/material.dart';

//  Sección Padrón
Widget buildPadronSection(Padron? padron) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Padrón',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 10),
          if (padron != null) ...[
            buildInfoRow('ID', padron.idPadron?.toString()),
            buildInfoRow('Nombre', padron.padronNombre),
            buildInfoRow('Dirección', padron.padronDireccion),
            //const SizedBox(height: 10),
          ],
        ],
      ),
    ),
  );
}