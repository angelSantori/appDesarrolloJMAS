//  Librerías
import 'dart:convert';
import 'dart:typed_data';
import 'package:desarrollo_jmas/app/configs/controllers/docs_pdf_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

//  Validar Campos Antes de Imprimri
Future<bool> validarCampos({
  required BuildContext context,
  required var selectedPadron,
  required var selectedTipoProblema,
  required var selectedMedio,
  required var selectedPrioridad,
}) async {
  if (selectedMedio == null) {
    showAdvertence(context, 'Debe seleccionar un medio');
    return false;
  }
  if (selectedTipoProblema == null) {
    showAdvertence(context, 'Debe seleccionar un tipo de servicio');
    return false;
  }
  if (selectedPrioridad == null) {
    showAdvertence(context, 'Debe seleccionar una prioridad');
    return false;
  }
  if (selectedPadron == null) {
    showAdvertence(context, 'Debe seleccionar un padrón');
    return false;
  }
  return true;
}

//  PDF
Future<Uint8List> _generateQrCode(String data) async {
  final qrCode = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: false,
  );
  final image = await qrCode.toImage(200);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<bool> _guardarPDFOrdenServicioBD({
  required String nombreDocPDF,
  required String fechaDocPDF,
  required String dataDocPDF,
  required int idUser,
}) async {
  final pdfController = DocsPdfController();
  return await pdfController.savePdf(
    nombreDocPdf: nombreDocPDF,
    fechaDocPdf: fechaDocPDF,
    dataDocPdf: dataDocPDF,
    idUser: idUser,
  );
}

Future<void> generarPDFOrdenServicio({
  required Padron padron,
  required TipoProblema tipoProblema,
  required Medios medio,
  required String idUser,
  required String userName,
  required String folioOS,
  required String fechaOS,
  required String prioridadOS,
  String? contacto,
  String? comentario,
}) async {
  try {
    final pdfBytes = await _generatePdfOrdenServicioBytes(
      padron: padron,
      fechaOS: fechaOS,
      prioridadOS: prioridadOS,
      idUser: idUser,
      userName: userName,
      tipoProblema: tipoProblema,
      folioOS: folioOS,
      medio: medio,
      contacto: contacto,
      comentarios: comentario,
    );

    final base64PDF = base64Encode(pdfBytes);

    final dbSuccess = await _guardarPDFOrdenServicioBD(
      nombreDocPDF: 'Orden_Servicio_$folioOS.pdf',
      fechaDocPDF: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      dataDocPDF: base64PDF,
      idUser: int.parse(idUser),
    );

    if (!dbSuccess) {
      print('PDF se descargó pero no se guardó en la BD');
    }

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'Orden_Servicio_${currentDate}_$currentTime.pdf';

    // ignore: unused_local_variable
    final anchor =
        html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = fileName
          ..click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error al generar PDF de salida: $e');
    throw Exception('Error al generar el PDF');
  }
}

Future<Uint8List> _generatePdfOrdenServicioBytes({
  required Padron padron,
  required TipoProblema tipoProblema,
  required Medios medio,
  required String idUser,
  required String userName,
  required String folioOS,
  required String fechaOS,
  required String prioridadOS,
  String? contacto,
  String? comentarios,
}) async {
  final pdf = pw.Document();
  final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  // Generar código QR
  final qrBytes = await _generateQrCode(folioOS);
  final qrImage = pw.MemoryImage(qrBytes);

  // Cargar imagen del logo desde assets
  final logoImage = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/logo_jmas_sf.png',
    )).buffer.asUint8List(),
  );

  // Estilos
  final headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final titleStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);

  final normalStyle = const pw.TextStyle(fontSize: 10);
  final boldStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 36,
        marginRight: 36,
        marginTop: 36,
        marginBottom: 36,
      ),
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            // Contenido principal
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado con logo
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo a la izquierda
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                      margin: const pw.EdgeInsets.only(right: 10),
                    ),
                    // Información de la organización centrada
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'JUNTA MUNICIPAL DE AGUA Y SANEAMIENTO DE MEOQUI',
                            style: headerStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'ORDEN DE SERVICIO',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // QR a la derecha
                    pw.Container(
                      width: 70,
                      height: 70,
                      child: pw.Image(qrImage),
                    ),
                  ],
                ),

                pw.Divider(thickness: 1),
                pw.SizedBox(height: 15),

                // Información básica
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Folio:', style: boldStyle),
                        pw.Text(folioOS, style: normalStyle),
                        pw.SizedBox(height: 10),

                        pw.Text('Fecha:', style: boldStyle),
                        pw.Text(fechaOS, style: normalStyle),
                        pw.SizedBox(height: 10),

                        pw.Text('Prioridad:', style: boldStyle),
                        pw.Text(prioridadOS, style: normalStyle),
                      ],
                    ),

                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Tipo de Problema:', style: boldStyle),
                        pw.Text(
                          '${tipoProblema.idTipoProblema} - ${tipoProblema.nombreTP}',
                          style: normalStyle,
                        ),
                        pw.SizedBox(height: 10),

                        pw.Text('Medio:', style: boldStyle),
                        pw.Text(
                          '${medio.idMedio} - ${medio.nombreMedio}',
                          style: normalStyle,
                        ),
                        pw.SizedBox(height: 10),

                        pw.Text('Capturó:', style: boldStyle),
                        pw.Text('$idUser - $userName', style: normalStyle),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 15),

                // Información del padrón (centrado)
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                    'INFORMACIÓN DEL PADRÓN',
                    style: titleStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Padrón:', style: boldStyle),
                        pw.Text(
                          '${padron.idPadron} - ${padron.padronNombre}',
                          style: normalStyle,
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Dirección:', style: boldStyle),
                        pw.Text(
                          '${padron.padronDireccion}',
                          style: normalStyle,
                        ),
                        if (contacto!.isNotEmpty) ...[
                          pw.SizedBox(height: 10),
                          pw.Text('Contacto:', style: boldStyle),
                          pw.Text(contacto, style: normalStyle),
                        ],
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 15),

                // Descripción del problema
                if (comentarios != null) ...[
                  pw.Text('COMENTARIO', style: titleStyle),
                  pw.SizedBox(height: 10),

                  if (comentarios.isNotEmpty)
                    pw.Text(comentarios, style: normalStyle)
                  else
                    pw.Text(
                      'No se proporcionaron detalles adicionales',
                      style: pw.TextStyle(font: normalStyle.fontItalic),
                    ),
                ],
              ],
            ),

            // Firmas al pie de página
            pw.Positioned(
              bottom: 60, // Ajustar según sea necesario
              left: 0,
              right: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  // Firma de quien captura
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Capturó', style: normalStyle),
                      pw.Text(userName, style: normalStyle),
                    ],
                  ),

                  // Firma de quien recibe
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Recibió', style: normalStyle),
                      pw.Text('Nombre y firma', style: normalStyle),
                    ],
                  ),
                ],
              ),
            ),

            // Pie de página con fecha de generación
            pw.Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: pw.Center(
                child: pw.Text(
                  'Generado el $fechaFormateada',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
