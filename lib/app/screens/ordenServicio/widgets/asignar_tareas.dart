// asignar_tareas.dart
import 'package:desarrollo_jmas/app/configs/controllers/orden_servicio_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/padron_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/tipo_problema_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/users_controller.dart';
import 'package:desarrollo_jmas/app/widgets/forms/custom_autocomplete_field.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';


class AsignarTareas {
  static Future<void> mostrarDialogoAsignarServicios({
    required BuildContext context,
    required List<OrdenServicio> ordenesServicios,
    required List<TipoProblema> tiposProblema,
    required List<Padron> padrones,
    required List<Users> usuarios,
    required Function(List<OrdenServicio>, Users) onAsignar,
  }) async {
    final List<OrdenServicio> ordenesSinAsignar =
        ordenesServicios
            .where(
              (orden) =>
                  orden.idUserAsignado == null &&
                  orden.estadoOS != 'Cancelada' &&
                  orden.estadoOS != 'Cerrada',
            )
            .toList();

    if (ordenesSinAsignar.isEmpty) {
      showAdvertence(context, 'No hay órdenes de servicio sin asignar');
      return;
    }

    // Lista para mantener el estado de selección
    final Map<int, bool> seleccionadas = {};
    for (var orden in ordenesSinAsignar) {
      seleccionadas[orden.idOrdenServicio!] = false;
    }

    Users? usuarioSeleccionado;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Asignar Servicios'),
              content: SizedBox(
                width: 800,
                height: 600,
                child: Column(
                  children: [
                    // Buscador de usuario
                    CustomAutocompleteField<Users>(
                      value: usuarioSeleccionado,
                      labelText: 'Buscar Usuario para Asignar',
                      items: usuarios,
                      prefixIcon: Icons.person_search,
                      onChanged: (Users? usuario) {
                        setStateDialog(() {
                          usuarioSeleccionado = usuario;
                        });
                      },
                      itemLabelBuilder:
                          (usuario) =>
                              '${usuario.id_User} - ${usuario.user_Name}',
                      itemValueBuilder: (usuario) => usuario.id_User.toString(),
                    ),
                    const SizedBox(height: 20),

                    // Lista de órdenes sin asignar
                    Expanded(
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text(
                                'Órdenes Sin Asignar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: ordenesSinAsignar.length,
                                  itemBuilder: (context, index) {
                                    final orden = ordenesSinAsignar[index];
                                    final tipoProblema = tiposProblema
                                        .firstWhere(
                                          (tp) =>
                                              tp.idTipoProblema ==
                                              orden.idTipoProblema,
                                          orElse: () => TipoProblema(),
                                        );

                                    final padron = padrones.firstWhere(
                                      (p) => p.idPadron == orden.idPadron,
                                      orElse: () => Padron(),
                                    );

                                    return CheckboxListTile(
                                      title: Text('Folio: ${orden.folioOS}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Problema: ${tipoProblema.nombreTP ?? "N/A"}',
                                          ),
                                          Text(
                                            'Dirección: ${padron.padronDireccion ?? "N/A"}',
                                          ),
                                          Text('Estado: ${orden.estadoOS}'),
                                        ],
                                      ),
                                      value:
                                          seleccionadas[orden
                                              .idOrdenServicio!] ??
                                          false,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          seleccionadas[orden
                                                  .idOrdenServicio!] =
                                              value ?? false;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Seleccionadas: ${seleccionadas.values.where((v) => v).length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Seleccionar todas
                                      setStateDialog(() {
                                        for (var key in seleccionadas.keys) {
                                          seleccionadas[key] = true;
                                        }
                                      });
                                    },
                                    child: const Text('Seleccionar Todas'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    if (usuarioSeleccionado == null) {
                      showAdvertence(context, 'Seleccione un usuario');
                      return;
                    }

                    final ordenesSeleccionadas =
                        seleccionadas.entries
                            .where((entry) => entry.value)
                            .map(
                              (entry) => ordenesSinAsignar.firstWhere(
                                (o) => o.idOrdenServicio == entry.key,
                              ),
                            )
                            .toList();

                    if (ordenesSeleccionadas.isEmpty) {
                      showAdvertence(context, 'Seleccione al menos una orden');
                      return;
                    }

                    Navigator.of(context).pop();
                    onAsignar(ordenesSeleccionadas, usuarioSeleccionado!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                  ),
                  child: const Text(
                    'Asignar Servicios',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
