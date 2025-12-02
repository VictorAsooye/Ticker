import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Profile")
                            .font(.custom(AppFonts.serifTitle, size: 32))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.text)
                        
                        if let email = authViewModel.currentUser?.email {
                            Text(email)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    
                    // Account Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account Information")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.text)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            ProfileRow(title: "Email", value: authViewModel.currentUser?.email ?? "Not available")
                            Divider().background(Color(hex: "222222"))
                            ProfileRow(title: "User ID", value: authViewModel.currentUser?.uid ?? "Not available")
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

