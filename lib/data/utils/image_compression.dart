import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Same limit as images picked by admins in the flashcard builder.
const _maxImageSizeInBytes = 2 * 1024 * 1024;

/// Compresses an image coming from an import to JPEG, like the images picked
/// in the flashcard builder. Returns null if the image can't be used.
Future<Uint8List?> compressImportedImage(Uint8List bytes) async {
  try {
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 85,
      minWidth: 1600,
      minHeight: 1600,
    );
    if (compressed.isNotEmpty &&
        compressed.lengthInBytes <= _maxImageSizeInBytes) {
      return compressed;
    }
  } on Object {
    // Unsupported format (e.g. SVG) or platform without compression support,
    // fall back to the original image below.
  }
  return bytes.lengthInBytes <= _maxImageSizeInBytes ? bytes : null;
}
