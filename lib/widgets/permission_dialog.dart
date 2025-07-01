import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../constants/app_constants.dart';

class PermissionDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const PermissionDialog({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.camera_alt, color: Colors.orange),
          SizedBox(width: 8),
          Text('Camera Permission'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.permissionDenied,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'To scan QR codes, this app needs access to your camera. '
            'Please grant camera permission to continue.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();

            // Check if permission is permanently denied
            final isPermanentlyDenied = 
                await PermissionService.isCameraPermissionPermanentlyDenied();

            if (isPermanentlyDenied) {
              // Open app settings
              await PermissionService.openAppSettings();
            } else {
              // Retry permission request
              onRetry();
            }
          },
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }
}
