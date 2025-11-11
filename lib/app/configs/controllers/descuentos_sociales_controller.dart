import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class DescuentosSocialesController {
  final AuthService _authService = AuthService();

  Future<DescuentosSociales?> addDS(DescuentosSociales ds) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/DescuentosSociales'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: ds.toJson(),
      );

      if (response.statusCode == 201) {
        // Parsear la respuesta para obtener el objeto con el folio generado
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DescuentosSociales.fromMap(responseData);
      } else {
        print(
          'Error addDS | DescuentosSocialesController: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error addDS | Try | DescuentosSocialesController: $e');
      return null;
    }
  }

  Future<List<DescuentosSocialesList>> listDS() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentosSociales'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listDS) => DescuentosSocialesList.fromMap(listDS))
            .toList();
      } else {
        print(
          'Error listDS | Ife | DescuentosSocialesController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listDS | Try | DescuentosSocialesController: $e');
      return [];
    }
  }

  Future<DescuentosSociales?> getDSById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentosSociales/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DescuentosSociales.fromMap(jsonData);
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

class DescuentosSociales {
  final int idDescuentoSocial;
  final String dsFolio;
  final DateTime dsFecha;
  final String dsNombreBeneficiario;
  final String dsNombreConyugue;
  final int dsEdad;
  final String dsCURP;
  final String dsTelefono;
  final String dsRazonDescuento;
  final String dsVivienda;
  final String dsNumeroINE;
  final String? dsComprobante;
  final String dsImgDocBase64;
  final int idUser;
  final int idPadron;
  DescuentosSociales({
    required this.idDescuentoSocial,
    required this.dsFolio,
    required this.dsFecha,
    required this.dsNombreBeneficiario,
    required this.dsNombreConyugue,
    required this.dsEdad,
    required this.dsCURP,
    required this.dsTelefono,
    required this.dsRazonDescuento,
    required this.dsVivienda,
    required this.dsNumeroINE,
    this.dsComprobante,
    required this.dsImgDocBase64,
    required this.idUser,
    required this.idPadron,
  });

  DescuentosSociales copyWith({
    int? idDescuentoSocial,
    String? dsFolio,
    DateTime? dsFecha,
    String? dsNombreBeneficiario,
    String? dsNombreConyugue,
    int? dsEdad,
    String? dsCURP,
    String? dsTelefono,
    String? dsRazonDescuento,
    String? dsVivienda,
    String? dsNumeroINE,
    String? dsComprobante,
    String? dsImgDocBase64,
    int? idUser,
    int? idPadron,
  }) {
    return DescuentosSociales(
      idDescuentoSocial: idDescuentoSocial ?? this.idDescuentoSocial,
      dsFolio: dsFolio ?? this.dsFolio,
      dsFecha: dsFecha ?? this.dsFecha,
      dsNombreBeneficiario: dsNombreBeneficiario ?? this.dsNombreBeneficiario,
      dsNombreConyugue: dsNombreConyugue ?? this.dsNombreConyugue,
      dsEdad: dsEdad ?? this.dsEdad,
      dsCURP: dsCURP ?? this.dsCURP,
      dsTelefono: dsTelefono ?? this.dsTelefono,
      dsRazonDescuento: dsRazonDescuento ?? this.dsRazonDescuento,
      dsVivienda: dsVivienda ?? this.dsVivienda,
      dsNumeroINE: dsNumeroINE ?? this.dsNumeroINE,
      dsComprobante: dsComprobante ?? this.dsComprobante,
      dsImgDocBase64: dsImgDocBase64 ?? this.dsImgDocBase64,
      idUser: idUser ?? this.idUser,
      idPadron: idPadron ?? this.idPadron,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDescuentoSocial': idDescuentoSocial,
      'dsFolio': dsFolio,
      'dsFecha': dsFecha.toIso8601String(),
      'dsNombreBeneficiario': dsNombreBeneficiario,
      'dsNombreConyugue': dsNombreConyugue,
      'dsEdad': dsEdad,
      'dsCURP': dsCURP,
      'dsTelefono': dsTelefono,
      'dsRazonDescuento': dsRazonDescuento,
      'dsVivienda': dsVivienda,
      'dsNumeroINE': dsNumeroINE,
      'dsComprobante': dsComprobante,
      'dsImgDocBase64': dsImgDocBase64,
      'idUser': idUser,
      'idPadron': idPadron,
    };
  }

