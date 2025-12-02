import Foundation
import RevenueCat
import FirebaseFirestore

class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var offerings: Offerings?
    @Published var isPro = false
    @Published var isLoading = false
    @Published var error: String?
    
    private var isConfigured = false
    
    private init() {}
    
    func configure() {
        // Only configure once
        guard !isConfigured else { return }
        
        // Check if API key is set (not placeholder)
        let apiKey = "YOUR_REVENUECAT_PUBLIC_KEY"
        guard apiKey != "YOUR_REVENUECAT_PUBLIC_KEY" else {
            #if DEBUG
            print("⚠️ RevenueCat API key not configured. Subscriptions will not work.")
            print("   Get your key from: https://app.revenuecat.com/ -> Your Project -> API Keys")
            print("   Then update PurchaseManager.swift line 24")
            #endif
            isConfigured = true // Mark as configured to prevent repeated warnings
            return
        }
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        isConfigured = true
    }
    
    func setUserId(_ userId: String) {
        // Only set user ID if RevenueCat is configured
        guard Purchases.isConfigured else {
            #if DEBUG
            print("⚠️ RevenueCat not configured. Skipping setUserId.")
            #endif
            return
        }
        
        Purchases.shared.logIn(userId) { customerInfo, created, error in
            if let error = error {
                #if DEBUG
                print("RevenueCat login error: \(error)")
                #endif
                return
            }
            
            self.checkSubscriptionStatus()
        }
    }
    
    func loadOfferings() async {
        guard Purchases.isConfigured else {
            #if DEBUG
            print("⚠️ RevenueCat not configured. Cannot load offerings.")
            #endif
            isLoading = false
            return
        }
        
        isLoading = true
        
        do {
            self.offerings = try await Purchases.shared.offerings()
            FirebaseManager.shared.logEvent("offerings_loaded")
        } catch {
            self.error = error.localizedDescription
            FirebaseManager.shared.logEvent("offerings_load_failed", parameters: [
                "error": error.localizedDescription
            ])
        }
        
        isLoading = false
    }
    
    func purchase() async throws {
        // CRITICAL FIX: Check if already subscribed before attempting purchase
        isLoading = true
        
        do {
            // Check current subscription status
            let customerInfo = try await Purchases.shared.customerInfo()
            
            if customerInfo.entitlements["pro"]?.isActive == true {
                #if DEBUG
                print("✅ User already has active subscription")
                #endif
                self.isPro = true
                await updateSubscriptionInFirestore(isPro: true)
                isLoading = false
                
                FirebaseManager.shared.logEvent("subscription_already_active")
                return
            }
            
            // Not subscribed, proceed with purchase
            guard Purchases.isConfigured else {
                throw PurchaseError.noProductsAvailable
            }
            
            guard let offering = offerings?.current,
                  let package = offering.availablePackages.first else {
                throw PurchaseError.noProductsAvailable
            }
            
            #if DEBUG
            print("💳 Starting purchase: \(package.storeProduct.productIdentifier)")
            #endif
            
            let result = try await Purchases.shared.purchase(package: package)
            
            if !result.userCancelled {
                // Update Firestore with new subscription status
                await updateSubscriptionInFirestore(isPro: true)
                self.isPro = true
                
                AnalyticsHelper.trackSubscriptionPurchased(price: package.storeProduct.price.description)
                
                #if DEBUG
                print("✅ Purchase successful")
                #endif
            } else {
                #if DEBUG
                print("ℹ️ Purchase cancelled by user")
                #endif
                FirebaseManager.shared.logEvent("subscription_purchase_cancelled")
            }
        } catch {
            self.error = error.localizedDescription
            #if DEBUG
            print("❌ Purchase error: \(error)")
            #endif
            AnalyticsHelper.trackError("purchase_failed", context: "purchase")
            throw error
        }
        
        isLoading = false
    }
    
    func restorePurchases() async throws {
        guard Purchases.isConfigured else {
            throw PurchaseError.noProductsAvailable
        }
        
        isLoading = true
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let hasPro = customerInfo.entitlements["pro"]?.isActive == true
            
            await updateSubscriptionInFirestore(isPro: hasPro)
            self.isPro = hasPro
            
            FirebaseManager.shared.logEvent("purchases_restored", parameters: [
                "has_pro": hasPro
            ])
        } catch {
            self.error = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func checkSubscriptionStatus() {
        guard Purchases.isConfigured else {
            #if DEBUG
            print("⚠️ RevenueCat not configured. Cannot check subscription status.")
            #endif
                return
        }
        
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                #if DEBUG
                print("Error checking subscription: \(error)")
                #endif
                return
            }
            
            let hasPro = customerInfo?.entitlements["pro"]?.isActive == true
            
            DispatchQueue.main.async {
                self.isPro = hasPro
            }
            
            // Sync with Firestore
            Task {
                await self.updateSubscriptionInFirestore(isPro: hasPro)
            }
        }
    }
    
    private func updateSubscriptionInFirestore(isPro: Bool) async {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let tier: UserDocument.SubscriptionTier = isPro ? .pro : .free
        let maxSwipes = isPro ? 50 : 10
        
        do {
            // CRITICAL: Update subscription tier AND immediately give full swipes
            try await FirebaseManager.shared.db
                .collection("users")
                .document(userId)
                .updateData([
                    "subscriptionTier": tier.rawValue,
                    "swipesRemainingToday": maxSwipes // Immediately give full swipes
                ])
            
            print("✅ Subscription updated in Firestore: tier=\(tier.rawValue), swipes=\(maxSwipes)")
            
            // Log to analytics for monitoring
            FirebaseManager.shared.logEvent("subscription_synced", parameters: [
                "tier": tier.rawValue,
                "swipes": maxSwipes
            ])
        } catch {
            print("❌ Error updating subscription in Firestore: \(error)")
            // Log to analytics for monitoring
            FirebaseManager.shared.logEvent("subscription_sync_failed", parameters: [
                "error": error.localizedDescription,
                "tier": tier.rawValue
            ])
        }
    }
}

enum PurchaseError: LocalizedError {
    case noProductsAvailable
    case purchaseFailed
    case restoreFailed
    
    var errorDescription: String? {
        switch self {
        case .noProductsAvailable:
            return "Unable to load subscription options. Please try again."
        case .purchaseFailed:
            return "Payment could not be processed. Please check your payment method."
        case .restoreFailed:
            return "No previous purchases found"
        }
    }
}



