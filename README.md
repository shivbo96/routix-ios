# Routix iOS SDK 🚀

[![CocoaPods](https://img.shields.io/cocoapods/v/RoutixSDK?color=blue&logo=apple)](https://cocoapods.org/pods/RoutixSDK)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The official **Routix SDK** for native iOS applications. High-precision attribution, deep linking, and conversion tracking for the Apple ecosystem.

---

## 📦 Installation

### CocoaPods
Add to your `Podfile`:
```ruby
pod 'RoutixSDK', '~> 1.0.4'
```

### Swift Package Manager
Add `https://github.com/shivbo96/routix-ios` as a package dependency.

## 🚀 Technical Capabilities

The Routix iOS SDK is built for high-precision attribution in a privacy-first world:

- **Universal Links Support**: 100% accurate attribution for installed users without redirects.
- **Deferred Deep Linking**: Uses high-integrity clipboard matching and probabilistic fingerprinting to carry context through the App Store.
- **SKAdNetwork 4.0**: Built-in support for Apple's attribution framework with coarse and fine-grained conversion value mapping.
- **Privacy First**: No IDFA required by default. Fully GDPR and CCPA compliant.
- **Lightweight**: < 500kb binary footprint with zero external dependencies.

---

## 🛠️ Usage

### 1. Initialize the SDK
Initialize in your `AppDelegate`.

```swift
import RoutixSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Routix.shared.initialize(apiKey: "your_api_key")
    return true
}
```

### 2. Resolve Deep Links (Deferred)
```swift
// On first app open (deferred deep linking)
Routix.shared.resolve(enableClipboard: true) { match in
    if let match = match, match.success {
        print("Attributed to: \(match.shortCode)")
        // Handle your navigation or attribution logic
    }
}
```

### 3. Handle Universal Links (Direct)
```swift
func application(_ application: UIApplication, 
                 continue userActivity: NSUserActivity, 
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let url = userActivity.webpageURL {
        Routix.shared.handleDeepLink(url: url) { match in
            // Handle active deep link
        }
    }
    return true
}
```

### 4. Track Events
Tie conversion events directly to a campaign short code for ROI analysis.
```swift
Routix.shared.trackSale(code: "SUMMER_24", amount: 29.99, currency: "USD")
```

### 5. Track Custom Events
Track workspace-level actions like signups or tutorial completions.
```swift
Routix.shared.trackCustomEvent(eventType: "user_signup", metadata: ["method": "apple"])
```

---

## 📄 License
MIT License.
