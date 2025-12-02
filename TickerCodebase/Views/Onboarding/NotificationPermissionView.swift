import SwiftUI

struct NotificationPermissionView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Binding var hasCompletedOnboarding: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.text)
                
                Text("Stay Updated")
                    .font(.custom(AppFonts.serifTitle, size: 32))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.text)
                
                Text("Get daily recommendations at 9am and 6pm")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 80)
            
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        _ = await notificationManager.requestAuthorization()
                        onContinue()
                    }
                }) {
                    Text("Enable Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.text, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onContinue()
                }) {
                    Text("Not Now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .background(AppColors.background)
    }
}



