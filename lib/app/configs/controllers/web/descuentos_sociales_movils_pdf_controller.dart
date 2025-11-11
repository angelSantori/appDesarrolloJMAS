import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class DescuentosSocialesMovilsPdfController {
  final AuthService _authService = AuthService();

  // Listar todos los documentos
  Future<List<DescuentosSocialesMovilsPdf>>
  listDescuentoSocialPdfMovil() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/DescuentoSocialPDFMovils'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => DescuentosSocialesMovilsPdf.fromMap(item))
            .toList();
      } else {
        print(
          'Error listDescuentoSocialPdfMovil | Ife | DescuentosSocialesMovilsPdfController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print(
        'Error listDescuentoSocialPdfMovil | Try | DescuentosSocialesMovilsPdfController: $e',
      );
      return [];
    }
  }

  // Buscar documentos con filtros
  Future<List<DescuentosSocialesMovilsPdf>> searchDescuentoSocialMovilPdf({
    String? name,
    String? docType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final uri =
          Uri.parse(
            '${_authService.apiURL}/DescuentoSocialPDFMovils/search',
          ).replace(
            queryParameters: {
              if (name != null && name.isNotEmpty) 'name': name,
              if (docType != null && docType.isNotEmpty) 'docType': docType,
              if (startDate != null) 'startDate': startDate,
              if (endDate != null) 'endDate': endDate,
            },
          );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => DescuentosSocialesMovilsPdf.fromMap(item))
            .toList();
      } else {
        print(
          'Error searchDescuentoSocialMovilPdf | Ife | DescuentosSocialesMovilsPdfController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print(
        'Error searchDescuentoSocialMovilPdf | Try | DescuentosSocialesMovilsPdfController: $e',
      );
      return [];
    }
  }

  // Obtener documento por ID
  Future<DescuentosSocialesMovilsPdf?> getDescuentoSocialPdfMovil(
    int id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/DescuentoSocialPDFMovils/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return DescuentosSocialesMovilsPdf.fromMap(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print(
          'Error getDescuentoSocialPdfMovil | Ife | DescuentosSocialesMovilsPdfController: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print(
        'Error getDescuentoSocialPdfMovil | Try | DescuentosSocialesMovilsPdfController: $e',
      );
      return null;
    }
  }

  // Descargar PDF individual
  Future<Uint8List?> downloadPdf(int id) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${_authService.apiNubeURL}/DescuentoSocialPDFMovils/download/$id',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
          'Error downloadPdf | Ife |DescuentosSocialesMovilsPdfController: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print(
        'Error downloadPdf | Try | DescuentosSocialesMovilsPdfController: $e',
      );
      return null;
    }
  }

  // Descargar múltiples PDFs en ZIP
  Future<Uint8List?> downloadMultiplePdfsAsZip({
    required String startDate,
    required String endDate,
    String? name,
  }) async {
    try {
      final uri =
          Uri.parse(
            '${_authService.apiNubeURL}/DescuentoSocialPDFMovils/download-zip',
          ).replace(
            queryParameters: {
              'startDate': startDate,
              'endDate': endDate,
              if (name != null && name.isNotEmpty) 'name': name,
            },
          );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
          'Error downloadMultiplePdfsAsZip | Ife | DescuentosSocialesMovilsPdfController: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print(
        'Error downloadMultiplePdfsAsZip | Try | DescuentosSocialesMovilsPdfController: $e',
      );
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

class DescuentosSocialesMovilsPdf {
  final int idDescuentoSocialMovilPDF;
  final String nombreDocPdfDSM;
  final DateTime fechaDocPdfDSM;
  final String dataDocPdfDSM;
  DescuentosSocialesMovilsPdf({
    required this.idDescuentoSocialMovilPDF,
    required this.nombreDocPdfDSM,
    required this.fechaDocPdfDSM,
    required this.dataDocPdfDSM,
  });

  DescuentosSocialesMovilsPdf copyWith({
    int? idDescuentoSocialMovilPDF,
    String? nombreDocPdfDSM,
    DateTime? fechaDocPdfDSM,
    String? dataDocPdfDSM,
  }) {
    return DescuentosSocialesMovilsPdf(
      idDescuentoSocialMovilPDF:
          idDescuentoSocialMovilPDF ?? this.idDescuentoSocialMovilPDF,
      nombreDocPdfDSM: nombreDocPdfDSM ?? this.nombreDocPdfDSM,
      fechaDocPdfDSM: fechaDocPdfDSM ?? this.fechaDocPdfDSM,
      dataDocPdfDSM: dataDocPdfDSM ?? this.dataDocPdfDSM,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDescuentoSocialMovilPDF': idDescuentoSocialMovilPDF,
      'nombreDocPdfDSM': nombreDocPdfDSM,
      'fechaDocPdfDSM': fechaDocPdfDSM.toIso8601String(),
      'dataDocPdfDSM': dataDocPdfDSM,
    };
  }

  factory DescuentosSocialesMovilsPdf.fromMap(Map<String, dynamic> map) {
    return DescuentosSocialesMovilsPdf(
      idDescuentoSocialMovilPDF: map['idDescuentoSocialMovilPDF'] as int,
      nombreDocPdfDSM: map['nombreDocPdfDSM'] as String,
      fechaDocPdfDSM: _parseDateTime(map['fechaDocPdfDSM']),
      dataDocPdfDSM: map['dataDocPdfDSM'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DescuentosSocialesMovilsPdf.fromJson(String source) =>
      DescuentosSocialesMovilsPdf.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'DescuentosSocialesMovilsPdf(idDescuentoSocialMovilPDF: $idDescuentoSocialMovilPDF, nombreDocPdfDSM: $nombreDocPdfDSM, fechaDocPdfDSM: $fechaDocPdfDSM, dataDocPdfDSM: $dataDocPdfDSM)';
  }

  @override
  bool operator ==(covariant DescuentosSocialesMovilsPdf other) {
    if (identical(this, other)) return true;

    return other.idDescuentoSocialMovilPDF == idDescuentoSocialMovilPDF &&
        other.nombreDocPdfDSM == nombreDocPdfDSM &&
        other.fechaDocPdfDSM == fechaDocPdfDSM &&
        other.dataDocPdfDSM == dataDocPdfDSM;
  }

  @override
  int get hashCode {
    return idDescuentoSocialMovilPDF.hashCode ^
        nombreDocPdfDSM.hashCode ^
        fechaDocPdfDSM.hashCode ^
        dataDocPdfDSM.hashCode;
  }
}
