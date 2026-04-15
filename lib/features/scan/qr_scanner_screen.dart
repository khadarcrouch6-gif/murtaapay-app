import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive_utils.dart';
import 'scan_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isDisposed) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // Stop scanning to prevent multiple triggers
        controller.stop();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(data: code),
          ),
        ).then((_) {
          // Restart scanning when coming back
          if (!_isDisposed) {
            controller.start();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Scanner Preview
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // 2. Custom Overlay
          _buildOverlay(context),

          // 3. Header Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Text(
                  l10n.scanQR,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                _buildCircularButton(
                  icon: Icons.flash_on_rounded,
                  onTap: () => controller.toggleTorch(),
                ),
              ],
            ),
          ),

          // 4. Footer Instructions
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 32,
            right: 32,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          l10n.alignQRCode,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // Darkened background with a hole
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: screenWidth * 0.7,
                  height: screenWidth * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Animated Scan Line
        Align(
          alignment: Alignment.center,
          child: Container(
            width: screenWidth * 0.7,
            height: screenWidth * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: _ScanLine(width: screenWidth * 0.7),
          ),
        ),
        
        // Corners decoration
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: screenWidth * 0.7 + 4,
            height: screenWidth * 0.7 + 4,
            child: Stack(
              children: [
                _buildCorner(0, 0, 1, 0, 0, 1),
                _buildCorner(null, 0, 1, 1, 0, 0),
                _buildCorner(0, null, 0, 0, 1, 1),
                _buildCorner(null, null, 0, 1, 1, 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(double? left, double? top, double tr, double tl, double br, double bl) {
    return Positioned(
      left: left,
      top: top,
      right: left == null ? 0 : null,
      bottom: top == null ? 0 : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            bottom: top == null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            right: left == null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(tl * 12),
            topRight: Radius.circular(tr * 12),
            bottomLeft: Radius.circular(bl * 12),
            bottomRight: Radius.circular(br * 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  final double width;
  const _ScanLine({required this.width});

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: _animation.value * widget.width,
              left: 20,
              right: 20,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
