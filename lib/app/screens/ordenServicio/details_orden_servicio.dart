//Librerías
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/dialog/cancelacion_dialog.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/dialog/entrevista_dialog.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/dialog/estado_dialog.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/dialog/evaluacion_dialog.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/dialog/reasignar_dialog.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/dialog/revision_dialog.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/sections/entrevista_section.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/sections/estatus_section.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/sections/evaluacion_section.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/sections/info_general_section.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/sections/padron_section.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/widgets/sections/trabajo_realizado_section.dart';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:desarrollo_jmas/app/configs/controllers/entrevista_padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/evaluacion_orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/trabajo_realizado_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';

class DetailsOrdenServicio extends StatefulWidget {
  final OrdenServicio ordenServicio;
  const DetailsOrdenServicio({super.key, required this.ordenServicio});

  @override
  State<DetailsOrdenServicio> createState() => _DetailsOrdenServicioState();
}

class _DetailsOrdenServicioState extends State<DetailsOrdenServicio> {
  final AuthService _authService = AuthService();
  final PadronController _padronController = PadronController();
  final EvaluacionOrdenServicioController _evaluacionOrdenServicioController =
      EvaluacionOrdenServicioController();
  final UsersController _usersController = UsersController();
  final TrabajoRealizadoController _trabajoRealizadoController =
      TrabajoRealizadoController();
  final TipoProblemaController _tipoProblemaController =
      TipoProblemaController();
  final MedioController _medioController = MedioController();
  final EntrevistaPadronController _entrevistaPadronController =
      EntrevistaPadronController();

  List<TipoProblema> _allTipoProblemas = [];
  List<Medios> _allMedios = [];

  Padron? _padron;
  TipoProblema? _problema;
  String? idUser;
  // ignore: unused_field
  Users? _evaluador;
  // ignore: unused_field
  EvaluacionOS? _evaluacionOS;
  List<EvaluacionOS> _evaluaciones = [];
  // ignore: unused_field
  int _currentEvaluacionIndex = 0;
  bool _isLoadingEvaluacion = false;
  List<TrabajoRealizado> _trabajosRealizados = [];
  bool _isLoadingTrabajos = false;
  String? folioTR;
  // ignore: unused_field
  bool _isLoading = false;

  //  Entrevista
  EntrevistaPadron? _entrevista;
  bool _isLoadingEntrevista = false;

  //  User

