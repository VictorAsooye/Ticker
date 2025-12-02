/**
 * Content validation utilities
 * Validates card quality and data integrity
 */

import { Card, CardType, ValidationResult } from '../types';
import { CONSTANTS } from '../config/constants';

/**
 * Validate generated card quality
 */
export function validateCard(card: any, type: CardType): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  // Required fields
  if (!card.title) errors.push('Missing title');
  if (!card.tagline) errors.push('Missing tagline');
  if (!card.simpleExplainer) errors.push('Missing simpleExplainer');
  if (!card.goodReasons || card.goodReasons.length === 0) errors.push('Missing goodReasons');
  if (!card.concerns || card.concerns.length === 0) errors.push('Missing concerns');

  // Stock-specific validation
  if (type === 'stock') {
    if (!card.ticker) errors.push('Missing ticker');
    if (!card.price) warnings.push('Missing price');

    // Validate ticker format (1-5 uppercase letters)
    if (card.ticker && !CONSTANTS.VALIDATION.TICKER_REGEX.test(card.ticker)) {
      errors.push(`Invalid ticker format: ${card.ticker}`);
    }
  }

  // Idea-specific validation
  if (type === 'idea') {
    if (!card.investment) warnings.push('Missing investment range');
    if (!card.category) warnings.push('Missing category');
  }

  // Content quality checks
  if (card.tagline && card.tagline.length > CONSTANTS.VALIDATION.MAX_TAGLINE_LENGTH) {
    warnings.push(`Tagline too long (>${CONSTANTS.VALIDATION.MAX_TAGLINE_LENGTH} chars)`);
  }

  if (card.simpleExplainer && card.simpleExplainer.length < CONSTANTS.VALIDATION.MIN_EXPLAINER_LENGTH) {
    warnings.push(`Explainer too short (<${CONSTANTS.VALIDATION.MIN_EXPLAINER_LENGTH} chars)`);
  }

  // URL validation
  if (card.sources) {
    card.sources.forEach((source: any, idx: number) => {
      if (!source.url || source.url === '#' || !source.url.startsWith('http')) {
        errors.push(`Invalid source URL at index ${idx}`);
      }
    });
  }

  if (card.getStarted) {
    card.getStarted.forEach((tool: any, idx: number) => {
      if (!tool.url || tool.url === '#' || !tool.url.startsWith('http')) {
        errors.push(`Invalid getStarted URL at index ${idx}`);
      }
    });
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

/**
 * Fix invalid URLs in cards
 */
export function fixInvalidUrls(cards: Card[]): void {
  cards.forEach((card: any, index: number) => {
    if (card.sources && Array.isArray(card.sources)) {
      card.sources.forEach((source: any) => {
        if (source.url === '#' || !source.url || !source.url.startsWith('http')) {
          console.warn(`⚠️ Fixing invalid source URL in card ${index}:`, source);
          source.url = 'https://www.google.com/search?q=' +
            encodeURIComponent(card.title || card.ticker || 'investment');
        }
      });
    }

    if (card.getStarted && Array.isArray(card.getStarted)) {
      card.getStarted.forEach((tool: any) => {
        if (tool.url === '#' || !tool.url || !tool.url.startsWith('http')) {
          console.warn(`⚠️ Fixing invalid getStarted URL in card ${index}:`, tool);
          tool.url = 'https://www.google.com/search?q=' +
            encodeURIComponent(tool.name || 'investment platform');
        }
      });
    }
  });
}