  factory DescuentosSociales.fromMap(Map<String, dynamic> map) {
    return DescuentosSociales(
      idDescuentoSocial: map['idDescuentoSocial'] as int,
      dsFolio: map['dsFolio'] as String,
      dsFecha: _parseDateTime(map['dsFecha']),
      dsNombreBeneficiario: map['dsNombreBeneficiario'] as String,
      dsNombreConyugue: map['dsNombreConyugue'] as String,
      dsEdad: map['dsEdad'] as int,
      dsCURP: map['dsCURP'] as String,
      dsTelefono: map['dsTelefono'] as String,
      dsRazonDescuento: map['dsRazonDescuento'] as String,
      dsVivienda: map['dsVivienda'] as String,
      dsNumeroINE: map['dsNumeroINE'] as String,
      dsComprobante: map['dsComprobante'] != null
          ? map['dsComprobante'] as String
          : null,
      dsImgDocBase64: map['dsImgDocBase64'] as String,
      idUser: map['idUser'] as int,
      idPadron: map['idPadron'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory DescuentosSociales.fromJson(String source) =>
      DescuentosSociales.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DescuentosSociales(idDescuentoSocial: $idDescuentoSocial, dsFolio: $dsFolio, dsFecha: $dsFecha, dsNombreBeneficiario: $dsNombreBeneficiario, dsNombreConyugue: $dsNombreConyugue, dsEdad: $dsEdad, dsCURP: $dsCURP, dsTelefono: $dsTelefono, dsRazonDescuento: $dsRazonDescuento, dsVivienda: $dsVivienda, dsNumeroINE: $dsNumeroINE, dsComprobante: $dsComprobante, dsImgDocBase64: $dsImgDocBase64, idUser: $idUser, idPadron: $idPadron)';
  }

  @override
  bool operator ==(covariant DescuentosSociales other) {
    if (identical(this, other)) return true;

    return other.idDescuentoSocial == idDescuentoSocial &&
        other.dsFolio == dsFolio &&
        other.dsFecha == dsFecha &&
        other.dsNombreBeneficiario == dsNombreBeneficiario &&
        other.dsNombreConyugue == dsNombreConyugue &&
        other.dsEdad == dsEdad &&
        other.dsCURP == dsCURP &&
        other.dsTelefono == dsTelefono &&
        other.dsRazonDescuento == dsRazonDescuento &&
        other.dsVivienda == dsVivienda &&
        other.dsNumeroINE == dsNumeroINE &&
        other.dsComprobante == dsComprobante &&
        other.dsImgDocBase64 == dsImgDocBase64 &&
        other.idUser == idUser &&
        other.idPadron == idPadron;
  }

  @override
  int get hashCode {
    return idDescuentoSocial.hashCode ^
        dsFolio.hashCode ^
        dsFecha.hashCode ^
        dsNombreBeneficiario.hashCode ^
        dsNombreConyugue.hashCode ^
        dsEdad.hashCode ^
        dsCURP.hashCode ^
        dsTelefono.hashCode ^
        dsRazonDescuento.hashCode ^
        dsVivienda.hashCode ^
        dsNumeroINE.hashCode ^
        dsComprobante.hashCode ^
        dsImgDocBase64.hashCode ^
        idUser.hashCode ^
        idPadron.hashCode;
  }
}

class DescuentosSocialesList {
  final int idDescuentoSocial;
  final String dsFolio;
  final DateTime dsFecha;
  final String dsNombreBeneficiario;
  final String dsNombreConyugue;
  final int dsEdad;
  final String dsCURP;
  final String dsTelefono;
  final String dsRazonDescuento;
  final String dsVivienda;
  final String dsNumeroINE;
  final String? dsComprobante;
  final int idUser;
  final int idPadron;

  DescuentosSocialesList({
    required this.idDescuentoSocial,
    required this.dsFolio,
    required this.dsFecha,
    required this.dsNombreBeneficiario,
    required this.dsNombreConyugue,
    required this.dsEdad,
    required this.dsCURP,
    required this.dsTelefono,
    required this.dsRazonDescuento,
    required this.dsVivienda,
    required this.dsNumeroINE,
    this.dsComprobante,
    required this.idUser,
    required this.idPadron,
  });

  factory DescuentosSocialesList.fromMap(Map<String, dynamic> map) {
    return DescuentosSocialesList(
      idDescuentoSocial: map['idDescuentoSocial'] as int,
      dsFolio: map['dsFolio'] as String,
      dsFecha: _parseDateTime(map['dsFecha']),
      dsNombreBeneficiario: map['dsNombreBeneficiario'] as String,
      dsNombreConyugue: map['dsNombreConyugue'] as String,
      dsEdad: map['dsEdad'] as int,
      dsCURP: map['dsCURP'] as String,
      dsTelefono: map['dsTelefono'] as String,
      dsRazonDescuento: map['dsRazonDescuento'] as String,
      dsVivienda: map['dsVivienda'] as String,
      dsNumeroINE: map['dsNumeroINE'] as String,
      dsComprobante: map['dsComprobante'] != null
          ? map['dsComprobante'] as String
          : null,
      idUser: map['idUser'] as int,
      idPadron: map['idPadron'] as int,
    );
  }
}
