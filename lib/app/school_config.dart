import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchoolConfig {
  final String schoolId;
  final String appName;
  final String primaryColor;
  final String secondaryColor;
  final String logoPath;
  final String supportEmail;

  const SchoolConfig({
    required this.schoolId,
    required this.appName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoPath,
    required this.supportEmail,
  });

  Color get primaryColorValue {
    final hex = primaryColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Color get secondaryColorValue {
    final hex = secondaryColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory SchoolConfig.fromJson(Map<String, dynamic> json) => SchoolConfig(
    schoolId: json['schoolId'] ?? '',
    appName: json['appName'] ?? 'ShalaLink',
    primaryColor: json['primaryColor'] ?? '#065F46',
    secondaryColor: json['secondaryColor'] ?? '#F3F4F6',
    logoPath: json['logoPath'] ?? 'assets/images/logo.png',
    supportEmail: json['supportEmail'] ?? '',
  );
}

// Loaded once at startup in main.dart
final schoolConfigProvider = Provider<SchoolConfig>((ref) {
  throw UnimplementedError('schoolConfigProvider not initialized');
});

Future<SchoolConfig> loadSchoolConfig() async {
  final raw = await rootBundle.loadString('assets/school_config.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return SchoolConfig.fromJson(json);
}
