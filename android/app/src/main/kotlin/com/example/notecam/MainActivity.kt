package com.example.notecam

import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.MotionEvent
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
    
    // For double press detection
    private var lastUpPressTime = 0L
    private var lastDownPressTime = 0L
    private var upPressCount = 0
    private var downPressCount = 0
    private val DOUBLE_PRESS_INTERVAL = 500L // 500ms window for double press
    
    // For hold detection
    private var upHoldStartTime = 0L
    private var downHoldStartTime = 0L
    private var upHoldFired = false
    private var downHoldFired = false
    private val HOLD_DURATION = 2000L // 2 seconds for hold
    private var holdCheckRunnable: Runnable? = null
    
    // For triple tap detection
    private var lastTapTime = 0L
    private var tapCount = 0
    private val TRIPLE_TAP_INTERVAL = 500L // 500ms window for triple tap

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

        val currentTime = System.currentTimeMillis()

        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            upPressed = true
            upHoldStartTime = currentTime
            upHoldFired = false
            
            // Check for both buttons pressed
            if (downPressed) {
                bothFired = true
                handler.removeCallbacksAndMessages(null)
                eventSink?.success("VOLUME_BOTH")
                resetCounters()
                return true
            }
            
            // Check for double press
            if (currentTime - lastUpPressTime < DOUBLE_PRESS_INTERVAL) {
                upPressCount++
                if (upPressCount == 2) {
                    handler.removeCallbacksAndMessages(null)
                    eventSink?.success("VOLUME_UP_DOUBLE")
                    upPressCount = 0
                    lastUpPressTime = 0
                    return true
                }
            } else {
                upPressCount = 1
            }
            lastUpPressTime = currentTime
            
            // Schedule hold check
            holdCheckRunnable = Runnable {
                if (upPressed && !bothFired && currentTime == upHoldStartTime) {
                    upHoldFired = true
                    eventSink?.success("VOLUME_HOLD")
                }
            }
            handler.postDelayed(holdCheckRunnable!!, HOLD_DURATION)
            
            return true
        }

        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            downPressed = true
            downHoldStartTime = currentTime
            downHoldFired = false
            
            // Check for both buttons pressed
            if (upPressed) {
                bothFired = true
                handler.removeCallbacksAndMessages(null)
                eventSink?.success("VOLUME_BOTH")
                resetCounters()
                return true
            }
            
            // Check for double press
            if (currentTime - lastDownPressTime < DOUBLE_PRESS_INTERVAL) {
                downPressCount++
                if (downPressCount == 2) {
                    handler.removeCallbacksAndMessages(null)
                    eventSink?.success("VOLUME_DOWN_DOUBLE")
                    downPressCount = 0
                    lastDownPressTime = 0
                    return true
                }
            } else {
                downPressCount = 1
            }
            lastDownPressTime = currentTime
            
            // Schedule hold check
            holdCheckRunnable = Runnable {
                if (downPressed && !bothFired && currentTime == downHoldStartTime) {
                    downHoldFired = true
                    eventSink?.success("VOLUME_HOLD")
                }
            }
            handler.postDelayed(holdCheckRunnable!!, HOLD_DURATION)
            
            return true
        }

        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            val wasBoth = bothFired
            val wasHold = upHoldFired
            upPressed = false
            upHoldFired = false
            
            // Only send single press if not part of double/hold/both
            if (!wasBoth && !wasHold && upPressCount == 1) {
                // Wait a bit to see if it's a double press
                handler.postDelayed({
                    if (upPressCount == 1) {
                        eventSink?.success("VOLUME_UP")
                        upPressCount = 0
                    }
                }, DOUBLE_PRESS_INTERVAL)
            }
            
            if (!upPressed && !downPressed) {
                bothFired = false
            }
            return true
        }
        
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            val wasBoth = bothFired
            val wasHold = downHoldFired
            downPressed = false
            downHoldFired = false
            
            // Only send single press if not part of double/hold/both
            if (!wasBoth && !wasHold && downPressCount == 1) {
                // Wait a bit to see if it's a double press
                handler.postDelayed({
                    if (downPressCount == 1) {
                        eventSink?.success("VOLUME_DOWN")
                        downPressCount = 0
                    }
                }, DOUBLE_PRESS_INTERVAL)
            }
            
            if (!upPressed && !downPressed) {
                bothFired = false
            }
            return true
        }
        
        return super.onKeyUp(keyCode, event)
    }
    
    private fun resetCounters() {
        upPressCount = 0
        downPressCount = 0
        lastUpPressTime = 0
        lastDownPressTime = 0
    }
    
    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        if (ev?.action == MotionEvent.ACTION_DOWN) {
            val currentTime = System.currentTimeMillis()
            
            if (currentTime - lastTapTime < TRIPLE_TAP_INTERVAL) {
                tapCount++
                if (tapCount == 3) {
                    eventSink?.success("TRIPLE_TAP")
                    tapCount = 0
                    lastTapTime = 0
                    return super.dispatchTouchEvent(ev)
                }
            } else {
                tapCount = 1
            }
            lastTapTime = currentTime
        }
        return super.dispatchTouchEvent(ev)
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        eventSink = null
        super.onDestroy()
    }
}
