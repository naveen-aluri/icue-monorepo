package school.icue.face.core

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint

/**
 * Aligns detected face landmarks to canonical 112x112 MobileFaceNet eye positions.
 *
 * Canonical coordinates:
 * - Left eye: (38.29, 51.69)
 * - Right eye: (73.53, 51.69)
 *
 * These coordinates correspond to standard MobileFaceNet affine alignment matrices.
 */
internal object FaceAlignment {
    fun alignToCanonicalEyes(
        bitmap: Bitmap,
        leftEyeX: Float,
        leftEyeY: Float,
        rightEyeX: Float,
        rightEyeY: Float,
    ): Bitmap? {
        val matrix = Matrix()
        val mapped = matrix.setPolyToPoly(
            floatArrayOf(leftEyeX, leftEyeY, rightEyeX, rightEyeY),
            0,
            floatArrayOf(
                FaceSdkDefaults.CANONICAL_LEFT_EYE_X,
                FaceSdkDefaults.CANONICAL_LEFT_EYE_Y,
                FaceSdkDefaults.CANONICAL_RIGHT_EYE_X,
                FaceSdkDefaults.CANONICAL_RIGHT_EYE_Y,
            ),
            0,
            2,
        )
        if (!mapped) return null

        return Bitmap.createBitmap(
            FaceSdkDefaults.MOBILEFACENET_INPUT_SIZE,
            FaceSdkDefaults.MOBILEFACENET_INPUT_SIZE,
            Bitmap.Config.ARGB_8888,
        ).also { aligned ->
            val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
            Canvas(aligned).drawBitmap(bitmap, matrix, paint)
        }
    }
}
