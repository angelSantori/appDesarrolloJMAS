import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';

class DescuentoSocialPdfController {
  final AuthService _authService = AuthService();

  // Listar todos los documentos
  Future<List<DescuentoSocialPDF>> listDescuentoSocialPdf() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentoSocialPDF'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => DescuentoSocialPDF.fromMap(item))
            .toList();
      } else {
        print(
            'Error listDescuentoSocialPdf | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listDescuentoSocialPdf | Try | Controller: $e');
      return [];
    }
  }

  // Obtener documento por ID
  Future<DescuentoSocialPDF?> getDescuentoSocialPdf(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentoSocialPDF/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return DescuentoSocialPDF.fromMap(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print(
            'Error getDescuentoSocialPdf | Controller: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getDescuentoSocialPdf | Try | Controller: $e');
      return null;
    }
  }

  // Buscar documentos con filtros
  Future<List<DescuentoSocialPDF>> searchDescuentoSocialPdf({
    String? name,
    String? docType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final uri =
          Uri.parse('${_authService.apiURL}/DescuentoSocialPDF/search').replace(
        queryParameters: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (docType != null && docType.isNotEmpty) 'docType': docType,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => DescuentoSocialPDF.fromMap(item))
            .toList();
      } else {
        print(
            'Error searchDescuentoSocialPdf | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error searchDescuentoSocialPdf | Try | Controller: $e');
      return [];
    }
  }

  // Descargar PDF individual
  Future<Uint8List?> downloadPdf(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DescuentoSocialPDF/download/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
            'Error downloadPdf | Controller: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error downloadPdf | Try | Controller: $e');
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
          Uri.parse('${_authService.apiURL}/DescuentoSocialPDF/download-zip')
              .replace(
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
            'Error downloadMultiplePdfsAsZip | Controller: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error downloadMultiplePdfsAsZip | Try | Controller: $e');
      return null;
    }
  }

  // Guardar PDF
  Future<bool> savePdf({
    required String nombreDocPdfDS,
    required String fechaDocPdfDS,
    required String dataDocPdfDS,
  }) async {
    try {
      final descuentoSocialPDF = DescuentoSocialPDF(
        idDescuentoSocualPDF: 0, // Será generado por la base de datos
        nombreDocPdfDS: nombreDocPdfDS,
        fechaDocPdfDS: fechaDocPdfDS,
        dataDocPdfDS: dataDocPdfDS,
      );

      final response = await http.post(
        Uri.parse('${_authService.apiURL}/DescuentoSocialPDF/save-pdf'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(descuentoSocialPDF.toMap()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error savePdf | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error savePdf | Try | Controller: $e');
      return false;
    }
  }

  // Actualizar PDF
  Future<bool> updatePdf(DescuentoSocialPDF descuentoSocialPDF) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/DescuentoSocialPDF/${descuentoSocialPDF.idDescuentoSocualPDF}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(descuentoSocialPDF.toMap()),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error updatePdf | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updatePdf | Try | Controller: $e');
      return false;
    }
  }

  // Eliminar PDF
  Future<bool> deletePdf(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${_authService.apiURL}/DescuentoSocialPDF/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error deletePdf | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deletePdf | Try | Controller: $e');
      return false;
    }
  }
}

class DescuentoSocialPDF {
  int idDescuentoSocualPDF;
  String nombreDocPdfDS;
  String fechaDocPdfDS;
  String dataDocPdfDS;

  DescuentoSocialPDF({
    required this.idDescuentoSocualPDF,
    required this.nombreDocPdfDS,
    required this.fechaDocPdfDS,
    required this.dataDocPdfDS,
  });

  DescuentoSocialPDF copyWith({
    int? idDescuentoSocualPDF,
    String? nombreDocPdfDS,
    String? fechaDocPdfDS,
    String? dataDocPdfDS,
  }) {
    return DescuentoSocialPDF(
      idDescuentoSocualPDF: idDescuentoSocualPDF ?? this.idDescuentoSocualPDF,
      nombreDocPdfDS: nombreDocPdfDS ?? this.nombreDocPdfDS,
      fechaDocPdfDS: fechaDocPdfDS ?? this.fechaDocPdfDS,
      dataDocPdfDS: dataDocPdfDS ?? this.dataDocPdfDS,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDescuentoSocualPDF': idDescuentoSocualPDF,
      'nombreDocPdfDS': nombreDocPdfDS,
      'fechaDocPdfDS': fechaDocPdfDS,
      'dataDocPdfDS': dataDocPdfDS,
    };
  }

  factory DescuentoSocialPDF.fromMap(Map<String, dynamic> map) {
    return DescuentoSocialPDF(
      idDescuentoSocualPDF: map['idDescuentoSocualPDF'] as int,
      nombreDocPdfDS: map['nombreDocPdfDS'] as String,
      fechaDocPdfDS: map['fechaDocPdfDS'] as String,
      dataDocPdfDS: map['dataDocPdfDS'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DescuentoSocialPDF.fromJson(String source) =>
      DescuentoSocialPDF.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DescuentoSocialPDF(idDescuentoSocualPDF: $idDescuentoSocualPDF, nombreDocPdfDS: $nombreDocPdfDS, fechaDocPdfDS: $fechaDocPdfDS, dataDocPdfDS: ${dataDocPdfDS.length > 50 ? '${dataDocPdfDS.substring(0, 50)}...' : dataDocPdfDS})';
  }

  @override
  bool operator ==(covariant DescuentoSocialPDF other) {
    if (identical(this, other)) return true;

    return other.idDescuentoSocualPDF == idDescuentoSocualPDF &&
        other.nombreDocPdfDS == nombreDocPdfDS &&
        other.fechaDocPdfDS == fechaDocPdfDS &&
        other.dataDocPdfDS == dataDocPdfDS;
  }

  @override
  int get hashCode {
    return idDescuentoSocualPDF.hashCode ^
        nombreDocPdfDS.hashCode ^
        fechaDocPdfDS.hashCode ^
        dataDocPdfDS.hashCode;
  }
}
