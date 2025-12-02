import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Help & Support")
                        .font(.custom(AppFonts.serifTitle, size: 32))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.text)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequently Asked Questions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.text)
                            .padding(.horizontal, 24)
                        
                        FAQRow(question: "How do I save an investment?", answer: "Swipe right on any card or tap the 'INTERESTED' button to save it to your interests.")
                        FAQRow(question: "What are daily swipe limits?", answer: "Free users get 10 swipes per day. Pro users get 50 swipes per day.")
                        FAQRow(question: "How do I upgrade to Pro?", answer: "Tap the paywall when you run out of swipes, or go to Settings to manage your subscription.")
                    }
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Support")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.text)
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                        
                        Button(action: {
                            if let url = URL(string: "mailto:support@ticker.app") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Email Support")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.text)
                            .padding(16)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.text)
            
            Text(answer)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
        .padding(.horizontal, 24)
    }
}

