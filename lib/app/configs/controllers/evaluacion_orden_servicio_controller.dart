// Librerías
import 'dart:convert';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class EvaluacionOrdenServicioController {
  final AuthService _authService = AuthService();

  //Get
  //List
  Future<List<EvaluacionOS>> listEvOS() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/EvaluacionOrdenServicios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((listEvOS) => EvaluacionOS.fromMap(listEvOS)).toList();
      } else {
        print(
          'Error listEvOS | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listEvOS | Try | Controller: $e');
      return [];
    }
  }

  //EvOTxidOT
  Future<List<EvaluacionOS>> listEvXidOS(int idOS) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/EvaluacionOrdenServicios/ByOS/$idOS'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((listEvOTxidOS) => EvaluacionOS.fromMap(listEvOTxidOS))
            .toList();
      } else {
        print(
          'Error listEvXidOS | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listEvXidOS | Try | Controller: $e');
      return [];
    }
  }

  //POST
  //Add
  Future<bool> addEvOS(EvaluacionOS evaluacionOS) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/EvaluacionOrdenServicios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: evaluacionOS.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error addEvOS | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error addEvOS | Try | Controller: $e');
      return false;
    }
  }
}

class EvaluacionOS {
  int? idEvaluacionOrdenServicio;
  String? fechaEOS;
  String? comentariosEOS;
  String? estadoEnviadoEOS;
  int? idUser;
  int? idOrdenServicio;
  EvaluacionOS({
    this.idEvaluacionOrdenServicio,
    this.fechaEOS,
    this.comentariosEOS,
    this.estadoEnviadoEOS,
    this.idUser,
    this.idOrdenServicio,
  });

  EvaluacionOS copyWith({
    int? idEvaluacionOrdenServicio,
    String? fechaEOS,
    String? comentariosEOS,
    String? estadoEnviadoEOS,
    int? idUser,
    int? idOrdenServicio,
  }) {
    return EvaluacionOS(
      idEvaluacionOrdenServicio:
          idEvaluacionOrdenServicio ?? this.idEvaluacionOrdenServicio,
      fechaEOS: fechaEOS ?? this.fechaEOS,
      comentariosEOS: comentariosEOS ?? this.comentariosEOS,
      estadoEnviadoEOS: estadoEnviadoEOS ?? this.estadoEnviadoEOS,
      idUser: idUser ?? this.idUser,
      idOrdenServicio: idOrdenServicio ?? this.idOrdenServicio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idEvaluacionOrdenServicio': idEvaluacionOrdenServicio,
      'fechaEOS': fechaEOS,
      'comentariosEOS': comentariosEOS,
      'estadoEnviadoEOS': estadoEnviadoEOS,
      'idUser': idUser,
      'idOrdenServicio': idOrdenServicio,
    };
  }

  factory EvaluacionOS.fromMap(Map<String, dynamic> map) {
    return EvaluacionOS(
      idEvaluacionOrdenServicio:
          map['idEvaluacionOrdenServicio'] != null
              ? map['idEvaluacionOrdenServicio'] as int
              : null,
      fechaEOS: map['fechaEOS'] != null ? map['fechaEOS'] as String : null,
      comentariosEOS:
          map['comentariosEOS'] != null
              ? map['comentariosEOS'] as String
              : null,
      estadoEnviadoEOS:
          map['estadoEnviadoEOS'] != null
              ? map['estadoEnviadoEOS'] as String
              : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      idOrdenServicio:
          map['idOrdenServicio'] != null ? map['idOrdenServicio'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EvaluacionOS.fromJson(String source) =>
      EvaluacionOS.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EvaluacionOS(idEvaluacionOrdenServicio: $idEvaluacionOrdenServicio, fechaEOS: $fechaEOS, comentariosEOS: $comentariosEOS, estadoEnviadoEOS: $estadoEnviadoEOS, idUser: $idUser, idOrdenServicio: $idOrdenServicio)';
  }

  @override
  bool operator ==(covariant EvaluacionOS other) {
    if (identical(this, other)) return true;

    return other.idEvaluacionOrdenServicio == idEvaluacionOrdenServicio &&
        other.fechaEOS == fechaEOS &&
        other.comentariosEOS == comentariosEOS &&
        other.estadoEnviadoEOS == estadoEnviadoEOS &&
        other.idUser == idUser &&
        other.idOrdenServicio == idOrdenServicio;
  }

  @override
  int get hashCode {
    return idEvaluacionOrdenServicio.hashCode ^
        fechaEOS.hashCode ^
        comentariosEOS.hashCode ^
        estadoEnviadoEOS.hashCode ^
        idUser.hashCode ^
        idOrdenServicio.hashCode;
  }
}
