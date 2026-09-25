import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/main.dart';
import 'package:equipment_app/documents.dart';
import 'package:equipment_app/maintenance.dart';
import 'package:equipment_app/team.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response reply(Object value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Widget host(Widget page) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: page,
);

void main() {
  test('auth profile restores the selected workspace and selection uses its endpoint', () async {
    final paths = <String>[];
    final api = Api(
      client: MockClient((request) async {
        paths.add('${request.method} ${request.url.path}');
        if (request.url.path.endsWith('/auth/me')) {
          return reply({
            'csrfToken': 'csrf',
            'lastWorkspaceId': 'second',
            'workspaces': [
              {'id': 'first'},
              {'id': 'second'},
            ],
          });
        }
        return reply({'selectedWorkspaceId': 'first'});
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    );
    await api.me();
    expect(api.workspace, 'second');
    await api.selectWorkspace('first');
    expect(api.workspace, 'first');
    expect(paths.last, 'PUT /api/v1/workspaces/first/selection');
  });

  testWidgets(
    'driver invitation sends assigned scope and default permissions',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic>? sent;
      final api = Api(
        client: MockClient((request) async {
          if (request.method == 'GET') return reply({'items': [], 'total': 0});
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return reply({'id': 'invite'});
        }),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'workspace';
      await tester.pumpWidget(host(TeamEditorPage(api: api)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('inviteName')), 'أحمد');
      await tester.enterText(
        find.byKey(const Key('invitePhone')),
        '٠٥٠٠٠٠٠٠٠٣',
      );
      tester.testTextInput.hide();
      await tester.ensureVisible(find.byKey(const Key('saveTeamMember')));
      await tester.tap(find.byKey(const Key('saveTeamMember')));
      await tester.pumpAndSettle();
      expect(sent?['role'], 'DRIVER');
      expect(sent?['scope'], 'ASSIGNED_EQUIPMENT');
      expect(sent?['phone'], '0500000003');
      expect(sent?['capabilities'], contains('FINANCE_MANAGE'));
    },
  );

  testWidgets(
    'pending submission opens approval and posts one full expense without initialPaid',
    (tester) async {
      Map<String, dynamic>? approved;
      final submission = {
        'id': 'submission',
        'equipmentId': 'equipment',
        'equipmentName': 'قلاب',
        'submitterName': 'أحمد',
        'amount': '120.00',
        'transactionDate': '2026-09-25',
        'status': 'PENDING_REVIEW',
        'note': 'وقود',
        'attachments': <Object>[],
      };
      final api = Api(
        client: MockClient((request) async {
          if (request.method == 'GET') return reply(submission);
          approved = jsonDecode(request.body) as Map<String, dynamic>;
          return reply({...submission, 'status': 'APPROVED'});
        }),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'workspace';
      await tester.pumpWidget(
        host(SubmissionDetailPage(api: api, id: 'submission', reviewer: true)),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('approveSubmission')));
      await tester.tap(find.byKey(const Key('approveSubmission')));
      await tester.pumpAndSettle();
      expect(find.byType(ApprovalPage), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('confirmApproval')),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.drag(find.byType(ListView).last, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmApproval')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('اعتماد').last);
      await tester.pumpAndSettle();
      expect(approved?['equipmentId'], 'equipment');
      expect(approved?['expenseScope'], 'SINGLE');
      expect(approved?['paymentStatus'], 'FULL');
      expect(approved?['initialPaid'], isNull);
    },
  );

  testWidgets('driver gets simple home without ledger navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = Api(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/drivers/me/assignment')) {
          return reply({'equipmentId': null});
        }
        if (request.url.path.contains('/financial-submissions/mine')) {
          return reply({'items': [], 'total': 0});
        }
        if (request.url.path.endsWith('/notifications/unread-count')) {
          return reply({'unreadCount': 0});
        }
        return reply({'items': [], 'total': 0});
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'workspace';
    await tester.pumpWidget(
      host(
        WorkspacePage(
          api: api,
          user: {
            'name': 'أحمد',
            'workspaces': [
              {
                'id': 'workspace',
                'name': 'مساحة',
                'role': 'DRIVER',
                'financialMode': 'REVIEW',
                'capabilities': ['EQUIPMENT_VIEW', 'FINANCE_MANAGE'],
              },
            ],
          },
          logout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('لا توجد معدة معيّنة لك حاليًا.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('openTeam')), findsNothing);
    expect(tester.takeException(), isNull);
    expect(
      Directionality.of(
        tester.element(find.text('لا توجد معدة معيّنة لك حاليًا.')),
      ),
      TextDirection.rtl,
    );
  });

  testWidgets('financial attention opens review queue', (tester) async {
    final api = Api(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/attention')) {
          return reply([
            {
              'entityType': 'FINANCIAL_REVIEW',
              'pendingCount': 2,
              'priorityRank': 5,
            },
          ]);
        }
        if (request.url.path.contains('/financial-submissions/review-queue')) {
          return reply({'items': [], 'total': 0});
        }
        return reply([]);
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'workspace';
    await tester.pumpWidget(host(AttentionPage(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 طلبات مالية بانتظار المراجعة'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewQueuePage), findsOneWidget);
  });

  testWidgets('review rejection requires a reason and sends it once', (
    tester,
  ) async {
    Map<String, dynamic>? rejected;
    final item = {
      'id': 'request',
      'equipmentId': 'equipment',
      'equipmentName': 'معدة',
      'submitterName': 'سائق',
      'status': 'PENDING_REVIEW',
      'transactionDate': '2026-09-25',
      'attachments': <Object>[],
    };
    final api = Api(
      client: MockClient((request) async {
        if (request.method == 'GET') return reply(item);
        rejected = jsonDecode(request.body) as Map<String, dynamic>;
        return reply({...item, 'status': 'REJECTED'});
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'workspace';
    await tester.pumpWidget(
      host(SubmissionDetailPage(api: api, id: 'request', reviewer: true)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('rejectSubmission')));
    await tester.tap(find.byKey(const Key('rejectSubmission')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفض').last);
    await tester.pumpAndSettle();
    expect(rejected, isNull);
    expect(find.text('اكتب سبب الرفض'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('rejectSubmission')));
    await tester.tap(find.byKey(const Key('rejectSubmission')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('rejectionReason')),
      'الإيصال غير واضح',
    );
    await tester.tap(find.text('رفض').last);
    await tester.pumpAndSettle();
    expect(rejected?['reason'], 'الإيصال غير واضح');
    expect(tester.takeException(), isNull);
  });

  testWidgets('owner assigns a driver to selected equipment after warning', (
    tester,
  ) async {
    Map<String, dynamic>? assigned;
    final api = Api(
      client: MockClient((request) async {
        if (request.method == 'POST') {
          assigned = jsonDecode(request.body) as Map<String, dynamic>;
          return reply({'id': 'assignment'});
        }
        if (request.url.path.endsWith(
          '/drivers/equipment/equipment/assignment',
        )) {
          return reply({
            'equipmentId': 'equipment',
            'assignmentId': null,
            'driverUserId': null,
            'driverName': null,
            'startedAt': null,
          });
        }
        if (request.url.path.endsWith('/assignments')) return reply([]);
        return reply({
          'items': [
            {'id': 'equipment', 'name': 'قلاب', 'reference': 'EQ-000001', 'archivedAt': null},
          ],
          'total': 1,
        });
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'workspace';
    await tester.pumpWidget(
      host(
        DriverAssignmentPage(
          api: api,
          driver: {'userId': 'driver', 'displayName': 'أحمد'},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('assignmentEquipment')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('قلاب • EQ-000001').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('assignDriver')));
    await tester.pumpAndSettle();
    expect(assigned, isNull);
    expect(find.text('تعيين أحمد على قلاب؟'), findsOneWidget);
    await tester.tap(find.text('تعيين').last);
    await tester.pumpAndSettle();
    expect(assigned?['driverUserId'], 'driver');
    expect(assigned?['equipmentId'], 'equipment');
  });

  testWidgets(
    'maintenance read only member sees no finance summary or mutation controls',
    (tester) async {
      final api =
          Api(
              client: MockClient((request) async {
                if (request.url.path.endsWith('/maintenance/record')) {
                  return reply({
                    'id': 'record',
                    'equipmentId': 'equipment',
                    'equipmentName': 'قلاب',
                    'description': 'تغيير زيت',
                    'maintenanceDate': '2026-09-25',
                    'type': null,
                    'workshop': null,
                    'issueId': null,
                    'cancelledAt': null,
                    'equipmentArchived': false,
                  });
                }
                return reply([]);
              }),
              base: 'http://localhost/api/v1',
              persistNative: false,
            )
            ..workspace = 'workspace'
            ..capabilities = {'MAINTENANCE_VIEW'};
      await tester.pumpWidget(
        host(MaintenanceDetailPage(api: api, id: 'record')),
      );
      await tester.pumpAndSettle();
      expect(find.text('تغيير زيت'), findsOneWidget);
      expect(find.text('إضافة مصروف'), findsNothing);
      expect(find.text('تعديل الصيانة'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'scoped assignment manager opens equipment picker without team access and confirms replacement and move',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final paths = <String>[];
      Map<String, dynamic>? assigned;
      final api = Api(
        client: MockClient((request) async {
          paths.add('${request.method} ${request.url.path}');
          if (request.url.path.endsWith('/equipment')) {
            return reply({
              'items': [
                {
                  'id': 'target',
                  'name': 'الشاحنة ١',
                  'model': 'M',
                  'reference': 'EQ-1',
                  'archivedAt': null,
                },
              ],
              'total': 1,
            });
          }
          if (request.url.path.endsWith(
            '/drivers/equipment/target/assignment',
          )) {
            return reply({
              'equipmentId': 'target',
              'assignmentId': 'old',
              'driverUserId': 'old-driver',
              'driverName': 'سالم',
              'startedAt': '2026-09-24T10:00:00Z',
            });
          }
          if (request.url.path.endsWith('/drivers/eligible')) {
            return reply([
              {
                'userId': 'new-driver',
                'displayName': 'أحمد',
                'currentEquipmentId': 'source',
                'currentEquipmentName': 'الشاحنة ٢',
                'startedAt': '2026-09-23T10:00:00Z',
              },
            ]);
          }
          if (request.method == 'POST' &&
              request.url.path.endsWith('/drivers/assignments')) {
            assigned = jsonDecode(request.body) as Map<String, dynamic>;
            return reply({'id': 'new-assignment'});
          }
          if (request.url.path.endsWith('/notifications/unread-count')) {
            return reply({'unreadCount': 0});
          }
          return reply([]);
        }),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'workspace';
      await tester.pumpWidget(
        host(
          WorkspacePage(
            api: api,
            user: {
              'name': 'مدير',
              'workspaces': [
                {
                  'id': 'workspace',
                  'name': 'مساحة',
                  'role': 'MANAGER',
                  'scope': 'SELECTED_EQUIPMENT',
                  'capabilities': [
                    'EQUIPMENT_VIEW',
                    'DRIVER_ASSIGNMENT_MANAGE',
                  ],
                },
              ],
            },
            logout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('workspaceMenu')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('openTeam')), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tap(find.text('الشاحنة ١'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('openEquipmentDriverAssignment')));
      await tester.pumpAndSettle();
      expect(find.text('سالم'), findsOneWidget);
      expect(
        paths,
        contains(
          'GET /api/v1/workspaces/workspace/drivers/equipment/target/assignment',
        ),
      );
      expect(
        paths,
        contains('GET /api/v1/workspaces/workspace/drivers/eligible'),
      );
      expect(paths.where((path) => path.contains('/team/')), isEmpty);
      await tester.tap(find.byKey(const Key('eligibleDriverPicker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('أحمد').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('assignEligibleDriver')));
      await tester.pumpAndSettle();
      expect(find.text('استبدال سالم بـ أحمد على الشاحنة ١؟'), findsOneWidget);
      expect(
        find.text('سينتهي تعيين أحمد الحالي على الشاحنة ٢.'),
        findsOneWidget,
      );
      expect(assigned, isNull);
      await tester.tap(
        find.byKey(const Key('confirmEquipmentDriverAssignment')),
      );
      await tester.pumpAndSettle();
      expect(assigned, {'driverUserId': 'new-driver', 'equipmentId': 'target'});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'owner keeps equipment assignment and team entry without explicit capability',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = Api(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/equipment')) {
            return reply({
              'items': [
                {
                  'id': 'target',
                  'name': 'قلاب',
                  'model': 'M',
                  'reference': 'EQ-1',
                  'archivedAt': null,
                },
              ],
              'total': 1,
            });
          }
          if (request.url.path.endsWith(
            '/drivers/equipment/target/assignment',
          )) {
            return reply({
              'equipmentId': 'target',
              'assignmentId': null,
              'driverUserId': null,
              'driverName': null,
              'startedAt': null,
            });
          }
          if (request.url.path.endsWith('/drivers/eligible')) {
            return reply([
              {
                'userId': 'driver',
                'displayName': 'خالد',
                'currentEquipmentId': null,
                'currentEquipmentName': null,
                'startedAt': null,
              },
            ]);
          }
          if (request.url.path.endsWith('/notifications/unread-count')) {
            return reply({'unreadCount': 0});
          }
          return reply([]);
        }),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'workspace';
      await tester.pumpWidget(
        host(
          WorkspacePage(
            api: api,
            user: {
              'name': 'مالك',
              'workspaces': [
                {
                  'id': 'workspace',
                  'name': 'مساحة',
                  'role': 'OWNER',
                  'capabilities': <String>[],
                },
              ],
            },
            logout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('workspaceMenu')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('openTeam')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tap(find.text('قلاب'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('openEquipmentDriverAssignment')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('openEquipmentDriverAssignment')));
      await tester.pumpAndSettle();
      expect(find.text('لا يوجد تعيين حالي'), findsOneWidget);
      expect(find.byKey(const Key('eligibleDriverPicker')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
