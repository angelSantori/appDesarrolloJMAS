import 'dart:async';

import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_numero.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/generales.dart';
import 'package:flutter/material.dart';

class BuscarPadronWidgetSalida extends StatefulWidget {
  final TextEditingController idPadronController;
  final PadronController padronController;
  final Padron? selectedPadron;
  final Function(Padron?) onPadronSeleccionado;
  final Function(String) onAdvertencia;

  BuscarPadronWidgetSalida({
    super.key,
    required this.idPadronController,
    required this.padronController,
    required this.selectedPadron,
    required this.onPadronSeleccionado,
    required this.onAdvertencia,
  });

  @override
  State<BuscarPadronWidgetSalida> createState() =>
      _BuscarPadronWidgetSalidaState();
}

class _BuscarPadronWidgetSalidaState extends State<BuscarPadronWidgetSalida> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final TextEditingController _busquedaController = TextEditingController();
  List<Padron> _resultadosBusqueda = [];
  Timer? _debounce;

  final FocusNode _busquedaFocusNode = FocusNode();
  bool _showReults = false;

  @override
  void initState() {
    super.initState();
    _busquedaFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounce?.cancel();
    _busquedaFocusNode.removeListener(_onFocusChange);
    _busquedaFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_busquedaFocusNode.hasFocus) {
      setState(() => _showReults = false);
    }
  }

  Future<void> _buscarPadronXId() async {
    final id = widget.idPadronController.text;
    if (id.isNotEmpty) {
      widget.onPadronSeleccionado(null); // Limpiar el padrón antes de buscar
      _isLoading.value = true; // Iniciar el estado de carga

      try {
        final padronList = await widget.padronController.listPadron();
        final foundPadron = padronList.firstWhere(
          (p) => p.idPadron.toString() == id,
          orElse: () => Padron(),
        );
        if (foundPadron.idPadron != null) {
          widget.onPadronSeleccionado(foundPadron);
        } else {
          widget.onAdvertencia('Padrón con ID: $id, no encontrado');
          widget.idPadronController.clear();
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar el padrón: $e');
      } finally {
        _isLoading.value = false; // Finalizar el estado de carga
      }
    } else {
      widget.onAdvertencia('Por favor, ingrese un ID de padrón.');
    }
  }

  Future<void> _buscarPadron(String query) async {
    try {
      final resultados = await widget.padronController.getBuscar(query);
      setState(() => _resultadosBusqueda = resultados);
    } catch (e) {
      widget.onAdvertencia('Error al buscar padron: $e');
      setState(() => _resultadosBusqueda = []);
    }
  }

  void _onBusquedaChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (query.isNotEmpty) {
          setState(() => _showReults = true);
          _buscarPadron(query);
        } else {
          setState(() {
            _resultadosBusqueda = [];
            _showReults = false;
          });
        }
      },
    );
  }

  void _seleccionarPadron(Padron padron) {
    widget.idPadronController.text = padron.idPadron.toString();
    widget.onPadronSeleccionado(padron);
    setState(() {
      _resultadosBusqueda = [];
      _showReults = false;
      _busquedaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DividerWithText(text: 'Selección de Padrón'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextFielTexto(
                controller: _busquedaController,
                labelText: 'Buscar padron por nombre o dirección',
                onChanged: _onBusquedaChanged,
              ),
            ),
          ],
        ),
        // Resultados de búsqueda
        if (_showReults && _resultadosBusqueda.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 500),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _resultadosBusqueda.length,
              itemBuilder: (context, index) {
                final padron = _resultadosBusqueda[index];
                return ListTile(
                  title: Text(padron.padronNombre ?? 'Sin nombre'),
                  subtitle: Text(padron.padronDireccion ?? 'Sin dirección'),
                  onTap: () => _seleccionarPadron(padron),
                );
              },
            ),
          ),
        const SizedBox(height: 30),
        // Campo para ID del Padrón
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              child: CustomTextFieldNumero(
                controller: widget.idPadronController,
                prefixIcon: Icons.search,
                labelText: 'Id Padrón',
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _buscarPadronXId();
                  }
                },
              ),
            ),
            const SizedBox(width: 15),

            // Botón para buscar padrón
            // ValueListenableBuilder<bool>(
            //   valueListenable: _isLoading,
            //   builder: (context, isLoading, child) {
            //     return ElevatedButton(
            //       onPressed: isLoading ? null : _buscarPadronXId,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: isLoading
            //             ? Colors.grey
            //             : Colors
            //                 .blue.shade900, // Cambiar color si está cargando
            //       ),
            //       child: isLoading
            //           ? const SizedBox(
            //               height: 16,
            //               width: 16,
            //               child: CircularProgressIndicator(
            //                 strokeWidth: 2,
            //                 color: Colors.white,
            //               ),
            //             )
            //           : const Text(
            //               'Buscar padrón',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //     );
            //   },
            // ),
            const SizedBox(width: 15),
            // Información del Padrón
            if (widget.selectedPadron != null &&
                widget.selectedPadron!.idPadron != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Padrón:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Nombre: ${widget.selectedPadron!.padronNombre ?? 'No disponible'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Dirección: ${widget.selectedPadron!.padronDireccion ?? 'No disponible'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                flex: 2,
                child: Text(
                  'No se ha buscado un padrón.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ],
    );
  }
}