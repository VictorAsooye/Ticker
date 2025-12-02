# RevenueCat API Key Setup

## Current Issue
The app is showing this error:
```
ERROR: 😿‼️ The specified API Key is not recognized.
Ensure that you are using the public app-specific API key, which should look like 'appl_1a2b3c4d5e6f7h'.
```

## Fix This (Optional for Now)

**Note:** This error won't crash your app, but in-app purchases won't work until you add your API key.

### Step 1: Get Your RevenueCat API Key

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Sign up or log in
3. Create a new project (or select existing)
4. Go to **Project Settings** → **API Keys**
5. Copy your **Public API Key** (starts with `appl_`)

### Step 2: Add to Your Code

1. Open `TickerCodebase/ViewModels/PurchaseManager.swift`
2. Find line 19:
   ```swift
   Purchases.configure(withAPIKey: "YOUR_REVENUECAT_PUBLIC_KEY")
   ```
3. Replace `"YOUR_REVENUECAT_PUBLIC_KEY"` with your actual key:
   ```swift
   Purchases.configure(withAPIKey: "appl_1a2b3c4d5e6f7h") // Your actual key
   ```

### Step 3: Rebuild

1. Clean: `Shift + Cmd + K`
2. Build: `Cmd + B`
3. Run: `Cmd + R`

---

## For Now (Testing Without Payments)

You can test the app without RevenueCat. The error is just a warning - the app will still run, but:
- ❌ In-app purchases won't work
- ❌ Subscription features won't work
- ✅ Everything else (auth, swiping, etc.) will work fine

**You can add the RevenueCat key later when you're ready to test payments.**

