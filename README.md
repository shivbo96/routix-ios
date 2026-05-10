# Routix iOS SDK 🚀

[![CocoaPods](https://img.shields.io/cocoapods/v/RoutixSDK?color=blue&logo=apple)](https://cocoapods.org/pods/RoutixSDK)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The official **Routix SDK** for native iOS applications. High-precision attribution, deep linking, and conversion tracking for the Apple ecosystem.

---

## 📦 Installation

### CocoaPods
Add to your `Podfile`:
```ruby
pod 'RoutixSDK', '~> 1.0.0'
```

### Swift Package Manager
Add `https://github.com/shivbo96/routix-ios` as a package dependency.

---

## 🛠️ Usage

### 1. Initialize the SDK
Initialize in your `AppDelegate`.

```swift
import RoutixSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Routix.initialize(apiKey: "your_api_key")
    return true
}
```

### 2. Resolve Deep Links
```swift
Routix.resolve(enableClipboard: true) { match in
    if match.success {
        print("Attributed to: \(match.shortCode)")
    }
}
```

### 3. Track Events
```swift
Routix.trackSale(shortCode: "SUMMER_24", amount: 29.99, currency: "USD")
```

---

## 📄 License
MIT License.
