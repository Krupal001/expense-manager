// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import '../../../domain/entities/expense.dart';

// class PDFGenerator {
//   static Future<void> generateAndPrintPDF(
//     BuildContext context,
//     List<Expense> expenses,
//     double totalIncome,
//     double totalExpense,
//     double balance,
//     String filterType,
//     DateTimeRange? dateRange,
//   ) async {
//     final pdf = pw.Document();

//     // Calculate category totals
//     final categoryTotals = <String, double>{};
//     for (var expense in expenses.where((e) => e.type == ExpenseType.debit)) {
//       categoryTotals[expense.category] =
//           (categoryTotals[expense.category] ?? 0) + expense.amount;
//     }

//     final sortedCategories = categoryTotals.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) => [
//           // Header
//           pw.Container(
//             padding: const pw.EdgeInsets.all(20),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.purple,
//               borderRadius: pw.BorderRadius.circular(10),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'Expense Report',
//                   style: pw.TextStyle(
//                     fontSize: 28,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.white,
//                   ),
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Text(
//                   filterType == 'Custom' && dateRange != null
//                       ? '${DateFormat('MMM dd, yyyy').format(dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(dateRange.end)}'
//                       : filterType,
//                   style: const pw.TextStyle(
//                     fontSize: 14,
//                     color: PdfColors.white,
//                   ),
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Text(
//                   'Generated on ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
//                   style: const pw.TextStyle(
//                     fontSize: 12,
//                     color: PdfColors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 24),

//           // Summary Cards
//           pw.Row(
//             children: [
//               pw.Expanded(
//                 child: _buildPDFSummaryCard(
//                   'Total Income',
//                   '₹${totalIncome.toStringAsFixed(2)}',
//                   PdfColors.green,
//                 ),
//               ),
//               pw.SizedBox(width: 16),
//               pw.Expanded(
//                 child: _buildPDFSummaryCard(
//                   'Total Expenses',
//                   '₹${totalExpense.toStringAsFixed(2)}',
//                   PdfColors.red,
//                 ),
//               ),
//               pw.SizedBox(width: 16),
//               pw.Expanded(
//                 child: _buildPDFSummaryCard(
//                   'Balance',
//                   '₹${balance.toStringAsFixed(2)}',
//                   balance >= 0 ? PdfColors.blue : PdfColors.orange,
//                 ),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 24),

//           // Category Breakdown
//           if (categoryTotals.isNotEmpty) ...[
//             pw.Text(
//               'Category Breakdown',
//               style: pw.TextStyle(
//                 fontSize: 20,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//             pw.SizedBox(height: 16),
//             pw.Table(
//               border: pw.TableBorder.all(color: PdfColors.grey300),
//               children: [
//                 // Header
//                 pw.TableRow(
//                   decoration: const pw.BoxDecoration(
//                     color: PdfColors.grey200,
//                   ),
//                   children: [
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         'Category',
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         'Amount',
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         textAlign: pw.TextAlign.right,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         'Percentage',
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         textAlign: pw.TextAlign.right,
//                       ),
//                     ),
//                   ],
//                 ),
//                 // Data rows
//                 ...sortedCategories.map((entry) {
//                   final percentage =
//                       (entry.value / totalExpense * 100).toStringAsFixed(1);
//                   return pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(entry.key),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           '₹${entry.value.toStringAsFixed(2)}',
//                           textAlign: pw.TextAlign.right,
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           '$percentage%',
//                           textAlign: pw.TextAlign.right,
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//             pw.SizedBox(height: 24),
//           ],

//           // Transaction List
//           pw.Text(
//             'All Transactions (${expenses.length})',
//             style: pw.TextStyle(
//               fontSize: 20,
//               fontWeight: pw.FontWeight.bold,
//             ),
//           ),
//           pw.SizedBox(height: 16),
//           pw.Table(
//             border: pw.TableBorder.all(color: PdfColors.grey300),
//             columnWidths: {
//               0: const pw.FlexColumnWidth(2),
//               1: const pw.FlexColumnWidth(1.5),
//               2: const pw.FlexColumnWidth(1),
//               3: const pw.FlexColumnWidth(1),
//               4: const pw.FlexColumnWidth(1.5),
//             },
//             children: [
//               // Header
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(
//                   color: PdfColors.grey200,
//                 ),
//                 children: [
//                   _buildTableHeader('Title'),
//                   _buildTableHeader('Category'),
//                   _buildTableHeader('Type'),
//                   _buildTableHeader('Date'),
//                   _buildTableHeader('Amount', align: pw.TextAlign.right),
//                 ],
//               ),
//               // Data rows
//               ...expenses.map((expense) {
//                 final isDebit = expense.type == ExpenseType.debit;
//                 return pw.TableRow(
//                   children: [
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         expense.title,
//                         style: const pw.TextStyle(fontSize: 10),
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         expense.category,
//                         style: const pw.TextStyle(fontSize: 10),
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         isDebit ? 'Debit' : 'Credit',
//                         style: pw.TextStyle(
//                           fontSize: 10,
//                           color: isDebit ? PdfColors.red : PdfColors.green,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         DateFormat('dd/MM/yy').format(expense.date),
//                         style: const pw.TextStyle(fontSize: 10),
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         '${isDebit ? '-' : '+'}₹${expense.amount.toStringAsFixed(2)}',
//                         style: pw.TextStyle(
//                           fontSize: 10,
//                           color: isDebit ? PdfColors.red : PdfColors.green,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                         textAlign: pw.TextAlign.right,
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),

//           // Footer
//           pw.SizedBox(height: 32),
//           pw.Divider(),
//           pw.SizedBox(height: 8),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text(
//                 'Expense Manager App',
//                 style: const pw.TextStyle(
//                   fontSize: 10,
//                   color: PdfColors.grey,
//                 ),
//               ),
//               pw.Text(
//                 'Page ${context.pageNumber} of ${context.pagesCount}',
//                 style: const pw.TextStyle(
//                   fontSize: 10,
//                   color: PdfColors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );

//     // Show print dialog
//     await Printing.layoutPdf(
//       onLayout: (format) async => pdf.save(),
//       name: 'expense_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
//     );
//   }

//   static pw.Widget _buildPDFSummaryCard(
//     String title,
//     String amount,
//     PdfColor color,
//   ) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: color, width: 2),
//         borderRadius: pw.BorderRadius.circular(8),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             title,
//             style: pw.TextStyle(
//               fontSize: 12,
//               color: PdfColors.grey700,
//             ),
//           ),
//           pw.SizedBox(height: 8),
//           pw.Text(
//             amount,
//             style: pw.TextStyle(
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildTableHeader(String text,
//       {pw.TextAlign align = pw.TextAlign.left}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontWeight: pw.FontWeight.bold,
//           fontSize: 11,
//         ),
//         textAlign: align,
//       ),
//     );
//   }
// }
