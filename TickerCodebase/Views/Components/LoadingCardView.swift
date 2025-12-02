import SwiftUI

struct LoadingCardView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // White accent bar
            Rectangle()
                .fill(AppColors.text)
                .frame(height: 4)
            
            VStack(alignment: .leading, spacing: 0) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    // Title placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(shimmerGradient)
                        .frame(width: 200, height: 32)
                    
                    // Tagline placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(shimmerGradient)
                        .frame(width: 280, height: 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                // Divider
                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                
                // Content section
                VStack(alignment: .leading, spacing: 20) {
                    // Simple explainer placeholder
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(height: 14)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(height: 14)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(width: 180, height: 14)
                    }
                    .padding(.top, 20)
                    
                    // Good reasons placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(width: 120, height: 16)
                        
                        ForEach(0..<3) { _ in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(shimmerGradient)
                                    .frame(width: 6, height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(shimmerGradient)
                                    .frame(height: 12)
                            }
                        }
                    }
                    
                    // Concerns placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(width: 100, height: 16)
                        
                        ForEach(0..<2) { _ in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(shimmerGradient)
                                    .frame(width: 6, height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(shimmerGradient)
                                    .frame(height: 12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                Spacer()
                
                // Loading indicator at bottom
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.text))
                        .scaleEffect(0.8)
                    
                    Text("Loading recommendations...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                AppColors.darkGray.opacity(0.3),
                AppColors.darkGray.opacity(0.6),
                AppColors.darkGray.opacity(0.3)
            ]),
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}



