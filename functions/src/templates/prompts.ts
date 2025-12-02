/**
 * Prompt Templates
 * AI prompt engineering and template management
 */

import { CardType, UserProfile, InterestMap } from '../types';

// Interest mapping for targeted recommendations
const INTEREST_MAP: InterestMap = {
  'technology': {
    stocks: 'Recommend tech stocks: semiconductors (NVDA, AMD), cloud (MSFT, AMZN), AI/ML companies, cybersecurity (CRWD, PANW), software (CRM, ADBE)',
    ideas: 'Tech business ideas: SaaS tools, mobile apps, automation services, AI-powered solutions, dev tools'
  },
  'healthcare': {
    stocks: 'Healthcare stocks: biotech (MRNA, REGN), medical devices (ABT, MDT), pharma (PFE, JNJ), health tech (TDOC, VEEV)',
    ideas: 'Healthcare ideas: telemedicine platforms, medical billing software, health apps, elder care services, wellness products'
  },
  'finance': {
    stocks: 'Finance stocks: fintech (SQ, PYPL), traditional banks (JPM, BAC), asset managers (BLK, SCHW), insurance (PGR, TRV)',
    ideas: 'Finance ideas: personal finance apps, investment tools, accounting software, payment processing, financial education'
  },
  'ecommerce': {
    stocks: 'E-commerce stocks: marketplaces (AMZN, ETSY), payment (SHOP, PYPL), logistics (UPS, FDX), retail (WMT, TGT)',
    ideas: 'E-commerce ideas: niche online stores, subscription boxes, dropshipping, marketplace platforms, DTC brands'
  },
  'creative': {
    stocks: 'Creative/Media stocks: streaming (NFLX, DIS), gaming (RBLX, EA), design tools (ADBE), social media (META)',
    ideas: 'Creative ideas: content creation tools, design services, online courses, creator platforms, digital products'
  }
};

/**
 * Generate specific guidance based on user interests
 */
function generateInterestGuidance(interests: string[], type: CardType): string {
  const guidance: string[] = [];

  interests.forEach(interest => {
    const mappedInterest = INTEREST_MAP[interest.toLowerCase()];
    if (mappedInterest) {
      guidance.push(type === 'stock' ? mappedInterest.stocks : mappedInterest.ideas);
    }
  });

  return guidance.length > 0
    ? guidance.join('\n')
    : 'Generate diverse recommendations that could appeal to a beginner investor';
}

// Example templates
const STOCK_EXAMPLE = `[
  {
    "type": "stock",
    "title": "NVIDIA",
    "ticker": "NVDA",
    "price": "$875.32",
    "change": "+2.4%",
    "tagline": "Chips fueling AI innovation",
    "simpleExplainer": "NVIDIA powers AI technology used in self-driving cars and more.",
    "whatToExpect": "Stock can be volatile due to AI developments.",
    "goodReasons": [
      "Leading AI chip manufacturer",
      "Strong demand from tech companies"
    ],
    "concerns": [
      "Market dependency on AI trends",
      "High competition risk"
    ],
    "timeline": "3-5 years",
    "riskLevel": "Medium-High",
    "beginnerTip": "Invest in NVIDIA for potential growth in the AI industry.",
    "sources": [
      {"name": "Yahoo Finance", "url": "https://finance.yahoo.com/quote/NVDA"},
      {"name": "Seeking Alpha", "url": "https://seekingalpha.com/symbol/NVDA"}
    ],
    "getStarted": [
      {"name": "Robinhood", "description": "Easy app to buy stocks", "url": "https://robinhood.com"},
      {"name": "Fidelity", "description": "Full-service broker", "url": "https://fidelity.com"}
    ]
  }
]`;

const IDEA_EXAMPLE = `[
  {
    "type": "idea",
    "title": "Telemedicine Platform for Seniors",
    "category": "Healthcare Technology",
    "investment": "$20K - $50K",
    "tagline": "Connect seniors with doctors online for convenient care",
    "simpleExplainer": "Seniors struggle to visit doctors. You could create an app for virtual consultations.",
    "whatToExpect": "It may take 6-12 months to gain user trust and traction.",
    "goodReasons": [
      "Growing telemedicine market",
      "Seniors value convenience and safety"
    ],
    "concerns": [
      "Ensuring user-friendly interface for seniors",
      "Compliance with telemedicine regulations"
    ],
    "timeline": "12-18 months to break even",
    "riskLevel": "Medium",
    "beginnerTip": "Research user needs thoroughly before building the platform.",
    "sources": [
      {"name": "American Telemedicine Association", "url": "https://www.americantelemed.org"},
      {"name": "Forbes", "url": "https://www.forbes.com/telemedicine"}
    ],
    "getStarted": [
      {"name": "Doxy.me", "description": "Free telemedicine platform", "url": "https://doxy.me"},
      {"name": "Canva", "description": "Create marketing materials", "url": "https://canva.com"}
    ]
  }
]`;

