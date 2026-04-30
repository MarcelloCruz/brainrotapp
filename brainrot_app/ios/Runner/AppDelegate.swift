import Flutter
import UIKit
import FamilyControls
import ManagedSettings
import SwiftUI

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let nativeChannel = FlutterMethodChannel(name: "com.dopaminetax/native", binaryMessenger: controller.binaryMessenger)
      
      nativeChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "requestScreenTimePermission" {
          if #available(iOS 16.0, *) {
            Task {
              do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                result(true)
              } catch {
                print("Failed to authorize Screen Time: \(error)")
                result(false)
              }
            }
          } else {
            result(FlutterError(code: "UNSUPPORTED_OS", message: "Screen Time requires iOS 16+", details: nil))
          }
        } else if call.method == "checkScreenTimePermission" {
          if #available(iOS 16.0, *) {
            let status = AuthorizationCenter.shared.authorizationStatus
            result(status == .approved)
          } else {
            result(false)
          }
        } else if call.method == "selectAppsToBlock" {
          if #available(iOS 16.0, *) {
            let pickerView = FamilyPickerView()
            let hostingController = UIHostingController(rootView: pickerView)
            controller.present(hostingController, animated: true, completion: nil)
            result(true)
          } else {
            result(FlutterError(code: "UNSUPPORTED_OS", message: "Screen Time requires iOS 16+", details: nil))
          }
        } else if call.method == "setShieldStatus" {
          if #available(iOS 16.0, *) {
             if let args = call.arguments as? [String: Any], let enable = args["enable"] as? Bool {
                 if enable {
                     ScreenTimeManager.shared.applyShield()
                 } else {
                     ScreenTimeManager.shared.removeShield()
                 }
                 result(true)
             } else {
                 result(FlutterError(code: "INVALID_ARGS", message: "Missing enable boolean", details: nil))
             }
          } else {
             result(FlutterError(code: "UNSUPPORTED_OS", message: "Screen Time requires iOS 16+", details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

// MARK: - Screen Time Manager

@available(iOS 16.0, *)
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    let store = ManagedSettingsStore()
    
    @Published var selection = FamilyActivitySelection() {
        didSet {
            saveSelection()
            applyShield()
        }
    }
    
    private let selectionKey = "screenTimeSelection"
    
    private init() {
        loadSelection()
    }
    
    func loadSelection() {
        if let data = UserDefaults.standard.data(forKey: selectionKey),
           let savedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.selection = savedSelection
        }
    }
    
    func saveSelection() {
        if let data = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: selectionKey)
        }
    }
    
    func applyShield() {
        // Clear existing shield
        store.shield.applications = nil
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific([])
        store.shield.webDomains = nil
        
        // Apply new shield
        let apps = selection.applicationTokens
        let categories = selection.categoryTokens
        let webCategories = selection.webDomainTokens
        
        if !apps.isEmpty {
            store.shield.applications = apps
        }
        if !categories.isEmpty {
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
        }
        if !webCategories.isEmpty {
            store.shield.webDomains = webCategories
        }
    }
    
    func removeShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific([])
        store.shield.webDomains = nil
    }
}

// MARK: - Family Picker View

@available(iOS 16.0, *)
struct FamilyPickerView: View {
    @ObservedObject var manager = ScreenTimeManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var isPickerPresented = true
    
    var body: some View {
        Color.clear
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $manager.selection)
            .onChange(of: isPickerPresented) { isPresented in
                if !isPresented {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}
