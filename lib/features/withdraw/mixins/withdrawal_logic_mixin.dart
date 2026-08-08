import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_state.dart';
import '../../../l10n/app_localizations.dart';

mixin WithdrawalLogicMixin<T extends StatefulWidget> on State<T> {
  String? getWithdrawPrefixError(String val, String? provider, AppLocalizations l10n) {
    if (val.isEmpty) return null;
    if (provider == l10n.evcPlus && !(val.startsWith('61') || val.startsWith('77'))) {
      return "EVC Plus prefix must be 61 or 77";
    }
    if (provider == l10n.edahab && !val.startsWith('65')) {
      return "e-Dahab prefix must be 65";
    }
    if (provider == l10n.zaad && !val.startsWith('63')) {
      return "ZAAD prefix must be 63";
    }
    if (provider == l10n.sahal && !val.startsWith('90')) {
      return "Sahal prefix must be 90";
    }
    return null;
  }

  String? detectProvider(String val, AppLocalizations l10n) {
    if (val.length >= 2) {
      if (val.startsWith('61') || val.startsWith('77')) return l10n.evcPlus;
      if (val.startsWith('65')) return l10n.edahab;
      if (val.startsWith('63')) return l10n.zaad;
      if (val.startsWith('90')) return l10n.sahal;
    }
    return null;
  }

  String? lookupName(String val, AppState state) {
    if (val.length < 6) return null;
    
    final profile = state.quickProfiles.where((p) => p.walletId.contains(val)).firstOrNull;
    if (profile != null) return profile.name;

    final recent = state.recentWithdrawals.where((r) => r['detail'] == val).firstOrNull;
    if (recent != null) return recent['name'];
    
    return null;
  }

  List<String> getPurposes(AppLocalizations l10n) => [
    l10n.familySupport,
    l10n.educationTuition,
    l10n.medicalExpenses,
    l10n.businessTransaction,
    l10n.propertyRent,
    l10n.gift,
    l10n.other,
  ];

  void triggerHapticSuccess() {
    HapticFeedback.lightImpact();
  }
}
