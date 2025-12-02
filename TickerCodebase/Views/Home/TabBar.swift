import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: InvestmentType
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "STOCKS",
                icon: "chart.line.uptrend.xyaxis",
                isSelected: selectedTab == .stock,
                action: { 
                    HapticManager.shared.selection()
                    selectedTab = .stock 
                }
            )
            
            TabButton(
                title: "IDEAS",
                icon: "lightbulb",
                isSelected: selectedTab == .idea,
                action: { 
                    HapticManager.shared.selection()
                    selectedTab = .idea 
                }
            )
        }
        .padding(.horizontal, AppConstants.spacingLG)
        .padding(.vertical, AppConstants.spacingSM)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppConstants.spacingXS) {
                HStack(spacing: AppConstants.spacingXS) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                    Text(title)
                        .font(.system(size: AppConstants.fontSizeTab, weight: .medium))
                        .tracking(AppConstants.trackingTab)
                }
                .foregroundColor(isSelected ? AppColors.text : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                
                // Underline: 2px white when selected, 8px gap from text
                Rectangle()
                    .fill(isSelected ? AppColors.text : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
