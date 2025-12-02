/**
 * Application-wide constants
 * Centralized configuration values
 */

export const CONSTANTS = {
  // Swipe limits
  SWIPE_LIMITS: {
    FREE_TIER: 10,
    PRO_TIER: 50,
  },

  // Cache settings
  CACHE: {
    TTL_HOURS: 24,
    TTL_MS: 24 * 60 * 60 * 1000,
  },

  // Seen cards tracking
  SEEN_CARDS: {
    MAX_HISTORY: 50,
  },

  // OpenAI settings
  OPENAI: {
    MODEL: 'gpt-3.5-turbo',
    MAX_TOKENS: 4000,
    TEMPERATURE: 0.7,
  },

  // Alpha Vantage settings
  ALPHA_VANTAGE: {
    REQUEST_DELAY_MS: 500,
    TIMEOUT_MS: 5000,
  },

  // Content validation
  VALIDATION: {
    MAX_TAGLINE_LENGTH: 100,
    MIN_EXPLAINER_LENGTH: 50,
    TICKER_REGEX: /^[A-Z]{1,5}$/,
  },

  // Rotation themes
  ROTATION_THEMES: [
    'Focus on: Large cap tech stocks and SaaS ideas',
    'Focus on: Healthcare stocks and medical service ideas',
    'Focus on: Financial stocks and fintech ideas',
    'Focus on: Consumer goods stocks and e-commerce ideas',
    'Focus on: Emerging growth stocks and innovative ideas',
    'Focus on: Dividend stocks and stable business ideas',
    'Focus on: International stocks and global business ideas',
  ],

  // Subscription tiers
  TIERS: {
    FREE: 'free' as const,
    PRO: 'pro' as const,
  },
} as const;
