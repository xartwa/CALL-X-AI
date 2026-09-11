import 'app_url_helper.dart';

/// Validation utilities with robust regex patterns for Phone, Email, and Website.
/// Designed to be resilient so invalid or legacy data from Excel never causes crashes.
class AppValidators {
  // Mobile / Phone regex:
  // Supports international formats (+1 604 343 7893, +98 912 345 6789, 09123456789, etc.)
  // Allows optional '+', digits, spaces, dashes, parentheses, dots.
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9\s\-().]{7,25}$');

  // Email regex: standard RFC 5322 compatible pattern.
  static final RegExp _emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  /// Validates phone number for forms.
  /// When [required] is true, an empty value returns an error message.
  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }
    final trimmed = value.trim();
    final lower = trimmed.toLowerCase();
    if (lower == '-' || lower == 'n/a' || lower == 'none' || lower == 'null') {
      return required ? 'Enter a valid phone number' : null;
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (!_phonePattern.hasMatch(trimmed) ||
        digitsOnly.length < 7 ||
        digitsOnly.length > 15) {
      return 'Enter a valid phone number (e.g. +1 604 343 7893)';
    }
    return null;
  }

  /// Validates email address for forms.
  /// [required] defaults to false so optional email fields are not blocked when empty.
  static String? validateEmail(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }
    final trimmed = value.trim();
    final lower = trimmed.toLowerCase();
    if (lower == '-' || lower == 'n/a' || lower == 'none' || lower == 'null') {
      return required ? 'Enter a valid email address' : null;
    }
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address (e.g. name@company.com)';
    }
    return null;
  }

  /// Validates website URL for forms.
  /// [required] defaults to false so optional website fields are not blocked when empty.
  /// Accepts domains with or without 'https://' (e.g. company.com or https://company.com).
  static String? validateWebsite(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Website is required' : null;
    }
    final trimmed = value.trim();
    final lower = trimmed.toLowerCase();
    if (lower == '-' || lower == 'n/a' || lower == 'none' || lower == 'null') {
      return required ? 'Enter a valid website URL' : null;
    }
    if (!AppUrlHelper.isValidUrl(trimmed)) {
      return 'Enter a valid website URL (e.g. company.com or https://company.com)';
    }
    return null;
  }

  /// Safe boolean phone check that never throws.
  static bool isValidPhone(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    return _phonePattern.hasMatch(trimmed) &&
        digitsOnly.length >= 7 &&
        digitsOnly.length <= 15;
  }

  /// Safe boolean email check that never throws.
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();
    return _emailPattern.hasMatch(trimmed);
  }

  /// Safe boolean website check that never throws.
  static bool isValidWebsite(String? value) {
    return AppUrlHelper.isValidUrl(value);
  }
}
