// Librerías
import 'dart:convert';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class TrabajoRealizadoController {
  final AuthService _authService = AuthService();

  //GET
  //ListTR
  Future<List<TrabajoRealizado>> listTrabajosRealizados() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/TrabajoRealizadoes'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((listTR) => TrabajoRealizado.fromMap(listTR)).toList();
      } else {
        print(
          'Error listTrabajosRealizados | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listTrabajosRealizados | Try | Controller: $e');
      return [];
    }
  }

  //TRXUserId
  Future<List<TrabajoRealizado>> getTRXUserID(int userID) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${_authService.apiNubeURL}/TrabajoRealizadoes/ByUser/$userID',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listTRXUser) => TrabajoRealizado.fromMap(listTRXUser))
            .toList();
      } else {
        print(
          'Error getTRXUserID | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getTRXUserID | Try | Controller: $e');
      return [];
    }
  }

  //TRXOtID
  Future<List<TrabajoRealizado>> getTRXOtID(int otID) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/TrabajoRealizadoes/ByOT/$otID'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((listTROT) => TrabajoRealizado.fromMap(listTROT))
            .toList();
      } else {
        print(
          'Error getTRXOtID | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getTRXOtID | Try | Controller: $e');
      return [];
    }
  }

  //NextTRFolio
  Future<String> getNextTRFolio() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${_authService.apiURL}/TrabajoRealizadoes/next-trabajofolio',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print(
          'Error getNextTRFolio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return '';
      }
    } catch (e) {
      print('Error getNextTRFolio | Try | Controller: $e');
      return '';
    }
  }

  //Post
  //Add
  Future<bool> addTrabajoRealizado(TrabajoRealizado trabajoRealizado) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/TrabajoRealizadoes'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: trabajoRealizado.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error addTrabajoRealizado | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error addTrabajoRealizado | Try | Controller: $e');
      return false;
    }
  }

  Future<TrabajoRealizado?> addTrabajoRealizado2(
    TrabajoRealizado trabajoRealizado,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/TrabajoRealizadoes'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: trabajoRealizado.toJson(),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return TrabajoRealizado.fromMap(responseBody);
      } else {
        print(
          'Error addTrabajoRealizado2 | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error addTrabajoRealizado2 | Try | Controller: $e');
      return null;
    }
  }

  //PUT
  //edit
  Future<bool> editTrabajoRealizado(TrabajoRealizado trabajoRealizado) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${_authService.apiURL}/TrabajoRealizadoes/${trabajoRealizado.idTrabajoRealizado}',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: trabajoRealizado.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
          'Error editTrabajoRealizado | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error editTrabajoRealizado | Try | Controller: $e');
      return false;
    }
  }
}

class TrabajoRealizado {
  int? idTrabajoRealizado;
  String? folioTR;
  String? fechaTR;
  String? ubicacionTR;
  String? comentarioTR;
  String? fotoAntes64TR;
  String? fotoDespues64TR;
  String? fotoRequiereMaterial64TR;
  String? firma64TR;
  String? estadoTR;
  int? idUserTR;
  int? idOrdenServicio;
  String? folioOS;
  String? padronNombre;
  String? padronDireccion;
  String? problemaNombre;
  String? folioSalida;
  bool? imagenesCargadas;
  TrabajoRealizado({
    this.idTrabajoRealizado,
    this.folioTR,
    this.fechaTR,
    this.ubicacionTR,
    this.comentarioTR,
    this.fotoAntes64TR,
    this.fotoDespues64TR,
    this.fotoRequiereMaterial64TR,
    this.firma64TR,
    this.estadoTR,
    this.idUserTR,
    this.idOrdenServicio,
    this.folioOS,
    this.padronNombre,
    this.padronDireccion,
    this.problemaNombre,
    this.folioSalida,
    this.imagenesCargadas,
  });

  TrabajoRealizado copyWith({
    int? idTrabajoRealizado,
    String? folioTR,
    String? fechaTR,
    String? ubicacionTR,
    String? comentarioTR,
    String? fotoAntes64TR,
    String? fotoDespues64TR,
    String? fotoRequiereMaterial64TR,
    String? firma64TR,
    String? estadoTR,
    int? idUserTR,
    int? idOrdenServicio,
    String? folioOS,
    String? padronNombre,
    String? padronDireccion,
    String? problemaNombre,
    String? folioSalida,
    bool? imagenesCargadas,
  }) {
    return TrabajoRealizado(
      idTrabajoRealizado: idTrabajoRealizado ?? this.idTrabajoRealizado,
      folioTR: folioTR ?? this.folioTR,
      fechaTR: fechaTR ?? this.fechaTR,
      ubicacionTR: ubicacionTR ?? this.ubicacionTR,
      comentarioTR: comentarioTR ?? this.comentarioTR,
      fotoAntes64TR: fotoAntes64TR ?? this.fotoAntes64TR,
      fotoDespues64TR: fotoDespues64TR ?? this.fotoDespues64TR,
      fotoRequiereMaterial64TR:
          fotoRequiereMaterial64TR ?? this.fotoRequiereMaterial64TR,
      firma64TR: firma64TR ?? this.firma64TR,
      estadoTR: estadoTR ?? this.estadoTR,
      idUserTR: idUserTR ?? this.idUserTR,
      idOrdenServicio: idOrdenServicio ?? this.idOrdenServicio,
      folioOS: folioOS ?? this.folioOS,
      padronNombre: padronNombre ?? this.padronNombre,
      padronDireccion: padronDireccion ?? this.padronDireccion,
      problemaNombre: problemaNombre ?? this.problemaNombre,
      folioSalida: folioSalida ?? this.folioSalida,
      imagenesCargadas: imagenesCargadas ?? this.imagenesCargadas,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idTrabajoRealizado': idTrabajoRealizado,
      'folioTR': folioTR,
      'fechaTR': fechaTR,
      'ubicacionTR': ubicacionTR,
      'comentarioTR': comentarioTR,
      'fotoAntes64TR': fotoAntes64TR,
      'fotoDespues64TR': fotoDespues64TR,
      'fotoRequiereMaterial64TR': fotoRequiereMaterial64TR,
      'firma64TR': firma64TR,
      'estadoTR': estadoTR,
      'idUserTR': idUserTR,
      'idOrdenServicio': idOrdenServicio,
      'folioOS': folioOS,
      'padronNombre': padronNombre,
      'padronDireccion': padronDireccion,
      'problemaNombre': problemaNombre,
      'folioSalida': folioSalida,
      'imagenesCargadas': imagenesCargadas,
    };
  }

