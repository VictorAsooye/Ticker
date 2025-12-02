import SwiftUI

struct NotificationsSettingsView: View {
    @State private var notificationsEnabled = true
    @State private var dailyRecommendations = true
    @State private var priceAlerts = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Notifications")
                        .font(.custom(AppFonts.serifTitle, size: 32))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.text)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    VStack(spacing: 0) {
                        ToggleRow(title: "Enable Notifications", isOn: $notificationsEnabled)
                        Divider().background(Color(hex: "222222"))
                        ToggleRow(title: "Daily Recommendations", isOn: $dailyRecommendations)
                        Divider().background(Color(hex: "222222"))
                        ToggleRow(title: "Price Alerts", isOn: $priceAlerts)
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.text)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppColors.text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

