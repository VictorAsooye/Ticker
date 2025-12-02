import Foundation
import FirebaseFirestore

// Helper function to get UTC date string in YYYY-MM-DD format
func getUTCDateString() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter.string(from: date)
}

struct UserDocument: Codable {
    let userId: String
    let email: String
    var profile: UserProfile
    var subscriptionTier: SubscriptionTier
    var swipesRemainingToday: Int
    var lastSwipeResetDate: String  // CHANGED: Now stores "YYYY-MM-DD" string instead of Date
    var createdAt: Date
    var lastLoginAt: Date
    
    enum SubscriptionTier: String, Codable {
        case free
        case pro
    }
    
    // Convert to Firestore-compatible dictionary (converts Date to Timestamp)
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [:]
        data["userId"] = userId
        data["email"] = email
        data["profile"] = try! Firestore.Encoder().encode(profile)
        data["subscriptionTier"] = subscriptionTier.rawValue
        data["swipesRemainingToday"] = swipesRemainingToday
        data["lastSwipeResetDate"] = lastSwipeResetDate
        data["createdAt"] = Timestamp(date: createdAt)
        data["lastLoginAt"] = Timestamp(date: lastLoginAt)
        return data
    }
}

struct SwipeRecord: Codable {
    let userId: String
    let investmentId: String
    let direction: SwipeDirection
    let timestamp: Date
    
    enum SwipeDirection: String, Codable {
        case left
        case right
    }
}

struct CachedCardSet: Codable {
    let cacheId: String
    let userId: String
    let profile: UserProfile
    let stocks: [Investment]
    let ideas: [Investment]
    let generatedAt: Date
    let expiresAt: Date
}

