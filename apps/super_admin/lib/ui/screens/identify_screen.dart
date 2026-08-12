import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:icue_face_sdk/icue_face_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection.dart';
import '../../core/storage/pref_service.dart';
import '../../data/models/student_model.dart';
import '../../providers/student_provider.dart';
import '../widgets/ambient_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  CameraDescription? _cameraDescription;
  late IcueFaceSdk _faceSdk;

  // Preparation & Candidate Database
  bool _isPreparing = true;
  String _statusText = 'Loading face embeddings from local storage...';
  double _prepProgress = 0.0;

  final List<FaceProfile> _faceProfiles = [];
  final Map<String, Student> _candidateStudentMap = {};
  bool _isProcessingFrame = false;

  // Real-time Recognition & Bounding Box Overlay State
  List<FaceRecognitionResult> _recognitionResults = [];
  int _imageWidth = 0;
  int _imageHeight = 0;

  // Performance State
  final List<double> _processingTimes = [];
  double _avgLatencyMs = 0.0;
  double _currentFps = 0.0;
  DateTime? _lastFrameTime;

  // For Mock Mode
  bool _isMockMode = false;

  @override
  void initState() {
    super.initState();
    _faceSdk = getIt<IcueFaceSdk>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPreparation();
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startPreparation() async {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final prefService = getIt<PrefService>();
    final candidates = studentProvider.filteredStudents;

    _faceProfiles.clear();
    _candidateStudentMap.clear();

    // Load embeddings exclusively from SharedPreferences
    for (int i = 0; i < candidates.length; i++) {
      final student = candidates[i];
      if (prefService.hasStudentEmbedding(student.id)) {
        final savedEmbedding = prefService.getStudentEmbedding(student.id);
        if (savedEmbedding != null) {
          _candidateStudentMap[student.id.toString()] = student;
          _faceProfiles.add(
            FaceProfile(
              personId: student.id.toString(),
              embedding: savedEmbedding.embedding,
            ),
          );
        }
      }
    }

    if (_faceProfiles.isEmpty) {
      setState(() {
        _isPreparing = false;
        _statusText =
            'No face embeddings found in local storage.\nPlease generate embeddings from the Student Directory screen first.';
      });
      return;
    }

    setState(() {
      _prepProgress = 1.0;
      _isPreparing = false;
      _statusText = 'Initializing camera stream...';
    });

    try {
      if (!Platform.isAndroid) {
        _startMockScanner(_candidateStudentMap.values.toList());
        return;
      }

      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        throw Exception('Camera permission denied.');
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras available.');
      }

      _cameraDescription = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      await _initCameraController();

      setState(() {
        _statusText = 'Align face within viewfinder';
      });
    } catch (e) {
      debugPrint('LiveScanner preparation failed: $e');
      _startMockScanner(_candidateStudentMap.values.toList());
    }
  }

  Future<void> _initCameraController() async {
    if (_cameraController != null) {
      final oldController = _cameraController;
      _cameraController = null;
      if (mounted) setState(() {});
      await oldController!.dispose();
    }

    final controller = CameraController(
      _cameraDescription!,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      await controller.startImageStream(_processCameraImage);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _toggleCameraLens() async {
    if (_cameras.length < 2) return;

    final currentLens = _cameraDescription!.lensDirection;
    final newDescription = _cameras.firstWhere(
      (cam) => cam.lensDirection != currentLens,
      orElse: () => _cameras.first,
    );

    setState(() {
      _cameraDescription = newDescription;
      _recognitionResults = [];
      _processingTimes.clear();
      _avgLatencyMs = 0.0;
      _currentFps = 0.0;
    });

    await _initCameraController();
  }

  void _startMockScanner(List<Student> candidates) {
    if (candidates.isEmpty) return;

    setState(() {
      _isMockMode = true;
      _isPreparing = false;
      _statusText = 'Running in Camera Mock Mode (iOS/Simulator)...';
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      final random = Random();
      final student1 = candidates[0];
      final student2 = candidates.length > 1 ? candidates[1] : candidates[0];
      final confidence1 = 94.0 + random.nextDouble() * 5.0;
      final confidence2 = 88.0 + random.nextDouble() * 8.0;

      setState(() {
        _statusText = 'Students Identified!';
        _recognitionResults = [
          FaceRecognitionResult(
            personId: student1.id.toString(),
            score: confidence1 / 100.0,
            matched: true,
            boundingBox: const FaceBoundingBox(
              left: 40.0,
              top: 200.0,
              right: 180.0,
              bottom: 340.0,
            ),
          ),
          if (candidates.length > 1)
            FaceRecognitionResult(
              personId: student2.id.toString(),
              score: confidence2 / 100.0,
              matched: true,
              boundingBox: const FaceBoundingBox(
                left: 210.0,
                top: 220.0,
                right: 350.0,
                bottom: 360.0,
              ),
            ),
        ];
        _imageWidth = 400;
        _imageHeight = 500;
      });
    });
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    final startTime = DateTime.now();

    try {
      final rotation = _cameraDescription!.sensorOrientation;

      if (_faceProfiles.isEmpty) {
        setState(() {
          _statusText = 'No registered student embeddings in local storage.';
        });
        return;
      }

      final isFrontCamera =
          _cameraDescription!.lensDirection == CameraLensDirection.front;

      final frame = IcueYuv420Frame(
        yBytes: image.planes[0].bytes,
        uBytes: image.planes[1].bytes,
        vBytes: image.planes[2].bytes,
        width: image.width,
        height: image.height,
        yRowStride: image.planes[0].bytesPerRow,
        uRowStride: image.planes[1].bytesPerRow,
        vRowStride: image.planes[2].bytesPerRow,
        uPixelStride: image.planes[1].bytesPerPixel ?? 1,
        vPixelStride: image.planes[2].bytesPerPixel ?? 1,
        rotationDegrees: rotation,
        mirrorHorizontally: isFrontCamera,
      );

      final results = await _faceSdk.recognizeInYuvFrame(
        frame: frame,
        profiles: _faceProfiles,
        mode: RecognitionMode.multi,
        threshold: defaultFaceMatchThreshold,
      );

      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;
      _updateMetrics(latency);

      final matchedCount = results
          .where((r) => r.matched && r.personId != null)
          .length;
      if (matchedCount > 0) {
        _statusText =
            '$matchedCount Student${matchedCount > 1 ? 's' : ''} Identified';
      }

      if (mounted) {
        setState(() {
          _recognitionResults = results;
          if (rotation == 90 || rotation == 270) {
            _imageWidth = image.height;
            _imageHeight = image.width;
          } else {
            _imageWidth = image.width;
            _imageHeight = image.height;
          }
        });
      }
    } catch (e) {
      debugPrint('Error processing camera frame: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _updateMetrics(int latency) {
    _processingTimes.add(latency.toDouble());
    if (_processingTimes.length > 15) {
      _processingTimes.removeAt(0);
    }
    _avgLatencyMs =
        _processingTimes.reduce((a, b) => a + b) / _processingTimes.length;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final diff = now.difference(_lastFrameTime!).inMilliseconds;
      if (diff > 0) {
        _currentFps = 1000.0 / diff;
      }
    }
    _lastFrameTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: _isPreparing || _faceProfiles.isEmpty
          ? AmbientBackground(child: _buildPreparingOrEmptyState())
          : Stack(
              fit: StackFit.expand,
              children: [
                if (_isMockMode)
                  Container(
                    color: const Color(0xFF06040A),
                    child: const Center(
                      child: Icon(
                        Icons.face_unlock_rounded,
                        size: 160,
                        color: Colors.white12,
                      ),
                    ),
                  )
                else if (_cameraController != null &&
                    _cameraController!.value.isInitialized)
                  CameraPreview(_cameraController!)
                else
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF),
                      ),
                    ),
                  ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: FacePainter(
                        results: _recognitionResults,
                        studentMap: _candidateStudentMap,
                        imageWidth: _imageWidth,
                        imageHeight: _imageHeight,
                        screenWidth: constraints.maxWidth,
                        screenHeight: constraints.maxHeight,
                        isFrontCamera:
                            _cameraDescription?.lensDirection ==
                            CameraLensDirection.front,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTopNavBar(),
                        const SizedBox(height: 8),
                        _buildTelemetryHUD(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: 18,
        bgColor: const Color(0x1AFFFFFF),
        bordercolor: const Color(0x336C63FF),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00E5FF),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text(
                          'ATTENDANCE SCANNER',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8C85FF),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                '${_faceProfiles.length} ENROLLED',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00E676),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (_cameras.length > 1) ...[
              const SizedBox(width: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleCameraLens,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.flip_camera_android_rounded,
                      color: Color(0xFF00E5FF),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryHUD() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: 16,
        bgColor: const Color(0x180F0C20),
        bordercolor: Colors.white.withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricColumn(
              'LATENCY',
              '${_avgLatencyMs.toStringAsFixed(0)} ms',
              _avgLatencyMs > 150
                  ? Colors.orangeAccent
                  : const Color(0xFF00E5FF),
            ),
            _buildMetricDivider(),
            _buildMetricColumn(
              'FPS',
              _currentFps.toStringAsFixed(1),
              _currentFps < 10
                  ? const Color(0xFFFF2A54)
                  : const Color(0xFF00E5FF),
            ),
            _buildMetricDivider(),
            _buildMetricColumn(
              'IDENTIFIED',
              '${_recognitionResults.where((r) => r.matched).length}',
              _recognitionResults.any((r) => r.matched)
                  ? const Color(0xFF00E676)
                  : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparingOrEmptyState() {
    final size = MediaQuery.of(context).size;
    final isEmptyState = !_isPreparing && _faceProfiles.isEmpty;

    return SafeArea(
      child: SizedBox(
        height: size.height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isPreparing) ...[
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const Icon(
                    Icons.no_cell_rounded,
                    size: 60,
                    color: Color(0xFFFF2A54),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  _statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isPreparing) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _prepProgress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C63FF),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
                if (isEmptyState) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 180,
                    child: CustomButton(
                      text: 'GO BACK',
                      height: 44,
                      borderRadius: 14,
                      fontSize: 13,
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(width: 1, height: 20, color: Colors.white12);
  }
}

class FacePainter extends CustomPainter {
  final List<FaceRecognitionResult> results;
  final Map<String, Student> studentMap;
  final int imageWidth;
  final int imageHeight;
  final double screenWidth;
  final double screenHeight;
  final bool isFrontCamera;

  FacePainter({
    required this.results,
    required this.studentMap,
    required this.imageWidth,
    required this.imageHeight,
    required this.screenWidth,
    required this.screenHeight,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth == 0 || imageHeight == 0 || results.isEmpty) return;

    final double frameRatio = imageWidth / imageHeight;
    final double screenRatio = screenWidth / screenHeight;

    final double scale = (screenRatio > frameRatio)
        ? screenWidth / imageWidth
        : screenHeight / imageHeight;

    final double actualWidth = imageWidth * scale;
    final double actualHeight = imageHeight * scale;

    final double offsetX = (screenWidth - actualWidth) / 2.0;
    final double offsetY = (screenHeight - actualHeight) / 2.0;

    final paintBox = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintCorner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final result in results) {
      final box = result.boundingBox;

      double left = offsetX + box.left * scale;
      double right = offsetX + box.right * scale;
      final double top = offsetY + box.top * scale;
      final double bottom = offsetY + box.bottom * scale;

      if (isFrontCamera) {
        final double tempLeft = screenWidth - right;
        final double tempRight = screenWidth - left;
        left = tempLeft;
        right = tempRight;
      }

      final rect = Rect.fromLTRB(left, top, right, bottom);

      final Color accentColor = result.matched
          ? const Color(0xFF00E676)
          : const Color(0xFFFF2A54);

      // 1. Faint background boundary
      paintBox.color = accentColor.withValues(alpha: 0.25);
      canvas.drawRect(rect, paintBox);

      // 2. Thick neon corner brackets
      paintCorner.color = accentColor;
      final double cornerLength = ((right - left) * 0.15).coerceAtMost(22.0);

      // Top Left
      canvas.drawLine(
        Offset(left, top),
        Offset(left + cornerLength, top),
        paintCorner,
      );
      canvas.drawLine(
        Offset(left, top),
        Offset(left, top + cornerLength),
        paintCorner,
      );
      // Top Right
      canvas.drawLine(
        Offset(right, top),
        Offset(right - cornerLength, top),
        paintCorner,
      );
      canvas.drawLine(
        Offset(right, top),
        Offset(right, top + cornerLength),
        paintCorner,
      );
      // Bottom Left
      canvas.drawLine(
        Offset(left, bottom),
        Offset(left + cornerLength, bottom),
        paintCorner,
      );
      canvas.drawLine(
        Offset(left, bottom),
        Offset(left, bottom - cornerLength),
        paintCorner,
      );
      // Bottom Right
      canvas.drawLine(
        Offset(right, bottom),
        Offset(right - cornerLength, bottom),
        paintCorner,
      );
      canvas.drawLine(
        Offset(right, bottom),
        Offset(right, bottom - cornerLength),
        paintCorner,
      );

      // 3. Floating AR Callout Box attached to bounding box
      final bool hasLabel =
          result.personId != null && result.personId!.isNotEmpty;
      final student = hasLabel ? studentMap[result.personId] : null;

      final String nameText = student != null
          ? student.name.toUpperCase()
          : (hasLabel
                ? result.personId!.toUpperCase()
                : 'UNREGISTERED VISITOR');
      final String matchText =
          '${(result.score * 100).toStringAsFixed(1)}% MATCH';
      final String idText = student != null
          ? 'ADM NO: ${student.admissionNumber}'
          : 'NO RECORD';
      final String classText = student != null
          ? 'CLASS ${student.standard}-${student.section}'
          : 'UNASSIGNED';

      textPainter.text = TextSpan(
        text: nameText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout();
      final double nameWidth = textPainter.width;

      textPainter.text = TextSpan(
        text: matchText,
        style: TextStyle(
          color: accentColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout();
      final double matchWidth = textPainter.width;

      textPainter.text = TextSpan(
        text: idText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 9.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final double idWidth = textPainter.width;

      final double cardWidth = (max(
        nameWidth + matchWidth + 24,
        idWidth + 20,
      )).coerceAtLeast(160.0);
      const double cardHeight = 52.0;

      double cardTop = top - cardHeight - 10;
      if (cardTop < 90) cardTop = bottom + 10;
      double cardLeft = left + (right - left - cardWidth) / 2.0;
      cardLeft = cardLeft.coerceIn(10.0, screenWidth - cardWidth - 10.0);

      final cardRect = Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight);
      final rRect = RRect.fromRectAndRadius(
        cardRect,
        const Radius.circular(10),
      );

      final glassBg = Paint()..color = const Color(0xCC0F0C20);
      canvas.drawRRect(rRect, glassBg);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = accentColor.withValues(alpha: 0.6)
        ..strokeWidth = 1.2;
      canvas.drawRRect(rRect, borderPaint);

      final leftPillPaint = Paint()..color = accentColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cardLeft, cardTop, 4, cardHeight),
          const Radius.circular(2),
        ),
        leftPillPaint,
      );

      textPainter.text = TextSpan(
        text: nameText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout(maxWidth: cardWidth - 70);
      textPainter.paint(canvas, Offset(cardLeft + 10, cardTop + 6));

      textPainter.text = TextSpan(
        text: matchText,
        style: TextStyle(
          color: accentColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(cardLeft + cardWidth - matchWidth - 8, cardTop + 7),
      );

      textPainter.text = TextSpan(
        text: idText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 9.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout(maxWidth: cardWidth - 16);
      textPainter.paint(canvas, Offset(cardLeft + 10, cardTop + 22));

      if (student != null) {
        textPainter.text = TextSpan(
          text: classText,
          style: const TextStyle(
            color: Color(0xFF8C85FF),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        );
        textPainter.layout(maxWidth: cardWidth - 16);
        textPainter.paint(canvas, Offset(cardLeft + 10, cardTop + 36));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension CoerceExtensionDouble on double {
  double coerceAtLeast(double minimumValue) =>
      this < minimumValue ? minimumValue : this;
  double coerceAtMost(double maximumValue) =>
      this > maximumValue ? maximumValue : this;
  double coerceIn(double min, double max) =>
      this < min ? min : (this > max ? max : this);
}
