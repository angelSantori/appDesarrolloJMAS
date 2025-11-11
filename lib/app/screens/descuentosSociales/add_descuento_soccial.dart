import 'package:desarrollo_jmas/app/screens/descuentosSociales/widgets/ds_pdf.dart';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:desarrollo_jmas/app/configs/controllers/descuentos_sociales_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_autocomplete_field.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_numero.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_lista_desplegable.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class DescuentosSocialesForm extends StatefulWidget {
  const DescuentosSocialesForm({super.key});

  @override
  State<DescuentosSocialesForm> createState() => _DescuentosSocialesFormState();
}

class _DescuentosSocialesFormState extends State<DescuentosSocialesForm> {
  final _formKey = GlobalKey<FormState>();
  final _padronController = PadronController();
  final _dsController = DescuentosSocialesController();
  final _authService = AuthService();

  // Controladores para los campos
  final TextEditingController _idPadronController = TextEditingController();
  final TextEditingController _nombreBeneficiarioController =
      TextEditingController();
  final TextEditingController _nombreConyugueController =
      TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _numeroINEController = TextEditingController();

  // Controladores para campos "Otro"
  final TextEditingController _otroViviendaController = TextEditingController();
  final TextEditingController _otroComprobanteController =
      TextEditingController();

  // Variables de estado
  int? _selectedPadronId;
  String? _selectedRazonDescuento;
  String? _selectedVivienda;
  String? _selectedComprobante;
  String? _imagenBase64;
  Uint8List? _imagenBytes;
  String? _nombreArchivo;
  String? _selectedPadron;
  List<Padron> _padrones = [];
  Padron? _padronSeleccionado;

  bool _dataLoaded = false;

  // Listas para los dropdowns
  final List<String> _razonesDescuento = [
    'Edad',
    'Jubilación',
    'Cesantía',
    'Invalidez'
  ];
  final List<String> _tiposVivienda = ['Propia', 'Rentada', 'Prestada', 'Otro'];
  final List<String> _tiposComprobante = [
    'INE',
    'INAPAM',
    'Jubilación',
    'Pensión',
    'Discapacidad',
    'Otro'
  ];

  // Variables de validación de secciones
  bool _seccion1Completa = false;
  bool _seccion2Completa = false;
  bool _seccion3Completa = false;
  bool _seccion4Completa = false;
  bool _seccion5Completa = false;

  // Variables para controlar la visibilidad de campos "Otro"
  bool _mostrarOtroVivienda = false;
  bool _mostrarOtroComprobante = false;

  // Variable para controlar el guardado
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _idPadronController.addListener(_validarSeccion1);
    _nombreBeneficiarioController.addListener(_validarSeccion2);
    _nombreConyugueController.addListener(_validarSeccion2);
    _edadController.addListener(_validarSeccion2);
    _curpController.addListener(_validarSeccion2);
    _telefonoController.addListener(_validarSeccion2);
    _numeroINEController.addListener(_validarSeccion5);

    // Listeners para campos "Otro"
    _otroViviendaController.addListener(_validarSeccion4);
    _otroComprobanteController.addListener(_validarSeccion5);

    _curpController.addListener(_convertirCURPAutomaticamente);
    _telefonoController.addListener(_limpiarTelefonoAutomaticamente);

