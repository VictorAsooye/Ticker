# Fix Console Errors

You have 2 issues to fix:

## 🔴 CRITICAL: Enable Firestore API

**This is blocking your app from working!**

### Quick Fix:
1. **Open this link:**
   https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=ticker-54e2f

2. **Click "Enable"** button

3. **Wait 1-2 minutes** for it to activate

4. **OR use Firebase Console:**
   - Go to: https://console.firebase.google.com/project/ticker-54e2f/firestore
   - Click "Create database"
   - Choose "Start in test mode"
   - Select location: **us-central1**
   - Click "Enable"

---

## ⚠️ OPTIONAL: Fix RevenueCat API Key

RevenueCat errors won't break your app, but subscriptions won't work without it.

### Steps:
1. **Get your RevenueCat API key:**
   - Go to: https://app.revenuecat.com/
   - Select your project (or create one)
   - Go to **API Keys** section
   - Copy the **Public API Key** (starts with `appl_`)

2. **Update the code:**
   - Open `TickerCodebase/ViewModels/PurchaseManager.swift`
   - Find line 24: `Purchases.configure(withAPIKey: "YOUR_REVENUECAT_PUBLIC_KEY")`
   - Replace `"YOUR_REVENUECAT_PUBLIC_KEY"` with your actual key
   - Example: `Purchases.configure(withAPIKey: "appl_abc123xyz...")`

3. **Rebuild the app** in Xcode

---

## After Fixing:

1. **Wait 1-2 minutes** after enabling Firestore
2. **Close and reopen your app**
3. **Try again** - the errors should be gone!

---

**Priority:** Fix Firestore first (it's blocking everything). RevenueCat can wait if you're not testing subscriptions yet.

