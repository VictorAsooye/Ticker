# Setup OpenAI API Key for Ticker App

The app uses Firebase Cloud Functions to securely call the OpenAI API. Follow these steps to connect your OpenAI API key:

## Step 1: Install Firebase CLI (if not already installed)

```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase

```bash
firebase login
```

## Step 3: Set Your OpenAI API Key

Run this command (replace `YOUR_OPENAI_API_KEY` with your actual key):

```bash
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
```

**Example:**
```bash
firebase functions:config:set openai.key="sk-proj-abc123xyz..."
```

## Step 4: Install Function Dependencies

Navigate to the functions directory and install dependencies:

```bash
cd functions
npm install
cd ..
```

## Step 5: Deploy Cloud Functions

Deploy the functions to Firebase:

```bash
firebase deploy --only functions
```

This will:
- Build the TypeScript functions
- Deploy `generateCards` and `trackSwipe` functions to Firebase
- Make them available for your app to call

## Step 6: Verify Deployment

After deployment, you should see output like:
```
✔  functions[generateCards(us-central1)]: Successful create operation.
✔  functions[trackSwipe(us-central1)]: Successful create operation.
```

## Troubleshooting

### If you get "functions not found" error:
1. Make sure you're in the project root directory (where `firebase.json` should be)
2. Check that `firebase.json` exists and has functions configured
3. Run `firebase use --add` to select your Firebase project

### If you get "permission denied" errors:
1. Make sure you're logged in: `firebase login`
2. Make sure you have the correct project selected: `firebase use <project-id>`
3. Check your Firebase project permissions in the Firebase Console

### To check your current config:
```bash
firebase functions:config:get
```

### To update your API key later:
Just run Step 3 again with the new key, then redeploy:
```bash
firebase deploy --only functions
```

## Important Notes

- **Never commit your API key to git** - it's stored securely in Firebase Functions config
- The API key is only accessible server-side in Cloud Functions
- Your app calls the Cloud Functions, which then call OpenAI securely
- This keeps your API key safe and allows you to control usage/rate limiting

## Next Steps

After deploying:
1. Open your app
2. Complete onboarding (if you haven't)
3. Try swiping on the home screen - cards should generate using OpenAI!

