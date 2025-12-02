import SwiftUI

struct InterestsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var profile: UserProfile
    @Binding var currentStep: Int
    @Binding var showNotificationPermission: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("What interests you most?")
                    .font(.custom(AppFonts.serifTitle, size: 32))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Select all that apply")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 60)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(UserProfile.Interest.allCases, id: \.self) { interest in
                    Button(action: {
                        if profile.interests.contains(interest) {
                            profile.interests.removeAll { $0 == interest }
                        } else {
                            profile.interests.append(interest)
                        }
                        HapticManager.shared.selection()
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: interest.icon)
                                .font(.system(size: 32))
                                .foregroundColor(profile.interests.contains(interest) ? AppColors.text : AppColors.textSecondary)
                            
                            Text(interest.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.text)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(profile.interests.contains(interest) ? AppColors.darkGray : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(profile.interests.contains(interest) ? AppColors.text : AppColors.border, lineWidth: profile.interests.contains(interest) ? 2 : 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                showNotificationPermission = true
            }) {
                Text("Get Started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(profile.interests.isEmpty ? AppColors.border : AppColors.text, lineWidth: 1)
                    )
            }
            .disabled(profile.interests.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}
