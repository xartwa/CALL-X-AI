import 'package:callx_ai/core/utils/app_url_helper.dart';
import 'package:callx_ai/core/utils/app_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppValidators', () {
    group('validatePhone', () {
      test('validates correct phone numbers', () {
        expect(AppValidators.validatePhone('+1 604 343 7893'), isNull);
        expect(AppValidators.validatePhone('+16043437893'), isNull);
        expect(AppValidators.validatePhone('09123456789'), isNull);
        expect(AppValidators.validatePhone('+98 912 345 6789'), isNull);
        expect(AppValidators.validatePhone('1234567'), isNull);
        expect(AppValidators.validatePhone('(604) 343-7893'), isNull);
      });

      test('rejects empty or invalid phone numbers when required', () {
        expect(AppValidators.validatePhone(''), 'Phone number is required');
        expect(AppValidators.validatePhone(null), 'Phone number is required');
        expect(AppValidators.validatePhone('   '), 'Phone number is required');
        expect(AppValidators.validatePhone('-'), 'Enter a valid phone number');
        expect(AppValidators.validatePhone('N/A'), 'Enter a valid phone number');
        expect(AppValidators.validatePhone('123'), isNotNull);
        expect(AppValidators.validatePhone('abcdefgh'), isNotNull);
      });

      test('allows empty when optional', () {
        expect(AppValidators.validatePhone('', required: false), isNull);
        expect(AppValidators.validatePhone(null, required: false), isNull);
        expect(AppValidators.validatePhone('-', required: false), isNull);
      });
    });

    group('validateEmail', () {
      test('accepts valid email addresses', () {
        expect(AppValidators.validateEmail('test@example.com'), isNull);
        expect(AppValidators.validateEmail('user.name+tag@sub.domain.co.uk'), isNull);
      });

      test('accepts empty when optional', () {
        expect(AppValidators.validateEmail(''), isNull);
        expect(AppValidators.validateEmail(null), isNull);
        expect(AppValidators.validateEmail('   '), isNull);
        expect(AppValidators.validateEmail('-'), isNull);
      });

      test('rejects invalid email formats when not empty', () {
        expect(AppValidators.validateEmail('plainaddress'), isNotNull);
        expect(AppValidators.validateEmail('@missinguser.com'), isNotNull);
        expect(AppValidators.validateEmail('user@nodomain'), isNotNull);
        expect(AppValidators.validateEmail('user@.com'), isNotNull);
      });
    });

    group('validateWebsite', () {
      test('accepts valid websites with or without scheme', () {
        expect(AppValidators.validateWebsite('https://example.com'), isNull);
        expect(AppValidators.validateWebsite('http://example.com/path'), isNull);
        expect(AppValidators.validateWebsite('example.com'), isNull);
        expect(AppValidators.validateWebsite('www.example.com'), isNull);
        expect(AppValidators.validateWebsite('sub.domain.org/about'), isNull);
      });

      test('accepts empty when optional', () {
        expect(AppValidators.validateWebsite(''), isNull);
        expect(AppValidators.validateWebsite(null), isNull);
        expect(AppValidators.validateWebsite('-'), isNull);
        expect(AppValidators.validateWebsite('N/A'), isNull);
      });

      test('rejects malformed URLs when not empty', () {
        expect(AppValidators.validateWebsite('not a url'), isNotNull);
        expect(AppValidators.validateWebsite('http://'), isNotNull);
        expect(AppValidators.validateWebsite('nodotdomain'), isNotNull);
      });
    });
  });

  group('AppUrlHelper', () {
    test('normalizes website url by prepending https:// if missing', () {
      expect(AppUrlHelper.normalizeWebsiteUrl('example.com'), 'https://example.com');
      expect(AppUrlHelper.normalizeWebsiteUrl('www.google.com'), 'https://www.google.com');
      expect(AppUrlHelper.normalizeWebsiteUrl('https://example.com'), 'https://example.com');
      expect(AppUrlHelper.normalizeWebsiteUrl('http://example.com'), 'http://example.com');
    });

    test('gracefully handles Excel placeholder and empty values', () {
      expect(AppUrlHelper.normalizeWebsiteUrl(null), '');
      expect(AppUrlHelper.normalizeWebsiteUrl(''), '');
      expect(AppUrlHelper.normalizeWebsiteUrl('   '), '');
      expect(AppUrlHelper.normalizeWebsiteUrl('-'), '');
      expect(AppUrlHelper.normalizeWebsiteUrl('N/A'), '');
      expect(AppUrlHelper.normalizeWebsiteUrl('null'), '');
      expect(AppUrlHelper.normalizeWebsiteUrl('undefined'), '');
      expect(AppUrlHelper.normalizeWebsiteUrl('none'), '');
    });

    test('isValidUrl detects valid domains and schemes', () {
      expect(AppUrlHelper.isValidUrl('example.com'), isTrue);
      expect(AppUrlHelper.isValidUrl('https://example.com'), isTrue);
      expect(AppUrlHelper.isValidUrl('invalid'), isFalse);
      expect(AppUrlHelper.isValidUrl(''), isFalse);
      expect(AppUrlHelper.isValidUrl('-'), isFalse);
    });
  });
}
