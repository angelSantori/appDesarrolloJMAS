import 'package:desarrollo_jmas/app/configs/auth/permission_widget.dart';
import 'package:desarrollo_jmas/app/configs/controllers/medio_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListMedios extends StatefulWidget {
  const ListMedios({super.key});

  @override
  State<ListMedios> createState() => _ListMediosState();
}

class _ListMediosState extends State<ListMedios> {
  final MedioController _medioController = MedioController();

  final TextEditingController _searchController = TextEditingController();

  List<Medios> _allMedios = [];
  List<Medios> _filteredMedios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedios();
    _searchController.addListener(_filterMedios);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedios() async {
    setState(() => _isLoading = true);
    try {
      List<Medios> medios = await _medioController.listMedios();

      setState(() {
        _allMedios = medios;
        _filteredMedios = medios;
        _isLoading = false;
      });
    } catch (e) {
      print('Error _loadMedios | ListMedios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterMedios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedios =
          _allMedios.where((medio) {
            final medioNombre = medio.nombreMedio?.toLowerCase() ?? '';

            return medioNombre.contains(query);
          }).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreCNT = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar Medio', textAlign: TextAlign.center),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFielTexto(
                    controller: nombreCNT,
                    labelText: 'Nombre del Medio',
                    validator: (medio) {
                      if (medio == null || medio.isEmpty) {
                        return 'Nombre del medio obligatorio';
                      }
                      return null;
                    },
                    prefixIcon: Icons.text_fields_rounded,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  elevation: 2,
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    if (result == true) {
      final nuevoMedio = Medios(idMedio: 0, nombreMedio: nombreCNT.text);

      final success = await _medioController.addMedio(nuevoMedio);

      if (success) {
        showOk(context, 'Nuevo medio agregado correctamente');
        _loadMedios();
      } else {
        showError(context, 'Error al agregar el nuevo medio');
      }
    }
  }

  Future<void> _showEditDialog(Medios medio) async {
    final formKey = GlobalKey<FormState>();
    final nombreCNT = TextEditingController(text: medio.nombreMedio);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar medio', textAlign: TextAlign.center),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFielTexto(
                    controller: nombreCNT,
                    labelText: 'Nombre del medio',
                    validator: (medio) {
                      if (medio == null || medio.isEmpty) {
                        return 'Nombre del medio obligatorio';
                      }
                      return null;
                    },
                    prefixIcon: Icons.text_fields_rounded,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  elevation: 2,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    if (result == true) {
      final medioEditado = medio.copyWith(
        idMedio: medio.idMedio,
        nombreMedio: nombreCNT.text,
      );

      final success = await _medioController.editMedio(medioEditado);

      if (success) {
        showOk(context, 'Medio actualizado correctamente');
        _loadMedios();
      } else {
        showError(context, 'Error al actualizar el medio');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Medios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: PermissionWidget(
        permission: 'add',
        child: FloatingActionButton(
          onPressed: _showAddDialog,
          backgroundColor: Colors.indigo.shade900,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Buscar Medio',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.indigo.shade900,
                        ),
                      )
                      : _filteredMedios.isEmpty
                      ? const Center(
                        child: Text(
                          'No hay algún tipo de medio que coincidan con la búsqueda',
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredMedios.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final medios = _filteredMedios[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade50, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //  Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.tour_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  //  Información
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //  Nombre
                                        Text(
                                          '${medios.idMedio} - ${medios.nombreMedio ?? 'Sin nombre'}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //  Editar
                                  PermissionWidget(
                                    permission: 'edit',
                                    child: IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                      onPressed: () => _showEditDialog(medios),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
