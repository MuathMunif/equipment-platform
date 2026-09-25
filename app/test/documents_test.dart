import 'dart:convert';
import 'dart:typed_data';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/documents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response reply(Object value, [int status = 200]) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json'},
);
Widget host(Widget page) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: page,
);
Api apiWith(Future<http.Response> Function(http.Request) handler) =>
    Api(client: MockClient(handler), persistNative: false)..workspace = 'w';
final equipment = <String, dynamic>{
  'id': 'eq',
  'name': 'قلاب ١',
  'model': 'FH16',
  'reference': 'EQ-000001',
};
Map<String, dynamic> doc({
  String id = 'd',
  String status = 'EXPIRING_SOON',
  String? expiry = '2026-09-30',
  String type = 'INSURANCE',
  int version = 1,
  String? archivedAt,
}) => {
  'id': id,
  'equipmentId': 'eq',
  'type': type,
  'customTypeName': null,
  'currentVersionId': 'v$version',
  'versionId': 'v$version',
  'versionNumber': version,
  'documentNumber': 'POL-1',
  'issueDate': null,
  'expiryDate': expiry,
  'notes': '',
  'status': status,
  'archivedAt': archivedAt,
  'equipmentArchived': false,
};
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget launcher(Widget Function(BuildContext) destination) => host(
  Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: FilledButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: destination)),
          child: const Text('فتح'),
        ),
      ),
    ),
  ),
);

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'equipment document card and list separate attention/current at $width RTL',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final missing = doc(
          id: 'missing',
          status: 'MISSING_EXPIRY',
          expiry: null,
          type: 'REGISTRATION',
        );
        final urgent = doc();
        final api = apiWith((request) async {
          if (request.url.path.endsWith('/documents') &&
              request.url.query.isEmpty) {
            return reply([urgent, missing]);
          }
          if (request.url.query == 'archived=true') return reply([]);
          return reply({'code': 'NOT_FOUND', 'message': 'غير موجود'}, 404);
        });
        await tester.pumpWidget(
          host(
            Scaffold(
              body: EquipmentDocumentsCard(api: api, equipment: equipment),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('2 مستندات'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.text('المستندات'))),
          TextDirection.rtl,
        );
        await tester.tap(find.byKey(const Key('openEquipmentDocuments')));
        await tester.pumpAndSettle();
        expect(find.text('يحتاج انتباه'), findsOneWidget);
        expect(find.text('المستندات الحالية'), findsOneWidget);
        expect(find.text('التأمين'), findsOneWidget);
        expect(find.text('الاستمارة'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('empty document card offers add action', (tester) async {
    final api = apiWith((_) async => reply([]));
    await tester.pumpWidget(
      host(
        Scaffold(
          body: EquipmentDocumentsCard(api: api, equipment: equipment),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('لم تضف مستندات لهذه المعدة بعد'), findsOneWidget);
    expect(find.text('إضافة مستند'), findsOneWidget);
  });
  testWidgets('custom document can save without expiry after validation', (
    tester,
  ) async {
    Map<String, dynamic>? posted;
    final api = apiWith((request) async {
      if (request.method == 'GET' && request.url.path.endsWith('/duplicates')) {
        return reply([]);
      }
      if (request.method == 'POST') {
        posted = jsonDecode(request.body) as Map<String, dynamic>;
        return reply(
          doc(status: 'MISSING_EXPIRY', expiry: null, type: 'OTHER'),
        );
      }
      return reply([]);
    });
    await tester.pumpWidget(
      launcher((_) => DocumentFormPage(api: api, equipment: equipment)),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('documentType')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أخرى').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('saveDocument')));
    expect(find.text('اكتب اسم المستند'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('customDocumentName')),
      'بطاقة تشغيل',
    );
    await tapVisible(tester, find.byKey(const Key('saveDocument')));
    expect(posted?['type'], 'OTHER');
    expect(posted?['customTypeName'], 'بطاقة تشغيل');
    expect(posted?['expiryDate'], isNull);
  });
  testWidgets('renewal requires expiry and shows current document context', (
    tester,
  ) async {
    final api = apiWith((_) async => reply({}));
    await tester.pumpWidget(
      host(
        DocumentFormPage(
          api: api,
          equipment: equipment,
          document: doc(),
          renewal: true,
        ),
      ),
    );
    await tapVisible(tester, find.byKey(const Key('saveDocument')));
    expect(find.text('أضف تاريخ الانتهاء'), findsOneWidget);
    expect(find.textContaining('سيُحفظ المستند السابق'), findsOneWidget);
  });
  testWidgets(
    'expired detail prioritizes renewal, archive confirms, history is read only',
    (tester) async {
      var archived = false;
      final expired = doc(status: 'EXPIRED', expiry: '2026-09-01');
      final api = apiWith((request) async {
        final path = request.url.path;
        if (path.endsWith('/documents/d/versions/v0/attachments') ||
            path.endsWith('/documents/d/versions/v1/attachments')) {
          return reply([]);
        }
        if (path.endsWith('/documents/d/versions/v0')) {
          return reply({
            ...doc(version: 0, status: 'PREVIOUS_VERSION'),
            'currentVersionId': 'v1',
          });
        }
        if (path.endsWith('/documents/d/versions')) {
          return reply([
            expired,
            {
              ...doc(version: 0, status: 'PREVIOUS_VERSION'),
              'currentVersionId': 'v1',
            },
          ]);
        }
        if (path.endsWith('/documents/d/archive')) {
          archived = true;
          return reply({
            ...expired,
            'status': 'ARCHIVED',
            'archivedAt': '2026-09-25T00:00:00Z',
          });
        }
        if (path.endsWith('/documents/d')) {
          return reply(
            archived
                ? {
                    ...expired,
                    'status': 'ARCHIVED',
                    'archivedAt': '2026-09-25T00:00:00Z',
                  }
                : expired,
          );
        }
        if (path.endsWith('/equipment/eq')) return reply(equipment);
        return reply([]);
      });
      await tester.pumpWidget(host(DocumentDetailPage(api: api, id: 'd')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('renewDocument')), findsOneWidget);
      expect(find.text('منتهي'), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('documentHistory')));
      await tester.tap(find.text('النسخة 0'));
      await tester.pumpAndSettle();
      expect(find.text('نسخة سابقة للعرض فقط'), findsOneWidget);
      expect(find.byKey(const Key('editDocument')), findsNothing);
      Navigator.of(tester.element(find.byType(DocumentVersionPage))).pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(DocumentHistoryPage))).pop();
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('archiveDocument')));
      expect(find.textContaining('تنبيهات انتهاء'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirmDocumentArchive')));
      await tester.pumpAndSettle();
      expect(archived, isTrue);
      expect(find.byKey(const Key('restoreDocument')), findsOneWidget);
    },
  );
  testWidgets('attention and incomplete lists open document detail', (
    tester,
  ) async {
    final api = apiWith((request) async {
      final path = request.url.path;
      if (path.endsWith('/attention/documents')) {
        return reply([
          {
            'documentId': 'd',
            'equipmentId': 'eq',
            'equipmentName': 'قلاب ١',
            'type': 'INSURANCE',
            'body': 'ينتهي بعد 5 أيام',
            'expiryDate': '2026-09-30',
            'daysRemaining': 5,
            'status': 'EXPIRING_SOON',
          },
        ]);
      }
      if (path.endsWith('/documents/incomplete')) {
        return reply([
          doc(id: 'missing', status: 'MISSING_EXPIRY', expiry: null),
        ]);
      }
      if (path.endsWith('/documents/d')) return reply(doc());
      if (path.endsWith('/equipment/eq')) return reply(equipment);
      if (path.endsWith('/documents/d/versions/v1/attachments')) {
        return reply([]);
      }
      return reply([]);
    });
    await tester.pumpWidget(host(HomeDocumentAttention(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('يحتاج انتباه'), findsOneWidget);
    expect(find.text('1 مستند بدون تاريخ انتهاء'), findsOneWidget);
    await tester.tap(find.byKey(const Key('openAttention')));
    await tester.pumpAndSettle();
    expect(find.textContaining('ينتهي بعد 5 أيام'), findsWidgets);
    await tester.tap(find.textContaining('قلاب ١').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('renewDocument')), findsOneWidget);
  });
  testWidgets('incomplete document directly opens expiry edit form', (
    tester,
  ) async {
    final missing = doc(id: 'missing', status: 'MISSING_EXPIRY', expiry: null);
    final api = apiWith((request) async {
      if (request.url.path.endsWith('/documents/incomplete')) {
        return reply([missing]);
      }
      if (request.url.path.endsWith('/equipment/eq')) return reply(equipment);
      return reply([]);
    });
    await tester.pumpWidget(host(IncompleteDocumentsPage(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addExpiry-missing')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('documentExpiryDate')), findsOneWidget);
    expect(find.text('تعديل المستند'), findsOneWidget);
  });
  testWidgets('notification unread badge, mark read, deep link and mark all', (
    tester,
  ) async {
    final calls = <String>[];
    bool read = false;
    final api = apiWith((request) async {
      calls.add('${request.method} ${request.url.path}');
      final path = request.url.path;
      if (path.endsWith('/notifications/unread-count')) {
        return reply({'unreadCount': read ? 0 : 1});
      }
      if (path.endsWith('/notifications/read-all')) {
        read = true;
        return reply({'markedRead': 1});
      }
      if (path.endsWith('/notifications/n/read')) {
        read = true;
        return reply({});
      }
      if (path.endsWith('/notifications')) {
        return reply({
          'items': [
            {
              'id': 'n',
              'type': 'DOCUMENT_CURRENT_STATE',
              'entityType': 'DOCUMENT',
              'entityId': 'd',
              'title': 'التأمين',
              'body': 'ينتهي بعد 5 أيام',
              'createdAt': '2026-09-25T00:00:00Z',
              'readAt': read ? '2026-09-25T00:00:00Z' : null,
            },
          ],
          'page': 0,
          'pageSize': 30,
          'total': 1,
        });
      }
      if (path.endsWith('/documents/d')) return reply(doc());
      if (path.endsWith('/equipment/eq')) return reply(equipment);
      if (path.endsWith('/documents/d/versions/v1/attachments')) {
        return reply([]);
      }
      return reply([]);
    });
    await tester.pumpWidget(
      launcher(
        (_) => Scaffold(
          appBar: AppBar(actions: [NotificationButton(api: api)]),
        ),
      ),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('الإشعارات • 1 غير مقروء'), findsOneWidget);
    await tester.tap(find.byKey(const Key('openNotifications')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التأمين'));
    await tester.pumpAndSettle();
    expect(calls, contains('POST /api/v1/workspaces/w/notifications/n/read'));
    expect(find.byKey(const Key('renewDocument')), findsOneWidget);
    Navigator.of(tester.element(find.byType(DocumentDetailPage))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('markAllNotificationsRead')));
    await tester.pumpAndSettle();
    expect(calls, contains('POST /api/v1/workspaces/w/notifications/read-all'));
  });
  testWidgets('upload failure keeps form values and retry uses saved version', (
    tester,
  ) async {
    var puts = 0, creates = 0;
    final api = apiWith((request) async {
      final path = request.url.path;
      if (path.endsWith('/duplicates')) return reply([]);
      if (request.method == 'POST' && path.endsWith('/documents')) {
        creates++;
        return reply(doc());
      }
      if (request.method == 'POST' && path.endsWith('/attachments')) {
        return reply({'id': 'a'});
      }
      if (request.method == 'PUT' && path.endsWith('/attachments/a/content')) {
        puts++;
        return puts == 1
            ? reply({'code': 'UPLOAD_FAILED', 'message': 'تعذر رفع الملف'}, 503)
            : reply({'id': 'a'});
      }
      return reply([]);
    });
    await tester.pumpWidget(
      launcher(
        (_) => DocumentFormPage(
          api: api,
          equipment: equipment,
          pickFile: () async => DocumentUpload(
            'policy.png',
            'image/png',
            Uint8List.fromList([1, 2, 3]),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'POL-44');
    await tester.tap(find.byKey(const Key('selectDocumentAttachment')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('saveDocument')));
    expect(find.text('تعذر رفع الملف'), findsOneWidget);
    expect(find.text('POL-44'), findsOneWidget);
    expect(find.byKey(const Key('saveDocument')), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('saveDocument')));
    expect(creates, 1);
    expect(puts, 2);
  });
}
