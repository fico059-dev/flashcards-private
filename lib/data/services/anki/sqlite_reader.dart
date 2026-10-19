import 'dart:convert';
import 'dart:typed_data';

/// Reads the rows of a table straight from an SQLite database file, in plain
/// Dart. Used on the website, where the SQLite library isn't available, to
/// read the notes inside an Anki .apkg. Read-only and only what Anki needs:
/// table b-trees, records and overflow pages.
class SqliteFileReader {
  final Uint8List _data;
  late final int _pageSize;
  late final int _usable;
  late final Encoding _encoding;

  SqliteFileReader(this._data) {
    if (_data.length < 100 ||
        ascii.decode(_data.sublist(0, 15), allowInvalid: true) !=
            'SQLite format 3') {
      throw const FormatException('Not an SQLite database');
    }
    final size = _u16(16);
    _pageSize = size == 1 ? 65536 : size;
    _usable = _pageSize - _data[20];
    _encoding = switch (_u32(56)) {
      2 || 3 => const _Utf16Codec(),
      _ => utf8,
    };
  }

  /// Every row of [table] as column name → value, in rowid order.
  List<Map<String, Object?>> readTable(String table) {
    final master = _readTree(1);
    for (final row in master) {
      // sqlite_master: type, name, tbl_name, rootpage, sql
      if (row.length >= 5 &&
          row[0] == 'table' &&
          (row[1] as String?)?.toLowerCase() == table.toLowerCase()) {
        final columns = _columnNames(row[4] as String? ?? '');
        final rootPage = row[3] as int;
        return [
          for (final values in _readTree(rootPage, rowidColumn: true))
            {
              for (var i = 0; i < columns.length; i++)
                columns[i]: i < values.length ? values[i] : null,
            },
        ];
      }
    }
    throw FormatException('Table "$table" not found');
  }

