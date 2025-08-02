import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isFlashOn = false;
  bool _isScanning = true;
  String? _scannedData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.scanQRCode ?? 'QR-Code scannen'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: _buildScannerView(l10n),
          ),
          Expanded(
            flex: 1,
            child: _buildControlsView(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView(AppLocalizations? l10n) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Camera preview placeholder
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.pointCameraAtQR ?? 'Kamera auf QR-Code richten',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  if (_scannedData != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n?.qrCodeDetected ?? 'QR-Code erkannt!',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Scanning overlay
          if (_isScanning)
            Positioned.fill(
              child: CustomPaint(
                painter: ScannerOverlayPainter(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlsView(AppLocalizations? l10n) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_scannedData != null) ...[
            Text(
              l10n?.scannedData ?? 'Gescannte Daten:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Text(
                _scannedData!,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scannedData == null ? null : () => _processScannedData(l10n),
                  icon: Icon(Icons.group_add),
                  label: Text(l10n?.joinGroup ?? 'Gruppe beitreten'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _simulateScan,
                  icon: Icon(Icons.refresh),
                  label: Text(l10n?.scanAgain ?? 'Erneut scannen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    // In a real implementation, toggle camera flash here
  }

  void _simulateScan() {
    // Simulate scanning a QR code for demo purposes
    setState(() {
      _isScanning = true;
      _scannedData = null;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scannedData = 'https://stammtisch-app.com/invite/demo-group-id-12345';
        });
      }
    });
  }

  void _processScannedData(AppLocalizations? l10n) async {
    if (_scannedData == null) return;

    try {
      // Extract group ID from invite link
      final uri = Uri.parse(_scannedData!);
      if (uri.host == 'stammtisch-app.com' && uri.pathSegments.length >= 2) {
        final groupId = uri.pathSegments.last;
        
        // Join the group
        final groupProvider = Provider.of<GroupProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser != null) {
          // In a real app, this would make an API call to join the group
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.joiningGroup ?? 'Gruppe wird beigetreten...'),
              backgroundColor: Colors.blue,
            ),
          );

          // Simulate joining process
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            Navigator.of(context).pop(true); // Return success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.joinedGroup ?? 'Erfolgreich der Gruppe beigetreten!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.loginRequired ?? 'Anmeldung erforderlich'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.invalidQRCode ?? 'Ungültiger QR-Code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.invalidQRCode ?? 'Ungültiger QR-Code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw scanning line animation
    final scanLineY = size.height * 0.5;
    canvas.drawLine(
      Offset(size.width * 0.2, scanLineY),
      Offset(size.width * 0.8, scanLineY),
      paint,
    );

    // Draw corner brackets
    final cornerSize = 20.0;
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * 0.6,
      height: size.width * 0.6,
    );

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerSize, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerSize),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerSize, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerSize, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerSize, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}