import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static Future<bool> isCameraPermissionDenied() async {
    final status = await Permission.camera.status;
    return status.isDenied;
  }

  static Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  static String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Camera permission granted';
      case PermissionStatus.denied:
        return 'Camera permission denied';
      case PermissionStatus.restricted:
        return 'Camera permission restricted';
      case PermissionStatus.limited:
        return 'Camera permission limited';
      case PermissionStatus.permanentlyDenied:
        return 'Camera permission permanently denied. Please enable it in app settings.';
      default:
        return 'Unknown permission status';
    }
  }
}
