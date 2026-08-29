import 'package:flutter/material.dart';

class TagModel {
  final String id;
  final String label;
  final Color color;
  final int sortOrder;
  final bool isActive;

  const TagModel({
    required this.id,
    required this.label,
    required this.color,
    this.sortOrder = 0,
    this.isActive = true,
  });

  String get colorHex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static Color hexToColor(dynamic value, [Color fallback = const Color(0xFF3B82F6)]) {
    if (value == null) return fallback;
    if (value is int) return Color(value);
    if (value is Color) return value;
    if (value is String) {
      String hex = value.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'color': color.toARGB32(),
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toApiJson() {
    final map = <String, dynamic>{
      'label': label,
      'color': colorHex,
    };
    final numericId = int.tryParse(id);
    // Real persisted backend IDs are small integers (not empty, not temp timestamps, not prefixed)
    if (numericId != null &&
        numericId > 0 &&
        id.length < 10 &&
        !id.startsWith('new_') &&
        !id.startsWith('temp_')) {
      map['id'] = numericId;
    }
    return map;
  }

  factory TagModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId != null ? rawId.toString() : '';

    final rawColor = json['color'];
    final color = hexToColor(rawColor);

    return TagModel(
      id: idStr.isNotEmpty
          ? idStr
          : DateTime.now().millisecondsSinceEpoch.toString(),
      label: json['label'] as String? ?? 'Unknown',
      color: color,
      sortOrder: (json['sortOrder'] ?? json['sort_order'] ?? 0) as int,
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
    );
  }

  TagModel copyWith({
    String? id,
    String? label,
    Color? color,
    int? sortOrder,
    bool? isActive,
  }) {
    return TagModel(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
