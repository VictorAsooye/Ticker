import Foundation
import OpenAI

class OpenAIService {
    static let shared = OpenAIService()
    
    private var client: OpenAI
    
    private init() {
        self.client = OpenAI(apiToken: AppConstants.openAIKey)
    }
    
    func generateInvestments(for profile: UserProfile, type: InvestmentType, count: Int = 5) async throws -> [Investment] {
        let prompt = buildPrompt(for: profile, type: type, count: count)
        
        // Create messages using correct TextContent & Content helpers
        let systemMessage = ChatQuery.ChatCompletionMessageParam.system(
            .init(content: .textContent("You are a financial education assistant that generates personalized, beginner-friendly investment recommendations in JSON format."))
        )
        let userMessage = ChatQuery.ChatCompletionMessageParam.user(
            .init(content: .string(prompt))
        )
        
        let query = ChatQuery(
            messages: [systemMessage, userMessage],
            model: .gpt4
        )
        
        let result = try await client.chats(query: query)
        
        guard let firstChoice = result.choices.first,
              let content = firstChoice.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        return try parseInvestments(from: content, type: type)
    }
    
    private func buildPrompt(for profile: UserProfile, type: InvestmentType, count: Int) -> String {
        let typeString = type == .stock ? "stocks" : "business ideas"
        
        return """
        Generate \(count) personalized \(typeString) recommendations for a beginner investor with this profile:
        
        \(profile.openAIPrompt)
        
        Return ONLY a valid JSON array with no additional text. Each item must follow this exact structure:
        
        \(type == .stock ? stockJSONExample : ideaJSONExample)
        
        Requirements:
        - Write in simple, beginner-friendly language
        - Keep "goodReasons" and "concerns" to 3-4 items each
        - Make taglines catchy and under 15 words
        - Include real, clickable URLs for sources and getStarted resources
        - For stocks: use real current prices and ticker symbols
        - For ideas: provide realistic investment ranges
        - All text should educate and inform, not hype
        
        Return ONLY the JSON array, nothing else.
        """
    }
    
    private var stockJSONExample: String {
        """
        [
          {
            "type": "stock",
            "title": "NVIDIA",
            "ticker": "NVDA",
            "price": "$875.32",
            "change": "+2.4%",
            "tagline": "The company making chips that power AI",
            "simpleExplainer": "NVIDIA makes the computer chips that run ChatGPT, self-driving cars, and most AI technology.",
            "whatToExpect": "The stock price can swing up or down quickly based on AI news. You're betting that AI keeps growing.",
            "goodReasons": [
              "They make most of the AI chips in the world",
              "Big tech companies like Microsoft buy from them",
              "AI is still in early stages"
            ],
            "concerns": [
              "The stock is expensive right now",
              "Other companies are trying to compete",
              "If AI hype slows down, stock could drop"
            ],
            "timeline": "3-5 years",
            "riskLevel": "Medium-High",
            "beginnerTip": "This is a growth stock - you buy hoping the company gets bigger, not for steady income.",
            "sources": [
              {"name": "Yahoo Finance", "url": "https://finance.yahoo.com/quote/NVDA"},
              {"name": "Seeking Alpha", "url": "https://seekingalpha.com/symbol/NVDA"}
            ],
            "getStarted": [
              {"name": "Robinhood", "description": "Easy app to buy stocks", "url": "https://robinhood.com"},
              {"name": "Fidelity", "description": "Full-service broker", "url": "https://fidelity.com"}
            ]
          }
        ]
        """
    }
    
    private var ideaJSONExample: String {
        """
        [
          {
            "type": "idea",
            "title": "AI Tools for Doctor Offices",
            "category": "Software Business",
            "investment": "$50K - $150K",
            "tagline": "Build automation software that saves doctors time",
            "simpleExplainer": "Doctors spend hours on paperwork. You could build AI tools that automatically write up patient notes.",
            "whatToExpect": "Takes 12-18 months to get your first paying customers. Sales are slow because doctors are busy.",
            "goodReasons": [
              "Healthcare is always growing",
              "Once customers pay, they keep paying monthly",
              "Good profit margins once you have customers"
            ],
            "concerns": [
              "Strict rules about patient privacy (HIPAA)",
              "Doctors take 3-6 months to decide to buy",
              "You need to know how to code or hire developers"
            ],
            "timeline": "18-24 months to make profit",
            "riskLevel": "Medium",
            "beginnerTip": "This is called SaaS - customers pay you monthly. It takes time to start but can be very profitable.",
            "sources": [
              {"name": "CB Insights", "url": "https://cbinsights.com/healthcare-ai"},
              {"name": "Grand View Research", "url": "https://grandviewresearch.com"}
            ],
            "getStarted": [
              {"name": "Bubble.io", "description": "Build apps without coding", "url": "https://bubble.io"},
              {"name": "Stripe", "description": "Accept monthly payments", "url": "https://stripe.com"},
              {"name": "Canva", "description": "Design marketing materials", "url": "https://canva.com"}
            ]
          }
        ]
        """
    }
    
    private func parseInvestments(from json: String, type: InvestmentType) throws -> [Investment] {
        // Clean up potential markdown code blocks
        let cleanJSON = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanJSON.data(using: .utf8) else {
            throw OpenAIError.invalidJSON
        }
        
        let decoder = JSONDecoder()
        let investments = try decoder.decode([Investment].self, from: data)
        return investments
    }
}

enum OpenAIError: LocalizedError {
    case invalidResponse
    case invalidJSON
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Could not get response from AI"
        case .invalidJSON: return "Could not parse AI response"
        case .apiError(let message): return message
        }
    }
}
