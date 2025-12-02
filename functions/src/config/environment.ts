/**
 * Environment configuration
 * Modern approach using defineSecret (replaces deprecated functions.config())
 */

import { defineSecret } from 'firebase-functions/params';

// Define secrets (these will be set via Firebase CLI)
export const OPENAI_API_KEY = defineSecret('OPENAI_API_KEY');
export const ALPHA_VANTAGE_API_KEY = defineSecret('ALPHA_VANTAGE_API_KEY');

/**
 * Get environment configuration with fallbacks
 */
export function getEnvironmentConfig() {
  return {
    openai: {
      apiKey: OPENAI_API_KEY.value(),
    },
    alphaVantage: {
      apiKey: ALPHA_VANTAGE_API_KEY.value() || 'demo',
    },
  };
}
