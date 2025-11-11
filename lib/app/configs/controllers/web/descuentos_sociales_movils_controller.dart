import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class DescuentosSocialesMovilsController {
  final AuthService _authService = AuthService();

  Future<List<DescuentosSocialesMovilsList>> listDSM() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentosSocialesMovils'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listDS) => DescuentosSocialesMovilsList.fromMap(listDS))
            .toList();
      } else {
        print(
          'Error listDSM | Ife | DescuentosSocialesMovilsController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listDSM | Try | DescuentosSocialesMovilsController: $e');
      return [];
    }
  }

  Future<DescuentosSocialesMovils?> getDSMById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentosSocialesMovils/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DescuentosSocialesMovils.fromMap(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

DateTime _parseDateTime(dynamic dateValue) {
  if (dateValue is int) {
    return DateTime.fromMillisecondsSinceEpoch(dateValue);
  } else if (dateValue is String) {
    return DateTime.parse(dateValue);
  } else {
    throw FormatException('Formato de fecha no válido: $dateValue');
  }
}

class DescuentosSocialesMovils {
  final int idDescuentoSocialMovil;
  final String dsmFolio;
  final DateTime dsmFecha;
  final String dsmNombreBeneficiario;
  final String dsmNombreConyugue;
  final int dsmEdad;
  final String dsmCURP;
  final String dsmTelefono;
  final String dsmRazonDescuento;
  final String dsmVivienda;
  final String dsmNumeroINE;
  final String dsmComprobante;
  final String dsmImgDocBase64;
  final int idUser;
  final int idPadron;
  DescuentosSocialesMovils({
    required this.idDescuentoSocialMovil,
    required this.dsmFolio,
    required this.dsmFecha,
    required this.dsmNombreBeneficiario,
    required this.dsmNombreConyugue,
    required this.dsmEdad,
    required this.dsmCURP,
    required this.dsmTelefono,
    required this.dsmRazonDescuento,
    required this.dsmVivienda,
    required this.dsmNumeroINE,
    required this.dsmComprobante,
    required this.dsmImgDocBase64,
    required this.idUser,
    required this.idPadron,
  });

  DescuentosSocialesMovils copyWith({
    int? idDescuentoSocialMovil,
    String? dsmFolio,
    DateTime? dsmFecha,
    String? dsmNombreBeneficiario,
    String? dsmNombreConyugue,
    int? dsmEdad,
    String? dsmCURP,
    String? dsmTelefono,
    String? dsmRazonDescuento,
    String? dsmVivienda,
    String? dsmNumeroINE,
    String? dsmComprobante,
    String? dsmImgDocBase64,
    int? idUser,
    int? idPadron,
  }) {
    return DescuentosSocialesMovils(
      idDescuentoSocialMovil:
          idDescuentoSocialMovil ?? this.idDescuentoSocialMovil,
      dsmFolio: dsmFolio ?? this.dsmFolio,
      dsmFecha: dsmFecha ?? this.dsmFecha,
      dsmNombreBeneficiario:
          dsmNombreBeneficiario ?? this.dsmNombreBeneficiario,
      dsmNombreConyugue: dsmNombreConyugue ?? this.dsmNombreConyugue,
      dsmEdad: dsmEdad ?? this.dsmEdad,
      dsmCURP: dsmCURP ?? this.dsmCURP,
      dsmTelefono: dsmTelefono ?? this.dsmTelefono,
      dsmRazonDescuento: dsmRazonDescuento ?? this.dsmRazonDescuento,
      dsmVivienda: dsmVivienda ?? this.dsmVivienda,
      dsmNumeroINE: dsmNumeroINE ?? this.dsmNumeroINE,
      dsmComprobante: dsmComprobante ?? this.dsmComprobante,
      dsmImgDocBase64: dsmImgDocBase64 ?? this.dsmImgDocBase64,
      idUser: idUser ?? this.idUser,
      idPadron: idPadron ?? this.idPadron,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDescuentoSocialMovil': idDescuentoSocialMovil,
      'dsmFolio': dsmFolio,
      'dsmFecha': dsmFecha.toIso8601String(),
      'dsmNombreBeneficiario': dsmNombreBeneficiario,
      'dsmNombreConyugue': dsmNombreConyugue,
      'dsmEdad': dsmEdad,
      'dsmCURP': dsmCURP,
      'dsmTelefono': dsmTelefono,
      'dsmRazonDescuento': dsmRazonDescuento,
      'dsmVivienda': dsmVivienda,
      'dsmNumeroINE': dsmNumeroINE,
      'dsmComprobante': dsmComprobante,
      'dsmImgDocBase64': dsmImgDocBase64,
      'idUser': idUser,
      'idPadron': idPadron,
    };
  }

  factory DescuentosSocialesMovils.fromMap(Map<String, dynamic> map) {
    return DescuentosSocialesMovils(
      idDescuentoSocialMovil: map['idDescuentoSocialMovil'] as int,
      dsmFolio: map['dsmFolio'] as String,
      dsmFecha: _parseDateTime(map['dsmFecha']),
      dsmNombreBeneficiario: map['dsmNombreBeneficiario'] as String,
      dsmNombreConyugue: map['dsmNombreConyugue'] as String,
      dsmEdad: map['dsmEdad'] as int,
      dsmCURP: map['dsmCURP'] as String,
      dsmTelefono: map['dsmTelefono'] as String,
      dsmRazonDescuento: map['dsmRazonDescuento'] as String,
      dsmVivienda: map['dsmVivienda'] as String,
      dsmNumeroINE: map['dsmNumeroINE'] as String,
      dsmComprobante: map['dsmComprobante'] as String,
      dsmImgDocBase64: map['dsmImgDocBase64'] as String,
      idUser: map['idUser'] as int,
      idPadron: map['idPadron'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory DescuentosSocialesMovils.fromJson(String source) =>
      DescuentosSocialesMovils.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'DescuentosSocialesMovils(idDescuentoSocialMovil: $idDescuentoSocialMovil, dsmFolio: $dsmFolio, dsmFecha: $dsmFecha, dsmNombreBeneficiario: $dsmNombreBeneficiario, dsmNombreConyugue: $dsmNombreConyugue, dsmEdad: $dsmEdad, dsmCURP: $dsmCURP, dsmTelefono: $dsmTelefono, dsmRazonDescuento: $dsmRazonDescuento, dsmVivienda: $dsmVivienda, dsmNumeroINE: $dsmNumeroINE, dsmComprobante: $dsmComprobante, dsmImgDocBase64: $dsmImgDocBase64, idUser: $idUser, idPadron: $idPadron)';
  }

  @override
  bool operator ==(covariant DescuentosSocialesMovils other) {
    if (identical(this, other)) return true;

    return other.idDescuentoSocialMovil == idDescuentoSocialMovil &&
        other.dsmFolio == dsmFolio &&
        other.dsmFecha == dsmFecha &&
        other.dsmNombreBeneficiario == dsmNombreBeneficiario &&
        other.dsmNombreConyugue == dsmNombreConyugue &&
        other.dsmEdad == dsmEdad &&
        other.dsmCURP == dsmCURP &&
        other.dsmTelefono == dsmTelefono &&
        other.dsmRazonDescuento == dsmRazonDescuento &&
        other.dsmVivienda == dsmVivienda &&
        other.dsmNumeroINE == dsmNumeroINE &&
        other.dsmComprobante == dsmComprobante &&
        other.dsmImgDocBase64 == dsmImgDocBase64 &&
        other.idUser == idUser &&
        other.idPadron == idPadron;
  }

  @override
  int get hashCode {
    return idDescuentoSocialMovil.hashCode ^
        dsmFolio.hashCode ^
        dsmFecha.hashCode ^
        dsmNombreBeneficiario.hashCode ^
        dsmNombreConyugue.hashCode ^
        dsmEdad.hashCode ^
        dsmCURP.hashCode ^
        dsmTelefono.hashCode ^
        dsmRazonDescuento.hashCode ^
        dsmVivienda.hashCode ^
        dsmNumeroINE.hashCode ^
        dsmComprobante.hashCode ^
        dsmImgDocBase64.hashCode ^
        idUser.hashCode ^
        idPadron.hashCode;
  }
}

class DescuentosSocialesMovilsList {
  final int idDescuentoSocialMovil;
  final String dsmFolio;
  final DateTime dsmFecha;
  final String dsmNombreBeneficiario;
  final String dsmNombreConyugue;
  final int dsmEdad;
  final String dsmCURP;
  final String dsmTelefono;
  final String dsmRazonDescuento;
  final String dsmVivienda;
  final String dsmNumeroINE;
  final String dsmComprobante;
  final int idUser;
  final int idPadron;
  DescuentosSocialesMovilsList({
    required this.idDescuentoSocialMovil,
    required this.dsmFolio,
    required this.dsmFecha,
    required this.dsmNombreBeneficiario,
    required this.dsmNombreConyugue,
    required this.dsmEdad,
    required this.dsmCURP,
    required this.dsmTelefono,
    required this.dsmRazonDescuento,
    required this.dsmVivienda,
    required this.dsmNumeroINE,
    required this.dsmComprobante,
    required this.idUser,
    required this.idPadron,
  });

  DescuentosSocialesMovilsList copyWith({
    int? idDescuentoSocialMovil,
    String? dsmFolio,
    DateTime? dsmFecha,
    String? dsmNombreBeneficiario,
    String? dsmNombreConyugue,
    int? dsmEdad,
    String? dsmCURP,
    String? dsmTelefono,
    String? dsmRazonDescuento,
    String? dsmVivienda,
    String? dsmNumeroINE,
    String? dsmComprobante,
    int? idUser,
    int? idPadron,
  }) {
    return DescuentosSocialesMovilsList(
      idDescuentoSocialMovil:
          idDescuentoSocialMovil ?? this.idDescuentoSocialMovil,
      dsmFolio: dsmFolio ?? this.dsmFolio,
      dsmFecha: dsmFecha ?? this.dsmFecha,
      dsmNombreBeneficiario:
          dsmNombreBeneficiario ?? this.dsmNombreBeneficiario,
      dsmNombreConyugue: dsmNombreConyugue ?? this.dsmNombreConyugue,
      dsmEdad: dsmEdad ?? this.dsmEdad,
      dsmCURP: dsmCURP ?? this.dsmCURP,
      dsmTelefono: dsmTelefono ?? this.dsmTelefono,
      dsmRazonDescuento: dsmRazonDescuento ?? this.dsmRazonDescuento,
      dsmVivienda: dsmVivienda ?? this.dsmVivienda,
      dsmNumeroINE: dsmNumeroINE ?? this.dsmNumeroINE,
      dsmComprobante: dsmComprobante ?? this.dsmComprobante,
      idUser: idUser ?? this.idUser,
      idPadron: idPadron ?? this.idPadron,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDescuentoSocialMovil': idDescuentoSocialMovil,
      'dsmFolio': dsmFolio,
      'dsmFecha': dsmFecha.toIso8601String(),
      'dsmNombreBeneficiario': dsmNombreBeneficiario,
      'dsmNombreConyugue': dsmNombreConyugue,
      'dsmEdad': dsmEdad,
      'dsmCURP': dsmCURP,
      'dsmTelefono': dsmTelefono,
      'dsmRazonDescuento': dsmRazonDescuento,
      'dsmVivienda': dsmVivienda,
      'dsmNumeroINE': dsmNumeroINE,
      'dsmComprobante': dsmComprobante,
      'idUser': idUser,
      'idPadron': idPadron,
    };
  }

  factory DescuentosSocialesMovilsList.fromMap(Map<String, dynamic> map) {
    return DescuentosSocialesMovilsList(
      idDescuentoSocialMovil: map['idDescuentoSocialMovil'] as int,
      dsmFolio: map['dsmFolio'] as String,
      dsmFecha: _parseDateTime(map['dsmFecha']),
      dsmNombreBeneficiario: map['dsmNombreBeneficiario'] as String,
      dsmNombreConyugue: map['dsmNombreConyugue'] as String,
      dsmEdad: map['dsmEdad'] as int,
      dsmCURP: map['dsmCURP'] as String,
      dsmTelefono: map['dsmTelefono'] as String,
      dsmRazonDescuento: map['dsmRazonDescuento'] as String,
      dsmVivienda: map['dsmVivienda'] as String,
      dsmNumeroINE: map['dsmNumeroINE'] as String,
      dsmComprobante: map['dsmComprobante'] as String,
      idUser: map['idUser'] as int,
      idPadron: map['idPadron'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory DescuentosSocialesMovilsList.fromJson(String source) =>
      DescuentosSocialesMovilsList.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'DescuentosSocialesMovilsList(idDescuentoSocialMovil: $idDescuentoSocialMovil, dsmFolio: $dsmFolio, dsmFecha: $dsmFecha, dsmNombreBeneficiario: $dsmNombreBeneficiario, dsmNombreConyugue: $dsmNombreConyugue, dsmEdad: $dsmEdad, dsmCURP: $dsmCURP, dsmTelefono: $dsmTelefono, dsmRazonDescuento: $dsmRazonDescuento, dsmVivienda: $dsmVivienda, dsmNumeroINE: $dsmNumeroINE, dsmComprobante: $dsmComprobante, idUser: $idUser, idPadron: $idPadron)';
  }

  @override
  bool operator ==(covariant DescuentosSocialesMovilsList other) {
    if (identical(this, other)) return true;

    return other.idDescuentoSocialMovil == idDescuentoSocialMovil &&
        other.dsmFolio == dsmFolio &&
        other.dsmFecha == dsmFecha &&
        other.dsmNombreBeneficiario == dsmNombreBeneficiario &&
        other.dsmNombreConyugue == dsmNombreConyugue &&
        other.dsmEdad == dsmEdad &&
        other.dsmCURP == dsmCURP &&
        other.dsmTelefono == dsmTelefono &&
        other.dsmRazonDescuento == dsmRazonDescuento &&
        other.dsmVivienda == dsmVivienda &&
        other.dsmNumeroINE == dsmNumeroINE &&
        other.dsmComprobante == dsmComprobante &&
        other.idUser == idUser &&
        other.idPadron == idPadron;
  }

  @override
  int get hashCode {
    return idDescuentoSocialMovil.hashCode ^
        dsmFolio.hashCode ^
        dsmFecha.hashCode ^
        dsmNombreBeneficiario.hashCode ^
        dsmNombreConyugue.hashCode ^
        dsmEdad.hashCode ^
        dsmCURP.hashCode ^
        dsmTelefono.hashCode ^
        dsmRazonDescuento.hashCode ^
        dsmVivienda.hashCode ^
        dsmNumeroINE.hashCode ^
        dsmComprobante.hashCode ^
        idUser.hashCode ^
        idPadron.hashCode;
  }
}
