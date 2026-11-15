import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var timer: Timer?
  private var step: Double = 0.0
  private var altimeterOffset: Double = 0.0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    let methodChannel = FlutterMethodChannel(
      name: "com.safeer.voyageai/navigation_sensors",
      binaryMessenger: controller.binaryMessenger
    )

    methodChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      if call.method == "calibrateAltimeter" {
        let args = call.arguments as? [String: Any]
        let reference = (args?["referenceAltitude"] as? Double) ?? 2450.0
        self.altimeterOffset = reference - 2450.0
        result([
          "status": "calibrated",
          "referenceAltitude": reference,
          "offset": self.altimeterOffset,
          "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
        ])
      } else if call.method == "triggerOfflineSosBeacon" {
        let args = call.arguments as? [String: Any]
        let coords = args?["coordinates"] as? [String: Double]
        result([
          "status": "beacon_broadcast_active",
          "protocol": "COSPAS-SARSAT-406MHz-SIM",
          "latitude": coords?["latitude"] ?? 36.3167,
          "longitude": coords?["longitude"] ?? 74.6500,
          "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
        ])
      } else if call.method == "fetchLocalWeatherAdvisory" {
        let args = call.arguments as? [String: Any]
        let location = (args?["location"] as? String) ?? "Alpine Base"
        result([
          "location": location,
          "condition": "Partly Cloudy / Mountain Ridge Wind",
          "temperatureCelsius": 11.5,
          "windSpeedKph": 28.0,
          "barometricTrend": "Steady (1013.2 hPa equivalent)",
          "visibilityKm": 16.0,
          "advisoryLevel": "Moderate Caution - High Altitude Wind Shear",
          "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
        ])
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    let eventChannel = FlutterEventChannel(
      name: "com.safeer.voyageai/expedition_telemetry",
      binaryMessenger: controller.binaryMessenger
    )
    eventChannel.setStreamHandler(self)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
      guard let self = self, let sink = self.eventSink else { return }
      self.step += 1.0
      let altitudeMeters = 2438.4 + self.altimeterOffset + (sin(self.step * 0.1) * 6.5)
      let altitudeFeet = altitudeMeters * 3.28084
      let pressureHpa = 754.2 - (altitudeMeters / 100.0 * 8.5)
      let azimuth = Double(Int(38.0 + (self.step * 3.5)) % 360)
      let temperature = 14.2 - (altitudeMeters / 1000.0 * 3.2)
      let uvIndex = 6.2
      let gpsAccuracy = 3.2

      let payload: [String: Any] = [
        "altitudeMeters": round(altitudeMeters * 10) / 10,
        "altitudeFeet": round(altitudeFeet * 10) / 10,
        "pressureHpa": round(pressureHpa * 10) / 10,
        "azimuthDegrees": azimuth,
        "temperatureCelsius": round(temperature * 10) / 10,
        "uvIndex": uvIndex,
        "gpsAccuracyMeters": gpsAccuracy,
        "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
      ]
      sink(payload)
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.timer?.invalidate()
    self.timer = nil
    self.eventSink = nil
    return nil
  }
}
