import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Import para web
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/web/descuentos_sociales_movils_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/web/descuentos_sociales_movils_pdf_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';

class DetailsDescuentoSocialMovil extends StatefulWidget {
  final DescuentosSocialesMovils descuentoSocial;

  const DetailsDescuentoSocialMovil({super.key, required this.descuentoSocial});

  @override
  State<DetailsDescuentoSocialMovil> createState() =>
      _DetailsDescuentoSocialMovilState();
}

class _DetailsDescuentoSocialMovilState
    extends State<DetailsDescuentoSocialMovil> {
  final PadronController _padronController = PadronController();
  final UsersController _usersController = UsersController();
  final DescuentosSocialesMovilsPdfController _pdfController =
      DescuentosSocialesMovilsPdfController();

  Padron? _padron;
  Users? _usuario;
  bool _cargando = true;
  bool _descargandoPdf = false;
  DescuentosSocialesMovilsPdf? _pdfExistente;

  @override
  void initState() {
    super.initState();
    _cargarInformacionAdicional();
    _verificarPdfExistente();
  }

  Future<void> _cargarInformacionAdicional() async {
    try {
      // Cargar información del padrón
      final padron = await _padronController.getPadronById(
        widget.descuentoSocial.idPadron,
      );

      // Cargar información del usuario
      final usuario = await _usersController.getUserById(
        widget.descuentoSocial.idUser,
      );

      setState(() {
        _padron = padron;
        _usuario = usuario;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar información adicional: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _verificarPdfExistente() async {
    try {
      final nombreBuscado = '${widget.descuentoSocial.dsmFolio}.pdf';
      final pdfs = await _pdfController.searchDescuentoSocialMovilPdf(
        name: nombreBuscado,
      );

      if (pdfs.isNotEmpty) {
        setState(() {
          _pdfExistente = pdfs.first;
        });
      }
    } catch (e) {
      print('Error al verificar PDF existente: $e');
    }
  }

  Future<void> _descargarPdf() async {
    if (_pdfExistente == null) return;

    setState(() {
      _descargandoPdf = true;
    });

    try {
      final pdfBytes = await _pdfController.downloadPdf(
        _pdfExistente!.idDescuentoSocialMovilPDF,
      );

      if (pdfBytes != null && pdfBytes.isNotEmpty) {
        // Método para Flutter Web
        await _descargarArchivoWeb(pdfBytes, _pdfExistente!.nombreDocPdfDSM);
        _mostrarDialogoDescargaExitosa();
      } else {
        showError(context, 'Error al descargar el PDF');
      }
    } catch (e) {
      print('Error al descargar PDF: $e');
      showError(context, 'Error al descargar el PDF: $e');
    } finally {
      setState(() {
        _descargandoPdf = false;
      });
    }
  }

  // Método específico para Flutter Web
  Future<void> _descargarArchivoWeb(Uint8List bytes, String fileName) async {
    try {
      // Crear un blob con los bytes
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Crear un elemento anchor para la descarga
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      // Limpiar la URL
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error en descarga web: $e');
      throw e;
    }
  }

  // Método alternativo usando file_saver (para otras plataformas)
  Future<void> _descargarConFileSaver(Uint8List bytes, String fileName) async {
    try {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        mimeType: MimeType.pdf,
      );
    } catch (e) {
      print('Error con file_saver: $e');
      // Fallback al método web
      await _descargarArchivoWeb(bytes, fileName);
    }
  }

  void _mostrarDialogoDescargaExitosa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Descargado'),
        content: Text(
          'El PDF ${_pdfExistente!.nombreDocPdfDSM} se ha descargado exitosamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // ... (el resto de los métodos se mantienen igual)

  Widget _buildSeccion(String titulo, List<Widget> contenido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ...contenido,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No disponible',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles - ${widget.descuentoSocial.dsmFolio}'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando información...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Información General
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Esto empuja el contenido hacia los extremos
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Información General',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoItem(
                                      'Folio',
                                      widget.descuentoSocial.dsmFolio,
                                    ),
                                    _buildInfoItem(
                                      'Fecha',
                                      _formatearFecha(
                                        widget.descuentoSocial.dsmFecha,
                                      ),
                                    ),
                                    _buildInfoItem(
                                      'Razón del Descuento',
                                      widget.descuentoSocial.dsmRazonDescuento,
                                    ),
                                  ],
                                ),

                                // Información del PDF (ahora aparecerá hasta abajo)
                                if (_pdfExistente != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'PDF disponible: ${_pdfExistente!.nombreDocPdfDSM}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                              Text(
                                                'Fecha del PDF: ${_formatearFecha((_pdfExistente!.fechaDocPdfDSM))}',
                                                style: TextStyle(
                                                  color: Colors.green.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: _descargandoPdf
                                              ? null
                                              : _descargarPdf,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade700,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: _descargandoPdf
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Text('Descargar PDF'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'No hay PDF disponible para este descuento social',
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Datos del Beneficiario
                        Expanded(
                          child: _buildSeccion('Datos del Beneficiario', [
                            _buildInfoItem(
                              'Nombre',
                              widget.descuentoSocial.dsmNombreBeneficiario,
                            ),
                            _buildInfoItem(
                              'Cónyuge',
                              widget.descuentoSocial.dsmNombreConyugue,
                            ),
                            _buildInfoItem(
                              'Edad',
                              '${widget.descuentoSocial.dsmEdad} años',
                            ),
                            _buildInfoItem(
                              'CURP',
                              widget.descuentoSocial.dsmCURP,
                            ),
                            _buildInfoItem(
                              'Teléfono',
                              widget.descuentoSocial.dsmTelefono,
                            ),
                          ]),
                        ),
                        const SizedBox(width: 16),

                        // Vivienda y Documentación
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child:
                                    _buildSeccion('Información de Vivienda', [
                                      _buildInfoItem(
                                        'Tipo de Vivienda',
                                        widget.descuentoSocial.dsmVivienda,
                                      ),
                                    ]),
                              ),
                              Expanded(
                                child: _buildSeccion('Documentación', [
                                  _buildInfoItem(
                                    'Número de INE',
                                    widget.descuentoSocial.dsmNumeroINE,
                                  ),
                                  _buildInfoItem(
                                    'Tipo de Comprobante',
                                    widget.descuentoSocial.dsmComprobante,
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_padron != null) ...[
                          Expanded(
                            child: _buildSeccion('Información del Padrón', [
                              _buildInfoItem(
                                'ID Padrón',
                                _padron!.idPadron?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                'Nombre',
                                _padron!.padronNombre ?? 'No disponible',
                              ),
                              _buildInfoItem(
                                'Dirección',
                                _padron!.padronDireccion ?? 'No disponible',
                              ),
                            ]),
                          ),
                        ],
                        const SizedBox(width: 16),

                        if (_usuario != null) ...[
                          Expanded(
                            child: _buildSeccion('Información del Usuario', [
                              _buildInfoItem(
                                'ID Usuario',
                                _usuario!.id_User?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                'Nombre',
                                _usuario!.user_Name ?? 'No disponible',
                              ),
                              _buildInfoItem(
                                'Contacto',
                                _usuario!.user_Contacto ?? 'No disponible',
                              ),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),

                  _buildSeccion('Comprobante', [
                    if (widget.descuentoSocial.dsmImgDocBase64.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          // Mostrar diálogo con imagen ampliada
                          _mostrarImagenAmpliada(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Imagen del Comprobante:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '(Toca la imagen para ampliar)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Image.memory(
                                _decodeBase64Image(
                                  widget.descuentoSocial.dsmImgDocBase64,
                                ),
                                height: 300,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Error al cargar la imagen'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 100,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Text(
                            'No hay imagen disponible',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    try {
      return base64.decode(base64String);
    } catch (e) {
      print('Error al decodificar imagen base64: $e');
      return Uint8List(0);
    }
  }

  void _mostrarImagenAmpliada(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                _decodeBase64Image(widget.descuentoSocial.dsmImgDocBase64),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 50),
                        SizedBox(height: 16),
                        Text('Error al cargar la imagen'),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
