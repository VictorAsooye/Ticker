/**
 * Stock Price Service
 * Fetches real-time stock prices from Alpha Vantage
 */

import axios from 'axios';
import { StockQuote } from '../types';
import { CONSTANTS } from '../config/constants';

export class StockPriceService {
  private apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  /**
   * Fetch real-time stock price from Alpha Vantage
   * Free tier: 25 API calls per day, 5 calls per minute
   */
  async fetchStockPrice(ticker: string): Promise<StockQuote | null> {
    try {
      if (this.apiKey === 'demo') {
        console.warn(`⚠️ Alpha Vantage API key not configured. Using estimates for ${ticker}`);
        return null;
      }

      const url = `https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${ticker}&apikey=${this.apiKey}`;

      const response = await axios.get(url, {
        timeout: CONSTANTS.ALPHA_VANTAGE.TIMEOUT_MS,
      });

      const quote = response.data['Global Quote'];

      if (!quote || !quote['05. price']) {
        console.warn(`⚠️ No price data for ${ticker}`);
        return null;
      }

      const price = parseFloat(quote['05. price']);
      const change = parseFloat(quote['09. change']);
      const changePercent = parseFloat(quote['10. change percent'].replace('%', ''));

      return {
        symbol: ticker,
        price: `$${price.toFixed(2)}`,
        change: change >= 0 ? `+${Math.abs(change).toFixed(2)}` : `-${Math.abs(change).toFixed(2)}`,
        changePercent: change >= 0 ? `+${Math.abs(changePercent).toFixed(1)}%` : `-${Math.abs(changePercent).toFixed(1)}%`,
      };
    } catch (error: any) {
      console.error(`❌ Error fetching price for ${ticker}:`, error.message);
      return null;
    }
  }

  /**
   * Fetch multiple stock prices in parallel (with rate limiting)
   */
  async fetchStockPrices(tickers: string[]): Promise<Map<string, StockQuote>> {
    const priceMap = new Map<string, StockQuote>();

    // Batch requests with delay to respect rate limits (5 calls per minute on free tier)
    for (const ticker of tickers) {
      const quote = await this.fetchStockPrice(ticker);
      if (quote) {
        priceMap.set(ticker, quote);
      }

      // Delay between requests to respect rate limits
      await new Promise(resolve => setTimeout(resolve, CONSTANTS.ALPHA_VANTAGE.REQUEST_DELAY_MS));
    }

    return priceMap;
  }
}
