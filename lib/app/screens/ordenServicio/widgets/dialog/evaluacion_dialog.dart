import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/trabajo_realizado_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_lista_desplegable.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EvaluacionDialog extends StatefulWidget {
  final OrdenServicio ordenServicio;
  final String idUser;
  final List<Users> allUsers;
  final TrabajoRealizadoController trabajoRealizadoController;
  final String? folioTR;
  final Padron padron;
  final TipoProblema problema;
  final VoidCallback onSuccess;

  const EvaluacionDialog({
    super.key,
    required this.ordenServicio,
    required this.idUser,
    required this.allUsers,
    required this.trabajoRealizadoController,
    required this.folioTR,
    required this.padron,
    required this.problema,
    required this.onSuccess,
  });

  @override
  State<EvaluacionDialog> createState() => _EvaluacionDialogState();
}

class _EvaluacionDialogState extends State<EvaluacionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _usersSearchController = TextEditingController();
  final EvaluacionOrdenServicioController _evaluacionOSController =
      EvaluacionOrdenServicioController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();

  String? _estadoSeleccionado = 'Aprobar';
  Users? _selectedEmpleado;
  bool _isSubmitting = false;
  bool _showAsignarUsuario = true;

  List<Users> get _empleados {
    return widget.allUsers
        .where((user) => user.user_Rol == "Empleado")
        .toList();
  }

  String _getNuevoEstado(String estadoSeleccionado) {
    switch (estadoSeleccionado) {
      case 'Aprobar':
        return 'Aprobada - A';
      case 'Rechazar':
        return 'Rechazada';
      case 'Cancelar':
        return 'Cancelada';
      default:
        return 'Aprobada - A';
    }
  }

  Future<bool> _crearTrabajo() async {
    if (_selectedEmpleado == null) return false;

    try {
      final trabajo = TrabajoRealizado(
        idTrabajoRealizado: 0,
        folioTR: widget.folioTR,
        idUserTR: _selectedEmpleado!.id_User,
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

  Future<void> _enviarEvaluacion() async {
    if (_formKey.currentState!.validate()) {
      // Validar que si se aprueba y no requiere material, se haya seleccionado un empleado
      if (_estadoSeleccionado == 'Aprobar' &&
          widget.ordenServicio.materialOS != true &&
          _selectedEmpleado == null) {
        showError(
          context,
          'Debe seleccionar un empleado para asignar la tarea',
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        // Actualizar estado de la orden de trabajo
        final nuevoEstado = _getNuevoEstado(_estadoSeleccionado!);
        final ordenActualizada = widget.ordenServicio.copyWith(
          estadoOS: nuevoEstado,
          idUserAsignado: _selectedEmpleado?.id_User,
        );

        // Crear objeto de evaluación
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

        // Si se aprobó y no requiere material, crear trabajo realizado
        bool successTrabajo = true;
        if (_estadoSeleccionado == 'Aprobar' &&
            widget.ordenServicio.materialOS != true &&
            _selectedEmpleado != null) {
          successTrabajo = await _crearTrabajo();
        }

        if (successEvaluacion && successOrden && successTrabajo) {
          Navigator.pop(context);
          showOk(context, 'Evaluación enviada con éxito');
          widget.onSuccess();
        } else {
          showError(context, 'Error al enviar evaluación');
        }
      } catch (e) {
        showError(context, 'Error: ${e.toString()}');
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _showAsignarUsuario = widget.ordenServicio.materialOS != true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar Orden de Trabajo'),
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
                      items: const ['Aprobar', 'Rechazar', 'Cancelar'],
                      onChanged: (value) {
                        setState(() {
                          _estadoSeleccionado = value;
                          _showAsignarUsuario =
                              widget.ordenServicio.materialOS != true &&
                              value == 'Aprobar';
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
              const SizedBox(height: 16),
              // Sección para asignar usuario (solo visible cuando corresponda)
              if (_showAsignarUsuario) ...[
                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<Users>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Users>.empty();
                          }
                          return _empleados.where((Users user) {
                            final userName =
                                user.user_Name?.toLowerCase() ?? '';
                            final userAccess =
                                user.user_Access?.toLowerCase() ?? '';
                            final query = textEditingValue.text.toLowerCase();

                            return userName.contains(query) ||
                                userAccess.contains(query) ||
                                user.id_User.toString().contains(query);
                          });
                        },
                        onSelected: (Users selection) {
                          setState(() {
                            _selectedEmpleado = selection;
                            _usersSearchController.text =
                                '${selection.user_Name} (${selection.user_Access})';
                          });
                        },
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          // Sincronizar el controlador
                          if (_usersSearchController.text !=
                              textEditingController.text) {
                            textEditingController.text =
                                _usersSearchController.text;
                          }

                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Buscar usuario',
                              border: const OutlineInputBorder(),
                              suffixIcon:
                                  textEditingController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          textEditingController.clear();
                                          _usersSearchController.clear();
                                          setState(() {
                                            _selectedEmpleado = null;
                                          });
                                        },
                                      )
                                      : null,
                            ),
                            onChanged: (value) {
                              _usersSearchController.text = value;
                              if (value.isEmpty) {
                                setState(() {
                                  _selectedEmpleado = null;
                                });
                              }
                            },
                          );
                        },
                        optionsViewBuilder: (
                          BuildContext context,
                          AutocompleteOnSelected<Users> onSelected,
                          Iterable<Users> options,
                        ) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    final Users option = options.elementAt(
                                      index,
                                    );
                                    return ListTile(
                                      title: Text(
                                        '${option.user_Name} (${option.user_Access})',
                                      ),
                                      subtitle: Text(
                                        'ID: ${option.id_User} - ${option.user_Contacto ?? "Sin contacto"}',
                                      ),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
          onPressed: _isSubmitting ? null : _enviarEvaluacion,
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
