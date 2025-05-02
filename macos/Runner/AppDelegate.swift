import Cocoa
import FlutterMacOS
import Foundation

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "flutter/native", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getResourcePath" {
        result(Bundle.main.resourcePath)
      } else if call.method == "getMediaInfo" {
        // 实现获取媒体信息的逻辑
        result(["video": "info", "audio": "info", "thumbnails": "path"])
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    super.applicationDidFinishLaunching(notification)
  }
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
