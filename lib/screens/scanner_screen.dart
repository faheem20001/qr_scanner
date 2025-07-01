import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/scan_result.dart';
import '../services/qr_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../widgets/scan_result_dialog.dart';
import '../widgets/permission_dialog.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isPermissionGranted = false;
  bool _isScanning = false;
  String? _lastScannedData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _controller!.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller!.stop();
        break;
    }
  }

  Future<void> _initializeScanner() async {
    final hasPermission = await PermissionService.checkCameraPermission();

    if (!hasPermission) {
      final granted = await PermissionService.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }
    }

    setState(() {
      _isPermissionGranted = true;
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        returnImage: true,
      );
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        onRetry: _initializeScanner,
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    final Uint8List? image = capture.image;

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final data = barcode.rawValue;

      if (data != null && data.isNotEmpty && data != _lastScannedData) {
        _lastScannedData = data;
        _handleScanResult(data, image);
      }
    }
  }

  Future<void> _handleScanResult(String data, Uint8List? image) async {
    setState(() {
      _isScanning = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Detect QR code type
    final type = QRCodeService.detectQRCodeType(data);

    // Create scan result
    final result = QRScanResult(
      data: data,
      type: type,
      timestamp: DateTime.now(),
      title: type.displayName,
      description: QRCodeService.formatDisplayText(data, type),
    );

    // Save to history
    await StorageService.saveResult(result);

    // Show result dialog
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => ScanResultDialog(
          result: result,
          image: image,
        ),
      );
    }

    // Reset scanning state
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isScanning = false;
      _lastScannedData = null;
    });
  }

  void _toggleFlash() {
    _controller?.toggleTorch();
  }

  void _switchCamera() {
    _controller?.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.scanCodeTitle),
        actions: [
          if (_isPermissionGranted) ...[
            IconButton(
              onPressed: _toggleFlash,
              icon: const Icon(Icons.flash_on),
              tooltip: 'Toggle Flash',
            ),
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.cameraswitch),
              tooltip: 'Switch Camera',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isPermissionGranted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              AppConstants.permissionDenied,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        _buildScanOverlay(),
        _buildInstructions(),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QRScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 16,
          borderLength: 30,
          borderWidth: 4,
          cutOutSize: 250,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _isScanning 
                  ? 'Processing...' 
                  : AppConstants.scanInstruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (_isScanning) ...[
              const SizedBox(height: 8),
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QRScannerOverlayShape extends ShapeBorder {
  const QRScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);

    final center = Offset(rect.center.dx, rect.center.dy);
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    return path
      ..addRRect(RRect.fromRectAndRadius(
        cutOutRect,
        Radius.circular(borderRadius),
      ));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final cutOutLeft = centerX - cutOutSize / 2;
    final cutOutTop = centerY - cutOutSize / 2;
    final cutOutRight = centerX + cutOutSize / 2;
    final cutOutBottom = centerY + cutOutSize / 2;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cutOutLeft,
          cutOutTop,
          cutOutSize,
          cutOutSize,
        ),
        Radius.circular(borderRadius),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corners
    canvas.drawPath(
      Path()
        ..moveTo(cutOutLeft, cutOutTop + borderLength)
        ..lineTo(cutOutLeft, cutOutTop + borderRadius)
        ..arcToPoint(
          Offset(cutOutLeft + borderRadius, cutOutTop),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutLeft + borderLength, cutOutTop),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cutOutRight - borderLength, cutOutTop)
        ..lineTo(cutOutRight - borderRadius, cutOutTop)
        ..arcToPoint(
          Offset(cutOutRight, cutOutTop + borderRadius),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRight, cutOutTop + borderLength),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cutOutRight, cutOutBottom - borderLength)
        ..lineTo(cutOutRight, cutOutBottom - borderRadius)
        ..arcToPoint(
          Offset(cutOutRight - borderRadius, cutOutBottom),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRight - borderLength, cutOutBottom),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cutOutLeft + borderLength, cutOutBottom)
        ..lineTo(cutOutLeft + borderRadius, cutOutBottom)
        ..arcToPoint(
          Offset(cutOutLeft, cutOutBottom - borderRadius),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutLeft, cutOutBottom - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
