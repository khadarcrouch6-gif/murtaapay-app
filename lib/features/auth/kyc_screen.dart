import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> with WidgetsBindingObserver {
  int _currentStep = -1; // -1: Intro, 0: Info, 1: Selection, 2: Scan, 3: Face, 4: Result
  String _selectedDocType = "";
  bool _isFrontScanned = false;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitializing = false;
  bool _isVerifying = false;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); // Fixed missing controller
  
  String? _selectedCountry;
  String? _selectedCity;
  final _streetController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Real-time states
  String _scanStatus = "";
  double _captureProgress = 0.0;
  Timer? _captureTimer;
  int _livenessStep = 0; 
  bool _showWarning = false;

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
      if (_cameras == null) _cameras = await availableCameras();
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
          _updateScanStatus();
        } else {
          timer.cancel();
          _handleAutoCapture();
        }
      });
    });
  }

  void _updateScanStatus() {
    final state = AppState();
    if (_currentStep == 2) {
      _scanStatus = _captureProgress < 0.5 ? state.translate("Align your ID", "Toosi ID-ga") : state.translate("Capturing...", "Waa la qabanayaa...");
    } else if (_currentStep == 3) {
      _scanStatus = _livenessStep == 0 ? "Look Straight" : (_livenessStep == 1 ? "Look Left" : "Look Right");
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
    final state = AppState();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentStep == 2 || _currentStep == 3 ? null : AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: Text(state.translate("Identity Verification", "Xaqiijinta Aqoonsiga"), style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [TextButton(onPressed: () {}, child: Text(state.translate("Help", "Caawinaad"), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)))],
      ),
      body: _isVerifying ? _buildLoading() : _buildContent(state),
    );
  }

  Widget _buildContent(AppState state) {
    switch (_currentStep) {
      case -1: return _buildIntro(state);
      case 0: return _buildPersonalInfo(state);
      case 1: return _buildDocSelection(state);
      case 2: return _buildCamera(state, isDoc: true);
      case 3: return _buildCamera(state, isDoc: false);
      case 4: return _buildResult(state);
      default: return Container();
    }
  }

  Widget _buildIntro(AppState state) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          FadeInDown(child: const Icon(Icons.shield_rounded, size: 80, color: AppColors.primaryDark)),
          const SizedBox(height: 40),
          Text(state.translate("Verify Your Identity", "Xaqiiji Aqoonsigaaga"), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text(state.translate("We need to verify your identity to keep your account secure. This only takes 2 minutes.", "Waxaan u baahanahay inaan xaqiijino aqoonsigaaga si aan koontadaada u ilaalino."), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 40),
          _buildIntroStep(Icons.badge_outlined, state.translate("Prepare your ID document", "Diyaari dukumiintigaaga")),
          _buildIntroStep(Icons.light_mode_outlined, state.translate("Make sure you're in a well-lit area", "Hubi inaad joogto meel iftiimaysa")),
          _buildIntroStep(Icons.phonelink_ring_outlined, state.translate("Follow the on-screen instructions", "Raac tilmaamaha shaashadda")),
          const Spacer(),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => setState(() => _currentStep = 0), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(state.translate("Let's Get Started", "Aan Bilowno"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 20),
          Text(state.translate("ENCRYPTED & SECURE CONNECTION", "XOGTU WAA AMAAN"), style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIntroStep(IconData icon, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(children: [Icon(icon, color: AppColors.accentTeal, size: 24), const SizedBox(width: 16), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)))]));
  }

  Widget _buildPersonalInfo(AppState state) {
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
              const Text("Personal Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 32),
              _buildField(_nameController, "Full Name"),
              _buildField(_emailController, "Email Address"),
              Row(children: [Expanded(child: _buildField(_phoneController, "Phone")), const SizedBox(width: 16), Expanded(child: _buildField(_streetController, "City"))]),
              _buildField(_addressController, "Residential Address"),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () { if(_formKey.currentState!.validate()) setState(() => _currentStep = 1); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: TextFormField(controller: ctrl, decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v!.isEmpty ? "Required" : null));
  }

  Widget _buildDocSelection(AppState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2, 4, "50%"),
          const SizedBox(height: 24),
          const Text("Choose Document Type", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          _docCard("Passport", Icons.public, state),
          _docCard("National ID Card", Icons.badge, state),
          _docCard("Driver's License", Icons.drive_eta, state),
          const Spacer(),
          Center(child: Column(children: [const Icon(Icons.lock_outline, color: AppColors.accentTeal), const SizedBox(height: 8), const Text("Bank-grade encryption", style: TextStyle(fontWeight: FontWeight.bold)), Text("Your data is deleted after verification", style: TextStyle(color: Colors.grey[500], fontSize: 12))])),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _docCard(String title, IconData icon, AppState state) {
    return GestureDetector(
      onTap: () { setState(() { _selectedDocType = title; _currentStep = 2; }); _startCamera(CameraLensDirection.back); },
      child: Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)), child: Row(children: [Icon(icon, color: AppColors.primaryDark), const SizedBox(width: 16), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(), const Icon(Icons.chevron_right, color: Colors.grey)]))
    );
  }

  Widget _buildCamera(AppState state, {required bool isDoc}) {
    return Stack(
      children: [
        if (_controller != null && _controller!.value.isInitialized) Positioned.fill(child: CameraPreview(_controller!)),
        _buildCameraOverlay(isDoc),
        SafeArea(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)), Text(isDoc ? "Front of ID Card" : "Verification", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Icon(Icons.help_outline, color: Colors.white)])),
              const SizedBox(height: 20),
              if (!isDoc) ...[const Text("Verify your face", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text("Position your face well-lit and clearly", style: TextStyle(color: Colors.white70))],
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
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
        child: Stack(children: [Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)), Center(child: Container(width: isDoc ? w * 0.85 : w * 0.7, height: isDoc ? (w * 0.85) / 1.58 : w * 0.9, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(isDoc ? 20 : 200))))]),
      );
    });
  }

  Widget _buildResult(AppState state) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          FadeInDown(child: Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: AppColors.accentTeal.withOpacity(0.2), width: 4)), child: const Icon(Icons.access_time_filled_rounded, size: 80, color: AppColors.accentTeal))),
          const SizedBox(height: 40),
          const Text("Verification Pending", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text(state.translate("Your documents are being reviewed. This usually takes 10-15 minutes. We'll notify you once it's complete.", "Dukumiintigaaga waa la baarayaa. Waxay qaadanaysaa 10-15 daqiiqo."), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 40),
          _buildResultStatus(Icons.fact_check_outlined, "Document Check", "Scanning for clarity"),
          _buildResultStatus(Icons.face_unlock_outlined, "Biometric Match", "Comparing selfie with ID"),
          const Spacer(),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Return to Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 20),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified_user, size: 14, color: Colors.grey), SizedBox(width: 8), Text("Sovereign Institutional-Grade Security", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildResultStatus(IconData icon, String title, String sub) {
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, color: Colors.grey), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey))]), const Spacer(), const Icon(Icons.sync, color: AppColors.accentTeal, size: 18)]));
  }

  Widget _buildStepIndicator(int current, int total, String percent) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("STEP $current OF $total", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)), Text(percent, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accentTeal))]);
  }

  Widget _buildLoading() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(color: AppColors.accentTeal), const SizedBox(height: 24), const Text("Verifying Identity...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]));
  }
}
