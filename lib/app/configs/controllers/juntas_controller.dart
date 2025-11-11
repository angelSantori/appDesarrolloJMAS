import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class JuntasController {
  final AuthService _authService = AuthService();

  //Add junta
  Future<bool> addJunta(Juntas junta) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Juntas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: junta.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Errir al agregar junta: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error al agregar junta desde controller: $e');
      return false;
    }
  }

  //Lista Juntas
  Future<List<Juntas>> listJuntas() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Juntas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((junta) => Juntas.fromMap(junta)).toList();
      } else {
        print(
          'Error al obtener lista de juntas: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error lista de juntas: $e');
      return [];
    }
  }

  Future<bool> editJunta(Juntas junta) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Juntas/${junta.idJunta}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: junta.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
          'Error al editar junta: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error al editar junta desde controller: $e');
      return false;
    }
  }
}

class Juntas {
  int? idJunta;
  String? juntaNombre;
  String? juntaTelefono;
  String? juntaEncargado;
  String? juntaCuentaCargo;
  String? juntaCuentaAbono;
  Juntas({
    this.idJunta,
    this.juntaNombre,
    this.juntaTelefono,
    this.juntaEncargado,
    this.juntaCuentaCargo,
    this.juntaCuentaAbono,
  });

  Juntas copyWith({
    int? idJunta,
    String? juntaNombre,
    String? juntaTelefono,
    String? juntaEncargado,
    String? juntaCuentaCargo,
    String? juntaCuentaAbono,
  }) {
    return Juntas(
      idJunta: idJunta ?? this.idJunta,
      juntaNombre: juntaNombre ?? this.juntaNombre,
      juntaTelefono: juntaTelefono ?? this.juntaTelefono,
      juntaEncargado: juntaEncargado ?? this.juntaEncargado,
      juntaCuentaCargo: juntaCuentaCargo ?? this.juntaCuentaCargo,
      juntaCuentaAbono: juntaCuentaAbono ?? this.juntaCuentaAbono,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idJunta': idJunta,
      'juntaNombre': juntaNombre,
      'juntaTelefono': juntaTelefono,
      'juntaEncargado': juntaEncargado,
      'juntaCuentaCargo': juntaCuentaCargo,
      'juntaCuentaAbono': juntaCuentaAbono,
    };
  }

  factory Juntas.fromMap(Map<String, dynamic> map) {
    return Juntas(
      idJunta: map['idJunta'] != null ? map['idJunta'] as int : null,
      juntaNombre: map['juntaNombre'] != null
          ? map['juntaNombre'] as String
          : null,
      juntaTelefono: map['juntaTelefono'] != null
          ? map['juntaTelefono'] as String
          : null,
      juntaEncargado: map['juntaEncargado'] != null
          ? map['juntaEncargado'] as String
          : null,
      juntaCuentaCargo: map['juntaCuentaCargo'] != null
          ? map['juntaCuentaCargo'] as String
          : null,
      juntaCuentaAbono: map['juntaCuentaAbono'] != null
          ? map['juntaCuentaAbono'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Juntas.fromJson(String source) =>
      Juntas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Juntas(idJunta: $idJunta, juntaNombre: $juntaNombre, juntaTelefono: $juntaTelefono, juntaEncargado: $juntaEncargado, juntaCuentaCargo: $juntaCuentaCargo, juntaCuentaAbono: $juntaCuentaAbono)';
  }

  @override
  bool operator ==(covariant Juntas other) {
    if (identical(this, other)) return true;

    return other.idJunta == idJunta &&
        other.juntaNombre == juntaNombre &&
        other.juntaTelefono == juntaTelefono &&
        other.juntaEncargado == juntaEncargado &&
        other.juntaCuentaCargo == juntaCuentaCargo &&
        other.juntaCuentaAbono == juntaCuentaAbono;
  }

  @override
  int get hashCode {
    return idJunta.hashCode ^
        juntaNombre.hashCode ^
        juntaTelefono.hashCode ^
        juntaEncargado.hashCode ^
        juntaCuentaCargo.hashCode ^
        juntaCuentaAbono.hashCode;
  }
}
