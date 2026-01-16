# UX/UI Design Guide - Vista Egyptian AI Market Analysis App

## Design Philosophy

Vista prioritizes **psychological comfort**, **trust**, and **clarity**. The app must feel safe, explainable, and professional—never pushy or promotional. All financial language must be legal-safe with clear disclaimers.

### Core Principles

1. **Comfort Colors**: Soft, non-aggressive palette (avoid red/green for gains/losses)
2. **Full Explainability**: Every signal shows confidence, risk, reasons, and caveats
3. **Legal Safety**: No "Buy Now" or "Sell Now" language—only analysis
4. **Smooth Animations**: 60fps transitions, skeleton loaders, haptic feedback
5. **Accessibility**: WCAG 2.1 AA compliance, screen reader support
6. **RTL Support**: Full Arabic right-to-left layout with Alexandria font

## Typography

### Primary Font: Alexandria

Alexandria is the primary Arabic font family for all text in the app.

**Font Loading** (Flutter):
```dart
// pubspec.yaml
fonts:
  - family: Alexandria
    fonts:
      - asset: fonts/Alexandria-Regular.ttf
      - asset: fonts/Alexandria-Bold.ttf
        weight: 700
      - asset: fonts/Alexandria-Light.ttf
        weight: 300
```

**Usage**:
- **Headings**: Alexandria Bold, sizes 24-32sp
- **Body Text**: Alexandria Regular, sizes 14-16sp
- **Captions**: Alexandria Light, sizes 12-14sp

### Fallback Fonts

- **Arabic**: Cairo (fallback if Alexandria fails to load)
- **Numbers/Latin**: SF Pro (iOS), Roboto (Android) for consistency

## Color Palette

### Light Theme

```dart
class VistaLightColors {
  // Primary
  static const primary = Color(0xFF0066CC); // Trust blue
  static const primaryDark = Color(0xFF004499);
  static const primaryLight = Color(0xFF3399FF);
  
  // Background
  static const background = Color(0xFFF5F7FA); // Soft gray
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  
  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  
  // Comfort Colors (NOT red/green for gains/losses)
  static const positive = Color(0xFF10B981); // Soft green (calming)
  static const negative = Color(0xFFEF4444); // Soft red (non-alarming)
  static const neutral = Color(0xFF6B7280);
  
  // Signals
  static const signalBuy = Color(0xFF059669); // Deeper green (trust)
  static const signalSell = Color(0xFFDC2626); // Deeper red (caution)
  static const signalHold = Color(0xFF6B7280); // Neutral gray
  
  // Risk Levels
  static const riskLow = Color(0xFF10B981);
  static const riskMedium = Color(0xFFF59E0B); // Amber
  static const riskHigh = Color(0xFFEF4444);
  
  // Confidence (Gradient)
  static const confidenceHigh = Color(0xFF059669);
  static const confidenceMedium = Color(0xFFF59E0B);
  static const confidenceLow = Color(0xFFEF4444);
  
  // Dividers & Borders
  static const divider = Color(0xFFE5E7EB);
  static const border = Color(0xFFD1D5DB);
}
```

### Dark Theme

```dart
class VistaDarkColors {
  // Primary
  static const primary = Color(0xFF3399FF);
  static const primaryDark = Color(0xFF0066CC);
  static const primaryLight = Color(0xFF66B2FF);
  
  // Background
  static const background = Color(0xFF111827); // Dark gray
  static const surface = Color(0xFF1F2937);
  static const surfaceElevated = Color(0xFF374151);
  
  // Text
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFFD1D5DB);
  static const textTertiary = Color(0xFF9CA3AF);
  
  // Comfort Colors (adjusted for dark mode)
  static const positive = Color(0xFF34D399);
  static const negative = Color(0xFFF87171);
  static const neutral = Color(0xFF9CA3AF);
  
  // Signals, Risk, Confidence: Same as light theme (with slight adjustments)
  static const signalBuy = Color(0xFF10B981);
  static const signalSell = Color(0xFFEF4444);
  static const signalHold = Color(0xFF9CA3AF);
  
  // Dividers & Borders
  static const divider = Color(0xFF374151);
  static const border = Color(0xFF4B5563);
}
```

## Navigation Structure

### Bottom Navigation Bar (5 Tabs)

1. **Today** (اليوم)
   - Icon: Calendar/Home
   - Shows market summary + today's signals

2. **Signals** (الإشارات)
   - Icon: Trending Up/Chart
   - Shows all recent signals with filters

3. **Watchlist** (قائمة المتابعة)
   - Icon: Star/Bookmark
   - Shows favorites + user watchlists

