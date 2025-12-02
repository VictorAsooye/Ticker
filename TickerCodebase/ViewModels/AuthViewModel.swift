import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import Combine
import SwiftUI
import AuthenticationServices
import CryptoKit
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var hasCompletedOnboarding = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = FirebaseManager.shared.auth
    private let db = FirebaseManager.shared.db
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let user = auth.currentUser {
            self.currentUser = user
            self.isAuthenticated = true
            PurchaseManager.shared.setUserId(user.uid)
            
            // Ensure user document exists
            Task {
                await ensureUserDocumentExists(userId: user.uid, email: user.email ?? "")
            }
            
            loadUserProfile()
        }
    }
    
    private func ensureUserDocumentExists(userId: String, email: String) async {
        let userDocRef = db.collection("users").document(userId)
        let userDoc = try? await userDocRef.getDocument()
        
        if userDoc?.exists == false {
            // Create new user document if it doesn't exist
            let newUserDoc = UserDocument(
                userId: userId,
                email: email,
                profile: UserProfile(),
                subscriptionTier: .free,
                swipesRemainingToday: 10,
                lastSwipeResetDate: getUTCDateString(),
                createdAt: Date(),
                lastLoginAt: Date()
            )
            
            do {
                try await userDocRef.setData(newUserDoc.toFirestoreData())
            } catch {
                #if DEBUG
                print("Error creating user document: \(error)")
                #endif
            }
        }
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Create user document in Firestore
            let userDoc = UserDocument(
                userId: result.user.uid,
                email: email,
                profile: UserProfile(),
                subscriptionTier: .free,
                swipesRemainingToday: 10,
                lastSwipeResetDate: getUTCDateString(),
                createdAt: Date(),
                lastLoginAt: Date()
            )
            
                try await db.collection("users").document(result.user.uid).setData(userDoc.toFirestoreData())
            
            self.currentUser = result.user
            self.isAuthenticated = true
            PurchaseManager.shared.setUserId(result.user.uid)
            
            FirebaseManager.shared.logEvent("sign_up", parameters: ["method": "email"])
        } catch {
            // Convert Firebase errors to user-friendly messages
            let errorCode = (error as NSError).code
            let errorMessageText = (error as NSError).localizedDescription
            
            if errorCode == 17007 {
                errorMessage = "An account with this email already exists"
            } else if errorCode == 17008 {
                errorMessage = "Please enter a valid email address"
            } else if errorCode == 17026 {
                errorMessage = "Password must be at least 6 characters"
            } else if errorMessageText.contains("network") || errorMessageText.contains("connection") {
                errorMessage = "No internet connection. Please check your connection and try again."
            } else {
                errorMessage = errorMessageText
            }
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            
            // Check if user document exists
            let userDocRef = db.collection("users").document(result.user.uid)
            let userDoc = try? await userDocRef.getDocument()
            
            if userDoc?.exists == false {
                // Create new user document if it doesn't exist
                let newUserDoc = UserDocument(
                    userId: result.user.uid,
                    email: email,
                    profile: UserProfile(),
                    subscriptionTier: .free,
                    swipesRemainingToday: 10,
                    lastSwipeResetDate: getUTCDateString(),
                    createdAt: Date(),
                    lastLoginAt: Date()
                )
                
                try await userDocRef.setData(newUserDoc.toFirestoreData())
            } else {
                // Update last login
                try await userDocRef.updateData([
                    "lastLoginAt": FieldValue.serverTimestamp()
                ])
            }
            
            self.currentUser = result.user
            self.isAuthenticated = true
            PurchaseManager.shared.setUserId(result.user.uid)
            loadUserProfile()
            
            FirebaseManager.shared.logEvent("login", parameters: ["method": "email"])
        } catch {
            // Convert Firebase errors to user-friendly messages
            let errorCode = (error as NSError).code
            let errorMessageText = (error as NSError).localizedDescription
            
            if errorCode == 17011 {
                errorMessage = "No account found with this email"
            } else if errorCode == 17009 {
                errorMessage = "Email or password is incorrect"
            } else if errorCode == 17008 {
                errorMessage = "Please enter a valid email address"
            } else if errorMessageText.contains("network") || errorMessageText.contains("connection") {
                errorMessage = "No internet connection. Please check your connection and try again."
            } else {
                errorMessage = errorMessageText
            }
        }
        
        isLoading = false
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        errorMessage = nil
        
        // Apple Sign In temporarily disabled due to Firebase API compatibility issue
        // The Firebase OAuthProvider API signature doesn't match what's expected
        // Users can use Email/Password or Google Sign In instead
        errorMessage = "Apple Sign In is temporarily unavailable. Please use Email/Password or Google Sign In."
        isLoading = false
        
        // TODO: Fix Apple Sign In once Firebase API compatibility is resolved
        // The implementation is ready but needs the correct Firebase API method
    }
    
    // Generate random nonce for Apple Sign In
    private var currentNonce: String?
    
    func startSignInWithApple() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                errorMessage = "Google Sign In configuration error"
                isLoading = false
                return
            }
            
            // Configure Google Sign In
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // Get the presenting view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                errorMessage = "Unable to get root view controller"
                isLoading = false
                return
            }
            
            // Sign in with Google
            // This will present the Google Sign In UI
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Unable to get Google ID token"
                isLoading = false
                return
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            
            // Sign in with Firebase
            let authResult = try await auth.signIn(with: credential)
            
            // Get user info
            let email = authResult.user.email ?? ""
            let displayName = authResult.user.displayName ?? ""
            
            // Check if user document exists
            let userDocRef = db.collection("users").document(authResult.user.uid)
            let userDoc = try? await userDocRef.getDocument()
            
            if userDoc?.exists == false {
                // Create new user document
                let newUserDoc = UserDocument(
                    userId: authResult.user.uid,
                    email: email,
                    profile: UserProfile(),
                    subscriptionTier: .free,
                    swipesRemainingToday: 10,
                    lastSwipeResetDate: getUTCDateString(),
                    createdAt: Date(),
                    lastLoginAt: Date()
                )
                
                try await userDocRef.setData(newUserDoc.toFirestoreData())
                
                FirebaseManager.shared.logEvent("sign_up", parameters: ["method": "google"])
            } else {
                // Update last login
                try await userDocRef.updateData([
                    "lastLoginAt": FieldValue.serverTimestamp()
                ])
                
                FirebaseManager.shared.logEvent("login", parameters: ["method": "google"])
            }
            
            self.currentUser = authResult.user
            self.isAuthenticated = true
            PurchaseManager.shared.setUserId(authResult.user.uid)
            loadUserProfile()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            self.hasCompletedOnboarding = false
            FirebaseManager.shared.logEvent("logout")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        guard let user = currentUser else { return }
        
        isLoading = true
        
        do {
            // Delete user data from Firestore
            try await db.collection("users").document(user.uid).delete()
            
            // Delete auth account
            try await user.delete()
            
            self.currentUser = nil
            self.isAuthenticated = false
            
            FirebaseManager.shared.logEvent("account_deleted")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func loadUserProfile() {
        guard let userId = currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard var data = snapshot?.data() else {
                return
            }
            
            // Convert Firestore Timestamp to Date for decoding
            if let createdAtTimestamp = data["createdAt"] as? Timestamp {
                data["createdAt"] = createdAtTimestamp.dateValue()
            }
            if let lastLoginAtTimestamp = data["lastLoginAt"] as? Timestamp {
                data["lastLoginAt"] = lastLoginAtTimestamp.dateValue()
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
                  let userDoc = try? JSONDecoder().decode(UserDocument.self, from: jsonData) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.hasCompletedOnboarding = userDoc.profile.hasCompletedOnboarding
            }
        }
    }
    
    func updateOnboardingStatus(_ completed: Bool) async {
        guard let userId = currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(userId).updateData([
                "profile.hasCompletedOnboarding": completed
            ])
            self.hasCompletedOnboarding = completed
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


