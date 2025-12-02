import Foundation

struct AnalyticsHelper {
    // User journey events
    static func trackOnboardingStarted() {
        FirebaseManager.shared.logEvent("onboarding_started")
    }
    
    static func trackOnboardingStep(_ step: Int) {
        FirebaseManager.shared.logEvent("onboarding_step_\(step)")
    }
    
    static func trackOnboardingCompleted(
        investmentAmount: String,
        riskLevel: String,
        interests: [String]
    ) {
        FirebaseManager.shared.logEvent("onboarding_completed", parameters: [
            "investment_amount": investmentAmount,
            "risk_level": riskLevel,
            "interests_count": interests.count,
            "interests": interests.joined(separator: ",")
        ])
    }
    
    // Card interaction events
    static func trackCardViewed(type: String, title: String) {
        FirebaseManager.shared.logEvent("card_viewed", parameters: [
            "type": type,
            "title": title
        ])
    }
    
    static func trackCardSwiped(
        direction: String,
        type: String,
        title: String,
        timeSpent: TimeInterval
    ) {
        FirebaseManager.shared.logEvent("card_swiped", parameters: [
            "direction": direction,
            "type": type,
            "title": title,
            "time_spent_seconds": Int(timeSpent)
        ])
    }
    
    static func trackCardSaved(type: String, title: String) {
        FirebaseManager.shared.logEvent("investment_saved", parameters: [
            "type": type,
            "title": title
        ])
    }
    
    // Conversion events
    static func trackPaywallViewed(trigger: String) {
        FirebaseManager.shared.logEvent("paywall_viewed", parameters: [
            "trigger": trigger
        ])
    }
    
    static func trackSubscriptionPurchased(price: String) {
        FirebaseManager.shared.logEvent("subscription_purchased", parameters: [
            "price": price,
            "value": 4.99
        ])
    }
    
    // Engagement events
    static func trackDailyActive() {
        FirebaseManager.shared.logEvent("daily_active_user")
    }
    
    static func trackSessionStart() {
        FirebaseManager.shared.logEvent("session_start")
    }
    
    static func trackSessionEnd(duration: TimeInterval) {
        FirebaseManager.shared.logEvent("session_end", parameters: [
            "duration_seconds": Int(duration)
        ])
    }
    
    // Error tracking
    static func trackError(_ error: String, context: String) {
        FirebaseManager.shared.logEvent("error_occurred", parameters: [
            "error": error,
            "context": context
        ])
    }
    
    // Retry tracking
    static func trackRetry(context: String) {
        FirebaseManager.shared.logEvent("user_retry", parameters: [
            "context": context
        ])
    }
    
    // Daily limit tracking
    static func trackDailyLimitHit(tier: String) {
        FirebaseManager.shared.logEvent("daily_limit_hit", parameters: [
            "tier": tier
        ])
    }
    
    // Swipe undo tracking
    static func trackSwipeUndone(direction: String) {
        FirebaseManager.shared.logEvent("swipe_undone", parameters: [
            "direction": direction
        ])
    }
}



