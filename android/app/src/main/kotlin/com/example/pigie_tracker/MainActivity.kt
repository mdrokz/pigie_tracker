package com.example.pigie_tracker

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context;
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/ffmpeg"
    private var PRELOAD_LIBS = listOf(
        "libavdevice.so",
        "libavfilter.so",
        "libavcodec.so",
        "libavformat.so",
        "libavutil.so",
        "libswresample.so",
        "libswscale.so"
    )

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if(call.method == "execute") {

                result.success(executeFFMPEG(call.arguments()))
            }
        }
    }

    fun executeFFMPEG(args: List<String>): String {
        val libPath = applicationContext.getApplicationInfo().nativeLibraryDir
        val LD_LIBRARY="$libPath/"
        val ffmpegBinary = "$libPath/ffmpeg"

        val process = ProcessBuilder(listOf(ffmpegBinary,*args.toTypedArray()))

        val env = process.environment()

        env.put("LD_LIBRARY_PATH",LD_LIBRARY)

        val p = process.start()

        p.waitFor()

        return BufferedReader(InputStreamReader(p.inputStream)).readText()
    }
}
