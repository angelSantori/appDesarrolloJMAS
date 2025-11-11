import 'package:desarrollo_jmas/app/configs/controllers/entrevista_padron_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_lista_desplegable.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntrevistaDialog extends StatefulWidget {
  final int idOrdenServicio;
  final String idUser;
  final VoidCallback onSuccess;

  const EntrevistaDialog({
    super.key,
    required this.idOrdenServicio,
    required this.idUser,
    required this.onSuccess,
  });

  @override
  State<EntrevistaDialog> createState() => _EntrevistaDialogState();
}

class _EntrevistaDialogState extends State<EntrevistaDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  final EntrevistaPadronController _entrevistaPadronController =
      EntrevistaPadronController();

  String? _calificacionSeleccionada;
  final List<String> _opcionesCalificacion = [
    'Muy bueno',
    'Bueno',
    'Normal',
    'Malo',
    'Muy malo',
  ];

  bool _isSubmitting = false;

  Future<void> _registrarEntrevista() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final entrevista = EntrevistaPadron(
          idEntrevistaPadron: 0,
          comentariosEntrevistaPadron: _comentarioController.text,
          calificacionEntrevistaPadron: _calificacionSeleccionada,
          fechaEntrevistaPadron: DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(DateTime.now()),
          idUser: int.tryParse(widget.idUser),
          idOrdenServicio: widget.idOrdenServicio,
        );

        final success = await _entrevistaPadronController.addEntrevistaPadron(
          entrevista,
        );

        if (success) {
          Navigator.pop(context);
          showOk(context, 'Entrevista registrada con éxito');
          widget.onSuccess;
        } else {
          showError(context, 'Error al registrar entrevista');
        }
      } catch (e) {
        showError(context, 'Error registrarEntrevista | EntrevistaDialog');
        print('Error registrarEntrevista | EntrevistaDialog: ${e.toString()}');
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Entrevista'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSubmitting) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: CustomListaDesplegable(
                      value: _calificacionSeleccionada,
                      labelText: 'Calificación',
                      items: _opcionesCalificacion,
                      onChanged: (caificacion) {
                        setState(() {
                          _calificacionSeleccionada = caificacion;
                        });
                      },
                      validator: (calificacion) {
                        if (calificacion == null || calificacion.isEmpty) {
                          return 'Seleccione una calificación';
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
                validator: (comentario) {
                  if (comentario == null || comentario.isEmpty) {
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
          onPressed: _isSubmitting ? null : _registrarEntrevista,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade800,
          ),
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
