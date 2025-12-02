# Content Quality System - Setup Instructions

## ✅ Deployment Complete!

All functions have been successfully deployed:
- ✅ `generateCards` - Now includes content quality features
- ✅ `trackSwipe` - Working
- ✅ `undoSwipe` - Working
- ✅ `getSwipeStatus` - Working

---

## 🔧 Required Setup Steps

### 1. Set Alpha Vantage API Key (Optional but Recommended)

**Get Free API Key:**
1. Visit: https://www.alphavantage.co/support/#api-key
2. Enter your email and get a free API key
3. Free tier: 25 API calls per day, 5 calls per minute

**Set in Firebase:**
```bash
cd functions
firebase functions:config:set alphavantage.key="YOUR_API_KEY_HERE"
```

**Note:** The `functions.config()` API is deprecated and will be shut down in March 2026. For now, it still works. If you want to future-proof, you can:
- Use environment variables in `.env` file (recommended for production)
- Or wait until closer to March 2026 to migrate

**Without API Key:**
- The system will still work
- Stock prices will use AI estimates (with disclaimer)
- Real-time prices will be fetched when API key is configured

---

### 2. Create Firestore Index (REQUIRED)

The `seen_cards` collection needs a composite index for efficient querying.

**Option A: Auto-create via Firebase Console**
1. Go to: https://console.firebase.google.com/project/ticker-54e2f/firestore/indexes
2. Click "Create Index"
3. Collection ID: `seen_cards`
4. Add fields:
   - `userId` (Ascending)
   - `type` (Ascending)
   - `shownAt` (Descending)
5. Click "Create"

**Option B: Use Firebase CLI**
```bash
firebase deploy --only firestore:indexes
```

**Option C: Create manually in Firebase Console**
1. Go to Firestore Database
2. Click "Indexes" tab
3. Click "Create Index"
4. Fill in the fields above

**Without Index:**
- The app will still work
- But querying seen cards will be slower
- You may see warnings in Firebase logs

---

## 🎯 What's New

### Content Quality Features:

1. **No Duplicates**
   - Tracks last 50 seen cards per user
   - Excludes them from new generations
   - Prevents showing same stocks/ideas repeatedly

2. **Real Stock Prices** (when API key set)
   - Fetches real-time prices from Alpha Vantage
   - Falls back to AI estimates if API unavailable
   - Shows "Estimate for education only" disclaimer

3. **Diverse Recommendations**
   - Daily rotation strategy (7 different themes)
   - Mix of company sizes (large/mid/small cap)
   - Different sectors and investment themes
   - Not just popular tech stocks

4. **Interest-Based Relevance**
   - Maps user interests to specific sectors
   - Technology → Tech stocks (NVDA, AMD, MSFT, etc.)
   - Healthcare → Biotech, medical devices
   - Finance → Fintech, banks
   - E-commerce → Marketplaces, retail
   - Creative → Streaming, design tools

5. **Quality Validation**
   - Validates all required fields
   - Checks ticker format (for stocks)
   - Verifies URLs are real (not placeholders)
   - Filters out invalid cards before showing

---

## 🧪 Testing Checklist

After setup, test these scenarios:

### Test 1: No Duplicates
- [ ] Generate cards 5 times in a row
- [ ] Verify no duplicate stocks/ideas appear
- [ ] Check Firebase Console > Firestore > `seen_cards` collection
- [ ] Should see entries with `userId`, `cardIdentifier`, `type`, `shownAt`

### Test 2: Real Stock Prices
- [ ] Set Alpha Vantage API key
- [ ] Generate stock cards
- [ ] Verify prices are realistic (not $0.00 or $999999)
- [ ] Check Firebase Functions logs for "✅ [TICKER]: $XX.XX (+X.X%)"
- [ ] If API fails, should see "⚠️ Using estimate for [TICKER]"

### Test 3: Diversity
- [ ] Generate cards multiple times
- [ ] Verify different sectors appear (not all tech)
- [ ] Check for mix of company sizes
- [ ] Verify rotation strategy changes daily

### Test 4: Interest Relevance
- [ ] User with "Technology" interest gets tech stocks
- [ ] User with "Healthcare" interest gets healthcare stocks
- [ ] User with multiple interests gets diverse mix

### Test 5: Quality Validation
- [ ] All cards have required fields (title, tagline, explainer)
- [ ] All URLs are real (clickable, not #)
- [ ] Stock tickers are valid format (1-5 uppercase letters)
- [ ] No invalid cards shown to users

---

## 📊 Monitoring

### Check Firebase Functions Logs:
```bash
firebase functions:log
```

Look for:
- `📋 User has seen X cards before` - Seen cards tracking working
- `🔄 Today's rotation: ...` - Rotation strategy active
- `💰 Fetching real-time prices...` - Price fetching active
- `✅ Valid cards: X/Y` - Validation working
- `✅ Stored X seen cards` - Seen cards storage working

### Check Firestore:
- `seen_cards` collection should populate as users view cards
- Each document has: `userId`, `cardIdentifier`, `type`, `shownAt`

---

## ⚠️ Important Notes

1. **Rate Limits:**
   - Alpha Vantage free tier: 25 calls/day, 5 calls/minute
   - System delays 500ms between requests to respect limits
   - For production, consider upgrading Alpha Vantage plan

2. **Cache:**
   - Cards are still cached for 24 hours
   - Seen cards tracking happens after cache check
   - New cards generated will exclude seen cards

3. **Migration Path:**
   - `functions.config()` deprecated until March 2026
   - Still works for now
   - Can migrate to `.env` files later if needed

---

## 🚀 Next Steps

1. ✅ Set Alpha Vantage API key (optional)
2. ✅ Create Firestore index (required)
3. ✅ Test the new features
4. ✅ Monitor Firebase logs
5. ✅ Verify seen_cards collection populates

**Everything is ready to go!** 🎉

