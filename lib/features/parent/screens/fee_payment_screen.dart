import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/fee.dart';
import '../../../core/services/fee_receipt_service.dart';
import '../../../core/utils/app_logger.dart';
import '../parent_dashboard.dart';

class FeePaymentScreen extends ConsumerWidget {
  final Student student;
  const FeePaymentScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    AppLogger.d('FEE', 'FeePaymentScreen: studentId="${student.studentId}" schoolId="${student.schoolId}"');

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Fee & Payments',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<Fee?>(
        stream: fs.streamLatestStudentFee(
          student.studentId,
          student.schoolId,
        ),
        builder: (ctx, snap) {
          if (snap.hasError) {
            AppLogger.e('FEE', 'StreamBuilder error: ${snap.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading fee: ${snap.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kParentPrimary));
          }
          final fee = snap.data;
          if (fee == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No fee record yet',
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your school admin hasn\'t set your fee yet.\nCheck back later or contact the school.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary card ───────────────────────────────────────
                _FeeSummaryCard(fee: fee),
                const SizedBox(height: 12),

                // ── Consolidated receipt (when fully paid) ─────────────
                if (fee.isFullyPaid)
                  _ConsolidatedReceiptButton(
                      fee: fee, student: student),
                const SizedBox(height: 8),

                // ── Fee breakdown by components ─────────────────────────
                if (fee.feeComponents.isNotEmpty) ...[
                  const Text(
                    'Fee Breakdown',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kParentDark),
                  ),
                  const SizedBox(height: 10),
                  _FeeBreakdownCard(components: fee.feeComponents),
                  const SizedBox(height: 20),
                ],

                // ── Payment history (with receipt download) ─────────────
                if (fee.payments.isNotEmpty) ...[
                  const Text(
                    'Payment History',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kParentDark),
                  ),
                  const SizedBox(height: 10),
                  ...fee.payments.reversed.map((p) => _PaymentHistoryCard(
                        payment:       p,
                        student:       student,
                        fee:           fee,
                        academicYear:  fee.academicYear,
                      )),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            color: Colors.grey[400], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No payments recorded yet. Your school admin will record payments on your behalf.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Fee summary card ─────────────────────────────────────────────────────────
class _FeeSummaryCard extends StatelessWidget {
  final Fee fee;
  const _FeeSummaryCard({required this.fee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kParentDark, Color(0xFF7C2D12)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kParentDark.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Fee',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12),
                  ),
                  Text(
                    '₹${fee.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: fee.isFullyPaid
                      ? const Color(0xFF059669)
                      : kParentAmber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fee.isFullyPaid ? 'Fully Paid' : 'Pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                    '₹${fee.totalPaid.toStringAsFixed(0)}',
                    'Paid',
                    const Color(0xFF059669)),
              ),
              Container(
                  width: 1, height: 40,
                  color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _summaryItem(
                    '₹${fee.totalPending.toStringAsFixed(0)}',
                    'Pending',
                    kParentAmber),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${fee.totalAmount > 0 ? ((fee.totalPaid / fee.totalAmount) * 100).toStringAsFixed(0) : 0}% paid',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: fee.totalAmount > 0
                      ? fee.totalPaid / fee.totalAmount : 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: const Color(0xFF059669),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
      ],
    );
  }
}

// ─── Fee breakdown ────────────────────────────────────────────────────────────
class _FeeBreakdownCard extends StatelessWidget {
  final Map<String, double> components;
  const _FeeBreakdownCard({required this.components});

