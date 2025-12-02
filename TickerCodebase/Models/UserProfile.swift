import Foundation

struct UserProfile: Codable {
    var investmentAmount: InvestmentAmount
    var riskLevel: RiskLevel
    var interests: [Interest]
    var hasCompletedOnboarding: Bool
    
    enum InvestmentAmount: String, Codable, CaseIterable {
        case small = "$100 - $1,000"
        case medium = "$1,000 - $10,000"
        case large = "$10,000 - $50,000"
        case xlarge = "$50,000+"
        
        var prompt: String {
            switch self {
            case .small: return "small budget under $1000"
            case .medium: return "medium budget $1000-$10000"
            case .large: return "large budget $10000-$50000"
            case .xlarge: return "very large budget over $50000"
            }
        }
    }
    
    enum RiskLevel: String, Codable, CaseIterable {
        case conservative = "Conservative"
        case balanced = "Balanced"
        case aggressive = "Aggressive"
        
        var description: String {
            switch self {
            case .conservative: return "Steady & safe. I want minimal risk."
            case .balanced: return "Mix of safety and growth potential."
            case .aggressive: return "Higher risk for bigger potential gains."
            }
        }
        
        var prompt: String {
            switch self {
            case .conservative: return "conservative risk tolerance, prefers stable investments"
            case .balanced: return "balanced risk tolerance, open to moderate volatility"
            case .aggressive: return "aggressive risk tolerance, willing to take bigger risks"
            }
        }
    }
    
    enum Interest: String, Codable, CaseIterable {
        case tech = "Technology"
        case healthcare = "Healthcare"
        case ecommerce = "E-commerce"
        case finance = "Finance"
        case creative = "Creative/Media"
        
        var icon: String {
            switch self {
            case .tech: return "cpu"
            case .healthcare: return "cross.case"
            case .ecommerce: return "cart"
            case .finance: return "dollarsign.circle"
            case .creative: return "paintbrush"
            }
        }
    }
    
    init(investmentAmount: InvestmentAmount = .small,
         riskLevel: RiskLevel = .balanced,
         interests: [Interest] = [],
         hasCompletedOnboarding: Bool = false) {
        self.investmentAmount = investmentAmount
        self.riskLevel = riskLevel
        self.interests = interests
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
    
    var openAIPrompt: String {
        let interestsList = interests.map { $0.rawValue }.joined(separator: ", ")
        return """
        User profile:
        - Investment budget: \(investmentAmount.prompt)
        - Risk tolerance: \(riskLevel.prompt)
        - Interests: \(interestsList)
        """
    }
}
