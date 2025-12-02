import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // Black background matching app theme
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Logo/Icon - Using a stylized investment symbol
                // You can replace this with your actual logo image:
                // Image("AppIcon") or Image("Logo")
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    // Inner symbol - stylized interlocking loops
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.text)
                        .opacity(opacity)
                }
                
                // App Name
                Text("Ticker")
                    .font(.custom(AppFonts.serifTitle, size: 48))
                    .foregroundColor(AppColors.text)
                    .opacity(opacity)
                
                // Tagline
                Text("Invest Smarter")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(AppColors.textSecondary)
                    .opacity(opacity * 0.8)
            }
        }
        .onAppear {
            // Fade in animation
            withAnimation(.easeInOut(duration: 0.8)) {
                opacity = 1.0
            }
            
            // Subtle pulse animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}

