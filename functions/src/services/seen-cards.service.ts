/**
 * Seen Cards Service
 * Manages tracking of previously shown cards to prevent duplicates
 */

import * as admin from 'firebase-admin';
import { CardType, Card } from '../types';
import { CONSTANTS } from '../config/constants';

export class SeenCardsService {
  private db: FirebaseFirestore.Firestore;

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Get previously seen cards for a user
   */
  async getSeenCards(userId: string, type: CardType): Promise<string[]> {
    try {
      const seenCardsSnapshot = await this.db
        .collection('seen_cards')
        .where('userId', '==', userId)
        .where('type', '==', type)
        .orderBy('shownAt', 'desc')
        .limit(CONSTANTS.SEEN_CARDS.MAX_HISTORY)
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
  async storeSeenCards(userId: string, cards: Card[], type: CardType): Promise<void> {
    try {
      const batch = this.db.batch();

      cards.forEach((card: any) => {
        const identifier = type === 'stock' ? card.ticker : card.title;
        if (!identifier) return;

        const seenCardRef = this.db.collection('seen_cards').doc();
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
}
