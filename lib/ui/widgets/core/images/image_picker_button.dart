import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/core/picked_image.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/images/image_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerButton extends StatelessWidget {
  final String label;

  /// it uses this to render the image.
  /// You usually keep it in stateful widget
  /// or in bloc state.
  final ImageDataWrapper imageData;
  final void Function(ImageDataWrapper imageData)? onImageChanged;
  final void Function(Exception error)? onError;

  const ImagePickerButton({
    super.key,
    required this.label,
    required this.imageData,
    this.onImageChanged,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () =>
          _showImageSheet(context, label, imageData, onImageChanged, onError),
      tooltip: "إضافة صورة $label",
      icon: !imageData.imageDataExists
          ? const Icon(Icons.image_outlined)
          : Icon(Icons.image, color: context.customColors.success),
    );
  }
}

void _showImageSheet(
  BuildContext context,
  String label,
  ImageDataWrapper imageData,
  void Function(ImageDataWrapper imageData)? onImageChanged,
  void Function(Exception error)? onError,
) {
  showModalBottomSheet(
    showDragHandle: true,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> onAdd() async {
            try {
              final imageQuality = 85;
              final maxSizeInBytes = 2 * 1024 * 1024; // 2 MB

              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result == null || result.files.isEmpty) return;

              PickedImage newImage;
              if (kIsWeb) {
                final bytes = result.files.first.bytes!;
                if (bytes.lengthInBytes > maxSizeInBytes) {
                  throw Exception(
                    "الحد الأقصى لحجم الصورة "
                    "هو ${maxSizeInBytes / (1024 * 1024)} ميغابايت",
                  );
                }

                final compressedBytes =
                    await FlutterImageCompress.compressWithList(
                      bytes,
                      quality: imageQuality,
                    );

                newImage = PickedImage(bytes: compressedBytes);
              } else {
                final path = result.files.single.path!;
                if (await File(path).length() > maxSizeInBytes) {
                  throw Exception(
                    "الحد الأقصى لحجم الصورة "
                    "هو ${maxSizeInBytes / (1024 * 1024)} ميغابايت",
                  );
                }

                final dir = await getTemporaryDirectory();
                final targetPath =
                    "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

                final compressedFile =
                    await FlutterImageCompress.compressAndGetFile(
                      path,
                      targetPath,
                      quality: imageQuality,
                    );
                if (compressedFile == null) {
                  throw Exception(
                    "Something got wrong with compressing file on mobile",
                  );
                }

                newImage = PickedImage(file: File(compressedFile.path));
              }

              final newImageDataWrapper = imageData.copyWith(
                pickedImage: newImage,
                isChanged: true,
              );
              setState(() => imageData = newImageDataWrapper);

              onImageChanged?.call(newImageDataWrapper);
            } on Exception catch (error) {
              if (onError != null) {
                onError(error);
              } else {
                rethrow;
              }

              if (!context.mounted) return;
              context.router.pop();
            }
          }

          void onDelete() {
            final newImageData = imageData.copyWith(
              pickedImage: null,
              isChanged: true,
              imageDownloadUrl: null,
            );
            setState(() => imageData = newImageData);
            onImageChanged?.call(newImageData);
          }

          late Widget imageContainer;
          // print(imageData);
          // print(imageData.imageDataExists);
          if (!imageData.imageDataExists) {
            // print("no image selected");
            imageContainer = const Text("لم يتم اختيار صورة");
          } else if (imageData.pickedImage != null) {
            // print("there is a picked image");
            if (imageData.pickedImage!.file != null) {
              // print("picked image is file");
              imageContainer = ImagePreview(
                imageFile: imageData.pickedImage!.file!,
                onTap: () => onFileTap(context, imageData.pickedImage!.file!),
              );
            } else if (imageData.pickedImage!.bytes != null) {
              // print("picked image is bytes");
              imageContainer = ImagePreview(
                imageBytes: imageData.pickedImage!.bytes,
                onTap: () => onBytesTap(context, imageData.pickedImage!.bytes!),
              );
            }
          } else {
            // print("image comes from url");
            imageContainer = ImagePreview(
              downloadUrl: imageData.imageDownloadUrl!,
              onTap: () => onUrlTap(context, imageData.imageDownloadUrl!),
            );
          }

          return Padding(
            padding: bottomSheetPadding,
            child: Wrap(
              children: [
                Column(
                  children: [
                    Text(
                      "صورة $label",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    imageContainer,

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: imageData.imageDataExists
                                  ? onDelete
                                  : null,
                              label: const Text("حذف الصورة"),
                              icon: Icon(
                                Icons.delete,
                                color: imageData.imageDataExists
                                    ? context.colors.error
                                    : context.colors.error.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilledButton.icon(
                              onPressed: onAdd,
                              label: Text(
                                !imageData.imageDataExists
                                    ? "إضافة صورة"
                                    : "استبدال الصورة",
                              ),
                              icon: const Icon(Icons.add_photo_alternate),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// class _View extends StatefulWidget {
//   final void Function(PickedImage? pickedImage)? onImageChanged;
//
//   final String label;
//
//   const _View({super.key, required this.label, this.onImageChanged});
//
//   @override
//   State<_View> createState() => _ViewState();
// }
//
// class _ViewState extends State<_View> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<ImagePickerCubit, ImagePickerState>(
//       listener: (context, state) {
//         if (widget.onImageChanged != null) {
//           if (state is ImagePickerFileLoaded) {
//             widget.onImageChanged!(PickedImage(file: state.file));
//           } else if (state is ImagePickerBytesLoaded) {
//             widget.onImageChanged!(PickedImage(bytes: state.bytes));
//           } else {
//             widget.onImageChanged!(null);
//           }
//         }
//       },
//       child: IconButton(
//         onPressed: () => _showImageSheet(context, widget.label),
//         tooltip: "Add ${widget.label} image",
//         icon: BlocBuilder<ImagePickerCubit, ImagePickerState>(
//           builder: (context, state) {
//             switch (state) {
//               case ImagePickerEmtpy():
//               case ImagePickerLoading():
//               case ImagePickerError():
//                 return const Icon(Icons.image_outlined);
//               case ImagePickerFileLoaded():
//               case ImagePickerBytesLoaded():
//                 return const Icon(Icons.image, color: Colors.green);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// void _showImageSheet(BuildContext context, String label) {
//   final bloc = context.read<ImagePickerCubit>();
//
//   void onFileTap(File file) {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(child: InteractiveViewer(child: Image.file(file))),
//     );
//   }
//
//   void onBytesTap(Uint8List bytes) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => Dialog(child: InteractiveViewer(child: Image.memory(bytes))),
//     );
//   }
//
//   void onAdd() {
//     bloc.pickImage();
//   }
//
//   void onDelete() {
//     bloc.reset();
//   }
//
//   showModalBottomSheet(
//     showDragHandle: true,
//     backgroundColor: Colors.grey.shade100,
//     context: context,
//     shape: bottomSheetShape,
//     isScrollControlled: true,
//     builder: (context) {
//       return BlocProvider.value(
//         value: bloc,
//         child: Padding(
//           padding: bottomSheetPadding,
//           child: Wrap(
//             children: [
//               Column(
//                 children: [
//                   Text(
//                     "صورة $label",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   BlocBuilder<ImagePickerCubit, ImagePickerState>(
//                     builder: (context, state) {
//                       switch (state) {
//                         case ImagePickerEmtpy():
//                           return const Text("لم يتم اختيار صورة");
//                         case ImagePickerLoading():
//                           return CircularProgressIndicator(
//                             color: Colors.indigo,
//                           );
//                         case ImagePickerFileLoaded(:final file):
//                           return ImagePreview(
//                             imageFile: file,
//                             onTap: () => onFileTap(file),
//                           );
//                         case ImagePickerBytesLoaded(:final bytes):
//                           return ImagePreview(
//                             imageBytes: bytes,
//                             onTap: () => onBytesTap(bytes),
//                           );
//                         case ImagePickerError(:final error):
//                           return Text(
//                             extractErrorMessage(error),
//                             style: TextStyle(color: Colors.red),
//                           );
//                       }
//                     },
//                   ),
//
//                   SizedBox(height: 20),
//
//                   Row(
//                     spacing: 15,
//                     children: [
//                       BlocBuilder<ImagePickerCubit, ImagePickerState>(
//                         builder: (context, state) {
//                           bool disabled =
//                               state is ImagePickerLoading ||
//                               state is ImagePickerEmtpy;
//                           return Expanded(
//                             child: OutlinedButton.icon(
//                               label: Text("حذف الصورة"),
//                               onPressed: !disabled ? onDelete : null,
//                               icon: Icon(Icons.delete, color: Colors.red),
//                             ),
//                           );
//                         },
//                       ),
//
//                       BlocBuilder<ImagePickerCubit, ImagePickerState>(
//                         builder: (context, state) {
//                           bool disabled = state is ImagePickerLoading;
//
//                           bool isAdded =
//                               state is ImagePickerFileLoaded ||
//                               state is ImagePickerBytesLoaded;
//
//                           return Expanded(
//                             child: FilledButton.icon(
//                               onPressed: !disabled ? onAdd : null,
//                               label: Text(
//                                 isAdded ? "Replace Image" : "إضافة صورة",
//                               ),
//                               icon: Icon(Icons.add_photo_alternate),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
//
// class ImagePreview extends StatelessWidget {
//   final File? imageFile;
//   final Uint8List? imageBytes;
//   final VoidCallback? onTap;
//
//   const ImagePreview({super.key, this.imageFile, this.imageBytes, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     if (imageFile == null && imageBytes == null) {
//       return const Text("لم يتم اختيار صورة");
//     }
//
//     final imageWidget =
//         imageFile != null
//             ? Image.file(imageFile!, height: 400)
//             : Image.memory(imageBytes!, height: 400);
//
//     return GestureDetector(onTap: onTap, child: imageWidget);
//   }
// }
