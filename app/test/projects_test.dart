import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/projects.dart';
import 'package:equipment_app/main.dart' show ExpenseForm;
import 'package:equipment_app/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response answer(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Widget host(Widget child, [String locale = 'ar']) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: child,
);

void main() {
  testWidgets('project lifetime figure opens matching report basis and Back preserves summary',(tester)async{
    tester.view.physicalSize=const Size(800,1500);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final paths=<Uri>[];
    final api=Api(client:MockClient((request)async{
      paths.add(request.url);
      final path=request.url.path;
      if(path.endsWith('/projects/p/equipment')) return answer([]);
      if(path.endsWith('/projects/p/financial-summary')) {
        return answer({
        'recordedIncome':'1000.00','recordedExpenses':'0.00',
        'recordedDifference':'1000.00','collected':'400.00','paid':'0.00',
        'receivablesRemaining':'600.00','payablesRemaining':'0.00'});
      }
      if(path.endsWith('/projects/p')) {
        return answer({'id':'p','name':'Contract A',
        'kind':'PROJECT','status':'ACTIVE','archived_at':null});
      }
      if(path.endsWith('/reports/recorded')) {
        return answer({'summary':{
        'recordedIncome':'1000.00','recordedExpenses':'0.00',
        'recordedDifference':'1000.00','fromDate':'0001-01-01',
        'toDate':'9999-12-31','groups':[]},'items':[],
        'page':0,'pageSize':30,'total':0});
      }
      if(path.endsWith('/reports/movements')) {
        return answer({'summary':{
        'collected':'600.00','incomeRefunds':'200.00','netCollected':'400.00',
        'paid':'0.00','expenseRefunds':'0.00','netPaid':'0.00',
        'fromDate':'0001-01-01','toDate':'9999-12-31'},'items':[],
        'page':0,'pageSize':30,'total':0});
      }
      if(path.endsWith('/reports/outstanding')) {
        return answer({'summary':{
        'receivable':'600.00','payable':'0.00'},'items':[],
        'page':0,'pageSize':30,'total':0});
      }
      return answer([],404);
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(ProjectDetail(api:api,id:'p',canManage:false,canFinance:true),'en'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Recorded income'));
    await tester.tap(find.text('Recorded income'));
    await tester.pumpAndSettle();
    final recorded=paths.lastWhere((uri)=>uri.path.endsWith('/reports/recorded'));
    expect(recorded.queryParameters['projectId'],'p');
    expect(recorded.queryParameters['entryType'],'INCOME');
    expect(recorded.queryParameters['fromDate'],'0001-01-01');
    expect(recorded.queryParameters['toDate'],'9999-12-31');
    await tester.pageBack();await tester.pumpAndSettle();
    expect(find.text('Contract A'),findsOneWidget);
    await tester.ensureVisible(find.text('Net collected'));
    await tester.tap(find.text('Net collected'));await tester.pumpAndSettle();
    final movements=paths.lastWhere((uri)=>uri.path.endsWith('/reports/movements'));
    expect(movements.queryParameters['projectId'],'p');
    expect(movements.queryParameters['entryType'],'INCOME');
    expect(movements.queryParameters.containsKey('movementType'),false);
    expect(find.text('Net collected'), findsOneWidget);
    await tester.pageBack();await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Remaining receivable'));
    await tester.tap(find.text('Remaining receivable'));await tester.pumpAndSettle();
    final outstanding=paths.lastWhere((uri)=>uri.path.endsWith('/reports/outstanding'));
    expect(outstanding.queryParameters['projectId'],'p');
    expect(outstanding.queryParameters.containsKey('fromDate'),false);
  });
  testWidgets('organization creation keeps only name required', (tester) async {
    Map<String, dynamic>? sent;
    final api = Api(
      client: MockClient((request) async {
        if (request.method == 'POST') {
          sent = jsonDecode(request.body) as Map<String, dynamic>;
        }
        return answer({'id': 'org', 'name': 'مؤسسة الاختبار'});
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(host(OrganizationForm(api: api)));
    await tester.enterText(
      find.byKey(const Key('organizationName')),
      'مؤسسة الاختبار',
    );
    await tester.ensureVisible(find.byKey(const Key('saveOrganization')));
    await tester.tap(find.byKey(const Key('saveOrganization')));
    await tester.pumpAndSettle();
    expect(sent?['name'], 'مؤسسة الاختبار');
    expect(sent?['identifier'], '');
  });

  testWidgets('contract is one project record with optional organization', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Map<String, dynamic>? sent;
    final api = Api(
      client: MockClient((request) async {
        if (request.method == 'GET') return answer([]);
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return answer({'id': 'project'});
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(host(ProjectForm(api: api), 'en'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('projectKind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contract').last);
    await tester.enterText(
      find.byKey(const Key('projectName')),
      'Riyadh contract',
    );
    await tester.ensureVisible(find.byKey(const Key('saveProject')));
    await tester.tap(find.byKey(const Key('saveProject')));
    await tester.pumpAndSettle();
    expect(sent?['kind'], 'CONTRACT');
    expect(sent?['organizationId'], isNull);
  });

  testWidgets('organizations empty state says they are optional', (
    tester,
  ) async {
    final api = Api(
      client: MockClient((_) async => answer([])),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(host(OrganizationsPage(api: api, canManage: true)));
    await tester.pumpAndSettle();
    expect(find.textContaining('اختيارية'), findsOneWidget);
    expect(find.byKey(const Key('addOrganization')), findsOneWidget);
  });

  testWidgets(
    'member can select organization scope without picking equipment',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic>? sent;
      final api = Api(
        client: MockClient((request) async {
          if (request.method == 'GET' &&
              request.url.path.endsWith('/equipment')) {
            return answer({'items': [], 'total': 0});
          }
          if (request.method == 'GET') {
            return answer([
              {'id': 'org-1', 'name': 'شركة'},
            ]);
          }
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return answer({'id': 'invitation'});
        }),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(host(TeamEditorPage(api: api)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('inviteName')), 'أحمد');
      await tester.enterText(
        find.byKey(const Key('invitePhone')),
        '0500000003',
      );
      await tester.tap(find.byKey(const Key('teamRole')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مدير').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('teamScope')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مؤسسات محددة').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('memberOrganization-org-1')),
      );
      await tester.tap(find.byKey(const Key('memberOrganization-org-1')));
      await tester.ensureVisible(find.byKey(const Key('saveTeamMember')));
      await tester.tap(find.byKey(const Key('saveTeamMember')));
      await tester.pumpAndSettle();
      expect(sent?['scope'], 'SELECTED_ORGANIZATIONS');
      expect(sent?['organizationIds'], ['org-1']);
      expect(sent?['equipmentIds'], isEmpty);
    },
  );

  testWidgets('organization assignment can remove current organization', (
    tester,
  ) async {
    Map<String, dynamic>? sent;
    final api = Api(
      client: MockClient((request) async {
        if (request.method == 'PUT') {
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return answer({'equipmentId': 'eq', 'organizationId': null});
        }
        if (request.url.path.endsWith('/organizations')) {
          return answer([
            {'id': 'org', 'name': 'شركة'},
          ]);
        }
        return answer({
          'items': [
            {'id': 'eq', 'name': 'شاحنة', 'organizationId': 'org'},
          ],
          'total': 1,
        });
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(
      host(EquipmentOrganizationPage(api: api, equipmentId: 'eq')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('equipmentOrganizationChoice')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بدون مؤسسة').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('saveEquipmentOrganization')),
    );
    await tester.tap(find.byKey(const Key('saveEquipmentOrganization')));
    await tester.pumpAndSettle();
    expect(sent, isNull);
    await tester.tap(find.text('حفظ').last);
    await tester.pumpAndSettle();
    expect(sent, isNotNull);
    expect(sent?['organizationId'], isNull);
  });

  testWidgets(
    'project form retains preselected organization while choices load',
    (tester) async {
      final api = Api(
        client: MockClient(
          (request) async => answer([
            {'id': 'org', 'name': 'شركة'},
          ]),
        ),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(
        host(ProjectForm(api: api, initialOrganizationId: 'org')),
      );
      await tester.pumpAndSettle();
      final field = tester.widget<DropdownButtonFormField<String?>>(
        find.byKey(const Key('projectOrganization')),
      );
      expect(field.initialValue, 'org');
    },
  );

  testWidgets(
    'project edit waits for organization choices after load failure',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = Api(
        client: MockClient((_) async => answer({'code': 'NETWORK'}, 503)),
        base: 'http://localhost/api/v1',
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(
        host(
          ProjectForm(
            api: api,
            item: {
              'id': 'project',
              'kind': 'PROJECT',
              'name': 'مشروع',
              'organization_id': 'org',
              'organization_name': 'شركة',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('saveProject')))
            .onPressed,
        isNull,
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    },
  );

  testWidgets('project preselection is sent with normal M2 expense', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Map<String, dynamic>? sent;
    final api = Api(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return answer([
            {'id': 'project', 'name': 'مشروع'},
          ]);
        }
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return answer({'id': 'entry'});
      }),
      base: 'http://localhost/api/v1',
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(
      host(
        ExpenseForm(
          api: api,
          equipment: {'id': 'eq', 'name': 'شاحنة'},
          initialProjectId: 'project',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('expenseAmount')), '100');
    await tester.ensureVisible(find.byKey(const Key('saveExpense')));
    await tester.tap(find.byKey(const Key('saveExpense')));
    await tester.pumpAndSettle();
    expect(sent?['projectId'], 'project');
  });
}
