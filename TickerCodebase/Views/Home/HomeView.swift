import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var showMenu = false
    @State private var showNotifications = false
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    @State private var showDisclaimer = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (matching React mockup exactly)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ticker")
                            .font(.custom(AppFonts.serifTitle, size: AppConstants.fontSizeHeader))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.text)
                            .tracking(AppConstants.trackingHeader)
                        
                        Text("AI-POWERED INVESTMENT EDUCATION")
                            .font(.system(size: AppConstants.fontSizeSubtitle, weight: .medium))
                            .tracking(AppConstants.trackingSubtitle)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: AppConstants.spacingMD) {
                        // Notification bell (20px icon, 44x44 touch target)
                        Button(action: {
                            showNotifications.toggle()
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.text)
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                                
                                if viewModel.notifications.contains(where: { $0.isNew }) {
                                    Circle()
                                        .fill(AppColors.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Menu button (20px icon, 44x44 touch target)
                        Button(action: {
                            showMenu.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.text)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, AppConstants.spacingLG)
                .padding(.top, 60)
                .padding(.bottom, AppConstants.spacingMD)
                .background(AppColors.background)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(hex: "222222")),
                    alignment: .bottom
                )
                
                // Tab bar
                TabBar(selectedTab: $viewModel.currentTab)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                
                // Card stack
                GeometryReader { geometry in
                    HStack {
                        if DeviceHelper.isIPad {
                            Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            if viewModel.isLoading {
                                VStack(spacing: AppConstants.spacingLG) {
                                    // Show 2 shimmer cards for better loading experience
                                    ForEach(0..<2, id: \.self) { _ in
                                        LoadingCardView()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 600)
                                    }
                                }
                                .padding(.horizontal, AppConstants.spacingLG)
                                .padding(.vertical, AppConstants.spacingLG)
                            } else if let error = viewModel.error {
                                Spacer()
                                VStack(spacing: 16) {
                                    Text("Oops!")
                                        .font(.custom(AppFonts.serifTitle, size: 24))
                                        .foregroundColor(AppColors.text)
                                    Text(error)
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                    Button(action: {
                                        AnalyticsHelper.trackRetry(context: "load_cards")
                                        Task {
                                            await viewModel.loadInitialCards()
                                        }
                                    }) {
                                        Text("Try Again")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppColors.text)
                                            .padding(.horizontal, AppConstants.spacingLG)
                                            .padding(.vertical, AppConstants.spacingSM)
                                            .background(Color.clear)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(AppColors.text, lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(.horizontal, 32)
                                Spacer()
                            } else if viewModel.getCurrentCards().isEmpty && !viewModel.isLoading {
                                // Empty state when no cards available
                                Spacer()
                                VStack(spacing: AppConstants.spacingMD) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 48))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("No more cards")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(AppColors.text)
                                    
                                    Text("Check back tomorrow at 9am for fresh recommendations")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppConstants.spacingXL)
                                }
                                .frame(maxHeight: .infinity)
                                .padding(.vertical, 60)
                                Spacer()
                            } else {
                                SwipeCardStack(
                                    cards: viewModel.getCurrentCards(),
                                    swipesRemaining: viewModel.swipesRemaining,
                                    subscriptionTier: viewModel.subscriptionTier,
                                    onSwipeLeft: { card in
                                        Task {
                                            await viewModel.handleSwipe(card: card, direction: .left)
                                            // removeTopCard() is already called inside handleSwipe()
                                        }
                                    },
                                    onSwipeRight: { card in
                                        Task {
                                            await viewModel.handleSwipe(card: card, direction: .right)
                                            // removeTopCard() is already called inside handleSwipe()
                                        }
                                    }
                                )
                            }
                        }
                        .frame(maxWidth: DeviceHelper.cardMaxWidth)
                        .frame(maxHeight: .infinity)
                        
                        if DeviceHelper.isIPad {
                            Spacer()
                        }
                    }
                }
            }
            
            // Overlays
            if showNotifications {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showNotifications = false
                    }
                
                NotificationDropdown(
                    notifications: viewModel.notifications,
                    onDismiss: { showNotifications = false },
                    onMarkRead: { id in
                        viewModel.markNotificationRead(id)
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if showMenu {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMenu = false
                    }
                
                SideMenu(isShowing: $showMenu)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showNotifications)
        .animation(.easeInOut(duration: 0.3), value: showMenu)
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
                .environmentObject(authViewModel)
        }
        .overlay {
            if showDisclaimer {
                DisclaimerPopupView(isPresented: $showDisclaimer)
            }
        }
        .onAppear {
            if !hasSeenDisclaimer {
                showDisclaimer = true
            }
        }
        .overlay(alignment: .top) {
            // Undo banner
            if viewModel.undoManager.showUndoBanner,
               let card = viewModel.undoManager.lastSwipedCard,
               let direction = viewModel.undoManager.lastSwipeDirection {
                
                UndoBannerView(
                    cardTitle: card.type == .stock ? (card.ticker ?? card.title) : card.title,
                    direction: direction,
                    onUndo: {
                        Task {
                            await viewModel.undoLastSwipe()
                        }
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 16)
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("Try Again") {
                if let retry = viewModel.errorRetryAction {
                    Task {
                        await retry()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.error ?? "Something went wrong")
        }
    }
}
