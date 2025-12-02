/**
 * Date utility functions
 * Handles UTC-based date operations for consistent timezone handling
 */

/**
 * Get date string in YYYY-MM-DD format (UTC-based for consistency)
 * This ensures all users reset at the same absolute time regardless of timezone
 */
export function getUTCDateString(date: Date): string {
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const day = String(date.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Check if daily reset is needed for a user
 */
export function needsDailyReset(lastResetDate: string | null): boolean {
  if (!lastResetDate) return true;

  const todayStr = getUTCDateString(new Date());
  return todayStr !== lastResetDate;
}
