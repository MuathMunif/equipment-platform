import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';

const supportedLanguageCodes = {'ar', 'en', 'ur'};

Locale initialLocale(String? saved, Locale device) {
  if (saved != null && supportedLanguageCodes.contains(saved)) {
    return Locale(saved);
  }
  if (supportedLanguageCodes.contains(device.languageCode)) {
    return Locale(device.languageCode);
  }
  return const Locale('ar');
}

AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context)!;

String localizedDate(BuildContext context, String? value) {
  if (value == null || value.isEmpty) return '';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
      .format(date);
}

String localizedRiyadhDateTime(BuildContext context, String value) {
  final date = DateTime.tryParse(value)?.toUtc().add(const Duration(hours: 3));
  if (date == null) return value;
  return DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
      .add_jm()
      .format(date);
}

String localizedMoney(BuildContext context, Object? value) {
  final raw = '$value';
  if (!RegExp(r'^-?[0-9]+\.[0-9]{2}$').hasMatch(raw)) return raw;
  final language = Localizations.localeOf(context).languageCode;
  final parts = raw.split('.');
  final format = NumberFormat.decimalPattern(language);
  final symbols = format.symbols;
  String digits(String value) =>
      value.split('').map((digit) => format.format(int.parse(digit))).join();
  final negative = parts.first.startsWith('-');
  final whole = negative ? parts.first.substring(1) : parts.first;
  final groups = <String>[];
  for (var end = whole.length; end > 0; end -= 3) {
    groups.insert(0, digits(whole.substring(end < 3 ? 0 : end - 3, end)));
  }
  final integer =
      '${negative ? symbols.MINUS_SIGN : ''}${groups.join(symbols.GROUP_SEP)}';
  final amount = '$integer${symbols.DECIMAL_SEP}${digits(parts.last)}';
  return '$amount ${l10n(context).sarUnit}';
}

String localizedError(BuildContext context, Object error) =>
    localizedErrorForLocale(Localizations.localeOf(context), error);

String localizedErrorForLocale(Locale locale, Object error) {
  final loc = lookupAppLocalizations(locale);
  if (error is! LocaleApiError) return loc.requestFailed;
  return switch (error.localeCode) {
    'FINANCIAL_TOTAL_LOCKED' => loc.financialTotalLocked,
    'DOCUMENT_ALREADY_RENEWED' => loc.documentAlreadyRenewed,
    'INVALID_INPUT' => loc.invalidInput,
    'INVALID_OTP' => loc.invalidOtp,
    'SESSION_EXPIRED' => loc.sessionExpired,
    'OTP_THROTTLED' => loc.otpThrottled,
    'NOT_FOUND' => loc.recordNotFound,
    'DOCUMENT_VERSION_CHANGED' => loc.documentVersionChanged,
    'DOCUMENT_ARCHIVED' ||
    'EQUIPMENT_ARCHIVED' ||
    'HISTORICAL_VERSION' ||
    'HISTORICAL_RECORD' ||
    'ISSUE_CLOSED' ||
    'ISSUE_STATE' ||
    'MAINTENANCE_CANCELLED' ||
    'EXPENSE_ALREADY_LINKED' ||
    'MAINTENANCE_EXPENSE_LINKED' ||
    'TYPE_LOCKED' => loc.documentLocked,
    'FILE_NOT_READY' || 'FILE_UNAVAILABLE' => loc.fileUnavailable,
    'ATTACHMENT_LIMIT' => loc.attachmentLimit,
    'IDEMPOTENCY_CONFLICT' => loc.idempotencyConflict,
    'IMMUTABLE_ATTACHMENT' => loc.immutableAttachment,
    'UNSUPPORTED_LOCALE' => loc.unsupportedLocale,
    'MEMBERSHIP_REQUIRED' || 'ORIGIN_DENIED' => loc.accessDenied,
    'CSRF_REQUIRED' => loc.sessionExpired,
    'CROSS_WORKSPACE_ACCESS_DENIED' || 'ACCESS_DENIED' => loc.accessDenied,
    'SESSION_REQUIRED' => loc.sessionRequired,
    'NETWORK' => loc.networkError,
    'REQUEST_FAILED' => loc.requestFailed,
    'TIMEOUT' => loc.timeoutMessage,
    'UNSUPPORTED_FILE' => loc.unsupportedFile,
    'FILE_TOO_LARGE' => loc.fileTooLarge,
    'UPLOAD_FAILED' => loc.uploadFailed,
    _ => loc.requestFailed,
  };
}

abstract interface class LocaleApiError {
  String get localeCode;
}
