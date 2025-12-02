import Foundation
import FirebaseFunctions

class CloudFunctionsService {
    static let shared = CloudFunctionsService()
    private let functions = FirebaseManager.shared.functions
    
    private init() {}
    
    func generateCards(profile: UserProfile, type: InvestmentType, count: Int = 10) async throws -> [Investment] {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            throw CloudFunctionError.notAuthenticated
        }
        
        let data: [String: Any] = [
            "userId": userId,
            "profile": [
                "investmentAmount": profile.investmentAmount.prompt,
                "riskLevel": profile.riskLevel.prompt,
                "interests": profile.interests.map { $0.rawValue }
            ],
            "type": type == .stock ? "stock" : "idea",
            "count": count
        ]
        
        do {
            let result = try await functions.httpsCallable("generateCards").call(data)
            
            guard let resultData = result.data as? [String: Any],
                  let cardsData = resultData["cards"] as? [[String: Any]] else {
                throw CloudFunctionError.invalidResponse
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: cardsData)
            
            do {
                let investments = try JSONDecoder().decode([Investment].self, from: jsonData)
                
                FirebaseManager.shared.logEvent("cards_generated", parameters: [
                    "type": type.rawValue,
                    "count": investments.count,
                    "cached": resultData["cached"] as? Bool ?? false
                ])
                
                return investments
            } catch {
                // Log the actual JSON for debugging
                #if DEBUG
                print("JSON Decoding Error: \(error)")
                print("Cards Data: \(cardsData)")
                #endif
                throw CloudFunctionError.invalidResponse
            }
        } catch let error as NSError {
            // Handle Firebase Functions errors
            if error.domain == "com.firebase.functions" {
                let code = error.userInfo["code"] as? String ?? ""
                let message = error.userInfo["message"] as? String ?? error.localizedDescription
                
                if code == "resource-exhausted" || message.contains("Daily swipe limit reached") {
                    throw CloudFunctionError.dailyLimitReached
                }
                
                if code == "not-found" {
                    throw CloudFunctionError.networkError("User profile not found. Please complete onboarding.")
                }
                
                if code == "unauthenticated" {
                    throw CloudFunctionError.notAuthenticated
                }
                
                // For internal errors, provide a user-friendly message
                if code == "internal" {
                    throw CloudFunctionError.networkError("Server error. Please try again in a moment.")
                }
                
                throw CloudFunctionError.networkError(message)
            }
            
            // Handle other errors
            if error.localizedDescription.contains("INTERNAL") {
                throw CloudFunctionError.networkError("Server error. Please try again in a moment.")
            }
            
            throw CloudFunctionError.networkError(error.localizedDescription)
        }
    }
    
    func trackSwipe(investmentId: UUID, direction: SwipeDirection) async throws -> SwipeResult {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            throw CloudFunctionError.notAuthenticated
        }
        
        let data: [String: Any] = [
            "userId": userId,
            "investmentId": investmentId.uuidString,
            "direction": direction.rawValue
        ]
        
        do {
            let result = try await functions.httpsCallable("trackSwipe").call(data)
            
            guard let resultData = result.data as? [String: Any],
                  let swipesRemaining = resultData["swipesRemaining"] as? Int,
                  let maxSwipes = resultData["maxSwipes"] as? Int,
                  let tierString = resultData["tier"] as? String else {
                throw CloudFunctionError.invalidResponse
            }
            
            let tier: UserDocument.SubscriptionTier = tierString == "pro" ? .pro : .free
            
            return SwipeResult(
                swipesRemaining: swipesRemaining,
                maxSwipes: maxSwipes,
                tier: tier
            )
        } catch let error as NSError {
            if error.domain == "com.firebase.functions" {
                if let message = error.userInfo["message"] as? String,
                   message.contains("Daily swipe limit reached") {
                    throw CloudFunctionError.dailyLimitReached
                }
            }
            throw CloudFunctionError.networkError(error.localizedDescription)
        }
    }
    
    // NEW: Atomic undo operation
    func undoSwipe(investmentId: UUID, direction: SwipeDirection) async throws -> SwipeResult {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            throw CloudFunctionError.notAuthenticated
        }
        
        let data: [String: Any] = [
            "userId": userId,
            "investmentId": investmentId.uuidString,
            "direction": direction.rawValue
        ]
        
        do {
            let result = try await functions.httpsCallable("undoSwipe").call(data)
            
            guard let resultData = result.data as? [String: Any],
                  let swipesRemaining = resultData["swipesRemaining"] as? Int,
                  let maxSwipes = resultData["maxSwipes"] as? Int,
                  let tierString = resultData["tier"] as? String else {
                throw CloudFunctionError.invalidResponse
            }
            
            let tier: UserDocument.SubscriptionTier = tierString == "pro" ? .pro : .free
            
            return SwipeResult(
                swipesRemaining: swipesRemaining,
                maxSwipes: maxSwipes,
                tier: tier
            )
        } catch let error as NSError {
            throw CloudFunctionError.networkError(error.localizedDescription)
        }
    }
    
    // NEW: Get current swipe status
    func getSwipeStatus() async throws -> SwipeResult {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            throw CloudFunctionError.notAuthenticated
        }
        
        let data: [String: Any] = [
            "userId": userId
        ]
        
        do {
            let result = try await functions.httpsCallable("getSwipeStatus").call(data)
            
            guard let resultData = result.data as? [String: Any],
                  let swipesRemaining = resultData["swipesRemaining"] as? Int,
                  let maxSwipes = resultData["maxSwipes"] as? Int,
                  let tierString = resultData["tier"] as? String else {
                throw CloudFunctionError.invalidResponse
            }
            
            let tier: UserDocument.SubscriptionTier = tierString == "pro" ? .pro : .free
            
            return SwipeResult(
                swipesRemaining: swipesRemaining,
                maxSwipes: maxSwipes,
                tier: tier
            )
        } catch let error as NSError {
            throw CloudFunctionError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - Supporting Types

struct SwipeResult {
    let swipesRemaining: Int
    let maxSwipes: Int
    let tier: UserDocument.SubscriptionTier
}

enum CloudFunctionError: LocalizedError {
    case notAuthenticated
    case invalidResponse
    case dailyLimitReached
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .invalidResponse:
            return "Something went wrong. Please try again."
        case .dailyLimitReached:
            return "You've reached your daily limit. Upgrade to Pro for 50 swipes per day!"
        case .networkError(let message):
            if message.contains("offline") || message.contains("network") || message.contains("connection") {
                return "No internet connection. Please check your connection and try again."
            } else if message.contains("timeout") {
                return "Request timed out. Please try again."
            } else {
                return "Something went wrong. Please try again later."
            }
        }
    }
}

enum SwipeDirection: String {
    case left
    case right
}



