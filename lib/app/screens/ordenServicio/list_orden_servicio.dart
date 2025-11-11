import 'package:desarrollo_jmas/app/screens/ordenServicio/details_orden_servicio.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/asignar_tareas.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/card_custom.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/ordenes_excel.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/ordenes_pdf.dart';
import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/trabajo_realizado_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/customListaDesplegableTipo.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_numero.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_lista_desplegable.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListOrdenServicio extends StatefulWidget {
  const ListOrdenServicio({super.key});

  @override
  State<ListOrdenServicio> createState() => _ListOrdenServicioState();
}

class _ListOrdenServicioState extends State<ListOrdenServicio> {
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();
  final TipoProblemaController _tipoProblemaController =
      TipoProblemaController();
  final PadronController _padronController = PadronController();
  final MedioController _medioController = MedioController();
  final UsersController _usersController = UsersController();

  final TextEditingController _searchController = TextEditingController();

  List<OrdenServicio> _ordenServicios = [];
  List<OrdenServicio> _filteredOrdenesServicios = [];
  bool _isLoading = true;

  //  Tipo Problema
  List<TipoProblema> _allTipoProblemas = [];
  String? _selectedTipoProblema;

  //Users
  List<Users> _todosLosUsuarios = [];

  //  Medios
  List<Medios> _allMedios = [];
  String? _selectedMedio;

  //  Padron
  final TextEditingController _padronIdController = TextEditingController();
  Padron? _selectedPadron;
  List<Padron> _allPadrones = [];

  // Filtros
  String _searchFolio = '';
  String? _selectedEstado;
  String? _selectedPrioridad;
  DateTimeRange? _fechaRange;

  final List<String> _estados = [
    'Aprobada - A',
    'Cancelada',
    'Cerrada',
    'Completado',
    'Devuelta',
    'Pendiente',
    'Incompleto',
    'Rechazada',
    'Requiere Material',
    'Revisión',
  ];

  final List<String> _prioridades = ["Baja", "Media", "Alta"];

  bool _mostrarCanceladas = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _padronIdController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Obtener las órdenes normalmente
      _ordenServicios = await _ordenServicioController.listOrdenServicio();
      _allTipoProblemas = await _tipoProblemaController.listTipoProblema();
      _allMedios = await _medioController.listMedios();
      _allPadrones = await _padronController.listPadron();
      _todosLosUsuarios = await _usersController.listUsers();

      // Ordenar las órdenes por ID de mayor a menor
      _ordenServicios.sort((a, b) {
        // Asumiendo que idOrdenTrabajo es un entero
        return (b.idOrdenServicio ?? 0).compareTo(a.idOrdenServicio ?? 0);
      });

