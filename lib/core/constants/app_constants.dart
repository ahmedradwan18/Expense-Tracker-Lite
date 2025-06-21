class AppConstants {
  // Colors
  static const primaryColor = 0xFF5D67FF;
  static const darkBlueColor = 0xFF0B57D0;
  static const lightBlueColor = 0xFF466EF0;
  static const secondaryColor = 0xFF4A90E2;
  static const backgroundColor = 0xFFF8F9FA;
  static const cardColor = 0xFFFFFFFF;
  static const textPrimaryColor = 0xFF2D3436;
  static const textSecondaryColor = 0xFF8E8E93;
  static const successColor = 0xFF00B894;
  static const errorColor = 0xFFE74C3C;
  static const incomeColor = 0xFF00B894;
  static const expenseColor = 0xFFE74C3C;
  static const textFieldBackgroundColor = 0xFFF0F5F9;

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  
  // Pagination
  static const int itemsPerPage = 10;
  
  // Currency API
  static const String currencyApiKey = 'd95ebc36408cda68deeef2ed';
  static const String currencyApiUrl = 'https://v6.exchangerate-api.com/v6/$currencyApiKey/latest/USD';
  static const String baseCurrency = 'USD';
  
  // Hive Boxes
  static const String expenseBoxName = 'expenses';
  static const String currencyBoxName = 'currencies';
  static const String settingsBoxName = 'settings';
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  
  // Categories
  static const List<String> expenseCategories = [
    'Groceries',
    'Entertainment',
    'Gas',
    'Shopping',
    'News Paper',
    'Transport',
    'Rent',
    'Food',
    'Health',
    'Education',
    'Others'
  ];
  
  // Category Icons
  static const Map<String, String> categoryIcons = {
    'Groceries': '🛒',
    'Entertainment': '🎬',
    'Gas': '⛽',
    'Shopping': '🛍️',
    'News Paper': '📰',
    'Transport': '🚗',
    'Rent': '🏠',
    'Food': '🍔',
    'Health': '🏥',
    'Education': '📚',
    'Others': '💰'
  };
  
  // Currencies
  static const List<String> supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'BRL'
  ];
} 