import SwiftUI

struct SideMenu: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        HStack {
            Spacer()
            
            NavigationStack(path: $navigationPath) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("Menu")
                            .font(.custom(AppFonts.serifTitle, size: 28))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.text)
                        
                        Spacer()
                        
                        Button(action: {
                            isShowing = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 44, height: 44)
                                .background(AppColors.background)
                                .cornerRadius(8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(24)
                    
                    Divider()
                        .background(Color(hex: "222222"))
                    
                    // Menu items
                    ScrollView {
                        VStack(spacing: 0) {
                            MenuNavigationButton(icon: "person", title: "Profile", destination: AnyView(ProfileView()), isShowing: $isShowing)
                            
                            MenuNavigationButton(icon: "gearshape", title: "Settings", destination: AnyView(SettingsView()), isShowing: $isShowing)
                            
                            MenuNavigationButton(icon: "bell", title: "Notifications", destination: AnyView(NotificationsSettingsView()), isShowing: $isShowing)
                            
                            MenuNavigationButton(icon: "bookmark", title: "My Interests", destination: AnyView(SavedInterestsView()), isShowing: $isShowing)
                            
                            MenuNavigationButton(icon: "questionmark.circle", title: "Help & Support", destination: AnyView(HelpSupportView()), isShowing: $isShowing)
                            
                            Divider()
                                .background(Color(hex: "222222"))
                                .padding(.vertical, 8)
                            
                            MenuButton(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", color: AppColors.red) {
                                Task {
                                    authViewModel.signOut()
                                    isShowing = false
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(width: 320)
            .frame(maxHeight: .infinity)
            .background(AppColors.background)
            .overlay(
                Rectangle()
                    .fill(Color(hex: "222222"))
                    .frame(width: 1),
                alignment: .leading
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: -10, y: 0)
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    var color: Color = AppColors.textSecondary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(color == AppColors.red ? color : AppColors.text)
                
                Spacer()
            }
            .padding(16)
            .background(AppColors.background)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Group {
                if color != AppColors.red {
                    AppColors.darkGray.opacity(0)
                } else {
                    AppColors.background
                }
            }
        )
        .onHover { hovering in
            // Hover effect would go here if needed
        }
    }
}

struct MenuNavigationButton: View {
    let icon: String
    let title: String
    let destination: AnyView
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationLink(destination: destination.onAppear {
            isShowing = false
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(16)
            .background(AppColors.background)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
