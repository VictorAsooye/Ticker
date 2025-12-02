import SwiftUI

struct SavedInterestsView: View {
    @State private var savedInvestments: [Investment] = []
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Interests")
                        .font(.custom(AppFonts.serifTitle, size: 32))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.text)
                    
                    Spacer()
                    
                    if !savedInvestments.isEmpty {
                        Button(action: {
                            exportAllInvestments()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.text)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                if savedInvestments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("No saved interests yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.text)
                        
                        Text("Swipe right on stocks or ideas to save them here")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(savedInvestments) { investment in
                                SavedInvestmentRow(investment: investment) {
                                    removeInvestment(investment.id)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            loadSavedInvestments()
        }
    }
    
    private func loadSavedInvestments() {
        savedInvestments = StorageManager.shared.loadSavedInvestments()
    }
    
    private func removeInvestment(_ id: UUID) {
        StorageManager.shared.removeSavedInvestment(id)
        loadSavedInvestments()
    }
    
    private func exportAllInvestments() {
        let text = savedInvestments.map { investment in
            if investment.type == .stock {
                return "[\(investment.ticker ?? "")] \(investment.title) - \(investment.tagline)"
            } else {
                return "[\(investment.category ?? "")] \(investment.title) - \(investment.tagline)"
            }
        }.joined(separator: "\n\n")
        
        let fullText = """
        My Ticker Interests
        
        \(text)
        
        Get personalized investment recommendations: [App Store Link]
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [fullText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        
        FirebaseManager.shared.logEvent("investments_exported", parameters: [
            "count": savedInvestments.count
        ])
    }
}

struct SavedInvestmentRow: View {
    let investment: Investment
    let onDelete: () -> Void
    @State private var showingCard = false
    @State private var showShareSheet = false
    
    var body: some View {
        Button(action: {
            showingCard = true
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    if investment.type == .stock {
                        Text(investment.ticker ?? "")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.text)
                        Text(investment.title)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Text(investment.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.text)
                        Text(investment.category ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.text)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.red)
                    }
                }
            }
            .padding(16)
            .background(AppColors.darkGray)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .cornerRadius(8)
        }
        .contextMenu {
            Button(action: {
                showingCard = true
            }) {
                Label("View Details", systemImage: "eye")
            }
            
            Button(action: {
                showShareSheet = true
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingCard) {
            InvestmentCard(investment: investment)
                .background(AppColors.background)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [createShareText()])
        }
    }
    
    private func createShareText() -> String {
        if investment.type == .stock {
            return """
            Check out \(investment.ticker ?? "") on Ticker! 📈
            
            \(investment.tagline)
            
            Get personalized stock recommendations: [App Store Link]
            """
        } else {
            return """
            Interesting business idea: \(investment.title)
            
            \(investment.tagline)
            
            Discover more investment ideas on Ticker: [App Store Link]
            """
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

