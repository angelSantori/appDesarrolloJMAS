import 'dart:convert';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/widgets_detalles.dart';
import 'package:desarrollo_jmas/app/configs/controllers/trabajo_realizado_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

//Mostrar imagen
void showImageDialog(BuildContext context, String imageBase64, String title) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  1, // 90% del ancho de pantalla
              maxHeight:
                  MediaQuery.of(context).size.height *
                  1, // 80% del alto de pantalla
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.1, // Escala mínima reducida
                    maxScale: 4.0,
                    child: Image.memory(
                      base64Decode(
                        imageBase64.contains(',')
                            ? imageBase64.split(',').last
                            : imageBase64,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

// Maps
void _openGoogleMaps(String location) {
  // Extraer coordenadas si están en formato "lat, lng"
  final coords = location.split(',');
  if (coords.length == 2) {
    final lat = coords[0].trim();
    final lng = coords[1].trim();
    final url = 'https://www.google.com/maps?q=$lat,$lng';
    html.window.open(url, '_blank');
  } else {
    // Si no son coordenadas, hacer búsqueda por dirección
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    html.window.open(url, '_blank');
  }
}

Future<Users?> _getUserInfo(int? userId, List<Users> allUsers) async {
  if (userId == null) return null;
  return allUsers.firstWhere(
    (user) => user.id_User == userId,
    orElse: () => Users(),
  );
}

Widget _buildInfoRowCords(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child:
              label == 'Ubicación' && value != null && value != 'No disponible'
                  ? InkWell(
                    onTap: () => _openGoogleMaps(value),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                  : Text(
                    value ?? 'No disponible',
                    style: const TextStyle(fontSize: 16),
                  ),
        ),
      ],
    ),
  );
}

Widget _buildImageFromBase64(
  String? base64String,
  String label,
  BuildContext context,
) {
  if (base64String == null || base64String.isEmpty) {
    return Container();
  }

  try {
    final cleanBase64 =
        base64String.contains(',')
            ? base64String.split(',').last
            : base64String;

    return GestureDetector(
      onTap: () => showImageDialog(context, base64String, label),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 4),
          Image.memory(
            base64Decode(cleanBase64),
            height: 120, // Reducimos el tamaño para pantallas pequeñas
            width: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              );
            },
          ),
        ],
      ),
    );
  } catch (e) {
    print('Error al decodificar imagen: $e');
    return Column(
      children: [
        Text(label),
        const Icon(Icons.error_outline, color: Colors.red),
      ],
    );
  }
}

Widget buildTrabajoRealizadoCard(
  TrabajoRealizado trabajos,
  List<Users> allUsers,
) {
  return FutureBuilder<Users?>(
    future: _getUserInfo(trabajos.idUserTR, allUsers),
    builder: (context, snapshot) {
      String userInfo = 'N/A';
      if (snapshot.hasData && snapshot.data != null) {
        final user = snapshot.data!;
        userInfo = '${user.id_User} - ${user.user_Name}';
      } else if (trabajos.idUserTR != null) {
        userInfo = '${trabajos.idUserTR} - Usuario no encontrado';
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoRow('Folio', trabajos.folioTR),
                    buildInfoRow('Usuario', userInfo),
                    if (trabajos.fechaTR != null)
                      buildInfoRow('Fecha', trabajos.fechaTR),
                    if (trabajos.ubicacionTR != null)
                      _buildInfoRowCords('Ubicación', trabajos.ubicacionTR),
                    if (trabajos.comentarioTR != null)
                      buildInfoRow('Comentario', trabajos.comentarioTR),
                    if (trabajos.folioSalida != null)
                      buildInfoRow(
                        'ID Salida',
                        trabajos.folioSalida?.toString(),
                      ),
                    if (trabajos.estadoTR != null &&
                        trabajos.fotoRequiereMaterial64TR == null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                'Estado: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                trabajos.estadoTR ?? 'N/A',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: getEstadoTrabajoColor(
                                trabajos.estadoTR,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              //Fotos
              if (trabajos.fotoAntes64TR != null &&
                  trabajos.fotoAntes64TR!.isNotEmpty &&
                  trabajos.fotoDespues64TR != null &&
                  trabajos.fotoDespues64TR!.isNotEmpty) ...[
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trabajos.fotoAntes64TR != null)
                        _buildImageFromBase64(
                          trabajos.fotoAntes64TR,
                          'Antes',
                          context,
                        ),
                      const SizedBox(width: 50),
                      if (trabajos.fotoDespues64TR != null) ...[
                        const SizedBox(height: 8),
                        _buildImageFromBase64(
                          trabajos.fotoDespues64TR,
                          'Después',
                          context,
                        ),
                      ],
                      const SizedBox(width: 50),
                      if (trabajos.firma64TR != null) ...[
                        const SizedBox(height: 8),
                        _buildImageFromBase64(
                          trabajos.firma64TR,
                          'Firma',
                          context,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (trabajos.fotoRequiereMaterial64TR != null &&
                  trabajos.fotoRequiereMaterial64TR!.isNotEmpty) ...[
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (trabajos.fotoRequiereMaterial64TR != null)
                        _buildImageFromBase64(
                          trabajos.fotoRequiereMaterial64TR,
                          'Evidencia de Requerimiento de Material',
                          context,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

//  Sección Trabajo Realizado
Widget buildTrabajosRealizadosSection(
  bool isLoadingTrabajos,
  List<TrabajoRealizado> trabajosRealizados,
  List<Users> allUsers,
) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Trabajos Realizados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 10),
          if (isLoadingTrabajos)
            Center(
              child: CircularProgressIndicator(color: Colors.indigo.shade900),
            )
          else if (trabajosRealizados.isEmpty)
            const Text(
              'No hay trabajos realizados registrados',
              style: TextStyle(fontSize: 16),
            )
          else
            ...trabajosRealizados
                .map(
                  (listTrabajos) =>
                      buildTrabajoRealizadoCard(listTrabajos, allUsers),
                )
                .toList(),
        ],
      ),
    ),
  );
}
