/**
 * Track Swipe Cloud Function
 * Manages swipe tracking and daily limits
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { TrackSwipeRequest, SwipeResponse } from '../types';
import { needsDailyReset, getUTCDateString } from '../utils/date.utils';
import { getMaxSwipes } from '../utils/subscription.utils';

/**
 * Track a swipe and manage daily limits
 * THIS IS THE ONLY PLACE WHERE DAILY RESET HAPPENS
 */
export const trackSwipe = functions.https.onCall(
  async (data: TrackSwipeRequest, context: functions.https.CallableContext): Promise<SwipeResponse> => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { userId, investmentId, direction } = data;

    console.log(`👆 Tracking swipe: user=${userId}, direction=${direction}`);

    const userRef = admin.firestore().collection('users').doc(userId);

    // Use transaction to ensure atomic read-modify-write
    return await admin.firestore().runTransaction(async (transaction: FirebaseFirestore.Transaction) => {
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
  }
);
