import 'package:desarrollo_jmas/app/configs/controllers/areas_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_field_texto.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';


class ListAreasPage extends StatefulWidget {
  const ListAreasPage({super.key});

  @override
  State<ListAreasPage> createState() => _ListAreasPageState();
}

class _ListAreasPageState extends State<ListAreasPage> {
  final AreasController _areasController = AreasController();
  final TextEditingController _searchController = TextEditingController();

  List<Areas> _allAreas = [];
  List<Areas> _filteredAreas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterAreas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final areas = await _areasController.listAreas();

      setState(() {
        _allAreas = areas;
        _filteredAreas = areas;
        _isLoading = false;
      });
    } catch (e) {
      print('Error list_areas_page: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAreas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAreas = _allAreas.where((area) {
        final codigo = area.areaCodigo.toLowerCase();
        final nombre = area.areaNombre.toLowerCase();
        final descripcion = area.areaDescripcion.toLowerCase();
        final estado = area.areaEstado ? 'activo' : 'inactivo';

        return codigo.contains(query) ||
            nombre.contains(query) ||
            descripcion.contains(query) ||
            estado.contains(query);
      }).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final codigoController = TextEditingController();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Área',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: codigoController,
                labelText: 'Código del área',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Código del área obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.code,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del área',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del área obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: descripcionController,
                labelText: 'Descripción',
                prefixIcon: Icons.description,
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
      final nuevaArea = Areas(
        idArea: 0,
        areaCodigo: codigoController.text,
        areaNombre: nombreController.text,
        areaDescripcion: descripcionController.text,
        areaEstado: true,
      );

      final success = await _areasController.addArea(nuevaArea);
      if (success) {
        showOk(context, 'Nueva área agregada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al agregar la nueva área');
      }
    }
  }

  Future<void> _showEditDialog(Areas area) async {
    final formKey = GlobalKey<FormState>();
    final codigoController = TextEditingController(text: area.areaCodigo);
    final nombreController = TextEditingController(text: area.areaNombre);
    final descripcionController =
        TextEditingController(text: area.areaDescripcion);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Área',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: codigoController,
                labelText: 'Código del área',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Código del área obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.code,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del área',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del área obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: descripcionController,
                labelText: 'Descripción',
                prefixIcon: Icons.description,
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
      final areaEditada = area.copyWith(
        idArea: area.idArea,
        areaCodigo: codigoController.text,
        areaNombre: nombreController.text,
        areaDescripcion: descripcionController.text,
      );

      // Aquí necesitarías implementar el método editArea en AreasController
      final success = await _areasController.editArea(areaEditada);

      if (success) {
        showOk(context, 'Área actualizada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al actualizar el área');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Áreas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextFielTexto(
                    controller: _searchController,
                    labelText: 'Buscar por Código, Nombre o Descripción',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                      onPressed: _showAddDialog,
                      tooltip: 'Agregar Área Nueva',
                      iconSize: 30,
                      icon: Icon(
                        Icons.add_box,
                        color: Colors.blue.shade900,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.indigo.shade900,
                      ),
                    )
                  : _filteredAreas.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay áreas que coincidan con la búsqueda',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredAreas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final area = _filteredAreas[index];

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
                                  colors: [
                                    Colors.green.shade50,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Icon
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        Icons.business,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    //Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Código y Nombre
                                          Text(
                                            '${area.areaCodigo} - ${area.areaNombre}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          //Descripción
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.description,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  area.areaDescripcion.isEmpty
                                                      ? 'Sin descripción'
                                                      : area.areaDescripcion,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          //Estado
                                          Row(
                                            children: [
                                              Icon(
                                                area.areaEstado
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size: 16,
                                                color: area.areaEstado
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                area.areaEstado
                                                    ? 'Activo'
                                                    : 'Inactivo',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: area.areaEstado
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.green.shade700,
                                          size: 20,
                                        ),
                                      ),
                                      onPressed: () => _showEditDialog(area),
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
