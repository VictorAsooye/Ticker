import SwiftUI
// Google and Apple Sign In temporarily disabled
// import AuthenticationServices
// import CryptoKit

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Title Section
                    VStack(spacing: 16) {
                        Text("Ticker")
                            .font(.custom(AppFonts.serifTitle, size: 48))
                            .foregroundColor(AppColors.text)
                        
                        Text(isSignUp ? "Create your account" : "Welcome back")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 60)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.text)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(AuthTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.text)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppConstants.cardCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }
                        
                        // Confirm Password (Sign Up only)
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.text)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textFieldStyle(AuthTextFieldStyle())
                            }
                        }
                        
                        // Error Message
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.red)
                                .padding(.horizontal)
                        }
                        
                        // Submit Button
                        Button(action: handleSubmit) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                                    .stroke(AppColors.text, lineWidth: 1)
                            )
                            .cornerRadius(AppConstants.cardCornerRadius)
                        }
                        .disabled(authViewModel.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        
                        // Google and Apple Sign In temporarily disabled
                        // Divider - commented out since social sign in is disabled
                        /*
                        HStack {
                            Rectangle()
                                .fill(AppColors.border)
                                .frame(height: 1)
                            Text("or")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 16)
                            Rectangle()
                                .fill(AppColors.border)
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // Google Sign In
                        Button(action: {
                            Task {
                                await authViewModel.signInWithGoogle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 18))
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.26, green: 0.52, blue: 0.96))
                            .cornerRadius(AppConstants.cardCornerRadius)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                let nonce = authViewModel.startSignInWithApple()
                                request.requestedScopes = [.fullName, .email]
                                request.nonce = sha256(nonce)
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result: result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(AppConstants.cardCornerRadius)
                        */
                    }
                    .padding(.horizontal, 24)
                    
                    // Toggle Sign Up/Sign In
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Button(action: { 
                            isSignUp.toggle()
                            authViewModel.errorMessage = nil
                            password = ""
                            confirmPassword = ""
                        }) {
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.text)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        email.contains("@") &&
        password.count >= 6 &&
        (isSignUp ? password == confirmPassword : true)
    }
    
    private func handleSubmit() {
        Task {
            if isSignUp {
                await authViewModel.signUp(email: email, password: password)
            } else {
                await authViewModel.signIn(email: email, password: password)
            }
        }
    }
    
    // Apple Sign In temporarily disabled
    /*
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    await authViewModel.signInWithApple(credential: appleIDCredential)
                }
            }
        case .failure(let error):
            authViewModel.errorMessage = error.localizedDescription
        }
    }
    
    // Helper function to hash nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    */
}

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .foregroundColor(AppColors.text)
    }
}

