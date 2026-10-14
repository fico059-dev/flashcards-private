import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

/// Same limit as images picked by admins in the flashcard builder.
const _maxImageSizeInBytes = 2 * 1024 * 1024;

/// Compresses an image file coming from an import to JPEG, like the images
/// picked in the flashcard builder. Returns null if the image can't be used.
Future<Uint8List?> compressImportedImage(String path) async {
  try {
    final compressed = await FlutterImageCompress.compressWithFile(
      path,
      quality: 85,
      minWidth: 1600,
      minHeight: 1600,
    );
    if (compressed != null &&
        compressed.isNotEmpty &&
        compressed.lengthInBytes <= _maxImageSizeInBytes) {
      return compressed;
    }
  } on Object {
    // Unsupported format (e.g. SVG) or platform without compression support,
    // fall back to the original image below.
  }
  try {
    final file = File(path);
    if (await file.length() > _maxImageSizeInBytes) return null;
    return await file.readAsBytes();
  } on FileSystemException {
    return null;
  }
}

/// Joins several images into one picture, stacked top to bottom on white,
/// for an imported card side that had more than one image. Returns JPEG
/// bytes, or null if the images can't be read (the caller then keeps only
/// the first image).
Future<Uint8List?> combineImagesVertically(List<String> paths) async {
  try {
    final files = [for (final path in paths) await File(path).readAsBytes()];
    // Decoding and drawing is slow for big images, keep it off the UI thread.
    return await Isolate.run(() => stackImageBytes(files));
  } on Object {
    return null;
  }
}

/// The work of [combineImagesVertically], on image file bytes.
Uint8List? stackImageBytes(
  List<Uint8List> files, {
  int maxWidth = 1200,
  int maxHeight = 6000,
  int gap = 24,
}) {
  // Files that aren't readable images (e.g. SVG) are skipped.
  final images = [for (final bytes in files) ?_tryDecode(bytes)];
  if (images.isEmpty) return null;

  // Wide images are scaled down to a common width, small ones stay sharp and
  // are centred.
  final width = min(maxWidth, images.map((i) => i.width).reduce(max));
  var parts = [
    for (final image in images)
      image.width > width
          ? img.copyResize(
              image,
              width: width,
              interpolation: img.Interpolation.average,
            )
          : image,
  ];

  int totalHeight() =>
      parts.fold(0, (sum, p) => sum + p.height) + gap * (parts.length - 1);

  // Very tall results are scaled down so the picture stays a sensible size.
  if (totalHeight() > maxHeight) {
    final scale = maxHeight / totalHeight();
    parts = [
      for (final part in parts)
        img.copyResize(
          part,
          width: max(1, (part.width * scale).round()),
          interpolation: img.Interpolation.average,
        ),
    ];
  }

  final canvasWidth = parts.map((p) => p.width).reduce(max);
  final canvas = img.Image(width: canvasWidth, height: totalHeight());
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
  var y = 0;
  for (final part in parts) {
    img.compositeImage(
      canvas,
      part,
      dstX: (canvasWidth - part.width) ~/ 2,
      dstY: y,
    );
    y += part.height + gap;
  }

  for (final quality in [85, 70, 55]) {
    final jpg = img.encodeJpg(canvas, quality: quality);
    if (jpg.lengthInBytes <= _maxImageSizeInBytes) return jpg;
  }
  return null;
}

img.Image? _tryDecode(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } on Object {
    return null;
  }
}

/// Turns a picked image into a JPEG at most [maxSide] pixels wide or high,
/// for images uploaded through a function (e.g. OSCE descriptions).
Future<Uint8List?> prepareJpeg(Uint8List bytes, {int maxSide = 1600}) async {
  Uint8List? work() {
    final image = _tryDecode(bytes);
    if (image == null) return null;
    final scaled = image.width >= image.height
        ? (image.width > maxSide
              ? img.copyResize(image, width: maxSide)
              : image)
        : (image.height > maxSide
              ? img.copyResize(image, height: maxSide)
              : image);
    return img.encodeJpg(scaled, quality: 82);
  }

  if (kIsWeb) return work();
  return Isolate.run(work);
}
