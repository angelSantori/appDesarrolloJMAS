import 'dart:convert';
import 'dart:typed_data';
import 'package:desarrollo_jmas/app/configs/controllers/docs_pdf_controller.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:desarrollo_jmas/app/configs/controllers/almacenes_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/proveedores_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<bool> validarCamposAntesDeImprimirEntrada({
  required BuildContext context,
  required List productosAgregados,
  String? referencia,
  required String numFactura,
  required var selectedAlmacen,
  required var proveedor,
  //required var junta,
  required Uint8List? factura,
}) async {
  // if (referencia.isEmpty) {
  //   showAdvertence(context, 'Referencia es obligatoria.');
  //   return false;
  // }

  if (numFactura.isEmpty) {
    showAdvertence(context, 'Número de factura es obligatoria.');
    return false;
  }

  if (selectedAlmacen == null) {
    showAdvertence(context, 'Debe seleccionar un almacen.');
    return false;
  }

  if (proveedor == null) {
    showAdvertence(context, 'Debe seleccionar un proveedor.');
    return false;
  }

  // if (junta == null) {
  //   showAdvertence(context, 'Debe seleccionar una junta.');
  //   return false;
  // }

  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de imprimir.');
    return false;
  }

  if (factura == null) {
    showAdvertence(context, 'Factura obligatoria.');
    return false;
  }

  return true; // Si pasa todas las validaciones, los datos están completos
}

Future<Uint8List> generateQrCode(String data) async {
  final qrCode = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: false,
  );
  final image = await qrCode.toImage(200);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<bool> guardarPDFEntradaBD({
  required String nombreDocPdf,
  required String fechaDocPdf,
  required String dataDocPdf,
  required int idUser,
}) async {
  final pdfController = DocsPdfController();
  return await pdfController.savePdf(
    nombreDocPdf: nombreDocPdf,
    fechaDocPdf: fechaDocPdf,
    dataDocPdf: dataDocPdf,
    idUser: idUser,
  );
}

Future<void> generarPdfEntrada({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String idUser,
  required Almacenes alamcenA,
  required Proveedores proveedorP,
  required String numFactura,
  String? comentario,
  required List<Map<String, dynamic>> productos,
}) async {
  try {
    // 1. Generar PDF con bytes
    final pdfBytes = await generateAndPrintPdfEntradaByte(
      movimiento: movimiento,
      fecha: fecha,
      folio: folio,
      userName: userName,
      idUser: idUser,
      //referencia: referencia,
      alamcenA: alamcenA,
      proveedorP: proveedorP,
      numFactura: numFactura,
      comentario: comentario,
      productos: productos,
    );

    // 2. Convertir a base 64
    final base64Pdf = base64Encode(pdfBytes);

    // 3. Guardar en base de datos
    final dbSuccess = await guardarPDFEntradaBD(
      nombreDocPdf: 'Entrada_Reporte_$folio.pdf',
      fechaDocPdf: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      dataDocPdf: base64Pdf,
      idUser: int.parse(idUser),
    );

    if (!dbSuccess) {
      print('PDF se descargó pero no se guardó en la BD');
    }

    // 4. Descargar localmente
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'Entrada_Reporte_${currentDate}_$currentTime.pdf';

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error al generar PDF de entrada: $e');
    throw Exception('Error al generar el PDF');
  }
}

