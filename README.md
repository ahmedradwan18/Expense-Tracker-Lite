# 💰 Expense Tracker App

[![Flutter CI](https://github.com/yourusername/expense-tracker/actions/workflows/flutter.yml/badge.svg)](https://github.com/yourusername/expense-tracker/actions/workflows/flutter.yml)
[![PR Check](https://github.com/yourusername/expense-tracker/actions/workflows/pr-check.yml/badge.svg)](https://github.com/yourusername/expense-tracker/actions/workflows/pr-check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern Flutter expense tracking application built with Clean Architecture, BLoC state management, and real-time currency conversion. Features a beautiful animated UI with comprehensive expense management capabilities.

## 📱 Screenshots & Features

- **Dashboard**: Beautiful gradient header with animated balance cards and expense filtering
- **Add Expense**: Multi-currency support with real-time conversion and category selection
- **Responsive Design**: Optimized for different screen sizes using flutter_screenutil
- **Smooth Animations**: Custom animated transitions throughout the app
- **Data Export**: CSV and PDF export functionality for expense reports

## 🏗️ Architecture & Structure

### Clean Architecture Implementation

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                           # Core utilities and constants
│   ├── constants/                  # App constants and colors
│   ├── error/                      # Error handling
│   └── utils/                      # Utility functions
├── features/                       # Feature modules
│   ├── dashboard/                  # Dashboard feature
│   │   ├── data/                   # Data layer
│   │   │   ├── datasources/        # Local data sources (Hive)
│   │   │   ├── models/             # Data models
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/                 # Domain layer
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Business logic
│   │   └── presentation/           # Presentation layer
│   │       ├── bloc/               # BLoC state management
│   │       ├── pages/              # UI pages
│   │       └── widgets/            # Reusable widgets
│   └── add_expense/                # Add expense feature
│       ├── data/                   # Currency conversion data layer
│       ├── domain/                 # Currency conversion domain
│       └── presentation/           # Add expense UI and BLoC
└── main.dart                       # App entry point
```

### Key Architecture Benefits

- **Separation of Concerns**: Each layer has distinct responsibilities
- **Testability**: Easy to unit test business logic in isolation
- **Maintainability**: Clear structure makes code easy to modify
- **Scalability**: New features can be added without affecting existing code
- **Dependency Inversion**: High-level modules don't depend on low-level modules

## 🔄 State Management Approach

### BLoC Pattern Implementation

The app uses **BLoC (Business Logic Component)** pattern for state management:

#### Dashboard BLoC
```dart
// Events
- LoadDashboardData: Initial data loading
- RefreshDashboardData: Refresh after adding expenses
- ChangeFilterSelection: Filter by date range
- LoadMoreExpenses: Pagination support

// States  
- DashboardInitial: Initial state
- DashboardLoading: Loading indicator
- DashboardLoaded: Data loaded with expenses and totals
- DashboardError: Error handling
```

#### Add Expense BLoC
```dart
// Events
- ConvertCurrency: Real-time currency conversion
- SubmitExpenseForm: Save expense to database
- SelectCategory: Update selected category
- UpdateAmount: Update expense amount

// States
- AddExpenseInitial: Initial form state
- CurrencyConverting: API call in progress
- CurrencyConverted: Conversion completed
- ExpenseSubmitting: Saving expense
- ExpenseSubmitted: Successfully saved
- AddExpenseError: Error handling
```

### State Management Benefits

- **Reactive UI**: UI automatically updates when state changes
- **Predictable State**: Clear state transitions and event handling
- **Separation**: Business logic separated from UI components
- **Testing**: Easy to test state changes and business logic
- **Debugging**: Clear event/state flow for debugging

## 🌐 API Integration

### Currency Conversion API

**API Provider**: ExchangeRate-API.com  
**Endpoint**: `https://v6.exchangerate-api.com/v6/{API_KEY}/latest/{BASE_CURRENCY}`  
**API Key**: `d95ebc36408cda68deeef2ed`

#### Implementation Details

```dart
class CurrencyRemoteDataSource {
  final http.Client client;
  
  Future<ExchangeRateModel> getExchangeRates(String baseCurrency) async {
    final response = await client.get(
      Uri.parse('$baseUrl/$apiKey/latest/$baseCurrency'),
    );
    
    if (response.statusCode == 200) {
      return ExchangeRateModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
```

#### API Integration Features

- **Real-time Conversion**: Live currency rates as user types
- **Error Handling**: Graceful fallbacks for API failures
- **Loading States**: Visual feedback during API calls
- **Rate Display**: Shows actual conversion rates to users
- **Caching**: Efficient API usage with response caching

#### Supported Currencies
- USD (US Dollar)
- EUR (Euro)
- GBP (British Pound)
- JPY (Japanese Yen)
- CAD (Canadian Dollar)
- AUD (Australian Dollar)

## 📄 Pagination Strategy

### Local Database Pagination

The app implements **local pagination** using Hive database:

#### Implementation Approach
```dart
Future<List<ExpenseModel>> getExpenses({
  int page = 0,
  int limit = 10,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final box = await Hive.openBox<ExpenseModel>('expenses');
  var expenses = box.values.toList();
  
  // Apply date filtering
  if (startDate != null && endDate != null) {
    expenses = expenses.where((expense) {
      return expense.date.isAfter(startDate.subtract(Duration(days: 1))) &&
             expense.date.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }
  
  // Sort by date (newest first)
  expenses.sort((a, b) => b.date.compareTo(a.date));
  
  // Apply pagination
  final startIndex = page * limit;
  final endIndex = math.min(startIndex + limit, expenses.length);
  
  return expenses.sublist(startIndex, endIndex);
}
```

#### Pagination Benefits

- **Performance**: Only loads necessary data chunks
- **Memory Efficient**: Prevents loading large datasets at once
- **Smooth Scrolling**: Lazy loading as user scrolls
- **Filter Support**: Pagination works with date filtering
- **Offline Support**: No API dependency for pagination

#### Why Local vs API Pagination?

**Local Pagination Chosen Because:**
- ✅ Faster response times (no network latency)
- ✅ Offline functionality
- ✅ Simpler implementation for expense data
- ✅ Better user experience with instant filtering
- ✅ No API rate limiting concerns

**API Pagination Trade-offs:**
- ❌ Would require server-side expense storage
- ❌ Network dependency for basic operations
- ❌ More complex error handling
- ❌ Higher latency for user interactions

## 🎯 Bonus Points Implemented

### 1. ✨ Animated Transitions

**Comprehensive Animation System:**

- **Dashboard Animations**:
  - Staggered fade-in for header elements
  - Slide animations for balance cards
  - Scale animations for expense items
  - Smooth transitions between states

- **Add Expense Animations**:
  - Form field animations
  - Category selection animations
  - Loading state animations
  - Success feedback animations

- **Navigation Animations**:
  - Page transition animations
  - Bottom navigation animations
  - Floating action button animations

**Implementation Examples:**
```dart
// Staggered animations
AnimationController _slideController;
AnimationController _fadeController;

// Custom animated widgets
AnimatedCounter(value: totalBalance, duration: Duration(milliseconds: 1200))
SlideTransition(position: _slideAnimation, child: BalanceCard())
FadeTransition(opacity: _fadeAnimation, child: ExpensesList())
```

### 2. 📊 CSV and PDF Export

**Export Functionality:**

- **CSV Export**: Complete expense data with all fields
- **PDF Export**: Formatted expense reports with totals
- **Filter Support**: Export filtered data based on date ranges
- **File Sharing**: Native sharing integration

**Implementation:**
```dart
// CSV Export
String generateCSV(List<Expense> expenses) {
  return expenses.map((expense) => 
    '${expense.category},${expense.amount},${expense.date},${expense.description}'
  ).join('\n');
}

// PDF Export  
Future<void> generatePDF(List<Expense> expenses) async {
  final pdf = pw.Document();
  pdf.addPage(/* PDF content with expense table */);
  await Printing.sharePdf(bytes: await pdf.save());
}
```

### 3. 🚀 CI/CD with GitHub Actions

**Essential CI/CD Pipeline:**

#### Main Workflow (`.github/workflows/flutter.yml`)
```yaml
name: Flutter CI

jobs:
  test:    # Code analysis and unit tests
  build:   # Android APK build and artifact upload
```

#### PR Validation (`.github/workflows/pr-check.yml`)
```yaml
name: PR Check

# Fast validation for pull requests
- Code formatting checks
- Static analysis  
- Unit test execution
- Build verification
```

**CI/CD Features:**
- ✅ **Automated testing**: Unit tests and widget tests
- ✅ **Code quality**: Static analysis and formatting checks
- ✅ **Android builds**: Release APK generation
- ✅ **PR validation**: Fast feedback on pull requests
- ✅ **Artifact storage**: Build artifacts uploaded
- ✅ **Branch protection**: Required status checks

**Workflow Triggers:**
- **Push to main/develop**: Full CI pipeline
- **Pull requests**: Validation and testing

## ⚖️ Trade-offs & Assumptions

### Technical Trade-offs

1. **Local vs Cloud Storage**
   - **Chosen**: Hive (local storage)
   - **Trade-off**: No data sync across devices
   - **Benefit**: Offline functionality, faster performance

2. **State Management**
   - **Chosen**: BLoC pattern
   - **Trade-off**: More boilerplate code
   - **Benefit**: Better testability, clear separation

3. **API Integration**
   - **Chosen**: Direct HTTP calls with error handling
   - **Trade-off**: No sophisticated caching strategy
   - **Benefit**: Simpler implementation, real-time rates

4. **UI Framework**
   - **Chosen**: Custom animated widgets
   - **Trade-off**: More development time
   - **Benefit**: Unique user experience, better performance

### Assumptions Made

1. **User Behavior**:
   - Users primarily track personal expenses
   - Most expenses are in major currencies
   - Users want visual feedback for actions

2. **Data Requirements**:
   - Expense data doesn't need cloud backup
   - Currency rates updated in real-time acceptable
   - Limited expense categories sufficient

3. **Performance**:
   - Local database adequate for personal use
   - Pagination with 10 items per page optimal
   - Animation performance acceptable on mid-range devices

4. **Platform**:
   - Primary target is mobile devices
   - Android and iOS feature parity required
   - Offline functionality essential

## 🧪 Testing Strategy

### Current Tests Implemented

#### Widget Tests (`test/widget_test.dart`)
**Basic App Tests:**
```dart
// App initialization tests
testWidgets('App should build without crashing')
testWidgets('Dashboard should be the initial route')

// UI Component Tests
testWidgets('FloatingActionButton should be present')
testWidgets('Tapping FAB should navigate to add expense')
```

**Test Coverage:**
- ✅ **App initialization**: Verifies app builds without errors
- ✅ **Basic navigation**: Tests dashboard loading and FAB navigation
- ✅ **Widget presence**: Confirms essential UI components exist

#### Tests Structure
```
test/
├── widget_test.dart          # Basic widget tests (implemented)
└── features/
    └── add_expense/
        └── domain/           # Domain tests (structure exists)
```

### Planned Testing Strategy

**Unit Testing Areas:**
- Business logic in use cases
- Data models and serialization  
- Repository implementations
- BLoC state management

**Widget Testing Areas:**
- Form validation in AddExpenseForm
- Filter functionality in Dashboard
- Animation behavior
- Navigation flows

**Integration Testing:**
- Add expense flow end-to-end
- Currency conversion with API
- Filter and pagination functionality

### Test Execution

**Local Testing:**
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test file
```

**CI/CD Testing:**
- Automated test execution on every push and PR
- Build verification after tests pass
- Code analysis alongside testing

## 🐛 Known Issues & Limitations

### Current Bugs

1. **Animation Performance**
   - **Issue**: Occasional frame drops on older devices during complex animations
   - **Workaround**: Reduced animation complexity for low-end devices
   - **Status**: Investigating optimization strategies

2. **Currency API Rate Limiting**
   - **Issue**: API may rate limit with excessive requests
   - **Workaround**: Debounced API calls and caching
   - **Status**: Monitoring usage patterns

### Unimplemented Features

1. **Advanced Features**:
   - [ ] Expense categories customization
   - [ ] Budget tracking and alerts
   - [ ] Recurring expense templates
   - [ ] Multi-user support with authentication

2. **Data Features**:
   - [ ] Cloud synchronization
   - [ ] Data backup and restore
   - [ ] Advanced analytics and insights
   - [ ] Expense photo attachments

3. **UI Enhancements**:
   - [ ] Dark mode theme
   - [ ] Accessibility improvements
   - [ ] Tablet-optimized layouts
   - [ ] Advanced filtering options

4. **Export Features**:
   - [ ] Excel export format
   - [ ] Email integration for reports
   - [ ] Scheduled report generation
   - [ ] Custom report templates

### Technical Debt

1. **Code Quality**:
   - Some widget files could be further modularized
   - API error handling could be more granular
   - Test coverage could be improved in data layer

2. **Performance**:
   - Large datasets might impact scroll performance
   - Animation memory usage optimization needed
   - API response caching strategy needs refinement

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/expense-tracker.git
   cd expense-tracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Build Commands

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# iOS build
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc: ^8.1.6` - State management
- `hive: ^2.2.3` - Local database
- `go_router: ^14.2.7` - Navigation
- `flutter_screenutil: ^5.9.3` - Responsive design
- `http: ^1.1.0` - API integration

### UI Dependencies
- `intl: ^0.18.1` - Internationalization
- `pdf: ^3.10.7` - PDF generation
- `printing: ^5.11.1` - PDF sharing
- `csv: ^5.1.1` - CSV export
- `share_plus: ^7.2.2` - File sharing

### Development Dependencies
- `bloc_test: ^9.1.7` - BLoC testing
- `mocktail: ^1.0.3` - Mocking
- `build_runner: ^2.5.2` - Code generation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ahmed Radwan**
- Email: ahmed.radwan@example.com
- GitHub: [@ahmedradwan](https://github.com/ahmedradwan)
- LinkedIn: [Ahmed Radwan](https://linkedin.com/in/ahmedradwan)

---

**Built with ❤️ using Flutter** 