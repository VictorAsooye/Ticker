/**
 * Centralized type definitions for the Ticker application
 */

// ============================================================================
// USER & PROFILE TYPES
// ============================================================================

export interface UserProfile {
  investmentAmount: string;
  riskLevel: string;
  interests: string[];
}

export interface UserData {
  email?: string;
  subscriptionTier: 'free' | 'pro';
  swipesRemainingToday: number;
  lastSwipeResetDate: string | null;
  profile?: UserProfile;
}

// ============================================================================
// CARD TYPES
// ============================================================================

export type CardType = 'stock' | 'idea';

export interface BaseCard {
  type: CardType;
  title: string;
  tagline: string;
  simpleExplainer: string;
  whatToExpect?: string;
  goodReasons: string[];
  concerns: string[];
  timeline: string;
  riskLevel: string;
  beginnerTip: string;
  sources: CardSource[];
  getStarted: CardTool[];
}

export interface StockCard extends BaseCard {
  type: 'stock';
  ticker: string;
  price: string;
  change: string;
}

export interface IdeaCard extends BaseCard {
  type: 'idea';
  category: string;
  investment: string;
}

export type Card = StockCard | IdeaCard;

export interface CardSource {
  name: string;
  url: string;
}

export interface CardTool {
  name: string;
  description: string;
  url: string;
}

// ============================================================================
// STOCK PRICE TYPES
// ============================================================================

export interface StockQuote {
  symbol: string;
  price: string;
  change: string;
  changePercent: string;
}

// ============================================================================
// VALIDATION TYPES
// ============================================================================

export interface ValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

// ============================================================================
// API REQUEST TYPES
// ============================================================================

export interface GenerateCardsRequest {
  userId: string;
  profile: UserProfile;
  type: CardType;
  count: number;
}

export interface TrackSwipeRequest {
  userId: string;
  investmentId: string;
  direction: 'left' | 'right';
}

export interface UndoSwipeRequest {
  userId: string;
  investmentId: string;
  direction: 'left' | 'right';
}

export interface GetSwipeStatusRequest {
  userId: string;
}

// ============================================================================
// API RESPONSE TYPES
// ============================================================================

export interface GenerateCardsResponse {
  cards: Card[];
  cached: boolean;
}

export interface SwipeResponse {
  swipesRemaining: number;
  maxSwipes: number;
  tier: string;
}

export interface SwipeStatusResponse extends SwipeResponse {
  needsReset: boolean;
}

// ============================================================================
// CACHE TYPES
// ============================================================================

export interface CardCache {
  userId: string;
  profile: UserProfile;
  generatedAt: FirebaseFirestore.Timestamp;
  stocks?: StockCard[];
  ideas?: IdeaCard[];
}

// ============================================================================
// SEEN CARDS TYPES
// ============================================================================

export interface SeenCard {
  userId: string;
  cardIdentifier: string;
  type: CardType;
  shownAt: FirebaseFirestore.Timestamp;
}

// ============================================================================
// INTEREST MAPPING TYPES
// ============================================================================

export interface InterestMapping {
  stocks: string;
  ideas: string;
}

export type InterestMap = Record<string, InterestMapping>;
