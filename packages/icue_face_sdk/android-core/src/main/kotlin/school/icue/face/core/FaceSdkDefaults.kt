package school.icue.face.core

object FaceSdkDefaults {
    const val MODEL_ASSET = "mobilefacenet.tflite"
    const val MOBILEFACENET_INPUT_SIZE = 112
    const val MOBILEFACENET_EMBEDDING_SIZE = 192
    const val DEFAULT_MATCH_THRESHOLD = 0.68f
    const val DEFAULT_MAX_FACES = 5

    const val CANONICAL_LEFT_EYE_X = 38.29f
    const val CANONICAL_LEFT_EYE_Y = 51.69f
    const val CANONICAL_RIGHT_EYE_X = 73.53f
    const val CANONICAL_RIGHT_EYE_Y = 51.69f

    fun defaultThreadCount(): Int =
        (Runtime.getRuntime().availableProcessors() - 1).coerceIn(1, 4)

    fun normalizeRgbChannel(value: Int): Float = (value - 127.5f) / 128.0f
}