      _applyFilters();
    } catch (e) {
      print('Error _loadOrdenes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPadronById() async {
    final id = _padronIdController.text.trim();
    if (id.isEmpty) {
      setState(() => _selectedPadron = null);
      _applyFilters();
      return;
    }
    try {
      final padron = await _padronController.getPadronById(int.parse(id));
      setState(() => _selectedPadron = padron);
      _applyFilters();
    } catch (e) {
      setState(() => _selectedPadron = null);
      showAdvertence(context, 'No se encontró padrón con ID: $id');
      _applyFilters();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredOrdenesServicios =
          _ordenServicios.where((orden) {
            // Si no queremos mostrar canceladas y la orden está cancelada, la excluimos
            if (!_mostrarCanceladas && orden.estadoOS == 'Cancelada') {
              return false;
            }

            // Filtro por folio
            if (query.isNotEmpty &&
                !(orden.folioOS ?? '').toLowerCase().contains(query)) {
              return false;
            }

            // Filtro por estado
            if (_selectedEstado != null &&
                _selectedEstado != 'Todos' &&
                orden.estadoOS != _selectedEstado) {
              return false;
            }

            // Filtro por prioridad
            if (_selectedPrioridad != null &&
                _selectedPrioridad != 'Todos' &&
                orden.prioridadOS != _selectedPrioridad) {
              return false;
            }

            // Filtro por medio
            if (_selectedMedio != null &&
                orden.idMedio.toString() != _selectedMedio) {
              return false;
            }

            //  Filtro por tipo de problema
            if (_selectedTipoProblema != null &&
                orden.idTipoProblema.toString() != _selectedTipoProblema) {
              return false;
            }

            //  Filtro por padron
            if (_selectedPadron != null &&
                orden.idPadron != _selectedPadron?.idPadron) {
              return false;
            }

            // Filtro por fecha - CORRECCIÓN AQUÍ
            if (_fechaRange != null && orden.fechaOS != null) {
              try {
                // Parseamos la fecha correctamente
                final parts = orden.fechaOS!.split(' ');
                final dateParts = parts[0].split('/');
                final timeParts = parts[1].split(':');

                final fechaOT = DateTime(
                  int.parse(dateParts[2]), // año
                  int.parse(dateParts[1]), // mes
                  int.parse(dateParts[0]), // día
                  int.parse(timeParts[0]), // hora
                  int.parse(timeParts[1]), // minuto
                );

                // Ajustamos el rango de fechas para incluir todo el día
                final startDate = DateTime(
                  _fechaRange!.start.year,
                  _fechaRange!.start.month,
                  _fechaRange!.start.day,
                );

                final endDate = DateTime(
                  _fechaRange!.end.year,
                  _fechaRange!.end.month,
                  _fechaRange!.end.day,
                  23,
                  59,
                  59,
                );

                if (fechaOT.isBefore(startDate) || fechaOT.isAfter(endDate)) {
                  return false;
                }
              } catch (e) {
                print('Error al parsear fecha: ${orden.fechaOS} - $e');
                return false;
              }
            }

            return true;
          }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaRange = picked;
        _applyFilters();
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchFolio = '';
      _selectedEstado = null;
      _selectedPrioridad = null;
      _selectedMedio = null;
      _selectedTipoProblema = null;
      _fechaRange = null;
      _padronIdController.clear();
      _selectedPadron = null;
      _applyFilters();
    });
  }

  Future<void> _updateSingleOrder(int idOrdenServicio) async {
    try {
      final updatedOrder = await _ordenServicioController.getOrdenServicioXId(
        idOrdenServicio,
      );
      setState(() {
        final index = _ordenServicios.indexWhere(
          (o) => o.idOrdenServicio == idOrdenServicio,
        );
        if (index != -1) {
          _ordenServicios[index] = updatedOrder!;
        }
        _applyFilters(); // Reaplicar filtros para actualizar _filteredOrdenes
      });
    } catch (e) {
      print('Error al actualizar orden individual: $e');
      // Si falla, recargar todo como respaldo
      await _loadData();
    }
  }

  Future<void> _mostrarDialogoReporte() async {
    DateTimeRange? rangoSeleccionado;
    TipoProblema? tipoProblemaSeleccionado;

    // Función para mostrar el diálogo
    void mostrarDialogo() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text('Generar Reporte PDF'),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selector de rango de fechas
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final DateTimeRange? picked =
                                    await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                if (picked != null) {
                                  setStateDialog(() {
                                    rangoSeleccionado = picked;
                                  });
                                }
                              },
                              child: Text(
                                rangoSeleccionado == null
                                    ? 'Seleccionar rango de fechas'
                                    : '${DateFormat('dd/MM/yyyy').format(rangoSeleccionado!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoSeleccionado!.end)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Selector de tipo de problema
                      Row(
                        children: [
                          Expanded(
                            child: CustomListaDesplegableTipo<TipoProblema>(
                              value: tipoProblemaSeleccionado,
                              labelText: 'Tipo de Servicio (opcional)',
                              items: _allTipoProblemas,
                              onChanged: (TipoProblema? newValue) {
                                setStateDialog(() {
                                  tipoProblemaSeleccionado = newValue;
                                });
                              },
                              itemLabelBuilder:
                                  (tp) =>
                                      '${tp.nombreTP ?? 'N/A'} - ${tp.idTipoProblema}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (rangoSeleccionado == null) {
                        showAdvertence(
                          context,
                          'Debe seleccionar un rango de fechas',
                        );
                        return;
                      }

                      Navigator.of(context).pop();
                      await _generarReportePDF(
                        rangoSeleccionado!,
                        tipoProblemaSeleccionado,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                    ),
                    child: const Text(
                      'Generar PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Mostrar el diálogo inicial
    mostrarDialogo();
  }

  Future<void> _generarReportePDF(
    DateTimeRange rangoFechas,
    TipoProblema? tipoProblema,
  ) async {
    try {
      setState(() => _isLoading = true);

      // Filtrar órdenes según el rango de fechas y tipo de problema
      final ordenesFiltradas =
          _ordenServicios.where((orden) {
            if (orden.estadoOS == 'Cancelada') return false;
            if (orden.fechaOS == null) return false;

            try {
              // Parsear la fecha de la orden
              final parts = orden.fechaOS!.split(' ');
              final dateParts = parts[0].split('/');
              final timeParts = parts[1].split(':');

              final fechaOrden = DateTime(
                int.parse(dateParts[2]),
                int.parse(dateParts[1]),
                int.parse(dateParts[0]),
                int.parse(timeParts[0]),
                int.parse(timeParts[1]),
              );

              // Ajustar el rango de fechas
              final startDate = DateTime(
                rangoFechas.start.year,
                rangoFechas.start.month,
                rangoFechas.start.day,
              );

              final endDate = DateTime(
                rangoFechas.end.year,
                rangoFechas.end.month,
                rangoFechas.end.day,
                23,
                59,
                59,
              );

              // Verificar si está en el rango y coincide con el tipo de problema
              final enRango =
                  fechaOrden.isAfter(startDate) && fechaOrden.isBefore(endDate);
              final coincideTipo =
                  tipoProblema == null ||
                  orden.idTipoProblema == tipoProblema.idTipoProblema;

              return enRango && coincideTipo;
            } catch (e) {
              print('Error al parsear fecha: ${orden.fechaOS} - $e');
              return false;
            }
          }).toList();

      if (ordenesFiltradas.isEmpty) {
        showAdvertence(
          context,
          'No hay órdenes que coincidan con los filtros seleccionados',
        );
        return;
      }

      // Generar el PDF
      final pdfBytes = await OrdenesPDF.generarPDFMultiplesOrdenes(
        ordenes: ordenesFiltradas,
        medios: _allMedios,
        tiposProblema: _allTipoProblemas,
        padrones: _allPadrones,
        rangoFechas: rangoFechas,
        tipoProblemaFiltro: tipoProblema,
      );

      // Descargar el PDF
      final fechaActual = DateFormat('ddMMyyyy_HHmmss').format(DateTime.now());
      final nombreArchivo = 'Reporte_Ordenes_Servicio_$fechaActual.pdf';

      await OrdenesPDF.descargarPDF(
        pdfBytes: pdfBytes,
        fileName: nombreArchivo,
      );

      showOk(context, 'Reporte generado exitosamente');
    } catch (e) {
      print('Error al generar reporte PDF: $e');
      showAdvertence(context, 'Error al generar el reporte PDF');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listado de Órdenes de Servicio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: Icon(
              _mostrarCanceladas ? Icons.visibility_off : Icons.visibility,
              color: _mostrarCanceladas ? Colors.red : Colors.white,
            ),
            tooltip:
                _mostrarCanceladas
                    ? 'Ocultar canceladas'
                    : 'Mostrar canceladas',
            onPressed: () {
              setState(() {
                _mostrarCanceladas = !_mostrarCanceladas;
                _applyFilters();
              });
            },
          ),
          if (_searchFolio.isNotEmpty ||
              _selectedEstado != null ||
              _selectedPrioridad != null ||
              _selectedMedio != null ||
              _selectedTipoProblema != null ||
              _selectedPadron != null ||
              _fechaRange != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Limpiar todos los filtros',
              onPressed: _clearAllFilters,
            ),
        ],
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarMenuReportes,
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        tooltip: 'Acciones',
        child: const Icon(Icons.account_tree_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // Buscador de folio
                  Row(
                    children: [
                      //Folio
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _searchController,
                          labelText: 'Buscar por folio',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 20),

                      //  Padron
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _padronIdController,
                          labelText: 'Buscar padrón por ID',
                          prefixIcon: Icons.search,
                          onFieldSubmitted: (value) => _searchPadronById(),
                          trailingIcon:
                              _selectedPadron != null
                                  ? IconButton(
                                    icon: Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _padronIdController.clear();
                                      _selectedPadron = null;
                                      _applyFilters();
                                    },
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 20),

                      //Fecha
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.blue.shade300),
                          ),
                          onPressed: () => _selectDateRange(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _fechaRange == null
                                    ? 'Rango de fechas'
                                    : '${DateFormat('dd/MM/yyyy').format(_fechaRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_fechaRange!.end)}',
                                style: TextStyle(color: Colors.blue.shade900),
                              ),
                              if (_fechaRange != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _fechaRange = null;
                                      _applyFilters();
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      //Prioridad
                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedPrioridad,
                          labelText: 'Prioridad',
                          items: _prioridades,
                          onChanged: (value) {
                            setState(() {
                              _selectedPrioridad = value;
                              _applyFilters();
                            });
                          },
                          trailingIcon:
                              _selectedPrioridad != null
                                  ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _selectedPrioridad = null;
                                      _applyFilters();
                                    },
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 20),

                      //Estado
                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedEstado,
                          labelText: 'Estado',
                          items: _estados,
                          onChanged: (value) {
                            setState(() {
                              _selectedEstado = value;
                              _applyFilters();
                            });
                          },
                          trailingIcon:
                              _selectedEstado != null
                                  ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedEstado = null;
                                        _applyFilters();
                                      });
                                    },
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 20),

                      //Medio
                      Expanded(
                        child: CustomListaDesplegableTipo<Medios>(
                          value:
                              _selectedMedio != null
                                  ? _allMedios.firstWhere(
                                    (medio) =>
                                        medio.idMedio.toString() ==
                                        _selectedMedio,
                                  )
                                  : null,
                          labelText: 'Medio',
                          items: _allMedios,
                          onChanged: (Medios? newMedio) {
                            setState(() {
                              _selectedMedio = newMedio?.idMedio.toString();
                              _applyFilters();
                            });
                          },
                          itemLabelBuilder:
                              (medioLB) =>
                                  '${medioLB.nombreMedio ?? 'N/A'} - (${medioLB.idMedio})',
                          trailingIcon:
                              _selectedMedio != null
                                  ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedMedio = null;
                                        _applyFilters();
                                      });
                                    },
                                    icon: const Icon(Icons.close, size: 18),
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 20),

                      //  Tipo de Problema
                      Expanded(
                        child: CustomListaDesplegableTipo<TipoProblema>(
                          value:
                              _selectedTipoProblema != null
                                  ? _allTipoProblemas.firstWhere(
                                    (tp) =>
                                        tp.idTipoProblema.toString() ==
                                        _selectedTipoProblema,
                                  )
                                  : null,
                          labelText: 'Tipo Servicio',
                          items: _allTipoProblemas,
                          onChanged: (TipoProblema? newProblema) {
                            setState(() {
                              _selectedTipoProblema =
                                  newProblema?.idTipoProblema.toString();
                              _applyFilters();
                            });
                          },
                          itemLabelBuilder:
                              (tp) =>
                                  '${tp.nombreTP ?? 'N/A'} - ${tp.idTipoProblema}',
                          trailingIcon:
                              _selectedTipoProblema != null
                                  ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedTipoProblema = null;
                                        _applyFilters();
                                      });
                                    },
                                  )
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Listado
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue.shade900,
                        ),
                      )
                      : _filteredOrdenesServicios.isEmpty
                      ? const Center(
                        child: Text(
                          'No hay órdenes que coincidan con los filtros',
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 1200
                                  ? 4
                                  : MediaQuery.of(context).size.width > 800
                                  ? 3
                                  : 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: _filteredOrdenesServicios.length,
                        itemBuilder: (context, index) {
                          final orden = _filteredOrdenesServicios[index];

                          // Obtener nombre del tipo de problema
                          final tipoProblema = _allTipoProblemas.firstWhere(
                            (tp) => tp.idTipoProblema == orden.idTipoProblema,
                            orElse: () => TipoProblema(),
                          );

                          final medio = _allMedios.firstWhere(
                            (medio) => medio.idMedio == orden.idMedio,
                            orElse: () => Medios(),
                          );

                          // Obtener datos del padrón
                          final padron = _allPadrones.firstWhere(
                            (p) => p.idPadron == orden.idPadron,
                            orElse: () => Padron(),
                          );

                          return CardCustom(
                            folio: orden.folioOS ?? 'No disponible',
                            prioridad: orden.prioridadOS ?? 'N/A',
                            estado: orden.estadoOS ?? 'N/A',
                            fecha: orden.fechaOS ?? 'No disponible',
                            medio: medio.nombreMedio ?? 'No disponible',
                            problema: tipoProblema.nombreTP ?? 'No disponible',
                            padronInfo:
                                '${padron.padronNombre ?? 'N/A'} (${padron.idPadron ?? ''})',
                            padronDireccion: padron.padronDireccion ?? 'N/A',
                            direccion:
                                padron.padronDireccion ?? 'No disponible',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailsOrdenServicio(
                                        ordenServicio: orden,
                                      ),
                                ),
                              );
                              if (result == true || result != null) {
                                await _updateSingleOrder(
                                  orden.idOrdenServicio!,
                                );
                              }
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuReportes() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade900),
                title: const Text('Generar Reporte PDF'),
                subtitle: const Text('Crear reporte en formato PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoReporte();
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green.shade800),
                title: const Text('Generar Reporte Excel'),
                subtitle: const Text('Crear reporte en formato Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoReporteExcel();
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue.shade900),
                title: const Text('Asignar Servicios'),
                subtitle: const Text('Asignar Servicios'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoAsignarServicios();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoReporteExcel() async {
    DateTimeRange? rangoSeleccionado;
    TipoProblema? tipoProblemaSeleccionado;

    // Función para mostrar el diálogo
    void mostrarDialogo() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text('Generar Reporte Excel'),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selector de rango de fechas
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final DateTimeRange? picked =
                                    await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                if (picked != null) {
                                  setStateDialog(() {
                                    rangoSeleccionado = picked;
                                  });
                                }
                              },
                              child: Text(
                                rangoSeleccionado == null
                                    ? 'Seleccionar rango de fechas'
                                    : '${DateFormat('dd/MM/yyyy').format(rangoSeleccionado!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoSeleccionado!.end)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Selector de tipo de problema
                      Row(
                        children: [
                          Expanded(
                            child: CustomListaDesplegableTipo<TipoProblema>(
                              value: tipoProblemaSeleccionado,
                              labelText: 'Tipo de Servicio (opcional)',
                              items: _allTipoProblemas,
                              onChanged: (TipoProblema? newValue) {
                                setStateDialog(() {
                                  tipoProblemaSeleccionado = newValue;
                                });
                              },
                              itemLabelBuilder:
                                  (tp) =>
                                      '${tp.nombreTP ?? 'N/A'} - ${tp.idTipoProblema}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (rangoSeleccionado == null) {
                        showAdvertence(
                          context,
                          'Debe seleccionar un rango de fechas',
                        );
                        return;
                      }

                      Navigator.of(context).pop();
                      await _generarReporteExcel(
                        rangoSeleccionado!,
                        tipoProblemaSeleccionado,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                    ),
                    child: const Text(
                      'Generar Excel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Mostrar el diálogo inicial
    mostrarDialogo();
  }

  Future<void> _generarReporteExcel(
    DateTimeRange rangoFechas,
    TipoProblema? tipoProblema,
  ) async {
    try {
      setState(() => _isLoading = true);

      // Filtrar órdenes según el rango de fechas y tipo de problema (misma lógica que PDF)
      final ordenesFiltradas =
          _ordenServicios.where((orden) {
            if (orden.estadoOS == 'Cancelada') return false;
            if (orden.fechaOS == null) return false;

            try {
              // Parsear la fecha de la orden
              final parts = orden.fechaOS!.split(' ');
              final dateParts = parts[0].split('/');
              final timeParts = parts[1].split(':');

              final fechaOrden = DateTime(
                int.parse(dateParts[2]),
                int.parse(dateParts[1]),
                int.parse(dateParts[0]),
                int.parse(timeParts[0]),
                int.parse(timeParts[1]),
              );

              // Ajustar el rango de fechas
              final startDate = DateTime(
                rangoFechas.start.year,
                rangoFechas.start.month,
                rangoFechas.start.day,
              );

              final endDate = DateTime(
                rangoFechas.end.year,
                rangoFechas.end.month,
                rangoFechas.end.day,
                23,
                59,
                59,
              );

              // Verificar si está en el rango y coincide con el tipo de problema
              final enRango =
                  fechaOrden.isAfter(startDate) && fechaOrden.isBefore(endDate);
              final coincideTipo =
                  tipoProblema == null ||
                  orden.idTipoProblema == tipoProblema.idTipoProblema;

              return enRango && coincideTipo;
            } catch (e) {
              print('Error al parsear fecha: ${orden.fechaOS} - $e');
              return false;
            }
          }).toList();

      if (ordenesFiltradas.isEmpty) {
        showAdvertence(
          context,
          'No hay órdenes que coincidan con los filtros seleccionados',
        );
        return;
      }

      // Generar el Excel
      await OrdenesExcel.generarExcelMultiplesOrdenes(
        ordenes: ordenesFiltradas,
        medios: _allMedios,
        tiposProblema: _allTipoProblemas,
        padrones: _allPadrones,
        rangoFechas: rangoFechas,
        tipoProblemaFiltro: tipoProblema,
      );

      showOk(context, 'Reporte Excel generado exitosamente');
    } catch (e) {
      print('Error al generar reporte Excel: $e');
      showAdvertence(context, 'Error al generar el reporte Excel');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Agrega esta función en la clase _ListOrdenServicioState
  Future<void> _mostrarDialogoAsignarServicios() async {
    await AsignarTareas.mostrarDialogoAsignarServicios(
      context: context,
      ordenesServicios: _ordenServicios,
      tiposProblema: _allTipoProblemas,
      padrones: _allPadrones,
      usuarios: _todosLosUsuarios,
      onAsignar: _asignarOrdenesAUsuario,
    );
  }

  // Función para cargar usuarios (similar a la de addSalida)
  List<Users> _cargarUsuariosParaAsignacion() {
    return _todosLosUsuarios;
  }

  Future<void> _asignarOrdenesAUsuario(
    List<OrdenServicio> ordenes,
    Users usuario,
  ) async {
    final trabajoRealizadoController = TrabajoRealizadoController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Asignando servicios y creando trabajos...'),
            ],
          ),
        );
      },
    );

    try {
      int exitosas = 0;
      int trabajosCreados = 0;
      List<String> errores = [];

      for (var orden in ordenes) {
        print('🔄 Procesando orden: ${orden.folioOS}');

        // 1. Actualizar la orden de servicio
        final ordenActualizada = orden.copyWith(
          idUserAsignado: usuario.id_User,
          estadoOS: 'Aprobada - A',
        );

        final resultadoOrden = await _ordenServicioController.editOrdenServicio(
          ordenActualizada,
        );

        if (resultadoOrden) {
          exitosas++;
          print('✅ Orden actualizada: ${orden.folioOS}');

          // 2. Crear trabajo realizado
          final nextFolio = await trabajoRealizadoController.getNextTRFolio();
          print('📋 Folio obtenido: $nextFolio');

          if (nextFolio.isNotEmpty) {
            final trabajoRealizado = TrabajoRealizado(
              idTrabajoRealizado: 0,
              idOrdenServicio: orden.idOrdenServicio,
              folioOS: orden.folioOS,
              idUserTR: usuario.id_User,
              estadoTR: 'Pendiente',
              folioTR: nextFolio.replaceAll('"', '').trim(),
              padronNombre: _getPadronNombre(orden.idPadron),
              padronDireccion: _getPadronDireccion(orden.idPadron),
              problemaNombre: _getProblemaNombre(orden.idTipoProblema),
              imagenesCargadas: false,
            );

            // DEBUG: Imprimir el JSON que se enviará
            print('📤 JSON a enviar: ${trabajoRealizado.toJson()}');

            final resultadoTR = await trabajoRealizadoController
                .addTrabajoRealizado2(trabajoRealizado);

            if (resultadoTR != null && resultadoTR.idTrabajoRealizado != null) {
              trabajosCreados++;
              print(
                '✅ Trabajo realizado creado: ${resultadoTR.folioTR} (ID: ${resultadoTR.idTrabajoRealizado})',
              );
            } else {
              final errorMsg = '❌ No se pudo crear TR para ${orden.folioOS}';
              errores.add(errorMsg);
              print(errorMsg);
            }
          } else {
            final errorMsg = '❌ Folio vacío para ${orden.folioOS}';
            errores.add(errorMsg);
            print(errorMsg);
          }

          // Actualizar lista local
          final index = _ordenServicios.indexWhere(
            (o) => o.idOrdenServicio == orden.idOrdenServicio,
          );
          if (index != -1) {
            _ordenServicios[index] = ordenActualizada;
          }
        } else {
          final errorMsg = '❌ Error actualizando orden ${orden.folioOS}';
          errores.add(errorMsg);
          print(errorMsg);
        }
      }

      Navigator.of(context, rootNavigator: true).pop();
      await _loadData();

      // Mostrar resultados detallados
      if (errores.isEmpty) {
        showOk(
          context,
          '✅ Todas las órdenes asignadas exitosamente\n'
          'Órdenes: $exitosas/${ordenes.length}\n'
          'Trabajos: $trabajosCreados/${ordenes.length}\n'
          'Usuario: ${usuario.user_Name}',
        );
      } else {
        showAdvertence(
          context,
          '📊 Resultado parcial:\n'
          'Órdenes asignadas: $exitosas/${ordenes.length}\n'
          'Trabajos creados: $trabajosCreados/${ordenes.length}\n'
          'Errores: ${errores.length}\n'
          '${errores.take(3).join("\n")}'
          '${errores.length > 3 ? "\n... y ${errores.length - 3} más" : ""}',
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('❌ Error crítico al asignar órdenes: $e');
      showAdvertence(context, 'Error crítico: $e');
    }
  }

  // Funciones auxiliares para obtener nombres
  String _getPadronNombre(int? idPadron) {
    if (idPadron == null) return 'N/A';
    final padron = _allPadrones.firstWhere(
      (p) => p.idPadron == idPadron,
      orElse: () => Padron(),
    );
    return padron.padronNombre ?? 'N/A';
  }

  String _getPadronDireccion(int? idPadron) {
    if (idPadron == null) return 'N/A';
    final padron = _allPadrones.firstWhere(
      (p) => p.idPadron == idPadron,
      orElse: () => Padron(),
    );
    return padron.padronDireccion ?? 'N/A';
  }

  String _getProblemaNombre(int? idTipoProblema) {
    if (idTipoProblema == null) return 'N/A';
    final problema = _allTipoProblemas.firstWhere(
      (tp) => tp.idTipoProblema == idTipoProblema,
      orElse: () => TipoProblema(),
    );
    return problema.nombreTP ?? 'N/A';
  }
}