Future<Uint8List> generateAndPrintPdfEntradaByte({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String idUser,
  //required String referencia,
  required Almacenes alamcenA,
  required Proveedores proveedorP,
  required String? numFactura,
  String? comentario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Generar código QR
  final qrBytes = await generateQrCode(folio);
  final qrImage = pw.MemoryImage(qrBytes);

  // Cargar imagen del logo desde assets
  final logoImage = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/logo_jmas_sf.png',
    )).buffer.asUint8List(),
  );

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) => sum + (producto['precio'] ?? 0.0),
  );

  // Convertir total a letra con centavos
  final partes = total.toStringAsFixed(2).split('.');
  final entero = int.parse(partes[0]);
  final centavos = partes[1];
  final totalEnLetras =
      '${_convertirNumeroALetras(entero)} PESOS $centavos/100 M.N.';

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      // Márgenes estrechos (1.27 cm = 36 puntos)
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
                // Encabezado con logo y datos de la organización
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo a la izquierda
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                      margin: const pw.EdgeInsets.only(right: 15),
                    ),
                    // Información de la organización centrada
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'JUNTA MUNICIPAL DE AGUA Y SANEAMIENTO DE MEOQUI',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'CALLE ZARAGOZA No. 117, Colonia. CENTRO',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'MEOQUI, CHIHUAHUA, MEXICO.',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'www.jmasmeoqui.gob.mx',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Espacio para el QR
                    pw.SizedBox(width: 70),
                  ],
                ),

                // Título del movimiento
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 15, bottom: 15),
                  child: pw.Text(
                    'MOVIMIENTO DE INVENTARIOS: $movimiento',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Información de variables en 3 columnas
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Columna izquierda
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Mov: $folio',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 3),
                          // pw.Text('Ref: $referencia',
                          //     style: const pw.TextStyle(fontSize: 9)),
                          // pw.SizedBox(height: 3),
                          pw.Text(
                            'Prov: ${proveedorP.id_Proveedor} - ${proveedorP.proveedor_Name}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),

                      // Columna central
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Fec: $fecha',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Capturó: $idUser - $userName',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Junta: 1 - Meoqui',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),

                      // Columna derecha
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Almacen: ${alamcenA.id_Almacen} - ${alamcenA.almacen_Nombre}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Número Factura: $numFactura',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabla de productos con solución alternativa para celdas fusionadas
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(50), // Clave
                    1: const pw.FixedColumnWidth(50), // Cantidad
                    2: const pw.FlexColumnWidth(3), // Descripción
                    3: const pw.FixedColumnWidth(50), // Costo
                    4: const pw.FixedColumnWidth(60), // Total
                  },
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    // Encabezados de tabla
                    pw.TableRow(
                      children: [
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            'Clave',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            'Cantidad',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            'Descripción',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            'Costo/Uni',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            'Total',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Filas de productos
                    ...productos
                        .map(
                          (producto) => pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  producto['id'].toString(),
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  producto['cantidad'].toString(),
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  producto['descripcion'] ?? '',
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  '\$${(producto['costo'] ?? 0.0).toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  '\$${(producto['precio'] ?? 0.0).toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                    // Fila de total con solución alternativa para celdas fusionadas
                    pw.TableRow(
                      children: [
                        // Celda de clave vacía
                        pw.Container(),
                        // Celda de cantidad vacía
                        pw.Container(),
                        // Celda de descripción expandida (simula fusión)
                        pw.Expanded(
                          flex: 3, // Ocupa el espacio de 3 columnas
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              'SON: $totalEnLetras',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                        // Celda de "Total"
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            'Total',
                            textAlign: pw.TextAlign.end,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        // Celda con valor total
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            '\$${total.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                //  Comentario
                if (comentario != null && comentario.isNotEmpty) ...[
                  pw.Container(
                    width: double.infinity,
                    margin: const pw.EdgeInsets.only(top: 10),
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.5),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'COMENTARIOS: ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          comentario,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),
                ],
              ],
            ),

            // QR en la esquina superior derecha
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: 70,
                height: 70,
                child: pw.Image(qrImage),
              ),
            ),

            // Sección de firma al pie de página
            pw.Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 180,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Autorizó',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

// Función para convertir números a letras
String _convertirNumeroALetras(int numero) {
  if (numero == 0) return 'CERO';
  if (numero == 1) return 'UN';

  final unidades = [
    '',
    'UN',
    'DOS',
    'TRES',
    'CUATRO',
    'CINCO',
    'SEIS',
    'SIETE',
    'OCHO',
    'NUEVE',
  ];
  final decenas = [
    '',
    'DIEZ',
    'VEINTE',
    'TREINTA',
    'CUARENTA',
    'CINCUENTA',
    'SESENTA',
    'SETENTA',
    'OCHENTA',
    'NOVENTA',
  ];
  final especiales = [
    'DIEZ',
    'ONCE',
    'DOCE',
    'TRECE',
    'CATORCE',
    'QUINCE',
    'DIECISEIS',
    'DIECISIETE',
    'DIECIOCHO',
    'DIECINUEVE',
  ];
  final centenas = [
    '',
    'CIENTO',
    'DOSCIENTOS',
    'TRESCIENTOS',
    'CUATROCIENTOS',
    'QUINIENTOS',
    'SEISCIENTOS',
    'SETECIENTOS',
    'OCHOCIENTOS',
    'NOVECIENTOS',
  ];

  String resultado = '';
  int resto = numero;

  // Miles
  if (resto >= 1000) {
    final miles = resto ~/ 1000;
    if (miles == 1) {
      resultado += 'MIL ';
    } else {
      resultado += '${_convertirNumeroALetras(miles)} MIL ';
    }
    resto %= 1000;
  }

  // Centenas
  if (resto >= 100) {
    final centena = resto ~/ 100;
    resultado += '${centenas[centena]} ';
    resto %= 100;
    if (resto == 0 && centena == 1) {
      resultado = resultado.replaceAll('CIENTO', 'CIEN');
    }
  }

  // Decenas y unidades
  if (resto >= 10 && resto <= 19) {
    resultado += especiales[resto - 10];
  } else if (resto >= 20) {
    final decena = resto ~/ 10;
    resultado += decenas[decena];
    final unidad = resto % 10;
    if (unidad != 0) {
      resultado += ' Y ${unidades[unidad]}';
    }
  } else if (resto > 0) {
    resultado += unidades[resto];
  }

  return resultado.trim();
}
