import SwiftUI

struct InvestmentAmountView: View {
    @Binding var profile: UserProfile
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("How much are you thinking of investing?")
                    .font(.custom(AppFonts.serifTitle, size: 32))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Don't worry, you can always start smaller")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 60)
            
            VStack(spacing: 12) {
                ForEach(UserProfile.InvestmentAmount.allCases, id: \.self) { amount in
                    Button(action: {
                        profile.investmentAmount = amount
                        HapticManager.shared.selection()
                        withAnimation {
                            currentStep = 1
                        }
                    }) {
                        HStack {
                            Text(amount.rawValue)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppColors.text)
                            
                            Spacer()
                            
                            if profile.investmentAmount == amount {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.text)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(profile.investmentAmount == amount ? AppColors.darkGray : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(profile.investmentAmount == amount ? AppColors.text : AppColors.border, lineWidth: profile.investmentAmount == amount ? 2 : 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}
