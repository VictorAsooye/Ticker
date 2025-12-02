# Quick Deploy Instructions

## ✅ Prerequisites Check
You already have:
- ✅ Node.js v25.1.0
- ✅ Firebase CLI 14.22.0

## Step-by-Step Instructions

### Step 1: Open Terminal
Press `Cmd + Space`, type "Terminal", and press Enter.

### Step 2: Navigate to Your Project
Copy and paste this into Terminal:
```bash
cd /Users/victorasooye/Documents/Ticker
```

### Step 3: Login to Firebase (if not already logged in)
```bash
firebase login
```
- This will open a browser window
- Click "Allow" to authorize
- Come back to Terminal when done

### Step 4: Make Sure You're Using the Right Firebase Project
```bash
firebase use --add
```
- Select your Firebase project (ticker-54e2f or similar)
- Press Enter

### Step 5: Set Your OpenAI API Key
Replace `YOUR_OPENAI_API_KEY_HERE` with your actual OpenAI API key:
```bash
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY_HERE"
```

**Example:**
```bash
firebase functions:config:set openai.key="sk-proj-abc123xyz..."
```

### Step 6: Install Function Dependencies
```bash
cd functions
npm install
cd ..
```

### Step 7: Deploy Cloud Functions
```bash
firebase deploy --only functions
```

This will take 2-3 minutes. You should see:
```
✔  functions[generateCards(us-central1)]: Successful create operation.
✔  functions[trackSwipe(us-central1)]: Successful create operation.
```

### Step 8: Test Your App!
1. Open your app in Xcode
2. Run it on your phone
3. Complete onboarding (if needed)
4. You should now see investment cards instead of "NOT FOUND"!

## Troubleshooting

### If you get "permission denied":
- Make sure you're logged in: `firebase login`
- Check your Firebase project permissions

### If you get "functions not found":
- Make sure you're in `/Users/victorasooye/Documents/Ticker`
- Run `firebase use --add` to select your project

### To check your config:
```bash
firebase functions:config:get
```

### To update your API key later:
Just run Step 5 again, then Step 7.

---

**That's it!** Once deployed, your app will be able to generate investment cards using OpenAI! 🚀

