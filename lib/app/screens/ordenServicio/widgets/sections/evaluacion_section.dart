import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:desarrollo_jmas/app/configs/auth/permission_widget.dart';
import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:flutter/material.dart';


class EvaluacionSection extends StatefulWidget {
  final List<EvaluacionOS> evaluaciones;
  final List<Users> allUsers;
  final bool isLoadingEvaluacion;
  final String estadoOS;
  final VoidCallback onEvaluar;
  final VoidCallback onCancelar;
  final VoidCallback onRevisar;
  final VoidCallback onReasignar;
  final VoidCallback onCambiarEstado;

  const EvaluacionSection({
    super.key,
    required this.evaluaciones,
    required this.allUsers,
    required this.isLoadingEvaluacion,
    required this.estadoOS,
    required this.onEvaluar,
    required this.onCancelar,
    required this.onRevisar,
    required this.onReasignar,
    required this.onCambiarEstado,
  });

  @override
  State<EvaluacionSection> createState() => _EvaluacionSectionState();
}

class _EvaluacionSectionState extends State<EvaluacionSection> {
  int _currentEvaluacionIndex = 0;

  void _nextEvaluacion() {
    if (widget.evaluaciones.isEmpty) return;
    setState(() {
      _currentEvaluacionIndex =
          (_currentEvaluacionIndex + 1) % widget.evaluaciones.length;
    });
  }

  void _prevEvaluacion() {
    if (widget.evaluaciones.isEmpty) return;
    setState(() {
      _currentEvaluacionIndex =
          (_currentEvaluacionIndex - 1) % widget.evaluaciones.length;
      if (_currentEvaluacionIndex < 0) {
        _currentEvaluacionIndex = widget.evaluaciones.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentEvaluacion =
        widget.evaluaciones.isNotEmpty
            ? widget.evaluaciones[_currentEvaluacionIndex]
            : null;
    final evaluador =
        currentEvaluacion?.idUser != null
            ? widget.allUsers.firstWhere(
              (user) => user.id_User == currentEvaluacion?.idUser,
              orElse: () => Users(),
            )
            : null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.evaluaciones.isEmpty) ...[
                      const Text(
                        'Asignar Servicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Evaluar Servicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                    if (widget.evaluaciones.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '${_currentEvaluacionIndex + 1}/${widget.evaluaciones.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    if (widget.evaluaciones.length > 1)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: _prevEvaluacion,
                        tooltip: 'Evaluación anterior',
                      ),
                    if (widget.evaluaciones.length > 1)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: _nextEvaluacion,
                        tooltip: 'Siguiente evaluación',
                      ),
                    if (widget.estadoOS == 'Pendiente')
                      PermissionWidget(
                        permission: 'evaluar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 6,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade900,
                            ),
                            onPressed: widget.onEvaluar,

                            child: Text(
                              'Asignar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 20),
                    if (widget.estadoOS == 'Pendiente' ||
                        widget.estadoOS == 'Aprobada - A' ||
                        widget.estadoOS == 'Revisión')
                      PermissionWidget(
                        permission: 'evaluar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 6,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                            ),
                            onPressed: widget.onCancelar,
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 20),
                    if (widget.estadoOS == 'Revisión')
                      PermissionWidget(
                        permission: 'evaluar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 6,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade900,
                            ),
                            onPressed: widget.onRevisar,
                            child: const Text(
                              'Revisar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    if (widget.estadoOS == 'Pendiente' ||
                        widget.estadoOS == 'Completado' ||
                        widget.estadoOS == 'Incompleto') ...[
                      PermissionWidget(
                        permission: 'evaluar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 6,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                            ),
                            onPressed: widget.onCambiarEstado,
                            child: const Text(
                              'Estado',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (widget.estadoOS == 'Devuelta') ...[
                      PermissionWidget(
                        permission: 'evaluar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 6,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                            ),
                            onPressed: widget.onReasignar,
                            child: const Text(
                              'Reasignar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (widget.isLoadingEvaluacion)
              Center(
                child: CircularProgressIndicator(color: Colors.indigo.shade900),
              )
            else if (currentEvaluacion != null) ...[
              buildInfoRow('Fecha', currentEvaluacion.fechaEOS ?? 'N/A'),
              buildInfoRow(
                'Comentarios',
                currentEvaluacion.comentariosEOS ?? 'N/A',
              ),
              buildInfoRow(
                'Estado',
                currentEvaluacion.estadoEnviadoEOS ?? 'N/A',
              ),
              const SizedBox(height: 8),
              const Text(
                'Datos del Evaluador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              if (currentEvaluacion.idUser != null) ...[
                buildInfoRow(
                  'Usuario',
                  '${currentEvaluacion.idUser} - ${evaluador?.user_Name ?? 'No disponible'} (${evaluador?.user_Contacto ?? 'Sin contacto'})',
                ),
              ],
            ] else ...[
              buildInfoRow('Fecha', 'N/A'),
              buildInfoRow('Comentarios', 'N/A'),
              buildInfoRow('Revisado por', 'N/A'),
            ],
          ],
        ),
      ),
    );
  }
}
