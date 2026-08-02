import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_picker_utils.dart';

class FileUploadWidget extends StatelessWidget {
  const FileUploadWidget({
    super.key,
    this.file,
    required this.onDelete,
    required this.onFilePick,
    required this.title,
    this.hint,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
    this.platformFile,
    this.isPickImage = true,
    this.allowedExtensions,
  });

  final List<String>? allowedExtensions;
  final XFile? file;
  final String? hint;
  final bool isPickImage;
  final void Function() onDelete;
  final void Function(XFile? xFile, PlatformFile? platformFile) onFilePick;
  final EdgeInsetsGeometry padding;
  final PlatformFile? platformFile;
  final String title;

  @override
  Widget build(BuildContext context) {
    final filePath = file?.path ?? platformFile?.path;
    return DottedBorder(
      options: const RoundedRectDottedBorderOptions(
        dashPattern: [8, 6],
        strokeWidth: 2,
        padding: EdgeInsets.all(16),
        radius: Radius.circular(10),
      ),
      child: filePath == null
          ? Padding(
              padding: padding,
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text('Gallery'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    if (isPickImage) {
                                      final xfile = await FilePickerUtils()
                                          .pickImage(ImageSource.gallery);
                                      if (xfile != null) {
                                        onFilePick(xfile, null);
                                      }
                                    } else {
                                      final file = await FilePickerUtils()
                                          .pickFiles(allowedExtensions ?? []);
                                      if (file != null) {
                                        onFilePick(null, file);
                                      }
                                    }
                                  },
                                ),
                                if (!kIsWeb)
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Camera'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final xfile = await FilePickerUtils()
                                          .pickImage(ImageSource.camera);
                                      if (xfile != null) {
                                        onFilePick(xfile, null);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text(title, style: const TextStyle(fontSize: 16)),
                  ),
                  if (hint != null) const SizedBox(height: 5),
                  if (hint != null)
                    Text(
                      hint!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            )
          : Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: kIsWeb
                      ? Image.network(
                          filePath,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (_, error, stackTrace) => Image.asset(
                            'assets/document_placeholder.png',
                            width: 200,
                          ),
                        )
                      : Image.file(
                          File(filePath),
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (_, error, stackTrace) => Image.asset(
                            'assets/document_placeholder.png',
                            width: 200,
                          ),
                        ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
    );
  }
}
