# Ticker App - Comprehensive Architecture Breakdown

## 🏗️ Overall Architecture

### Architecture Pattern: **MVVM (Model-View-ViewModel)**

The app follows SwiftUI's recommended MVVM pattern with clear separation:
- **Models**: Pure data structures with Codable for persistence
- **ViewModels**: Business logic and state management using `@Published` properties
- **Views**: SwiftUI views that observe ViewModels via `@StateObject` and `@ObservedObject`

### Key Design Decisions

1. **Singleton Services**: `StorageManager` and `OpenAIService` use singleton pattern for shared state
2. **Async/Await**: Modern Swift concurrency for API calls
3. **Codable Persistence**: UserDefaults with JSON encoding for simple data persistence
4. **Type-Safe Enums**: Used throughout for investment types, risk levels, etc.

---

## 📊 Data Layer (Models)

### 1. Investment Model (`Models/Investment.swift`)

**Purpose**: Core data structure representing either a stock or business idea

**Key Design Decisions**:
- **Polymorphic Design**: Single struct handles both stocks and ideas using `InvestmentType` enum
- **Optional Fields**: Stock-specific (`ticker`, `price`, `change`) and idea-specific (`category`, `investment`) are optional
- **Nested Models**: `Source` and `Resource` as separate structs for better organization
- **UUID IDs**: Uses `UUID` instead of strings for type safety and uniqueness

**Structure**:
```swift
Investment {
  - Common fields (title, tagline, explainer, etc.)
  - Stock fields (ticker, price, change) - optional
  - Idea fields (category, investment) - optional
  - Educational arrays (goodReasons, concerns)
  - Action items (sources, getStarted resources)
}
```

**Why This Design?**
- Single source of truth for all investment types
- Easy to extend with new investment types
- Codable makes persistence straightforward
- Identifiable enables SwiftUI list rendering

### 2. UserProfile Model (`Models/UserProfile.swift`)

**Purpose**: Stores user preferences from onboarding

**Key Features**:
- **Enum-Based Choices**: `InvestmentAmount`, `RiskLevel`, `Interest` as enums with `CaseIterable`
- **Computed Properties**: `openAIPrompt` generates formatted prompt string
- **Icon Mapping**: Each interest has an associated SF Symbol icon
- **Descriptions**: Risk levels include user-friendly descriptions

**Why Enums?**
- Type safety (can't have invalid values)
- Easy iteration for UI (`allCases`)
- Self-documenting code
- Compile-time checking

### 3. AppNotification Model (`Models/Notification.swift`)

**Purpose**: Notification system for daily recommendations

**Design**:
- Simple structure with `isNew` boolean flag
- `time` as String (not Date) for flexible formatting
- UUID for unique identification

---

## 🧠 Business Logic Layer (ViewModels)

### 1. StorageManager (`ViewModels/StorageManager.swift`)

**Pattern**: Singleton with static methods

**Responsibilities**:
- User profile persistence (save/load)
- Saved investments management
- Notifications storage
- Default data seeding

**Implementation Details**:
```swift
// Uses UserDefaults with JSON encoding
UserDefaults.standard.set(encoded, forKey: key)
```

**Why UserDefaults?**
- Simple key-value storage
- No external dependencies
- Automatic persistence
- Good for small data sets

**Limitations**:
- Not suitable for large datasets
- No encryption (should use Keychain for sensitive data)
- Synchronous operations

### 2. OpenAIService (`ViewModels/OpenAIService.swift`)

**Pattern**: Singleton service with async/await

**Key Implementation**:

**a) Prompt Engineering**:
- System message defines AI role
- User prompt includes profile data
- JSON examples provided for structure
- Specific formatting requirements

**b) JSON Parsing**:
```swift
// Handles markdown code blocks that GPT sometimes returns
cleanJSON = json
  .replacingOccurrences(of: "```json", with: "")
  .replacingOccurrences(of: "```", with: "")
