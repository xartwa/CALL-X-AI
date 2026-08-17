import 'package:flutter/material.dart';

class TagModel {
  final String id;
  final String label;
  final Color color;

  TagModel({
    required this.id,
    required this.label,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'color': color.toARGB32(),
    };
  }

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: json['label'] as String? ?? 'Unknown',
      color: json['color'] != null
          ? Color(json['color'] as int)
          : const Color(0xFF3B82F6), // Default blue
    );
  }

  TagModel copyWith({
    String? id,
    String? label,
    Color? color,
  }) {
    return TagModel(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }
}
