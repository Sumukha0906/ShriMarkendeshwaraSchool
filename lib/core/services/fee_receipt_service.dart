import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/fee.dart';

// ────────────────────────────────────────────────────────────────────────────
// Data class for single-payment receipt
// ────────────────────────────────────────────────────────────────────────────
class ReceiptData {
  final String receiptNumber;
  final String schoolId;
  final String schoolName;
  final String schoolAddress;
  final String schoolPhone;
  final String schoolEmail;
  final String schoolLogoUrl;
  final String studentId;
  final String studentName;
  final String fatherName;
  final String admissionNo;
  final String className;
  final String rollNo;
  final String academicYear;
  final Map<String, double> feeComponents;
  final double totalAmount;
  final double remainingBalance;
  final Payment payment;

  const ReceiptData({
    required this.receiptNumber,
    required this.schoolId,
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolPhone,
    this.schoolEmail = '',
    required this.schoolLogoUrl,
    required this.studentId,
    required this.studentName,
    this.fatherName = '',
    this.admissionNo = '',
    required this.className,
    this.rollNo = '',
    required this.academicYear,
    required this.feeComponents,
    required this.totalAmount,
    this.remainingBalance = 0,
    required this.payment,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Data class for consolidated (full payment) receipt
// ────────────────────────────────────────────────────────────────────────────
class ConsolidatedReceiptData {
  final String receiptNumber;
  final String schoolId;
  final String schoolName;
  final String schoolAddress;
  final String schoolPhone;
  final String schoolEmail;
  final String schoolLogoUrl;
  final String studentId;
  final String studentName;
  final String fatherName;
  final String admissionNo;
  final String className;
  final String rollNo;
  final String academicYear;
  final Map<String, double> feeComponents;
  final double totalAmount;
  final double totalPaid;
  final List<Payment> payments;

  const ConsolidatedReceiptData({
    required this.receiptNumber,
    required this.schoolId,
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolPhone,
    this.schoolEmail = '',
    required this.schoolLogoUrl,
    required this.studentId,
    required this.studentName,
    this.fatherName = '',
    this.admissionNo = '',
    required this.className,
    this.rollNo = '',
    required this.academicYear,
    required this.feeComponents,
    required this.totalAmount,
    required this.totalPaid,
    required this.payments,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Service
// ────────────────────────────────────────────────────────────────────────────
class FeeReceiptService {
  static final _storage = FirebaseStorage.instance;
  static final _db = FirebaseFirestore.instance;

  // ── Sequential receipt number (SL01, SL02, …) ──────────────────────────
  static Future<String> getNextReceiptNumber(String schoolId) async {
    final counterRef = _db.collection('school_counters').doc(schoolId);
    return _db.runTransaction<String>((txn) async {
      final snap = await txn.get(counterRef);
      final current = (snap.data()?['lastReceiptNumber'] as int?) ?? 0;
      final next = current + 1;
      txn.set(counterRef, {'lastReceiptNumber': next}, SetOptions(merge: true));
      final pad = next < 100 ? next.toString().padLeft(2, '0') : next.toString();
      return 'SL$pad';
    });
  }

  // ── Legacy receipt number (kept for consolidated / re-download fallback) ─
  static String buildReceiptNumber(String academicYear, String paymentId) {
    final datePart = DateFormat('yyyyMMdd').format(DateTime.now());
    final shortId = paymentId.replaceAll('-', '').substring(0, 6);
    return 'RCPT/$academicYear/$datePart-$shortId';
  }

  static String buildConsolidatedReceiptNumber(String academicYear, String studentId) {
    final datePart = DateFormat('yyyyMMdd').format(DateTime.now());
    final shortId = studentId.replaceAll('-', '').substring(0, 6);
    return 'FULL-RCPT/$academicYear/$datePart-$shortId';
  }

  static String _amountToWords(double amount) {
    final int rupees = amount.toInt();
    if (rupees == 0) return 'Zero Rupees Only';

    const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String convert(int n) {
      if (n >= 10000000) return '${convert(n ~/ 10000000)} Crore ${convert(n % 10000000)}';
      if (n >= 100000)   return '${convert(n ~/ 100000)} Lakh ${convert(n % 100000)}';
      if (n >= 1000)     return '${convert(n ~/ 1000)} Thousand ${convert(n % 1000)}';
      if (n >= 100)      return '${ones[n ~/ 100]} Hundred ${convert(n % 100)}';
      if (n >= 20)       return '${tens[n ~/ 10]} ${ones[n % 10]}';
      return ones[n];
    }

    return '${convert(rupees).replaceAll(RegExp(r'\s+'), ' ').trim()} Rupees Only';
  }

  // ── Fetch image bytes from URL ──────────────────────────────────────────
  static Future<Uint8List?> _fetchImageBytes(String url) async {
    if (url.isEmpty) return null;
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(url));
      final resp = await req.close();
      final bytes = await resp.fold<List<int>>(
          [], (prev, chunk) => prev..addAll(chunk));
      client.close();
      return Uint8List.fromList(bytes);
    } catch (_) {
      return null;
    }
  }

  // ── Generate single-payment receipt PDF ────────────────────────────────
  static Future<Uint8List> generateReceiptPdf(ReceiptData data) async {
    final pdf = pw.Document();

    final logoBytes = await _fetchImageBytes(data.schoolLogoUrl);
    pw.ImageProvider? logoImage;
    if (logoBytes != null) logoImage = pw.MemoryImage(logoBytes);

    // ── Colours ─────────────────────────────────────────────────────────
    const darkGreen  = PdfColor.fromInt(0xFF065F46);
    const midGreen   = PdfColor.fromInt(0xFF059669);
    const lightGreen = PdfColor.fromInt(0xFFD1FAE5);
    const grey600    = PdfColor.fromInt(0xFF4B5563);
    const grey200    = PdfColor.fromInt(0xFFE5E7EB);
    const white      = PdfColors.white;
    const redColor   = PdfColor.fromInt(0xFFDC2626);

    final amtFmt = NumberFormat('#,##,##0', 'en_IN');
    final payDate = DateFormat('dd MMM yyyy').format(data.payment.paidAt);
    final modeLabel = data.payment.mode.name;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Header band ─────────────────────────────────────────
              pw.Container(
                decoration: const pw.BoxDecoration(color: darkGreen),
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: pw.Row(
                  children: [
                    if (logoImage != null) ...[
                      pw.Container(
                        width: 52,
                        height: 52,
                        decoration: pw.BoxDecoration(
                          color: white,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            data.schoolName,
                            style: pw.TextStyle(
                              color: white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (data.schoolAddress.isNotEmpty)
                            pw.Text(
                              data.schoolAddress,
                              style: const pw.TextStyle(color: white, fontSize: 8),
                            ),
                          if (data.schoolPhone.isNotEmpty)
                            pw.Text(
                              'Ph: ${data.schoolPhone}',
                              style: const pw.TextStyle(color: white, fontSize: 8),
                            ),
                          if (data.schoolEmail.isNotEmpty)
                            pw.Text(
                              'Email: ${data.schoolEmail}',
                              style: const pw.TextStyle(color: white, fontSize: 8),
                            ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'FEE RECEIPT',
                          style: pw.TextStyle(
                            color: white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: midGreen,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            data.receiptNumber,
                            style: pw.TextStyle(
                                color: white,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // ── Student info (3-row grid) ──────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: lightGreen,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(child: _infoItem('Student Name', data.studentName)),
                        pw.Expanded(child: _infoItem('Father Name',
                            data.fatherName.isNotEmpty ? data.fatherName : '—')),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(child: _infoItem('Regn. No.',
                            data.admissionNo.isNotEmpty ? data.admissionNo : '—')),
                        pw.Expanded(child: _infoItem('Class', data.className)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(child: _infoItem('Academic Year', data.academicYear)),
                        pw.Expanded(child: _infoItem('Date', payDate)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // ── Fee breakdown table ──────────────────────────────────
              _sectionHeader('Fee Details', darkGreen, white),
              pw.SizedBox(height: 6),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                border: pw.TableBorder.all(color: grey200),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFF9FAFB)),
                    children: [
                      _tableCell('Fee Component',
                          isHeader: true, color: grey600),
                      _tableCell('Amount (Rs.)',
                          isHeader: true,
                          color: grey600,
                          align: pw.TextAlign.right),
                    ],
                  ),
                  if (data.feeComponents.isNotEmpty)
                    ...data.feeComponents.entries.map((e) => pw.TableRow(
                          children: [
                            _tableCell(e.key),
                            _tableCell(amtFmt.format(e.value),
                                align: pw.TextAlign.right),
                          ],
                        ))
                  else
                    pw.TableRow(children: [
                      _tableCell('Annual Fee'),
                      _tableCell(amtFmt.format(data.totalAmount),
                          align: pw.TextAlign.right),
                    ]),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: lightGreen),
                    children: [
                      _tableCell('Total Fee',
                          isHeader: true, color: darkGreen),
                      _tableCell(
                          'Rs. ${amtFmt.format(data.totalAmount)}',
                          isHeader: true,
                          color: darkGreen,
                          align: pw.TextAlign.right),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // ── Payment details ───────────────────────────────────────
              _sectionHeader('Payment Received', darkGreen, white),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: grey200),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    _payRow('Amount Paid',
                        'Rs. ${amtFmt.format(data.payment.amount)}',
                        midGreen),
                    pw.Divider(color: grey200, thickness: 0.5),
                    _payRow('Payment Mode', modeLabel, grey600),
                    if (data.payment.transactionRef.isNotEmpty) ...[
                      pw.Divider(color: grey200, thickness: 0.5),
                      _payRow('Transaction Ref',
                          data.payment.transactionRef, grey600),
                    ],
                    pw.Divider(color: grey200, thickness: 0.5),
                    _payRow('Payment Date', payDate, grey600),
                    pw.Divider(color: grey200, thickness: 0.5),
                    _payRow('Total Amount',
                        'Rs. ${amtFmt.format(data.totalAmount)}', grey600),
                    pw.Divider(color: grey200, thickness: 0.5),
                    _payRow(
                      'Remaining Balance',
                      data.remainingBalance <= 0
                          ? 'NIL'
                          : 'Rs. ${amtFmt.format(data.remainingBalance)}',
                      data.remainingBalance <= 0 ? midGreen : redColor,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── Amount in words ───────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFFFBEB),
                  border: pw.Border.all(
                      color: PdfColor.fromInt(0xFFFCD34D)),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.RichText(
                  text: pw.TextSpan(children: [
                    pw.TextSpan(
                      text: 'Amount in Words: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: grey600),
                    ),
                    pw.TextSpan(
                      text: _amountToWords(data.payment.amount),
                      style: const pw.TextStyle(
                          fontSize: 9, color: grey600),
                    ),
                  ]),
                ),
              ),

              pw.Spacer(),

              // ── Footer ───────────────────────────────────────────────
              pw.Divider(color: grey200),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'This is a computer-generated receipt\nand does not require a physical signature.',
                    style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColor.fromInt(0xFF9CA3AF)),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                          width: 100, height: 0.5, color: grey600),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Authorised Signature',
                        style: const pw.TextStyle(
                            fontSize: 8, color: grey600),
                      ),
                      pw.Text(
                        data.schoolName,
                        style: const pw.TextStyle(
                            fontSize: 7,
                            color: PdfColor.fromInt(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ── Generate consolidated (full payment) receipt PDF ───────────────────
  static Future<Uint8List> generateConsolidatedReceiptPdf(
      ConsolidatedReceiptData data) async {
    final pdf = pw.Document();

    final logoBytes = await _fetchImageBytes(data.schoolLogoUrl);
    pw.ImageProvider? logoImage;
    if (logoBytes != null) logoImage = pw.MemoryImage(logoBytes);

    const darkGreen  = PdfColor.fromInt(0xFF065F46);
    const midGreen   = PdfColor.fromInt(0xFF059669);
    const lightGreen = PdfColor.fromInt(0xFFD1FAE5);
    const grey600    = PdfColor.fromInt(0xFF4B5563);
    const grey200    = PdfColor.fromInt(0xFFE5E7EB);
    const white      = PdfColors.white;
    const amber      = PdfColor.fromInt(0xFFF59E0B);

    final amtFmt  = NumberFormat('#,##,##0', 'en_IN');
    final dateFmt = DateFormat('dd MMM yyyy');
    final isFullyPaid = data.totalPaid >= data.totalAmount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          // ── Header band ───────────────────────────────────────────
          pw.Container(
            decoration: const pw.BoxDecoration(color: darkGreen),
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: pw.Row(
              children: [
                if (logoImage != null) ...[
                  pw.Container(
                    width: 52, height: 52,
                    decoration: pw.BoxDecoration(
                      color: white,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 12),
                ],
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data.schoolName,
                          style: pw.TextStyle(
                              color: white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold)),
                      if (data.schoolAddress.isNotEmpty)
                        pw.Text(data.schoolAddress,
                            style: const pw.TextStyle(color: white, fontSize: 8)),
                      if (data.schoolPhone.isNotEmpty)
                        pw.Text('Ph: ${data.schoolPhone}',
                            style: const pw.TextStyle(color: white, fontSize: 8)),
                      if (data.schoolEmail.isNotEmpty)
                        pw.Text('Email: ${data.schoolEmail}',
                            style: const pw.TextStyle(color: white, fontSize: 8)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'CONSOLIDATED FEE RECEIPT',
                      style: pw.TextStyle(
                        color: white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: midGreen,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(data.receiptNumber,
                          style: const pw.TextStyle(
                              color: white, fontSize: 7)),
                    ),
                    if (isFullyPaid) ...[
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: amber,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text('PAID IN FULL',
                            style: pw.TextStyle(
                                color: white,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // ── Student info ─────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightGreen,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(child: _infoItem('Student Name', data.studentName)),
                    pw.Expanded(child: _infoItem('Father Name',
                        data.fatherName.isNotEmpty ? data.fatherName : '—')),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(child: _infoItem('Regn. No.',
                        data.admissionNo.isNotEmpty ? data.admissionNo : '—')),
                    pw.Expanded(child: _infoItem('Class', data.className)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(child: _infoItem('Academic Year', data.academicYear)),
                    pw.Expanded(child: pw.SizedBox()),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // ── Fee breakdown ────────────────────────────────────────
          _sectionHeader('Fee Breakdown', darkGreen, white),
          pw.SizedBox(height: 6),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            border: pw.TableBorder.all(color: grey200),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF9FAFB)),
                children: [
                  _tableCell('Fee Component',
                      isHeader: true, color: grey600),
                  _tableCell('Amount (Rs.)',
                      isHeader: true,
                      color: grey600,
                      align: pw.TextAlign.right),
                ],
              ),
              if (data.feeComponents.isNotEmpty)
                ...data.feeComponents.entries
                    .map((e) => pw.TableRow(children: [
                          _tableCell(e.key),
                          _tableCell(amtFmt.format(e.value),
                              align: pw.TextAlign.right),
                        ]))
              else
                pw.TableRow(children: [
                  _tableCell('Annual Fee'),
                  _tableCell(amtFmt.format(data.totalAmount),
                      align: pw.TextAlign.right),
                ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: lightGreen),
                children: [
                  _tableCell('Total Fee',
                      isHeader: true, color: darkGreen),
                  _tableCell('Rs. ${amtFmt.format(data.totalAmount)}',
                      isHeader: true,
                      color: darkGreen,
                      align: pw.TextAlign.right),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 14),

          // ── Payment Summary ──────────────────────────────────────
          _sectionHeader('Payment Summary', darkGreen, white),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: grey200),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                _payRow('Total Amount',
                    'Rs. ${amtFmt.format(data.totalAmount)}', grey600),
                pw.Divider(color: grey200, thickness: 0.5),
                _payRow('Total Paid',
                    'Rs. ${amtFmt.format(data.totalPaid)}', midGreen),
                pw.Divider(color: grey200, thickness: 0.5),
                _payRow(
                  'Remaining Balance',
                  isFullyPaid
                      ? 'NIL'
                      : 'Rs. ${amtFmt.format(data.totalAmount - data.totalPaid)}',
                  isFullyPaid
                      ? midGreen
                      : const PdfColor.fromInt(0xFFDC2626),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // ── Payment History ──────────────────────────────────────
          _sectionHeader('Payment History', darkGreen, white),
          pw.SizedBox(height: 6),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            border: pw.TableBorder.all(color: grey200),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF9FAFB)),
                children: [
                  _tableCell('Date', isHeader: true, color: grey600),
                  _tableCell('Mode', isHeader: true, color: grey600),
                  _tableCell('Reference', isHeader: true, color: grey600),
                  _tableCell('Amount (Rs.)',
                      isHeader: true,
                      color: grey600,
                      align: pw.TextAlign.right),
                ],
              ),
              ...data.payments.map((p) => pw.TableRow(children: [
                    _tableCell(dateFmt.format(p.paidAt)),
                    _tableCell(p.mode.name),
                    _tableCell(p.transactionRef.isNotEmpty
                        ? p.transactionRef
                        : '—'),
                    _tableCell(amtFmt.format(p.amount),
                        align: pw.TextAlign.right),
                  ])),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: lightGreen),
                children: [
                  _tableCell('Total Paid',
                      isHeader: true, color: darkGreen),
                  _tableCell('', isHeader: true),
                  _tableCell('', isHeader: true),
                  _tableCell(
                      'Rs. ${amtFmt.format(data.totalPaid)}',
                      isHeader: true,
                      color: darkGreen,
                      align: pw.TextAlign.right),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 14),

          // ── Amount in words ──────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFFFBEB),
              border: pw.Border.all(
                  color: PdfColor.fromInt(0xFFFCD34D)),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(
                  text: 'Total Amount in Words: ',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                      color: grey600),
                ),
                pw.TextSpan(
                  text: _amountToWords(data.totalPaid),
                  style: const pw.TextStyle(
                      fontSize: 9, color: grey600),
                ),
              ]),
            ),
          ),

          pw.SizedBox(height: 24),

          // ── Footer ───────────────────────────────────────────────
          pw.Divider(color: grey200),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'This is a computer-generated receipt\nand does not require a physical signature.',
                style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColor.fromInt(0xFF9CA3AF)),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                      width: 100, height: 0.5, color: grey600),
                  pw.SizedBox(height: 3),
                  pw.Text('Authorised Signature',
                      style: const pw.TextStyle(
                          fontSize: 8, color: grey600)),
                  pw.Text(data.schoolName,
                      style: const pw.TextStyle(
                          fontSize: 7,
                          color: PdfColor.fromInt(0xFF9CA3AF))),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Upload to Firebase Storage and save to studentDocuments ────────────
  static Future<Map<String, dynamic>> uploadAndSaveReceipt({
    required ReceiptData data,
    required String adminUid,
    required String adminName,
  }) async {
    final pdfBytes = await generateReceiptPdf(data);

    final safeReceipt = data.receiptNumber.replaceAll('/', '-');
    final storagePath =
        'fee_receipts/${data.schoolId}/${data.studentId}/$safeReceipt.pdf';

    final ref = _storage.ref(storagePath);
    final uploadTask = await ref.putData(
      pdfBytes,
      SettableMetadata(contentType: 'application/pdf'),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    final fileName = '$safeReceipt.pdf';

    final docRef = _db
        .collection('students')
        .doc(data.studentId)
        .collection('studentDocuments')
        .doc();

    final docData = {
      'docId':          docRef.id,
      'docType':        'Fee Receipt',
      'fileName':       fileName,
      'downloadUrl':    downloadUrl,
      'storagePath':    storagePath,
      'uploadedAt':     FieldValue.serverTimestamp(),
      'uploadedByUid':  adminUid,
      'uploadedByName': adminName,
      'receiptNumber':  data.receiptNumber,
      'academicYear':   data.academicYear,
      'paymentId':      data.payment.paymentId,
      'amount':         data.payment.amount,
      'paymentMode':    data.payment.mode.name,
      'paymentDate':    Timestamp.fromDate(data.payment.paidAt),
    };

    await docRef.set(docData);

    return {
      'receiptNumber': data.receiptNumber,
      'downloadUrl':   downloadUrl,
      'pdfBytes':      pdfBytes,
      'fileName':      fileName,
    };
  }

  // ── PDF widget helpers ──────────────────────────────────────────────────
  static pw.Widget _infoItem(String label, String value) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColor.fromInt(0xFF065F46))),
          pw.SizedBox(height: 2),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF0A0F1E))),
        ],
      );

  static pw.Widget _sectionHeader(
          String title, PdfColor bg, PdfColor fg) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
              color: fg,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8),
        ),
      );

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    PdfColor color = PdfColors.black,
    pw.TextAlign align = pw.TextAlign.left,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight:
                isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      );

  static pw.Widget _payRow(
          String label, String value, PdfColor valueColor) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromInt(0xFF6B7280))),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: valueColor)),
          ],
        ),
      );
}
