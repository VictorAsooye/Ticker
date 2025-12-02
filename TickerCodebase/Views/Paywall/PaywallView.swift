import SwiftUI

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showNotNow = false
    @State private var showError = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        showNotNow = true
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(16)
                    }
                }
                
                Spacer()
                
                if purchaseManager.isLoading {
                    ProgressView()
                        .tint(AppColors.text)
                } else {
                    VStack(spacing: 24) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.text)
                        
                        Text("Upgrade to Pro")
                            .font(.custom(AppFonts.serifTitle, size: 36))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.text)
                        
                        VStack(spacing: 8) {
                            Text("You've reached your daily limit")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Check back tomorrow at 9am for new recommendations")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "infinity", text: "50 swipes per day")
                            FeatureRow(icon: "sparkles", text: "Priority AI recommendations")
                            FeatureRow(icon: "bell.badge", text: "Custom notifications")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced analytics")
                        }
                        .padding(.vertical, 24)
                        
                        // Pricing
                        VStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    do {
                                        HapticManager.shared.notification(.success)
                                        try await purchaseManager.purchase()
                                        dismiss()
                                    } catch {
                                        showError = true
                                    }
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text("Start Free Trial")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColors.text)
                                    
                                    Text("Then $4.99/month")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(Color.clear)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.text, lineWidth: 1)
                                )
                            }
                            
                            Button(action: {
                                Task {
                                    try? await purchaseManager.restorePurchases()
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.top, 8)
                            
                            if showNotNow {
                                VStack(spacing: 4) {
                                    Button(action: {
                                        dismiss()
                                    }) {
                                        Text("Not now")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Text("Check back tomorrow at 9am")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Terms
                Text("Auto-renewable subscription. Cancel anytime.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 32)
            }
        }
        .task {
            await purchaseManager.loadOfferings()
            AnalyticsHelper.trackPaywallViewed(trigger: "daily_limit")
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseManager.error ?? "Something went wrong")
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.text)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(AppColors.text)
            
            Spacer()
        }
    }
}

