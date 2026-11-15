package com.safeer.voyageai

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sin
import kotlin.random.Random

class MainActivity : FlutterActivity() {
    private val sensorMethodChannelName = "com.safeer.voyageai/navigation_sensors"
    private val telemetryEventChannelName = "com.safeer.voyageai/expedition_telemetry"

    private var telemetryHandler: Handler? = null
    private var telemetryRunnable: Runnable? = null
    private var telemetryEventSink: EventChannel.EventSink? = null
    private var simulationStep = 0
    private var calibratedOffset = 0.0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, sensorMethodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "calibrateAltimeter" -> {
                    val referenceAltitude = call.argument<Double>("referenceAltitude") ?: 2450.0
                    calibratedOffset = referenceAltitude - 2450.0
                    result.success(
                        mapOf(
                            "status" to "calibrated",
                            "referenceAltitude" to referenceAltitude,
                            "offset" to calibratedOffset,
                            "timestamp" to System.currentTimeMillis()
                        )
                    )
                }
                "triggerOfflineSosBeacon" -> {
                    val coordinates = call.argument<Map<String, Double>>("coordinates")
                    val latitude = coordinates?.get("latitude") ?: 36.3167
                    val longitude = coordinates?.get("longitude") ?: 74.6500
                    result.success(
                        mapOf(
                            "status" to "beacon_broadcast_active",
                            "protocol" to "COSPAS-SARSAT-406MHz-SIM",
                            "latitude" to latitude,
                            "longitude" to longitude,
                            "timestamp" to System.currentTimeMillis()
                        )
                    )
                }
                "fetchLocalWeatherAdvisory" -> {
                    val location = call.argument<String>("location") ?: "Karakoram Pass"
                    result.success(
                        mapOf(
                            "location" to location,
                            "condition" to "Partly Cloudy / Mountain Ridge Wind",
                            "temperatureCelsius" to 11.5,
                            "windSpeedKph" to 28.0,
                            "barometricTrend" to "Steady (1013.2 hPa equivalent)",
                            "visibilityKm" to 16.0,
                            "advisoryLevel" to "Moderate Caution - High Altitude Wind Shear",
                            "timestamp" to System.currentTimeMillis()
                        )
                    )
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, telemetryEventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    telemetryEventSink = events
                    startTelemetryStream()
                }

                override fun onCancel(arguments: Any?) {
                    stopTelemetryStream()
                    telemetryEventSink = null
                }
            }
        )
    }

    private fun startTelemetryStream() {
        telemetryHandler = Handler(Looper.getMainLooper())
        telemetryRunnable = object : Runnable {
            override fun run() {
                simulationStep++
                val baseAltitude = 2438.4 + calibratedOffset + (sin(simulationStep * 0.1) * 6.5) + Random.nextDouble(-0.8, 0.8)
                val baseAltitudeFeet = baseAltitude * 3.28084
                val basePressure = 754.2 - (baseAltitude / 100.0 * 8.5) + Random.nextDouble(-0.3, 0.3)
                val azimuth = (38.0 + (simulationStep * 3.5) % 360.0)
                val temperature = 14.2 - (baseAltitude / 1000.0 * 3.2)
                val uvIndex = 6.2
                val gpsAccuracy = 3.2 + Random.nextDouble(-0.4, 0.4)

                val telemetryPacket = mapOf(
                    "altitudeMeters" to Math.round(baseAltitude * 10.0) / 10.0,
                    "altitudeFeet" to Math.round(baseAltitudeFeet * 10.0) / 10.0,
                    "pressureHpa" to Math.round(basePressure * 10.0) / 10.0,
                    "azimuthDegrees" to Math.round(azimuth * 10.0) / 10.0,
                    "temperatureCelsius" to Math.round(temperature * 10.0) / 10.0,
                    "uvIndex" to uvIndex,
                    "gpsAccuracyMeters" to Math.round(gpsAccuracy * 10.0) / 10.0,
                    "timestamp" to System.currentTimeMillis()
                )

                telemetryEventSink?.success(telemetryPacket)
                telemetryHandler?.postDelayed(this, 2000)
            }
        }
        telemetryHandler?.post(telemetryRunnable!!)
    }

    private fun stopTelemetryStream() {
        telemetryRunnable?.let { telemetryHandler?.removeCallbacks(it) }
        telemetryHandler = null
    }

    override fun onDestroy() {
        stopTelemetryStream()
        super.onDestroy()
    }
}
