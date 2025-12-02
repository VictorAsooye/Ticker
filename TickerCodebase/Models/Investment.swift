import Foundation

enum InvestmentType: String, Codable {
    case stock
    case idea
}

struct Investment: Identifiable, Codable, Equatable {
    let id: UUID
    let type: InvestmentType
    
    // Common fields
    let title: String // For ideas, or company name for stocks
    let ticker: String? // Only for stocks
    let tagline: String
    let simpleExplainer: String
    let whatToExpect: String
    let goodReasons: [String]
    let concerns: [String]
    let timeline: String
    let riskLevel: String
    let beginnerTip: String
    let sources: [Source]
    let getStarted: [Resource]
    
    // Stock-specific
    let price: String?
    let change: String?
    
    // Idea-specific
    let category: String?
    let investment: String?
    
    init(id: UUID = UUID(), type: InvestmentType, title: String, ticker: String? = nil,
         tagline: String, simpleExplainer: String, whatToExpect: String,
         goodReasons: [String], concerns: [String], timeline: String,
         riskLevel: String, beginnerTip: String, sources: [Source],
         getStarted: [Resource], price: String? = nil, change: String? = nil,
         category: String? = nil, investment: String? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.ticker = ticker
        self.tagline = tagline
        self.simpleExplainer = simpleExplainer
        self.whatToExpect = whatToExpect
        self.goodReasons = goodReasons
        self.concerns = concerns
        self.timeline = timeline
        self.riskLevel = riskLevel
        self.beginnerTip = beginnerTip
        self.sources = sources
        self.getStarted = getStarted
        self.price = price
        self.change = change
        self.category = category
        self.investment = investment
    }
    
    // Equatable conformance - compare by id
    static func == (lhs: Investment, rhs: Investment) -> Bool {
        lhs.id == rhs.id
    }
    
    // Custom decoder to handle missing id field from OpenAI
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Generate UUID if id is missing
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        
        self.type = try container.decode(InvestmentType.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        self.ticker = try container.decodeIfPresent(String.self, forKey: .ticker)
        self.tagline = try container.decode(String.self, forKey: .tagline)
        self.simpleExplainer = try container.decode(String.self, forKey: .simpleExplainer)
        self.whatToExpect = try container.decode(String.self, forKey: .whatToExpect)
        self.goodReasons = try container.decode([String].self, forKey: .goodReasons)
        self.concerns = try container.decode([String].self, forKey: .concerns)
        self.timeline = try container.decode(String.self, forKey: .timeline)
        self.riskLevel = try container.decode(String.self, forKey: .riskLevel)
        self.beginnerTip = try container.decode(String.self, forKey: .beginnerTip)
        self.sources = try container.decode([Source].self, forKey: .sources)
        self.getStarted = try container.decode([Resource].self, forKey: .getStarted)
        self.price = try container.decodeIfPresent(String.self, forKey: .price)
        self.change = try container.decodeIfPresent(String.self, forKey: .change)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.investment = try container.decodeIfPresent(String.self, forKey: .investment)
    }
}

struct Source: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let url: String
    
    init(id: UUID = UUID(), name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
    
    // Custom decoder to handle missing id field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
    }
}

struct Resource: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let url: String
    
    init(id: UUID = UUID(), name: String, description: String, url: String) {
        self.id = id
        self.name = name
        self.description = description
        self.url = url
    }
    
    // Custom decoder to handle missing id field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.url = try container.decode(String.self, forKey: .url)
    }
}
