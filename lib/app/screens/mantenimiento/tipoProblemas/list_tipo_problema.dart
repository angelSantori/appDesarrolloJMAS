import 'package:desarrollo_jmas/app/configs/auth/permission_widget.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTipoProblema extends StatefulWidget {
  const ListTipoProblema({super.key});

  @override
  State<ListTipoProblema> createState() => _ListTipoProblemaState();
}

class _ListTipoProblemaState extends State<ListTipoProblema> {
  final TipoProblemaController _tipoProblemaController =
      TipoProblemaController();

  final TextEditingController _searchController = TextEditingController();

  List<TipoProblema> _allProblemas = [];
  List<TipoProblema> _filteredProblemas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTipoProblemas();
    _searchController.addListener(_filterProblemas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTipoProblemas() async {
    setState(() => _isLoading = true);
    try {
      List<TipoProblema> problemas =
          await _tipoProblemaController.listTipoProblema();

      setState(() {
        _allProblemas = problemas;
        _filteredProblemas = problemas;
        _isLoading = false;
      });
    } catch (e) {
      print('Error _loadTipoProblemas | ListTIpoProblema: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProblemas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProblemas =
          _allProblemas.where((problema) {
            final nombreProblema = problema.nombreTP?.toLowerCase() ?? '';

            return nombreProblema.contains(query);
          }).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Agregar Tipo de Servicio',
              textAlign: TextAlign.center,
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFielTexto(
                    controller: nombreController,
                    labelText: 'Nombre del servicio',
                    validator: (problema) {
                      if (problema == null || problema.isEmpty) {
                        return 'Nombre del servicio obligatorio';
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
      final nuevoProblema = TipoProblema(
        idTipoProblema: 0,
        nombreTP: nombreController.text,
      );

      final success = await _tipoProblemaController.addTipoProblema(
        nuevoProblema,
      );
      if (success) {
        showOk(context, 'Nuevo tipo de problema agregado correctamente');
        _loadTipoProblemas();
      } else {
        showError(context, 'Error al agregar el nuevo tipo de problema');
      }
    }
  }

  Future<void> _showEditDialog(TipoProblema problema) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: problema.nombreTP);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Editar Tipo de Servicio',
              textAlign: TextAlign.center,
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFielTexto(
                    controller: nombreController,
                    labelText: 'Nombre del Servicio',
                    validator: (problema) {
                      if (problema == null || problema.isEmpty) {
                        return 'Nombre del tipo de servicio obligatorio';
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
      final problemaEditado = problema.copyWith(
        idTipoProblema: problema.idTipoProblema,
        nombreTP: nombreController.text,
      );

      final success = await _tipoProblemaController.editTipoProblema(
        problemaEditado,
      );

      if (success) {
        showOk(context, 'Tipo de Servicio actualizado correctamente');
        _loadTipoProblemas();
      } else {
        showError(context, 'Error al actualizar el tipo de Servicio');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista Tipo de Servicios',
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
                labelText: 'Buscar Tipo de Servicio',
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
                      : _filteredProblemas.isEmpty
                      ? const Center(
                        child: Text(
                          'No hay algún tipo de servicios que coincidan con la búsqueda',
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredProblemas.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final problemas = _filteredProblemas[index];

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
                                        //Nombre
                                        Text(
                                          '${problemas.idTipoProblema} - ${problemas.nombreTP ?? 'Sin Nombre'}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                      onPressed:
                                          () => _showEditDialog(problemas),
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