4. **Explore** (استكشف)
   - Icon: Search/Compass
   - Browse stocks and funds

5. **Profile** (الملف الشخصي)
   - Icon: User
   - Settings, subscription, alerts, education

### Navigation Flow (GoRouter)

```dart
// Main routes
/today
/signals
  /signals/:id (Signal details)
/watchlist
  /watchlist/:id (Watchlist detail)
/explore
  /explore/stocks/:symbol (Stock detail)
  /explore/funds/:id (Fund detail)
/profile
  /profile/subscription
  /profile/alerts
  /profile/settings
  /profile/education
```

## Screen Specifications

### 1. Today Screen (اليوم)

**Layout**:
- **Header**: EGX30 index card (large, prominent)
  - Index value, change, percentage
  - Mini chart (7-day)
  - Last update time
- **Today's Signals**: Horizontal scrollable list
  - Signal cards (see Signal Card component)
  - "View All" button → Signals screen
- **Quick Stats**: 3-column grid
  - Total signals today
  - Active watchlists
  - Portfolio value (if Pro)

**Empty State**:
- Illustration + message: "لا توجد إشارات اليوم"
- Refresh button

**Loading State**:
- Skeleton loader for index card
- Skeleton loaders for signal cards (3 items)

### 2. Signals Screen (الإشارات)

**Filters** (Top bar):
- Signal type: All / Buy / Sell / Hold
- Confidence: Slider (0-100)
- Risk level: All / Low / Medium / High
- Sort: Newest / Confidence / Risk

**Signal List**:
- Infinite scroll (pagination)
- Signal cards (see Signal Card component)
- Pull-to-refresh

**Empty State**:
- "لم يتم العثور على إشارات"
- Adjust filters message

### 3. Signal Card Component

**Design**:
```
┌─────────────────────────────────────┐
│ COMI  البنك التجاري الدولي          │
│ 68.5 ج.م  +2.35%                    │
│                                     │
│ [Buy Signal]  Confidence: 85%       │
│ Risk: Low                           │
│                                     │
│ ✓ حجم التداول زاد 40%               │
│ ✓ اختراق مقاومة 67.50               │
│ ✓ مؤشرات فنية إيجابية               │
│                                     │
│ ⚠️ تحذيرات                          │
│ • تقلبات السوق قد تؤثر              │
│ • النتائج قد تختلف                  │
│                                     │
│ [View Details] →                    │
└─────────────────────────────────────┘
```

**Elements**:
- Stock symbol & name (Bold, 16sp)
- Current price & change (Primary color if positive, negative if negative)
- Signal type badge (Buy/Sell/Hold) with color coding
- Confidence bar (progress indicator, color-coded)
- Risk level badge (Low/Medium/High) with color
- Why reasons (3 bullets, checkmark icons)
- Caveats (2 bullets, warning icons)
- "View Details" button (primary)

**Animations**:
- Card entrance: Fade in + slide up (300ms)
- Confidence bar: Animated fill (400ms ease-out)
- Haptic feedback on tap

### 4. Signal Details Screen

**Layout**:
- **Header**: Stock symbol, name, price (sticky on scroll)
- **Signal Overview**: Large signal type badge, confidence, risk
- **Why Section**: Expanded 3 reasons with technical details
- **Caveats Section**: Expanded 2 caveats with disclaimers
- **Technical Details**: (Expandable)
  - RSI, MA, MACD values
  - Volume analysis
  - Calculation metadata (for transparency)
- **Actions**:
  - Add to Watchlist
  - Set Alert
  - Share (image/pdf export)
- **Legal Disclaimer** (Bottom):
  - "هذه الإشارة للأغراض التعليمية فقط. ليست توصية استثمارية."

**Animations**:
- Staggered entrance for sections (100ms delay each)
- Expandable sections: Smooth height animation

### 5. Watchlist Screen

**Tabs**:
- Favorites (المفضلة)
- My Lists (قوائمي)

**Favorites Tab**:
- Grid/List toggle
- Stock cards (mini version)
- Empty: "أضف أسهمًا إلى المفضلة"

**My Lists Tab**:
- List of user-created watchlists
- Each shows: Name, item count, last updated
- Create new button (FAB)
- Swipe to delete (with undo)

**Watchlist Detail Screen**:
- Header: Watchlist name (editable)
- Stock list (same as favorites)
- Add items button
- Reorder (drag handle)

### 6. Explore Screen

**Search Bar** (Top):
- RTL text input
- Search by symbol or name
- Voice input (optional)

**Sectors** (Horizontal scroll):
- Banking (البنوك)
- Real Estate (العقارات)
- Construction (المقاولات)
- etc.

