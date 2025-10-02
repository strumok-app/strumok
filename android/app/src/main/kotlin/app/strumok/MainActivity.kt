package app.strumok

import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import java.io.File

const val INSTALL_APK_CHANNEL = "install_apk"

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INSTALL_APK_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("installApk")) {
                val filePath = call.argument<String>("filePath")
               if (filePath == null) {
                    result.error(
                        "MISSING_ARGUMENT",
                        "Missing filePath argument.",
                        "Please call this method with filePath argument."
                    )
                } else {
                    try {
                        result.success(installNormal(filePath))
                        result.success(true)
                    } catch (ex: Exception) {
                        result.error(
                            "ANDROID_ERROR",
                            ex.message,
                            ex.message
                        )
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun installNormal(filePath: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) {
            return false
        }

        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val contentUri = FileProvider.getUriForFile(
                applicationContext,
                applicationContext.packageName + ".fileProvider", file
            )
            intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
        } else {
            intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive")
        }

        startActivity(intent)

        return true
    }
}
