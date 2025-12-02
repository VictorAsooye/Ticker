import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import OpenAI from 'openai';
import axios from 'axios';

admin.initializeApp();

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get date string in YYYY-MM-DD format (UTC-based for consistency)
 * This ensures all users reset at the same absolute time regardless of timezone
 */
function getUTCDateString(date: Date): string {
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const day = String(date.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Check if daily reset is needed for a user
 */
function needsDailyReset(lastResetDate: string | null): boolean {
  if (!lastResetDate) return true;
  
  const todayStr = getUTCDateString(new Date());
  return todayStr !== lastResetDate;
}

/**
 * Get max swipes for a subscription tier
 */
function getMaxSwipes(tier: string): number {
  return tier === 'pro' ? 50 : 10;
}

// ============================================================================
// CONTENT QUALITY INTERFACES
// ============================================================================

interface StockQuote {
  symbol: string;
  price: string;
  change: string;
  changePercent: string;
}

interface ValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

// ============================================================================
// SEEN CARDS TRACKING
// ============================================================================

/**
 * Get previously seen cards for a user
 */
async function getSeenCards(userId: string, type: 'stock' | 'idea'): Promise<string[]> {
  try {
    const seenCardsSnapshot = await admin.firestore()
      .collection('seen_cards')
      .where('userId', '==', userId)
      .where('type', '==', type)
      .orderBy('shownAt', 'desc')
      .limit(50) // Last 50 seen cards
      .get();
    
    const seenIdentifiers = seenCardsSnapshot.docs.map(doc => doc.data().cardIdentifier);
    console.log(`📋 User has seen ${seenIdentifiers.length} ${type} cards before`);
    return seenIdentifiers;
  } catch (error) {
    console.error('❌ Error fetching seen cards:', error);
    return []; // Return empty array on error
  }
}

/**
 * Store seen cards in Firestore
 */
async function storeSeenCards(userId: string, cards: any[], type: 'stock' | 'idea'): Promise<void> {
  try {
    const batch = admin.firestore().batch();
    
    cards.forEach((card: any) => {
      const identifier = type === 'stock' ? card.ticker : card.title;
      if (!identifier) return;
      
      const seenCardRef = admin.firestore().collection('seen_cards').doc();
      batch.set(seenCardRef, {
        userId,
        cardIdentifier: identifier,
        type,
        shownAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    
    await batch.commit();
    console.log(`✅ Stored ${cards.length} seen cards`);
  } catch (error) {
    console.error('❌ Error storing seen cards:', error);
    // Don't throw - this is non-critical
  }
}

// ============================================================================
// REAL STOCK PRICES (Alpha Vantage)
// ============================================================================

/**
 * Fetch real-time stock price from Alpha Vantage
 * Free tier: 25 API calls per day, 5 calls per minute
 */
async function fetchStockPrice(ticker: string): Promise<StockQuote | null> {
  try {
    const apiKey = functions.config().alphavantage?.key || 'demo';
    if (apiKey === 'demo') {
      console.warn(`⚠️ Alpha Vantage API key not configured. Using estimates for ${ticker}`);
      return null;
    }
    
    const url = `https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${ticker}&apikey=${apiKey}`;
    
    const response = await axios.get(url, { timeout: 5000 });
    const quote = response.data['Global Quote'];
    
    if (!quote || !quote['05. price']) {
      console.warn(`⚠️ No price data for ${ticker}`);
      return null;
    }
    
    const price = parseFloat(quote['05. price']);
    const change = parseFloat(quote['09. change']);
    const changePercent = parseFloat(quote['10. change percent'].replace('%', ''));
    
    return {
      symbol: ticker,
      price: `$${price.toFixed(2)}`,
      change: change >= 0 ? `+${Math.abs(change).toFixed(2)}` : `-${Math.abs(change).toFixed(2)}`,
      changePercent: change >= 0 ? `+${Math.abs(changePercent).toFixed(1)}%` : `-${Math.abs(changePercent).toFixed(1)}%`,
    };
  } catch (error: any) {
    console.error(`❌ Error fetching price for ${ticker}:`, error.message);
    return null;
  }
}

/**
 * Fetch multiple stock prices in parallel (with rate limiting)
 */
async function fetchStockPrices(tickers: string[]): Promise<Map<string, StockQuote>> {
  const priceMap = new Map<string, StockQuote>();
  
  // Batch requests with delay to respect rate limits (5 calls per minute on free tier)
  for (const ticker of tickers) {
    const quote = await fetchStockPrice(ticker);
    if (quote) {
      priceMap.set(ticker, quote);
    }
    
    // Delay 500ms between requests to respect rate limits
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  return priceMap;
}

// ============================================================================
// ROTATION STRATEGY
// ============================================================================

/**
 * Hash string to number
 */
function hashString(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return Math.abs(hash);
}

/**
 * Generate rotation strategy for variety across days
 */
function generateRotationStrategy(userId: string, date: Date): string {
  const dayOfWeek = date.getDay(); // 0-6
  const weekOfYear = Math.floor(date.getTime() / (7 * 24 * 60 * 60 * 1000));
  const userHash = hashString(userId) % 3; // 0-2
  
  const rotationIndex = (dayOfWeek + weekOfYear + userHash) % 7;
  
  const rotations = [
    'Focus on: Large cap tech stocks and SaaS ideas',
    'Focus on: Healthcare stocks and medical service ideas',
    'Focus on: Financial stocks and fintech ideas',
    'Focus on: Consumer goods stocks and e-commerce ideas',
    'Focus on: Emerging growth stocks and innovative ideas',
    'Focus on: Dividend stocks and stable business ideas',
    'Focus on: International stocks and global business ideas',
  ];
  
  return rotations[rotationIndex];
}

// ============================================================================
// INTEREST GUIDANCE
// ============================================================================

/**
 * Generate specific guidance based on user interests
 */
function generateInterestGuidance(interests: string[], type: 'stock' | 'idea'): string {
  const interestMap: { [key: string]: any } = {
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
  
  const guidance: string[] = [];
  
  interests.forEach(interest => {
    const mappedInterest = interestMap[interest.toLowerCase()];
    if (mappedInterest) {
      guidance.push(type === 'stock' ? mappedInterest.stocks : mappedInterest.ideas);
    }
  });
  
  return guidance.length > 0 
    ? guidance.join('\n') 
    : 'Generate diverse recommendations that could appeal to a beginner investor';
}

// ============================================================================
// CONTENT VALIDATION
// ============================================================================

/**
 * Validate generated card quality
 */
function validateCard(card: any, type: 'stock' | 'idea'): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];
  
  // Required fields
  if (!card.title) errors.push('Missing title');
  if (!card.tagline) errors.push('Missing tagline');
  if (!card.simpleExplainer) errors.push('Missing simpleExplainer');
  if (!card.goodReasons || card.goodReasons.length === 0) errors.push('Missing goodReasons');
  if (!card.concerns || card.concerns.length === 0) errors.push('Missing concerns');
  
  // Stock-specific validation
  if (type === 'stock') {
    if (!card.ticker) errors.push('Missing ticker');
    if (!card.price) warnings.push('Missing price');
    
    // Validate ticker format (1-5 uppercase letters)
    if (card.ticker && !/^[A-Z]{1,5}$/.test(card.ticker)) {
      errors.push(`Invalid ticker format: ${card.ticker}`);
    }
  }
  
  // Idea-specific validation
  if (type === 'idea') {
    if (!card.investment) warnings.push('Missing investment range');
    if (!card.category) warnings.push('Missing category');
  }
  
  // Content quality checks
  if (card.tagline && card.tagline.length > 100) {
    warnings.push('Tagline too long (>100 chars)');
  }
  
  if (card.simpleExplainer && card.simpleExplainer.length < 50) {
    warnings.push('Explainer too short (<50 chars)');
  }
  
  // URL validation
  if (card.sources) {
    card.sources.forEach((source: any, idx: number) => {
      if (!source.url || source.url === '#' || !source.url.startsWith('http')) {
        errors.push(`Invalid source URL at index ${idx}`);
      }
    });
  }
  
  if (card.getStarted) {
    card.getStarted.forEach((tool: any, idx: number) => {
      if (!tool.url || tool.url === '#' || !tool.url.startsWith('http')) {
        errors.push(`Invalid getStarted URL at index ${idx}`);
      }
    });
  }
  
  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

// ============================================================================
// CLOUD FUNCTIONS
// ============================================================================

interface GenerateCardsRequest {
  userId: string;
  profile: {
    investmentAmount: string;
    riskLevel: string;
    interests: string[];
  };
  type: 'stock' | 'idea';
  count: number;
}

export const generateCards = functions.https.onCall(async (data: GenerateCardsRequest, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, profile, type, count } = data;

  console.log(`📊 Generating ${count} ${type} cards for user ${userId}`);

  // NEW: Get previously seen cards
  const seenIdentifiers = await getSeenCards(userId, type);

  // NEW: Generate rotation strategy for variety
  const rotationStrategy = generateRotationStrategy(userId, new Date());
  console.log(`🔄 Today's rotation: ${rotationStrategy}`);

  // Check cache first
  const cacheRef = admin.firestore().collection('card_cache').doc(`${userId}_${type}`);
  const cacheDoc = await cacheRef.get();

  if (cacheDoc.exists) {
    const cache = cacheDoc.data();
    const generatedAt = cache?.generatedAt?.toDate();

    if (generatedAt) {
      const cacheAge = Date.now() - generatedAt.getTime();
      const TWENTY_FOUR_HOURS = 24 * 60 * 60 * 1000;

      // Use cache age instead of expiration date
      if (cacheAge < TWENTY_FOUR_HOURS) {
        console.log(`✅ Returning cached ${type} cards (age: ${Math.round(cacheAge / 1000 / 60)} minutes)`);
        return {
          cards: type === 'stock' ? cache?.stocks : cache?.ideas,
          cached: true,
        };
      } else {
        console.log(`🔄 Cache expired (age: ${Math.round(cacheAge / 1000 / 60 / 60)} hours)`);
      }
    }
  }

  // Check user's swipe limit (don't reset here, just check)
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const userData = userDoc.data();

  if (!userData) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const tier = userData.subscriptionTier || 'free';
  const maxSwipes = getMaxSwipes(tier);

  console.log(`👤 User tier: ${tier}, max swipes: ${maxSwipes}`);

  // Generate prompt with seen cards exclusion and rotation strategy
  const prompt = buildPrompt(profile, type, count, seenIdentifiers, rotationStrategy);

  try {
    console.log(`🤖 Calling OpenAI API...`);
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are a financial education assistant that generates personalized, beginner-friendly investment recommendations in JSON format.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
      max_tokens: 4000,
      temperature: 0.7,
    });

    const content = completion.choices[0]?.message?.content || '';
    
    // Clean JSON response
    let cleanJSON = content.trim();
    
    // Remove markdown code blocks
    if (cleanJSON.startsWith('```json')) {
      cleanJSON = cleanJSON.replace(/```json\n?/g, '').replace(/```\n?/g, '');
    } else if (cleanJSON.startsWith('```')) {
      cleanJSON = cleanJSON.replace(/```\n?/g, '');
    }
    
    cleanJSON = cleanJSON.trim();

    let cards = JSON.parse(cleanJSON);

    if (!Array.isArray(cards) || cards.length === 0) {
      throw new Error('Invalid response: expected array of cards');
    }

    // NEW: If stocks, fetch real prices
    if (type === 'stock') {
      console.log(`💰 Fetching real-time prices for ${cards.length} stocks...`);
      
      const tickers = cards.map((card: any) => card.ticker).filter(Boolean);
      const priceMap = await fetchStockPrices(tickers);
      
      // Enrich cards with real prices
      cards.forEach((card: any) => {
        const realPrice = priceMap.get(card.ticker);
        if (realPrice) {
          card.price = realPrice.price;
          card.change = realPrice.changePercent;
          console.log(`✅ ${card.ticker}: ${realPrice.price} (${realPrice.changePercent})`);
        } else {
          // Keep AI estimate but log warning
          console.warn(`⚠️ Using estimate for ${card.ticker}`);
        }
      });
    }

    // NEW: Comprehensive validation
    const validCards: any[] = [];
    const invalidCards: any[] = [];
    
    cards.forEach((card: any, index: number) => {
      const validation = validateCard(card, type);
      
      if (validation.valid) {
        validCards.push(card);
        
        if (validation.warnings.length > 0) {
          console.warn(`⚠️ Card ${index} warnings:`, validation.warnings);
        }
      } else {
        console.error(`❌ Card ${index} invalid:`, validation.errors);
        invalidCards.push({ card, errors: validation.errors });
      }
    });
    
    console.log(`✅ Valid cards: ${validCards.length}/${cards.length}`);
    
    if (validCards.length === 0) {
      throw new functions.https.HttpsError(
        'internal',
        'No valid cards generated. Please try again.',
      );
    }
    
    // Use only valid cards
    cards = validCards;
    
    // Fix invalid URLs (fallback for any that slipped through)
    cards.forEach((card: any, index: number) => {
      if (card.sources && Array.isArray(card.sources)) {
        card.sources.forEach((source: any) => {
          if (source.url === '#' || !source.url || !source.url.startsWith('http')) {
            console.warn(`⚠️ Fixing invalid source URL in card ${index}:`, source);
            source.url = 'https://www.google.com/search?q=' + encodeURIComponent(card.title || card.ticker || 'investment');
          }
        });
      }
      
      if (card.getStarted && Array.isArray(card.getStarted)) {
        card.getStarted.forEach((tool: any) => {
          if (tool.url === '#' || !tool.url || !tool.url.startsWith('http')) {
            console.warn(`⚠️ Fixing invalid getStarted URL in card ${index}:`, tool);
            tool.url = 'https://www.google.com/search?q=' + encodeURIComponent(tool.name || 'investment platform');
          }
        });
      }
    });
    
    // NEW: Store seen cards
    await storeSeenCards(userId, cards, type);

    console.log(`✅ Generated ${cards.length} ${type} cards`);

    // Cache the results - CRITICAL: Exactly 24 hours from now
    const now = admin.firestore.Timestamp.now();
    const cacheData = {
      userId,
      profile,
      generatedAt: now,
      [type === 'stock' ? 'stocks' : 'ideas']: cards,
    };

    await cacheRef.set(cacheData, { merge: true });
    console.log(`💾 Cached ${type} cards`);

    return {
      cards,
      cached: false,
    };
  } catch (error: any) {
    console.error('❌ OpenAI API error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate cards', error.message);
  }
});

/**
 * Track a swipe and manage daily limits
 * THIS IS THE ONLY PLACE WHERE DAILY RESET HAPPENS
 */
export const trackSwipe = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, investmentId, direction } = data;

  console.log(`👆 Tracking swipe: user=${userId}, direction=${direction}`);

  const userRef = admin.firestore().collection('users').doc(userId);

  // Use transaction to ensure atomic read-modify-write
  return await admin.firestore().runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const tier = userData.subscriptionTier || 'free';
    const maxSwipes = getMaxSwipes(tier);
    const lastResetDate = userData.lastSwipeResetDate || null;

    let swipesRemaining = userData.swipesRemainingToday || 0;

    // Check if daily reset is needed
    if (needsDailyReset(lastResetDate)) {
      console.log(`🔄 Daily reset triggered for user ${userId}`);
      swipesRemaining = maxSwipes;
      
      transaction.update(userRef, {
        swipesRemainingToday: maxSwipes,
        lastSwipeResetDate: getUTCDateString(new Date()),
      });
    }

    // Check if user has swipes remaining AFTER potential reset
    if (swipesRemaining <= 0) {
      console.log(`⛔ User ${userId} hit daily limit (tier: ${tier})`);
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Daily swipe limit reached',
        { tier, maxSwipes }
      );
    }

    // Decrement swipes
    const newSwipesRemaining = swipesRemaining - 1;
    
    transaction.update(userRef, {
      swipesRemainingToday: newSwipesRemaining,
    });

    // Log the swipe in history
    const swipeHistoryRef = userRef.collection('swipe_history').doc();
    transaction.set(swipeHistoryRef, {
      investmentId,
      direction,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Swipe tracked. Remaining: ${newSwipesRemaining}/${maxSwipes}`);

    return { 
      swipesRemaining: newSwipesRemaining,
      maxSwipes,
      tier,
    };
  });
});

/**
 * Undo a swipe (atomic operation)
 */
export const undoSwipe = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, investmentId, direction } = data;

  console.log(`↩️ Undoing swipe: user=${userId}, direction=${direction}`);

  const userRef = admin.firestore().collection('users').doc(userId);

  // Use transaction for atomic operation
  return await admin.firestore().runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const currentSwipes = userData.swipesRemainingToday || 0;
    const tier = userData.subscriptionTier || 'free';
    const maxSwipes = getMaxSwipes(tier);
    
    // Increment, but don't exceed max
    const newSwipes = Math.min(currentSwipes + 1, maxSwipes);
    
    transaction.update(userRef, {
      swipesRemainingToday: newSwipes,
    });
    
    // If it was a right swipe, remove from saved investments
    if (direction === 'right') {
      const savedRef = userRef.collection('saved_investments').doc(investmentId);
      
      // Check if it exists before deleting
      const savedDoc = await transaction.get(savedRef);
      if (savedDoc.exists) {
        transaction.delete(savedRef);
        console.log(`🗑️ Removed investment ${investmentId} from saved`);
      } else {
        console.log(`⚠️ Investment ${investmentId} not in saved (already deleted?)`);
      }
    }
    
    console.log(`✅ Undo complete. Swipes: ${currentSwipes} → ${newSwipes}`);
    
    return { 
      swipesRemaining: newSwipes,
      maxSwipes,
      tier,
    };
  });
});

