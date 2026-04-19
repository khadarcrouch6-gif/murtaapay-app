import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> with WidgetsBindingObserver {
  int _currentStep = -1; // -1: Intro, 0: Info, 1: Selection, 2: Scan, 3: Face, 4: Result
  bool _isFrontScanned = false;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitializing = false;
  bool _isVerifying = false;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); 
  
  final _streetController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Real-time states
  String _scanStatus = "";
  double _captureProgress = 0.0;
  Timer? _captureTimer;
  int _livenessStep = 0; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_currentStep >= 2) _startCamera(_controller!.description.lensDirection);
    }
  }

  void _disposeCamera() {
    _captureTimer?.cancel();
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _startCamera(CameraLensDirection direction) async {
    if (_isCameraInitializing) return;
    setState(() => _isCameraInitializing = true);
    try {
      _cameras ??= await availableCameras();
      CameraDescription selectedCamera = _cameras!.firstWhere((c) => c.lensDirection == direction, orElse: () => _cameras![0]);
      if (_controller != null) await _controller!.dispose();
      _controller = CameraController(selectedCamera, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitializing = false);
        _startAutoCaptureLogic();
      }
    } catch (e) {
      if (mounted) setState(() => _isCameraInitializing = false);
    }
  }

  void _startAutoCaptureLogic() {
    _captureProgress = 0.0;
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || _currentStep < 2 || _isVerifying || _controller == null || !_controller!.value.isInitialized) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_captureProgress < 1.0) {
          _captureProgress += 0.04;
          _updateScanStatus(AppLocalizations.of(context)!);
        } else {
          timer.cancel();
          _handleAutoCapture();
        }
      });
    });
  }

  void _updateScanStatus(AppLocalizations l10n) {
    if (_currentStep == 2) {
      _scanStatus = _captureProgress < 0.5 ? l10n.alignId : l10n.capturing;
    } else if (_currentStep == 3) {
      _scanStatus = _livenessStep == 0 ? l10n.lookStraight : (_livenessStep == 1 ? l10n.lookLeft : l10n.lookRight);
    }
  }

  void _handleAutoCapture() {
    if (_currentStep == 2) {
      if (!_isFrontScanned) {
        setState(() { _isFrontScanned = true; _captureProgress = 0.0; });
        _startAutoCaptureLogic();
      } else {
        setState(() { _currentStep = 3; _captureProgress = 0.0; });
        _startCamera(CameraLensDirection.front);
      }
    } else if (_currentStep == 3) {
      if (_livenessStep < 2) {
        setState(() { _livenessStep++; _captureProgress = 0.0; });
        _startAutoCaptureLogic();
      } else {
        _submitToVerification();
      }
    }
  }

  Future<void> _submitToVerification() async {
    _disposeCamera();
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() { _isVerifying = false; _currentStep = 4; });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _houseNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _currentStep == 2 || _currentStep == 3 ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.identityVerification, style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [TextButton(onPressed: () {}, child: Text(l10n.help, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)))],
      ),
      body: _isVerifying ? _buildLoading(l10n) : _buildContent(l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    switch (_currentStep) {
      case -1: return _buildIntro(l10n);
      case 0: return _buildPersonalInfo(l10n);
      case 1: return _buildDocSelection(l10n);
      case 2: return _buildCamera(l10n, isDoc: true);
      case 3: return _buildCamera(l10n, isDoc: false);
      case 4: return _buildResult(l10n);
      default: return Container();
    }
  }

  Widget _buildIntro(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(),
                  FadeInDown(child: Icon(Icons.shield_rounded, size: 80, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 40),
                  Text(l10n.verifyYourIdentity, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(l10n.verifyIdentityDesc, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7), height: 1.5)),
                  const SizedBox(height: 40),
                  _buildIntroStep(Icons.badge_outlined, l10n.prepareIdDoc),
                  _buildIntroStep(Icons.light_mode_outlined, l10n.wellLitArea),
                  _buildIntroStep(Icons.phonelink_ring_outlined, l10n.followInstructions),
                  const Spacer(),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => setState(() => _currentStep = 0), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.letsGetStarted, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 20),
                  Text(l10n.encryptedConnection, style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildIntroStep(IconData icon, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(children: [Icon(icon, color: AppColors.accentTeal, size: 24), const SizedBox(width: 16), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)))]));
  }

  Widget _buildPersonalInfo(AppLocalizations l10n) {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(1, 4, "25%"),
              const SizedBox(height: 24),
              Text(l10n.personalDetails, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 32),
              _buildField(_nameController, l10n.fullName, l10n),
              _buildField(_emailController, l10n.emailAddress, l10n),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _phoneController, 
                      l10n.phoneLabel, 
                      l10n, 
                      isPhone: true, 
                      prefix: "+252 ",
                    ),
                  ), 
                  const SizedBox(width: 16), 
                  Expanded(child: _buildField(_streetController, l10n.city, l10n))
                ]
              ),
              _buildField(_addressController, l10n.residentialAddress, l10n),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () { if(_formKey.currentState!.validate()) setState(() => _currentStep = 1); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.continueLabel, style: const TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, AppLocalizations l10n, {bool isPhone = false, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), 
      child: TextFormField(
        controller: ctrl, 
        maxLength: isPhone ? 9 : null,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label, 
          counterText: "",
          prefixIcon: prefix != null 
            ? Padding(
                padding: const EdgeInsets.only(left: 12, top: 14),
                child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
        ), 
        validator: (v) {
          if (v == null || v.isEmpty) return l10n.required;
          if (isPhone && v.length != 9) return l10n.phoneLengthError;
          return null;
        }
      )
    );
  }

  Widget _buildDocSelection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2, 4, "50%"),
          const SizedBox(height: 24),
          Text(l10n.chooseDocumentType, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          _docCard(l10n.passport, Icons.public, l10n),
          _docCard(l10n.nationalIdCard, Icons.badge, l10n),
          _docCard(l10n.driversLicense, Icons.drive_eta, l10n),
          const Spacer(),
          Center(child: Column(children: [const Icon(Icons.lock_outline, color: AppColors.accentTeal), const SizedBox(height: 8), Text(l10n.bankGradeEncryption, style: const TextStyle(fontWeight: FontWeight.bold)), Text(l10n.dataDeletedNotice, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12))])),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _docCard(String title, IconData icon, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () { setState(() { _currentStep = 2; }); _startCamera(CameraLensDirection.back); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), 
        padding: const EdgeInsets.all(20), 
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
        ), 
        child: Row(children: [Icon(icon, color: theme.primaryColor), const SizedBox(width: 16), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(), const Icon(Icons.chevron_right, color: Colors.grey)])
      )
    );
  }

  Widget _buildCamera(AppLocalizations l10n, {required bool isDoc}) {
    return Stack(
      children: [
        if (_controller != null && _controller!.value.isInitialized) Positioned.fill(child: CameraPreview(_controller!)),
        _buildCameraOverlay(isDoc),
        SafeArea(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)), Text(isDoc ? l10n.frontOfIdCard : l10n.verification, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Icon(Icons.help_outline, color: Colors.white)])),
              const SizedBox(height: 20),
              if (!isDoc) ...[Text(l10n.verifyYourFace, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(l10n.positionFaceNotice, style: const TextStyle(color: Colors.white70))],
              const Spacer(),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: _captureProgress > 0 ? AppColors.accentTeal : Colors.white, size: 12), const SizedBox(width: 8), Text(_scanStatus, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
              const SizedBox(height: 40),
              Stack(alignment: Alignment.center, children: [SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: _captureProgress, strokeWidth: 6, color: AppColors.accentTeal)), Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(isDoc ? Icons.camera_alt : Icons.face, color: AppColors.primaryDark))]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraOverlay(bool isDoc) {
    return LayoutBuilder(builder: (c, constraints) {
      double w = constraints.maxWidth;
      return ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.7), BlendMode.srcOut),
        child: Stack(children: [Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)), Center(child: Container(width: isDoc ? w * 0.85 : w * 0.7, height: isDoc ? (w * 0.85) / 1.58 : w * 0.9, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(isDoc ? 20 : 200))))]),
      );
    });
  }

  Widget _buildResult(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          FadeInDown(child: Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2), width: 4)), child: const Icon(Icons.access_time_filled_rounded, size: 80, color: AppColors.accentTeal))),
          const SizedBox(height: 40),
          Text(l10n.verificationPending, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text(l10n.verificationPendingDesc, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7), height: 1.5)),
          const SizedBox(height: 40),
          _buildResultStatus(Icons.fact_check_outlined, l10n.documentCheck, l10n.scanningForClarity),
          _buildResultStatus(Icons.face_unlock_outlined, l10n.biometricMatch, l10n.comparingSelfie),
          const Spacer(),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.returnToHome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 20),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified_user, size: 14, color: Colors.grey), SizedBox(width: 8), Text("Sovereign Institutional-Grade Security", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildResultStatus(IconData icon, String title, String sub) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16), 
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
      ), 
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color?.withValues(alpha: 0.5)), 
          const SizedBox(width: 16), 
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))]), 
          const Spacer(), 
          const Icon(Icons.sync, color: AppColors.accentTeal, size: 18)
        ]
      )
    );
  }

  Widget _buildStepIndicator(int current, int total, String percent) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("STEP $current OF $total", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)), Text(percent, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accentTeal))]);
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(color: AppColors.accentTeal), const SizedBox(height: 24), Text(l10n.verifyingIdentity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]));
  }
}
