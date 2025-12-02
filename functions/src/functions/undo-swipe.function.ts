/**
 * Undo Swipe Cloud Function
 * Allows users to undo their last swipe
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { UndoSwipeRequest, SwipeResponse } from '../types';
import { getMaxSwipes } from '../utils/subscription.utils';

/**
 * Undo a swipe (atomic operation)
 */
export const undoSwipe = functions.https.onCall(
  async (data: UndoSwipeRequest, context: functions.https.CallableContext): Promise<SwipeResponse> => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { userId, investmentId, direction } = data;

    console.log(`↩️ Undoing swipe: user=${userId}, direction=${direction}`);

    const userRef = admin.firestore().collection('users').doc(userId);

    // Use transaction for atomic operation
    return await admin.firestore().runTransaction(async (transaction: FirebaseFirestore.Transaction) => {
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data()!;
      const currentSwipes = userData.swipesRemainingToday || 0;
      const tier = userData.subscriptionTier || 'free';
      const maxSwipes = getMaxSwipes(tier);

      // Increment, but don't exceed max
      const newSwipes = Math.min(currentSwipes + 1, maxSwipes);

      transaction.update(userRef, {
        swipesRemainingToday: newSwipes,
      });

      // If it was a right swipe, remove from saved investments
      if (direction === 'right') {
        const savedRef = userRef.collection('saved_investments').doc(investmentId);

        // Check if it exists before deleting
        const savedDoc = await transaction.get(savedRef);
        if (savedDoc.exists) {
          transaction.delete(savedRef);
          console.log(`🗑️ Removed investment ${investmentId} from saved`);
        } else {
          console.log(`⚠️ Investment ${investmentId} not in saved (already deleted?)`);
        }
      }

      console.log(`✅ Undo complete. Swipes: ${currentSwipes} → ${newSwipes}`);

      return {
        swipesRemaining: newSwipes,
        maxSwipes,
        tier,
      };
    });
  }
);
