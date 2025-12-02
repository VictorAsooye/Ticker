# 📋 Files That Might Be Missing from Xcode Project

## All Swift Files Found in Directory:

### ✅ Core Files:
- `TickerApp.swift` (main app entry)

### ✅ Models:
- `Models/Investment.swift`
- `Models/UserProfile.swift`
- `Models/Notification.swift`
- `Models/FirestoreModels.swift`

### ✅ ViewModels:
- `ViewModels/HomeViewModel.swift`
- `ViewModels/OpenAIService.swift`
- `ViewModels/StorageManager.swift`
- `ViewModels/FirebaseManager.swift`
- `ViewModels/AuthViewModel.swift`
- `ViewModels/CloudFunctionsService.swift`
- `ViewModels/PurchaseManager.swift`

### ✅ Utilities:
- `Utilities/Constants.swift`
- `Utilities/Extensions.swift`
- `Utilities/HapticManager.swift`
- `Utilities/NotificationManager.swift`
- `Utilities/UndoManager.swift`
- `Utilities/DeviceHelper.swift`
- `Utilities/AnalyticsHelper.swift`

### ✅ Views - Onboarding:
- `Views/Onboarding/OnboardingView.swift`
- `Views/Onboarding/InvestmentAmountView.swift`
- `Views/Onboarding/RiskLevelView.swift`
- `Views/Onboarding/InterestsView.swift`
- `Views/Onboarding/NotificationPermissionView.swift`

### ✅ Views - Authentication:
- `Views/Authentication/AuthenticationView.swift`

### ✅ Views - Home:
- `Views/Home/HomeView.swift`
- `Views/Home/InvestmentCard.swift`
- `Views/Home/SwipeCardStack.swift`
- `Views/Home/TabBar.swift`

### ✅ Views - Components:
- `Views/Components/SideMenu.swift`
- `Views/Components/NotificationDropdown.swift`
- `Views/Components/GetStartedSection.swift`
- `Views/Components/UndoBannerView.swift`
- `Views/Components/LoadingCardView.swift`

### ✅ Views - Other:
- `Views/Paywall/PaywallView.swift`
- `Views/SavedInterests/SavedInterestsView.swift`
- `Views/Legal/LegalView.swift`
- `Views/Legal/DisclaimerPopupView.swift`
- `Views/Settings/SettingsView.swift`

---

## 🔍 How to Check Which Files Are Missing:

1. In Xcode, click **"TARGET: TickerCodebase"**
2. Go to **"Build Phases"** tab
3. Expand **"Compile Sources"**
4. Compare the list with the files above

---

## 📝 Files That Might Be Missing:

Based on common issues, these files are often missed:

- `Utilities/HapticManager.swift` ← **This one is causing errors!**
- `Utilities/UndoManager.swift`
- `Utilities/DeviceHelper.swift`
- `Utilities/AnalyticsHelper.swift`
- `Views/Components/UndoBannerView.swift`
- `Views/Components/LoadingCardView.swift`
- `Views/Legal/LegalView.swift`
- `Views/Legal/DisclaimerPopupView.swift`
- `Views/Settings/SettingsView.swift`
- `Views/Onboarding/NotificationPermissionView.swift`

---

## ✅ How to Add Missing Files:

1. In Xcode, right-click on the folder where the file should be (e.g., `Utilities/`)
2. Select **"Add Files to TickerCodebase..."**
3. Navigate to the file
4. Make sure:
   - ✅ **"Copy items if needed"** is UNCHECKED (file is already in project folder)
   - ✅ **"Create groups"** is selected
   - ✅ **"TickerCodebase"** target is CHECKED
5. Click **"Add"**

---

## 🎯 Quick Check:

If you're getting "Cannot find X in scope" errors, that file is likely missing from the target. Add it using the steps above!


