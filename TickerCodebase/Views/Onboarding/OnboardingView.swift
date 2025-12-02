import SwiftUI
import FirebaseFirestore

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    @State private var profile = UserProfile()
    @State private var showNotificationPermission = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if showNotificationPermission {
                NotificationPermissionView(
                    hasCompletedOnboarding: $authViewModel.hasCompletedOnboarding,
                    onContinue: {
                        // Save profile and complete onboarding
                        profile.hasCompletedOnboarding = true
                        Task {
                            guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
                            
                            do {
                                // Validate profile is complete
                                guard !profile.interests.isEmpty else {
                                    print("❌ Onboarding incomplete: No interests selected")
                                    return
                                }
                                
                                let encoder = Firestore.Encoder()
                                let userDocRef = FirebaseManager.shared.db
                                    .collection("users")
                                    .document(userId)
                                
                                // Check if document exists, use setData with merge if not
                                let userDoc = try? await userDocRef.getDocument()
                                if userDoc?.exists == true {
                                    // Update existing document
                                    try await userDocRef.updateData([
                                        "profile": try encoder.encode(profile),
                                        "profile.hasCompletedOnboarding": true
                                    ])
                                } else {
                                    // Document doesn't exist, create it with setData
                                    profile.hasCompletedOnboarding = true
                                    let newUserDoc = UserDocument(
                                        userId: userId,
                                        email: FirebaseManager.shared.auth.currentUser?.email ?? "",
                                        profile: profile,
                                        subscriptionTier: .free,
                                        swipesRemainingToday: 10,
                                        lastSwipeResetDate: getUTCDateString(),
                                        createdAt: Date(),
                                        lastLoginAt: Date()
                                    )
                                    try await userDocRef.setData(newUserDoc.toFirestoreData())
                                }
                                
                                // Update onboarding status locally (this will trigger view update)
                                await MainActor.run {
                                    authViewModel.hasCompletedOnboarding = true
                                }
                                
                                AnalyticsHelper.trackOnboardingCompleted(
                                    investmentAmount: profile.investmentAmount.rawValue,
                                    riskLevel: profile.riskLevel.rawValue,
                                    interests: profile.interests.map { $0.rawValue }
                                )
                                
                                print("✅ Onboarding completed successfully")
                            } catch {
                                print("❌ Error saving profile: \(error)")
                                // Show error but don't advance - let user retry
                                // The error will be logged but user stays on onboarding
                                // They can try again by tapping "Get Started" again
                            }
                        }
                    }
                )
                .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    // Progress bar
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Rectangle()
                                .fill(index <= currentStep ? AppColors.text : AppColors.darkGray)
                                .frame(height: 3)
                                .animation(.easeInOut, value: currentStep)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    TabView(selection: $currentStep) {
                        InvestmentAmountView(profile: $profile, currentStep: $currentStep)
                            .tag(0)
                            .onAppear {
                                AnalyticsHelper.trackOnboardingStep(0)
                            }
                        
                        RiskLevelView(profile: $profile, currentStep: $currentStep)
                            .tag(1)
                            .onAppear {
                                AnalyticsHelper.trackOnboardingStep(1)
                            }
                        
                        InterestsView(profile: $profile, currentStep: $currentStep, showNotificationPermission: $showNotificationPermission)
                            .tag(2)
                            .onAppear {
                                AnalyticsHelper.trackOnboardingStep(2)
                            }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onAppear {
                        AnalyticsHelper.trackOnboardingStarted()
                    }
                }
            }
        }
    }
}
