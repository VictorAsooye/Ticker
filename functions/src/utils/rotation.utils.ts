/**
 * Rotation strategy utilities
 * Generates daily content variety strategies
 */

import { CONSTANTS } from '../config/constants';

/**
 * Hash string to number
 */
function hashString(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return Math.abs(hash);
}

/**
 * Generate rotation strategy for variety across days
 * Uses day of week + week of year + user hash to create consistent daily themes
 */
export function generateRotationStrategy(userId: string, date: Date): string {
  const dayOfWeek = date.getDay(); // 0-6
  const weekOfYear = Math.floor(date.getTime() / (7 * 24 * 60 * 60 * 1000));
  const userHash = hashString(userId) % 3; // 0-2

  const rotationIndex = (dayOfWeek + weekOfYear + userHash) % CONSTANTS.ROTATION_THEMES.length;

  return CONSTANTS.ROTATION_THEMES[rotationIndex];
}
