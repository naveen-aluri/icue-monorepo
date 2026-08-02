package school.icue.face.core.camera

import android.Manifest
import android.animation.ValueAnimator
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.ColorStateList
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.RippleDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import school.icue.face.core.FaceSdkErrorCode
import school.icue.face.core.FaceSdkException
import school.icue.face.core.model.IcueBoundingBox
import school.icue.face.core.model.IcueYuv420Frame
import school.icue.face.core.model.RecognitionMode

class IcueFaceCameraActivity : ComponentActivity() {
    private val analysisExecutor = Executors.newSingleThreadExecutor()
    private val analysisScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val processing = AtomicBoolean(false)
    private lateinit var previewView: PreviewView
    private lateinit var overlay: FaceOverlayView
    private lateinit var statusPill: TextView
    private var shutterButton: FrameLayout? = null
    private var flashOverlay: View? = null
    private var sessionId: String? = null
    private var session: CameraSession? = null
    private var captureRequested = false
    private var completed = false
    private var capturedEmbedding: FloatArray? = null
    private var frontCamera = true
    private val cameraPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { granted ->
        if (granted) {
            startCamera()
        } else {
            fail("CAMERA_PERMISSION_DENIED", "Camera permission was denied")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        sessionId = intent.getStringExtra(IcueFaceCamera.EXTRA_SESSION_ID)
        session = CameraSessionRegistry.resolve(sessionId)
        if (session == null) {
            finish()
            return
        }
        frontCamera = intent.getStringExtra(IcueFaceCamera.EXTRA_LENS) != IcueCameraLens.BACK.name
        CameraSessionRegistry.attach(this)
        buildContent()
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            startCamera()
        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    override fun onDestroy() {
        analysisScope.cancel()
        analysisExecutor.shutdown()
        val embedding = capturedEmbedding
        val activeSession = session
        super.onDestroy()
        when {
            embedding != null && activeSession is CameraSession.Capture ->
                activeSession.callback.onCaptured(embedding)
            !completed -> notifyStopped()
        }
        CameraSessionRegistry.clear(sessionId)
    }

    private fun buildContent() {
        previewView = PreviewView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
            scaleType = PreviewView.ScaleType.FILL_CENTER
        }
        overlay = FaceOverlayView(this)

        flashOverlay = View(this).apply {
            setBackgroundColor(Color.WHITE)
            alpha = 0f
        }

        statusPill = TextView(this).apply {
            setTextColor(COLOR_TEXT_PRIMARY)
            textSize = 12f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            letterSpacing = 0.06f
            gravity = Gravity.CENTER
            setPadding(dp(14), dp(8), dp(14), dp(8))
            background = roundedPill(0xCC0B1422.toInt(), 0x4400E5FF.toInt())
            text = if (session is CameraSession.Capture) {
                "⚠️ Position student face in frame"
            } else {
                "ATTENDANCE • SCANNING CLASSROOM"
            }
        }

        val topScrim = View(this).apply {
            background = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(0xCC050B14.toInt(), Color.TRANSPARENT),
            )
        }
        val bottomScrim = View(this).apply {
            background = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(Color.TRANSPARENT, 0xCC050B14.toInt()),
            )
        }

