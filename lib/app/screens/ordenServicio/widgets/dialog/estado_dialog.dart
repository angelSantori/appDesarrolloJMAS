import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_lista_desplegable.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EstadoDialog extends StatefulWidget {
  final OrdenServicio ordenServicio;
  final String idUser;
  final VoidCallback onSuccess;

  const EstadoDialog({
    super.key,
    required this.ordenServicio,
    required this.idUser,
    required this.onSuccess,
  });

  @override
  State<EstadoDialog> createState() => _EstadoDialogState();
}

class _EstadoDialogState extends State<EstadoDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  final EvaluacionOrdenServicioController _evaluacionOrdenServicioController =
      EvaluacionOrdenServicioController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();

  String? _estadoSeleccionado;
  bool _isSumitting = false;

  @override
  void initState() {
    super.initState();
    _estadoSeleccionado =
        widget.ordenServicio.estadoOS == 'Completo' ? 'Completo' : 'Incompleto';
  }

  Future<void> _cambiarEstado() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSumitting = true);

      try {
        //  Actualizar estado de la orden de servicio
        final ordenActualizada = widget.ordenServicio.copyWith(
          estadoOS: _estadoSeleccionado,
        );

        //  Crear objeto de evaluación para registrar el cambio
        final evaluacion = EvaluacionOS(
          idEvaluacionOrdenServicio: 0,
          fechaEOS: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
          comentariosEOS:
              _comentarioController.text.isNotEmpty
                  ? _comentarioController.text
                  : 'Estado cambiado a: $_estadoSeleccionado',
          estadoEnviadoEOS: 'Cambio de estado',
          idUser: int.tryParse(widget.idUser),
          idOrdenServicio: widget.ordenServicio.idOrdenServicio,
        );

        //  Enviar cambios al servidor
        final successEvaluacion = await _evaluacionOrdenServicioController
            .addEvOS(evaluacion);
        final successOrden = await _ordenServicioController.editOrdenServicio(
          ordenActualizada,
        );

        if (successEvaluacion && successOrden) {
          Navigator.pop(context);
          showOk(context, 'Estado cambiado a $_estadoSeleccionado');
          widget.onSuccess();
        } else {
          showError(context, 'Error al cambiar el estado (IFE)');
        }
      } catch (e) {
        showError(context, 'Error al cambiar el estado (TRY)');
        print('Error: $e');
      } finally {
        setState(() => _isSumitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSumitting) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: CustomListaDesplegable(
                      value: _estadoSeleccionado,
                      labelText: 'Estado',
                      items: const ['Completado', 'Incompleto'],
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
                labelText: 'Comentario (opcional)',
              ),
              const SizedBox(height: 8),

              Text(
                'Actual: ${widget.ordenServicio.estadoOS ?? 'N/A'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSumitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade800,
          ),
          onPressed: _isSumitting ? null : _cambiarEstado,
          child:
              _isSumitting
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
