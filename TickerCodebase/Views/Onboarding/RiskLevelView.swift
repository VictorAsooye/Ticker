import SwiftUI

struct RiskLevelView: View {
    @Binding var profile: UserProfile
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("What's your risk comfort level?")
                    .font(.custom(AppFonts.serifTitle, size: 32))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("How much volatility can you handle?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 60)
            
            VStack(spacing: 12) {
                ForEach(UserProfile.RiskLevel.allCases, id: \.self) { risk in
                    Button(action: {
                        profile.riskLevel = risk
                        HapticManager.shared.selection()
                        withAnimation {
                            currentStep = 2
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(risk.rawValue)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(AppColors.text)
                                
                                Spacer()
                                
                                if profile.riskLevel == risk {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.text)
                                }
                            }
                            
                            Text(risk.description)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(profile.riskLevel == risk ? AppColors.darkGray : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(profile.riskLevel == risk ? AppColors.text : AppColors.border, lineWidth: profile.riskLevel == risk ? 2 : 1)
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