  /// Column names from a CREATE TABLE statement.
  static List<String> _columnNames(String sql) {
    final open = sql.indexOf('(');
    final close = sql.lastIndexOf(')');
    if (open == -1 || close <= open) return [];
    final body = sql.substring(open + 1, close);
    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < body.length; i++) {
      final c = body[i];
      if (c == '(') depth++;
      if (c == ')') depth--;
      if (c == ',' && depth == 0) {
        parts.add(body.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(body.substring(start));
    final names = <String>[];
    for (final part in parts) {
      final words = part.trim().split(RegExp(r'\s+'));
      if (words.isEmpty || words.first.isEmpty) continue;
      final first = words.first.toLowerCase();
      // Table constraints, not columns.
      if (const {
        'primary',
        'unique',
        'check',
        'foreign',
        'constraint',
      }.contains(first)) {
        continue;
      }
      names.add(words.first.replaceAll(RegExp(r'^["`\[]|["`\]]$'), ''));
    }
    return names;
  }

  /// All records of the table b-tree starting at [page]. With [rowidColumn]
  /// an INTEGER PRIMARY KEY stored as NULL gets the rowid.
  List<List<Object?>> _readTree(int page, {bool rowidColumn = false}) {
    final rows = <List<Object?>>[];
    final stack = [page];
    final seen = <int>{};
    // Depth first, children left to right, so rows come in rowid order.
    void visit(int pageNumber) {
      if (!seen.add(pageNumber)) {
        throw const FormatException('Damaged database (page loop)');
      }
      final base = (pageNumber - 1) * _pageSize;
      final header = pageNumber == 1 ? base + 100 : base;
      final type = _data[header];
      final cellCount = _u16(header + 3);
      final cellPointers = header + (type == 5 || type == 2 ? 12 : 8);
      if (type == 5) {
        for (var i = 0; i < cellCount; i++) {
          final cell = base + _u16(cellPointers + i * 2);
          visit(_u32(cell));
        }
        visit(_u32(header + 8));
      } else if (type == 13) {
        for (var i = 0; i < cellCount; i++) {
          var offset = base + _u16(cellPointers + i * 2);
          final (payloadSize, a) = _varint(offset);
          offset += a;
          final (rowid, b) = _varint(offset);
          offset += b;
          final payload = _payload(offset, payloadSize);
          final values = _record(payload);
          if (rowidColumn && values.isNotEmpty && values[0] == null) {
            values[0] = rowid;
          }
          rows.add(values);
        }
      } else {
        throw FormatException('Unexpected page type $type');
      }
    }

    for (final p in stack) {
      visit(p);
    }
    return rows;
  }

  Uint8List _payload(int offset, int size) {
    final maxLocal = _usable - 35;
    if (size <= maxLocal)
      return Uint8List.sublistView(_data, offset, offset + size);
    final minLocal = ((_usable - 12) * 32 ~/ 255) - 23;
    var local = minLocal + ((size - minLocal) % (_usable - 4));
    if (local > maxLocal) local = minLocal;

    final out = BytesBuilder(copy: false)
      ..add(Uint8List.sublistView(_data, offset, offset + local));
    var remaining = size - local;
    var next = _u32(offset + local);
    final seen = <int>{};
    while (remaining > 0 && next != 0) {
      if (!seen.add(next)) {
        throw const FormatException('Damaged database (overflow loop)');
      }
      final base = (next - 1) * _pageSize;
      final chunk = remaining < _usable - 4 ? remaining : _usable - 4;
      out.add(Uint8List.sublistView(_data, base + 4, base + 4 + chunk));
      remaining -= chunk;
      next = _u32(base);
    }
    return out.takeBytes();
  }

  List<Object?> _record(Uint8List p) {
    var (headerSize, n) = _varintIn(p, 0);
    var pos = n;
    final types = <int>[];
    while (pos < headerSize) {
      final (type, m) = _varintIn(p, pos);
      types.add(type);
      pos += m;
    }
    var offset = headerSize;
    final values = <Object?>[];
    for (final type in types) {
      switch (type) {
        case 0:
          values.add(null);
        case >= 1 && <= 6:
          final length = const [0, 1, 2, 3, 4, 6, 8][type];
          var value = 0;
          for (var i = 0; i < length; i++) {
            value = (value << 8) | p[offset + i];
          }
          // Two's complement.
          final bits = length * 8;
          if (bits < 64 && (value & (1 << (bits - 1))) != 0) {
            value -= 1 << bits;
          }
          values.add(value);
          offset += length;
        case 7:
          values.add(ByteData.sublistView(p, offset, offset + 8).getFloat64(0));
          offset += 8;
        case 8:
          values.add(0);
        case 9:
          values.add(1);
        default:
          if (type >= 12 && type.isEven) {
            final length = (type - 12) ~/ 2;
            values.add(Uint8List.sublistView(p, offset, offset + length));
            offset += length;
          } else if (type >= 13) {
            final length = (type - 13) ~/ 2;
            values.add(
              _encoding.decode(
                Uint8List.sublistView(p, offset, offset + length),
              ),
            );
            offset += length;
          } else {
            values.add(null);
          }
      }
    }
    return values;
  }

  (int, int) _varint(int offset) => _varintIn(_data, offset);

  static (int, int) _varintIn(Uint8List bytes, int offset) {
    var value = 0;
    for (var i = 0; i < 8; i++) {
      final byte = bytes[offset + i];
      value = (value << 7) | (byte & 0x7f);
      if (byte & 0x80 == 0) return (value, i + 1);
    }
    return ((value << 8) | bytes[offset + 8], 9);
  }

  int _u16(int offset) => (_data[offset] << 8) | _data[offset + 1];

  int _u32(int offset) =>
      (_data[offset] << 24) |
      (_data[offset + 1] << 16) |
      (_data[offset + 2] << 8) |
      _data[offset + 3];
}

/// Text in UTF-16 databases (rare for Anki).
class _Utf16Codec extends Encoding {
  const _Utf16Codec();

  @override
  String get name => 'utf-16le';

  @override
  Converter<List<int>, String> get decoder => const _Utf16Decoder();

  @override
  Converter<String, List<int>> get encoder => throw UnimplementedError();
}

class _Utf16Decoder extends Converter<List<int>, String> {
  const _Utf16Decoder();

  @override
  String convert(List<int> input) {
    final units = <int>[];
    for (var i = 0; i + 1 < input.length; i += 2) {
      units.add(input[i] | (input[i + 1] << 8));
    }
    return String.fromCharCodes(units);
  }
}
