import 'dart:typed_data';
import 'package:desarrollo_jmas/app/screens/descuentosSociales/details_descuento_social.dart';
import 'package:desarrollo_jmas/app/configs/controllers/descuento_social_pdf_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/descuentos_sociales_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'dart:html' as html;

class ListDescuentoSocial extends StatefulWidget {
  const ListDescuentoSocial({super.key});

  @override
  State<ListDescuentoSocial> createState() => _ListDescuentoSocialState();
}

class _ListDescuentoSocialState extends State<ListDescuentoSocial> {
  final DescuentosSocialesController _controller =
      DescuentosSocialesController();
  final DescuentoSocialPdfController _pdfController =
      DescuentoSocialPdfController();
  final PadronController _padronController = PadronController();

  List<DescuentosSocialesList> _descuentosSociales = [];
  List<DescuentosSocialesList> _descuentosFiltrados = [];
  bool _cargando = true;
  bool _error = false;
  bool _descargandoZip = false;
  bool _generandoExcel = false;
  DateTimeRange? _selectedDateRange;

  // Controladores para los campos de búsqueda
  final TextEditingController _searchFolioController = TextEditingController();
  final TextEditingController _searchCurpController = TextEditingController();
  final TextEditingController _searchIneController = TextEditingController();
  final TextEditingController _searchPadronController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDescuentosSociales();

