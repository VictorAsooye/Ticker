/**
 * Get Swipe Status Cloud Function
 * Returns user's current swipe status
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GetSwipeStatusRequest, SwipeStatusResponse } from '../types';
import { needsDailyReset } from '../utils/date.utils';
import { getMaxSwipes } from '../utils/subscription.utils';

/**
 * Get user's current swipe status (for client to check)
 */
export const getSwipeStatus = functions.https.onCall(
  async (data: GetSwipeStatusRequest, context: functions.https.CallableContext): Promise<SwipeStatusResponse> => {
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
  }
);
