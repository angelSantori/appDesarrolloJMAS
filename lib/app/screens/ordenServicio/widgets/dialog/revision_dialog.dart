import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_lista_desplegable.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class RevisionDialog extends StatefulWidget {
  final OrdenServicio ordenServicio;
  final String idUser;
  final VoidCallback onSuccess;

  const RevisionDialog({
    super.key,
    required this.ordenServicio,
    required this.idUser,
    required this.onSuccess,
  });

  @override
  State<RevisionDialog> createState() => _RevisionDialogState();
}

class _RevisionDialogState extends State<RevisionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  final EvaluacionOrdenServicioController _evaluacionOSController =
      EvaluacionOrdenServicioController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();

  String? _estadoSeleccionado = 'Cerrar';
  bool _isSubmitting = false;

  final List<String> _opcionesEstado = [
    'Cerrar',
    'Devolver',
    'Aprobar Material',
  ];

  String _getNuevoEstado(String estadoSeleccionado) {
    switch (estadoSeleccionado) {
      case 'Cerrar':
        return 'Cerrada';
      case 'Devolver':
        return 'Devuelta';
      case 'Aprobar Material':
        return 'Requiere Material';
      default:
        return 'Cerrada';
    }
  }

  Future<void> _enviarRevision() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        // Actualizar estado de la orden de trabajo
        final nuevoEstado = _getNuevoEstado(_estadoSeleccionado!);
        final ordenActualizada = widget.ordenServicio.copyWith(
          estadoOS: nuevoEstado,
        );

        // Crear objeto de evaluación/revisión
        final evaluacion = EvaluacionOS(
          idEvaluacionOrdenServicio: 0,
          fechaEOS: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          comentariosEOS: _comentarioController.text,
          estadoEnviadoEOS: _estadoSeleccionado,
          idUser: int.tryParse(widget.idUser),
          idOrdenServicio: widget.ordenServicio.idOrdenServicio,
        );

        // Enviar cambios al servidor
        final successEvaluacion = await _evaluacionOSController.addEvOS(
          evaluacion,
        );
        final successOrden = await _ordenServicioController.editOrdenServicio(
          ordenActualizada,
        );

        if (successEvaluacion && successOrden) {
          Navigator.pop(context);
          showOk(context, 'Revisión enviada con éxito');
          widget.onSuccess();
        } else {
          showError(context, 'Error al enviar revisión');
        }
      } catch (e) {
        showError(context, 'Error: ${e.toString()}');
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Revisar Orden de Trabajo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                ),
              Row(
                children: [
                  Expanded(
                    child: CustomListaDesplegable(
                      value: _estadoSeleccionado,
                      labelText: 'Estado',
                      items: _opcionesEstado,
                      onChanged: (value) {
                        setState(() {
                          _estadoSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleccione un estado';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextFielTexto(
                controller: _comentarioController,
                labelText: 'Comentarios',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deje un comentario';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade800,
          ),
          onPressed: _isSubmitting ? null : _enviarRevision,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                  : const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ],
    );
  }
}
