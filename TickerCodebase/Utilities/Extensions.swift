import SwiftUI
import Foundation

extension View {
    func cardStyle() -> some View {
        self
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

