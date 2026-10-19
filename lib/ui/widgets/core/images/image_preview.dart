import 'dart:io';
import 'dart:typed_data';

import 'package:flashcards/ui/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? downloadUrl;
  final VoidCallback? onTap;
  final double height;
  final bool showTextWhenEmpty;

  const ImagePreview({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.onTap,
    this.downloadUrl,
    this.height = 400,
    this.showTextWhenEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null && imageBytes == null && downloadUrl == null) {
      if (showTextWhenEmpty) {
        return const Text("لم يتم اختيار صورة");
      } else {
        return SizedBox.shrink();
      }
    }

    late final Widget imageWidget;
    if (imageFile != null) {
      imageWidget = Image.file(imageFile!, height: height);
    } else if (imageBytes != null) {
      imageWidget = Image.memory(imageBytes!, height: height);
    } else if (downloadUrl != null) {
      imageWidget = Image.network(
        downloadUrl!,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: shimmerBaseColor(context),
            highlightColor: shimmerHighlightColor(context),
            child: Container(
              width: height,
              height: height,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red);
        },
      );
    } else {
      throw Exception(
        "Please provide at least one image source for ImagePreview",
      );
    }

    void _onTap() {
      late final Widget imageWidget;
      if (imageFile != null) {
        imageWidget = Image.file(imageFile!);
      } else if (imageBytes != null) {
        imageWidget = Image.memory(imageBytes!);
      } else if (downloadUrl != null) {
        imageWidget = Image.network(
          downloadUrl!,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      } else {
        return;
      }

      showDialog(
        context: context,
        builder: (_) {
          return Dialog(child: InteractiveViewer(child: imageWidget));
        },
      );
    }

    return GestureDetector(onTap: onTap ?? _onTap, child: imageWidget);
  }
}

void onFileTap(BuildContext context, File file) {
  showDialog(
    context: context,
    builder: (_) => Dialog(child: InteractiveViewer(child: Image.file(file))),
  );
}

void onBytesTap(BuildContext context, Uint8List bytes) {
  showDialog(
    context: context,
    builder:
        (_) => Dialog(child: InteractiveViewer(child: Image.memory(bytes))),
  );
}

void onUrlTap(BuildContext context, String downloadUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: InteractiveViewer(child: Image.network(downloadUrl)),
      );
    },
  );
}
