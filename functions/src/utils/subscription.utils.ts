/**
 * Subscription tier utilities
 * Manages subscription-related logic
 */

import { CONSTANTS } from '../config/constants';

/**
 * Get max swipes for a subscription tier
 */
export function getMaxSwipes(tier: string): number {
  return tier === CONSTANTS.TIERS.PRO
    ? CONSTANTS.SWIPE_LIMITS.PRO_TIER
    : CONSTANTS.SWIPE_LIMITS.FREE_TIER;
}
