import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
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
        subtitle: state.translate("Support your family in Somali with the fastest transfer service.", "Ku taageer qoyskaaga Soomaaliya adeegga ugu xawaaraha badan.", ar: "ادعم عائلtek في الصومال بأرسع خدمة تحويل.", de: "Unterstützen Sie Ihre Familie in Somalia mit dem schnellsten Transferservice."),
        imagePath: 'assets/images/sending.png',
        color: AppColors.accentTeal,
      ),
      OnboardingData(
        title: state.translate("Fast & Secure Transfers", "Xawaalad Degdeg ah & Ammaan ah", ar: "تحويلات سريعة وآمنة", de: "Schnelle & sichere Überweisungen"),
        subtitle: state.translate("Bank-level security ensures your money reaches its destination safely.", "Amniga heerka bangiga ayaa hubinaya in lacagtaadu si nabad ah ku gaadho meeshii loogu talagalay.", ar: "أمان بمستوى البنك يضمن وصول أموالك إلى وجهتها بأمان.", de: "Sicherheit auf Bankenniveau sorgt dafür, dass Ihr Geld sicher ans Ziel kommt."),
        imagePath: 'assets/images/security.png',
        color: Colors.amberAccent,
      ),
      OnboardingData(
        title: state.translate("Send to ZAAD, EVC, eDahab", "U dir ZAAD, EVC, eDahab", ar: "أرسل إلى ZAAD ، EVC ، eDahab", de: "Senden an ZAAD, EVC, eDahab"),
        subtitle: state.translate("Direct transfers to all major Somali mobile money platforms.", "Xawilaad toos ah dhammaan barmaamijyada lacagaha gacanta ee Soomaaliya.", ar: "تحويلات مباشرة إلى جميع منصات الأموال المحmولة الصومالية الرئيسية.", de: "Direkte Überweisungen an alle wichtigen somalischen Mobile-Money-Plattformen."),
        imagePath: 'assets/images/dire.png', 
        color: Colors.cyanAccent,
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
    final state = AppState();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark,
                  Color(0xFF0F172A),
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FadeInRight(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            state.translate("Skip", "Sii dhaaf", ar: "تخطى", de: "Überspringen"),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                              fontSize: 14 * context.fontSizeFactor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => isLastPage = index == _pages.length - 1);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        data: _pages[index],
                        isSpecial: index == 2,
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(context.horizontalPadding),
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: 120 * context.fontSizeFactor,
                    borderRadius: 24,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SmoothPageIndicator(
                            controller: _controller,
                            count: _pages.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: AppColors.accentTeal,
                              dotColor: Colors.white.withValues(alpha: 0.2),
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
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutQuart,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentTeal,
                                foregroundColor: Colors.white,
                                minimumSize: Size(130 * context.fontSizeFactor, 56 * context.fontSizeFactor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                isLastPage ? state.translate("Get Started", "Bilow Hadda", ar: "ابدأ الآن", de: "Loslegen") : state.translate("Next", "Xiga", ar: "التالي", de: "Nächste"),
                                style: TextStyle(
                                  fontSize: 16 * context.fontSizeFactor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isSpecial;

  const OnboardingPage({super.key, required this.data, this.isSpecial = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  FadeInDown(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 320 * context.fontSizeFactor,
                          borderRadius: 32,
                          blur: 10,
                          alignment: Alignment.center,
                          border: 2,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              data.color.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0.2),
                            ],
                          ),
                          child: data.imagePath.startsWith('http')
                              ? Image.network(
                                  data.imagePath,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (c, e, s) => Icon(Icons.broken_image_rounded, size: 100, color: data.color),
                                )
                              : Image.asset(
                                  data.imagePath,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (c, e, s) => Icon(Icons.image_not_supported_rounded, size: 100, color: data.color),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28 * context.fontSizeFactor,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15 * context.fontSizeFactor,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