    // Agregar listeners a los controladores de búsqueda
    _searchFolioController.addListener(_filtrarDescuentos);
    _searchCurpController.addListener(_filtrarDescuentos);
    _searchIneController.addListener(_filtrarDescuentos);
    _searchPadronController.addListener(_filtrarDescuentos);
  }

  @override
  void dispose() {
    _searchFolioController.dispose();
    _searchCurpController.dispose();
    _searchIneController.dispose();
    _searchPadronController.dispose();
    super.dispose();
  }

  Future<void> _cargarDescuentosSociales() async {
    try {
      setState(() {
        _cargando = true;
        _error = false;
      });

      final descuentos = await _controller.listDS();

      // Ordenar por fecha descendente (más nuevo primero)
      descuentos.sort((a, b) => b.dsFecha.compareTo(a.dsFecha));

      setState(() {
        _descuentosSociales = descuentos;
        _descuentosFiltrados = descuentos;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar descuentos sociales: $e');
      setState(() {
        _cargando = false;
        _error = true;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      // Personalización en español
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validar que el rango no sea muy extenso (opcional)
      final difference = picked.end.difference(picked.start).inDays;
      if (difference > 365) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rango muy extenso'),
            content: const Text(
              'El rango seleccionado no puede ser mayor a 1 año.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _filtrarDescuentos() {
    final folio = _searchFolioController.text.toLowerCase().trim();
    final curp = _searchCurpController.text.toLowerCase().trim();
    final ine = _searchIneController.text.toLowerCase().trim();
    final padron = _searchPadronController.text.toLowerCase().trim();

    setState(() {
      _descuentosFiltrados = _descuentosSociales.where((descuento) {
        bool matches = true;

        // Filtrar por folio
        if (folio.isNotEmpty) {
          matches = matches && descuento.dsFolio.toLowerCase().contains(folio);
        }

        // Filtrar por CURP
        if (curp.isNotEmpty) {
          matches = matches && descuento.dsCURP.toLowerCase().contains(curp);
        }

        // Filtrar por número de INE
        if (ine.isNotEmpty) {
          matches =
              matches && descuento.dsNumeroINE.toLowerCase().contains(ine);
        }

        // Filtrar por ID de padrón
        if (padron.isNotEmpty) {
          matches = matches && descuento.idPadron.toString().contains(padron);
        }

        return matches;
      }).toList();

      // Mantener el orden descendente después de filtrar
      _descuentosFiltrados.sort((a, b) => b.dsFecha.compareTo(a.dsFecha));
    });
  }

  void _limpiarBusqueda() {
    _searchFolioController.clear();
    _searchCurpController.clear();
    _searchIneController.clear();
    _searchPadronController.clear();
    setState(() {
      _descuentosFiltrados = List.from(_descuentosSociales)
        ..sort((a, b) => b.dsFecha.compareTo(a.dsFecha));
    });
  }

  Future<void> _verDetalles(DescuentosSocialesList descuentoList) async {
    try {
      // Mostrar loading mientras se cargan los detalles completos
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Obtener los detalles completos con la imagen
      final descuentoCompleto = await _controller.getDSById(
        descuentoList.idDescuentoSocial,
      );

      // Cerrar el loading
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (descuentoCompleto != null) {
        // Navegar a los detalles con la información completa
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailsDescuentoSocial(descuentoSocial: descuentoCompleto),
            ),
          );
        }
      } else {
        if (mounted) {
          showError(context, 'Error al cargar los detalles del descuento');
        }
      }
    } catch (e) {
      // Cerrar el loading si hay error
      if (mounted) {
        Navigator.of(context).pop();
        showError(context, 'Error al cargar los detalles: $e');
      }
    }
  }

  Future<void> _descargarZip() async {
    if (_selectedDateRange == null) {
      showError(context, 'Seleccione un rango de fechas válido');
      return;
    }

    setState(() {
      _descargandoZip = true;
    });

    try {
      final zipBytes = await _pdfController.downloadMultiplePdfsAsZip(
        startDate: _selectedDateRange!.start.toIso8601String(),
        endDate: _selectedDateRange!.end.toIso8601String(),
      );

      if (zipBytes != null && zipBytes.isNotEmpty) {
        // Método para Flutter Web
        final now = DateTime.now();
        final zipFileName =
            'DescuentosSociales_${_formatearFechaParaArchivo(_selectedDateRange!.start)}_${_formatearFechaParaArchivo(_selectedDateRange!.end)}_${_formatearHoraParaArchivo(now)}.zip';
        await _descargarArchivoWeb(zipBytes, zipFileName);
        _mostrarDialogoDescargaExitosa('ZIP');
      } else {
        showError(
          context,
          'No se encontraron PDFs en el rango de fechas seleccionado',
        );
      }
    } catch (e) {
      print('Error al descargar ZIP: $e');
      showError(context, 'Error al descargar el ZIP: $e');
    } finally {
      setState(() {
        _descargandoZip = false;
      });
    }
  }

  Future<void> _generarExcel() async {
    if (_selectedDateRange == null) {
      showError(context, 'Seleccione un rango de fechas válido');
      return;
    }

    setState(() {
      _generandoExcel = true;
    });

    try {
      // Filtrar descuentos sociales por el rango de fechas
      final descuentosFiltrados = _descuentosSociales.where((descuento) {
        return descuento.dsFecha.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            descuento.dsFecha.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();

      if (descuentosFiltrados.isEmpty) {
        showError(context, 'No hay datos en el rango de fechas seleccionado');
        return;
      }

      // Crear el archivo Excel
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Definir estilos
      final Style headerStyle = workbook.styles.add('HeaderStyle');
      headerStyle.backColor = '#4472C4';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 12;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;

      final Style dataStyle = workbook.styles.add('DataStyle');
      dataStyle.fontName = 'Arial';
      dataStyle.fontSize = 10;
      dataStyle.hAlign = HAlignType.left;
      dataStyle.vAlign = VAlignType.center;

      // Configurar cabeceras - AGREGAR COLUMNA "FECHA CADUCIDAD"
      final List<String> headers = [
        'Folio',
        'Fecha',
        'Fecha Caducidad',
        'Nombre Beneficiario',
        'Nombre Cónyugue',
        'Edad',
        'CURP',
        'Teléfono',
        'Razón Descuento',
        'Vivienda',
        'Número INE',
        'Comprobante',
        'ID Padrón',
        'Nombre Padrón',
        'Dirección Padrón',
      ];

      // Escribir cabeceras
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(1, i + 1).cellStyle = headerStyle;
      }

      // Obtener información del padrón para cada descuento
      for (int i = 0; i < descuentosFiltrados.length; i++) {
        final descuento = descuentosFiltrados[i];
        Padron? padronInfo;

        // Obtener información del padrón si está disponible
        if (descuento.idPadron > 0) {
          padronInfo = await _padronController.getPadronById(
            descuento.idPadron,
          );
        }

        // Calcular fecha de caducidad (último día del año en curso)
        final fechaCaducidad = DateTime(DateTime.now().year, 12, 31);

        // Escribir datos - AJUSTAR COLUMNAS POR LA NUEVA COLUMNA AGREGADA
        sheet.getRangeByIndex(i + 2, 1).setText(descuento.dsFolio);
        sheet
            .getRangeByIndex(i + 2, 2)
            .setText(_formatearFecha(descuento.dsFecha));
        // NUEVA COLUMNA: Fecha Caducidad
        sheet
            .getRangeByIndex(i + 2, 3)
            .setText(_formatearFecha(fechaCaducidad));
        sheet.getRangeByIndex(i + 2, 4).setText(descuento.dsNombreBeneficiario);
        sheet.getRangeByIndex(i + 2, 5).setText(descuento.dsNombreConyugue);
        sheet.getRangeByIndex(i + 2, 6).setNumber(descuento.dsEdad.toDouble());
        sheet.getRangeByIndex(i + 2, 7).setText(descuento.dsCURP);
        sheet.getRangeByIndex(i + 2, 8).setText(descuento.dsTelefono);
        sheet.getRangeByIndex(i + 2, 9).setText(descuento.dsRazonDescuento);
        sheet.getRangeByIndex(i + 2, 10).setText(descuento.dsVivienda);
        sheet.getRangeByIndex(i + 2, 11).setText(descuento.dsNumeroINE);
        sheet.getRangeByIndex(i + 2, 12).setText(descuento.dsComprobante ?? '');
        sheet
            .getRangeByIndex(i + 2, 13)
            .setNumber(descuento.idPadron.toDouble());
        sheet
            .getRangeByIndex(i + 2, 14)
            .setText(padronInfo?.padronNombre ?? '');
        sheet
            .getRangeByIndex(i + 2, 15)
            .setText(padronInfo?.padronDireccion ?? '');

        // Aplicar estilo a toda la fila
        for (int j = 1; j <= headers.length; j++) {
          sheet.getRangeByIndex(i + 2, j).cellStyle = dataStyle;
        }
      }

      // Autoajustar columnas
      for (int i = 1; i <= headers.length; i++) {
        sheet.autoFitColumn(i);
      }

      // Convertir a bytes
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Descargar el archivo
      final now = DateTime.now();
      final excelFileName =
          'DescuentosSociales_${_formatearFechaParaArchivo(_selectedDateRange!.start)}_${_formatearFechaParaArchivo(_selectedDateRange!.end)}_${_formatearHoraParaArchivo(now)}.xlsx';
      await _descargarArchivoWeb(Uint8List.fromList(bytes), excelFileName);
      _mostrarDialogoDescargaExitosa('Excel');
    } catch (e) {
      print('Error al generar Excel: $e');
      showError(context, 'Error al generar el Excel: $e');
    } finally {
      setState(() {
        _generandoExcel = false;
      });
    }
  }

  String _formatearFechaParaArchivo(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}${fecha.month.toString().padLeft(2, '0')}${fecha.year}';
  }

  String _formatearHoraParaArchivo(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}${fecha.minute.toString().padLeft(2, '0')}${fecha.second.toString().padLeft(2, '0')}';
  }

  Future<void> _descargarArchivoWeb(Uint8List bytes, String fileName) async {
    try {
      // Crear un blob con los bytes
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Crear un elemento anchor para la descarga
      // ignore: unused_local_variable
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

  void _mostrarDialogoDescargaExitosa(String tipoArchivo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$tipoArchivo Descargado'),
        content: Text(
          'El archivo $tipoArchivo con los datos del ${_formatearFecha(_selectedDateRange!.start)} al ${_formatearFecha(_selectedDateRange!.end)} se ha descargado exitosamente.',
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

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          // Botón para seleccionar rango
          ElevatedButton.icon(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.calendar_today, size: 18),
            label: const Text('Seleccionar Rango de Fechas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // Mostrar rango seleccionado
          if (_selectedDateRange != null) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rango seleccionado:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_formatearFecha(_selectedDateRange!.start)} - ${_formatearFecha(_selectedDateRange!.end)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red.shade600),
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                        });
                      },
                      tooltip: 'Limpiar rango',
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                'No se ha seleccionado un rango de fechas',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListItem(DescuentosSocialesList descuento) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.discount, color: Colors.blue.shade700, size: 30),
        ),
        title: Text(
          'Folio: ${descuento.dsFolio}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Fecha: ${_formatearFecha(descuento.dsFecha)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              'CURP: ${descuento.dsCURP}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              'Beneficiario: ${descuento.dsNombreBeneficiario}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue.shade700,
          size: 16,
        ),
        onTap: () => _verDetalles(descuento),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Widget _buildCampoBusqueda({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            isDense: true,
          ),
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Descuentos Sociales'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          // Campos de búsqueda - SIEMPRE VISIBLES
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                // Primera fila de campos de búsqueda
                Row(
                  children: [
                    _buildCampoBusqueda(
                      controller: _searchFolioController,
                      labelText: 'Buscar por Folio',
                      icon: Icons.confirmation_number,
                    ),
                    _buildCampoBusqueda(
                      controller: _searchCurpController,
                      labelText: 'Buscar por CURP',
                      icon: Icons.badge,
                    ),
                    _buildCampoBusqueda(
                      controller: _searchIneController,
                      labelText: 'Buscar por INE',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                    ),
                    _buildCampoBusqueda(
                      controller: _searchPadronController,
                      labelText: 'Buscar por ID Padrón',
                      icon: Icons.home,
                      keyboardType: TextInputType.number,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _limpiarBusqueda,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Segunda fila de campos de búsqueda
                // Contador de resultados
                if (_descuentosFiltrados.length != _descuentosSociales.length)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_descuentosFiltrados.length} de ${_descuentosSociales.length} resultados',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Selector de rango de fechas
          if (_selectedDateRange != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rango seleccionado:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          '${_formatearFecha(_selectedDateRange!.start)} - ${_formatearFecha(_selectedDateRange!.end)}',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                  // Botón para descargar Excel
                  ElevatedButton(
                    onPressed: _generandoExcel ? null : _generarExcel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                    ),
                    child: _generandoExcel
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.table_chart, size: 18),
                              SizedBox(width: 4),
                              Text('Excel'),
                            ],
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Botón para descargar ZIP
                  ElevatedButton(
                    onPressed: _descargandoZip ? null : _descargarZip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _descargandoZip
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.archive, size: 18),
                              SizedBox(width: 4),
                              Text('ZIP PDFs'),
                            ],
                          ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                    },
                    tooltip: 'Limpiar rango',
                  ),
                ],
              ),
            ),

          // Lista de descuentos sociales
          Expanded(
            child: _cargando
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando descuentos sociales...'),
                      ],
                    ),
                  )
                : _error
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al cargar los datos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Por favor, intente nuevamente',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _cargarDescuentosSociales,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _descuentosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          color: Colors.grey.shade400,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay descuentos sociales registrados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          'Los descuentos sociales aparecerán aquí',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarDescuentosSociales,
                    child: ListView.builder(
                      itemCount: _descuentosFiltrados.length,
                      itemBuilder: (context, index) {
                        final descuento = _descuentosFiltrados[index];
                        return _buildListItem(descuento);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
