import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/api_service.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  final TextEditingController _amountController = TextEditingController(text: "100");
  String _fromCurrency = "USD";
  String _toCurrency = "EUR";
  bool _isLoading = true;

  final Map<String, double> _rates = {
    "USD": 1.0,
    "EUR": 0.93,
    "GBP": 0.79,
    "CAD": 1.35,
    "KES": 128.50,
    "SOS": 570.00,
  };

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    final newRates = await ApiService.fetchAllRates();
    if (mounted) {
      setState(() {
        _rates.addAll(newRates);
        _isLoading = false;
      });
    }
  }

  final Map<String, String> _flagCodes = {
    "USD": "us",
    "EUR": "eu",
    "GBP": "gb",
    "CAD": "ca",
  };

  Widget _buildFlag(String currency, {double width = 28, double height = 20}) {
    final Map<String, String> flagMap = {
      "USD": "us", "EUR": "eu", "GBP": "gb", "CAD": "ca", "KES": "ke", "SOS": "so",
      "AED": "ae", "SAR": "sa", "TRY": "tr", "ETB": "et", "DJF": "dj", "UGX": "ug",
      "TZS": "tz", "RWF": "rw", "SDG": "sd", "EGP": "eg", "INR": "in", "CNY": "cn",
      "JPY": "jp", "AUD": "au", "CHF": "ch", "ZAR": "za",
    };
    final code = flagMap[currency] ?? "un";
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Image.network(
        "https://flagcdn.com/w40/$code.png",
        width: width, height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.flag_rounded, size: 18, color: Colors.white),
      ),
    );
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  double _calculateConversion() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double inUsd = amount / _rates[_fromCurrency]!;
    return inUsd * _rates[_toCurrency]!;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(state.translate("Exchange Rates", "Sarifka Lacagta", ar: "أسعار الصرف", de: "Wechselkurse"), 
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: MaxWidthBox(
              maxWidth: 800,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.horizontalPadding,
                  context.horizontalPadding,
                  context.horizontalPadding,
                  120, // Padding to clear the floating navigation bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(child: _buildConverterCard(context, state)),
                    const SizedBox(height: 32),
                    FadeInUp(child: Text(state.translate("Live Market Rates", "Qiimaha Suuqyada", ar: "أسعار السوق المباشرة", de: "Live-Marktkurse"), 
                        style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                    const SizedBox(height: 16),
                    
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.accentTeal))
                    else
                      ..._rates.entries.where((e) => e.key != "USD").take(8).map((e) => 
                        _buildRateItem(context, e.key, e.key, e.value.toStringAsFixed(2), Icons.monetization_on_rounded, Colors.blue, true)
                      ).toList(),
                    
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.translate(
                                "Rates are mid-market rates updated every 15 minutes.",
                                "Qiimayaashu waa kuwa suuqa dhexe waxaana la cusboonaysiiyaa 15 daqiiqo kasta.",
                                ar: "الأسعار هي أسعار السوق المتوسطة ويتم تحديثها كل 15 دقيقة.",
                                de: "Die Kurse sind Mittelkurse, die alle 15 Minuten aktualisiert werden."
                              ),
                              style: TextStyle(fontSize: 12 * context.fontSizeFactor, color: AppColors.grey),
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
      },
    );
  }

  Widget _buildConverterCard(BuildContext context, AppState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.translate("You Convert", "Waxaad Beddelaysaa", ar: "أنت تحول", de: "Sie konvertieren"), 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    _buildCurrencySelector(context, state, _fromCurrency, true),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _swapCurrencies,
                child: Container(
                  height: 44 * context.fontSizeFactor, width: 44 * context.fontSizeFactor,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 28 * context.fontSizeFactor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.translate("You Get", "Waxaad Helaysaa", ar: "تحصل على", de: "Sie erhalten"), 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    _buildCurrencySelector(context, state, _toCurrency, false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8 * context.fontSizeFactor),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.white54),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "= ${_calculateConversion().toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, AppState state, String currency, bool isActive) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(state, isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFlag(currency, width: 28 * context.fontSizeFactor, height: 20 * context.fontSizeFactor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                currency, 
                style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20 * context.fontSizeFactor),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(AppState state, bool isActive) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              state.translate("Select Currency", "Dooro Lacagta", ar: "اختر العملة", de: "Währung wählen"),
              style: TextStyle(
                fontSize: 20 * context.fontSizeFactor,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 600,
                  child: ListView(
                    children: _rates.keys.map((curr) => ListTile(
                      leading: _buildFlag(curr, width: 32 * context.fontSizeFactor, height: 24 * context.fontSizeFactor),
                      title: Text(
                        curr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * context.fontSizeFactor,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (isActive) {
                            _fromCurrency = curr;
                          } else {
                            _toCurrency = curr;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateItem(BuildContext context, String name, String code, String rate, IconData icon, Color color, bool isUp) {
    final theme = Theme.of(context);
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: theme.brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _buildFlag(code, width: 40 * context.fontSizeFactor, height: 28 * context.fontSizeFactor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor, color: theme.colorScheme.primary)),
                  Text("1 USD = $rate $code", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(rate, style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                Row(
                  children: [
                    Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, 
                         color: isUp ? Colors.green : Colors.red, size: 12 * context.fontSizeFactor),
                    Text(isUp ? "+0.2%" : "-0.1%", style: TextStyle(color: isUp ? Colors.green : Colors.red, fontSize: 12 * context.fontSizeFactor)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

