import UIKit
import RoutixSDK

class ViewController: UIViewController {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var resolveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Initialize Routix
        Routix.shared.initialize(apiKey: "rtx_test_key_123")
        
        // 🌟 THE REACTIVE PATTERN:
        // Set the global observer to handle all attribution events.
        Routix.shared.onAttribution = { [weak self] match in
            DispatchQueue.main.async {
                self?.codeLabel.text = match.shortCode ?? "N/A"
                self?.sourceLabel.text = "Source: \(match.matchSource ?? "unknown")"
                let confidence = Int((match.confidence ?? 0.0) * 100)
                self?.confidenceLabel.text = "Confidence: \(confidence)%"
            }
        }
        
        // 2. TRIGGER: Check for a new install (Deferred)
        Routix.shared.resolve(enableClipboard: true) { _ in }
        
        // 🔗 PRODUCTION INTEGRATION:
        // For real deep links, call Routix from your SceneDelegate/AppDelegate:
        // func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //    if let url = URLContexts.first?.url { Routix.shared.handleDeepLink(url: url) { _ in } }
        // }
        
        // 3. TRIGGER: Simulate a direct link click (Flow A)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let url = "https://routix.link/SUMMER24?code=SUMMER24"
            Routix.shared.handleDeepLink(url: url) { _ in }
        }
    }

    @IBAction func resolveTapped(_ sender: UIButton) {
        sender.isEnabled = false
        Routix.shared.resolve(enableClipboard: true) { _ in
            DispatchQueue.main.async { sender.isEnabled = true }
        }
    }
}
