import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  late List<OnboardingData> _pages;

  @override
  void initState() {
    super.initState();
    final state = AppState();
    _pages = [
      OnboardingData(
        title: state.translate("Send Money Home, Instantly", "Lacag u Dir Guriga, Degdeg", ar: "أرسل الأموال إلى المنزل فوراً", de: "Geld sofort nach Hause senden"),
        subtitle: state.translate("Support your family in Somalia with the fastest transfer service.", "Ku taageer qoyskaaga Soomaaliya adeegga ugu xawaaraha badan.", ar: "ادعم عائلتك في الصومال بأسرع خدمة تحويل.", de: "Unterstützen Sie Ihre Familie in Somalia mit dem schnellsten Transferservice."),
        image: "assets/images/logo.png",
      ),
      OnboardingData(
        title: state.translate("Fast & Secure Transfers", "Xawaalad Degdeg ah & Ammaan ah", ar: "تحويلات سريعة وآمنة", de: "Schnelle & sichere Überweisungen"),
        subtitle: state.translate("Bank-level security ensures your money reaches its destination safely.", "Amniga heerka bangiga ayaa hubinaya in lacagtaadu si nabad ah ku gaadho meeshii loogu talagalay.", ar: "أمان بمستوى البنك يضمن وصول أموالك إلى وجهتها بأمان.", de: "Sicherheit auf Bankenniveau sorgt dafür, dass Ihr Geld sicher ans Ziel kommt."),
        image: "assets/images/logo.png",
      ),
      OnboardingData(
        title: state.translate("Send to ZAAD, EVC, eDahab", "U dir ZAAD, EVC, eDahab", ar: "أرسل إلى ZAAD ، EVC ، eDahab", de: "Senden an ZAAD, EVC, eDahab"),
        subtitle: state.translate("Direct transfers to all major Somali mobile money platforms.", "Xawilaad toos ah dhammaan barmaamijyada lacagaha gacanta ee Soomaaliya.", ar: "تحويلات مباشرة إلى جميع منصات الأموال المحمولة الصومالية الرئيسية.", de: "Direkte Überweisungen an alle wichtigen somalischen Mobile-Money-Plattformen."),
        image: "assets/images/logo.png",
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 1000,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => isLastPage = index == _pages.length - 1);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: _pages[index]);
                  },
                ),
                Positioned(
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                  left: context.horizontalPadding,
                  right: context.horizontalPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: AppColors.primaryDark,
                          dotColor: AppColors.grey,
                          dotHeight: 8 * context.fontSizeFactor,
                          dotWidth: 8 * context.fontSizeFactor,
                          expansionFactor: 4,
                        ),
                      ),
                      FadeInRight(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120 * context.fontSizeFactor, 56 * context.fontSizeFactor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isLastPage ? AppState().translate("Get Started", "Bilow Hadda", ar: "ابدأ الآن", de: "Loslegen") : AppState().translate("Next", "Xiga", ar: "التالي", de: "Nächste"), 
                            style: TextStyle(fontSize: 14 * context.fontSizeFactor)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String image;

  OnboardingData({required this.title, required this.subtitle, required this.image});
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: Image.asset(
                      data.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200 * context.fontSizeFactor,
                        width: 200 * context.fontSizeFactor,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.image_not_supported_rounded, size: 100 * context.fontSizeFactor, color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: (MediaQuery.of(context).size.width > 600 ? 36 : 28) * context.fontSizeFactor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey,
                      fontSize: (MediaQuery.of(context).size.width > 600 ? 20 : 16) * context.fontSizeFactor,
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Boos loogu talagalay badhamada hoose
              ],
            ),
          ),
        ),
      ),
    );
  }
}

