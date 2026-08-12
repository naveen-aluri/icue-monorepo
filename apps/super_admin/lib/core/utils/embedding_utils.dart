import 'dart:convert';
import 'dart:typed_data';

/// Utility functions to serialize and deserialize embedding vectors to/from Base64.
class EmbeddingUtils {
  /// Encodes a list of doubles (embeddings) into a Base64 string.
  ///
  /// Uses 32-bit floats (4 bytes per number) in Little Endian format by default
  /// to keep the representation compact and compatible with native SDKs.
  static String encode(
    List<double> embedding, {
    Endian endian = Endian.little,
  }) {
    final bytes = Uint8List(embedding.length * 4);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < embedding.length; i++) {
      byteData.setFloat32(i * 4, embedding[i], endian);
    }
    return base64Encode(bytes);
  }

  /// Decodes a Base64 string back into a list of doubles.
  ///
  /// Expects 32-bit floats (4 bytes per number) in Little Endian format by default.
  static List<double> decode(
    String base64String, {
    Endian endian = Endian.little,
  }) {
    final bytes = base64Decode(base64String);
    final byteData = ByteData.sublistView(bytes);
    final length = bytes.length ~/ 4;
    final embedding = List<double>.filled(length, 0.0);
    for (var i = 0; i < length; i++) {
      embedding[i] = byteData.getFloat32(i * 4, endian);
    }
    return embedding;
  }
}
