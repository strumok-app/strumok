package app.strumok

import android.app.Activity
import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import android.util.Rational
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

const val PIP_CHANNEL = "strumok/pip"

/** Bridges Android picture-in-picture mode with the Dart `AndroidPip` implementation. */
class PipHandler(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "PipHandler"
        private const val ACTION_PIP_CONTROL = "app.strumok.PIP_CONTROL"
        private const val EXTRA_ACTION = "action"

        // Android rejects aspect ratios outside 1:2.39 .. 2.39:1.
        private const val MIN_ASPECT_RATIO = 1.0 / 2.39
        private const val MAX_ASPECT_RATIO = 2.39
        private const val DEFAULT_ASPECT_RATIO = 16.0 / 9.0
    }

    private val channel = MethodChannel(messenger, PIP_CHANNEL)

    private var enabled = false
    private var isPlaying = false
    private var hasPrev = false
    private var hasNext = false
    private var showSkipButtons = false
    private var aspectRatio = DEFAULT_ASPECT_RATIO

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.getStringExtra(EXTRA_ACTION)?.let { sendAction(it) }
        }
    }

    val isSupported: Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    init {
        channel.setMethodCallHandler(this)
        ContextCompat.registerReceiver(
            activity,
            receiver,
            IntentFilter(ACTION_PIP_CONTROL),
            ContextCompat.RECEIVER_NOT_EXPORTED
        )
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        activity.unregisterReceiver(receiver)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(isSupported)
            "enable" -> {
                enabled = true
                applyParams()
                result.success(null)
            }
            "disable" -> {
                enabled = false
                applyParams()
                restore()
                result.success(null)
            }
            "update" -> {
                isPlaying = call.argument<Boolean>("isPlaying") ?: false
                hasPrev = call.argument<Boolean>("hasPrev") ?: false
                hasNext = call.argument<Boolean>("hasNext") ?: false
                showSkipButtons = call.argument<Boolean>("showSkipButtons") ?: false
                aspectRatio = call.argument<Double>("aspectRatio") ?: DEFAULT_ASPECT_RATIO
                applyParams()
                result.success(null)
            }
            "enter" -> result.success(enter())
            "exit" -> {
                restore()
                result.success(null)
            }
            "closeApp" -> {
                activity.finishAndRemoveTask()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Auto enter for Android < 12, newer versions use [PictureInPictureParams.Builder.setAutoEnterEnabled]. */
    fun onUserLeaveHint() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S && enabled) {
            enter()
        }
    }

    /** [dismissed] is true when the user closed the PIP window. */
    fun onPictureInPictureModeChanged(isInPip: Boolean, dismissed: Boolean) {
        channel.invokeMethod("onPipModeChanged", mapOf("active" to isInPip))
        if (!isInPip && dismissed) {
            sendAction("dismissed")
        }
    }

    private fun sendAction(action: String) {
        channel.invokeMethod("onAction", mapOf("action" to action))
    }

    private fun isInPip(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && activity.isInPictureInPictureMode

    private fun enter(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        if (!enabled || !isSupported || isInPip()) return false
        return try {
            activity.enterPictureInPictureMode(buildParams())
        } catch (e: IllegalStateException) {
            // PIP is disabled for the app in system settings.
            Log.w(TAG, "Failed to enter PIP", e)
            false
        }
    }

    private fun restore() {
        if (!isInPip()) return
        activity.startActivity(
            Intent(activity, activity.javaClass).addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
        )
    }

    private fun applyParams() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !isSupported) return
        try {
            activity.setPictureInPictureParams(buildParams())
        } catch (e: IllegalStateException) {
            Log.w(TAG, "Failed to update PIP params", e)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildParams(): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder()
            .setAspectRatio(rational())
            .setActions(buildActions())

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder
                .setAutoEnterEnabled(enabled)
                .setSeamlessResizeEnabled(false)
        }

        return builder.build()
    }

    private fun rational(): Rational {
        val ratio = if (aspectRatio.isFinite() && aspectRatio > 0) aspectRatio else DEFAULT_ASPECT_RATIO
        val clamped = ratio.coerceIn(MIN_ASPECT_RATIO + 0.001, MAX_ASPECT_RATIO - 0.001)
        return Rational((clamped * 10000).roundToInt(), 10000)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildActions(): List<RemoteAction> {
        val playPause = if (isPlaying) {
            remoteAction("playPause", 1, R.drawable.ic_pip_pause, "Pause", true)
        } else {
            remoteAction("playPause", 1, R.drawable.ic_pip_play, "Play", true)
        }

        if (!showSkipButtons) {
            return listOf(playPause)
        }

        return listOf(
            remoteAction("prev", 2, R.drawable.ic_pip_skip_previous, "Previous", hasPrev),
            playPause,
            remoteAction("next", 3, R.drawable.ic_pip_skip_next, "Next", hasNext),
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun remoteAction(
        action: String,
        requestCode: Int,
        icon: Int,
        title: String,
        enabled: Boolean,
    ): RemoteAction {
        val intent = Intent(ACTION_PIP_CONTROL)
            .setPackage(activity.packageName)
            .putExtra(EXTRA_ACTION, action)
        val pendingIntent = PendingIntent.getBroadcast(
            activity,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return RemoteAction(Icon.createWithResource(activity, icon), title, title, pendingIntent)
            .apply { isEnabled = enabled }
    }
}
