import 'package:flutter/material.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final String creator;
  final IconData icon;
  final String imageUrl;
  final String category;
  final int donorCount;
  final String lastDonationAgo;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.creator,
    required this.icon,
    required this.imageUrl,
    required this.category,
    required this.donorCount,
    required this.lastDonationAgo,
  });
}
