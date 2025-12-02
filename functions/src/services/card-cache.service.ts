/**
 * Card Cache Service
 * Manages 24-hour caching of generated cards
 */

import * as admin from 'firebase-admin';
import { CardType, Card, UserProfile, CardCache } from '../types';
import { CONSTANTS } from '../config/constants';

export class CardCacheService {
  private db: FirebaseFirestore.Firestore;

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Get cached cards if available and not expired
   */
  async getCachedCards(userId: string, type: CardType): Promise<Card[] | null> {
    const cacheRef = this.db.collection('card_cache').doc(`${userId}_${type}`);
    const cacheDoc = await cacheRef.get();

    if (!cacheDoc.exists) {
      return null;
    }

    const cache = cacheDoc.data() as CardCache;
    const generatedAt = cache?.generatedAt?.toDate();

    if (!generatedAt) {
      return null;
    }

    const cacheAge = Date.now() - generatedAt.getTime();

    if (cacheAge < CONSTANTS.CACHE.TTL_MS) {
      console.log(`✅ Returning cached ${type} cards (age: ${Math.round(cacheAge / 1000 / 60)} minutes)`);
      return (type === 'stock' ? cache?.stocks : cache?.ideas) || null;
    }

    console.log(`🔄 Cache expired (age: ${Math.round(cacheAge / 1000 / 60 / 60)} hours)`);
    return null;
  }

  /**
   * Store generated cards in cache
   */
  async setCachedCards(
    userId: string,
    type: CardType,
    cards: Card[],
    profile: UserProfile
  ): Promise<void> {
    const cacheRef = this.db.collection('card_cache').doc(`${userId}_${type}`);
    const now = admin.firestore.Timestamp.now();

    const cacheData = {
      userId,
      profile,
      generatedAt: now,
      [type === 'stock' ? 'stocks' : 'ideas']: cards,
    };

    await cacheRef.set(cacheData, { merge: true });
    console.log(`💾 Cached ${type} cards`);
  }
}
