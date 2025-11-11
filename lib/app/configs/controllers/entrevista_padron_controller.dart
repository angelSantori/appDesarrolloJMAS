// Librerías
import 'dart:convert';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class EntrevistaPadronController {
  final AuthService _authService = AuthService();

  //  GET
  Future<List<EntrevistaPadron>> getEPxOS(int idOS) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/EntrevistaPadrons/ByOS/$idOS'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((listEPxOS) => EntrevistaPadron.fromMap(listEPxOS))
            .toList();
      } else {
        print(
          'Error getEPxOS | Ife | EntrevistaPadronController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getEPxOS | Try | EntrevistaPadronController: $e');
      return [];
    }
  }

  //  POST
  //  Add
  Future<bool> addEntrevistaPadron(EntrevistaPadron entrevistaPadron) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/EntrevistaPadrons'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: entrevistaPadron.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error addEntrevistaPadron | Ife | EntrevistaPadronController: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error addEntrevistaPadron | Try | EntrevistaPadronController: $e');
      return false;
    }
  }
}

class EntrevistaPadron {
  int? idEntrevistaPadron;
  String? comentariosEntrevistaPadron;
  String? calificacionEntrevistaPadron;
  String? fechaEntrevistaPadron;
  int? idUser;
  int? idOrdenServicio;
  EntrevistaPadron({
    this.idEntrevistaPadron,
    this.comentariosEntrevistaPadron,
    this.calificacionEntrevistaPadron,
    this.fechaEntrevistaPadron,
    this.idUser,
    this.idOrdenServicio,
  });

  EntrevistaPadron copyWith({
    int? idEntrevistaPadron,
    String? comentariosEntrevistaPadron,
    String? calificacionEntrevistaPadron,
    String? fechaEntrevistaPadron,
    int? idUser,
    int? idOrdenServicio,
  }) {
    return EntrevistaPadron(
      idEntrevistaPadron: idEntrevistaPadron ?? this.idEntrevistaPadron,
      comentariosEntrevistaPadron:
          comentariosEntrevistaPadron ?? this.comentariosEntrevistaPadron,
      calificacionEntrevistaPadron:
          calificacionEntrevistaPadron ?? this.calificacionEntrevistaPadron,
      fechaEntrevistaPadron:
          fechaEntrevistaPadron ?? this.fechaEntrevistaPadron,
      idUser: idUser ?? this.idUser,
      idOrdenServicio: idOrdenServicio ?? this.idOrdenServicio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idEntrevistaPadron': idEntrevistaPadron,
      'comentariosEntrevistaPadron': comentariosEntrevistaPadron,
      'calificacionEntrevistaPadron': calificacionEntrevistaPadron,
      'fechaEntrevistaPadron': fechaEntrevistaPadron,
      'idUser': idUser,
      'idOrdenServicio': idOrdenServicio,
    };
  }

  factory EntrevistaPadron.fromMap(Map<String, dynamic> map) {
    return EntrevistaPadron(
      idEntrevistaPadron:
          map['idEntrevistaPadron'] != null
              ? map['idEntrevistaPadron'] as int
              : null,
      comentariosEntrevistaPadron:
          map['comentariosEntrevistaPadron'] != null
              ? map['comentariosEntrevistaPadron'] as String
              : null,
      calificacionEntrevistaPadron:
          map['calificacionEntrevistaPadron'] != null
              ? map['calificacionEntrevistaPadron'] as String
              : null,
      fechaEntrevistaPadron:
          map['fechaEntrevistaPadron'] != null
              ? map['fechaEntrevistaPadron'] as String
              : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      idOrdenServicio:
          map['idOrdenServicio'] != null ? map['idOrdenServicio'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EntrevistaPadron.fromJson(String source) =>
      EntrevistaPadron.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EntrevistaPadron(idEntrevistaPadron: $idEntrevistaPadron, comentariosEntrevistaPadron: $comentariosEntrevistaPadron, calificacionEntrevistaPadron: $calificacionEntrevistaPadron, fechaEntrevistaPadron: $fechaEntrevistaPadron, idUser: $idUser, idOrdenServicio: $idOrdenServicio)';
  }

  @override
  bool operator ==(covariant EntrevistaPadron other) {
    if (identical(this, other)) return true;

    return other.idEntrevistaPadron == idEntrevistaPadron &&
        other.comentariosEntrevistaPadron == comentariosEntrevistaPadron &&
        other.calificacionEntrevistaPadron == calificacionEntrevistaPadron &&
        other.fechaEntrevistaPadron == fechaEntrevistaPadron &&
        other.idUser == idUser &&
        other.idOrdenServicio == idOrdenServicio;
  }

  @override
  int get hashCode {
    return idEntrevistaPadron.hashCode ^
        comentariosEntrevistaPadron.hashCode ^
        calificacionEntrevistaPadron.hashCode ^
        fechaEntrevistaPadron.hashCode ^
        idUser.hashCode ^
        idOrdenServicio.hashCode;
  }
}
