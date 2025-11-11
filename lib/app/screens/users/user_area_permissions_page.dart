import 'package:desarrollo_jmas/app/configs/controllers/areas_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/user_area_permisos_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';


class UserAreaPermissionsPage extends StatefulWidget {
  final Users user;

  const UserAreaPermissionsPage({super.key, required this.user});

  @override
  State<UserAreaPermissionsPage> createState() =>
      _UserAreaPermissionsPageState();
}

class _UserAreaPermissionsPageState extends State<UserAreaPermissionsPage> {
  final AreasController _areasController = AreasController();
  final UserAreaPermisosController _permisosController =
      UserAreaPermisosController();

  List<Areas> _allAreas = [];
  List<UserAreaPermisos> _userPermissions = [];
  Map<int, bool> _validarPermissions = {};
  Map<int, bool> _autorizarPermissions = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final areas = await _areasController.listAreas();
      final permissions =
          await _permisosController.getPermisosPorUsuario(widget.user.id_User!);

      setState(() {
        _allAreas = areas;
        _userPermissions = permissions;

        // Inicializar los mapas de permisos
        for (var area in _allAreas) {
          final existingPermission = _userPermissions.firstWhere(
            (p) => p.idArea == area.idArea,
            orElse: () => UserAreaPermisos(
              idUserAreaPermiso: 0,
              apValidar: false,
              apAutorizar: false,
              idUser: widget.user.id_User!,
              idArea: area.idArea,
            ),
          );

          _validarPermissions[area.idArea] = existingPermission.apValidar;
          _autorizarPermissions[area.idArea] = existingPermission.apAutorizar;
        }
      });
    } catch (e) {
      print('Error loading permissions: $e');
      showError(context, 'Error al cargar los permisos');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePermissions() async {
    setState(() => _isSaving = true);

    try {
      bool allSuccess = true;
      int successCount = 0;
      int errorCount = 0;

      for (var area in _allAreas) {
        final existingPermission = _userPermissions.firstWhere(
          (p) => p.idArea == area.idArea,
          orElse: () => UserAreaPermisos(
            idUserAreaPermiso: 0,
            apValidar: false,
            apAutorizar: false,
            idUser: widget.user.id_User!,
            idArea: area.idArea,
          ),
        );

        final newPermission = existingPermission.copyWith(
          apValidar: _validarPermissions[area.idArea] ?? false,
          apAutorizar: _autorizarPermissions[area.idArea] ?? false,
        );

        bool success;
        if (newPermission.idUserAreaPermiso == 0) {
          // Crear nuevo permiso
          print('Creando nuevo permiso para área: ${area.areaNombre}');
          success = await _permisosController.asignarPermiso(newPermission);
        } else {
          // Actualizar permiso existente
          print('Actualizando permiso existente para área: ${area.areaNombre}');
          success = await _updatePermission(newPermission);
        }

        if (success) {
          successCount++;
        } else {
          errorCount++;
          allSuccess = false;
          print('Error guardando permiso para área: ${area.areaNombre}');
        }
      }

      print('Resultado: $successCount éxitos, $errorCount errores');

      // Primero cerramos la página y luego mostramos el mensaje
      if (allSuccess) {
        Navigator.pop(context, true); // Cerrar primero
        // Mostrar mensaje después de cerrar (opcional, puedes quitarlo si prefieres)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOk(context, 'Permisos guardados correctamente');
        });
      } else {
        setState(() => _isSaving = false);
        showError(
            context, 'Error al guardar algunos permisos ($errorCount errores)');
      }
    } catch (e) {
      print('Error saving permissions: $e');
      setState(() => _isSaving = false);
      showError(context, 'Error al guardar los permisos: $e');
    }
  }

  Future<bool> _updatePermission(UserAreaPermisos permiso) async {
    try {
      return await _permisosController.actualizarPermiso(permiso);
    } catch (e) {
      print('Error updating permission: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permisos de Áreas - ${widget.user.user_Name}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _savePermissions,
            tooltip: 'Guardar permisos',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del usuario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue.shade900),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.user_Name ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                Text(
                                  'Contacto: ${widget.user.user_Contacto}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Rol: ${widget.user.user_Rol ?? "Sin rol"}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título de la sección
                  Text(
                    'Asignar Permisos por Área',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lista de áreas con permisos
                  Expanded(
                    child: _allAreas.isEmpty
                        ? const Center(
                            child: Text('No hay áreas disponibles'),
                          )
                        : ListView.builder(
                            itemCount: _allAreas.length,
                            itemBuilder: (context, index) {
                              final area = _allAreas[index];
                              return _buildAreaPermissionCard(area);
                            },
                          ),
                  ),

                  // Botón guardar
                  if (!_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _savePermissions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'GUARDAR PERMISOS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildAreaPermissionCard(Areas area) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del área
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.areaNombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Código: ${area.areaCodigo}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (area.areaDescripcion.isNotEmpty)
                        Text(
                          area.areaDescripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Permisos
            Row(
              children: [
                // Permiso Validar
                Expanded(
                  child: _buildPermissionSwitch(
                    title: 'Validar',
                    subtitle: 'Puede validar en esta área',
                    value: _validarPermissions[area.idArea] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _validarPermissions[area.idArea] = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // Permiso Autorizar
                Expanded(
                  child: _buildPermissionSwitch(
                    title: 'Autorizar',
                    subtitle: 'Puede autorizar en esta área',
                    value: _autorizarPermissions[area.idArea] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _autorizarPermissions[area.idArea] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade900,
          ),
        ],
      ),
    );
  }
}
