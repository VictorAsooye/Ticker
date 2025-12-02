import Foundation
import UserNotifications
import FirebaseFirestore

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled = false
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
            }
            
            if granted {
                print("✅ Notifications authorized")
                await scheduleDailyNotifications()
                FirebaseManager.shared.logEvent("notifications_enabled")
            } else {
                print("⛔ Notifications denied")
                FirebaseManager.shared.logEvent("notifications_denied")
            }
            
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
                print("📱 Notification status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    func scheduleDailyNotifications() async {
        let center = UNUserNotificationCenter.current()
        
        // CRITICAL FIX: Check permission first
        let settings = await center.notificationSettings()
        
        guard settings.authorizationStatus == .authorized else {
            print("⛔ Cannot schedule notifications: Not authorized")
            return
        }
        
        print("📅 Scheduling daily notifications...")
        
        // Remove ALL existing notifications first
        center.removeAllPendingNotificationRequests()
        
        // Schedule 9 AM notification
        await scheduleNotification(
            id: "morning_notification",
            hour: 9,
            minute: 0,
            title: "New investment opportunities!",
            body: "Fresh stock picks and ideas are ready for you 📈"
        )
        
        // Schedule 6 PM notification
        await scheduleNotification(
            id: "evening_notification",
            hour: 18,
            minute: 0,
            title: "Evening market insights",
            body: "Check out today's trending investments 🚀"
        )
        
        // Verify notifications were scheduled
        let pending = await center.pendingNotificationRequests()
        print("✅ Scheduled \(pending.count) notifications:")
        for request in pending {
            print("  - \(request.identifier)")
        }
        
        FirebaseManager.shared.logEvent("notifications_scheduled", parameters: [
            "count": pending.count
        ])
    }
    
    private func scheduleNotification(id: String, hour: Int, minute: Int, title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Scheduled: \(id) at \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("❌ Error scheduling \(id): \(error)")
        }
    }
    
    func scheduleStockAlertNotification(ticker: String, message: String) async {
        let content = UNMutableNotificationContent()
        content.title = "\(ticker) Alert"
        content.body = "\(message) - Check it out! 📈"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "stock_alert_\(ticker)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            FirebaseManager.shared.logEvent("stock_alert_sent", parameters: ["ticker": ticker])
        } catch {
            print("Error sending stock alert: \(error)")
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications cancelled")
        FirebaseManager.shared.logEvent("notifications_cancelled")
    }
}