```

**c) Error Handling**:
- Custom `OpenAIError` enum
- Localized error descriptions
- Graceful degradation

**d) Async Concurrency**:
```swift
// Parallel loading of stocks and ideas
async let stocks = openAI.generateInvestments(...)
async let ideas = openAI.generateInvestments(...)
let (loadedStocks, loadedIdeas) = try await (stocks, ideas)
```

**Why This Approach?**
- Parallel API calls = faster loading
- Structured prompts = consistent output
- Error handling = better UX
- JSON parsing = type-safe data

### 3. HomeViewModel (`ViewModels/HomeViewModel.swift`)

**Pattern**: ObservableObject with @Published properties

**State Management**:
```swift
@Published var stockCards: [Investment] = []
@Published var ideaCards: [Investment] = []
@Published var currentTab: InvestmentType = .stock
@Published var isLoading = false
@Published var error: String?
```

**Key Methods**:
- `loadInitialCards()`: Async function that loads both types in parallel
- `getCurrentCards()`: Returns cards for current tab
- `removeTopCard()`: Removes first card (swipe left)
- `saveInterest()`: Saves to StorageManager (swipe right)

**Why @MainActor?**
- Ensures all UI updates happen on main thread
- SwiftUI requirement for ObservableObject
- Prevents race conditions

**Initialization Flow**:
1. Load notifications immediately (synchronous)
2. Start async card loading in Task
3. Check if onboarding completed
4. Load cards if profile exists

---

## 🎨 Presentation Layer (Views)

### 1. App Entry Point (`TickerApp.swift`)

**Flow Control**:
```swift
if hasCompletedOnboarding {
  NavigationView { HomeView() }
} else {
  OnboardingView()
}
```

**Initialization Logic**:
- Checks UserDefaults on app launch
- Sets state based on persisted profile
- Conditional rendering based on onboarding status

**Why This Design?**
- Single source of truth for app state
- Clean separation of onboarding vs main app
- NavigationView only when needed

### 2. Onboarding Flow

**Structure**: 3-step TabView with progress indicator

**Step 1: InvestmentAmountView**
- Displays all `InvestmentAmount` enum cases
- Auto-advances on selection
- Visual feedback with checkmark

**Step 2: RiskLevelView**
- Shows risk levels with descriptions
- Uses `risk.description` for user-friendly text
- Auto-advances on selection

**Step 3: InterestsView**
- Grid layout (2 columns)
- Multi-select with toggle behavior
- "Get Started" button saves profile
- Disabled until at least one interest selected

**Progress Bar**:
```swift
ForEach(0..<3) { index in
  Rectangle()
    .fill(index <= currentStep ? AppColors.gold : AppColors.darkGray)
}
```

**Why TabView?**
- Native swipe gestures
- Smooth transitions
- Built-in page indicators (hidden)
- Prevents back navigation (good for onboarding)

### 3. Home Screen (`Views/Home/HomeView.swift`)

**Layout Structure**:
```
VStack {
  Header (title + buttons)
  TabBar (Stocks/Ideas toggle)
  Content (loading/error/cards)
}
Overlays (menu + notifications)
```

**State Management**:
- `@StateObject` for HomeViewModel (creates instance)
- `@State` for UI state (menu, notifications)
- ViewModel handles all business logic

**Overlay Pattern**:
```swift
if showMenu {
  Color.black.opacity(0.5) // Backdrop
    .onTapGesture { showMenu = false }
  SideMenu() // Content
}
```

**Why Overlays?**
- Modal presentation
- Easy dismissal
- Clean separation
- Smooth animations

### 4. Swipe Card Stack (`Views/Home/SwipeCardStack.swift`)

**Core Mechanics**:

**a) Gesture Handling**:
```swift
DragGesture()
  .onChanged { gesture in
    offset = gesture.translation
    rotation = Double(gesture.translation.width / 20)
  }
