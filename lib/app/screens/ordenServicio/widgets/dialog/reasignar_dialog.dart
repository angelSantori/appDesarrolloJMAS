import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/trabajo_realizado_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/customListaDesplegableTipo.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ReasignacionDialog extends StatefulWidget {
  final OrdenServicio ordenServicio;
  final String idUser;
  final List<Users> allUsers;
  final Padron padron;
  final TrabajoRealizadoController trabajoRealizadoController;
  final String? folioTR;
  final TipoProblema problema;
  final VoidCallback onSuccess;

  const ReasignacionDialog({
    super.key,
    required this.ordenServicio,
    required this.idUser,
    required this.allUsers,
    required this.trabajoRealizadoController,
    required this.folioTR,
    required this.onSuccess,
    required this.padron,
    required this.problema,
  });

  @override
  State<ReasignacionDialog> createState() => _ReasignacionDialogState();
}

class _ReasignacionDialogState extends State<ReasignacionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  final EvaluacionOrdenServicioController _evaluacionOSController =
      EvaluacionOrdenServicioController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();

  Users? _empleadoSeleccionado;
  bool _isSubmitting = false;

  List<Users> get _empleados {
    return widget.allUsers
        .where((user) => user.user_Rol == "Empleado")
        .toList();
  }

  Future<bool> _crearTrabajo(Users empleado) async {
    try {
      final trabajo = TrabajoRealizado(
        idTrabajoRealizado: 0,
        folioTR: widget.folioTR,
        idUserTR: empleado.id_User,
        idOrdenServicio: widget.ordenServicio.idOrdenServicio,
        folioOS: widget.ordenServicio.folioOS,
        padronNombre: widget.padron.padronNombre,
        padronDireccion: widget.padron.padronDireccion,
        problemaNombre: widget.problema.nombreTP,
      );

      return await widget.trabajoRealizadoController.addTrabajoRealizado(
        trabajo,
      );
    } catch (e) {
      print('Error al crear trabajo: $e');
      return false;
    }
  }

  Future<void> _reasignarTarea() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        // Actualizar estado a "Aprobada - A"
        final ordenActualizada = widget.ordenServicio.copyWith(
          estadoOS: 'Aprobada - A',
        );

        // Crear nueva evaluación para registrar la reasignación
        final evaluacion = EvaluacionOS(
          idEvaluacionOrdenServicio: 0,
          fechaEOS: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          comentariosEOS: _comentarioController.text,
          estadoEnviadoEOS: 'Reasignada',
          idUser: int.tryParse(widget.idUser),
          idOrdenServicio: widget.ordenServicio.idOrdenServicio,
        );

        // Si no requiere material, crear trabajo realizado con el nuevo empleado
        bool successTrabajo = true;
        if (widget.ordenServicio.materialOS != true &&
            _empleadoSeleccionado != null) {
          successTrabajo = await _crearTrabajo(_empleadoSeleccionado!);
        }

        // Enviar cambios al servidor
        final successEvaluacion = await _evaluacionOSController.addEvOS(
          evaluacion,
        );
        final successOrden = await _ordenServicioController.editOrdenServicio(
          ordenActualizada,
        );

        if (successEvaluacion && successOrden && successTrabajo) {
          Navigator.pop(context);
          showOk(context, 'Tarea reasignada con éxito');
          widget.onSuccess();
        } else {
          showError(context, 'Error al reasignar tarea');
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
      title: const Text('Reasignar Tarea'),
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
                    child: CustomListaDesplegableTipo<Users>(
                      value: _empleadoSeleccionado,
                      labelText: 'Seleccionar Empleado',
                      items: _empleados,
                      onChanged: (Users? newValue) {
                        setState(() {
                          _empleadoSeleccionado = newValue;
                        });
                      },
                      itemLabelBuilder:
                          (empleado) =>
                              '${empleado.user_Name ?? 'Sin nombre'} - (${empleado.id_User})',
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un empleado';
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
                    return 'Ingrese un comentario';
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
            backgroundColor: Colors.orange.shade800,
          ),
          onPressed: _isSubmitting ? null : _reasignarTarea,
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
                    'Reasignar',
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ],
    );
  }
}
