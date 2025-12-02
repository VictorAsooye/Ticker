import SwiftUI
import FirebaseCore
import UserNotifications
import GoogleSignIn

@main
struct TickerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var authViewModel = AuthViewModel()
    @State private var sessionStartTime = Date()
    @State private var showLaunchScreen = true
    
    init() {
        // Configure PurchaseManager BEFORE AuthViewModel tries to use it
        PurchaseManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    if authViewModel.isAuthenticated {
                        if authViewModel.hasCompletedOnboarding {
                            NavigationStack {
                                HomeView()
                                    .navigationBarHidden(true)
                            }
                            .environmentObject(authViewModel)
                        } else {
                            OnboardingView()
                                .environmentObject(authViewModel)
                        }
                    } else {
                        AuthenticationView()
                            .environmentObject(authViewModel)
                    }
                }
            }
            .onAppear {
                // Show launch screen for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                sessionStartTime = Date()
                AnalyticsHelper.trackSessionStart()
                if authViewModel.isAuthenticated {
                    AnalyticsHelper.trackDailyActive()
                    // Refresh swipe status when app comes to foreground
                    Task {
                        if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                            try? await CloudFunctionsService.shared.getSwipeStatus()
                        }
                    }
                }
            case .inactive, .background:
                let duration = Date().timeIntervalSince(sessionStartTime)
                AnalyticsHelper.trackSessionEnd(duration: duration)
            @unknown default:
                break
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase and PurchaseManager in AppDelegate to ensure it's done early
        FirebaseManager.shared.configure()
        PurchaseManager.shared.configure() // Configure before any views try to use it
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle Google Sign In URL
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Navigate to home screen
        NotificationCenter.default.post(name: .openHomeScreen, object: nil)
        
        FirebaseManager.shared.logEvent("notification_tapped", parameters: [
            "notification_id": response.notification.request.identifier
        ])
        
        completionHandler()
    }
}

extension Notification.Name {
    static let openHomeScreen = Notification.Name("openHomeScreen")
}

