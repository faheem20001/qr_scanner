import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/scan_result.dart';

class QRCodeService {
  static QRCodeType detectQRCodeType(String data) {
    data = data.trim().toLowerCase();

    if (data.startsWith('http://') || data.startsWith('https://')) {
      return QRCodeType.url;
    } else if (data.startsWith('mailto:')) {
      return QRCodeType.email;
    } else if (data.startsWith('tel:') || data.startsWith('phone:')) {
      return QRCodeType.phone;
    } else if (data.startsWith('sms:') || data.startsWith('smsto:')) {
      return QRCodeType.sms;
    } else if (data.startsWith('wifi:')) {
      return QRCodeType.wifi;
    } else if (data.startsWith('geo:') || data.startsWith('maps:')) {
      return QRCodeType.location;
    } else if (data.contains('BEGIN:VCARD') || data.contains('begin:vcard')) {
      return QRCodeType.contact;
    } else if (_isEmail(data)) {
      return QRCodeType.email;
    } else if (_isPhoneNumber(data)) {
      return QRCodeType.phone;
    } else if (_isUrl(data)) {
      return QRCodeType.url;
    }

    return QRCodeType.text;
  }

  static bool _isEmail(String data) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(data);
  }

  static bool _isPhoneNumber(String data) {
    return RegExp(r'^[+]?[0-9\s\-\(\)]{7,15}$').hasMatch(data);
  }

  static bool _isUrl(String data) {
    try {
      final uri = Uri.parse(data);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri uri = Uri(scheme: 'tel', path: cleanNumber);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendSMS(String phoneNumber, [String? message]) async {
    try {
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri uri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: message != null ? {'body': message} : null,
      );
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendEmail(String email, [String? subject, String? body]) async {
    try {
      final Uri uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareContent(String content, [String? subject]) async {
    await Share.share(content, subject: subject);
  }

  static String parseWifiData(String wifiData) {
    // Parse WiFi QR code format: WIFI:T:WPA;S:network_name;P:password;H:false;;
    final regex = RegExp(r'WIFI:T:([^;]*);S:([^;]*);P:([^;]*);');
    final match = regex.firstMatch(wifiData.toUpperCase());

    if (match != null) {
      final security = match.group(1) ?? '';
      final ssid = match.group(2) ?? '';
      final password = match.group(3) ?? '';

      return 'Network: $ssid\nSecurity: $security\nPassword: $password';
    }

    return wifiData;
  }

  static String parseContactData(String contactData) {
    // Parse vCard format
    final lines = contactData.split('\n');
    final Map<String, String> fields = {};

    for (String line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();

          if (key.startsWith('FN')) {
            fields['Name'] = value;
          } else if (key.startsWith('TEL')) {
            fields['Phone'] = value;
          } else if (key.startsWith('EMAIL')) {
            fields['Email'] = value;
          } else if (key.startsWith('ORG')) {
            fields['Organization'] = value;
          }
        }
      }
    }

    return fields.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  static String formatDisplayText(String data, QRCodeType type) {
    switch (type) {
      case QRCodeType.wifi:
        return parseWifiData(data);
      case QRCodeType.contact:
        return parseContactData(data);
      case QRCodeType.email:
        if (data.startsWith('mailto:')) {
          return data.substring(7);
        }
        return data;
      case QRCodeType.phone:
        if (data.startsWith('tel:')) {
          return data.substring(4);
        }
        return data;
      case QRCodeType.sms:
        if (data.startsWith('sms:') || data.startsWith('smsto:')) {
          return data.substring(data.indexOf(':') + 1);
        }
        return data;
      default:
        return data;
    }
  }
}