**Stock Grid/List**:
- Stock cards (symbol, name, price, change, mini chart)
- Infinite scroll
- Filter by sector

**Funds Tab**:
- Similar layout for mutual funds

### 7. Stock Detail Screen

**Header** (Sticky):
- Stock name, symbol
- Current price, change (large)

**Tabs**:
- Overview (نظرة عامة)
- Chart (رسم بياني)
- Signals (إشارات)
- News (أخبار)

**Overview Tab**:
- Key metrics (Market Cap, P/E, EPS, Dividend)
- Technical indicators (RSI, MA, MACD)
- Sector info

**Chart Tab**:
- Interactive chart (fl_chart or similar)
- Time range: 1D, 1W, 1M, 3M, 1Y, All
- Volume overlay

**Signals Tab**:
- List of all signals for this stock
- Filter by type, date range

**News Tab**:
- Related news items
- Sentiment indicators

### 8. Profile Screen

**User Info Card**:
- Avatar, name, email
- Subscription status badge
- Edit profile button

**Sections**:
- **Subscription** (الاشتراك)
  - Current plan, features, upgrade CTA
  - Trial countdown (if active)
- **Alerts** (التنبيهات)
  - Notification center
  - Settings (quiet hours, types)
- **Settings** (الإعدادات)
  - Language (AR/EN)
  - Theme (Light/Dark/System)
  - Currency (EGP)
  - Notifications
  - Privacy
- **Education** (التعليم)
  - Tutorials, articles, glossary
- **About** (حول)
  - App version, terms, privacy policy

## Components Library

### Buttons

**Primary Button**:
- Background: Primary color
- Text: White, Bold, 16sp
- Padding: 16px horizontal, 12px vertical
- Border radius: 12px
- Height: 48dp
- Shadow: Subtle elevation

**Secondary Button**:
- Background: Transparent
- Border: 1px primary color
- Text: Primary color

**Text Button**:
- Background: Transparent
- Text: Primary color, 16sp

### Input Fields

**Text Field**:
- Background: Surface color
- Border: 1px border color (focused: primary)
- Border radius: 8px
- Padding: 12px
- Label: Above field (Arabic, RTL)
- Helper text: Below field (small, secondary text)

### Cards

**Elevated Card**:
- Background: Surface color
- Border radius: 16px
- Shadow: Subtle (dark mode: glow)
- Padding: 16px

**Outlined Card**:
- Background: Surface color
- Border: 1px divider color
- Border radius: 16px
- Padding: 16px

### Badges

**Signal Badge** (Buy/Sell/Hold):
- Background: Signal color (with opacity)
- Text: White, Bold, 12sp
- Padding: 6px 12px
- Border radius: 16px

**Risk Badge** (Low/Medium/High):
- Background: Risk color (with opacity)
- Text: White, Bold, 12sp
- Padding: 6px 12px
- Border radius: 16px

### Progress Indicators

**Confidence Bar**:
- Background: Surface color (light gray)
- Fill: Confidence color (gradient: low→medium→high)
- Height: 8px
- Border radius: 4px
- Animated fill on load

### Skeleton Loaders

**Placeholder**:
- Shimmer animation
- Background: Surface color
- Border radius: Matches content
- Duration: 1.5s loop

**Card Skeleton**:
- Rectangle with rounded corners
- Shimmer effect

### Empty States

**Illustration**:
- Custom SVG/Lottie animation
- Size: 200x200dp

**Message**:
- Text: Secondary color, 16sp
- Centered

**Action Button**:
- Primary button below message

## Animations

### Transition Animations

**Page Transitions**:
- Slide from right (LTR) or left (RTL)
- Duration: 300ms
- Easing: ease-out

**Modal/Sheet**:
- Slide up from bottom
- Backdrop fade (50% opacity)
- Duration: 250ms

### Micro-interactions

**Button Press**:
- Scale: 0.95 (100ms)
- Haptic feedback (light)

**Card Tap**:
- Scale: 0.98 (100ms)
- Haptic feedback (light)

**Pull to Refresh**:
- Circular progress indicator
- Haptic feedback (medium) on refresh

**Infinite Scroll**:
- Loading indicator at bottom
- Smooth scroll to new items

### Loading States

**Initial Load**:
- Skeleton loaders for all content
- Shimmer animation

**Data Refresh**:
- Subtle indicator at top
- No full-screen blocking

## Accessibility

### Screen Reader Support

- **Semantic Labels**: All interactive elements have Arabic labels
- **Content Descriptions**: Charts, images have descriptive text
- **Headings Hierarchy**: H1 → H2 → H3 for proper navigation

