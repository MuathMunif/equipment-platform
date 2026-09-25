import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/documents.dart';
import 'package:equipment_app/localization.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response reply(Object body) => http.Response(jsonEncode(body), 200);

void main() {
  test(
    'saved locale precedes device, unsupported locale falls back to Arabic',
    () {
      expect(initialLocale('ur', const Locale('en')).languageCode, 'ur');
      expect(initialLocale(null, const Locale('en')).languageCode, 'en');
      expect(initialLocale(null, const Locale('fr')).languageCode, 'ar');
      expect(initialLocale('xx', const Locale('fr')).languageCode, 'ar');
    },
  );

  for (final (code, direction) in [
    ('ar', TextDirection.rtl),
    ('en', TextDirection.ltr),
    ('ur', TextDirection.rtl),
  ]) {
    testWidgets('$code loads with correct direction and stable domain values', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              expect(Directionality.of(context), direction);
              expect(localizedCategory(context, 'FUEL'), isNotEmpty);
              expect(
                localizedFinancialStatus(context, false, 'PAID'),
                isNotEmpty,
              );
              expect(
                localizedDocumentStatus(context, {'status': 'EXPIRED'}),
                isNotEmpty,
              );
              final (title, body) = localizedNotification(context, {
                'templateKey': 'DOCUMENT_EXPIRY',
                'params': {
                  'documentType': 'INSURANCE',
                  'equipmentName': 'قلاب 1',
                  'daysRemaining': 7,
                },
                'readAt': null,
              });
              expect(title, isNotEmpty);
              expect(body, contains('قلاب 1'));
              expect(
                localizedError(
                  context,
                  const ApiError(409, 'FINANCIAL_TOTAL_LOCKED', 'raw'),
                ),
                isNot('raw'),
              );
              expect(localizedDate(context, '2026-09-25'), isNotEmpty);
              expect(localizedMoney(context, '350.00'), contains('350'));
              return Text(l10n(context).appTitle);
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('language changes without logout and persists to user endpoint', (
    tester,
  ) async {
    String? saved;
    final requests = <String>[];
    final api = Api(
      client: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        if (request.url.path.endsWith('/auth/me/locale')) {
          saved =
              (jsonDecode(request.body)
                      as Map<String, dynamic>)['preferredLocale']
                  as String;
          return reply({
            'name': 'Owner',
            'preferredLocale': saved,
            'csrfToken': 'csrf',
            'workspaces': [
              {'id': 'w'},
            ],
          });
        }
        if (request.url.path.endsWith('/auth/me')) {
          return reply({
            'name': 'Owner',
            'preferredLocale': 'ar',
            'csrfToken': 'csrf',
            'workspaces': [
              {'id': 'w'},
            ],
          });
        }
        if (request.url.path.endsWith('/notifications/unread-count')) {
          return reply({'unreadCount': 0});
        }
        return reply({'items': [], 'total': 0});
      }),
      persistNative: false,
    );
    await tester.pumpWidget(EquipmentApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('إدارة المعدات'), findsOneWidget);
    await tester.tap(find.byKey(const Key('languageSettings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(saved, 'en');
    expect(requests, contains('PUT /api/v1/auth/me/locale'));
    expect(find.text('Equipment Manager'), findsOneWidget);
    expect(find.byKey(const Key('languageSettings')), findsOneWidget);
    expect(
      Directionality.of(
        tester.element(find.byKey(const Key('languageSettings'))),
      ),
      TextDirection.ltr,
    );
    expect(tester.takeException(), isNull);
  });
  for (final language in ['en', 'ur']) {
    for (final width in [390.0, 1440.0]) {
      testWidgets('$language empty equipment screen fits width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = Api(
          client: MockClient((request) async {
            if (request.url.path.endsWith('/auth/me')) {
              return reply({
                'name': 'Owner',
                'preferredLocale': language,
                'csrfToken': 'csrf',
                'workspaces': [
                  {'id': 'w'},
                ],
              });
            }
            if (request.url.path.endsWith('/notifications/unread-count')) {
              return reply({'unreadCount': 0});
            }
            return reply({'items': [], 'total': 0});
          }),
          persistNative: false,
        );
        await tester.pumpWidget(EquipmentApp(api: api));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('languageSettings')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
