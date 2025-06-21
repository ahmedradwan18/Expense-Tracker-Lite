import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/dashboard/domain/entities/expense.dart';

class ExportUtils {
  static Future<String> exportToCSV(List<Expense> expenses) async {
    // Create CSV data
    List<List<dynamic>> csvData = [
      ['Date', 'Category', 'Amount (USD)', 'Currency', 'Description'],
    ];

    for (var expense in expenses) {
      csvData.add([
        DateFormat('yyyy-MM-dd HH:mm').format(expense.date),
        expense.category,
        expense.amount.toStringAsFixed(2),
        expense.currency ?? 'USD',
        expense.description ?? '',
      ]);
    }

    // Convert to CSV string
    String csvString = const ListToCsvConverter().convert(csvData);

    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv');

    // Write CSV file
    await file.writeAsString(csvString);

    return file.path;
  }

  static Future<String> exportToPDF(List<Expense> expenses) async {
    final pdf = pw.Document();

    // Calculate totals
    double totalAmount = expenses.fold(0, (sum, expense) => sum + expense.amount);
    Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Expenses: \$${totalAmount.toStringAsFixed(2)}'),
                  pw.Text('Number of Transactions: ${expenses.length}'),
                  pw.Text('Date Range: ${_getDateRange(expenses)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Category Breakdown
            pw.Text(
              'Category Breakdown',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Percentage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...categoryTotals.entries.map(
                  (entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$${entry.value.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${((entry.value / totalAmount) * 100).toStringAsFixed(1)}%'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Detailed Transactions
            pw.Text(
              'Detailed Transactions',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...expenses.map(
                  (expense) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(DateFormat('MM/dd/yy').format(expense.date)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(expense.category),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$${expense.amount.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(expense.description ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.pdf');

    // Write PDF file
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static Future<void> shareFile(String filePath, String fileName) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Here is your expense report: $fileName',
    );
  }

  static String _getDateRange(List<Expense> expenses) {
    if (expenses.isEmpty) return 'No expenses';
    
    expenses.sort((a, b) => a.date.compareTo(b.date));
    final startDate = DateFormat('MM/dd/yy').format(expenses.first.date);
    final endDate = DateFormat('MM/dd/yy').format(expenses.last.date);
    
    return '$startDate - $endDate';
  }
} 