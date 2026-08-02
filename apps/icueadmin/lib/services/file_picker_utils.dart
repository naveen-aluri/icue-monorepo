import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerUtils {
  final _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 30,
    );
    return pickedFile;
  }

  Future<PlatformFile?> pickFiles(List<String> allowedExtensions) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result != null) {
      return result.files.single;
    }
    return null;
  }
}
