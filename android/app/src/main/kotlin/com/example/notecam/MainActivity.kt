package com.example.notecam

import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "volume_button_channel"
    private var eventSink: EventChannel.EventSink? = null

    private var upPressed = false
    private var downPressed = false
    private var bothFired = false
    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (event?.repeatCount != 0) return true

        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            upPressed = true
            if (downPressed) {
                bothFired = true
                handler.removeCallbacksAndMessages(null)
                eventSink?.success("VOLUME_BOTH")
            } else {
                bothFired = false
                handler.postDelayed({
                    if (upPressed && !downPressed && !bothFired) {
                        // single up — sẽ gửi ở onKeyUp
                    }
                }, 100)
            }
            return true
        }

        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            downPressed = true
            if (upPressed) {
                bothFired = true
                handler.removeCallbacksAndMessages(null)
                eventSink?.success("VOLUME_BOTH")
            } else {
                bothFired = false
                handler.postDelayed({
                    if (downPressed && !upPressed && !bothFired) {
                        // single down — sẽ gửi ở onKeyUp
                    }
                }, 100)
            }
            return true
        }

        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            val wasBoth = bothFired
            upPressed = false
            if (!wasBoth) {
                eventSink?.success("VOLUME_UP")
            }
            if (!upPressed && !downPressed) bothFired = false
            return true
        }
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            val wasBoth = bothFired
            downPressed = false
            if (!wasBoth) {
                eventSink?.success("VOLUME_DOWN")
            }
            if (!upPressed && !downPressed) bothFired = false
            return true
        }
        return super.onKeyUp(keyCode, event)
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        eventSink = null
        super.onDestroy()
    }
}
