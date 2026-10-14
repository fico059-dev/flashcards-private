import 'dart:typed_data';

/// Saves [bytes] as a download in the browser. Returns false outside the
/// website, where there is nothing to download to.
Future<bool> downloadBytes(
  Uint8List bytes, {
  required String fileName,
  required String mimeType,
}) async => false;