```

**b) Swipe Detection**:
```swift
if abs(swipeDistance) > swipeThreshold {
  // Complete swipe
  offset = CGSize(width: swipeDistance > 0 ? 500 : -500, ...)
  // Callback after animation
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    onSwipeRight(cards[0])
  }
}
```

**c) Visual Depth**:
```swift
// Background card (second card visible)
if cards.count > 1 {
  InvestmentCard(investment: cards[1])
    .scaleEffect(0.95)
    .offset(y: 10)
    .opacity(0.5)
}
```

**d) Action Buttons**:
- Programmatic swipe triggers
- Same animation as gesture
- Same callbacks

**Why This Implementation?**
- Native SwiftUI gestures (smooth)
- Spring animations (natural feel)
- Threshold prevents accidental swipes
- Rotation adds visual feedback

### 5. Investment Card (`Views/Home/InvestmentCard.swift`)

**Layout Strategy**:

**a) Conditional Header**:
```swift
if investment.type == .stock {
  // Ticker + Price layout
} else {
  // Title + Category layout
}
```

**b) Section Components**:
- `SectionView`: Reusable wrapper for labeled sections
- Color-coded sections (green for pros, red for concerns)
- Consistent padding and styling

**c) ScrollView**:
- Allows long content
- Maintains card boundaries
- Smooth scrolling

**d) Link Integration**:
```swift
Link(destination: URL(string: source.url)!) {
  // Clickable source/resource items
}
```

**Design Patterns**:
- Composition over inheritance
- Reusable components (`SectionView`)
- Consistent spacing system
- Visual hierarchy with typography

### 6. Tab Bar (`Views/Home/TabBar.swift`)

**Implementation**:
- Two-button layout
- Active state with gold underline
- Icon + text labels
- Tracks `InvestmentType` enum

**Why Custom TabBar?**
- Matches design system
- Only 2 tabs (simpler than TabView)
- Full control over styling

---

## 🎨 Design System (`Utilities/Constants.swift`)

### Color System

**Structure**:
- Base colors (background, text)
- Semantic colors (gold, green, red)
- Variants (dark, light, border)

**Hex Color Extension**:
```swift
extension Color {
  init(hex: String) {
    // Handles 3, 6, and 8 character hex codes
    // Supports alpha channel
  }
}
```

**Why This System?**
- Centralized color management
- Easy theme switching
- Consistent across app
- Type-safe access

### Typography

**Font Strategy**:
- Serif for titles (Cormorant Garamond)
- Sans-serif for body (SF Pro Text)
- System fonts for icons

**Why Mixed Fonts?**
- Serif adds elegance to titles
- Sans-serif improves readability
- System fonts ensure icon compatibility

---

## 🔄 Data Flow

### 1. App Launch Flow

```
TickerApp.init()
  ↓
Check StorageManager for profile
  ↓
Set hasCompletedOnboarding state
  ↓
Render OnboardingView OR HomeView
```

### 2. Onboarding Flow

```
InvestmentAmountView
  ↓ (user selects)
Update profile.investmentAmount
  ↓
Auto-advance to RiskLevelView
  ↓ (user selects)
Update profile.riskLevel
  ↓
Auto-advance to InterestsView
  ↓ (user selects interests)
Update profile.interests
  ↓
User taps "Get Started"
  ↓
Set profile.hasCompletedOnboarding = true
  ↓
StorageManager.saveUserProfile(profile)
  ↓
Update hasCompletedOnboarding binding
  ↓
App shows HomeView
```

### 3. Card Loading Flow

```
HomeViewModel.init()
  ↓
Task { await loadInitialCards() }
  ↓
Check if profile exists and onboarding complete
  ↓
Set isLoading = true
  ↓
Parallel API calls:
  - async let stocks = openAI.generateInvestments(...)
  - async let ideas = openAI.generateInvestments(...)
  ↓
Wait for both (try await)
  ↓
Update @Published properties:
  - stockCards = loadedStocks
  - ideaCards = loadedIdeas
  ↓
Set isLoading = false
  ↓
SwiftUI automatically updates UI
```

### 4. Swipe Flow

```
User drags card
  ↓
DragGesture.onChanged
  ↓
Update offset and rotation state
  ↓
Card visually moves
  ↓
User releases
  ↓
DragGesture.onEnded
  ↓
Check if swipeDistance > threshold
  ↓
If yes:
  - Animate card off screen
  - Wait for animation
  - Call onSwipeRight/onSwipeLeft
  - Remove card from array
If no:
  - Animate back to center
