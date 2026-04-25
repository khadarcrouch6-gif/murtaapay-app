import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String title;
  final String soTitle;
  final String arTitle;
  final String deTitle;
  final double saved;
  final double target;
  final String deadline;
  final IconData icon;
  final Color color;
  final int delay;
  final bool isPaused;

  SavingsGoal({
    required this.id,
    required this.title,
    this.soTitle = "",
    this.arTitle = "",
    this.deTitle = "",
    required this.saved,
    required this.target,
    required this.deadline,
    required this.icon,
    required this.color,
    this.delay = 0,
    this.isPaused = false,
  });

  SavingsGoal copyWith({
    String? title,
    String? soTitle,
    String? arTitle,
    String? deTitle,
    double? saved,
    double? target,
    String? deadline,
    IconData? icon,
    Color? color,
    int? delay,
    bool? isPaused,
  }) {
    return SavingsGoal(
      id: id,
      title: title ?? this.title,
      soTitle: soTitle ?? this.soTitle,
      arTitle: arTitle ?? this.arTitle,
      deTitle: deTitle ?? this.deTitle,
      saved: saved ?? this.saved,
      target: target ?? this.target,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      delay: delay ?? this.delay,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'soTitle': soTitle,
      'arTitle': arTitle,
      'deTitle': deTitle,
      'saved': saved,
      'target': target,
      'deadline': deadline,
      'icon': icon.codePoint,
      'color': color.value,
      'delay': delay,
      'isPaused': isPaused,
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      title: json['title'],
      soTitle: json['soTitle'] ?? "",
      arTitle: json['arTitle'] ?? "",
      deTitle: json['deTitle'] ?? "",
      saved: (json['saved'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
      deadline: json['deadline'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      delay: json['delay'] ?? 0,
      isPaused: json['isPaused'] ?? false,
    );
  }
}
