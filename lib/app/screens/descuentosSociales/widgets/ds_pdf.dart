import 'dart:convert';
import 'package:desarrollo_jmas/app/configs/controllers/descuento_social_pdf_controller.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

Future<bool> guardarPDFEnBaseDeDatos({
  required String folioDS,
  required String fechaDS,
  required String nombreBeneficiario,
  required String nombreConyugue,
  required int edad,
  required String curp,
  required String telefono,
  required String razonDescuento,
  required String tipoVivienda,
  required String numeroINE,
  required String tipoComprobante,
  required String nombrePadron,
  required String direccionPadron,
  required String userName,
  required int selectedPadronId,
}) async {
  try {
    // Generar el PDF en bytes
    final pdfBytes = await generarPdfDescuentoSocialBytes(
      folioDS: folioDS,
      fechaDS: fechaDS,
      nombreBeneficiario: nombreBeneficiario,
      nombreConyugue: nombreConyugue,
      edad: edad,
      curp: curp,
      telefono: telefono,
      razonDescuento: razonDescuento,
      tipoVivienda: tipoVivienda,
      numeroINE: numeroINE,
      tipoComprobante: tipoComprobante,
      nombrePadron: nombrePadron,
      direccionPadron: direccionPadron,
      userName: userName,
      selectedPadronId: selectedPadronId,
    );

    // Convertir bytes a base64
    final pdfBase64 = base64.encode(pdfBytes);

    // Crear nombre del documento
    final nombreDocumento = '$folioDS.pdf';

    // Usar el controlador para guardar en la base de datos
    final controller = DescuentoSocialPdfController();
    final resultado = await controller.savePdf(
      nombreDocPdfDS: nombreDocumento,
      fechaDocPdfDS: DateTime.now().toIso8601String(),
      dataDocPdfDS: pdfBase64,
    );

    return resultado;
  } catch (e) {
    print('Error al guardar PDF en base de datos: $e');
    return false;
  }
}

Future<void> generarGuardarYDescargarPDF({
  required String folioDS,
  required String fechaDS,
  required String nombreBeneficiario,
  required String nombreConyugue,
  required int edad,
  required String curp,
  required String telefono,
  required String razonDescuento,
  required String tipoVivienda,
  required String numeroINE,
  required String tipoComprobante,
  required String nombrePadron,
  required String direccionPadron,
  required String userName,
  required int selectedPadronId,
}) async {
  try {
    // Mostrar indicador de progreso
    // Puedes usar un diálogo de carga aquí si estás en un contexto con UI

    // 1. Guardar en base de datos
    final guardadoExitoso = await guardarPDFEnBaseDeDatos(
      folioDS: folioDS,
      fechaDS: fechaDS,
      nombreBeneficiario: nombreBeneficiario,
      nombreConyugue: nombreConyugue,
      edad: edad,
      curp: curp,
      telefono: telefono,
      razonDescuento: razonDescuento,
      tipoVivienda: tipoVivienda,
      numeroINE: numeroINE,
      tipoComprobante: tipoComprobante,
      nombrePadron: nombrePadron,
      direccionPadron: direccionPadron,
      userName: userName,
      selectedPadronId: selectedPadronId,
    );

    if (guardadoExitoso) {
      print('PDF guardado exitosamente en la base de datos');

      // 2. Generar y descargar el archivo para el usuario
      await generarPdfDescuentoSocialFile(
        folioDS: folioDS,
        fechaDS: fechaDS,
        nombreBeneficiario: nombreBeneficiario,
        nombreConyugue: nombreConyugue,
        edad: edad,
        curp: curp,
        telefono: telefono,
        razonDescuento: razonDescuento,
        tipoVivienda: tipoVivienda,
        numeroINE: numeroINE,
        tipoComprobante: tipoComprobante,
        nombrePadron: nombrePadron,
        direccionPadron: direccionPadron,
        userName: userName,
        selectedPadronId: selectedPadronId,
      );

      // Mostrar mensaje de éxito
      // _mostrarMensajeExito(context); // Si tienes contexto
    } else {
      print('Error al guardar PDF en la base de datos');
      // _mostrarMensajeError(context); // Si tienes contexto
    }
  } catch (e) {
    print('Error en el proceso completo: $e');
    // _mostrarMensajeError(context); // Si tienes contexto
  }
}

