import SwiftUI

struct UndoBannerView: View {
    let cardTitle: String
    let direction: SwipeDirection
    let onUndo: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: direction == .left ? "hand.thumbsdown" : "hand.thumbsup")
                .font(.system(size: 18))
                .foregroundColor(direction == .left ? AppColors.red : AppColors.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(direction == .left ? "Passed" : "Saved")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.text)
                
                Text(cardTitle)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                onUndo()
                // Haptic feedback
                HapticManager.shared.impact(.medium)
            }) {
                Text("UNDO")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.text)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.darkGray)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        .padding(.horizontal, 24)
    }
}



