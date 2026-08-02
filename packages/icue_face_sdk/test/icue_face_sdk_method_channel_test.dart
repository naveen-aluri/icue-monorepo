import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icue_face_sdk/icue_face_sdk.dart';
import 'package:icue_face_sdk/icue_face_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelIcueFaceSdk();
  const channel = MethodChannel('icue_face_sdk');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'initialize' ||
            'dispose' ||
            'startFaceTracking' ||
            'stopFaceTracking' => null,
            'getInfo' => <String, Object>{
              'sdkVersion': '0.1.0',
              'modelName': 'mobilefacenet.tflite',
              'embeddingSize': faceEmbeddingSize,
            },
            'extractEmbedding' => Float32List(faceEmbeddingSize),
            'captureEmbeddingWithCamera' => Float32List(faceEmbeddingSize),
            'detectFaces' => <Object>[
              <String, double>{'left': 1, 'top': 2, 'right': 11, 'bottom': 22},
            ],
            _ => throw PlatformException(code: 'TEST_ERROR', message: 'failed'),
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('passes configuration and parses SDK information', () async {
    await platform.initialize(
      const FaceSdkConfig(accelerator: FaceSdkAccelerator.gpu, numThreads: 3),
    );
    final info = await platform.getInfo();

    expect(calls.first.arguments, <String, Object>{
      'accelerator': 'gpu',
      'numThreads': 3,
    });
    expect(info.sdkVersion, '0.1.0');
    expect(info.embeddingSize, faceEmbeddingSize);
  });

  test('preserves typed embeddings and bounding boxes', () async {
    final embedding = await platform.extractEmbedding(
      imagePath: '/face.jpg',
      isFrontCamera: false,
    );
    final boxes = await platform.detectFaces(
      imagePath: '/face.jpg',
      isFrontCamera: false,
    );

    expect(embedding, isA<Float32List>());
    expect(embedding, hasLength(faceEmbeddingSize));
    expect(boxes.single.width, 10);
    expect(boxes.single.height, 20);
  });

  test('maps PlatformException to IcueFaceSdkException', () async {
    expect(
      () => platform.compareEmbeddings(first: const [1], second: const [1]),
      throwsA(
        isA<IcueFaceSdkException>().having(
          (error) => error.code,
          'code',
          'TEST_ERROR',
        ),
      ),
    );
  });

  test('passes camera lens to capture and tracking calls', () async {
    final profile = FaceProfile(
      personId: 'Alex',
      embedding: List<double>.filled(faceEmbeddingSize, 0),
    );
    final embedding = await platform.captureEmbeddingWithCamera(
      lens: CameraLens.back,
    );
    await platform.startFaceTracking(
      profiles: <FaceProfile>[profile],
      lens: CameraLens.front,
      maxFaces: defaultMaximumFaces,
      threshold: defaultFaceMatchThreshold,
    );
    await platform.stopFaceTracking();

    expect(embedding, hasLength(faceEmbeddingSize));
    expect(calls[0].method, 'captureEmbeddingWithCamera');
    expect(calls[0].arguments, <String, Object>{'lens': 'back'});
    expect(calls[1].method, 'startFaceTracking');
    expect(calls[1].arguments, <String, Object>{
      'profiles': <Object>[profile.toMap()],
      'lens': 'front',
      'mode': 'MULTI',
      'maxFaces': defaultMaximumFaces,
      'threshold': defaultFaceMatchThreshold,
    });
    expect(calls[2].method, 'stopFaceTracking');
  });
}
