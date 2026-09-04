import 'package:flutter/material.dart';

class AppStatusHelper {
  // Standard Color Palette
  static const Color green = Color(0xFF10B981); // Completed, Won, Active, Excellent
  static const Color amber = Color(0xFFF59E0B); // Queued, Pending, Upcoming, Warm, Average
  static const Color blue = Color(0xFF3B82F6); // In Progress, Ongoing, Contacted, Cold, Good
  static const Color skyBlue = Color(0xFF0284C7); // Ringing, Initiated
  static const Color indigo = Color(0xFF6366F1); // New
  static const Color purple = Color(0xFF8B5CF6); // Qualified, Interested
  static const Color orange = Color(0xFFF97316); // Busy
  static const Color red = Color(0xFFEF4444); // Failed, Canceled, Lost, Hot, Poor, Inactive, Deactive
  static const Color slateMuted = Color(0xFF94A3B8); // No Answer, Missed, Unanswered
  static const Color slate = Color(0xFF64748B); // Default, Unknown, Other

  /// Resolves the unified semantic status color for any status, outcome, or priority label.
  static Color getStatusColor(String? status) {
    if (status == null || status.trim().isEmpty) return slate;
    final lower = status.toLowerCase().trim();

    // 1. Completed / Won / Active / Excellent / Delivered / Sent
    if (lower == 'completed' ||
        lower == 'won' ||
        lower == 'active' ||
        lower == 'excellent' ||
        lower == 'delivered' ||
        lower == 'sent' ||
        lower == 'success' ||
        lower.contains('movafagh')) {
      return green;
    }

    // 2. Queued / Pending / Upcoming / Warm / Average
    if (lower == 'queued' ||
        lower == 'pending' ||
        lower == 'upcoming' ||
        lower == 'warm' ||
        lower == 'average' ||
        lower.contains('paygiri')) {
      return amber;
    }

    // 3. In Progress / Ongoing / Contacted / Cold / Good / Opened
    if (lower == 'in progress' ||
        lower == 'in-progress' ||
        lower == 'ongoing' ||
        lower == 'contacted' ||
        lower == 'cold' ||
        lower == 'good' ||
        lower == 'opened') {
      return blue;
    }

    // 4. Ringing / Initiated
    if (lower == 'ringing' || lower == 'initiated') {
      return skyBlue;
    }

    // 5. New
    if (lower == 'new') {
      return indigo;
    }

    // 6. Qualified / Interested
    if (lower == 'qualified' ||
        lower == 'interested' ||
        lower.contains('proposal')) {
      return purple;
    }

    // 7. Busy
    if (lower == 'busy') {
      return orange;
    }

    // 8. Failed / Canceled / Lost / Hot / Poor / Inactive / Deactive
    if (lower == 'failed' ||
        lower == 'cancelled' ||
        lower == 'canceled' ||
        lower == 'lost' ||
        lower == 'hot' ||
        lower == 'poor' ||
        lower == 'inactive' ||
        lower == 'deactive' ||
        lower.contains('namovafagh')) {
      return red;
    }

    // 9. No Answer / Missed
    if (lower == 'no answer' ||
        lower == 'missed' ||
        lower == 'unanswered') {
      return slateMuted;
    }

    // 10. Draft
    if (lower == 'draft') {
      return slate;
    }

    return slate;
  }

  /// Formats any status string to uppercase with trimmed spaces.
  static String format(String? status) {
    if (status == null || status.trim().isEmpty) return '';
    return status.trim().toUpperCase();
  }
}