        val titleStack = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(TextView(this@IcueFaceCameraActivity).apply {
                text = if (session is CameraSession.Capture) "STUDENT ENROLLMENT" else "STUDENT ATTENDANCE SCAN"
                setTextColor(COLOR_ACCENT_CYAN)
                textSize = 13f
                letterSpacing = 0.18f
                typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            })
            addView(TextView(this@IcueFaceCameraActivity).apply {
                text = "iCue School Vision · on-device"
                setTextColor(COLOR_TEXT_SECONDARY)
                textSize = 11f
                setPadding(0, dp(2), 0, 0)
            })
        }

        val cameraFlipBtn = FrameLayout(this).apply {
            background = roundedRipple(0x66101B2B.toInt(), 0x44FFFFFF, 22f, 0x4400E5FF.toInt())
            contentDescription = "Switch Camera Lens"
            addView(CameraFlipIconView(this@IcueFaceCameraActivity), FrameLayout.LayoutParams(dp(22), dp(22), Gravity.CENTER))
            setOnClickListener {
                frontCamera = !frontCamera
                startCamera()
            }
        }

        val closeBtn = TextView(this).apply {
            text = "✕"
            textSize = 18f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            contentDescription = "Close session"
            background = roundedRipple(0x66101B2B.toInt(), 0x44FFFFFF, 22f, 0x33FFFFFF)
            setOnClickListener { finish() }
        }

        val topControls = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            addView(cameraFlipBtn, LinearLayout.LayoutParams(dp(42), dp(42)).apply { marginEnd = dp(8) })
            addView(closeBtn, LinearLayout.LayoutParams(dp(42), dp(42)))
        }

        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            addView(titleStack, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
            addView(topControls, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        }

        val topPillContainer = FrameLayout(this).apply {
            addView(statusPill, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER))
        }

        // Floating Circular Shutter Button for Capture mode (No bottom card panel!)
        if (session is CameraSession.Capture) {
            val outerRing = View(this).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setStroke(dp(3), COLOR_ACCENT_GREEN)
                    setColor(Color.TRANSPARENT)
                }
            }
            val innerDot = View(this).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(COLOR_ACCENT_GREEN)
                }
            }
            shutterButton = FrameLayout(this).apply {
                contentDescription = "Enroll Student Face"
                addView(outerRing, FrameLayout.LayoutParams(dp(72), dp(72), Gravity.CENTER))
                addView(innerDot, FrameLayout.LayoutParams(dp(54), dp(54), Gravity.CENTER))
                isEnabled = false
                alpha = 0.35f
                setOnClickListener {
                    isEnabled = false
                    alpha = 0.55f
                    captureRequested = true
                    statusPill.text = "Processing student biometric embedding..."
                    triggerCaptureFlash()
                }
            }
        }

        val root = FrameLayout(this).apply {
            setBackgroundColor(Color.BLACK)
            addView(previewView)
            addView(topScrim, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(180),
                Gravity.TOP,
            ))
            if (session is CameraSession.Capture) {
                addView(bottomScrim, FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dp(160),
                    Gravity.BOTTOM,
                ))
            }
            addView(this@IcueFaceCameraActivity.overlay, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ))
            addView(this@IcueFaceCameraActivity.flashOverlay, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ))
            addView(topBar, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.TOP,
            ).apply {
                leftMargin = dp(20)
                rightMargin = dp(20)
                topMargin = dp(12)
            })
            addView(topPillContainer, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.TOP,
            ).apply {
                topMargin = dp(68)
            })

            shutterButton?.let { shutter ->
                addView(shutter, FrameLayout.LayoutParams(
                    dp(76),
                    dp(76),
                    Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL,
                ).apply {
                    bottomMargin = dp(32)
                })
            }
        }

        WindowInsetsControllerCompat(window, root).apply {
            isAppearanceLightStatusBars = false
            isAppearanceLightNavigationBars = false
        }
        ViewCompat.setOnApplyWindowInsetsListener(root) { _, windowInsets ->
            val safeInsets = windowInsets.getInsets(
                WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout(),
            )
            (topBar.layoutParams as FrameLayout.LayoutParams).apply {
                leftMargin = safeInsets.left + dp(20)
                topMargin = safeInsets.top + dp(12)
                rightMargin = safeInsets.right + dp(20)
                topBar.layoutParams = this
            }
            (topPillContainer.layoutParams as FrameLayout.LayoutParams).apply {
                topMargin = safeInsets.top + dp(68)
                topPillContainer.layoutParams = this
            }
            shutterButton?.let { shutter ->
                (shutter.layoutParams as FrameLayout.LayoutParams).apply {
                    bottomMargin = safeInsets.bottom + dp(32)
                    shutter.layoutParams = this
                }
            }
            windowInsets
        }
        setContentView(root)
        ViewCompat.requestApplyInsets(root)
    }

    private fun triggerCaptureFlash() {
        flashOverlay?.apply {
            alpha = 0.85f
            animate()
                .alpha(0f)
                .setDuration(350)
                .start()
        }
    }

    private fun roundedPill(bgColor: Int, strokeColor: Int) = GradientDrawable().apply {
        cornerRadius = dp(20).toFloat()
        setColor(bgColor)
        setStroke(dp(1), strokeColor)
    }

    private fun roundedRipple(
        color: Int,
        rippleColor: Int,
        radiusDp: Float,
        strokeColor: Int,
    ): RippleDrawable {
        val content = GradientDrawable().apply {
            cornerRadius = dp(radiusDp.toInt()).toFloat()
            setColor(color)
            if (strokeColor != Color.TRANSPARENT) setStroke(dp(1), strokeColor)
        }
        val mask = GradientDrawable().apply {
            cornerRadius = dp(radiusDp.toInt()).toFloat()
            setColor(Color.WHITE)
        }
        return RippleDrawable(ColorStateList.valueOf(rippleColor), content, mask)
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private companion object {
        val COLOR_ACCENT_CYAN = 0xFF00E5FF.toInt()
        val COLOR_ACCENT_GREEN = 0xFF00E676.toInt()
        val COLOR_TEXT_PRIMARY = 0xFFF1F5F9.toInt()
        val COLOR_TEXT_SECONDARY = 0xFF94A3B8.toInt()
    }

    private fun startCamera() {
        val providerFuture = ProcessCameraProvider.getInstance(this)
        providerFuture.addListener({
            try {
                val provider = providerFuture.get()
                val preview = Preview.Builder().build().also {
                    it.surfaceProvider = previewView.surfaceProvider
                }
                val analysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                    .build()
                analysis.setAnalyzer(analysisExecutor, ::analyze)
                val selector = if (frontCamera) {
                    CameraSelector.DEFAULT_FRONT_CAMERA
                } else {
                    CameraSelector.DEFAULT_BACK_CAMERA
                }
                provider.unbindAll()
                provider.bindToLifecycle(this, selector, preview, analysis)
            } catch (error: Throwable) {
                fail("CAMERA_UNAVAILABLE", error.message ?: "Unable to open camera")
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun analyze(image: ImageProxy) {
        if (!processing.compareAndSet(false, true)) {
            image.close()
            return
        }
        val frame = try {
            image.toIcueFrame(frontCamera)
        } catch (error: Throwable) {
            processing.set(false)
            image.close()
            fail("CAMERA_FRAME_ERROR", error.message ?: "Unable to read camera frame")
            return
        }
        image.close()
        analysisScope.launch {
            try {
                when (val activeSession = session) {
                    is CameraSession.Capture -> processCapture(activeSession, frame)
                    is CameraSession.Tracking -> processTracking(activeSession, frame)
                    null -> Unit
                }
            } finally {
                processing.set(false)
            }
        }
    }

    private suspend fun processCapture(
        activeSession: CameraSession.Capture,
        frame: IcueYuv420Frame,
    ) {
        if (!captureRequested) {
            val faces = activeSession.sdk.detectFacesInYuv420(frame)
            showFaces(faces, frame)
            return
        }
        captureRequested = false
        try {
            val embedding = activeSession.sdk.extractEmbeddingFromYuv420(frame)
            capturedEmbedding = embedding.copyOf()
            completed = true
            runOnUiThread {
                statusPill.text = "Student face captured"
                finish()
            }
        } catch (error: FaceSdkException) {
            if (error.code == FaceSdkErrorCode.NO_FACE ||
                error.code == FaceSdkErrorCode.MULTIPLE_FACES
            ) {
                runOnUiThread {
                    statusPill.text = error.message
                    shutterButton?.apply {
                        isEnabled = false
                        alpha = 0.35f
                    }
                }
            } else {
                fail(error.code.name, error.message ?: "Student enrollment capture failed")
            }
        } catch (error: Throwable) {
            fail("CAPTURE_FAILED", error.message ?: "Student enrollment capture failed")
        }
    }

    private suspend fun processTracking(
        activeSession: CameraSession.Tracking,
        frame: IcueYuv420Frame,
    ) {
        try {
            val recognitions = if (activeSession.profiles.isEmpty()) {
                emptyList()
            } else {
                activeSession.sdk.recognizeYuv420(
                    frame = frame,
                    profiles = activeSession.profiles,
                    mode = RecognitionMode.MULTI,
                    maxFaces = activeSession.maxFaces,
                    threshold = activeSession.threshold,
                )
            }
            val faces = if (activeSession.profiles.isEmpty()) {
                activeSession.sdk.detectFacesInYuv420(frame)
            } else {
                recognitions.map { it.boundingBox }
            }
            val (width, height) = frame.outputDimensions()
            val result = IcueFaceTrackingResult(
                faces = faces,
                recognitions = recognitions,
                frameWidth = width,
                frameHeight = height,
                timestampMillis = System.currentTimeMillis(),
            )
            val matchCount = recognitions.count { it.matched }
            runOnUiThread {
                overlay.update(
                    faces,
                    width,
                    height,
                    recognitions.map { recognition ->
                        if (recognition.matched) {
                            "${recognition.personId} • ${(recognition.score * 100).toInt()}%"
                        } else {
                            "UNREGISTERED STUDENT"
                        }
                    },
                )
                statusPill.text = when {
                    activeSession.profiles.isEmpty() -> "ATTENDANCE • TRACKING ${faces.size} STUDENT(S)"
                    faces.isEmpty() -> "ATTENDANCE • SCANNING CLASSROOM"
                    else -> "ATTENDANCE • ${faces.size} STUDENT(S) (${matchCount} RECOGNIZED)"
                }
                statusPill.background = roundedPill(0xCC0B1422.toInt(), 0x6600E5FF.toInt())
                activeSession.listener.onFaces(result)
            }
        } catch (error: Throwable) {
            val code = (error as? FaceSdkException)?.code?.name ?: "TRACKING_FAILED"
            fail(code, error.message ?: "Attendance tracking failed")
        }
    }

    private fun showFaces(faces: List<IcueBoundingBox>, frame: IcueYuv420Frame) {
        val (width, height) = frame.outputDimensions()
        runOnUiThread {
            overlay.update(faces, width, height)
            when (faces.size) {
                0 -> {
                    statusPill.text = "⚠️ Position student face in frame"
                    statusPill.background = roundedPill(0xDD2A1800.toInt(), 0xAAFFB300.toInt())
                    shutterButton?.apply {
                        isEnabled = false
                        alpha = 0.35f
                    }
                }
                1 -> {
                    statusPill.text = "Student face locked • Tap to enroll"
                    statusPill.background = roundedPill(0xDD092418.toInt(), 0xAA00E676.toInt())
                    shutterButton?.apply {
                        isEnabled = true
                        alpha = 1.0f
                    }
                }
                else -> {
                    statusPill.text = "⚠️ Multiple students • Position single student"
                    statusPill.background = roundedPill(0xDD2A1800.toInt(), 0xAAFFB300.toInt())
                    shutterButton?.apply {
                        isEnabled = false
                        alpha = 0.35f
                    }
                }
            }
        }
    }

    private fun fail(code: String, message: String) {
        if (completed || isFinishing) return
        completed = true
        runOnUiThread {
            when (val activeSession = session) {
                is CameraSession.Capture -> activeSession.callback.onError(code, message)
                is CameraSession.Tracking -> activeSession.listener.onError(code, message)
                null -> Unit
            }
            finish()
        }
    }

    private fun notifyStopped() {
        when (val activeSession = session) {
            is CameraSession.Capture -> activeSession.callback.onCancelled()
            is CameraSession.Tracking -> activeSession.listener.onStopped()
            null -> Unit
        }
    }

    private fun ImageProxy.toIcueFrame(mirror: Boolean): IcueYuv420Frame {
        require(planes.size == 3) { "Expected a YUV_420_888 frame" }
        return IcueYuv420Frame(
            yBytes = planes[0].buffer.copyRemaining(),
            uBytes = planes[1].buffer.copyRemaining(),
            vBytes = planes[2].buffer.copyRemaining(),
            width = width,
            height = height,
            yRowStride = planes[0].rowStride,
            uRowStride = planes[1].rowStride,
            vRowStride = planes[2].rowStride,
            uPixelStride = planes[1].pixelStride,
            vPixelStride = planes[2].pixelStride,
            rotationDegrees = imageInfo.rotationDegrees,
            mirrorHorizontally = mirror,
        )
    }

    private fun java.nio.ByteBuffer.copyRemaining(): ByteArray = duplicate().let { buffer ->
        ByteArray(buffer.remaining()).also(buffer::get)
    }

    private fun IcueYuv420Frame.outputDimensions(): Pair<Int, Int> =
        if (rotationDegrees == 90 || rotationDegrees == 270) height to width else width to height
}

private class CameraFlipIconView(context: Context) : View(context) {
    private val density = resources.displayMetrics.density
    private val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 2.2f * density
        strokeCap = Paint.Cap.ROUND
    }
    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.FILL
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val cx = width / 2f
        val cy = height / 2f
        val radius = width * 0.32f

        val oval = RectF(cx - radius, cy - radius, cx + radius, cy + radius)
        canvas.drawArc(oval, 200f, 130f, false, strokePaint)
        canvas.drawArc(oval, 20f, 130f, false, strokePaint)

        // Arrowhead 1 (top right)
        val p1 = Path().apply {
            moveTo(cx + radius * 0.95f, cy - radius * 0.75f)
            lineTo(cx + radius * 1.15f, cy - radius * 0.15f)
            lineTo(cx + radius * 0.45f, cy - radius * 0.3f)
            close()
        }
        canvas.drawPath(p1, fillPaint)

        // Arrowhead 2 (bottom left)
        val p2 = Path().apply {
            moveTo(cx - radius * 0.95f, cy + radius * 0.75f)
            lineTo(cx - radius * 1.15f, cy + radius * 0.15f)
            lineTo(cx - radius * 0.45f, cy + radius * 0.3f)
            close()
        }
        canvas.drawPath(p2, fillPaint)
    }
}

private class FaceOverlayView(activity: Activity) : View(activity) {
    private val density = resources.displayMetrics.density

    // Animators
    private var scanProgress = 0f
    private var pulseProgress = 1f
    private val scanAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
        duration = 1800
        repeatMode = ValueAnimator.REVERSE
        repeatCount = ValueAnimator.INFINITE
        interpolator = AccelerateDecelerateInterpolator()
        addUpdateListener {
            scanProgress = it.animatedValue as Float
            invalidate()
        }
    }
    private val pulseAnimator = ValueAnimator.ofFloat(0.92f, 1.05f).apply {
        duration = 1200
        repeatMode = ValueAnimator.REVERSE
        repeatCount = ValueAnimator.INFINITE
        interpolator = AccelerateDecelerateInterpolator()
        addUpdateListener {
            pulseProgress = it.animatedValue as Float
            invalidate()
        }
    }

    init {
        scanAnimator.start()
        pulseAnimator.start()
    }

    // Paints
    private val reticlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x8800E5FF.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 2f * density
        pathEffect = DashPathEffect(floatArrayOf(12f * density, 8f * density), 0f)
    }

    private val reticleTickPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFF00E5FF.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 3f * density
        strokeCap = Paint.Cap.ROUND
    }

    private val reticleTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xDD00E5FF.toInt()
        textSize = 11f * density
        typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
        textAlign = Paint.Align.CENTER
        letterSpacing = 0.15f
    }

    private val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x4400E5FF.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 12f * density
        strokeCap = Paint.Cap.ROUND
    }

    private val bracketPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFF00E5FF.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 3f * density
        strokeCap = Paint.Cap.ROUND
    }

    private val scanLinePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFF00E5FF.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 2.5f * density
        strokeCap = Paint.Cap.ROUND
    }

    private val labelBackgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xEE0B1422.toInt()
        style = Paint.Style.FILL
    }

    private val labelStrokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x6600E5FF.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 1f * density
    }

    private val labelTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textSize = 12f * density
        typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
    }

    private var faces: List<IcueBoundingBox> = emptyList()
    private var labels: List<String?> = emptyList()
    private var sourceWidth = 1
    private var sourceHeight = 1

    fun update(
        newFaces: List<IcueBoundingBox>,
        width: Int,
        height: Int,
        newLabels: List<String?> = emptyList(),
    ) {
        faces = newFaces
        labels = newLabels
        sourceWidth = width.coerceAtLeast(1)
        sourceHeight = height.coerceAtLeast(1)
        invalidate()
    }

    override fun onDetachedFromWindow() {
        scanAnimator.cancel()
        pulseAnimator.cancel()
        super.onDetachedFromWindow()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val scale = maxOf(width.toFloat() / sourceWidth, height.toFloat() / sourceHeight)
        val offsetX = (width - sourceWidth * scale) / 2f
        val offsetY = (height - sourceHeight * scale) / 2f

        if (faces.isEmpty()) {
            drawCenterReticle(canvas)
        } else {
            faces.forEachIndexed { index, face ->
                val rect = RectF(
                    offsetX + face.left * scale,
                    offsetY + face.top * scale,
                    offsetX + face.right * scale,
                    offsetY + face.bottom * scale,
                )
                val label = labels.getOrNull(index)
                val isMatched = label != null && label != "UNREGISTERED STUDENT" && label.isNotBlank()
                val mainColor = if (isMatched) 0xFF00E676.toInt() else 0xFF00E5FF.toInt()

                bracketPaint.color = mainColor
                glowPaint.color = (mainColor and 0x00FFFFFF) or 0x33000000
                scanLinePaint.color = mainColor

                drawCyberBrackets(canvas, rect)
                drawLaserScanLine(canvas, rect)
                label?.takeIf { it.isNotBlank() }?.let { text ->
                    drawCyberLabel(canvas, rect, text, mainColor)
                }
            }
        }
    }

    private fun drawCenterReticle(canvas: Canvas) {
        val centerX = width / 2f
        val centerY = height * 0.42f
        val rx = (width * 0.32f) * pulseProgress
        val ry = (width * 0.42f) * pulseProgress

        val oval = RectF(centerX - rx, centerY - ry, centerX + rx, centerY + ry)
        canvas.drawOval(oval, reticlePaint)

        // Draw crosshair corner marks
        val tickLen = 20f * density
        // Top
        canvas.drawLine(centerX, oval.top - tickLen, centerX, oval.top + tickLen, reticleTickPaint)
        // Bottom
        canvas.drawLine(centerX, oval.bottom - tickLen, centerX, oval.bottom + tickLen, reticleTickPaint)
        // Left
        canvas.drawLine(oval.left - tickLen, centerY, oval.left + tickLen, centerY, reticleTickPaint)
        // Right
        canvas.drawLine(oval.right - tickLen, centerY, oval.right + tickLen, centerY, reticleTickPaint)

        // Scanning beam through center reticle
        val scanY = oval.top + (oval.height() * scanProgress)
        canvas.drawLine(oval.left + 10f * density, scanY, oval.right - 10f * density, scanY, scanLinePaint)

        canvas.drawText("ALIGN STUDENT FACE WITHIN RETICLE", centerX, oval.bottom + 36f * density, reticleTextPaint)
    }

    private fun drawCyberBrackets(canvas: Canvas, rect: RectF) {
        val length = (minOf(rect.width(), rect.height()) * 0.24f)
            .coerceIn(20f * density, 48f * density)

        // Draw ambient glow outer
        canvas.drawRect(rect, glowPaint)

        // Draw corner tech brackets
        // Top-Left
        canvas.drawLine(rect.left, rect.top, rect.left + length, rect.top, bracketPaint)
        canvas.drawLine(rect.left, rect.top, rect.left, rect.top + length, bracketPaint)
        // Top-Right
        canvas.drawLine(rect.right, rect.top, rect.right - length, rect.top, bracketPaint)
        canvas.drawLine(rect.right, rect.top, rect.right, rect.top + length, bracketPaint)
        // Bottom-Left
        canvas.drawLine(rect.left, rect.bottom, rect.left + length, rect.bottom, bracketPaint)
        canvas.drawLine(rect.left, rect.bottom, rect.left, rect.bottom - length, bracketPaint)
        // Bottom-Right
        canvas.drawLine(rect.right, rect.bottom, rect.right - length, rect.bottom, bracketPaint)
        canvas.drawLine(rect.right, rect.bottom, rect.right, rect.bottom - length, bracketPaint)
    }

    private fun drawLaserScanLine(canvas: Canvas, rect: RectF) {
        val scanY = rect.top + (rect.height() * scanProgress)
        val pad = 4f * density
        canvas.drawLine(rect.left + pad, scanY, rect.right - pad, scanY, scanLinePaint)

        // Draw trailing beam gradient above/below scan line
        val trailHeight = 18f * density
        val gradientShader = LinearGradient(
            0f, scanY - trailHeight, 0f, scanY,
            intArrayOf(Color.TRANSPARENT, (scanLinePaint.color and 0x00FFFFFF) or 0x44000000),
            null,
            Shader.TileMode.CLAMP
        )
        val trailPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = gradientShader
            style = Paint.Style.FILL
        }
        canvas.drawRect(rect.left + pad, scanY - trailHeight, rect.right - pad, scanY, trailPaint)
    }

    private fun drawCyberLabel(canvas: Canvas, faceRect: RectF, label: String, strokeColor: Int) {
        val horizontalPadding = 12f * density
        val verticalPadding = 8f * density
        val displayLabel = ellipsizeLabel(label, width - 16f * density - horizontalPadding * 2)
        val textWidth = labelTextPaint.measureText(displayLabel)
        val metrics = labelTextPaint.fontMetrics
        val labelHeight = metrics.descent - metrics.ascent + verticalPadding * 2
        val labelWidth = textWidth + horizontalPadding * 2
        val left = faceRect.left.coerceIn(8f * density, width - labelWidth - 8f * density)
        val preferredTop = faceRect.top - labelHeight - 12f * density
        val top = if (preferredTop >= 8f * density) preferredTop else faceRect.top + 12f * density
        val labelRect = RectF(left, top, left + labelWidth, top + labelHeight)

        labelStrokePaint.color = (strokeColor and 0x00FFFFFF) or 0x66000000
        canvas.drawRoundRect(labelRect, 10f * density, 10f * density, labelBackgroundPaint)
        canvas.drawRoundRect(labelRect, 10f * density, 10f * density, labelStrokePaint)

        canvas.drawText(
            displayLabel,
            labelRect.left + horizontalPadding,
            labelRect.top + verticalPadding - metrics.ascent,
            labelTextPaint,
        )
    }

    private fun ellipsizeLabel(label: String, availableWidth: Float): String {
        if (labelTextPaint.measureText(label) <= availableWidth) return label
        val ellipsis = "…"
        var end = label.length
        while (end > 0 && labelTextPaint.measureText(label.substring(0, end) + ellipsis) > availableWidth) {
            end--
        }
        return label.substring(0, end) + ellipsis
    }
}
