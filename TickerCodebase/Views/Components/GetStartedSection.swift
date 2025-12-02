import SwiftUI

struct GetStartedSection: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(AppColors.text)
            
            Text("Welcome to Ticker")
                .font(.custom(AppFonts.serifTitle, size: 32))
                .foregroundColor(AppColors.text)
                .multilineTextAlignment(.center)
            
            Text("Swipe through investment opportunities and learn about stocks and business ideas tailored to your interests.")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.text, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    GetStartedSection(onGetStarted: {})
        .background(AppColors.background)
}

