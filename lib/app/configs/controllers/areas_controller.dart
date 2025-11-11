import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class AreasController {
  final AuthService _authService = AuthService();

  Future<bool> addArea(Areas area) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Areas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: area.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error addArea | Ife | AreasController: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error addArea | Try | AreasController: $e');
      return false;
    }
  }

  Future<bool> editArea(Areas area) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Areas/${area.idArea}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: area.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
          'Error editArea | Ife | AreasController: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error editArea | Try | AreasController: $e');
      return false;
    }
  }

  Future<List<Areas>> listAreas() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Areas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((area) => Areas.fromMap(area)).toList();
      } else {
        print(
          'Error al obtener áreas: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error al listar áreas: $e');
      return [];
    }
  }
}

class Areas {
  final int idArea;
  final String areaCodigo;
  final String areaNombre;
  final String areaDescripcion;
  final bool areaEstado;
  Areas({
    required this.idArea,
    required this.areaCodigo,
    required this.areaNombre,
    required this.areaDescripcion,
    required this.areaEstado,
  });

  Areas copyWith({
    int? idArea,
    String? areaCodigo,
    String? areaNombre,
    String? areaDescripcion,
    bool? areaEstado,
  }) {
    return Areas(
      idArea: idArea ?? this.idArea,
      areaCodigo: areaCodigo ?? this.areaCodigo,
      areaNombre: areaNombre ?? this.areaNombre,
      areaDescripcion: areaDescripcion ?? this.areaDescripcion,
      areaEstado: areaEstado ?? this.areaEstado,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idArea': idArea,
      'areaCodigo': areaCodigo,
      'areaNombre': areaNombre,
      'areaDescripcion': areaDescripcion,
      'areaEstado': areaEstado,
    };
  }

  factory Areas.fromMap(Map<String, dynamic> map) {
    return Areas(
      idArea: map['idArea'] as int,
      areaCodigo: map['areaCodigo'] as String,
      areaNombre: map['areaNombre'] as String,
      areaDescripcion: map['areaDescripcion'] as String,
      areaEstado: map['areaEstado'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Areas.fromJson(String source) =>
      Areas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Areas(idArea: $idArea, areaCodigo: $areaCodigo, areaNombre: $areaNombre, areaDescripcion: $areaDescripcion, areaEstado: $areaEstado)';
  }

  @override
  bool operator ==(covariant Areas other) {
    if (identical(this, other)) return true;

    return other.idArea == idArea &&
        other.areaCodigo == areaCodigo &&
        other.areaNombre == areaNombre &&
        other.areaDescripcion == areaDescripcion &&
        other.areaEstado == areaEstado;
  }

  @override
  int get hashCode {
    return idArea.hashCode ^
        areaCodigo.hashCode ^
        areaNombre.hashCode ^
        areaDescripcion.hashCode ^
        areaEstado.hashCode;
  }
}
