package school.icue.face.core.camera

import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import java.lang.ref.WeakReference
import java.util.UUID
import school.icue.face.core.FaceSdkDefaults
import school.icue.face.core.IcueFaceSdk
import school.icue.face.core.model.IcueFaceProfile

object IcueFaceCamera {
    fun openCapture(
        activity: Activity,
        sdk: IcueFaceSdk,
        lens: IcueCameraLens = IcueCameraLens.FRONT,
        callback: CaptureCallback,
    ) {
        val sessionId = CameraSessionRegistry.registerCapture(sdk, callback)
        activity.startActivity(cameraIntent(activity, sessionId, MODE_CAPTURE, lens))
    }

    fun startTracking(
        activity: Activity,
        sdk: IcueFaceSdk,
        profiles: List<IcueFaceProfile> = emptyList(),
        lens: IcueCameraLens = IcueCameraLens.FRONT,
        maxFaces: Int = FaceSdkDefaults.DEFAULT_MAX_FACES,
        threshold: Float = FaceSdkDefaults.DEFAULT_MATCH_THRESHOLD,
        listener: TrackingListener,
    ) {
        val sessionId = CameraSessionRegistry.registerTracking(
            sdk,
            profiles,
            maxFaces,
            threshold,
            listener,
        )
        activity.startActivity(cameraIntent(activity, sessionId, MODE_TRACKING, lens))
    }

    fun stop() {
        CameraSessionRegistry.stopActiveActivity()
    }

    interface CaptureCallback {
        fun onCaptured(embedding: FloatArray)
        fun onCancelled()
        fun onError(code: String, message: String)
    }

    interface TrackingListener {
        fun onFaces(result: IcueFaceTrackingResult)
        fun onStopped()
        fun onError(code: String, message: String)
    }

    private fun cameraIntent(
        activity: Activity,
        sessionId: String,
        mode: String,
        lens: IcueCameraLens,
    ) = Intent(activity, IcueFaceCameraActivity::class.java).apply {
        putExtra(EXTRA_SESSION_ID, sessionId)
        putExtra(EXTRA_MODE, mode)
        putExtra(EXTRA_LENS, lens.name)
    }

    internal const val EXTRA_SESSION_ID = "icue.camera.session_id"
    internal const val EXTRA_MODE = "icue.camera.mode"
    internal const val EXTRA_LENS = "icue.camera.lens"
    internal const val MODE_CAPTURE = "capture"
    internal const val MODE_TRACKING = "tracking"
}

internal sealed interface CameraSession {
    val sdk: IcueFaceSdk

    data class Capture(
        override val sdk: IcueFaceSdk,
        val callback: IcueFaceCamera.CaptureCallback,
    ) : CameraSession

    data class Tracking(
        override val sdk: IcueFaceSdk,
        val profiles: List<IcueFaceProfile>,
        val maxFaces: Int,
        val threshold: Float,
        val listener: IcueFaceCamera.TrackingListener,
    ) : CameraSession
}

internal object CameraSessionRegistry {
    private val lock = Any()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var sessionId: String? = null
    private var session: CameraSession? = null
    private var activity = WeakReference<IcueFaceCameraActivity>(null)
    private var launchTimeoutRunnable: Runnable? = null

    fun registerCapture(sdk: IcueFaceSdk, callback: IcueFaceCamera.CaptureCallback): String =
        register(CameraSession.Capture(sdk, callback))

    fun registerTracking(
        sdk: IcueFaceSdk,
        profiles: List<IcueFaceProfile>,
        maxFaces: Int,
        threshold: Float,
        listener: IcueFaceCamera.TrackingListener,
    ): String = register(
        CameraSession.Tracking(sdk, profiles.toList(), maxFaces, threshold, listener),
    )

    private fun register(newSession: CameraSession): String = synchronized(lock) {
        check(session == null) { "A face camera session is already active" }
        cancelTimeoutLocked()
        val id = UUID.randomUUID().toString()
        sessionId = id
        session = newSession
        val timeoutTask = Runnable {
            synchronized(lock) {
                if (sessionId == id && activity.get() == null) {
                    val expiredSession = session
                    sessionId = null
                    session = null
                    activity.clear()
                    when (expiredSession) {
                        is CameraSession.Capture -> expiredSession.callback.onError(
                            "CAMERA_LAUNCH_TIMEOUT",
                            "Camera activity failed to launch in time",
                        )
                        is CameraSession.Tracking -> expiredSession.listener.onError(
                            "CAMERA_LAUNCH_TIMEOUT",
                            "Camera activity failed to launch in time",
                        )
                        null -> Unit
                    }
                }
            }
        }
        launchTimeoutRunnable = timeoutTask
        mainHandler.postDelayed(timeoutTask, 5000)
        id
    }

    fun resolve(id: String?): CameraSession? = synchronized(lock) {
        session.takeIf { id != null && id == sessionId }
    }

    fun attach(cameraActivity: IcueFaceCameraActivity) = synchronized(lock) {
        activity = WeakReference(cameraActivity)
        cancelTimeoutLocked()
    }

    fun stopActiveActivity() {
        val activeActivity = synchronized(lock) { activity.get() }
        if (activeActivity != null) {
            activeActivity.runOnUiThread { activeActivity.finish() }
            return
        }
        val stoppedSession = synchronized(lock) {
            cancelTimeoutLocked()
            session.also {
                sessionId = null
                session = null
                activity.clear()
            }
        }
        mainHandler.post {
            when (stoppedSession) {
                is CameraSession.Capture -> stoppedSession.callback.onCancelled()
                is CameraSession.Tracking -> stoppedSession.listener.onStopped()
                null -> Unit
            }
        }
    }

    fun clear(id: String?) = synchronized(lock) {
        if (id == sessionId) {
            cancelTimeoutLocked()
            sessionId = null
            session = null
            activity.clear()
        }
    }

    private fun cancelTimeoutLocked() {
        launchTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        launchTimeoutRunnable = null
    }
}
