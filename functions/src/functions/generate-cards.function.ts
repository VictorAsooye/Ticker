/**
 * Generate Cards Cloud Function
 * Main AI content generation endpoint
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GenerateCardsRequest, GenerateCardsResponse } from '../types';
import { OpenAIService } from '../services/openai.service';
import { StockPriceService } from '../services/stock-price.service';
import { CardCacheService } from '../services/card-cache.service';
import { SeenCardsService } from '../services/seen-cards.service';
import { generateRotationStrategy } from '../utils/rotation.utils';
import { getMaxSwipes } from '../utils/subscription.utils';
import { buildPrompt } from '../templates/prompts';
import { getEnvironmentConfig } from '../config/environment';

export const generateCards = functions.https.onCall(
  async (data: GenerateCardsRequest, context: functions.https.CallableContext): Promise<GenerateCardsResponse> => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { userId, profile, type, count } = data;

    console.log(`📊 Generating ${count} ${type} cards for user ${userId}`);

    // Initialize services
    const config = getEnvironmentConfig();
    const stockPriceService = new StockPriceService(config.alphaVantage.apiKey);
    const openaiService = new OpenAIService(config.openai.apiKey, stockPriceService);
    const cacheService = new CardCacheService();
    const seenCardsService = new SeenCardsService();

    // Check cache first
    const cachedCards = await cacheService.getCachedCards(userId, type);
    if (cachedCards) {
      return {
        cards: cachedCards,
        cached: true,
      };
    }

    // Get previously seen cards
    const seenIdentifiers = await seenCardsService.getSeenCards(userId, type);

    // Generate rotation strategy for variety
    const rotationStrategy = generateRotationStrategy(userId, new Date());
    console.log(`🔄 Today's rotation: ${rotationStrategy}`);

    // Check user's swipe limit
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const userData = userDoc.data();

    if (!userData) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const tier = userData.subscriptionTier || 'free';
    const maxSwipes = getMaxSwipes(tier);

    console.log(`👤 User tier: ${tier}, max swipes: ${maxSwipes}`);

    // Generate cards using OpenAI
    const cards = await openaiService.generateCards(
      profile,
      type,
      count,
      seenIdentifiers,
      rotationStrategy,
      buildPrompt
    );

    // Store seen cards
    await seenCardsService.storeSeenCards(userId, cards, type);

    // Cache the results
    await cacheService.setCachedCards(userId, type, cards, profile);

    return {
      cards,
      cached: false,
    };
  }
);
