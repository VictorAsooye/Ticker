/**
 * OpenAI Service
 * Handles AI-powered card generation using GPT-3.5 Turbo
 */

import OpenAI from 'openai';
import { Card, CardType, UserProfile } from '../types';
import { CONSTANTS } from '../config/constants';
import { validateCard, fixInvalidUrls } from '../utils/validation.utils';
import { StockPriceService } from './stock-price.service';
import * as functions from 'firebase-functions';

export class OpenAIService {
  private client: OpenAI;
  private stockPriceService: StockPriceService;

  constructor(apiKey: string, stockPriceService: StockPriceService) {
    this.client = new OpenAI({ apiKey });
    this.stockPriceService = stockPriceService;
  }

  /**
   * Generate cards using OpenAI
   */
  async generateCards(
    profile: UserProfile,
    type: CardType,
    count: number,
    excludeList: string[],
    rotationStrategy: string,
    promptBuilder: (profile: UserProfile, type: CardType, count: number, excludeList: string[], rotationStrategy: string) => string
  ): Promise<Card[]> {
    const prompt = promptBuilder(profile, type, count, excludeList, rotationStrategy);

    try {
      console.log(`🤖 Calling OpenAI API...`);

      const completion = await this.client.chat.completions.create({
        model: CONSTANTS.OPENAI.MODEL,
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
        max_tokens: CONSTANTS.OPENAI.MAX_TOKENS,
        temperature: CONSTANTS.OPENAI.TEMPERATURE,
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

      // If stocks, fetch real prices
      if (type === 'stock') {
        cards = await this.enrichWithRealPrices(cards);
      }

      // Validate cards
      const validCards = this.validateCards(cards, type);

      if (validCards.length === 0) {
        throw new functions.https.HttpsError(
          'internal',
          'No valid cards generated. Please try again.'
        );
      }

      // Fix invalid URLs
      fixInvalidUrls(validCards);

      console.log(`✅ Generated ${validCards.length} valid ${type} cards`);

      return validCards;
    } catch (error: any) {
      console.error('❌ OpenAI API error:', error);
      throw new functions.https.HttpsError('internal', 'Failed to generate cards', error.message);
    }
  }

  /**
   * Enrich stock cards with real-time prices
   */
  private async enrichWithRealPrices(cards: any[]): Promise<any[]> {
    console.log(`💰 Fetching real-time prices for ${cards.length} stocks...`);

    const tickers = cards.map((card: any) => card.ticker).filter(Boolean);
    const priceMap = await this.stockPriceService.fetchStockPrices(tickers);

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

    return cards;
  }

  /**
   * Validate generated cards
   */
  private validateCards(cards: any[], type: CardType): Card[] {
    const validCards: Card[] = [];

    cards.forEach((card: any, index: number) => {
      const validation = validateCard(card, type);

      if (validation.valid) {
        validCards.push(card);

        if (validation.warnings.length > 0) {
          console.warn(`⚠️ Card ${index} warnings:`, validation.warnings);
        }
      } else {
        console.error(`❌ Card ${index} invalid:`, validation.errors);
      }
    });

    console.log(`✅ Valid cards: ${validCards.length}/${cards.length}`);

    return validCards;
  }
}
