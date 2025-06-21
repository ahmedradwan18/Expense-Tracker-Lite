# 💰 Expense Tracker App

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

**Automated Workflow:**

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
      
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

**CI/CD Features:**
- ✅ Automated testing on every push
- ✅ Code analysis and linting
- ✅ Automated builds for releases
- ✅ Artifact generation and storage
- ✅ Branch protection with required checks

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

### Unit Testing

**Coverage Areas:**
- Business logic in use cases
- Data models and serialization
- Repository implementations
- BLoC state management

**Example Tests:**
```dart
// Use case testing
test('should return expenses when repository call is successful', () async {
  // arrange
  when(mockRepository.getExpenses()).thenAnswer((_) async => tExpenseList);
  
  // act
  final result = await usecase(NoParams());
  
  // assert
  expect(result, Right(tExpenseList));
});

// BLoC testing
blocTest<DashboardBloc, DashboardState>(
  'emits [DashboardLoading, DashboardLoaded] when LoadDashboardData is added',
  build: () => dashboardBloc,
  act: (bloc) => bloc.add(LoadDashboardData()),
  expect: () => [DashboardLoading(), DashboardLoaded(expenses: tExpenseList)],
);
```

### Widget Testing

**UI Component Tests:**
- Form validation in AddExpenseForm
- Filter functionality in Dashboard
- Animation behavior
- Navigation flows

**Example Widget Tests:**
```dart
testWidgets('should display expense list when data is loaded', (tester) async {
  // arrange
  when(mockBloc.state).thenReturn(DashboardLoaded(expenses: tExpenseList));
  
  // act
  await tester.pumpWidget(makeTestableWidget(DashboardPage()));
  
  // assert
  expect(find.byType(ExpenseCard), findsNWidgets(tExpenseList.length));
});
```

### Integration Testing

**End-to-End Scenarios:**
- Add expense flow from dashboard to save
- Currency conversion with API integration
- Filter and pagination functionality
- Export functionality

### Test Coverage Goals

- **Unit Tests**: 80%+ coverage for business logic
- **Widget Tests**: All major UI components
- **Integration Tests**: Critical user flows
- **BLoC Tests**: All state transitions

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