```

### 5. Save Interest Flow

```
User swipes right
  ↓
onSwipeRight callback
  ↓
HomeViewModel.saveInterest(investment)
  ↓
StorageManager.saveInvestment(investment)
  ↓
Load from UserDefaults
  ↓
Append if not exists
  ↓
Encode and save to UserDefaults
  ↓
Remove card from array
```

---

## 🔌 API Integration

### OpenAI Service Architecture

**Request Structure**:
```swift
ChatQuery(
  messages: [
    SystemMessage: "You are a financial education assistant...",
    UserMessage: buildPrompt(profile, type, count)
  ],
  model: .gpt4,
  maxTokens: 4000
)
```

**Prompt Engineering Strategy**:

1. **System Message**: Defines AI role and output format
2. **User Prompt**: Includes:
   - User profile (budget, risk, interests)
   - Investment type (stock/idea)
   - Count requested
   - JSON structure example
   - Formatting requirements

3. **JSON Examples**: Provided in prompt to guide structure

**Response Parsing**:
1. Extract content from response
2. Clean markdown code blocks
3. Convert to Data
4. Decode JSON to [Investment]
5. Return typed array

**Error Handling**:
- Network errors → catch and set error message
- Invalid JSON → throw OpenAIError.invalidJSON
- Missing response → throw OpenAIError.invalidResponse

---

## 💾 Persistence Strategy

### UserDefaults with JSON Encoding

**Why UserDefaults?**
- Built into iOS
- No external dependencies
- Automatic persistence
- Good for small datasets

**Encoding Strategy**:
```swift
// Save
let encoded = try JSONEncoder().encode(object)
UserDefaults.standard.set(encoded, forKey: key)

