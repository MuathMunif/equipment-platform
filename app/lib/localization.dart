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
  final decimal = num.tryParse('$value');
  if (decimal == null) return '$value';
  final language = Localizations.localeOf(context).languageCode;
  final amount = NumberFormat.decimalPatternDigits(
    locale: language,
    decimalDigits: 2,
  ).format(decimal);
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