**Example**:
```dart
Semantics(
  label: 'إشارة شراء على سهم البنك التجاري الدولي',
  child: SignalCard(...),
)
```

### Color Contrast

- **Text on Background**: Minimum 4.5:1 ratio (WCAG AA)
- **Interactive Elements**: Minimum 3:1 ratio
- **Not Color-Only**: Information conveyed through color also uses icons/text

### Touch Targets

- **Minimum Size**: 48x48dp (iOS/Android guideline)
- **Spacing**: 8dp minimum between targets

### Font Scaling

- **Support System Font Size**: Respect user's accessibility font scaling
- **Max Scale**: 200% without breaking layout

## Responsive Design

### Breakpoints

- **Mobile**: 320px - 768px (primary target)
- **Tablet**: 768px - 1024px (adjusted layout)

### Layout Adaptations

- **Grid Columns**: 2 columns (mobile), 3-4 columns (tablet)
- **Card Sizes**: Responsive width with max-width constraints
- **Typography**: Scales slightly on larger screens

## RTL Support

### Layout Direction

```dart
MaterialApp(
  locale: Locale('ar'),
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [Locale('ar')],
)
```

### Icon Mirroring

- **Directional Icons**: Automatically mirrored (chevron-left → chevron-right in RTL)
- **Charts**: X-axis labels RTL-aligned
- **Navigation**: Back button on right side

### Text Alignment

- **Arabic Text**: Right-aligned
- **Numbers**: Left-aligned within Arabic text (standard Arabic typography)
- **Mixed Content**: Proper RTL/LTR isolation

## Dark Theme Implementation

### System Preference

```dart
ThemeMode systemBrightness = MediaQuery.of(context).platformBrightness == Brightness.dark
  ? ThemeMode.dark
  : ThemeMode.light;
```

### Color Adaptation

- All colors defined for both themes
- Automatic switching based on system/user preference
- Smooth transition animation (300ms)

## Performance Guidelines

### Rendering Performance

- **60 FPS Target**: All animations must maintain 60fps
- **Lazy Loading**: Images loaded on-demand
- **List Optimization**: `ListView.builder` for long lists (not `ListView`)

### Memory Management

- **Image Caching**: Cached network images (flutter_cache_manager)
- **Dispose Controllers**: Proper disposal of AnimationControllers, StreamControllers

### Network Optimization

- **Pagination**: Load data in chunks (20-50 items per page)
- **Caching**: Cache market data for 1-5 minutes
- **Retry Logic**: Automatic retry on network failures (3 attempts)

## Legal & Disclaimer UI

### Required Disclaimers

**Signal Cards** (always visible):
- Small text below signal: "للأغراض التعليمية فقط. ليست توصية استثمارية."

**Signal Details Screen** (prominent):
- Full disclaimer section at bottom:
  - "جميع الإشارات والتحليلات المقدمة هي لأغراض تعليمية وإعلامية فقط."
  - "لا تشكل توصية شراء أو بيع."
  - "يُرجى استشارة مستشار مالي مرخص قبل اتخاذ أي قرارات استثمارية."

**Subscription Screen**:
- "جميع الأسعار بالجنيه المصري."
- "الاشتراكات قابلة للإلغاء في أي وقت."

## Brand Guidelines

### Logo Usage

- **App Icon**: 1024x1024px (iOS), various densities (Android)
- **Primary Logo**: Full-color version (light backgrounds)
- **Monochrome Logo**: Single color version (dark backgrounds)

### Voice & Tone

- **Professional**: Clear, factual language
- **Reassuring**: Avoid alarmist language
- **Educational**: Explain concepts simply
- **Respectful**: Never pressure users to subscribe

## Implementation Notes

### Flutter Packages

```yaml
dependencies:
  flutter_localizations:
  intl: # Date/number formatting
  fl_chart: # Charts
  cached_network_image: # Image caching
  shimmer: # Skeleton loaders
  lottie: # Animations (optional)
  flutter_svg: # SVG icons
  google_fonts: # Font loading (if needed)
```

### State Management (Riverpod)

- **Providers**: Separate providers for each feature (signals, watchlists, subscription)
- **Auto-dispose**: Use `autoDispose` for UI-specific state
- **Persistence**: Combine with `flutter_secure_storage` for auth tokens

### Theme Configuration

```dart
class VistaTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Alexandria',
    colorScheme: ColorScheme.light(
      primary: VistaLightColors.primary,
      // ... other colors
    ),
    // ... other theme config
  );
  
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Alexandria',
    colorScheme: ColorScheme.dark(
      primary: VistaDarkColors.primary,
      // ... other colors
    ),
    // ... other theme config
  );
}
```
