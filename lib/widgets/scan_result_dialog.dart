import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scan_result.dart';
import '../services/qr_service.dart';
import '../constants/app_constants.dart';

class ScanResultDialog extends StatelessWidget {
  final QRScanResult result;
  final Uint8List? image;

  const ScanResultDialog({
    super.key,
    required this.result,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(result.type.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.type.displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Content:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                QRCodeService.formatDisplayText(result.data, result.type),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scanned: ${_formatDateTime(result.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareContent(context),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_getMainAction() != null) ...[
          ElevatedButton.icon(
            onPressed: () => _performMainAction(context),
            icon: Icon(_getMainActionIcon(), size: 18),
            label: Text(_getMainAction()!),
          ),
          const SizedBox(height: 8),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String? _getMainAction() {
    switch (result.type) {
      case QRCodeType.url:
        return AppConstants.openUrl;
      case QRCodeType.phone:
        return AppConstants.callNumber;
      case QRCodeType.email:
        return AppConstants.sendEmail;
      case QRCodeType.sms:
        return AppConstants.sendSMS;
      default:
        return null;
    }
  }

  IconData _getMainActionIcon() {
    switch (result.type) {
      case QRCodeType.url:
        return Icons.open_in_browser;
      case QRCodeType.phone:
        return Icons.phone;
      case QRCodeType.email:
        return Icons.email;
      case QRCodeType.sms:
        return Icons.sms;
      default:
        return Icons.open_in_browser;
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await QRCodeService.copyToClipboard(result.data);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  Future<void> _shareContent(BuildContext context) async {
    await QRCodeService.shareContent(result.data, result.type.displayName);
  }

  Future<void> _performMainAction(BuildContext context) async {
    bool success = false;
    String message = '';

    try {
      switch (result.type) {
        case QRCodeType.url:
          success = await QRCodeService.openUrl(result.data);
          message = success ? 'Opening URL...' : 'Failed to open URL';
          break;
        case QRCodeType.phone:
          success = await QRCodeService.makePhoneCall(result.data);
          message = success ? 'Opening phone app...' : 'Failed to make call';
          break;
        case QRCodeType.email:
          success = await QRCodeService.sendEmail(result.data);
          message = success ? 'Opening email app...' : 'Failed to open email';
          break;
        case QRCodeType.sms:
          success = await QRCodeService.sendSMS(result.data);
          message = success ? 'Opening SMS app...' : 'Failed to send SMS';
          break;
        default:
          message = 'Action not supported';
      }
    } catch (e) {
      message = 'Failed to perform action: $e';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
