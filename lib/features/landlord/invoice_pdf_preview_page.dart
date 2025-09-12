import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class InvoicePdfPreviewPage extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const InvoicePdfPreviewPage({super.key, required this.invoice});

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final invoiceNumber = invoice['invoiceNumber'] ?? '52131';
    final invoiceDate =
        invoice['dueDate']?.toString().split('T').first ?? '01/02/2023';
    final tenant = invoice['tenant'] ?? '';
    final address = invoice['property'] ?? '';
    final items = [
      {
        'item': invoice['invoiceType'] ?? 'Invoice',
        'qty': 1,
        'unit': invoice['amount'] ?? 0,
        'total': invoice['amount'] ?? 0,
      },
    ];
    final subtotal = items.fold(0, (sum, i) => sum + (i['total'] as int));
    final tax = 0;
    final total = subtotal + tax;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blue,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Icon(
                      pw.IconData(0xe88d),
                      color: PdfColors.white,
                      size: 32,
                    ), // house icon
                  ),
                ),
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Invoice to:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      tenant,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    if (address.isNotEmpty) pw.Text(address),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Invoice#',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(invoiceNumber),
                    pw.Text('Date'),
                    pw.Text(invoiceDate),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Table(
              border: pw.TableBorder(horizontalInside: pw.BorderSide(width: 1)),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Item',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Quantity',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Unit Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                ...items.map(
                  (i) => pw.TableRow(
                    children: [
                      pw.Text(i['item'].toString()),
                      pw.Text(i['qty'].toString()),
                      pw.Text(_formatAmount(i['unit'] as int)),
                      pw.Text(_formatAmount(i['total'] as int)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Subtotal',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(_formatAmount(subtotal)),
                    pw.Text(
                      'Tax (0%)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('\u0000'),
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      _formatAmount(total),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice PDF Preview',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF181F2A),
      ),
      backgroundColor: const Color(0xFF181F2A),
      body: FutureBuilder<pw.Document>(
        future: _generatePdf(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return PdfPreview(
            build: (format) => snapshot.data!.save(),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            pdfFileName: 'invoice.pdf',
          );
        },
      ),
    );
  }
}
