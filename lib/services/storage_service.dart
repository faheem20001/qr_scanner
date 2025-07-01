import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';

class StorageService {
  static const String _historyKey = 'scan_history';
  static final List<QRScanResult> _history = [];

  static List<QRScanResult> get history => List.unmodifiable(_history);

  static Future<void> saveResult(QRScanResult result) async {
    _history.insert(0, result); // Add to beginning of list

    // Keep only last 100 results
    if (_history.length > 100) {
      _history.removeRange(100, _history.length);
    }

    await _saveToStorage();
  }

  static Future<void> loadHistory() async {
    // In a real app, you would load from SharedPreferences or Hive
    // For this example, we'll keep it in memory
    if (kDebugMode) {
      print('Loading scan history...');
    }
  }

  static Future<void> _saveToStorage() async {
    // In a real app, you would save to SharedPreferences or Hive
    // For this example, we'll keep it in memory
    if (kDebugMode) {
      print('Saving scan history... ${_history.length} items');
    }
  }

  static Future<void> deleteResult(QRScanResult result) async {
    _history.removeWhere((item) => 
        item.data == result.data && 
        item.timestamp == result.timestamp);
    await _saveToStorage();
  }

  static Future<void> clearHistory() async {
    _history.clear();
    await _saveToStorage();
  }

  static QRScanResult? findResult(String data) {
    try {
      return _history.firstWhere((result) => result.data == data);
    } catch (e) {
      return null;
    }
  }

  static List<QRScanResult> searchHistory(String query) {
    if (query.isEmpty) return history;

    return _history.where((result) =>
        result.data.toLowerCase().contains(query.toLowerCase()) ||
        (result.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (result.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  static Map<String, int> getHistoryStats() {
    final stats = <String, int>{};

    for (final result in _history) {
      final type = result.type.displayName;
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return stats;
  }
}
