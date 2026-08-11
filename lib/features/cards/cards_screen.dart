import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui' as ui;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import '../../core/models/recurring_payment_model.dart';
import '../../core/models/transaction.dart';
import '../deposit/deposit_card_screen.dart';
import '../../core/widgets/receipt_view.dart';
import '../withdraw/withdraw_screen.dart';
import '../../l10n/app_localizations.dart';
import 'models/card_model.dart';
import 'widgets/elite_virtual_card.dart';
import 'card_statement_screen.dart';
import '../navigation/main_navigation.dart';
import '../../core/widgets/pin_entry_dialog.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  int _verifiedIndex = 0; // Tracks which card is currently unlocked
  bool _showBack = false;
  bool _showNumber = false;
  bool _isSearching = false;
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.mediumImpact();
    setState(() {
      _showBack = !_showBack;
      if (_showBack) _showNumber = false;
    });
  }

  void _toggleShowNumber() {
    HapticFeedback.selectionClick();
    setState(() => _showNumber = !_showNumber);
  }

  void _copyCardNumber(BuildContext context, AppState state) {
    if (state.cards.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: state.cards[_currentIndex].cardNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cardNumberCopied),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.accentTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final filteredTransactions = state.transactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == "All" || tx.category == _selectedFilter;
      
      // Filter by the currently selected card if any cards exist
      bool matchesCard = true;
      if (state.cards.isNotEmpty) {
        final currentCardId = state.cards[_currentIndex].id;
        // Show only transactions specifically for this card
        matchesCard = tx.cardId == currentCardId;
      }
      
      return matchesSearch && matchesFilter && matchesCard;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ResponsiveBreakpoints.of(context).equals(TABLET)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded, color: theme.iconTheme.color),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(context.horizontalPadding, 16, context.horizontalPadding, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.myCards,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24 * context.fontSizeFactor,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  _buildBalanceDisplay(context, state, theme),
                  IconButton(
                    onPressed: () {
                      if (state.cards.isNotEmpty) {
                        _showPinRequiredAction(context, state, () {
                          _showCardSettings(context, state);
                        });
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.settings_outlined, color: theme.colorScheme.primary, size: 22 * context.fontSizeFactor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.cards.isEmpty
                  ? _buildEmptyState(context, state)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 240 * context.fontSizeFactor,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                  _showBack = false;
                                  _showNumber = false;
                                });
                              },
                              itemCount: state.cards.length,
                              itemBuilder: (context, index) {
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    double value = 1.0;
                                    if (_pageController.position.haveDimensions) {
                                      value = _pageController.page! - index;
                                      value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                                    }
                                    return Center(
                                      child: SizedBox(
                                        height: Curves.easeInOut.transform(value) * 240 * context.fontSizeFactor,
                                        width: Curves.easeInOut.transform(value) * MediaQuery.of(context).size.width,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: GestureDetector(
                                    onTap: _flipCard,
                                    child: EliteVirtualCard(
                                      card: state.cards[index],
                                      showBack: _showBack,
                                      showNumber: _showNumber,
                                      onFlip: _flipCard,
                                      onToggleShowNumber: _toggleShowNumber,
                                      onCopyNumber: () => _copyCardNumber(context, state),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: state.cards.length,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8 * context.fontSizeFactor,
                                dotWidth: 8 * context.fontSizeFactor,
                                activeDotColor: theme.colorScheme.primary,
                                dotColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildQuickActions(context, state),
                          const SizedBox(height: 32),
                          _buildTransactionList(context, state, filteredTransactions),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: state.cards.length < 2
          ? FloatingActionButton.extended(
              onPressed: () => _showNewCardDialog(context, state),
              label: Text(l10n.addNewCard),
              icon: const Icon(Icons.add_rounded),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.credit_card_off_rounded, size: 64 * context.fontSizeFactor, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noActiveCards,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.translate("Ma jiraan kaadhadh shaqaynaya hadda. Fadlan sameyso kaadh cusub si aad u bilowdo.", "You don't have any active cards yet. Please create one to get started."),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showNewCardDialog(context, state),
            icon: const Icon(Icons.add_rounded),
            label: Text(state.translate("Sameyso Kaadhkaagii Koowaad", "Create Your First Card")),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (state.terminatedCards.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showRestoreCardDialog(context, state),
              icon: const Icon(Icons.restore_rounded),
              label: Text(state.translate("Soo cesho kaadh hore", "Restore previous card")),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            context,
            Icons.add_circle_outline_rounded,
            l10n.topUp,
            () {
              if (state.cards.isEmpty) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => DepositCardScreen(
                amount: "0", 
                currencyCode: state.currencyCode, 
                cardId: state.cards[_currentIndex].id
              )));
            },
          ),
          _actionButton(
            context,
            Icons.arrow_circle_down_rounded,
            l10n.withdraw,
            () {
              if (state.cards.isEmpty) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawScreen(cardId: state.cards[_currentIndex].id)));
            },
          ),
          _actionButton(
            context,
            Icons.receipt_long_rounded,
            state.translate("Warbixin", "Statement"),
            () {
              if (state.cards.isEmpty) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => CardStatementScreen(card: state.cards[_currentIndex])));
            },
          ),
          _actionButton(
            context,
            Icons.ac_unit_rounded,
            state.cards[_currentIndex].isFrozen ? state.translate("Ka saar barafka", "Unfreeze") : state.translate("Baraf mari", "Freeze"),
            () {
              _showPinRequiredAction(context, state, () {
                final card = state.cards[_currentIndex];
                state.updateCard(_currentIndex, card.copyWith(isFrozen: !card.isFrozen));
              });
            },
            color: state.cards[_currentIndex].isFrozen ? Colors.orange : null,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? theme.colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color ?? theme.colorScheme.primary, size: 24 * context.fontSizeFactor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12 * context.fontSizeFactor,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, AppState state, List<Transaction> transactions) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentTransactions,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  if (state.cards.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CardStatementScreen(card: state.cards[_currentIndex])));
                  }
                },
                child: Text(l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.receipt_outlined, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(l10n.noTransactionsYet, style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionItem(context, tx, isDark, theme);
              },
            ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction tx, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getCategoryColor(tx.category).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(tx.category), color: _getCategoryColor(tx.category), size: 20 * context.fontSizeFactor),
        ),
        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(tx.date, style: TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: Text(
          tx.amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: tx.isNegative ? Colors.redAccent : Colors.greenAccent,
            fontSize: 16,
          ),
        ),
        onTap: () => _showTransactionDetails(context, tx),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shopping': return Icons.shopping_bag_outlined;
      case 'food': return Icons.restaurant_outlined;
      case 'transport': return Icons.directions_bus_outlined;
      case 'entertainment': return Icons.movie_outlined;
      case 'health': return Icons.medical_services_outlined;
      case 'refund': return Icons.replay_circle_filled_outlined;
      case 'subscription': return Icons.subscriptions_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'shopping': return Colors.orange;
      case 'food': return Colors.red;
      case 'transport': return Colors.blue;
      case 'entertainment': return Colors.purple;
      case 'health': return Colors.green;
      case 'refund': return Colors.teal;
      case 'subscription': return Colors.indigo;
      default: return AppColors.primary;
    }
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptView(transaction: tx.toJson()),
    );
  }

  void _showPinRequiredAction(BuildContext context, AppState state, VoidCallback onVerified) async {
    showDialog(
      context: context,
      builder: (context) => PinEntryDialog(
        title: state.translate("Xaqiijinta PIN-ka", "PIN Verification"),
        description: state.translate("Fadlan geli PIN-kaaga si aad u sii waddo.", "Please enter your PIN to continue."),
        onConfirm: (pin) {
          if (state.verifyPin(pin)) {
            onVerified();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.translate("PIN-ku waa khalad", "Incorrect PIN")))
            );
          }
        },
      ),
    );
  }

  void _showCardSettings(BuildContext context, AppState state) {
    if (state.cards.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Consumer<AppState>(
        builder: (context, state, child) {
          final currentCardIndex = state.selectedCardIndex;
          if (currentCardIndex >= state.cards.length) return const SizedBox.shrink();
          final currentCard = state.cards[currentCardIndex];
          
          return GlassmorphicContainer(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.82,
            borderRadius: 24 * context.fontSizeFactor,
            blur: 30,
            alignment: Alignment.topCenter,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                  ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
                  : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
            ),
            borderGradient: LinearGradient(
              colors: [
                (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
                (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.cardSettings,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (currentCard.isFrozen ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: (currentCard.isFrozen ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          currentCard.isFrozen 
                            ? l10n.frozen
                            : l10n.active,
                          style: TextStyle(color: currentCard.isFrozen ? Colors.orange : AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _walletSection(context, state, currentCard),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, l10n.security, isDark),
                        _buildSettingsTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.receipt_long_rounded,
                          color: Colors.teal,
                          title: l10n.cardStatement,
                          subtitle: l10n.viewCardHistory,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => CardStatementScreen(card: currentCard)));
                          },
                        ),
                        _buildSettingsTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.lock_reset_rounded,
                          color: Colors.blueAccent,
                          title: l10n.changePin,
                          subtitle: l10n.updateCardPin,
                          onTap: () {
                            _showNewPinVerification(context, l10n, isTerminate: false, isChangePin: true);
                          },
                        ),
                        _buildSettingsTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.ac_unit_rounded,
                          color: Colors.blue,
                          title: currentCard.isFrozen 
                            ? l10n.unfreezeCard
                            : l10n.freezeCard,
                          subtitle: l10n.temporarilyDisablePayments,
                          onTap: () {
                            // Ask for PIN for freezing/unfreezing
                            _showNewPinVerification(context, l10n, isTerminate: false, customAction: () {
                              state.updateCard(state.selectedCardIndex, currentCard.copyWith(isFrozen: !currentCard.isFrozen));
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, l10n.cardControls, isDark),
                        _buildSettingsTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.subscriptions_rounded,
                          color: Colors.purple,
                          title: l10n.subscriptionManager,
                          subtitle: l10n.manageSubscriptions,
                          onTap: () {
                            _showSubscriptionManager(context, state, currentCard);
                          },
                        ),
                        _buildSwitchTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.shopping_basket_outlined,
                          color: Colors.teal,
                          title: l10n.onlinePayments,
                          value: currentCard.allowOnline,
                          onChanged: (v) {
                            state.updateCard(state.selectedCardIndex, currentCard.copyWith(allowOnline: v));
                          },
                        ),
                        _buildSwitchTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.public_rounded,
                          color: Colors.orange,
                          title: l10n.internationalUsage,
                          value: currentCard.allowInternational,
                          onChanged: (v) {
                            state.updateCard(state.selectedCardIndex, currentCard.copyWith(allowInternational: v));
                          },
                        ),
                        _buildSwitchTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.contactless_rounded,
                          color: Colors.purple,
                          title: l10n.contactlessPayments,
                          value: currentCard.allowContactless,
                          onChanged: (v) {
                            state.updateCard(state.selectedCardIndex, currentCard.copyWith(allowContactless: v));
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, l10n.spendingLimit, isDark),
                        _buildSpendingLimitTile(context, state, currentCard, isDark),
                        const SizedBox(height: 32),
                        _buildSettingsTile(
                          context: context,
                          isDark: isDark,
                          icon: Icons.delete_forever_rounded,
                          color: Colors.redAccent,
                          title: l10n.terminateCard,
                          subtitle: l10n.permanentlyDeleteCard,
                          onTap: () {
                            Navigator.pop(context);
                            _showTerminateReasons(context, l10n, state);
                          },
                          isLast: true,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _walletSection(BuildContext context, AppState state, VirtualCard card) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.translate("Haraaga Kaadhka", "Card Balance"), style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13 * context.fontSizeFactor)),
                  const SizedBox(height: 4),
                  Text("\$${card.balance.toStringAsFixed(2)}", style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DepositCardScreen(
                    amount: "0", 
                    currencyCode: state.cards[state.selectedCardIndex].theme == CardThemeType.gold ? "USD" : "SOS", 
                    cardId: card.id
                  )));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(state.translate("Ku Shub", "Top Up")),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black45, fontSize: 10 * context.fontSizeFactor, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24 * context.fontSizeFactor),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary)),
          subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 12 * context.fontSizeFactor)),
          trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
        ),
        if (!isLast) Divider(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), height: 24),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20 * context.fontSizeFactor),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.accentTeal),
        ],
      ),
    );
  }

  Widget _buildSpendingLimitTile(BuildContext context, AppState state, VirtualCard card, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.translate("Xadka Bisha", "Monthly Limit"), style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13 * context.fontSizeFactor)),
                  const SizedBox(height: 4),
                  Text("\$2,500.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.edit_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: 0.65, backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal), minHeight: 8),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.translate("La isticmaalay: \$1,625.00", "Spent: \$1,625.00"), style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 12 * context.fontSizeFactor)),
              Text("65%", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor)),
            ],
          ),
        ],
      ),
    );
  }

  void _showTerminateReasons(BuildContext context, AppLocalizations l10n, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasons = [
      {"label": l10n.reasonLostStolen},
      {"label": l10n.reasonBetterService},
      {"label": l10n.reasonNotUsed},
      {"label": l10n.reasonHighFees},
      {"label": l10n.reasonSecurityConcerns},
      {"label": l10n.reasonTechnicalIssues},
      {"label": l10n.reasonOther},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassmorphicContainer(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.75,
        borderRadius: 24 * context.fontSizeFactor,
        blur: 30,
        alignment: Alignment.topCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
              : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
        ),
        borderGradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
            (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 12 * context.fontSizeFactor),
            Container(width: 40 * context.fontSizeFactor, height: 4 * context.fontSizeFactor, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10 * context.fontSizeFactor))),
            SizedBox(height: 24 * context.fontSizeFactor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.whyTerminateCard,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20 * context.fontSizeFactor,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.shareReasonImprove,
                style: TextStyle(
                  fontSize: 13 * context.fontSizeFactor,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  final reason = reasons[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _showTerminationTypeSelection(context, l10n, state);
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                      ),
                      title: Text(reason["label"]!, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                      trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerminationTypeSelection(BuildContext context, AppLocalizations l10n, AppState state) {
    // 1. Capture everything needed from context BEFORE showing modal or closing it
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fSizeFactor = context.fontSizeFactor;
    final currentCard = state.cards[_currentIndex];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassmorphicContainer(
        width: double.infinity,
        height: 480 * fSizeFactor,
        borderRadius: 24,
        blur: 30,
        alignment: Alignment.topCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
              : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
        ),
        borderGradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
            (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(
              l10n.selectActionType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20 * fSizeFactor,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            _buildTypeOption(
              theme: theme,
              fontSizeFactor: fSizeFactor,
              icon: Icons.pause_circle_outline_rounded,
              color: Colors.orange,
              title: l10n.deactivateCardTemp,
              description: l10n.deactivateCardDesc,
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(Duration.zero, () {
                  if (mounted) {
                    // Use the captured navigator context which is stable
                    _showNewPinVerification(navigator.context, l10n, isTerminate: false);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTypeOption(
              theme: theme,
              fontSizeFactor: fSizeFactor,
              icon: Icons.delete_forever_rounded,
              color: Colors.redAccent,
              title: l10n.terminatePermanently,
              description: l10n.terminatePermanentlyDesc(currentCard.balance.toStringAsFixed(2)),
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(Duration.zero, () {
                  if (mounted) {
                    // Use the captured navigator context which is stable
                    _showTerminationConfirmationDialog(navigator.context, l10n, state, isDark);
                  }
                });
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextButton(
                onPressed: () => Navigator.pop(sheetCtx),
                child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required ThemeData theme,
    required double fontSizeFactor,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24 * fontSizeFactor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12 * fontSizeFactor, color: isDark ? Colors.white60 : AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }

  void _showTerminationConfirmationDialog(BuildContext context, AppLocalizations l10n, AppState state, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.primaryDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * context.fontSizeFactor)),
          title: Text(
            l10n.confirmTermination,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18 * context.fontSizeFactor,
            ),
          ),
          content: Text(
            l10n.confirmTerminationDesc,
            style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, fontSize: 14 * context.fontSizeFactor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showNewPinVerification(context, l10n, isTerminate: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
              ),
              child: Text(l10n.yesTerminate, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewPinVerification(BuildContext context, AppLocalizations l10n, {required bool isTerminate, VoidCallback? customAction, bool isChangePin = false}) {
    if (!context.mounted) return;
    
    final TextEditingController pinController = TextEditingController();
    final state = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fontSizeFactor = context.fontSizeFactor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 400 * fontSizeFactor,
          borderRadius: 24 * fontSizeFactor,
          blur: 30,
          alignment: Alignment.topCenter,
          border: 2,
          linearGradient: LinearGradient(
            colors: isDark 
                ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
                : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
          ),
          child: Column(
            children: [
              SizedBox(height: 12 * fontSizeFactor),
              Container(width: 40 * fontSizeFactor, height: 4 * fontSizeFactor, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10 * fontSizeFactor))),
              SizedBox(height: 24 * fontSizeFactor),
              Icon(
                isChangePin ? Icons.security_rounded : (isTerminate ? Icons.delete_sweep_rounded : Icons.lock_outline_rounded), 
                color: isChangePin ? Colors.blueAccent : (isTerminate ? Colors.redAccent : Colors.orange), 
                size: 48 * fontSizeFactor
              ),
              SizedBox(height: 16 * fontSizeFactor),
              Text(
                isChangePin 
                  ? l10n.enterCurrentPin
                  : l10n.enterCardPin,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              SizedBox(height: 8 * fontSizeFactor),
              Text(
                isChangePin 
                  ? l10n.enterCurrentPinDesc
                  : l10n.enterPinConfirmAction,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13 * fontSizeFactor),
              ),
              SizedBox(height: 32 * fontSizeFactor),
              SizedBox(
                width: 220 * fontSizeFactor,
                child: TextField(
                  controller: pinController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 28 * fontSizeFactor, letterSpacing: 20 * fontSizeFactor, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "****",
                    hintStyle: TextStyle(letterSpacing: 20 * fontSizeFactor, fontSize: 28 * fontSizeFactor, color: isDark ? Colors.white24 : Colors.black12),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * fontSizeFactor), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) {
                    if (value.length == 4) {
                      final currentCardId = state.cards[state.selectedCardIndex].id;
                      final isValid = isTerminate || isChangePin || customAction != null 
                          ? state.verifyCardPin(value, cardId: currentCardId) 
                          : state.verifyPin(value);

                      if (isValid) {
                        Navigator.pop(sheetCtx);
                        if (isChangePin) {
                          _showSetupNewPin(context, l10n, isChange: true);
                        } else if (customAction != null) {
                          customAction();
                        } else {
                          _processTransaction(context, l10n, isTerminate: isTerminate);
                        }
                      } else {
                        HapticFeedback.vibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.incorrectPin),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        pinController.clear();
                      }
                    }
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetupNewPin(BuildContext context, AppLocalizations l10n, {bool isChange = false}) {
    final TextEditingController pinController = TextEditingController();
    final state = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 400 * context.fontSizeFactor,
          borderRadius: 24,
          blur: 30,
          alignment: Alignment.topCenter,
          border: 2,
          linearGradient: LinearGradient(
            colors: isDark 
                ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
                : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Icon(isChange ? Icons.lock_outline_rounded : Icons.lock_reset_rounded, color: AppColors.accentTeal, size: 48 * context.fontSizeFactor),
              const SizedBox(height: 16),
              Text(
                isChange 
                  ? state.translate("Beddel PIN-ka", "Change PIN")
                  : state.translate("Samee PIN Cusub", "Set New PIN"),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                isChange
                  ? state.translate("Fadlan geli 4 god oo PIN cusub ah.", "Please enter a new 4-digit PIN.")
                  : state.translate("U samee PIN gaar ah kaadhkaaga virtual-ka ah.", "Set a unique PIN for your virtual card."),
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13 * context.fontSizeFactor),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220 * context.fontSizeFactor,
                child: TextField(
                  controller: pinController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 28 * context.fontSizeFactor, letterSpacing: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "****",
                    hintStyle: TextStyle(letterSpacing: 20 * context.fontSizeFactor, fontSize: 28 * context.fontSizeFactor, color: isDark ? Colors.white24 : Colors.black12),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) {
                    if (value.length == 4) {
                      if (isChange) {
                        final currentCard = state.cards[state.selectedCardIndex];
                        if (state.verifyCardPin(value, cardId: currentCard.id)) {
                          HapticFeedback.vibrate();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.translate(
                                "PIN-kani waa kii hadda. Fadlan dooro PIN cusub.", 
                                "This is your current PIN. Please choose a new PIN."
                              )),
                            ),
                          );
                          pinController.clear();
                        } else {
                          state.updateCardPin(value, cardId: currentCard.id);
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.translate("PIN-ka si guul leh ayaa loo beddelay!", "PIN changed successfully!")),
                              backgroundColor: AppColors.accentTeal,
                            ),
                          );
                        }
                      } else {
                        final currentCard = state.cards[state.selectedCardIndex];
                        state.updateCardPin(value, cardId: currentCard.id);
                        Navigator.pop(sheetCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.translate("PIN-ka waa la keydiyay!", "PIN saved successfully!")),
                            backgroundColor: AppColors.accentTeal,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processTransaction(BuildContext context, AppLocalizations l10n, {required bool isTerminate}) async {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 220 * context.fontSizeFactor,
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 65 * context.fontSizeFactor,
                        height: 65 * context.fontSizeFactor,
                        child: CircularProgressIndicator(color: isTerminate ? Colors.redAccent : Colors.orange, strokeWidth: 3),
                      ),
                      Icon(isTerminate ? Icons.delete_sweep_rounded : Icons.pause_circle_filled_rounded, color: isTerminate ? Colors.redAccent : Colors.orange, size: 32 * context.fontSizeFactor),
                    ],
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(
                    l10n.processing, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color, decoration: TextDecoration.none)
                  ),
                  SizedBox(height: 8 * context.fontSizeFactor),
                  Text(
                    l10n.justAMoment,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13 * context.fontSizeFactor, color: AppColors.grey, decoration: TextDecoration.none)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    HapticFeedback.vibrate();
    _audioPlayer.play(AssetSource('sounds/success.mp3'));
    Navigator.of(context, rootNavigator: true).pop();

    if (isTerminate) {
      final oldIndex = appState.selectedCardIndex;
      if (oldIndex >= appState.cards.length) return;
      final cardToTerminate = appState.cards[oldIndex];
      final refundAmount = cardToTerminate.balance;
      
      // Update app state first
      appState.addBalance(refundAmount);
      
      // Add transaction to the history
      final now = DateTime.now();
      final tx = Transaction(
        id: "TX-REF-${now.millisecondsSinceEpoch}",
        title: appState.translate("Refund: Kaadhka la tirtiray", "Refund: Card Terminated"),
        date: "${now.day}/${now.month}/${now.year}",
        timestamp: now,
        amount: "+\$${refundAmount.toStringAsFixed(2)}",
        numericAmount: refundAmount,
        isNegative: false,
        category: "Refund",
        status: "Success",
        type: "deposit",
        method: "Virtual Card",
        purpose: "Card Termination Refund",
        referenceId: cardToTerminate.id,
      );
      appState.addTransaction(tx);

      appState.removeCard(oldIndex);
      
      // Update local index to prevent out-of-bounds
      if (mounted) {
        setState(() {
          if (_currentIndex >= appState.cards.length && appState.cards.isNotEmpty) {
            _currentIndex = appState.cards.length - 1;
          } else if (appState.cards.isEmpty) {
            _currentIndex = 0;
          }
        });
      }
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            title: appState.translate("Kaadhka waa la tirtiray", "Card Terminated"),
            message: appState.translate(
              "Kaadhkaaga si joogto ah ayaa loo tirtiray.", 
              "Your card has been permanently terminated."
            ),
            subMessage: appState.translate(
              "Haraagii kaadhka oo ahaa \$${refundAmount.toStringAsFixed(2)} waxaa si guul leh loogu wareejiyay Wallet-kaaga.",
              "The card balance of \$${refundAmount.toStringAsFixed(2)} has been successfully transferred to your wallet."
            ),
            buttonText: l10n.backToHome,
            onPressed: () {
              appState.setNavIndex(3); // 3 is Cards
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MainNavigation()),
                (route) => false,
              );
            },
          ),
        ),
        (route) => false,
      );
    } else {
      final currentCard = appState.cards[_currentIndex];
      appState.updateCard(_currentIndex, currentCard.copyWith(isFrozen: true));
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            title: appState.translate("Waa la Demiya", "Card Deactivated"),
            message: appState.translate("Kaadhkaaga si guul leh ayaa loo demiyay.", "Your card has been successfully deactivated."),
            buttonText: l10n.backToHome,
            onPressed: () {
              appState.setNavIndex(3); // 3 is Cards
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MainNavigation()),
                (route) => false,
              );
            },
          ),
        ),
        (route) => false,
      );
    }
  }

  void _showTerminateConfirmation(BuildContext context, AppLocalizations l10n) {
    // This is now handled through PIN verification flow
  }

  Widget _buildBalanceDisplay(BuildContext context, AppState state, ThemeData theme) {
    final currencyFormatter = NumberFormat.simpleCurrency(name: state.currencyCode);
    final currentCardIndex = state.selectedCardIndex;
    if (state.cards.isEmpty || currentCardIndex >= state.cards.length) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        currencyFormatter.format(state.cards[currentCardIndex].balance),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showNewCardDialog(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context)!;
    
    if (state.cards.length >= 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              Text(state.translate("Card Limit Reach", "Xadka Kaadhka")),
            ],
          ),
          content: Text(
            state.translate(
              "You can only have a maximum of 2 virtual cards at a time. Please terminate an existing card to order a new one.",
              "Waxa aad yeelan kartaa ugu badnaan 2 kaadh oo keliya. Fadlan tirtir mid ka mid ah kuwa hadda kuu furan si aad u dalbato mid cusub."
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(state.translate("Understood", "Waan fahmay")),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassmorphicContainer(
        width: double.infinity,
        height: 320,
        borderRadius: 24,
        blur: 30,
        alignment: AlignmentDirectional.topCenter,
        border: 2,
        linearGradient: LinearGradient(colors: [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]),
        borderGradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)]),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(l10n.addNewCard, style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context: context, 
                    icon: Icons.add_card_rounded, 
                    color: AppColors.accentTeal, 
                    title: l10n.orderVirtualCard, 
                    subtitle: l10n.instantlyIssueNewCard, 
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _createNewVirtualCard(context, state);
                    }, 
                    isLast: state.terminatedCards.isEmpty,
                    isDark: true
                  ),
                  if (state.terminatedCards.isNotEmpty)
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.restore_rounded,
                      color: Colors.orange,
                      title: state.translate("Soo cesho Kaadh", "Restore Card"),
                      subtitle: state.translate("Ka soo cesho kaadhka tirtiran", "Recover recently terminated card"),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _showRestoreCardDialog(context, state);
                      },
                      isLast: true,
                      isDark: true
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionManager(BuildContext context, AppState state, VirtualCard card) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final subscriptions = state.recurringPayments.where((p) => p.cardId == card.id).toList();
          
          return GlassmorphicContainer(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.75,
            borderRadius: 24,
            blur: 30,
            alignment: Alignment.topCenter,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                  ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
                  : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
            ),
            borderGradient: LinearGradient(
              colors: [
                (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
                (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(
                  state.translate("Maareeyaha Is-qorista", "Subscription Manager"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  state.translate("Adeegyada ku xidhan kaadhkan", "Services linked to this card"),
                  style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13 * context.fontSizeFactor),
                ),
                const SizedBox(height: 24),
                if (subscriptions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.subscriptions_outlined, size: 64, color: isDark ? Colors.white10 : Colors.black12),
                          const SizedBox(height: 16),
                          Text(
                            state.translate("Ma jiraan is-qoris ku xidhan kaadhkan", "No subscriptions linked to this card"),
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final sub = subscriptions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.subscriptions, color: Colors.purple),
                            ),
                            title: Text(sub.title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            subtitle: Text("\$${sub.amount.toStringAsFixed(2)} / ${sub.frequency}", style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
                            trailing: Switch(
                              value: sub.status == RecurringStatus.active,
                              onChanged: (v) {
                                state.toggleRecurringPayment(sub.id);
                                setModalState(() {});
                              },
                              activeColor: AppColors.accentTeal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _createNewVirtualCard(BuildContext context, AppState state) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Enforce 2-card limit
    if (state.cards.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.translate("Ma abuuri kartid wax ka badan laba kaadh oo virtual ah.", "You cannot create more than two virtual cards.")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user has enough balance for a new card ($5 fee)
    if (state.balance < 5.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.translate("Dhibka: Baaqigaagu kuma filna (\$5 fee).", "Error: Insufficient balance (\$5 fee).")), backgroundColor: Colors.red),
      );
      return;
    }

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    // Deduct fee
    state.deductBalance(5.0);

    // Create new card
    final newCard = VirtualCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardNumber: "4${(100000000000000 + (DateTime.now().millisecondsSinceEpoch % 900000000000000)).toString()}",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "10/30",
      cvv: (100 + (DateTime.now().millisecondsSinceEpoch % 900)).toString(),
      theme: CardThemeType.values[state.cards.length % CardThemeType.values.length],
      network: CardNetwork.visa,
    );

    state.addCard(newCard);
    
    // Play success sound
    _audioPlayer.play(AssetSource('sounds/success.mp3'));

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          title: state.translate("Kaadhka waa la sameeyay", "Card Created"),
          message: state.translate("Kaadhkaaga cusub hadda waa diyaar.", "Your new virtual card is now ready."),
          buttonText: l10n.backToHome,
          onPressed: () {
            state.setNavIndex(3); // 3 is Cards
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainNavigation()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  void _showRestoreCardDialog(BuildContext context, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassmorphicContainer(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.6,
        borderRadius: 24,
        blur: 30,
        alignment: Alignment.topCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
              : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
        ),
        borderGradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
            (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(
              state.translate("Soo cesho Kaadhka", "Restore Card"),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              state.translate("Dooro kaadhka aad rabto inaad soo celiso", "Select the card you want to restore"),
              style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 13 * context.fontSizeFactor),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.terminatedCards.length,
                itemBuilder: (context, index) {
                  final card = state.terminatedCards[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.credit_card, color: AppColors.accentTeal),
                      ),
                      title: Text(
                        "Visa • ${card.cardNumber.substring(card.cardNumber.length - 4)}",
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Expired: ${card.expiryDate}",
                        style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          if (state.cards.length >= 2) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(state.translate("Ma abuuri kartid wax ka badan laba kaadh.", "You cannot have more than two active cards.")))
                             );
                             return;
                          }
                          
                          final success = await _showSecurityPinDialog(context);
                          if (success) {
                            await state.restoreCard(card.id);
                            if (context.mounted) {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.translate("Kaadhka waa la soo celiyay!", "Card restored successfully!")))
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(state.translate("Soo celi", "Restore")),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showSecurityPinDialog(BuildContext context) async {
    final state = Provider.of<AppState>(context, listen: false);
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => PinEntryDialog(
        title: state.translate("Geli PIN", "Enter PIN"),
        description: state.translate("Fadlan geli PIN-kaaga si aad u sii wadato.", "Please enter your PIN to continue."),
        onConfirm: (pin) {
          // Handled by Navigator.pop in dialog
        },
      ),
    );
    return pin != null && state.verifyPin(pin);
  }
}