  List<Users> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
    _loadPadronInfo();
    _loadProblemaInfo();
    _loadData();
    _getUserId();
    _loadEvaluacion();
    _loadTrabajosRealizados();
    _loadFolioTR();
    _loadEntrevista();
  }

  Future<void> _loadEntrevista() async {
    setState(() => _isLoadingEntrevista = true);
    try {
      final entrevistas = await _entrevistaPadronController.getEPxOS(
        widget.ordenServicio.idOrdenServicio!,
      );
      if (entrevistas.isNotEmpty) {
        setState(() => _entrevista = entrevistas.first);
      } else {
        setState(() => _entrevista = null);
      }
    } catch (e) {
      print('Error al cargar entrevista: $e');
    } finally {
      setState(() => _isLoadingEntrevista = false);
    }
  }

  Future<void> _showEntrevistaDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EntrevistaDialog(
          idOrdenServicio: widget.ordenServicio.idOrdenServicio!,
          idUser: idUser!,
          onSuccess: () async {
            await _loadEntrevista();
          },
        );
      },
    );
  }

  Future<Users?> _loadEvaluadorInfo(int? userId) async {
    if (userId == null) return null;

    try {
      return await _usersController.getUserById(userId);
    } catch (e) {
      print('Error al cargar información del evaluador: $e');
      return null;
    }
  }

  Future<void> _loadAllUsers() async {
    try {
      final users = await _usersController.listUsers();
      setState(() => _allUsers = users);
    } catch (e) {
      print('Error al cargar todos los usuarios: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tipoProblemas = await _tipoProblemaController.listTipoProblema();
      final medios = await _medioController.listMedios();
      final users = await _usersController.listUsers();

      setState(() {
        _allTipoProblemas = tipoProblemas;
        _allMedios = medios;
        _allUsers = users;
      });
    } catch (e) {
      print('Error _loadData | DetailsOrdenTRabajo: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFolioTR() async {
    final fetchedFolioTR = await _trabajoRealizadoController.getNextTRFolio();
    setState(() {
      folioTR = fetchedFolioTR;
    });
  }

  Future<void> _loadTrabajosRealizados() async {
    setState(() => _isLoadingTrabajos = true);
    try {
      final trabajos = await _trabajoRealizadoController.getTRXOtID(
        widget.ordenServicio.idOrdenServicio!,
      );
      setState(() => _trabajosRealizados = trabajos);
    } catch (e) {
      print('Error _loadTrabajosRealizados | DetailsOrdenTRabajo: $e');
    } finally {
      setState(() => _isLoadingTrabajos = false);
    }
  }

  Future<void> _loadEvaluacion() async {
    setState(() => _isLoadingEvaluacion = true);
    try {
      final evaluaciones = await _evaluacionOrdenServicioController.listEvXidOS(
        widget.ordenServicio.idOrdenServicio!,
      );
      if (evaluaciones.isNotEmpty) {
        // ignore: unused_local_variable
        final evaluadores = await Future.wait(
          evaluaciones.map((evs) => _loadEvaluadorInfo(evs.idUser)).toList(),
        );

        setState(() {
          _evaluaciones = evaluaciones;
          _currentEvaluacionIndex = 0;
        });
      } else {
        setState(() {
          _evaluaciones = [];
          _currentEvaluacionIndex = 0;
        });
      }
    } catch (e) {
      print('Error al cargar evaluación: $e');
    } finally {
      setState(() => _isLoadingEvaluacion = false);
    }
  }

  Future<void> _loadPadronInfo() async {
    try {
      final padronList = await _padronController.listPadron();
      final foundPadron = padronList.firstWhere(
        (p) => p.idPadron == widget.ordenServicio.idPadron,
        orElse: () => Padron(),
      );
      if (foundPadron.idPadron != null) {
        setState(() {
          _padron = foundPadron;
        });
      }
    } catch (e) {
      print('Error al cargar información del padrón: $e');
    }
  }

  Future<void> _loadProblemaInfo() async {
    try {
      final problemasList = await _tipoProblemaController.listTipoProblema();
      final foundProblema = problemasList.firstWhere(
        (probl) => probl.idTipoProblema == widget.ordenServicio.idTipoProblema,
        orElse: () => TipoProblema(),
      );
      if (foundProblema.idTipoProblema != null) {
        setState(() {
          _problema = foundProblema;
        });
      }
    } catch (e) {
      print('Error al cargar información del problema: $e');
    }
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    setState(() {
      idUser = decodeToken?['Id_User'] ?? '0';
    });
  }

  Future<void> _recargarPagina() async {
    setState(() {
      _isLoadingEvaluacion = true;
      _isLoadingTrabajos = true;
      _isLoadingEntrevista = true;
    });

    try {
      await Future.wait([
        _loadAllUsers(),
        _loadPadronInfo(),
        _loadProblemaInfo(),
        _loadData(),
        _getUserId(),
        _loadEvaluacion(),
        _loadTrabajosRealizados(),
        _loadFolioTR(),
        _loadEntrevista(),
      ]);

      showOk(context, 'Página recargada correctamente');
    } catch (e) {
      print('Error al recargar: $e');
      showError(context, 'Error al recargar los datos');
    } finally {
      setState(() {
        _isLoadingEvaluacion = false;
        _isLoadingTrabajos = false;
        _isLoadingEntrevista = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Detalles: ${widget.ordenServicio.folioOS}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.indigo.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => _recargarPagina(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar página',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera fila con Info General y Estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de Datos Generales (izquierda)
                  Expanded(
                    flex: 1,
                    child: buildInfoCardInfoGeneral(
                      _allTipoProblemas,
                      widget.ordenServicio,
                      _allMedios,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Tarjeta de Estado y descripción a la derecha
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStatusSection(widget.ordenServicio),
                        const SizedBox(height: 4),
                        buildPadronSection(_padron),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildEvaluacionSection()),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildEntrevistaSection()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              buildTrabajosRealizadosSection(
                _isLoadingTrabajos,
                _trabajosRealizados,
                _allUsers,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluacionSection() {
    return EvaluacionSection(
      evaluaciones: _evaluaciones,
      allUsers: _allUsers,
      isLoadingEvaluacion: _isLoadingEvaluacion,
      estadoOS: widget.ordenServicio.estadoOS ?? 'N/A',
      onEvaluar: () => _showEvaluationDialog(context),
      onCancelar: () => _showCancelacionDialog(context),
      onRevisar: () => _showRevisionDialog(context),
      onReasignar: () => _showReasignarDialog(context),
      onCambiarEstado: () => _showEstadoDialog(context),
    );
  }

  Future<void> _showEstadoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EstadoDialog(
          ordenServicio: widget.ordenServicio,
          idUser: idUser!,
          onSuccess: () {
            // Recargar los datos después de cambiar el estado
            _loadEvaluacion();
            _recargarPagina();
          },
        );
      },
    );
  }

  Future<void> _showEvaluationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EvaluacionDialog(
          ordenServicio: widget.ordenServicio,
          idUser: idUser!,
          allUsers: _allUsers,
          trabajoRealizadoController: _trabajoRealizadoController,
          folioTR: folioTR,
          padron: _padron!,
          problema: _problema!,
          onSuccess: () {
            setState(() {
              widget.ordenServicio.estadoOS = 'Aprobada - A';
            });
            // Forzar recarga de la página
            _loadEvaluacion();
            _loadTrabajosRealizados();
            Navigator.pop(context, true);
          },
        );
      },
    );
  }

  Future<void> _showCancelacionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CancelacionDialog(
          ordenServicio: widget.ordenServicio,
          idUser: idUser!,
          onSuccess: () {
            // Actualizar el estado local
            setState(() {
              widget.ordenServicio.estadoOS = 'Cancelada';
            });
            _loadEvaluacion();
            Navigator.pop(context, true);
          },
        );
      },
    );
  }

  Future<void> _showRevisionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RevisionDialog(
          ordenServicio: widget.ordenServicio,
          idUser: idUser!,
          onSuccess: () {
            // Actualizar el estado local basado en la selección
            // El estado real se actualizará después de recargar
            _loadEvaluacion();
            Navigator.pop(context, true);
          },
        );
      },
    );
  }

  Widget _buildEntrevistaSection() {
    return EntrevistaSection(
      entrevista: _entrevista,
      allUsers: _allUsers,
      isLoadingEntrevista: _isLoadingEntrevista,
      estadoOS: widget.ordenServicio.estadoOS ?? 'N/A',
      onRegistrarEntrevista: () => _showEntrevistaDialog(context),
    );
  }

  Future<void> _showReasignarDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReasignacionDialog(
          ordenServicio: widget.ordenServicio,
          idUser: idUser!,
          allUsers: _allUsers,
          trabajoRealizadoController: _trabajoRealizadoController,
          folioTR: folioTR,
          padron: _padron!,
          problema: _problema!,
          onSuccess: () {
            setState(() {
              widget.ordenServicio.estadoOS = 'Aprobada - A';
            });
            _loadEvaluacion();
            _loadTrabajosRealizados();
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
