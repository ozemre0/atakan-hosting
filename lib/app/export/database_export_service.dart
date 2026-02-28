import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../api/api_client.dart';
import 'export_save_io.dart' if (dart.library.html) 'export_save_web.dart' as export_save;

enum DbExportTable {
  customers,
  hostings,
  domains,
  ssls,
  incomes,
  expenses,
}

extension DbExportTableX on DbExportTable {
  String get key => name;

  String get defaultFileName {
    switch (this) {
      case DbExportTable.customers:
        return 'customers';
      case DbExportTable.hostings:
        return 'hostings';
      case DbExportTable.domains:
        return 'domains';
      case DbExportTable.ssls:
        return 'ssls';
      case DbExportTable.incomes:
        return 'incomes';
      case DbExportTable.expenses:
        return 'expenses';
    }
  }

  String get apiPath {
    switch (this) {
      case DbExportTable.customers:
        return '/customers';
      case DbExportTable.hostings:
        return '/hostings';
      case DbExportTable.domains:
        return '/domains';
      case DbExportTable.ssls:
        return '/ssls';
      case DbExportTable.incomes:
        return '/incomes';
      case DbExportTable.expenses:
        return '/expenses';
    }
  }

  static DbExportTable? fromKey(String key) {
    for (final t in DbExportTable.values) {
      if (t.key == key) return t;
    }
    return null;
  }
}

class DatabaseExportService {
  DatabaseExportService(this._api);

  final ApiClient _api;

  Future<Map<DbExportTable, List<Map<String, dynamic>>>> fetchTables(
    Set<DbExportTable> tables,
  ) async {
    final result = <DbExportTable, List<Map<String, dynamic>>>{};
    for (final table in tables) {
      result[table] = await _fetchTable(table);
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _fetchTable(DbExportTable table) async {
    switch (table) {
      case DbExportTable.customers:
        return _fetchPaged(
          table.apiPath,
          baseQuery: const {
            'q': '',
            'sort': 'name',
            'dir': 'asc',
          },
        );
      case DbExportTable.hostings:
        return _fetchPaged(
          table.apiPath,
          baseQuery: const {
            'status': 'all',
            'sort': 'end_date',
            'dir': 'asc',
          },
        );
      case DbExportTable.domains:
        return _fetchPaged(
          table.apiPath,
          baseQuery: const {
            'status': 'all',
            'sort': 'end_date',
            'dir': 'asc',
          },
        );
      case DbExportTable.ssls:
        return _fetchPaged(
          table.apiPath,
          baseQuery: const {
            'status': 'all',
            'sort': 'end_date',
            'dir': 'asc',
          },
        );
      case DbExportTable.incomes:
        return _fetchSimple(table.apiPath);
      case DbExportTable.expenses:
        return _fetchSimple(table.apiPath);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPaged(
    String path, {
    Map<String, dynamic>? baseQuery,
    int pageSize = 500,
  }) async {
    final all = <Map<String, dynamic>>[];
    var offset = 0;
    int? total;

    while (true) {
      final query = <String, dynamic>{
        if (baseQuery != null) ...baseQuery,
        'limit': pageSize,
        'offset': offset,
      };

      final res = await _api.getJson(path, queryParameters: query);
      final raw =
          (res['items'] as List?) ?? (res['data'] as List?) ?? const <dynamic>[];
      final page = raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();

      all.addAll(page);

      total ??=
          res['total'] as int? ?? res['count'] as int? ?? all.length;

      if (all.length >= total || page.length < pageSize) {
        break;
      }

      offset += pageSize;
    }

    return all;
  }

  Future<List<Map<String, dynamic>>> _fetchSimple(String path) async {
    final res = await _api.getJson(path);
    final raw =
        (res['items'] as List?) ?? (res['data'] as List?) ?? const <dynamic>[];
    return raw
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  /// Exports selected tables as CSV. Returns list of saved file paths (on mobile).
  Future<List<String>> exportAsCsv(Set<DbExportTable> tables) async {
    final paths = <String>[];
    if (tables.isEmpty) return paths;
    final data = await fetchTables(tables);

    for (final entry in data.entries) {
      final rows = entry.value;
      if (rows.isEmpty) continue;

      final csv = _buildCsv(rows);
      final bytes = Uint8List.fromList(utf8.encode(csv));

      final path = await export_save.saveExportFile(
        bytes,
        entry.key.defaultFileName,
        'csv',
      );
      if (path != null) paths.add(path);
    }
    return paths;
  }

  /// Exports selected tables as Excel. Returns list of saved file paths (on mobile).
  Future<List<String>> exportAsExcel(Set<DbExportTable> tables) async {
    final paths = <String>[];
    if (tables.isEmpty) return paths;
    final data = await fetchTables(tables);

    for (final entry in data.entries) {
      final rows = entry.value;
      if (rows.isEmpty) continue;

      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      final headers = _collectHeaders(rows);
      sheet.appendRow(
        headers.map<CellValue?>(
          (h) => TextCellValue(h),
        ).toList(),
      );

      for (final row in rows) {
        final cells = <CellValue?>[];
        for (final key in headers) {
          final value = row[key];
          if (value is int) {
            cells.add(IntCellValue(value));
          } else if (value is double) {
            cells.add(DoubleCellValue(value));
          } else if (value is num) {
            cells.add(DoubleCellValue(value.toDouble()));
          } else if (value is bool) {
            cells.add(BoolCellValue(value));
          } else {
            cells.add(TextCellValue(value?.toString() ?? ''));
          }
        }
        sheet.appendRow(cells);
      }

      final encoded = excel.encode();
      if (encoded == null) {
        continue;
      }

      final path = await export_save.saveExportFile(
        Uint8List.fromList(encoded),
        entry.key.defaultFileName,
        'xlsx',
      );
      if (path != null) paths.add(path);
    }
    return paths;
  }

  List<String> _collectHeaders(List<Map<String, dynamic>> rows) {
    final headers = <String>{};
    for (final row in rows) {
      headers.addAll(row.keys);
    }
    final list = headers.toList();
    list.sort();
    return list;
  }

  String _buildCsv(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '';

    final headers = _collectHeaders(rows);
    final buffer = StringBuffer();

    buffer.writeln(headers.map(_escapeCsvField).join(','));

    for (final row in rows) {
      final values = headers.map((h) => _escapeCsvField(row[h])).join(',');
      buffer.writeln(values);
    }

    return buffer.toString();
  }

  String _escapeCsvField(dynamic value) {
    final s = value?.toString() ?? '';
    final needsQuote = s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
    final escaped = s.replaceAll('"', '""');
    return needsQuote ? '"$escaped"' : escaped;
  }
}