  @override
  Widget build(BuildContext context) {
    final entries = components.entries.toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kParentAmber.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          ...entries.asMap().entries.map((e) {
            final idx   = e.key;
            final entry = e.value;
            final isLast = idx == entries.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: kParentAmber, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(entry.key,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kParentDark)),
                      ),
                      Text('₹${entry.value.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: kParentDark)),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: Colors.grey[100]),
              ],
            );
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kParentDark.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: kParentDark)),
                Text(
                  '₹${components.values.fold(0.0, (a, b) => a + b).toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kParentDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment history card (with receipt download) ─────────────────────────────
class _PaymentHistoryCard extends ConsumerStatefulWidget {
  final Payment  payment;
  final Student  student;
  final Fee      fee;
  final String   academicYear;
  const _PaymentHistoryCard({
    required this.payment,
    required this.student,
    required this.fee,
    required this.academicYear,
  });

  @override
  ConsumerState<_PaymentHistoryCard> createState() =>
      _PaymentHistoryCardState();
}

class _PaymentHistoryCardState extends ConsumerState<_PaymentHistoryCard> {
  bool _downloading = false;

  Future<void> _downloadReceipt() async {
    setState(() => _downloading = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final school = await fs.getSchool(widget.student.schoolId);
      final receiptNumber = FeeReceiptService.buildReceiptNumber(
          widget.academicYear, widget.payment.paymentId);
      final receiptData = ReceiptData(
        receiptNumber: receiptNumber,
        schoolId:      widget.student.schoolId,
        schoolName:    school?.name ?? '',
        schoolAddress: school?.address ?? '',
        schoolPhone:   school?.phone ?? '',
        schoolLogoUrl: school?.logoUrl ?? '',
        studentId:     widget.student.studentId,
        studentName:   widget.student.name,
        className:     widget.student.classId, // shown on receipt
        academicYear:  widget.academicYear,
        feeComponents: widget.fee.feeComponents,
        totalAmount:   widget.fee.totalAmount,
        payment:       widget.payment,
      );
      final Uint8List pdfBytes =
          await FeeReceiptService.generateReceiptPdf(receiptData);
      final safeReceipt = receiptNumber.replaceAll('/', '-');
      await Printing.sharePdf(bytes: pdfBytes, filename: '$safeReceipt.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF059669).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF059669), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${p.amount.toStringAsFixed(0)} — ${p.mode.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF065F46)),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy hh:mm a').format(p.paidAt),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF059669)),
                    ),
                    if (p.transactionRef.isNotEmpty)
                      Text(
                        'Ref: ${p.transactionRef}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF059669)),
                      ),
                  ],
                ),
              ),
              // Receipt download button
              GestureDetector(
                onTap: _downloading ? null : _downloadReceipt,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF065F46).withValues(alpha: 0.3)),
                  ),
                  child: _downloading
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              color: Color(0xFF065F46), strokeWidth: 1.5))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.receipt_long_rounded,
                                size: 13, color: Color(0xFF065F46)),
                            SizedBox(width: 4),
                            Text('Receipt',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF065F46),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Consolidated receipt download (shown when fully paid) ───────────────────
class _ConsolidatedReceiptButton extends ConsumerStatefulWidget {
  final Fee fee;
  final Student student;
  const _ConsolidatedReceiptButton({required this.fee, required this.student});

  @override
  ConsumerState<_ConsolidatedReceiptButton> createState() =>
      _ConsolidatedReceiptButtonState();
}

class _ConsolidatedReceiptButtonState
    extends ConsumerState<_ConsolidatedReceiptButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final school = await fs.getSchool(widget.student.schoolId);
      final receiptNumber = FeeReceiptService.buildConsolidatedReceiptNumber(
          widget.fee.academicYear, widget.student.studentId);
      final data = ConsolidatedReceiptData(
        receiptNumber: receiptNumber,
        schoolId:      widget.student.schoolId,
        schoolName:    school?.name ?? '',
        schoolAddress: school?.address ?? '',
        schoolPhone:   school?.phone ?? '',
        schoolLogoUrl: school?.logoUrl ?? '',
        studentId:     widget.student.studentId,
        studentName:   widget.student.name,
        className:     widget.student.classId,
        rollNo:        widget.student.rollNo,
        academicYear:  widget.fee.academicYear,
        feeComponents: widget.fee.feeComponents,
        totalAmount:   widget.fee.totalAmount,
        totalPaid:     widget.fee.totalPaid,
        payments:      widget.fee.payments,
      );
      final pdfBytes =
          await FeeReceiptService.generateConsolidatedReceiptPdf(data);
      final safeReceipt = receiptNumber.replaceAll('/', '-');
      await Printing.sharePdf(
          bytes: pdfBytes,
          filename:
              '${widget.student.name}-${widget.fee.academicYear}-$safeReceipt.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _download,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF065F46), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else
              const Icon(Icons.download_rounded,
                  color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              _loading
                  ? 'Generating Receipt...'
                  : 'Download Full Receipt',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
