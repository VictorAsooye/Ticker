import SwiftUI

struct DisclaimerPopupView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.text)
                
                Text("Important Notice")
                    .font(.custom(AppFonts.serifTitle, size: 28))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.text)
                
                VStack(alignment: .leading, spacing: 16) {
                    DisclaimerPoint(text: "Ticker provides educational information only")
                    DisclaimerPoint(text: "This is not financial or investment advice")
                    DisclaimerPoint(text: "Always consult a licensed financial advisor")
                    DisclaimerPoint(text: "All investments carry risk of loss")
                    DisclaimerPoint(text: "Prices shown are estimates only")
                }
                
                Button(action: {
                    hasSeenDisclaimer = true
                    isPresented = false
                    FirebaseManager.shared.logEvent("disclaimer_accepted")
                }) {
                    Text("I Understand")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.clear)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.text, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    // Show full disclaimer
                    // Navigate to LegalView
                }) {
                    Text("Read Full Disclaimer")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(32)
            .background(AppColors.darkGray)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }
}

struct DisclaimerPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.text)
                .font(.system(size: 18))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AppColors.text)
                .lineSpacing(4)
        }
    }
}