/**
 * Build AI prompt for card generation
 */
export function buildPrompt(
  profile: UserProfile,
  type: CardType,
  count: number,
  excludeList: string[] = [],
  rotationStrategy: string = ''
): string {
  const typeString = type === 'stock' ? 'stocks' : 'business ideas';
  const interestsList = profile.interests.join(', ');

  // Generate interest-specific guidance
  const interestGuidance = generateInterestGuidance(profile.interests, type);

  // Build exclusion instruction
  let excludeInstruction = '';
  if (excludeList.length > 0) {
    excludeInstruction = type === 'stock'
      ? `\n\nDO NOT RECOMMEND THESE STOCKS (user has seen them): ${excludeList.join(', ')}`
      : `\n\nDO NOT RECOMMEND IDEAS WITH THESE TITLES: ${excludeList.join(', ')}`;
  }

  // Build rotation instruction
  const rotationInstruction = rotationStrategy
    ? `\n\nTODAY'S FOCUS: ${rotationStrategy}`
    : '';

  return `Generate ${count} DIVERSE and UNIQUE personalized ${typeString} recommendations for a beginner investor.

USER PROFILE:
- Investment budget: ${profile.investmentAmount}
- Risk tolerance: ${profile.riskLevel}
- Interests: ${interestsList}${excludeInstruction}${rotationInstruction}

RELEVANCE STRATEGY:
${interestGuidance}

DIVERSITY REQUIREMENTS:
${type === 'stock' ? `
- Include a MIX of company sizes: 2-3 large cap, 2-3 mid cap, 2-3 small cap
- Include DIFFERENT sectors: tech, healthcare, finance, consumer, energy, etc.
- Include DIFFERENT investment themes: growth, value, dividend, innovation
- DO NOT just recommend the most popular tech stocks (NVDA, AAPL, MSFT, GOOGL, META)
- Include some lesser-known but solid companies
- Match recommendations to user's specific interests: ${interestsList}
` : `
- Include a MIX of business types: SaaS, e-commerce, services, products, marketplaces
- Include DIFFERENT industries related to user interests
- Include DIFFERENT investment levels across the range
- DO NOT just recommend "AI startup" or "app idea" - be SPECIFIC
- Each idea should be DISTINCTLY different from others
`}

ACCURACY REQUIREMENTS:
${type === 'stock' ? `
- Use REAL ticker symbols that are currently traded on NYSE/NASDAQ
- Verify companies are active and publicly traded
- Price estimates should be realistic based on current market (2024-2025)
- If you're unsure about a stock, choose a different one
` : `
- Investment ranges must be realistic for the business type
- Timeline must be achievable (12-24 months typical)
- Consider actual market demand and competition
`}

STRICT REQUIREMENTS:
1. Every recommendation MUST clearly relate to user's interests
2. Explain the connection to their interests in the tagline or explainer
3. Be SPECIFIC - avoid generic recommendations
4. Ensure DIVERSITY - different sectors, sizes, and themes
5. Use REAL data - valid tickers, realistic prices, working URLs

Content quality:
- Taglines: Under 10 words, compelling but not hype
- Plain English: Truly simple, no jargon
- What to Expect: Honest and realistic
- Good Reasons: Specific (not generic like "growing market")
- Concerns: Legitimate risks (not just "it might fail")
- Beginner Tips: Actually explain investing concepts

URLs MUST BE REAL:
- Sources: Use real financial news sites (Yahoo Finance, Seeking Alpha, MarketWatch, Motley Fool)
- Get Started: Use real platforms (Robinhood, Fidelity, E*TRADE, Shopify, Stripe, Canva, Bubble.io)
- Format: https://full-url.com (NO # placeholders, NO fake URLs)

Return ONLY a valid JSON array. Each item must follow this exact structure:

${type === 'stock' ? STOCK_EXAMPLE : IDEA_EXAMPLE}

Return ONLY the JSON array with NO markdown formatting.`;
}
