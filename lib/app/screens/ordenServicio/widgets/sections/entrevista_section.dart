import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:desarrollo_jmas/app/configs/auth/permission_widget.dart';
import 'package:desarrollo_jmas/app/configs/controllers/entrevista_padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:flutter/material.dart';


class EntrevistaSection extends StatelessWidget {
  final EntrevistaPadron? entrevista;
  final List<Users> allUsers;
  final bool isLoadingEntrevista;
  final String estadoOS;
  final VoidCallback onRegistrarEntrevista;

  const EntrevistaSection({
    super.key,
    required this.entrevista,
    required this.allUsers,
    required this.isLoadingEntrevista,
    required this.estadoOS,
    required this.onRegistrarEntrevista,
  });

  @override
  Widget build(BuildContext context) {
    final entrevistador =
        entrevista?.idUser != null
            ? allUsers.firstWhere(
              (user) => user.id_User == entrevista?.idUser,
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
                const Text(
                  'Entrevista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                if (estadoOS == "Cerrada" && entrevista == null)
                  PermissionWidget(
                    permission: 'evaluar',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6,
                            offset: Offset(3, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade800,
                        ),
                        onPressed: onRegistrarEntrevista,
                        child: const Text(
                          'Registrar entrevista',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 13),
            if (isLoadingEntrevista)
              Center(
                child: CircularProgressIndicator(color: Colors.indigo.shade900),
              )
            else if (entrevista != null) ...[
              const SizedBox(height: 8),
              buildInfoRow('Fecha', entrevista!.fechaEntrevistaPadron ?? 'N/A'),
              const SizedBox(height: 2),
              buildInfoRow(
                'Calificación',
                entrevista!.calificacionEntrevistaPadron ?? 'N/A',
              ),
              const SizedBox(height: 2),
              buildInfoRow(
                'Comentarios',
                entrevista!.comentariosEntrevistaPadron ?? 'N/A',
              ),
              const SizedBox(height: 8),
              const Text(
                'Datos del Entrevistador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              if (entrevistador != null)
                buildInfoRow(
                  'Usuario',
                  '${entrevistador.id_User} - ${entrevistador.user_Name} (${entrevistador.user_Contacto ?? 'Sin contacto'})',
                ),
            ] else ...[
              buildInfoRow('Fecha', 'N/A'),
              const SizedBox(height: 2),
              buildInfoRow('Calificación', 'N/A'),
              const SizedBox(height: 2),
              buildInfoRow('Comentarios', 'N/A'),
              const SizedBox(height: 8),
              const Text(
                'Datos del Entrevistador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 4),
              buildInfoRow('Usuario', 'N/A'),
            ],
          ],
        ),
      ),
    );
  }
}
