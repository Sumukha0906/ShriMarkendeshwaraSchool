class SmesPaymentVerifier {
  static bool isValidAmount(double amount) => amount > 0 && amount < 10000000;

  static bool isValidTransactionId(String txnId) {
    if (txnId.trim().isEmpty) return false;
    return RegExp(r'^[A-Za-z0-9_\-]{6,40}$').hasMatch(txnId.trim());
  }

  static String? validatePaymentData({
    required double amount,
    required String studentId,
    required String termId,
    required String paymentMode,
  }) {
    if (!isValidAmount(amount)) return 'Invalid payment amount';
    if (studentId.trim().isEmpty) return 'Student ID is required';
    if (termId.trim().isEmpty) return 'Term ID is required';
    if (!['CASH', 'ONLINE', 'CHEQUE', 'DD', 'NEFT', 'UPI'].contains(paymentMode.toUpperCase())) {
      return 'Invalid payment mode';
    }
    return null;
  }

  static String maskAccountNumber(String accountNo) {
    if (accountNo.length <= 4) return accountNo;
    final visible = accountNo.substring(accountNo.length - 4);
    return '${'*' * (accountNo.length - 4)}$visible';
  }

  static String formatReceiptNumber(String schoolCode, int sequence) {
    final padded = sequence.toString().padLeft(6, '0');
    return 'SMES-$schoolCode-RCP-$padded';
  }

  static bool isReceiptNumberValid(String receiptNo) {
    return RegExp(r'^SMES-[A-Z]{3,6}-RCP-\d{6}$').hasMatch(receiptNo);
  }

  static Map<String, dynamic> buildPaymentSummary({
    required String studentName,
    required String className,
    required double amountPaid,
    required String paymentMode,
    required DateTime paidOn,
  }) {
    return {
      'student': studentName,
      'class': className,
      'amount': amountPaid,
      'mode': paymentMode,
      'paidOn': paidOn.toIso8601String(),
      'status': 'VERIFIED',
      'verifiedAt': DateTime.now().toIso8601String(),
    };
  }
}
