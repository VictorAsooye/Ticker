import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.custom(AppFonts.serifTitle, size: 32))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.text)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 32)
                    
                    // Account Section
                    VStack(spacing: 0) {
                        SectionHeader(title: "ACCOUNT")
                        
                        if let email = authViewModel.currentUser?.email {
                            SettingsRow(icon: "envelope", title: "Email", value: email)
                        }
                        
                        if purchaseManager.isPro {
                            SettingsButton(icon: "crown.fill", title: "Manage Subscription", iconColor: AppColors.text) {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                    
                    // Preferences Section
                    VStack(spacing: 0) {
                        SectionHeader(title: "PREFERENCES")
                        
                        SettingsToggle(
                            icon: "bell",
                            title: "Notifications",
                            isOn: $notificationManager.notificationsEnabled
                        ) {
                            if notificationManager.notificationsEnabled {
                                Task {
                                    await notificationManager.requestAuthorization()
                                }
                            } else {
                                notificationManager.cancelAllNotifications()
                            }
                        }
                        
                        Divider().background(Color(hex: "222222"))
                        
                        SettingsHapticToggle()
                    }
                    
                    // Legal Section
                    VStack(spacing: 0) {
                        SectionHeader(title: "LEGAL")
                        
                        NavigationLink(destination: LegalView(type: .disclaimer)) {
                            SettingsRowButton(icon: "exclamationmark.triangle", title: "Investment Disclaimer")
                        }
                        
                        NavigationLink(destination: LegalView(type: .terms)) {
                            SettingsRowButton(icon: "doc.text", title: "Terms of Service")
                        }
                        
                        NavigationLink(destination: LegalView(type: .privacy)) {
                            SettingsRowButton(icon: "lock.shield", title: "Privacy Policy")
                        }
                    }
                    
                    // Support Section
                    VStack(spacing: 0) {
                        SectionHeader(title: "SUPPORT")
                        
                        SettingsButton(icon: "envelope", title: "Contact Support") {
                            if let url = URL(string: "mailto:support@tickerapp.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsButton(icon: "star", title: "Rate Ticker") {
                            // Request review
                            if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    // Danger Zone
                    VStack(spacing: 0) {
                        SectionHeader(title: "DANGER ZONE")
                        
                        SettingsButton(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", iconColor: AppColors.red) {
                            authViewModel.signOut()
                        }
                        
                        SettingsButton(icon: "trash", title: "Delete Account", iconColor: AppColors.red) {
                            showDeleteConfirmation = true
                        }
                    }
                    
                    // App Version
                    Text("Version 1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await authViewModel.deleteAccount()
                }
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppColors.text)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.darkGray)
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    var iconColor: Color = AppColors.textSecondary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor == AppColors.red ? iconColor : AppColors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(AppColors.darkGray)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppColors.text)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.darkGray)
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let onChange: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppColors.text)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppColors.text)
                .onChange(of: isOn) { _ in
                    onChange()
                }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.darkGray)
    }
}

struct SettingsHapticToggle: View {
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "hand.tap")
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Haptic Feedback")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.text)
                
                Text("Vibration on interactions")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $hapticFeedbackEnabled)
                .tint(AppColors.text)
                .onChange(of: hapticFeedbackEnabled) { newValue in
                    // Provide haptic feedback when toggling ON to demonstrate it works
                    // We use direct generator here because AppStorage hasn't updated yet
                    if newValue {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.darkGray)
    }
}



