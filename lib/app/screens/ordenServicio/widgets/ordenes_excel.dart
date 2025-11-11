import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class OrdenesExcel {
  static Future<void> generarExcelMultiplesOrdenes({
    required List<OrdenServicio> ordenes,
    required List<Medios> medios,
    required List<TipoProblema> tiposProblema,
    required List<Padron> padrones,
    required DateTimeRange rangoFechas,
    required TipoProblema? tipoProblemaFiltro,
  }) async {
    try {
      // Crear Excel workbook
      final Workbook workbook = Workbook();

      // Eliminar la hoja por defecto "Sheet1"
      workbook.worksheets.clear();

      // Crear única hoja con el nombre deseado
      final Worksheet sheet = workbook.worksheets.add();
      sheet.name = 'Órdenes de Servicio';

      // Configuración de columnas
      sheet.getRangeByName('A1').columnWidth = 15; // Folio
      sheet.getRangeByName('B1').columnWidth = 20; // Fecha
      sheet.getRangeByName('C1').columnWidth = 25; // Tipo Servicio
      sheet.getRangeByName('D1').columnWidth = 15; // Prioridad
      sheet.getRangeByName('E1').columnWidth = 15; // Estado
      sheet.getRangeByName('F1').columnWidth = 12; // ID Padrón
      sheet.getRangeByName('G1').columnWidth = 30; // Nombre Padrón
      sheet.getRangeByName('H1').columnWidth = 40; // Dirección Padrón
      sheet.getRangeByName('I1').columnWidth = 20; // Contacto
      sheet.getRangeByName('J1').columnWidth = 30; // Comentarios
      sheet.getRangeByName('K1').columnWidth = 15; // Requiere Material
      sheet.getRangeByName('L1').columnWidth = 20; // Medio
      sheet.getRangeByName('M1').columnWidth = 15; // Usuario Asignado

      // Estilos
      final Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#2E5B96';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 11;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;
      headerStyle.borders.all.lineStyle = LineStyle.thin;
      headerStyle.borders.all.color = '#000000';

      final Style titleStyle = workbook.styles.add('titleStyle');
      titleStyle.fontName = 'Arial';
      titleStyle.fontSize = 14;
      titleStyle.bold = true;
      titleStyle.hAlign = HAlignType.center;

      final Style normalStyle = workbook.styles.add('normalStyle');
      normalStyle.fontName = 'Arial';
      normalStyle.fontSize = 10;
      normalStyle.borders.all.lineStyle = LineStyle.thin;
      normalStyle.borders.all.color = '#CCCCCC';

      final Style boldStyle = workbook.styles.add('boldStyle');
      boldStyle.fontName = 'Arial';
      boldStyle.fontSize = 10;
      boldStyle.bold = true;

      final Style infoStyle = workbook.styles.add('infoStyle');
      infoStyle.fontName = 'Arial';
      infoStyle.fontSize = 10;
      infoStyle.bold = true;
      infoStyle.backColor = '#D6E4F0';

      // ===== ENCABEZADO DEL REPORTE =====

      // Título principal
      sheet.getRangeByName('A1:M1').merge();
      sheet
          .getRangeByName('A1')
          .setText('JUNTA MUNICIPAL DE AGUA Y SANEAMIENTO DE MEOQUI');
      sheet.getRangeByName('A1').cellStyle = titleStyle;

      // Subtítulo
      sheet.getRangeByName('A2:M2').merge();
      sheet
          .getRangeByName('A2')
          .setText('REPORTE DE ÓRDENES DE SERVICIO - EXCEL');
      sheet.getRangeByName('A2').cellStyle = titleStyle;

      // Espacio
      sheet.getRangeByName('A3:M3').merge();
      sheet.getRangeByName('A3').setText('');

      // Información del reporte
      sheet.getRangeByName('A4:M4').merge();
      sheet.getRangeByName('A4').setText('INFORMACIÓN DEL REPORTE');
      sheet.getRangeByName('A4').cellStyle = infoStyle;

      // Rango de fechas
      sheet.getRangeByName('A5').setText('Rango de fechas:');
      sheet.getRangeByName('A5').cellStyle = boldStyle;
      sheet.getRangeByName('B5:C5').merge();
      sheet
          .getRangeByName('B5')
          .setText(
            '${DateFormat('dd/MM/yyyy').format(rangoFechas.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas.end)}',
          );
      sheet.getRangeByName('B5').cellStyle = normalStyle;

      // Tipo de servicio
      sheet.getRangeByName('A6').setText('Tipo de servicio:');
      sheet.getRangeByName('A6').cellStyle = boldStyle;
      sheet.getRangeByName('B6:C6').merge();
      sheet
          .getRangeByName('B6')
          .setText(
            tipoProblemaFiltro != null
                ? '${tipoProblemaFiltro.idTipoProblema} - ${tipoProblemaFiltro.nombreTP}'
                : 'Todos',
          );
      sheet.getRangeByName('B6').cellStyle = normalStyle;

      // Total de órdenes
      sheet.getRangeByName('A7').setText('Total de órdenes:');
      sheet.getRangeByName('A7').cellStyle = boldStyle;
      sheet.getRangeByName('B7').setText('${ordenes.length}');
      sheet.getRangeByName('B7').cellStyle = boldStyle;

      // Espacio
      sheet.getRangeByName('A8:M8').merge();
      sheet.getRangeByName('A8').setText('');

      // ===== ENCABEZADOS DE LA TABLA =====
      final List<String> headers = [
        'Folio',
        'Fecha',
        'Tipo Servicio',
        'Prioridad',
        'Estado',
        'ID Padrón',
        'Nombre Padrón',
        'Dirección Padrón',
        'Contacto',
        'Comentarios',
        'Requiere Material',
        'Medio',
        'Usuario Asignado',
      ];

      // Escribir encabezados
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(9, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(9, i + 1).cellStyle = headerStyle;
      }

      // ===== DATOS DE LAS ÓRDENES =====
      int rowIndex = 10;

      for (final orden in ordenes) {
        final tipoProblema = tiposProblema.firstWhere(
          (tp) => tp.idTipoProblema == orden.idTipoProblema,
          orElse: () => TipoProblema(),
        );

        final padron = padrones.firstWhere(
          (p) => p.idPadron == orden.idPadron,
          orElse: () => Padron(),
        );

        final medio = medios.firstWhere(
          (m) => m.idMedio == orden.idMedio,
          orElse: () => Medios(),
        );

        // Datos de la fila
        final rowData = [
          orden.folioOS ?? 'N/A',
          orden.fechaOS ?? 'N/A',
          tipoProblema.nombreTP ?? 'N/A',
          orden.prioridadOS ?? 'N/A',
          orden.estadoOS ?? 'N/A',
          padron.idPadron?.toString() ?? 'N/A',
          padron.padronNombre ?? 'N/A',
          padron.padronDireccion ?? 'N/A',
          orden.contactoOS ?? 'N/A',
          orden.comentarioOS ?? 'N/A',
          orden.materialOS == true ? 'Sí' : 'No',
          medio.nombreMedio ?? 'N/A',
          orden.idUserAsignado?.toString() ?? 'N/A',
        ];

        // Escribir datos en la fila
        for (int i = 0; i < rowData.length; i++) {
          final cell = sheet.getRangeByIndex(rowIndex, i + 1);
          cell.setText(rowData[i].toString());
          cell.cellStyle = normalStyle;

          // Alinear numéricos a la derecha
          if (i == 5 || i == 12) {
            // ID Padrón y Usuario Asignado
            cell.cellStyle.hAlign = HAlignType.right;
          }
        }

        rowIndex++;
      }

      // ===== PIE DEL REPORTE =====
      sheet.getRangeByName('A${rowIndex + 1}:M${rowIndex + 1}').merge();
      sheet.getRangeByName('A${rowIndex + 1}').setText('');

      sheet.getRangeByName('A${rowIndex + 2}:M${rowIndex + 2}').merge();
      sheet
          .getRangeByName('A${rowIndex + 2}')
          .setText(
            'Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          );
      final Style footerStyle = workbook.styles.add('footerStyle');
      footerStyle.fontName = 'Arial';
      footerStyle.fontSize = 9;
      footerStyle.italic = true;
      footerStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('A${rowIndex + 2}').cellStyle = footerStyle;

      // ===== GUARDAR Y DESCARGAR =====
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Reporte_Ordenes_Servicio_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

      final blob = html.Blob([
        bytes,
      ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error al generar Excel: $e');
      throw Exception('Error al generar el archivo Excel: $e');
    }
  }
}
