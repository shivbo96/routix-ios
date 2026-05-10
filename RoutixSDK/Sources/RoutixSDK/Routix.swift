import Foundation
import UIKit

public class Routix {
    public static let shared = Routix()
    private init() {}

    private let version = "1.0.0"
    private var apiKey: String?
    private let baseUrl: String = "https://api.routix.link"

    /// Global observer for attribution events.
    /// Set this closure to handle navigation or analytics whenever a match is found.
    public var onAttribution: ((RoutixMatch) -> Void)?

    // MARK: - Initialization

    public func initialize(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Deep Link Handling (Layer 1 — Universal Links)

    /// Call this from `AppDelegate` or `SceneDelegate` when a Universal Link opens your app.
    ///
    /// This handles the case where the app is **already installed** and iOS opens it
    /// directly via Universal Links. This is 100% accurate attribution — no fingerprinting needed.
    ///
    /// ```swift
    /// // In AppDelegate:
    /// func application(_ application: UIApplication,
    ///                  continue userActivity: NSUserActivity,
    ///                  restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    ///     if let url = userActivity.webpageURL {
    ///         Routix.shared.handleDeepLink(url: url) { match in
    ///             // handle attribution
    ///         }
    ///     }
    ///     return true
    /// }
    /// ```
    public func handleDeepLink(url: URL, completion: @escaping (RoutixMatch?) -> Void) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let shortCode = components.queryItems?.first(where: {
                  $0.name == "code" || $0.name == "ref"
              })?.value else {
            completion(nil)
            return
        }

        let match = RoutixMatch(
            success: true,
            shortCode: shortCode,
            originalUrl: url.absoluteString,
            matchSource: "universal_link",
            confidence: 1.0,
            metadata: nil,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        onAttribution?(match)
        completion(match)
    }

    // MARK: - Attribution Resolution (Layer 2 + 3 — Clipboard + Fingerprint)

    /// Resolves the attribution for this install.
    ///
    /// - Parameter enableClipboard: When `true`, reads the system clipboard for an `rtx_` prefixed
    ///   token. Useful for deferred deep linking on iOS when the app was not installed at click time.
    ///   Note: On iOS 16+, this may trigger a system permission prompt.
    /// - Parameter completion: Called with a `RoutixMatch` if attribution is found, or `nil` if not.
    public func resolve(enableClipboard: Bool = false, completion: @escaping (RoutixMatch?) -> Void) {
        guard apiKey != nil else {
            print("[Routix] SDK not initialized. Call initialize() first.")
            completion(nil)
            return
        }

        // Idempotency: Only resolve once per install
        if UserDefaults.standard.bool(forKey: "routix_resolved") {
            completion(nil)
            return
        }

        var token: String? = nil

        // Layer 2: Clipboard token fallback
        if enableClipboard {
            if let content = UIPasteboard.general.string, content.hasPrefix("rtx_") {
                token = String(content.dropFirst(4)) // Strip 'rtx_' prefix
            }
        }

        // Layer 3: Send device fingerprint to server (always runs)
        executeResolve(token: token, completion: completion)
    }

    private func executeResolve(token: String?, completion: @escaping (RoutixMatch?) -> Void) {
        let deviceInfo = getDeviceInfo()
        let payload: [String: Any] = [
            "install_referrer": token as Any,
            "device_info": deviceInfo
        ]

        makePostRequest(endpoint: "/api/v1/sdk/resolve", payload: payload) { data in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let match = try JSONDecoder().decode(RoutixMatch.self, from: data)
                if match.success {
                    UserDefaults.standard.set(true, forKey: "routix_resolved")
                    self.onAttribution?(match)
                }
                completion(match)
            } catch {
                print("[Routix] Decode error: \(error)")
                completion(nil)
            }
        }
    }

    // MARK: - Conversion Tracking

    /// Track when a user installs the app via a specific link.
    public func trackInstall(code: String) {
        trackEvent(code: code, type: "install")
    }

    /// Track a lead event attributed to a specific link.
    public func trackLead(code: String, metadata: [String: Any]? = nil) {
        trackEvent(code: code, type: "lead", metadata: metadata)
    }

    /// Track a sale/revenue event attributed to a specific link.
    public func trackSale(code: String, amount: Double, currency: String = "USD") {
        trackEvent(code: code, type: "sale", metadata: ["amount": amount, "currency": currency])
    }

    /// Track a custom event attributed to a specific link.
    public func trackLinkEvent(code: String, eventType: String, metadata: [String: Any]? = nil) {
        var combined: [String: Any] = metadata ?? [:]
        combined["event_type"] = eventType
        trackEvent(code: code, type: "track", metadata: combined)
    }

    /// Track a workspace-level custom event independent of any link.
    public func trackCustomEvent(eventType: String, metadata: [String: Any]? = nil) {
        guard apiKey != nil else { return }
        var payload: [String: Any] = metadata ?? [:]
        payload["event_type"] = eventType
        payload["sdk_v"] = "ios-\(version)"
        payload["timestamp"] = ISO8601DateFormatter().string(from: Date())
        makePostRequest(endpoint: "/api/v1/track", payload: payload) { _ in }
    }

    private func trackEvent(code: String, type: String, metadata: [String: Any]? = nil) {
        var payload: [String: Any] = metadata ?? [:]
        payload["sdk_v"] = "ios-\(version)"
        payload["timestamp"] = ISO8601DateFormatter().string(from: Date())
        makePostRequest(endpoint: "/api/v1/links/\(code)/\(type)", payload: payload) { _ in }
    }

    // MARK: - Networking

    private func makePostRequest(endpoint: String, payload: [String: Any], completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "\(baseUrl)\(endpoint)"),
              let currentApiKey = apiKey else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5.0 // Prevent hanging on bad networks
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(currentApiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("ios-\(version)", forHTTPHeaderField: "X-SDK-Version")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[Routix] Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }

    // MARK: - Device Info (used for fingerprint matching)

    private func getDeviceInfo() -> [String: Any] {
        let device = UIDevice.current
        let screen = UIScreen.main.bounds
        let defaults = UserDefaults.standard

        // 1. Anonymous Device ID
        var anonId = defaults.string(forKey: "routix_anon_id")
        if anonId == nil {
            anonId = UUID().uuidString.lowercased()
            defaults.set(anonId, forKey: "routix_anon_id")
        }

        // 2. First Open Timestamp
        var firstOpen = defaults.string(forKey: "routix_first_open")
        if firstOpen == nil {
            firstOpen = ISO8601DateFormatter().string(from: Date())
            defaults.set(firstOpen, forKey: "routix_first_open")
        }

        return [
            "sdk_version": "ios-\(version)",
            "app_id": Bundle.main.bundleIdentifier ?? "",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "build_number": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
            "os": "ios",
            "os_version": device.systemVersion,
            "manufacturer": "Apple",
            "model": device.model, // e.g. "iPhone"
            "model_identifier": deviceModelIdentifier(), // e.g. "iPhone18,2"
            "screen_width": Int(screen.width),
            "screen_height": Int(screen.height),
            "locale": Locale.current.identifier,
            "timezone": TimeZone.current.identifier,
            "anonymous_device_id": anonId ?? "",
            "first_open_timestamp": firstOpen ?? ""
        ]
    }

    private func deviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