    _loadData();
  }

  @override
  void dispose() {
    _idPadronController.dispose();
    _nombreBeneficiarioController.dispose();
    _nombreConyugueController.dispose();
    _edadController.dispose();
    _curpController.dispose();
    _telefonoController.dispose();
    _numeroINEController.dispose();
    _otroViviendaController.dispose();
    _otroComprobanteController.dispose();
    super.dispose();
  }

  // Método para obtener el valor final de vivienda
  String get _valorViviendaFinal {
    if (_selectedVivienda == 'Otro') {
      return _otroViviendaController.text.trim().isEmpty
          ? 'No especificado'
          : _otroViviendaController.text.trim();
    }
    return _selectedVivienda ?? 'No especificado';
  }

  // Método para obtener el valor final de comprobante
  String get _valorComprobanteFinal {
    if (_selectedComprobante == 'Otro') {
      return _otroComprobanteController.text.trim().isEmpty
          ? 'No especificado'
          : _otroComprobanteController.text.trim();
    }
    return _selectedComprobante ?? 'No especificado';
  }

  Future<void> _loadData() async {
    if (_dataLoaded) return; // Evitar recargas múltiples

    try {
      final padrones = await _padronController.listPadron();
      setState(() {
        _padrones = padrones;
        _dataLoaded = true; // Marcar como cargado
      });
    } catch (e) {
      print('Error _loadData | DescuentosSocialesForm: $e');
    }
  }

  void _convertirCURPAutomaticamente() {
    final value = _curpController.text;
    if (value.isNotEmpty && value != value.toUpperCase()) {
      final newValue = value.toUpperCase();
      // Usar un pequeño delay para evitar ciclos de renderizado
      Future.microtask(() {
        if (_curpController.text == value) {
          // Solo si no ha cambiado
          _curpController.value = _curpController.value.copyWith(
            text: newValue,
            selection: TextSelection.collapsed(offset: newValue.length),
          );
          _validarSeccion2(); // Revalidar después del cambio
        }
      });
    }
  }

  void _limpiarTelefonoAutomaticamente() {
    final value = _telefonoController.text;
    final soloNumeros = value.replaceAll(RegExp(r'[^\d]'), '');
    if (value.isNotEmpty && soloNumeros != value) {
      Future.microtask(() {
        if (_telefonoController.text == value) {
          // Solo si no ha cambiado
          _telefonoController.value = _telefonoController.value.copyWith(
            text: soloNumeros,
            selection: TextSelection.collapsed(offset: soloNumeros.length),
          );
          _validarSeccion2(); // Revalidar después del cambio
        }
      });
    }
  }

  void _validarSeccion1() {
    final bool valida = _selectedPadronId != null && _selectedPadronId! > 0;
    if (_seccion1Completa != valida) {
      setState(() {
        _seccion1Completa = valida;
      });
    }
  }

  void _validarSeccion2() {
    // Forzar validación del formulario
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
    }

    final bool nombreValido = _nombreBeneficiarioController.text.isNotEmpty;
    final bool conyugueValido = _nombreConyugueController.text.isNotEmpty;
    final bool edadValida = _edadController.text.isNotEmpty &&
        int.tryParse(_edadController.text) != null;
    final bool curpValida = _validarCURP(_curpController.text) == null;
    final bool telefonoValido =
        _validarTelefono(_telefonoController.text) == null;

    final bool valida = nombreValido &&
        conyugueValido &&
        edadValida &&
        curpValida &&
        telefonoValido;

    if (_seccion2Completa != valida) {
      setState(() {
        _seccion2Completa = valida;
      });
    }
  }

  void _validarSeccion3() {
    // Forzar validación del formulario primero
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
    }

    final bool valida = _selectedRazonDescuento != null;
    if (_seccion3Completa != valida) {
      setState(() {
        _seccion3Completa = valida;
      });
    }
  }

  void _validarSeccion4() {
    // Forzar validación del formulario primero
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
    }

    final bool valida = _selectedVivienda != null &&
        (_selectedVivienda != 'Otro' ||
            _otroViviendaController.text.isNotEmpty);

    if (_seccion4Completa != valida) {
      setState(() {
        _seccion4Completa = valida;
      });
    }
  }

  void _validarSeccion5() {
    // Forzar validación del formulario primero
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
    }

    final bool validaComprobante = _selectedComprobante != null &&
        (_selectedComprobante != 'Otro' ||
            _otroComprobanteController.text.isNotEmpty);

    final bool valida =
        _numeroINEController.text.isNotEmpty && validaComprobante;

    if (_seccion5Completa != valida) {
      setState(() {
        _seccion5Completa = valida;
      });
    }
  }

  void _limpiarErrores() {
    if (_formKey.currentState != null) {
      // Esto fuerza a que los validadores se ejecuten nuevamente
      _formKey.currentState!.validate();
    }
  }

  bool get _formularioCompleto {
    return _seccion1Completa &&
        _seccion2Completa &&
        _seccion3Completa &&
        _seccion4Completa &&
        _seccion5Completa &&
        _imagenBase64 != null;
  }

  Future<void> _seleccionarImagen() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _imagenBytes = bytes;
            _imagenBase64 = base64Image;
            _nombreArchivo = image.name;
          });
          _validarSeccion5();
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      showError(context, 'Error al seleccionar imagen: $e');
    }
  }

  Future<void> _guardarDescuentoSocial() async {
    if (!_formularioCompleto) {
      showError(context, 'Por favor complete todos los campos requeridos');
      return;
    }

    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        showError(context, 'No se pudo obtener la información del usuario');
        setState(() {
          _guardando = false;
        });
        return;
      }

      // Crear objeto sin folio (se generará en el back-end)
      final descuentoSocial = DescuentosSociales(
        idDescuentoSocial: 0,
        dsFolio: '', // Se generará en el back-end
        dsFecha: DateTime.now(),
        dsNombreBeneficiario: _nombreBeneficiarioController.text,
        dsNombreConyugue: _nombreConyugueController.text,
        dsEdad: int.parse(_edadController.text),
        dsCURP: _curpController.text,
        dsTelefono: _telefonoController.text,
        dsRazonDescuento: _selectedRazonDescuento!,
        dsVivienda: _valorViviendaFinal, // Usar el valor final
        dsNumeroINE: _numeroINEController.text,
        dsComprobante: _valorComprobanteFinal, // Usar el valor final
        dsImgDocBase64: _imagenBase64!,
        idUser: userData.id_User!,
        idPadron: _selectedPadronId!,
      );

      // Guardar y obtener el objeto con el folio generado
      final descuentoGuardado = await _dsController.addDS(descuentoSocial);

      if (descuentoGuardado != null) {
        // Usar el folio generado por el back-end para el PDF
        await _generarPDF(
            descuentoGuardado.dsFolio, userData.user_Name ?? 'Usuario');

        showOk(context,
            'Descuento social guardado exitosamente\nFolio: ${descuentoGuardado.dsFolio}\nPDF generado automáticamente');
        _limpiarFormulario();
      } else {
        showError(context, 'Error al guardar el descuento social');
      }
    } catch (e) {
      showError(context, 'Error: $e');
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  Future<void> _generarPDF(String folio, String userName) async {
    try {
      if (_padronSeleccionado == null) {
        print('Error: No hay padrón seleccionado para generar PDF');
        return;
      }

      await generarGuardarYDescargarPDF(
        folioDS: folio,
        fechaDS: DateTime.now().toIso8601String(),
        nombreBeneficiario: _nombreBeneficiarioController.text,
        nombreConyugue: _nombreConyugueController.text,
        edad: int.parse(_edadController.text),
        curp: _curpController.text,
        telefono: _telefonoController.text,
        razonDescuento: _selectedRazonDescuento!,
        tipoVivienda: _valorViviendaFinal, // Usar el valor final
        numeroINE: _numeroINEController.text,
        tipoComprobante: _valorComprobanteFinal, // Usar el valor final
        nombrePadron: _padronSeleccionado!.padronNombre ?? 'No disponible',
        direccionPadron:
            _padronSeleccionado!.padronDireccion ?? 'No disponible',
        userName: userName,
        selectedPadronId: _selectedPadronId!,
      );

      print('PDF generado exitosamente: $folio');
    } catch (e) {
      print('Error al generar PDF: $e');
      // Mostrar mensaje de error pero no interrumpir el flujo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _idPadronController.clear();
      _nombreBeneficiarioController.clear();
      _nombreConyugueController.clear();
      _edadController.clear();
      _curpController.clear();
      _telefonoController.clear();
      _numeroINEController.clear();
      _otroViviendaController.clear();
      _otroComprobanteController.clear();
      _selectedPadronId = null;
      _selectedPadron = null;
      _selectedRazonDescuento = null;
      _selectedVivienda = null;
      _selectedComprobante = null;
      _imagenBase64 = null;
      _imagenBytes = null;
      _nombreArchivo = null;
      _padronSeleccionado = null;
      _mostrarOtroVivienda = false;
      _mostrarOtroComprobante = false;
      _seccion1Completa = false;
      _seccion2Completa = false;
      _seccion3Completa = false;
      _seccion4Completa = false;
      _seccion5Completa = false;
    });
  }

  String? _validarCURP(String? value) {
    if (value == null || value.isEmpty) {
      return 'La CURP es requerida';
    }

    if (value.length != 18) {
      return 'La CURP debe tener exactamente 18 caracteres';
    }

    // Validar formato básico de CURP (versión más flexible)
    final curpRegex = RegExp(r'^[A-Z]{4}\d{6}[A-Z]{6}[A-Z0-9]{2}$');
    if (!curpRegex.hasMatch(value)) {
      return 'Formato de CURP inválido';
    }

    return null;
  }

  String? _validarTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    if (value.length != 10) {
      return 'El teléfono debe tener exactamente 10 dígitos';
    }

    final telefonoRegex = RegExp(r'^\d{10}$');
    if (!telefonoRegex.hasMatch(value)) {
      return 'Solo se permiten números';
    }

    // Validar que el primer dígito sea válido (1-9)
    if (!RegExp(r'^[1-9]').hasMatch(value)) {
      return 'El teléfono debe comenzar con un dígito del 1 al 9';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Descuento Social'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección 1: Datos del recibo
              _buildSeccion(
                titulo:
                    'Sección 1: Datos del recibo en el que se aplica el descuento',
                completada: _seccion1Completa,
                contenido: _buildSeccion1(),
              ),
              const SizedBox(height: 24),

              // Layout horizontal para secciones 2, 3, 4 y 5
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna izquierda - Sección 2
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.415,
                      ),
                      child: _buildSeccion(
                        titulo: 'Sección 2: Datos del usuario beneficiado',
                        completada: _seccion2Completa,
                        habilitada: _seccion1Completa,
                        contenido: _buildSeccion2(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Columna derecha - Secciones 3, 4 y 5
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Sección 3
                        _buildSeccion(
                          titulo: 'Sección 3: Se otorga el descuento por',
                          completada: _seccion3Completa,
                          habilitada: _seccion2Completa,
                          contenido: _buildSeccion3(),
                        ),
                        const SizedBox(height: 16),

                        // Sección 4
                        _buildSeccion(
                          titulo: 'Sección 4: La vivienda es',
                          completada: _seccion4Completa,
                          habilitada: _seccion3Completa,
                          contenido: _buildSeccion4(),
                        ),
                        const SizedBox(height: 16),

                        // Sección 5
                        _buildSeccion(
                          titulo:
                              'Sección 5: Documento o comprobante que se presenta para acreditación',
                          completada: _seccion5Completa,
                          habilitada: _seccion4Completa,
                          contenido: _buildSeccion5(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Área para subir imagen (fuera del layout horizontal)
              if (_seccion5Completa && _imagenBase64 == null)
                _buildAreaSubirImagen(),
              if (_seccion5Completa && _imagenBase64 != null)
                _buildAreaSubirImagen(),

              const SizedBox(height: 32),

              // Botón guardar
              Center(
                child: ElevatedButton(
                  onPressed: _formularioCompleto && !_guardando
                      ? _guardarDescuentoSocial
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _formularioCompleto && !_guardando
                        ? Colors.blue.shade900
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _guardando
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Guardando...'),
                          ],
                        )
                      : const Text('Guardar Descuento Social'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required bool completada,
    required Widget contenido,
    bool habilitada = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habilitada ? Colors.white : Colors.grey.shade100,
        border: Border.all(
          color: completada ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completada ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completada ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: habilitada ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IgnorePointer(
            ignoring: !habilitada,
            child: AnimatedOpacity(
              opacity: habilitada ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: contenido,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSubirImagen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _imagenBase64 != null ? Colors.green : Colors.blue.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subir Imagen del Comprobante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Botón grande y estilizado para subir imagen
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(
                color: Colors.blue.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: _seleccionarImagen,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Haz clic para subir imagen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Formatos: JPG, PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Vista previa de la imagen
          if (_imagenBytes != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Vista previa:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Archivo: $_nombreArchivo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.memory(
                    _imagenBytes!,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _seleccionarImagen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cambiar Imagen'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeccion1() {
    return Column(
      children: [
        CustomAutocompleteField<Padron>(
          value: _selectedPadron != null
              ? _padrones.firstWhere(
                  (padron) => padron.idPadron.toString() == _selectedPadron,
                  orElse: () => Padron(idPadron: 0, padronNombre: 'N/A'),
                )
              : null,
          labelText: 'Buscar Padron',
          items: _padrones,
          prefixIcon: Icons.search,
          onChanged: (Padron? newValue) {
            setState(() {
              _selectedPadron = newValue?.idPadron.toString();
              _selectedPadronId = newValue?.idPadron;
              _padronSeleccionado = newValue;
            });
            _validarSeccion1();
          },
          itemLabelBuilder: (padron) =>
              '${padron.idPadron ?? 0} - ${padron.padronNombre ?? 'N/A'}',
          itemValueBuilder: (padron) => padron.idPadron.toString(),
        ),
        if (_selectedPadronId != null) ...[
          const SizedBox(height: 16),
          FutureBuilder<Padron?>(
            future: _padronController.getPadronById(_selectedPadronId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasData && snapshot.data != null) {
                final padron = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre: ${padron.padronNombre ?? 'No disponible'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Dirección: ${padron.padronDireccion ?? 'No disponible'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }
              return const Text('No se encontró información del padrón');
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSeccion2() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFielTexto(
                controller: _nombreBeneficiarioController,
                labelText: 'Nombre del beneficiario',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del beneficiario es requerido';
                  }
                  return null;
                },
                onChanged: (value) => _validarSeccion2(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: CustomTextFielTexto(
                controller: _nombreConyugueController,
                labelText: 'Nombre Esposo(a)',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del esposo(a) es requerido';
                  }
                  return null;
                },
                onChanged: (value) => _validarSeccion2(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: CustomTextFieldNumero(
                controller: _edadController,
                labelText: 'Edad',
                prefixIcon: Icons.cake,
                isDecimal: false,
                allowNegative: false,
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La edad es requerida';
                  }
                  final edad = int.tryParse(value);
                  if (edad == null || edad < 1 || edad > 120) {
                    return 'Edad inválida (1-120)';
                  }
                  return null;
                },
                onChanged: (value) => _validarSeccion2(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: CustomTextFielTexto(
                controller: _curpController,
                labelText: 'CURP',
                prefixIcon: Icons.badge,
                maxLength: 18,
                autoUppercase: true,
                noSpaces: true,
                validator: _validarCURP,
                onChanged: (value) => _validarSeccion2(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: CustomTextFieldNumero(
                controller: _telefonoController,
                labelText: 'Teléfono',
                prefixIcon: Icons.phone,
                isDecimal: false,
                allowNegative: false,
                maxLength: 10,
                validator: _validarTelefono,
                onChanged: (value) => _validarSeccion2(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccion3() {
    return Row(
      children: [
        Expanded(
          child: CustomListaDesplegable(
            value: _selectedRazonDescuento,
            labelText: 'Seleccione la razón del descuento',
            items: _razonesDescuento,
            onChanged: (String? value) {
              setState(() {
                _selectedRazonDescuento = value;
              });
              // Forzar revalidación del formulario
              if (_formKey.currentState != null) {
                _formKey.currentState!.validate();
              }
              _validarSeccion3();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Seleccione una razón de descuento';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeccion4() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomListaDesplegable(
                value: _selectedVivienda,
                labelText: 'Seleccione el tipo de vivienda',
                items: _tiposVivienda,
                onChanged: (String? value) {
                  setState(() {
                    _selectedVivienda = value;
                    _mostrarOtroVivienda = value == 'Otro';
                    if (value != 'Otro') {
                      _otroViviendaController.clear();
                    }
                  });
                  // Forzar revalidación del formulario
                  if (_formKey.currentState != null) {
                    _formKey.currentState!.validate();
                  }
                  _validarSeccion4();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione el tipo de vivienda';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        if (_mostrarOtroVivienda) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextFielTexto(
                  controller: _otroViviendaController,
                  labelText: 'Especifique el tipo de vivienda',
                  prefixIcon: Icons.home_work,
                  validator: (value) {
                    if (_selectedVivienda == 'Otro' &&
                        (value == null || value.isEmpty)) {
                      return 'Por favor especifique el tipo de vivienda';
                    }
                    return null;
                  },
                  onChanged: (value) => _validarSeccion4(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSeccion5() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFieldNumero(
                controller: _numeroINEController,
                labelText: 'Número de INE',
                prefixIcon: Icons.credit_card,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El número de INE es requerido';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Forzar revalidación del formulario
                  if (_formKey.currentState != null) {
                    _formKey.currentState!.validate();
                  }
                  _validarSeccion5();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomListaDesplegable(
                value: _selectedComprobante,
                labelText: 'Tipo de comprobante',
                items: _tiposComprobante,
                onChanged: (String? value) {
                  setState(() {
                    _selectedComprobante = value;
                    _mostrarOtroComprobante = value == 'Otro';
                    if (value != 'Otro') {
                      _otroComprobanteController.clear();
                    }
                  });
                  // Forzar revalidación del formulario
                  if (_formKey.currentState != null) {
                    _formKey.currentState!.validate();
                  }
                  _validarSeccion5();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione el tipo de comprobante';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        if (_mostrarOtroComprobante) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextFielTexto(
                  controller: _otroComprobanteController,
                  labelText: 'Especifique el tipo de comprobante',
                  prefixIcon: Icons.description,
                  validator: (value) {
                    if (_selectedComprobante == 'Otro' &&
                        (value == null || value.isEmpty)) {
                      return 'Por favor especifique el tipo de comprobante';
                    }
                    return null;
                  },
                  onChanged: (value) => _validarSeccion5(),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Nota: Después de completar esta sección, podrás subir la imagen del comprobante',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
