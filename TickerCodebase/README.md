# Ticker - AI-Powered Investment Education App

A SwiftUI iOS app with a Tinder-style swipe interface for discovering and learning about stocks and business ideas, powered by OpenAI.

## Features

- 🎯 Personalized investment recommendations based on user profile
- 📱 Tinder-style swipe interface for stocks and business ideas
- 📚 Educational content with beginner-friendly explanations
- 💾 Save interesting investments for later review
- 🔔 Daily recommendations and notifications
- 🎨 Beautiful dark theme UI

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- OpenAI API Key

## Setup Instructions

### 1. Create New Xcode Project

1. Open Xcode
2. Create new iOS App
3. Name: **"Ticker"**
4. Interface: **SwiftUI**
5. Language: **Swift**
6. Minimum Deployment: **iOS 17.0**

### 2. Add OpenAI Package

1. In Xcode: **File > Add Package Dependencies**
2. Enter URL: `https://github.com/MacPaw/OpenAI`
3. Click **Add Package**
4. Select the package and add to your target

### 3. Download Custom Fonts (Optional but Recommended)

1. Download **Cormorant Garamond** from [Google Fonts](https://fonts.google.com/specimen/Cormorant+Garamond)
2. Add font files to your Xcode project
3. Update `Info.plist`:
   - Add key: `Fonts provided by application`
   - Add font filenames as array items

### 4. Add Info.plist Entries

Add the following to your `Info.plist` if needed:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

For custom fonts:
```xml
<key>UIAppFonts</key>
<array>
    <string>CormorantGaramond-Regular.ttf</string>
    <string>CormorantGaramond-SemiBold.ttf</string>
</array>
```

### 5. Replace API Key

1. Open `Utilities/Constants.swift`
2. Replace `"YOUR_OPENAI_API_KEY"` with your actual OpenAI API key:

```swift
static let openAIKey = "sk-your-actual-api-key-here"
```

**⚠️ Important:** For production, use Keychain or environment variables instead of hardcoding the key.

### 6. Project Structure

Ensure all files are organized as follows:

```
Ticker/
├── TickerApp.swift
├── Models/
│   ├── Investment.swift
│   ├── UserProfile.swift
│   └── Notification.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── OpenAIService.swift
│   └── StorageManager.swift
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── InvestmentAmountView.swift
│   │   ├── RiskLevelView.swift
│   │   └── InterestsView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── InvestmentCard.swift
│   │   ├── TabBar.swift
│   │   └── SwipeCardStack.swift
│   ├── Components/
│   │   ├── SideMenu.swift
│   │   ├── NotificationDropdown.swift
│   │   └── GetStartedSection.swift
│   └── SavedInterests/
│       └── SavedInterestsView.swift
├── Utilities/
│   ├── Constants.swift
│   └── Extensions.swift
└── Info.plist
```

### 7. Build & Run

1. Select **iPhone 15 Pro** simulator (or any iOS 17+ device)
2. Press **⌘ + R** to build and run
3. The app should launch and show the onboarding flow

### 8. Test Flow

1. **Onboarding:**
   - Complete all 3 onboarding screens
   - Select investment amount
   - Choose risk level
   - Select interests

2. **Home Screen:**
   - View AI-generated investment cards
   - Swipe left to pass
   - Swipe right to save
   - Use action buttons at bottom

3. **Menu:**
   - Tap menu icon (top right)
   - Navigate to "My Interests"
   - View saved investments

4. **Notifications:**
   - Tap bell icon
   - View daily recommendations
   - Mark notifications as read

## Important Notes

### API Costs
- The OpenAI API will make real API calls and incur costs
- Monitor your usage in the OpenAI dashboard
- Consider implementing rate limiting for production

### Error Handling
- Add proper error handling for network failures
- Implement retry logic for failed API calls
- Show user-friendly error messages

### Security
- **Never commit API keys to version control**
- Use Keychain for secure API key storage
- Consider using environment variables for development

### Production Readiness

Before App Store submission, add:

1. **API Key Management:**
   - Move API key to Keychain
   - Add secure configuration management

2. **Error Handling:**
   - Network error recovery
   - Graceful degradation
   - User-friendly error messages

3. **Analytics:**
   - User engagement tracking
   - Feature usage analytics
   - Crash reporting

4. **App Store Assets:**
   - App icon (1024x1024)
   - Screenshots for all device sizes
   - App preview videos

5. **Legal:**
   - Privacy policy
   - Terms of service
   - Data usage disclosure

6. **Testing:**
   - Unit tests for ViewModels
   - UI tests for critical flows
   - Device testing (not just simulator)

## Troubleshooting

### Build Errors
- Ensure all files are added to the target
- Check that OpenAI package is properly linked
- Verify iOS deployment target is 17.0+

### API Errors
- Verify API key is correct
- Check internet connection
- Review OpenAI API status
- Check API rate limits

### Font Issues
- Verify fonts are added to project bundle
- Check Info.plist font entries
- Ensure font names match exactly

## License

This project is provided as-is for educational purposes.

## Support

For issues or questions, please check:
- OpenAI API documentation
- SwiftUI documentation
- Xcode release notes

---

**Happy Investing! 📈**

