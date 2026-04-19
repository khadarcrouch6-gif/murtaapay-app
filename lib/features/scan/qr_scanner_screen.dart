import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
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
  bool _isReceiveMode = false;

  @override
  void dispose() {
    _isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isDisposed || !mounted) return;
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
          if (!_isDisposed && mounted && !_isReceiveMode) {
            controller.start();
          }
        });
      }
    }
  }

  Future<void> _pickAndAnalyzeImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null && !_isDisposed) {
        final BarcodeCapture? capture = await controller.analyzeImage(image.path);
        
        if (capture == null || capture.barcodes.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Naga raali ahoow, sawirkan ma laha QR code la aqoonsan karo."),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          _onDetect(capture);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Dark background similar to the screenshot
      body: Stack(
        children: [
          // Background Gradient to match the aesthetic
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF1C1C1E),
                ],
              ),
            ),
          ),

          // Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isReceiveMode ? _buildReceiveView(context) : _buildPayView(context),
          ),

          // Header with Toggle
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircularButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      
                      // Toggle Switch
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isReceiveMode = false;
                                  controller.start();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isReceiveMode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Text(
                                  "Pay",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: !_isReceiveMode ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isReceiveMode = true;
                                  controller.stop();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isReceiveMode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Text(
                                  "Receive",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: _isReceiveMode ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings or Flash/Image buttons depending on mode
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isReceiveMode) ...[
                            _buildCircularButton(
                              icon: Icons.image_rounded,
                              onTap: _pickAndAnalyzeImage,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _buildCircularButton(
                            icon: _isReceiveMode ? Icons.settings_rounded : Icons.flash_on_rounded,
                            onTap: () {
                              if (!_isReceiveMode) {
                                controller.toggleTorch();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      key: const ValueKey('pay_view'),
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _onDetect,
        ),
        _buildOverlay(context),
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
    );
  }

  Widget _buildReceiveView(BuildContext context) {
    final state = AppState();
    return Center(
      key: const ValueKey('receive_view'),
      child: FadeIn(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    QrImageView(
                      data: 'https://murtaaxpay.com/pay/${state.walletId}',
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black87,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black87,
                      ),
                    ),
                    // Central 'M' Logo for MurtaaxPay
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "M",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Username
              Text(
                "@${state.walletId}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Scan to get paid by anyone, even if they are not on MurtaaxPay",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Share Button
              ElevatedButton.icon(
                onPressed: () {
                  // Share logic
                },
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text(
                  "Share link",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  minimumSize: const Size(200, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            child: Icon(icon, color: Colors.white, size: 20),
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