// Load
let data = UserDefaults.standard.data(forKey: key)
let decoded = try JSONDecoder().decode(Type.self, from: data)
```

**Stored Data**:
1. UserProfile (single object)
2. SavedInvestments (array)
3. Notifications (array)

**Limitations**:
- Not encrypted (use Keychain for API keys)
- Size limits (not for large datasets)
- Synchronous (can block main thread)

---

## 🎯 Key Implementation Details

### 1. SwiftUI State Management

**Pattern Used**:
- `@State`: Local view state
- `@StateObject`: Creates and owns ViewModel
- `@ObservedObject`: Observes existing ViewModel
- `@Binding`: Two-way data binding
- `@Published`: ViewModel properties that trigger updates

**Why This Mix?**
- `@StateObject` for ViewModels (lifecycle management)
- `@State` for UI-only state (menu visibility)
- `@Binding` for parent-child communication
- `@Published` for reactive updates

### 2. Async/Await Concurrency

**Usage**:
```swift
@MainActor class HomeViewModel {
  func loadInitialCards() async {
    async let stocks = ...
    async let ideas = ...
    let (loadedStocks, loadedIdeas) = try await (stocks, ideas)
  }
}
```

**Benefits**:
- Parallel execution (faster)
- Type-safe error handling
- No callback hell
- Main thread safety with @MainActor

### 3. Gesture System

**DragGesture Implementation**:
- `.onChanged`: Continuous updates during drag
- `.onEnded`: Final position and velocity
- Threshold check: Prevents accidental swipes
- Animation: Spring physics for natural feel

**Why DragGesture?**
- Native SwiftUI (smooth)
- Built-in velocity tracking
- Easy to implement
- Good performance

### 4. Animation System

**Types Used**:
- `.spring()`: Natural physics-based animations
- `.easeInOut`: Smooth transitions
- `.animation()`: View modifier for automatic animations

**Key Animations**:
- Card swipe (spring)
- Menu slide (easeInOut)
- Progress bar (easeInOut)
- Button presses (implicit)

### 5. Component Reusability

**Reusable Components**:
- `SectionView`: Generic section wrapper
- `MenuButton`: Consistent menu item styling
- `TabButton`: Tab bar button component
- `SavedInvestmentRow`: List item component

**Benefits**:
- DRY principle
- Consistent styling
- Easy maintenance
- Type-safe

---

## 🚀 Performance Optimizations

### 1. Lazy Loading
- `LazyVGrid` for interests grid
- `LazyVStack` for saved investments
- Only renders visible items

### 2. Parallel API Calls
- Stocks and ideas load simultaneously
- Reduces total wait time
- Better user experience

### 3. State Management
- `@Published` only updates when changed
- SwiftUI's diffing minimizes redraws
- Efficient view updates

### 4. Image Loading
- SF Symbols (vector, no loading)
- No external image dependencies
- Instant rendering

---

## 🔒 Security Considerations

### Current Implementation
- API key in Constants (⚠️ not secure)
- UserDefaults for data (not encrypted)

### Production Improvements Needed
1. **Keychain for API Keys**
   ```swift
   // Should use:
   KeychainHelper.save(key: "openai_key", value: apiKey)
   ```

2. **Encrypted Storage**
   - Use Keychain for sensitive data
   - Encrypt UserDefaults if needed

3. **Network Security**
   - HTTPS only
   - Certificate pinning (optional)

---

## 📱 User Experience Flow

### First Launch
1. App checks onboarding status
2. Shows onboarding if not completed
3. 3-step flow with progress indicator
4. Saves profile on completion
5. Transitions to home screen

### Returning User
1. App loads saved profile
2. Shows home screen immediately
3. Loads cards in background
4. Shows loading state
5. Displays cards when ready

### Card Interaction
1. User sees card stack
2. Can swipe or use buttons
3. Left swipe = pass (removes card)
4. Right swipe = save (saves + removes)
5. Empty state when done

### Menu Access
1. Tap menu icon
2. Side menu slides in
3. Access saved interests
4. Settings, profile, etc.
5. Tap outside to dismiss

---

## 🎨 Design Philosophy

### Visual Hierarchy
1. **Titles**: Large serif font (elegance)
2. **Body**: Medium sans-serif (readability)
3. **Labels**: Small caps (organization)
4. **Colors**: Gold for emphasis, green/red for pros/cons

### Spacing System
- Consistent padding (16, 20, 24)
- Card corner radius: 12
- Border width: 1
- Section spacing: 20

### Color Psychology
- **Gold**: Premium, valuable (investment theme)
- **Green**: Positive, growth (pros)
- **Red**: Caution, risk (concerns)
- **Dark Gray**: Depth, hierarchy

---

## 🔧 Extensibility

### Easy to Add
1. **New Investment Types**: Add to `InvestmentType` enum
2. **New Risk Levels**: Add to `RiskLevel` enum
3. **New Interests**: Add to `Interest` enum
4. **New Sections**: Use `SectionView` component

### Architecture Supports
- Multiple investment types
- Different card layouts
- Additional onboarding steps
- More notification types

---

## 📊 Code Statistics

- **Total Files**: ~20 Swift files
- **Lines of Code**: ~2,500+
- **Models**: 3 main models
- **ViewModels**: 3 ViewModels
- **Views**: 15+ view components
- **Dependencies**: 1 (OpenAI package)

---

## 🎓 Key Learnings & Best Practices

### What Worked Well
1. **MVVM Pattern**: Clean separation of concerns
2. **Enum-Based Models**: Type safety and easy iteration
3. **Async/Await**: Modern, readable async code
4. **Component Reusability**: DRY principle
5. **Design System**: Consistent styling

### Areas for Improvement
1. **Error Handling**: More comprehensive error states
2. **Loading States**: Skeleton screens instead of spinner
3. **Caching**: Cache API responses to reduce calls
4. **Testing**: Unit tests for ViewModels
5. **Accessibility**: VoiceOver support, dynamic type

---

## 🚀 Future Enhancements

### Potential Additions
1. **Offline Mode**: Cache cards for offline viewing
2. **Push Notifications**: Real-time price alerts
3. **Social Features**: Share investments
4. **Analytics**: Track user engagement
5. **A/B Testing**: Test different card layouts
6. **Dark/Light Mode**: Theme switching
7. **iPad Support**: Adaptive layouts
8. **Watch App**: Quick price checks

---

This architecture provides a solid foundation for a production-ready investment education app with room for growth and enhancement.

