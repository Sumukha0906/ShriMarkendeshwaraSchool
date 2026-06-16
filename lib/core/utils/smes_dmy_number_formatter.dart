class SmesNumberFormatter {
  static String indianCurrency(double amount, {bool showSymbol = true}) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    String formatted;
    if (abs >= 10000000) {
      formatted = '${(abs / 10000000).toStringAsFixed(2)} Cr';
    } else if (abs >= 100000) {
      formatted = '${(abs / 100000).toStringAsFixed(2)} L';
    } else if (abs >= 1000) {
      final str = abs.toStringAsFixed(0);
      final last3 = str.substring(str.length - 3);
      final rest = str.substring(0, str.length - 3);
      final groups = <String>[];
      for (var i = rest.length; i > 0; i -= 2) {
        groups.insert(0, rest.substring(i > 2 ? i - 2 : 0, i));
      }
      formatted = '${groups.join(',')},$last3';
    } else {
      formatted = abs.toStringAsFixed(0);
    }
    final sign = isNegative ? '-' : '';
    return showSymbol ? '$sign₹$formatted' : '$sign$formatted';
  }

  static String compact(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 100000) return '${(number / 100000).toStringAsFixed(1)}L';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  static String percentage(double value, {int decimals = 1}) =>
      '${value.toStringAsFixed(decimals)}%';

  static String ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  static String rollNumber(String classCode, int seq) =>
      '$classCode${seq.toString().padLeft(3, '0')}';

  static double parseIndianCurrency(String text) {
    final cleaned = text.replaceAll(RegExp(r'[₹,\s]'), '').trim();
    if (cleaned.endsWith('Cr')) {
      return (double.tryParse(cleaned.replaceAll('Cr', '')) ?? 0) * 10000000;
    }
    if (cleaned.endsWith('L')) {
      return (double.tryParse(cleaned.replaceAll('L', '')) ?? 0) * 100000;
    }
    if (cleaned.endsWith('K')) {
      return (double.tryParse(cleaned.replaceAll('K', '')) ?? 0) * 1000;
    }
    return double.tryParse(cleaned) ?? 0;
  }
}
