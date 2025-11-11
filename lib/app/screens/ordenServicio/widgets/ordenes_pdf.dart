import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:pdf/pdf.dart';

class OrdenesPDF {
  static Future<Uint8List> generarPDFMultiplesOrdenes({
    required List<OrdenServicio> ordenes,
    required List<Medios> medios,
    required List<TipoProblema> tiposProblema,
    required List<Padron> padrones,
    required DateTimeRange rangoFechas,
    required TipoProblema? tipoProblemaFiltro,
  }) async {
    final pdf = pw.Document();

    final fechaGeneracion = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.now());

    // Cargar imagen del logo desde assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/logo_jmas_sf.png',
      )).buffer.asUint8List(),
    );

    // Estilos
    final headerStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );

    final titleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );
    final normalStyle = const pw.TextStyle(fontSize: 10);
    final boldStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final smallStyle = const pw.TextStyle(fontSize: 8);

    // Usar MultiPage en lugar de Page para manejar múltiples páginas
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 36,
          marginRight: 36,
          marginTop: 36,
          marginBottom: 36,
        ),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              // Encabezado
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(logoImage),
                    margin: const pw.EdgeInsets.only(right: 10),
                  ),
                  // Información de la organización
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
                          'REPORTE DE ÓRDENES DE SERVICIO',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 15),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(thickness: 1),
              pw.Center(
                child: pw.Text(
                  'Página ${context.pageNumber} de ${context.pagesCount} - Generado el $fechaGeneracion',
                  style: smallStyle,
                ),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Información del reporte
            pw.Text('INFORMACIÓN DEL REPORTE', style: titleStyle),
            pw.SizedBox(height: 10),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Rango de fechas:', style: boldStyle),
                    pw.Text(
                      '${DateFormat('dd/MM/yyyy').format(rangoFechas.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas.end)}',
                      style: normalStyle,
                    ),
                  ],
                ),
                pw.SizedBox(width: 50),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Tipo de servicio:', style: boldStyle),
                    pw.Text(
                      tipoProblemaFiltro != null
                          ? '${tipoProblemaFiltro.idTipoProblema} - ${tipoProblemaFiltro.nombreTP}'
                          : 'Todos',
                      style: normalStyle,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Text('Total de órdenes: ${ordenes.length}', style: boldStyle),

            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 15),

            // Lista de órdenes
            pw.Text('ÓRDENES DE SERVICIO', style: titleStyle),
            pw.SizedBox(height: 10),

            // Tabla de órdenes
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: boldStyle,
              cellStyle: smallStyle,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2), // Folio
                1: const pw.FlexColumnWidth(2), // Fecha
                2: const pw.FlexColumnWidth(2.5), // Tipo Servicio
                3: const pw.FlexColumnWidth(1.5), // ID Padrón
                4: const pw.FlexColumnWidth(3), // Nombre Padrón
                5: const pw.FlexColumnWidth(3), // Dirección Padrón
              },
              headers: [
                'Folio',
                'Fecha',
                'Tipo Servicio',
                'ID Padrón',
                'Nombre Padrón',
                'Dirección',
              ],
              data:
                  ordenes.map((orden) {
                    final tipoProblema = tiposProblema.firstWhere(
                      (tp) => tp.idTipoProblema == orden.idTipoProblema,
                      orElse: () => TipoProblema(),
                    );

                    // Obtener información del padrón
                    final padron = padrones.firstWhere(
                      (p) => p.idPadron == orden.idPadron,
                      orElse: () => Padron(),
                    );

                    return [
                      orden.folioOS ?? 'N/A',
                      orden.fechaOS ?? 'N/A',
                      tipoProblema.nombreTP ?? 'N/A',
                      padron.idPadron?.toString() ?? 'N/A',
                      padron.padronNombre ?? 'N/A',
                      padron.padronDireccion ?? 'N/A',
                    ];
                  }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> descargarPDF({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor =
          html.AnchorElement(href: url)
            ..target = '_blank'
            ..download = fileName
            ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error al descargar PDF: $e');
      throw Exception('Error al descargar el PDF');
    }
  }
}
