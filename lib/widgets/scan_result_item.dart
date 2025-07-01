import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/qr_service.dart';
import 'scan_result_dialog.dart';

class ScanResultItem extends StatelessWidget {
  final QRScanResult result;
  final VoidCallback? onDelete;

  const ScanResultItem({
    super.key,
    required this.result,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            result.type.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          result.type.displayName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getDisplayText(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(result.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (_hasMainAction()) ...[
              PopupMenuItem(
                value: 'action',
                child: ListTile(
                  leading: Icon(_getMainActionIcon()),
                  title: Text(_getMainActionText()),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            if (onDelete != null)
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () => _showResultDialog(context),
      ),
    );
  }

  String _getDisplayText() {
    return QRCodeService.formatDisplayText(result.data, result.type);
  }

  bool _hasMainAction() {
    return [
      QRCodeType.url,
      QRCodeType.phone,
      QRCodeType.email,
      QRCodeType.sms,
    ].contains(result.type);
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

  String _getMainActionText() {
    switch (result.type) {
      case QRCodeType.url:
        return 'Open URL';
      case QRCodeType.phone:
        return 'Call';
      case QRCodeType.email:
        return 'Send Email';
      case QRCodeType.sms:
        return 'Send SMS';
      default:
        return 'Open';
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        _showResultDialog(context);
        break;
      case 'copy':
        _copyToClipboard(context);
        break;
      case 'share':
        _shareContent();
        break;
      case 'action':
        _performMainAction(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ScanResultDialog(result: result),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await QRCodeService.copyToClipboard(result.data);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  Future<void> _shareContent() async {
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this scan result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
