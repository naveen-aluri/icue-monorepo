import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:icue_face_sdk/icue_face_sdk.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/student_model.dart';

@injectable
class IdentifyProvider extends ChangeNotifier {
  final IcueFaceSdk _faceSdk;
  final Dio _dio;

  IdentifyProvider(this._faceSdk) : _dio = Dio();

  bool _isIdentifying = false;
  bool get isIdentifying => _isIdentifying;

  String _statusText = 'Select a photo to start identification';
  String get statusText => _statusText;

  String? _localImagePath;
  String? get localImagePath => _localImagePath;

  String? _imageSource;
  String? get imageSource => _imageSource;

  Student? _identifiedStudent;
  Student? get identifiedStudent => _identifiedStudent;

  double? _confidenceScore;
  double? get confidenceScore => _confidenceScore;

  double _preparationProgress = 0.0;
  double get preparationProgress => _preparationProgress;

  void resetState() {
    _isIdentifying = false;
    _statusText = 'Select a photo to start identification';
    _localImagePath = null;
    _imageSource = null;
    _identifiedStudent = null;
    _confidenceScore = null;
    _preparationProgress = 0.0;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        _localImagePath = pickedFile.path;
        _imageSource = source == ImageSource.camera ? 'Camera' : 'Gallery';
        _identifiedStudent = null;
        _confidenceScore = null;
        _statusText = 'Photo loaded. Click IDENTIFY PERSON to start scan.';
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> identifyPerson(List<Student> candidates) async {
    if (_isIdentifying) return;
    if (_localImagePath == null) {
      throw Exception('Please select a photo first.');
    }
    if (candidates.isEmpty) {
      throw Exception('No students with photos available for comparison.');
    }

    _isIdentifying = true;
    _identifiedStudent = null;
    _confidenceScore = null;
    _preparationProgress = 0.0;
    _statusText = 'Starting identification...';
    notifyListeners();

    try {
      if (!Platform.isAndroid) {
        // Mock Mode for iOS/Simulator/Other
        _statusText = 'Preparing templates in Mock Mode...';
        notifyListeners();

        for (int i = 0; i < candidates.length; i++) {
          _preparationProgress = (i + 1) / candidates.length;
          _statusText = 'Extracting template for ${candidates[i].name}...';
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 400));
        }

        _statusText = 'Comparing templates...';
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));

        // Mock pick a random student from candidates
        final random = Random();
        final matchedIndex = random.nextInt(candidates.length);
        _identifiedStudent = candidates[matchedIndex];
        _confidenceScore = 75.0 + random.nextDouble() * 20.0; // 75% to 95%
        _statusText = 'Student identified: ${_identifiedStudent!.name}';
        _isIdentifying = false;
        notifyListeners();
        return;
      }

      // Android Flow - Real SDK calls
      final List<FaceProfile> profiles = [];

      // 1. Download and extract embeddings for candidates
      for (int i = 0; i < candidates.length; i++) {
        final student = candidates[i];
        _preparationProgress = i / candidates.length;
        _statusText =
            'Downloading photo for ${student.name} (${i + 1}/${candidates.length})...';
        notifyListeners();

        String? tempFilePath;
        try {
          if (student.photoUrl == null || student.photoUrl!.isEmpty) {
            continue;
          }

          final tempDir = await getTemporaryDirectory();
          tempFilePath =
              '${tempDir.path}/temp_identify_student_${student.id}_photo.jpg';
          final file = File(tempFilePath);
          if (await file.exists()) {
            await file.delete();
          }

          await _dio.download(student.photoUrl!, tempFilePath);

          _statusText = 'Extracting signature for ${student.name}...';
          notifyListeners();

          final embedding = await _faceSdk.extractEmbedding(
            imagePath: tempFilePath,
          );
          profiles.add(
            FaceProfile(personId: student.id.toString(), embedding: embedding),
          );
        } catch (e) {
          debugPrint('Error preparing profile for ${student.name}: $e');
        } finally {
          if (tempFilePath != null) {
            final file = File(tempFilePath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      }

      _preparationProgress = 1.0;
      if (profiles.isEmpty) {
        throw Exception('Failed to prepare any face templates for comparison.');
      }

      _statusText = 'Scanning and recognizing face...';
      notifyListeners();

      final results = await _faceSdk.recognize(
        imagePath: _localImagePath!,
        profiles: profiles,
        mode: RecognitionMode.single,
        threshold: defaultFaceMatchThreshold,
      );

      if (results.isNotEmpty &&
          results.first.matched &&
          results.first.personId != null) {
        final matchedId = int.tryParse(results.first.personId!);
        if (matchedId != null) {
          _identifiedStudent = candidates.firstWhere((s) => s.id == matchedId);
          _confidenceScore = results.first.score * 100;
          _statusText = 'Student identified!';
        } else {
          _statusText = 'Face detected but no match found.';
        }
      } else {
        _statusText = 'Face detected but no match found.';
      }

      _isIdentifying = false;
      notifyListeners();
    } catch (e) {
      _isIdentifying = false;
      _statusText = 'Identification failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setIdentifiedStudent(Student student, double confidence) {
    _identifiedStudent = student;
    _confidenceScore = confidence;
    _statusText = 'Student identified via live scan!';
    _localImagePath = null;
    _imageSource = 'Live Video Stream';
    notifyListeners();
  }
}
