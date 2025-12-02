/**
 * Ticker Cloud Functions
 * Main entry point - exports all Firebase Cloud Functions
 *
 * Architecture:
 * - config/       - Configuration and constants
 * - types/        - TypeScript type definitions
 * - services/     - Business logic services (OpenAI, StockPrice, Cache, etc.)
 * - utils/        - Utility functions (date, validation, rotation, etc.)
 * - templates/    - Prompt templates
 * - functions/    - Cloud Function handlers
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export Cloud Functions
export { generateCards } from './functions/generate-cards.function';
export { trackSwipe } from './functions/track-swipe.function';
export { undoSwipe } from './functions/undo-swipe.function';
export { getSwipeStatus } from './functions/get-swipe-status.function';
