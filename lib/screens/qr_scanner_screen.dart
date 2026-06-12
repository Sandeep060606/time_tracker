import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/scanner_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isHandling = false;
  bool _isCoolingDown = false;
  int _sessionScanCount = 0;
  String _statusMessage = 'Ready to scan';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_isHandling || _isCoolingDown) {
      return;
    }
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (value == null || value.trim().isEmpty) {
      _showMessage('Invalid QR code.');
      return;
    }

    _isHandling = true;
    _isCoolingDown = true;
    setState(() => _statusMessage = 'Processing scan...');
    try {
      await _controller.stop();
    } catch (_) {}
    if (!mounted) {
      return;
    }

    try {
      final result = await context.read<ScannerProvider>().processScan(value);
      if (!mounted) {
        return;
      }
      setState(() {
        _sessionScanCount += 1;
        _statusMessage = 'Scanned ${result.history.studentQr}';
      });
      Fluttertoast.showToast(msg: 'Scan successful');
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = _cleanMessage(error.toString());
      setState(() => _statusMessage = message);
      if (_isAlreadyScannedMessage(message)) {
        _showAlreadyScannedDialog(message);
      } else {
        _showMessage(message);
      }
    } finally {
      await _restartAfterCooldown();
    }
  }

  Future<void> _restartAfterCooldown() async {
    if (mounted) {
      setState(() => _statusMessage = 'Next scan starts in 1 seconds...');
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    try {
      await _controller.start();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isHandling = false;
        _isCoolingDown = false;
        _statusMessage = 'Ready to scan next card';
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_cleanMessage(message))));
  }

  void _showAlreadyScannedDialog(String message) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Already scanned'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isAlreadyScannedMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('already scanned') || lower.contains('duplicate');
  }

  String _cleanMessage(String message) {
    return message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ScanException: ', '');
  }

  void _openHistory() {
    context.read<NavigationProvider>().setIndex(1);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Scan QR Code',
        actions: [
          IconButton(
            tooltip: 'Toggle torch',
            onPressed: _controller.toggleTorch,
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _controller.switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleCapture,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      size: 72,
                      color: Colors.black38,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera unavailable',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.errorDetails?.message ??
                          'Camera permission denied or camera is in use.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 18),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Card(
              color: Colors.black.withValues(alpha: 0.72),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isCoolingDown
                              ? Icons.hourglass_top_rounded
                              : Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$_sessionScanCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _openHistory,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Submit Complete'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
