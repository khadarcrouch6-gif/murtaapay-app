import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';

import '../../core/widgets/pin_entry_dialog.dart';
import '../../core/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Transactions, 2: Promos

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          state.translate("Notifications", "Ogeysiisyada", ar: "الإشعارات", de: "Benachrichtigungen"),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              state.translate("Clear All", "Tir dhammaan", ar: "مسح الكل", de: "Alle löschen"),
              style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(context, state),
          Expanded(
            child: _buildNotificationsList(context, state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, AppState state) {
    final filters = [
      state.translate("All", "Dhammaan", ar: "الكل", de: "Alle"),
      state.translate("Transactions", "Xawaaladaha", ar: "المعاملات", de: "Transaktionen"),
      state.translate("Requests", "Codsiyada", ar: "الطلبات", de: "Anfragen"),
      state.translate("Promos", "Dalabyada", ar: "العروض", de: "Angebote"),
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryDark : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryDark : Colors.grey.withOpacity(0.2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * context.fontSizeFactor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, AppState state, ThemeData theme) {
    final List<NotificationData> staticNotifications = [
      NotificationData(
        title: state.translate("Money Request", "Codsi Lacag", ar: "طلب مبلغ", de: "Geldanforderung"),
        subtitle: state.translate("Mustafe Gedi requested \$45.00 for Lunch.", "Mustafe Gedi wuxuu ku waydiistay \$45.00 qadadii.", ar: "طلب مصطفى جيدي مبلغ \$45.00 للغداء.", de: "Mustafe Gedi hat \$45.00 für das Mittagessen angefordert."),
        time: state.translate("Just now", "Hadda", ar: "الآن", de: "Gerade eben"),
        icon: Icons.payments_outlined,
        iconColor: Colors.blue,
        type: 3,
        extraData: {'sender': 'Mustafe Gedi', 'amount': 45.0},
      ),
      NotificationData(
        title: state.translate("Transaction Successful", "Xawaalad Guulaysatay", ar: "تمت العملية بنجاح", de: "Transaktion erfolgreich"),
        subtitle: state.translate("You sent \$2,500 to Ahmed Warsame.", "Waxaad \$2,500 u dirtay Ahmed Warsame.", ar: "لقد أرسلت \$2,500 إلى أحمد ورسمة.", de: "Sie haben \$2.500 an Ahmed Warsame gesendet."),
        time: state.translate("2 mins ago", "2 daqiiqo ka hor", ar: "منذ دقيقتين", de: "vor 2 Min."),
        icon: Icons.check_circle_outline,
        iconColor: AppColors.accentTeal,
        type: 1,
      ),
      NotificationData(
        title: state.translate("New Promo!", "Dalab Cusub!", ar: "عرض جديد!", de: "Neues Angebot!"),
        subtitle: state.translate("Get 5% cashback on your next bill payment.", "Hel 5% lacag celin ah biilkaaga soo socda.", ar: "احصل على استرداد نقدي 5% عند دفع فاتورتك القادمة.", de: "Erhalten Sie 5% Cashback auf Ihre nächste Rechnung."),
        time: state.translate("1 hour ago", "1 saac ka hor", ar: "منذ ساعة", de: "vor 1 Std."),
        icon: FontAwesomeIcons.gift,
        iconColor: Colors.purple,
        type: 2,
      ),
      NotificationData(
        title: state.translate("Payment Received", "Lacag lagu soo diray", ar: "تم استلام دفعة", de: "Zahlung erhalten"),
        subtitle: state.translate("You received \$150 from Sahra Ali.", "Waxaad \$150 ka heshay Sahra Ali.", ar: "لقد استلمت \$150 من صحراء علي.", de: "Sie haben \$150 von Sahra Ali erhalten."),
        time: state.translate("3 hours ago", "3 saac ka hor", ar: "منذ 3 ساعات", de: "vor 3 Std."),
        icon: FontAwesomeIcons.arrowDownLong,
        iconColor: Colors.blue,
        type: 1,
      ),
      NotificationData(
        title: state.translate("Security Alert", "Digniin Ammaan", ar: "تنبيه أمني", de: "Sicherheitswarnung"),
        subtitle: state.translate("A new login was detected from a New iPhone.", "Soo galid cusub ayaa laga dareemay iPhone cusub.", ar: "تم اكتشاف تسجيل دخول جديد من هاتف iPhone جديد.", de: "Eine neue Anmeldung wurde von einem neuen iPhone erkannt."),
        time: state.translate("Yesterday", "Shalay", ar: "أمس", de: "Gestern"),
        icon: FontAwesomeIcons.shieldHalved,
        iconColor: Colors.orange,
        type: 0,
      ),
    ];
    
    final List<NotificationData> allNotifications = [...state.notifications, ...staticNotifications];

    final filteredList = _selectedFilter == 0
        ? allNotifications
        : allNotifications.where((n) {
            if (_selectedFilter == 1) return n.type == 1; // Transactions
            if (_selectedFilter == 2) return n.type == 3; // Requests
            if (_selectedFilter == 3) return n.type == 2; // Promos
            return false;
          }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              state.translate("No notifications yet", "Ma jiraan ogeysiisyo wali", ar: "لا توجد إشعارات بعد", de: "Noch keine Benachrichtigungen"),
              style: TextStyle(color: Colors.grey, fontSize: 16 * context.fontSizeFactor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final notification = filteredList[index];
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showNotificationDetail(context, notification, state),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: notification.iconColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: AdaptiveIcon(notification.icon, color: notification.iconColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  notification.time,
                                  style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13 * context.fontSizeFactor,
                                height: 1.4,
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
          ),
        );
      },
    );
  }

  void _showNotificationDetail(BuildContext context, NotificationData notification, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: notification.type == 3 ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.45,
        borderRadius: 32,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.2),
            AppColors.primaryDark.withOpacity(0.05),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: AdaptiveIcon(notification.icon, color: notification.iconColor, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                notification.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 22 * context.fontSizeFactor,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                notification.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16 * context.fontSizeFactor,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              if (notification.type == 3)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(state.translate("Decline", "Diid", ar: "رفض", de: "Ablehnen")),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleApproveRequest(context, notification, state);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(state.translate("Approve", "Oggolow", ar: "موافقة", de: "Genehmigen")),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(state.translate("Close", "Xidh", ar: "إغلاق", de: "Schließen")),
                      ),
                    ),
                    if (notification.type == 1) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            state.setNavIndex(1);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(state.translate("View", "Eeg", ar: "عرض", de: "Ansehen")),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleApproveRequest(BuildContext context, NotificationData notification, AppState state) {
    showDialog(
      context: context,
      builder: (context) => PinEntryDialog(
        title: state.translate("Confirm Payment", "Hubi Lacag Bixinta", ar: "تأكيد الدفع", de: "Zahlung bestätigen"),
        description: state.translate("Enter PIN to pay ${notification.extraData?['sender'] ?? 'Request'}", "Geli PIN si aad u bixiso", ar: "أدخل PIN للدفع", de: "PIN eingeben, um zu bezahlen"),
        onConfirm: (pin) async {
          try {
            await state.approveMoneyRequest(notification.extraData?['requestId'] ?? "", pin);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.translate("Payment successful!", "Lacag bixintu way lagu guulaystay!", ar: "تم الدفع بنجاح!", de: "Zahlung erfolgreich!")),
                  backgroundColor: AppColors.accentTeal,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              String errorMsg = e.toString();
              if (errorMsg.contains("insufficient_funds")) {
                errorMsg = state.translate("Insufficient balance", "Haraagu kuguma filna", ar: "رصيد غير كاف", de: "Unzureichendes Guthaben");
              } else if (errorMsg.contains("daily_limit_exceeded")) {
                errorMsg = state.translate("Daily limit exceeded", "Xadka maalinlaha ah waa laga gudbay", ar: "تم تجاوز الحد اليومي", de: "Tageslimit überschritten");
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
              );
            }
          }
        },
      ),
    );
  }
}

