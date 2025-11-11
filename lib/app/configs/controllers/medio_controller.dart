// Librerías
import 'dart:convert';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class MedioController {
  final AuthService _authService = AuthService();

  //  Get
  //  List
  Future<List<Medios>> listMedios() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/MedioOrdenServicios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listMedios) => Medios.fromMap(listMedios))
            .toList();
      } else {
        print(
          'Error listMedios | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listMedios | Try | Controller: $e');
      return [];
    }
  }

  //  Meddio x Id
  Future<Medios?> medioXId(int idMedio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/MedioOrdenServicios/$idMedio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return Medios.fromMap(jsonData);
      } else {
        print(
          'Error medioXId | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error medioXId | Try | Controller: $e');
      return null;
    }
  }

  //  Post
  //  Add
  Future<bool> addMedio(Medios medio) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/MedioOrdenServicios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: medio.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error addMedio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error addMedio | Try | Controller: $e');
      return false;
    }
  }

  //  PUT
  //  Edit
  Future<bool> editMedio(Medios medio) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${_authService.apiURL}/MedioOrdenServicios/${medio.idMedio}',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: medio.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
          'Error editMedio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error editMedio | Try | Controller: $e');
      return false;
    }
  }
}

class Medios {
  int? idMedio;
  String? nombreMedio;
  Medios({this.idMedio, this.nombreMedio});

  Medios copyWith({int? idMedio, String? nombreMedio}) {
    return Medios(
      idMedio: idMedio ?? this.idMedio,
      nombreMedio: nombreMedio ?? this.nombreMedio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'idMedio': idMedio, 'nombreMedio': nombreMedio};
  }

  factory Medios.fromMap(Map<String, dynamic> map) {
    return Medios(
      idMedio: map['idMedio'] != null ? map['idMedio'] as int : null,
      nombreMedio:
          map['nombreMedio'] != null ? map['nombreMedio'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Medios.fromJson(String source) =>
      Medios.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Medios(idMedio: $idMedio, nombreMedio: $nombreMedio)';

  @override
  bool operator ==(covariant Medios other) {
    if (identical(this, other)) return true;

    return other.idMedio == idMedio && other.nombreMedio == nombreMedio;
  }

  @override
  int get hashCode => idMedio.hashCode ^ nombreMedio.hashCode;
}
