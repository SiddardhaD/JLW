import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateOrderPdf({
  required String orderId,
  required String projectId,
  required String supplier,
}) async {
  final pdf = pw.Document();

  for (var page = 1; page <= 4; page++) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'JLW PURCHASE ORDER',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'PO_M30_Ref.pdf • Page $page of 4',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 28),
              pw.Text('Order No: $orderId'),
              pw.SizedBox(height: 6),
              pw.Text('Project ID: $projectId'),
              pw.SizedBox(height: 6),
              pw.Text('Supplier: $supplier'),
              pw.SizedBox(height: 28),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Line Item Summary',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Container(height: 10, color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                    pw.Container(height: 10, width: 280, color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                    pw.Container(height: 10, width: 220, color: PdfColors.grey300),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Internal Executive Document — Confidential',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );
  }

  return Uint8List.fromList(await pdf.save());
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