/**
 * Get user's current swipe status (for client to check)
 */
export const getSwipeStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId } = data;
  
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const userData = userDoc.data()!;
  const tier = userData.subscriptionTier || 'free';
  const maxSwipes = getMaxSwipes(tier);
  const lastResetDate = userData.lastSwipeResetDate || null;

  let swipesRemaining = userData.swipesRemainingToday || 0;

  // Check if reset is needed (read-only check, don't modify)
  if (needsDailyReset(lastResetDate)) {
    swipesRemaining = maxSwipes;
  }

  return {
    swipesRemaining,
    maxSwipes,
    tier,
    needsReset: needsDailyReset(lastResetDate),
  };
});

// ============================================================================
// PROMPT BUILDER
// ============================================================================

function buildPrompt(
  profile: any, 
  type: string, 
  count: number, 
  excludeList: string[] = [],
  rotationStrategy: string = ''
): string {
  const typeString = type === 'stock' ? 'stocks' : 'business ideas';
  const interestsList = profile.interests.join(', ');
  
  // Generate interest-specific guidance
  const interestGuidance = generateInterestGuidance(profile.interests, type as 'stock' | 'idea');
  
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

  const stockExample = `[
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

  const ideaExample = `[
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

${type === 'stock' ? stockExample : ideaExample}

Return ONLY the JSON array with NO markdown formatting.`;
}
