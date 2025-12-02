import SwiftUI

struct SwipeCardStack: View {
    let cards: [Investment]
    let swipesRemaining: Int
    let subscriptionTier: UserDocument.SubscriptionTier
    let onSwipeLeft: (Investment) -> Void
    let onSwipeRight: (Investment) -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var isSwiping = false
    @State private var swipedCardId: UUID?
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private let swipeThreshold: CGFloat = 150
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Swipes remaining indicator - only show when cards exist
                if !cards.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "hand.point.up.left")
                                    .font(.system(size: 12))
                                Text("\(swipesRemaining) swipes left today")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(swipesRemaining <= 3 ? AppColors.red : AppColors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.darkGray)
                            .cornerRadius(20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
            
                if cards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.text)
                        
                        Text("You're all caught up!")
                            .font(.custom(AppFonts.serifTitle, size: 24))
                            .foregroundColor(AppColors.text)
                        
                        VStack(spacing: 8) {
                            Text("Check back tomorrow at 9am")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            if swipesRemaining <= 0 {
                                Text("for new recommendations")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Card stack container
                    ZStack {
                        // Background card (for depth)
                        if cards.count > 1 && swipedCardId != cards[1].id {
                            InvestmentCard(investment: cards[1])
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .scaleEffect(0.95)
                                .offset(y: 10)
                                .opacity(0.5)
                        }
                        
                        // Top card (swipeable) - only show if not swiped
                        if swipedCardId != cards[0].id {
                            InvestmentCard(investment: cards[0])
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .offset(offset)
                                .rotationEffect(.degrees(reduceMotion ? 0 : rotation))
                                .opacity(isSwiping ? 0 : 1)
                                .accessibilityAction(named: "Pass") {
                                    handleSwipe(direction: .left, card: cards[0])
                                }
                                .accessibilityAction(named: "Save") {
                                    handleSwipe(direction: .right, card: cards[0])
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            offset = gesture.translation
                                            rotation = Double(gesture.translation.width / 20)
                                        }
                                        .onEnded { gesture in
                                            let swipeDistance = gesture.translation.width
                                            
                                            if abs(swipeDistance) > swipeThreshold {
                                                // Complete the swipe
                                                HapticManager.shared.impact(.medium)
                                                isSwiping = true
                                                swipedCardId = cards[0].id
                                                
                                                withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                                    offset = CGSize(
                                                        width: swipeDistance > 0 ? 500 : -500,
                                                        height: gesture.translation.height
                                                    )
                                                    rotation = reduceMotion ? 0 : (swipeDistance > 0 ? 30 : -30)
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    if swipeDistance > 0 {
                                                        onSwipeRight(cards[0])
                                                    } else {
                                                        onSwipeLeft(cards[0])
                                                    }
                                                    // Reset after callback
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        offset = .zero
                                                        rotation = 0
                                                        isSwiping = false
                                                    }
                                                }
                                            } else {
                                                // Snap back
                                                HapticManager.shared.impact(.light)
                                                withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                                    offset = .zero
                                                    rotation = 0
                                                }
                                            }
                                        }
                                )
                        }
                    }
                    
                    // Action buttons - fixed at bottom
                    VStack {
                        Spacer()
                        
                        HStack(spacing: AppConstants.spacingMD) {
                            // PASS button (white text, gray border, transparent fill)
                            Button(action: {
                                guard !cards.isEmpty else { return }
                                handleSwipe(direction: .left, card: cards[0])
                            }) {
                                Text("PASS")
                                    .font(.system(size: AppConstants.fontSizeButton, weight: .semibold))
                                    .tracking(AppConstants.trackingButton)
                                    .foregroundColor(AppColors.text)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                            }
                            .accessibilityLabel("Pass on this investment")
                            .accessibilityHint("Swipe left or tap to skip this card")
                            
                            // INTERESTED button (white text, white border, transparent fill)
                            Button(action: {
                                guard !cards.isEmpty else { return }
                                handleSwipe(direction: .right, card: cards[0])
                            }) {
                                Text("INTERESTED")
                                    .font(.system(size: AppConstants.fontSizeButton, weight: .semibold))
                                    .tracking(AppConstants.trackingButton)
                                    .foregroundColor(AppColors.text)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.text, lineWidth: 1)
                                    )
                            }
                            .accessibilityLabel("Save this investment")
                            .accessibilityHint("Swipe right or tap to save to your interests")
                        }
                        .padding(.horizontal, AppConstants.spacingLG)
                        .padding(.bottom, AppConstants.spacingLG)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.background, AppColors.background.opacity(0)]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .frame(height: 120)
                            .offset(y: 24)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: cards) { oldCards, newCards in
            // Reset swipe state when cards change
            if oldCards.first?.id != newCards.first?.id {
                swipedCardId = nil
                isSwiping = false
                offset = .zero
                rotation = 0
            }
        }
    }
    
    private func handleSwipe(direction: SwipeDirection, card: Investment) {
        guard swipedCardId != card.id else { return }
        
        HapticManager.shared.impact(.light)
        isSwiping = true
        swipedCardId = card.id
        
        withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
            offset = CGSize(width: direction == .right ? 500 : -500, height: 0)
            rotation = reduceMotion ? 0 : (direction == .right ? 30 : -30)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if direction == .right {
                onSwipeRight(card)
            } else {
                onSwipeLeft(card)
            }
            // Reset after callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                offset = .zero
                rotation = 0
                isSwiping = false
            }
        }
    }
}
