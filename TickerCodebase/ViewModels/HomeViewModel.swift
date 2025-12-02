import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var stockCards: [Investment] = []
    @Published var ideaCards: [Investment] = []
    @Published var currentTab: InvestmentType = .stock
    @Published var isLoading = false
    @Published var error: String?
    @Published var notifications: [AppNotification] = []
    @Published var swipesRemaining: Int = 10
    @Published var maxSwipes: Int = 10
    @Published var subscriptionTier: UserDocument.SubscriptionTier = .free
    @Published var showPaywall = false
    @Published var showErrorAlert = false
    @Published var errorRetryAction: (() async -> Void)?
    @Published var isSwipeInProgress = false
    
    @Published var undoManager = UndoManager()
    
    private let storage = StorageManager.shared
    
    init() {
        loadNotifications()
        // Load user status on init
        Task {
            await loadUserStatus()
        }
    }
    
    func loadInitialCards() async {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            self.error = "Please sign in"
            return
        }
        
        // Load user's current swipe status from server
        await loadUserStatus()
        
        // Check if user has swipes remaining
        if swipesRemaining <= 0 {
            showPaywall = true
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let profile = try await loadUserProfile(userId: userId)
            
            // Use Cloud Functions instead of direct OpenAI calls
            async let stocks = CloudFunctionsService.shared.generateCards(
                profile: profile,
                type: .stock,
                count: 10
            )
            async let ideas = CloudFunctionsService.shared.generateCards(
                profile: profile,
                type: .idea,
                count: 10
            )
            
            let (loadedStocks, loadedIdeas) = try await (stocks, ideas)
            
            self.stockCards = loadedStocks
            self.ideaCards = loadedIdeas
            
            // Update notifications with stock recommendations
            updateNotificationsFromCards()
            
            FirebaseManager.shared.logEvent("cards_loaded_successfully")
        } catch CloudFunctionError.dailyLimitReached {
            self.showPaywall = true
            AnalyticsHelper.trackDailyLimitHit(tier: subscriptionTier.rawValue)
        } catch {
            // Provide user-friendly error messages
            let errorMessage: String
            if let cloudError = error as? CloudFunctionError {
                switch cloudError {
                case .dailyLimitReached:
                    errorMessage = "You've reached your daily swipe limit. Upgrade to Pro for more swipes."
                case .notAuthenticated:
                    errorMessage = "Please sign in to continue"
                case .invalidResponse:
                    errorMessage = "Unable to load investment suggestions. Please try again."
                case .networkError(let message):
                    errorMessage = message
                }
            } else if error.localizedDescription.contains("NOT FOUND") || error.localizedDescription.contains("not found") {
                errorMessage = "Unable to connect to server. Please check your internet connection and try again."
            } else if error.localizedDescription.contains("network") || error.localizedDescription.contains("connection") {
                errorMessage = "No internet connection. Please check your network and try again."
            } else if error.localizedDescription.contains("timeout") {
                errorMessage = "Request timed out. Please try again."
            } else {
                errorMessage = "Something went wrong. Please try again."
            }
            
            self.error = errorMessage
            self.showErrorAlert = true
            self.errorRetryAction = { [weak self] in
                await self?.loadInitialCards()
            }
            AnalyticsHelper.trackError(error.localizedDescription, context: "load_cards")
        }
        
        isLoading = false
    }
    
    /// Load user's current swipe status from server
    /// This is the ONLY way to get swipe count - no client-side reset
    private func loadUserStatus() async {
        do {
            let status = try await CloudFunctionsService.shared.getSwipeStatus()
            
            self.swipesRemaining = status.swipesRemaining
            self.maxSwipes = status.maxSwipes
            self.subscriptionTier = status.tier
            
            #if DEBUG
            print("📊 User status: \(swipesRemaining)/\(maxSwipes) swipes, tier: \(subscriptionTier)")
            #endif
        } catch {
            #if DEBUG
            print("❌ Error loading user status: \(error)")
            #endif
            // Don't show error to user, just use defaults
        }
    }
    
    private func loadUserProfile(userId: String) async throws -> UserProfile {
        let doc = try await FirebaseManager.shared.db
            .collection("users")
            .document(userId)
            .getDocument()
        
        guard var data = doc.data() else {
            throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "User document not found"])
        }
        
        // Convert Firestore Timestamp to Date for decoding
        if let createdAtTimestamp = data["createdAt"] as? Timestamp {
            data["createdAt"] = createdAtTimestamp.dateValue()
        }
        if let lastLoginAtTimestamp = data["lastLoginAt"] as? Timestamp {
            data["lastLoginAt"] = lastLoginAtTimestamp.dateValue()
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let userDoc = try JSONDecoder().decode(UserDocument.self, from: jsonData)
        return userDoc.profile
    }
    
    func getCurrentCards() -> [Investment] {
        currentTab == .stock ? stockCards : ideaCards
    }
    
    func removeTopCard() {
        if currentTab == .stock {
            if !stockCards.isEmpty {
                stockCards.removeFirst()
            }
        } else {
            if !ideaCards.isEmpty {
                ideaCards.removeFirst()
            }
        }
    }
    
    func handleSwipe(card: Investment, direction: SwipeDirection) async {
        // Prevent multiple simultaneous swipes
        guard !isSwipeInProgress else { return }
        isSwipeInProgress = true
        
        defer { isSwipeInProgress = false }
        
        // Register for undo BEFORE making server changes
        undoManager.registerSwipe(card: card, direction: direction)
        
        // Haptic feedback
        HapticManager.shared.impact(.medium)
        
        do {
            // Track swipe on backend (handles daily reset + decrement atomically)
            let result = try await CloudFunctionsService.shared.trackSwipe(
                investmentId: card.id,
                direction: direction
            )
            
            // Update local state from server response
            swipesRemaining = result.swipesRemaining
            maxSwipes = result.maxSwipes
            subscriptionTier = result.tier
            
            // Save if right swipe
            if direction == .right {
                try await saveInvestmentToFirestore(card)
            }
            
            // Remove card from deck (UI only)
            removeTopCard()
            
            // Show paywall if no swipes left
            if swipesRemaining <= 0 {
                showPaywall = true
            }
            
            AnalyticsHelper.trackCardSwiped(
                direction: direction.rawValue,
                type: card.type.rawValue,
                title: card.title,
                timeSpent: 0 // Time tracking is handled in InvestmentCard view
            )
            
            if direction == .right {
                AnalyticsHelper.trackCardSaved(type: card.type.rawValue, title: card.title)
            }
        } catch CloudFunctionError.dailyLimitReached {
            // User hit limit during swipe
            showPaywall = true
            swipesRemaining = 0
            undoManager.cancelUndo()
            AnalyticsHelper.trackDailyLimitHit(tier: subscriptionTier.rawValue)
        } catch {
            let errorMessage = (error as? CloudFunctionError)?.errorDescription ?? error.localizedDescription
            self.error = errorMessage
            self.showErrorAlert = true
            undoManager.cancelUndo()
            AnalyticsHelper.trackError(error.localizedDescription, context: "swipe")
        }
    }
    
    func undoLastSwipe() async {
        guard let (card, direction) = undoManager.performUndo() else { return }
        
        do {
            // Restore card to deck
            if currentTab == .stock {
                stockCards.insert(card, at: 0)
            } else {
                ideaCards.insert(card, at: 0)
            }
            
            // Increment swipes (reverse the decrement)
            swipesRemaining += 1
            
            // Remove from saved if it was a right swipe
            if direction == .right {
                try await removeInvestmentFromFirestore(card.id)
            }
            
            // Update backend - increment swipe count
            guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            
            // Get current swipe count and increment
            let userDoc = try await FirebaseManager.shared.db
                .collection("users")
                .document(userId)
                .getDocument()
            
            if let currentSwipes = userDoc.data()?["swipesRemainingToday"] as? Int {
                try await FirebaseManager.shared.db
                    .collection("users")
                    .document(userId)
                    .updateData([
                        "swipesRemainingToday": min(currentSwipes + 1, maxSwipes)
                    ])
            }
            
            // Reload user status to ensure accuracy
            await loadUserStatus()
            
            // Hide paywall if it was showing
            if swipesRemaining > 0 {
                showPaywall = false
            }
            
            AnalyticsHelper.trackSwipeUndone(direction: direction.rawValue)
            
            #if DEBUG
            print("✅ Swipe undone: \(direction.rawValue) on \(card.title), swipes now: \(swipesRemaining)")
            #endif
        } catch {
            #if DEBUG
            print("❌ Error undoing swipe: \(error)")
            #endif
            AnalyticsHelper.trackError("undo_swipe_failed", context: "undo_swipe")
            self.error = "Couldn't undo swipe. Please try again."
        }
    }
    
    private func removeInvestmentFromFirestore(_ id: UUID) async throws {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        try await FirebaseManager.shared.db
            .collection("users")
            .document(userId)
            .collection("saved_investments")
            .document(id.uuidString)
            .delete()
    }
    
    private func saveInvestmentToFirestore(_ investment: Investment) async throws {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(investment)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        try await FirebaseManager.shared.db
            .collection("users")
            .document(userId)
            .collection("saved_investments")
            .document(investment.id.uuidString)
            .setData(dict)
    }
    
    func saveInterest(_ investment: Investment) {
        Task {
            try? await saveInvestmentToFirestore(investment)
        }
    }
    
    func loadNotifications() {
        notifications = storage.loadNotifications()
    }
    
    private func updateNotificationsFromCards() {
        // Create notifications from stock cards
        var newNotifications: [AppNotification] = []
        
        // Add up to 3 stock recommendations
        for (index, stock) in stockCards.prefix(3).enumerated() {
            let ticker = stock.ticker ?? stock.title
            newNotifications.append(AppNotification(
                title: "Stock Suggestion",
                message: "\(ticker) - \(stock.tagline)",
                time: index == 0 ? "Just now" : "\(index + 1) hours ago",
                isNew: true
            ))
        }
        
        // Add "See More" divider notification
        if !stockCards.isEmpty {
            newNotifications.append(AppNotification(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                title: "See More",
                message: "Swipe through cards to see all recommendations",
                time: "",
                isNew: false
            ))
        }
        
        notifications = newNotifications
        storage.saveNotifications(newNotifications)
    }
    
    func markNotificationRead(_ id: UUID) {
        storage.markNotificationAsRead(id)
        loadNotifications()
    }
}
