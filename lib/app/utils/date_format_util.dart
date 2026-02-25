import 'package:intl/intl.dart';

/// GG-AA-YYYY (Türkçe tarih gösterimi)
const String displayPattern = 'dd-MM-yyyy';

/// API için YYYY-MM-DD
const String apiPattern = 'yyyy-MM-dd';

final DateFormat _displayFormat = DateFormat(displayPattern);
final DateFormat _apiFormat = DateFormat(apiPattern);

/// Tarihi ekranda göstermek için GG-AA-YYYY formatında string döner.
String formatForDisplay(DateTime date) {
  return _displayFormat.format(date);
}

/// Tarihi API'ye göndermek için YYYY-MM-DD formatında string döner.
String formatForApi(DateTime date) {
  return _apiFormat.format(date);
}

/// API'den gelen tarih string'ini (YYYY-MM-DD veya ISO) GG-AA-YYYY (dd-mm-yyyy) formatında döner.
/// Gelir/gider tablosu ve tüm ekranlarda bu format kullanılır.
String toDisplayDate(String? apiDate) {
  if (apiDate == null || apiDate.trim().isEmpty) return '';
  final s = apiDate.trim();
  // ISO veya saat içeren string'lerde sadece tarih kısmını al (YYYY-MM-DD)
  final datePart = s.contains('T') ? s.split('T').first : s;
  try {
    final dt = _apiFormat.parse(datePart);
    return _displayFormat.format(dt);
  } catch (_) {
    return apiDate;
  }
}

/// Ekrandaki GG-AA-YYYY string'ini API için YYYY-MM-DD'e çevirir. Boş veya geçersizse boş string.
String displayStringToApi(String? displayDate) {
  if (displayDate == null || displayDate.trim().isEmpty) return '';
  try {
    final dt = _displayFormat.parse(displayDate.trim());
    return _apiFormat.format(dt);
  } catch (_) {
    return displayDate;
  }
}

DateTime? parseDisplay(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  try {
    return _displayFormat.parse(s.trim());
  } catch (_) {
    return null;
  }
}

DateTime? parseApi(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  final trimmed = s.trim();
  final datePart = trimmed.contains('T') ? trimmed.split('T').first : trimmed;
  try {
    return _apiFormat.parse(datePart);
  } catch (_) {
    return null;
  }
}
