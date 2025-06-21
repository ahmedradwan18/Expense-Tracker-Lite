import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/constants/app_constants.dart';
import '../bloc/add_expense_bloc.dart';
import '../bloc/add_expense_event.dart';
import '../bloc/add_expense_state.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedCategory = 'Entertainment';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;
  
  // Keep track of last conversion to avoid losing state
  double? _lastConvertedAmount;
  String? _lastFromCurrency;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late List<AnimationController> _fieldControllers;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Groceries', 'icon': '🛒', 'color': Color(0xFF6C7CE7)},
    {'name': 'Entertainment', 'icon': '🎬', 'color': Color(0xFF5D67FF)},
    {'name': 'Gas', 'icon': '⛽', 'color': Color(0xFFFF6B6B)},
    {'name': 'Shopping', 'icon': '🛍️', 'color': Color(0xFFFFD93D)},
    {'name': 'News Paper', 'icon': '📰', 'color': Color(0xFFFFB347)},
    {'name': 'Transport', 'icon': '🚗', 'color': Color(0xFF74C0FC)},
    {'name': 'Rent', 'icon': '🏠', 'color': Color(0xFFFFB347)},
    {'name': 'Add Category', 'icon': '+', 'color': Color(0xFFE9ECEF)},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    
    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize field controllers
    _fieldControllers = List.generate(5, (index) => AnimationController(
      duration: Duration(milliseconds: 400 + (index * 100)),
      vsync: this,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
    
    // Stagger form field animations
    for (int i = 0; i < _fieldControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 150)), () {
        if (mounted) {
          _fieldControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    for (final controller in _fieldControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onAmountChanged() {
    if (_selectedCurrency != 'USD' && _amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null && amount > 0) {
        if (amount != _lastConvertedAmount || _selectedCurrency != _lastFromCurrency) {
          _lastConvertedAmount = amount;
          _lastFromCurrency = _selectedCurrency;
          
          context.read<AddExpenseBloc>().add(ConvertCurrency(
            amount: amount,
            fromCurrency: _selectedCurrency,
            toCurrency: 'USD',
          ));
        }
      }
    } else {
      _lastConvertedAmount = null;
      _lastFromCurrency = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: FadeTransition(
          opacity: _fadeController,
          child: Text(
            'Add Expense',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AddExpenseBloc, AddExpenseState>(
        listener: (context, state) {
          if (state is AddExpenseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expense saved successfully!'),
                backgroundColor: Color(AppConstants.successColor),
              ),
            );
            context.pop();
          } else if (state is AddExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Color(AppConstants.errorColor),
              ),
            );
          }
        },
        builder: (context, state) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: _fadeController,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAnimatedField(0, () => _buildCategoryDropdown()),
                            SizedBox(height: 28.h),
                            _buildAnimatedField(1, () => _buildAmountSection(state)),
                            SizedBox(height: 28.h),
                            _buildAnimatedField(2, () => _buildDateSection()),
                            SizedBox(height: 28.h),
                            _buildAnimatedField(3, () => _buildReceiptSection()),
                            SizedBox(height: 28.h),
                            _buildAnimatedField(4, () => _buildCategoriesGrid()),
                          ],
                        ),
                      ),
                    ),
                    _buildAnimatedSaveButton(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedField(int index, Widget Function() builder) {
    if (index >= _fieldControllers.length) return builder();
    
    return AnimatedBuilder(
      animation: _fieldControllers[index],
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _fieldControllers[index],
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _fieldControllers[index],
            child: builder(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:  Color(AppConstants.textFieldBackgroundColor),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            items: _categories.where((cat) => cat['name'] != 'Add Category').map((category) {
              return DropdownMenuItem<String>(
                value: category['name'],
                child: Text(category['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(AddExpenseState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w,  ),
                decoration: BoxDecoration(
                  color:  Color(AppConstants.textFieldBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: '50,000',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w,  ),
                decoration: BoxDecoration(
                  color: Color(AppConstants.textFieldBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20.sp),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  items: ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'].map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCurrency = newValue;
                        // Reset conversion cache when currency changes
                        _lastConvertedAmount = null;
                        _lastFromCurrency = null;
                      });
                      // Trigger conversion if amount exists
                      if (_amountController.text.isNotEmpty) {
                        _onAmountChanged();
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        // Show live currency conversion from BLoC state
        if (_selectedCurrency != 'USD')
          Builder(
            builder: (context) {
              if (state is CurrencyConversionLoaded) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Color(AppConstants.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 3.14159,
                            child: Icon(
                              Icons.swap_horiz,
                              size: 16.sp,
                              color: Color(AppConstants.primaryColor),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Equivalent: \$${state.convertedAmount.toStringAsFixed(2)} USD (Rate: ${(state.convertedAmount / double.parse(_amountController.text.isEmpty ? '1' : _amountController.text)).toStringAsFixed(4)})',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(AppConstants.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is CurrencyConversionLoading) {
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(AppConstants.primaryColor),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Converting currency...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(AppConstants.textSecondaryColor),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Color(AppConstants.textFieldBackgroundColor),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MM/dd/yy').format(_selectedDate),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Receipt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (_receiptImage != null) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Color(AppConstants.textFieldBackgroundColor),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _receiptImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showImageSourceDialog(),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _receiptImage = null;
                    });
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          GestureDetector(
            onTap: () => _showImageSourceDialog(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              decoration: BoxDecoration(
                color: Color(AppConstants.textFieldBackgroundColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Receipt',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Take a photo or choose from gallery',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['name'];
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: GestureDetector(
                    onTap: () {
                      if (category['name'] == 'Add Category') {
                        // TODO: Handle add category
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add Category feature coming soon!')),
                        );
                      } else {
                        setState(() {
                          _selectedCategory = category['name'];
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: category['name'] == 'Add Category' 
                                  ? Colors.grey.shade200
                                  : isSelected 
                                      ? category['color']
                                      : category['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: category['name'] == 'Add Category' 
                                  ? Border.all(color: Colors.grey.shade400, style: BorderStyle.solid)
                                  : null,
                            ),
                            child: Center(
                              child: category['name'] == 'Add Category'
                                  ? Icon(
                                      Icons.add,
                                      color: Colors.grey.shade600,
                                      size: 24,
                                    )
                                  : Text(
                                      category['icon'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedSaveButton(AddExpenseState state) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_buttonController.value * 0.05),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: state is AddExpenseLoading ? null : () {
                _buttonController.forward().then((_) {
                  _buttonController.reverse();
                });
                _saveExpense();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: state is AddExpenseLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickReceipt(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickReceipt(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  void _pickReceipt(ImageSource source) {
    setState(() {
      _receiptImage = null;
    });
    
    _picker.pickImage(source: source).then((image) {
      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
        });
      }
    });
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    context.read<AddExpenseBloc>().add(SubmitExpenseForm(
      category: _selectedCategory,
      amount: amount,
      currency: _selectedCurrency,
      date: _selectedDate,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      receiptImage: _receiptImage,
    ));
  }
} 