import 'package:intl/intl.dart';

DateTime? parseDate(String dateString) {
  try {
    // Primero intenta con el formato que incluye mes/día/año hora:minuto:segundo
    final formats = [
      'dd/MM/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm',
      'dd/MM/yyyy HH:mm',
      'dd/MM/yyyy',
    ];

    for (var format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (e) {
        continue;
      }
    }

    // Si ninguno de los formatos anteriores funciona, intenta parsear como DateTime directamente
    return DateTime.tryParse(dateString);
  } catch (e) {
    print('Error al parsear fecha: $dateString');
    return null;
  }
}