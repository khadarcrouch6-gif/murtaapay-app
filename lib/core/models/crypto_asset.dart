import 'package:flutter/material.dart';

class CryptoAsset {
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final dynamic icon;
  final Color color;
  final double holdings; // Amount owned by the user

  CryptoAsset({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.icon,
    required this.color,
    this.holdings = 0.0,
  });

  double get totalValue => holdings * price;

  CryptoAsset copyWith({
    String? symbol,
    String? name,
    double? price,
    double? change24h,
    dynamic icon,
    Color? color,
    double? holdings,
  }) {
    return CryptoAsset(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      holdings: holdings ?? this.holdings,
    );
  }
}
