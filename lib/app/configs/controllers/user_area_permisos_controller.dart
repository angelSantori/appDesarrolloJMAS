import 'dart:convert';
import 'package:desarrollo_jmas/app/configs/controllers/areas_controller.dart';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class UserAreaPermisosController {
  final AuthService _authService = AuthService();

  Future<List<UserAreaPermisos>> getPermisosPorUsuario(int idUser) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/UserAreaPermisos/PorUsuario/$idUser'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((permiso) => UserAreaPermisos.fromMap(permiso))
            .toList();
      } else {
        print(
          'Error al obtener permisos: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }

  Future<bool> validarPermiso(
    int idUser,
    String codigoArea,
    String tipoPermiso,
  ) async {
    try {
      // Primero obtener el idArea basado en el código
      final areasController = AreasController();
      final areas = await areasController.listAreas();
      final area = areas.firstWhere(
        (a) => a.areaCodigo == codigoArea,
        orElse: () => Areas(
          idArea: 0,
          areaCodigo: '',
          areaNombre: '',
          areaDescripcion: '',
          areaEstado: false,
        ),
      );

      if (area.idArea == 0) return false;

      // Obtener los permisos del usuario para esta área
      final permisos = await getPermisosPorUsuario(idUser);
      final permisoArea = permisos.firstWhere(
        (p) => p.idArea == area.idArea,
        orElse: () => UserAreaPermisos(
          idUserAreaPermiso: 0,
          apValidar: false,
          apAutorizar: false,
          idUser: idUser,
          idArea: area.idArea,
        ),
      );

      if (tipoPermiso.toLowerCase() == 'validar') {
        return permisoArea.apValidar;
      } else if (tipoPermiso.toLowerCase() == 'autorizar') {
        return permisoArea.apAutorizar;
      }

      return false;
    } catch (e) {
      print('Error al validar permiso: $e');
      return false;
    }
  }

  Future<bool> asignarPermiso(UserAreaPermisos permiso) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/UserAreaPermisos'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: permiso.toJson(),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error al asignar permiso: $e');
      return false;
    }
  }

  Future<bool> actualizarPermiso(UserAreaPermisos permiso) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${_authService.apiURL}/UserAreaPermisos/${permiso.idUserAreaPermiso}',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: permiso.toJson(),
      );

      return response.statusCode == 204; // NoContent
    } catch (e) {
      print('Error al actualizar permiso: $e');
      return false;
    }
  }
}

class UserAreaPermisos {
  final int idUserAreaPermiso;
  final bool apValidar;
  final bool apAutorizar;
  final int idUser;
  final int idArea;
  UserAreaPermisos({
    required this.idUserAreaPermiso,
    required this.apValidar,
    required this.apAutorizar,
    required this.idUser,
    required this.idArea,
  });

  UserAreaPermisos copyWith({
    int? idUserAreaPermiso,
    bool? apValidar,
    bool? apAutorizar,
    int? idUser,
    int? idArea,
  }) {
    return UserAreaPermisos(
      idUserAreaPermiso: idUserAreaPermiso ?? this.idUserAreaPermiso,
      apValidar: apValidar ?? this.apValidar,
      apAutorizar: apAutorizar ?? this.apAutorizar,
      idUser: idUser ?? this.idUser,
      idArea: idArea ?? this.idArea,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idUserAreaPermiso': idUserAreaPermiso,
      'apValidar': apValidar,
      'apAutorizar': apAutorizar,
      'idUser': idUser,
      'idArea': idArea,
    };
  }

  factory UserAreaPermisos.fromMap(Map<String, dynamic> map) {
    return UserAreaPermisos(
      idUserAreaPermiso: map['idUserAreaPermiso'] as int,
      apValidar: map['apValidar'] as bool,
      apAutorizar: map['apAutorizar'] as bool,
      idUser: map['idUser'] as int,
      idArea: map['idArea'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAreaPermisos.fromJson(String source) =>
      UserAreaPermisos.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserAreaPermisos(idUserAreaPermiso: $idUserAreaPermiso, apValidar: $apValidar, apAutorizar: $apAutorizar, idUser: $idUser, idArea: $idArea)';
  }

  @override
  bool operator ==(covariant UserAreaPermisos other) {
    if (identical(this, other)) return true;

    return other.idUserAreaPermiso == idUserAreaPermiso &&
        other.apValidar == apValidar &&
        other.apAutorizar == apAutorizar &&
        other.idUser == idUser &&
        other.idArea == idArea;
  }

  @override
  int get hashCode {
    return idUserAreaPermiso.hashCode ^
        apValidar.hashCode ^
        apAutorizar.hashCode ^
        idUser.hashCode ^
        idArea.hashCode;
  }
}
