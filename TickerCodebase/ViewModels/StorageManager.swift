import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let userProfileKey = "userProfile"
    private let savedInvestmentsKey = "savedInvestments"
    private let notificationsKey = "notifications"
    
    private init() {}
    
    // User Profile
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: userProfileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    // Saved Investments
    func saveInvestment(_ investment: Investment) {
        var saved = loadSavedInvestments()
        if !saved.contains(where: { $0.id == investment.id }) {
            saved.append(investment)
            if let encoded = try? JSONEncoder().encode(saved) {
                UserDefaults.standard.set(encoded, forKey: savedInvestmentsKey)
            }
        }
    }
    
    func loadSavedInvestments() -> [Investment] {
        guard let data = UserDefaults.standard.data(forKey: savedInvestmentsKey),
              let investments = try? JSONDecoder().decode([Investment].self, from: data) else {
            return []
        }
        return investments
    }
    
    func removeSavedInvestment(_ id: UUID) {
        var saved = loadSavedInvestments()
        saved.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(encoded, forKey: savedInvestmentsKey)
        }
    }
    
    // Notifications
    func saveNotifications(_ notifications: [AppNotification]) {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: notificationsKey)
        }
    }
    
    func loadNotifications() -> [AppNotification] {
        guard let data = UserDefaults.standard.data(forKey: notificationsKey),
              let notifications = try? JSONDecoder().decode([AppNotification].self, from: data) else {
            return defaultNotifications()
        }
        return notifications
    }
    
    func markNotificationAsRead(_ id: UUID) {
        var notifications = loadNotifications()
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isNew = false
            saveNotifications(notifications)
        }
    }
    
    private func defaultNotifications() -> [AppNotification] {
        return [
            AppNotification(
                title: "TSLA Breaking Out",
                message: "Tesla up 8% on new product announcement. Consider reviewing.",
                time: "2 hours ago",
                isNew: true
            ),
            AppNotification(
                title: "Healthcare AI Opportunity",
                message: "New AI regulations favor companies like Palantir in healthcare.",
                time: "5 hours ago",
                isNew: true
            )
        ]
    }
}