  factory TrabajoRealizado.fromMap(Map<String, dynamic> map) {
    return TrabajoRealizado(
      idTrabajoRealizado:
          map['idTrabajoRealizado'] != null
              ? map['idTrabajoRealizado'] as int
              : null,
      folioTR: map['folioTR'] != null ? map['folioTR'] as String : null,
      fechaTR: map['fechaTR'] != null ? map['fechaTR'] as String : null,
      ubicacionTR:
          map['ubicacionTR'] != null ? map['ubicacionTR'] as String : null,
      comentarioTR:
          map['comentarioTR'] != null ? map['comentarioTR'] as String : null,
      fotoAntes64TR:
          map['fotoAntes64TR'] != null ? map['fotoAntes64TR'] as String : null,
      fotoDespues64TR:
          map['fotoDespues64TR'] != null
              ? map['fotoDespues64TR'] as String
              : null,
      fotoRequiereMaterial64TR:
          map['fotoRequiereMaterial64TR'] != null
              ? map['fotoRequiereMaterial64TR'] as String
              : null,
      firma64TR: map['firma64TR'] != null ? map['firma64TR'] as String : null,
      estadoTR: map['estadoTR'] != null ? map['estadoTR'] as String : null,
      idUserTR: map['idUserTR'] != null ? map['idUserTR'] as int : null,
      idOrdenServicio:
          map['idOrdenServicio'] != null ? map['idOrdenServicio'] as int : null,
      folioOS: map['folioOS'] != null ? map['folioOS'] as String : null,
      padronNombre:
          map['padronNombre'] != null ? map['padronNombre'] as String : null,
      padronDireccion:
          map['padronDireccion'] != null
              ? map['padronDireccion'] as String
              : null,
      problemaNombre:
          map['problemaNombre'] != null
              ? map['problemaNombre'] as String
              : null,
      folioSalida:
          map['folioSalida'] != null ? map['folioSalida'] as String : null,
      imagenesCargadas:
          map['imagenesCargadas'] != null
              ? map['imagenesCargadas'] as bool
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TrabajoRealizado.fromJson(String source) =>
      TrabajoRealizado.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TrabajoRealizado(idTrabajoRealizado: $idTrabajoRealizado, folioTR: $folioTR, fechaTR: $fechaTR, ubicacionTR: $ubicacionTR, comentarioTR: $comentarioTR, fotoAntes64TR: $fotoAntes64TR, fotoDespues64TR: $fotoDespues64TR, fotoRequiereMaterial64TR: $fotoRequiereMaterial64TR, firma64TR: $firma64TR, estadoTR: $estadoTR, idUserTR: $idUserTR, idOrdenServicio: $idOrdenServicio, folioOS: $folioOS, padronNombre: $padronNombre, padronDireccion: $padronDireccion, problemaNombre: $problemaNombre, folioSalida: $folioSalida, imagenesCargadas: $imagenesCargadas)';
  }

  @override
  bool operator ==(covariant TrabajoRealizado other) {
    if (identical(this, other)) return true;

    return other.idTrabajoRealizado == idTrabajoRealizado &&
        other.folioTR == folioTR &&
        other.fechaTR == fechaTR &&
        other.ubicacionTR == ubicacionTR &&
        other.comentarioTR == comentarioTR &&
        other.fotoAntes64TR == fotoAntes64TR &&
        other.fotoDespues64TR == fotoDespues64TR &&
        other.fotoRequiereMaterial64TR == fotoRequiereMaterial64TR &&
        other.firma64TR == firma64TR &&
        other.estadoTR == estadoTR &&
        other.idUserTR == idUserTR &&
        other.idOrdenServicio == idOrdenServicio &&
        other.folioOS == folioOS &&
        other.padronNombre == padronNombre &&
        other.padronDireccion == padronDireccion &&
        other.problemaNombre == problemaNombre &&
        other.folioSalida == folioSalida &&
        other.imagenesCargadas == imagenesCargadas;
  }

  @override
  int get hashCode {
    return idTrabajoRealizado.hashCode ^
        folioTR.hashCode ^
        fechaTR.hashCode ^
        ubicacionTR.hashCode ^
        comentarioTR.hashCode ^
        fotoAntes64TR.hashCode ^
        fotoDespues64TR.hashCode ^
        fotoRequiereMaterial64TR.hashCode ^
        firma64TR.hashCode ^
        estadoTR.hashCode ^
        idUserTR.hashCode ^
        idOrdenServicio.hashCode ^
        folioOS.hashCode ^
        padronNombre.hashCode ^
        padronDireccion.hashCode ^
        problemaNombre.hashCode ^
        folioSalida.hashCode ^
        imagenesCargadas.hashCode;
  }

  get isEmpty => null;

  map(Widget Function(dynamic listTrabajos) param0) {}
}
