import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    
    private init() {}
    
    private var isEnabled: Bool {
        // Default to true if not set
        UserDefaults.standard.object(forKey: hapticFeedbackKey) as? Bool ?? true
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}



