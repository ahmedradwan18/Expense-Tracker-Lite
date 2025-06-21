import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class FilterChips extends StatefulWidget {
  final Function(String) onFilterSelected;

  const FilterChips({
    super.key,
    required this.onFilterSelected,
  });

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  String selectedFilter = 'All';
  
  final List<String> filters = [
    'All',
    'This Month',
    'Last 7 Days',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
                widget.onFilterSelected(filter);
              },
              backgroundColor: Color(AppConstants.cardColor),
              selectedColor: Color(AppConstants.primaryColor).withOpacity(0.1),
              checkmarkColor: Color(AppConstants.primaryColor),
              labelStyle: TextStyle(
                color: isSelected 
                    ? Color(AppConstants.primaryColor)
                    : Color(AppConstants.textSecondaryColor),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? Color(AppConstants.primaryColor)
                      : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 