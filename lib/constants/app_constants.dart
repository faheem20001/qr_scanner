import 'package:flutter/animation.dart';

class AppConstants {
  static const String appName = 'QR Code Scanner';
  static const String scanCodeTitle = 'Scan QR Code';
  static const String historyTitle = 'Scan History';
  static const String settingsTitle = 'Settings';

  // Messages
  static const String permissionDenied = 'Camera permission is required to scan QR codes';
  static const String scanInstruction = 'Point your camera at a QR code to scan it';
  static const String noDataFound = 'No QR code data found';
  static const String scanSuccess = 'QR code scanned successfully!';

  // Actions
  static const String openUrl = 'Open URL';
  static const String copyToClipboard = 'Copy to Clipboard';
  static const String shareContent = 'Share';
  static const String callNumber = 'Call Number';
  static const String sendEmail = 'Send Email';
  static const String sendSMS = 'Send SMS';
  static const String saveToHistory = 'Save to History';

  // QR Code Types
  static const String typeUrl = 'URL';
  static const String typeEmail = 'Email';
  static const String typePhone = 'Phone';
  static const String typeSMS = 'SMS';
  static const String typeText = 'Text';
  static const String typeWifi = 'WiFi';
  static const String typeContact = 'Contact';
  static const String typeLocation = 'Location';
}

class AppColors {
  static const primaryColor = Color(0xFF2196F3);
  static const secondaryColor = Color(0xFF03DAC6);
  static const errorColor = Color(0xFFB00020);
  static const successColor = Color(0xFF4CAF50);
  static const warningColor = Color(0xFFFF9800);
}