Future<Uint8List> generarPdfDescuentoSocialBytes({
  required String folioDS,
  required String fechaDS,
  required String nombreBeneficiario,
  required String nombreConyugue,
  required int edad,
  required String curp,
  required String telefono,
  required String razonDescuento,
  required String tipoVivienda,
  required String numeroINE,
  required String tipoComprobante,
  required String nombrePadron,
  required String direccionPadron,
  required String userName,
  required int selectedPadronId,
}) async {
  final pdf = pw.Document();

  // Cargar imagen del logo desde assets
  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/logo_jmas_sf.png'))
        .buffer
        .asUint8List(),
  );

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 20, // Márgenes más pequeños
        marginRight: 20,
        marginTop: 20,
        marginBottom: 20,
      ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Encabezado con borde negro
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2, color: PdfColors.black),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(logoImage),
                  ),
                  pw.SizedBox(width: 10),
                  // Título
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: double.infinity,
                          color: PdfColors.black,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'JUNTA MUNICIPAL DE AGUA Y SANEAMIENTO DE MEOQUI',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: double.infinity,
                          color: PdfColors.grey300,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'SOLICITUD DE DESCUENTO SOCIAL',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Información de formato
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Formato: DC 15.2',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 5),
                      pw.Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 5),
                      pw.Text('Versión: 1.0',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 5),
                      pw.Text('No. Folio',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(folioDS, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Sección 1: Datos del recibo - Estructura similar al Excel
            pw.Container(
              width: double.infinity,
              child: pw.Text(
                'DATOS DEL RECIBO EN EL QUE SE APLICA EL DESCUENTO',
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              //border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6),
                1: const pw.FlexColumnWidth(4.5),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      color: PdfColors.grey200,
                      child: pw.Text('Nombre',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(nombrePadron,
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(6),
                                  color: PdfColors.grey200,
                                  child: pw.Text('No. Cuenta',
                                      style: pw.TextStyle(
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(6),
                                  child: pw.Text(selectedPadronId.toString(),
                                      style: const pw.TextStyle(fontSize: 9)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      color: PdfColors.grey200,
                      child: pw.Text('Dirección',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        direccionPadron,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Sección 2: Datos del usuario beneficiado - Estructura similar al Excel
            pw.Container(
              width: double.infinity,
              child: pw.Text('DATOS DEL USUARIO BENEFICIADO',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900),
                  textAlign: pw.TextAlign.center),
            ),
            pw.SizedBox(height: 5),

            // Tabla para nombres del beneficiario y cónyugue
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(4.5),
              },
              children: [
                // Fila 1: Nombre del beneficiario
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      color: PdfColors.grey200,
                      child: pw.Text('Nombre del beneficiario',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(nombreBeneficiario,
                          style: const pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
                // Fila 2: Nombre Esposo(a)
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      color: PdfColors.grey200,
                      child: pw.Text('Nombre Esposo (a)',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(nombreConyugue,
                          style: const pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
              ],
            ),

            // Tabla separada para Edad, CURP y Teléfono
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8), // "Edad"
                1: const pw.FlexColumnWidth(0.6), // Valor edad
                2: const pw.FlexColumnWidth(1.2), // "CURP"
                3: const pw.FlexColumnWidth(2.5), // Valor CURP
                4: const pw.FlexColumnWidth(1.0), // "Teléfono"
                5: const pw.FlexColumnWidth(1.5), // Valor teléfono
              },
              children: [
                pw.TableRow(
                  children: [
                    // Edad
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      color: PdfColors.grey200,
                      child: pw.Text('Edad',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(edad.toString(),
                          style: const pw.TextStyle(fontSize: 9)),
                    ),
                    // CURP
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      color: PdfColors.grey200,
                      child: pw.Text('CURP',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child:
                          pw.Text(curp, style: const pw.TextStyle(fontSize: 9)),
                    ),
                    // Teléfono
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      color: PdfColors.grey200,
                      child: pw.Text('Teléfono',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(telefono,
                          style: const pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Sección 3 y 4: Razón del descuento y Tipo de vivienda - Lado a lado
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Sección 3: Razón del descuento
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        child: pw.Text('SE OTORGA EL DESCUENTO POR',
                            style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        width: double.infinity,
                        height: 20, // Altura aumentada para mejor visualización
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            razonDescuento,
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                // Sección 4: Tipo de vivienda
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        child: pw.Text('LA VIVIENDA ES',
                            style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        width: double.infinity,
                        height: 20, // Altura aumentada para mejor visualización
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            tipoVivienda,
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Sección 5: Documento comprobante
            pw.Container(
              width: double.infinity,
              child: pw.Text(
                  'DOCUMENTO O COMPROBANTE QUE SE PRESENTA PARA ACREDITACIÓN',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900),
                  textAlign: pw.TextAlign.center),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      color: PdfColors.grey200,
                      child: pw.Text('Número de INE',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(numeroINE,
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      color: PdfColors.grey200,
                      child: pw.Text('Tipo de Comprobante',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(tipoComprobante,
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Sección 6: Cláusulas
            pw.Text('CLÁUSULAS',
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildClausula(
                      '1. El descuento se otorgará a personas mayores de 65 años y será de 50% por el consumo de los primeros 20m³.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '2. En caso de tener un mes de rezago, el documento se perderá automáticamente.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '3. En caso de que el registro presente anomalías, daños o esté obstruido y no se permita la toma de lectura; el descuento se perderá hasta la reparación del daño.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '4. En el caso de que la vivienda no se ocupe por dos meses consecutivos, se retirara el descuento.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '5. Las casas solas, lotes baldíos o comercios no son acreedores del descuento.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '6. En caso de cambio de domicilio el usuario se obliga a notificarlo, de no hacerlo se le sancionará sin descuento por el tiempo que haya dejado sin avisar.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '7. El descuento social solo es válido en pagos a tiempo, no se aceptan pagos anticipados.'),
                  pw.SizedBox(height: 8),
                  _buildClausula(
                      '8. En caso de hacer el pago en el cajero automático, el monto deberá cubrirse en su totalidad, de lo contrario el sistema le retirará automáticamente el descuento.'),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    '**SI NO SE PAGA EL CONSUMO ANTES DE LA FECHA DE CORTE, EL DESCUENTO SERÁ REMOVIDO Y PASARÁ AL NUEVO MES CARGADO EN EL RECIBO.**',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Firmas y autorizaciones
            pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(top: 30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Línea para firma
                  pw.Container(
                    width: 250,
                    height: 1,
                    color: PdfColors.black,
                    margin: const pw.EdgeInsets.only(bottom: 8),
                  ),
                  pw.Text('Firma del Beneficiario',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 3),
                  pw.Text(nombreBeneficiario,
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

// Función auxiliar para construir cada cláusula
pw.Widget _buildClausula(String text) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
      ),
    ],
  );
}

Future<html.File> generarPdfDescuentoSocialFile(
    {required String folioDS,
    required String fechaDS,
    required String nombreBeneficiario,
    required String nombreConyugue,
    required int edad,
    required String curp,
    required String telefono,
    required String razonDescuento,
    required String tipoVivienda,
    required String numeroINE,
    required String tipoComprobante,
    required String nombrePadron,
    required String direccionPadron,
    required String userName,
    required int selectedPadronId}) async {
  final bytes = await generarPdfDescuentoSocialBytes(
      folioDS: folioDS,
      fechaDS: fechaDS,
      nombreBeneficiario: nombreBeneficiario,
      nombreConyugue: nombreConyugue,
      edad: edad,
      curp: curp,
      telefono: telefono,
      razonDescuento: razonDescuento,
      tipoVivienda: tipoVivienda,
      numeroINE: numeroINE,
      tipoComprobante: tipoComprobante,
      nombrePadron: nombrePadron,
      direccionPadron: direccionPadron,
      userName: userName,
      selectedPadronId: selectedPadronId);

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Obtener fecha y hora actual
  final now = DateTime.now();
  final dateFormat = DateFormat('ddMMyyyy');
  final timeFormat = DateFormat('HHmmss');

// Formatear fecha y hora
  final formattedDate = dateFormat.format(now);
  final formattedTime = timeFormat.format(now);

  // Crear nombre de archivo con fecha y hora
  final fileName =
      'DescuentoSocial_${folioDS}_${formattedDate}_$formattedTime.pdf';

  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..target = '_blank'
    ..download = fileName
    ..click();

  html.Url.revokeObjectUrl(url);

  return html.File([bytes], fileName, {'type': 'application/pdf'});
}
