import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CancelacionDialog extends StatefulWidget {
  final OrdenServicio ordenServicio;
  final String idUser;
  final VoidCallback onSuccess;

  const CancelacionDialog({
    super.key,
    required this.ordenServicio,
    required this.idUser,
    required this.onSuccess,
  });

  @override
  State<CancelacionDialog> createState() => _CancelacionDialogState();
}

class _CancelacionDialogState extends State<CancelacionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  final EvaluacionOrdenServicioController _evaluacionOSController =
      EvaluacionOrdenServicioController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();

  bool _isSubmitting = false;

  Future<void> _cancelarOrden() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        // Actualizar estado a "Cancelada"
        final ordenActualizada = widget.ordenServicio.copyWith(
          estadoOS: 'Cancelada',
        );

        // Crear objeto de evaluación para la cancelación
        final evaluacion = EvaluacionOS(
          idEvaluacionOrdenServicio: 0,
          fechaEOS: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          comentariosEOS: _comentarioController.text,
          estadoEnviadoEOS: 'Cancelada',
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
          showOk(context, 'Orden cancelada con éxito');
          widget.onSuccess();
        } else {
          showError(context, 'Error al cancelar la orden');
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
      title: const Text('Cancelar Orden de Servicio'),
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
              const Text(
                '¿Está seguro de que desea cancelar esta orden de servicio?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextFielTexto(
                controller: _comentarioController,
                labelText: 'Motivo de la cancelación',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el motivo de la cancelación';
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
          child: const Text('No cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
          onPressed: _isSubmitting ? null : _cancelarOrden,
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
                    'Confirmar cancelación',
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ],
    );
  }
}
