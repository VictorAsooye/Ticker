import SwiftUI

struct NotificationDropdown: View {
    let notifications: [AppNotification]
    let onDismiss: () -> Void
    let onMarkRead: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("STOCK SUGGESTION")
                            .font(.system(size: 12, weight: .medium))
                            .tracking(1.2)
                            .foregroundColor(AppColors.text)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(AppColors.background)
                    .overlay(
                        Rectangle()
                            .fill(Color(hex: "222222"))
                            .frame(height: 1),
                        alignment: .bottom
                    )
                    
                    // Notifications list
                    ScrollView {
                        VStack(spacing: 0) {
                            if notifications.isEmpty {
                                // Empty state
                                VStack(spacing: AppConstants.spacingSM) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 32))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("No notifications")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                            } else {
                                ForEach(notifications) { notification in
                                if notification.title == "See More" {
                                    // Divider for "See More"
                                    VStack(spacing: 8) {
                                        Divider()
                                            .background(Color(hex: "333333"))
                                            .padding(.horizontal, 16)
                                        
                                        HStack {
                                            Text(notification.message)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(AppColors.textSecondary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                    }
                                    .background(AppColors.background)
                                } else {
                                    Button(action: {
                                        onMarkRead(notification.id)
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(alignment: .top) {
                                                Text(notification.title)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(AppColors.text)
                                                
                                                Spacer()
                                                
                                                if notification.isNew {
                                                    Text("NEW")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.black)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(AppColors.text)
                                                        .foregroundColor(AppColors.background)
                                                        .cornerRadius(4)
                                                }
                                            }
                                            
                                            Text(notification.message)
                                                .font(.system(size: 13))
                                                .foregroundColor(AppColors.textSecondary)
                                                .lineLimit(2)
                                            
                                            if !notification.time.isEmpty {
                                                Text(notification.time)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                            }
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(AppColors.background)
                                        .overlay(
                                            Rectangle()
                                                .fill(Color(hex: "1a1a1a"))
                                                .frame(height: 1),
                                            alignment: .bottom
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                }
                .frame(width: 384)
                .background(AppColors.background)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "333333"), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Spacer()
                    .frame(width: 24)
            }
            
            Spacer()
        }
        .padding(.top, 120)
    }
}
