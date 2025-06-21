import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/export_utils.dart';
import '../../domain/entities/expense.dart';

class ExpensesHeader extends StatelessWidget {
  final VoidCallback? onSeeAllPressed;
  final List<Expense>? expenses;

  const ExpensesHeader({
    super.key,
    this.onSeeAllPressed,
    this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Expenses',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.textPrimaryColor),
          ),
        ),
        Row(
          children: [
            if (expenses != null && expenses!.isNotEmpty) ...[
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.download,
                  color: Color(AppConstants.primaryColor),
                  size: 20.sp,
                ),
                onSelected: (value) => _handleExport(context, value),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('Export CSV', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('Export PDF', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8.w),
            ],
            TextButton(
              onPressed: onSeeAllPressed ?? () {
                // TODO: Navigate to all expenses
              },
              child: Text(
                'see all',
                style: TextStyle(
                  color: Color(AppConstants.textSecondaryColor),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleExport(BuildContext context, String exportType) async {
    if (expenses == null || expenses!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(AppConstants.primaryColor),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Exporting ${exportType.toUpperCase()}...',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      String filePath;
      String fileName;

      if (exportType == 'csv') {
        filePath = await ExportUtils.exportToCSV(expenses!);
        fileName = 'expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
      } else {
        filePath = await ExportUtils.exportToPDF(expenses!);
        fileName = 'expenses_${DateTime.now().millisecondsSinceEpoch}.pdf';
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Share the file
      await ExportUtils.shareFile(filePath, fileName);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exportType.toUpperCase()} exported successfully!'),
          backgroundColor: Color(AppConstants.successColor),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export ${exportType.toUpperCase()}: $e'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
    }
  }
} 