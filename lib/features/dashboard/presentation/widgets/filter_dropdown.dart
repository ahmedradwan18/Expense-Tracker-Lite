import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class FilterDropdown extends StatelessWidget {
  final DashboardState state;

  const FilterDropdown({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    String currentFilter = 'This month';
    if (state is DashboardLoaded) {
      currentFilter = (state as DashboardLoaded).selectedFilter;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w,),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButton<String>(
        value: currentFilter,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20.sp),
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        items: ['This month', 'Last 7 Days', 'All'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black, fontSize: 14.sp),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            context.read<DashboardBloc>().add(ChangeFilterSelection(newValue));
          }
        },
      ),
    );
  }
} 