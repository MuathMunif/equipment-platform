import 'dart:async';
import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/reports.dart';
import 'package:equipment_app/main.dart' show WorkspacePage;
import 'package:equipment_app/documents.dart' show HomeDocumentAttention;
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response answer(Object value,[int code=200])=>http.Response(jsonEncode(value),code,
  headers:{'content-type':'application/json; charset=utf-8'});
Widget host(Widget page,{String locale='ar'})=>MaterialApp(locale:Locale(locale),
  supportedLocales:AppLocalizations.supportedLocales,
  localizationsDelegates:AppLocalizations.localizationsDelegates,
  home:Scaffold(body:page));
Map<String,dynamic> dashboard(String amount)=>{
  'month':'2026-09','fromDate':'2026-09-01','toDate':'2026-09-30','activeEquipmentCount':1,
  'summary':{'recordedIncome':'20.00','recordedExpenses':amount,'recordedDifference':'-80.00',
    'fromDate':'2026-09-01','toDate':'2026-09-30','groups':[]},'recentEntries':[]};
Map<String,dynamic> movements({String paid='0.00',String recovered='200.00',String net='-200.00'})=>{
  'summary':{'collected':'0.00','incomeRefunds':'0.00','netCollected':'0.00',
    'paid':paid,'expenseRefunds':recovered,'netPaid':net,'fromDate':'2026-10-01','toDate':'2026-10-31'},
  'items':[{'movementId':'m','entryId':'e','entryType':'EXPENSE','movementType':'REFUND',
    'movementDate':'2026-10-03','amount':'200.00','movementTotal':'200.00','entryTotal':'1000.00','expenseScope':'SINGLE'}],
  'page':0,'pageSize':30,'total':1};
void main(){
  testWidgets('project picker searches and pages beyond 100 without exposing forbidden projects',(tester)async{
    tester.view.physicalSize=const Size(800,1100);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final requests=<Uri>[];
    final first=List.generate(100,(i)=>{'id':'p$i','name':'Project $i'});
    final api=Api(client:MockClient((request)async{
      requests.add(request.url);
      final q=request.url.queryParameters;
      if(q['search']=='Project 101') return answer([{'id':'p101','name':'Project 101'}]);
      if(q['page']=='1') return answer([{'id':'p101','name':'Project 101'}]);
      return answer(first);
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(Scaffold(body:ProjectSearchPicker(api:api,
      selectedId:'p101',selectedName:'Project 101')),locale:'en'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('projectPickerSelection')),findsOneWidget);
    expect(find.text('Forbidden project'),findsNothing);
    await tester.scrollUntilVisible(find.byKey(const Key('projectPickerMore')),500,
      scrollable:find.byType(Scrollable).last);
    await tester.tap(find.byKey(const Key('projectPickerMore')));
    await tester.pumpAndSettle();
    expect(requests.last.queryParameters['page'],'1');
    await tester.enterText(find.byKey(const Key('projectPickerSearch')),'Project 101');
    await tester.pump(const Duration(milliseconds:350));
    await tester.pumpAndSettle();
    expect(requests.last.queryParameters['search'],'Project 101');
    expect(requests.last.queryParameters['page'],'0');
    expect(find.widgetWithText(ListTile,'Project 101'),findsOneWidget);
  });
  testWidgets('dashboard expense card opens journal with identical month and type',(tester)async{
    tester.view.physicalSize=const Size(800,1400);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final paths=<Uri>[];
    final api=Api(client:MockClient((request)async{
      paths.add(request.url);
      if(request.url.path.endsWith('/dashboard'))return answer(dashboard('100.00'));
      if(request.url.path.endsWith('/entries'))return answer({'items':[],'total':0});
      return answer({'items':[],'total':0});
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(DashboardSection(api:api,canFinance:true,canManage:false,canSubmitReview:false)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recordedExpenseCard')));
    await tester.pumpAndSettle();
    final journal=paths.lastWhere((uri)=>uri.path.endsWith('/entries'));
    expect(journal.queryParameters['entryType'],'EXPENSE');
    expect(journal.queryParameters['fromDate'],"${paths.first.queryParameters['month']}-01");
    expect(journal.queryParameters['toDate'],_last(paths.first.queryParameters['month']!));
  });
  testWidgets('movement net can be negative and refund metric filters detail',(tester)async{
    tester.view.physicalSize=const Size(800,1800);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final paths=<Uri>[];
    final api=Api(client:MockClient((request)async{
      paths.add(request.url);
      if(request.url.path.endsWith('/reports/recorded'))return answer({'summary':{'recordedIncome':'0.00','recordedExpenses':'0.00','recordedDifference':'0.00','fromDate':'2026-09-01','toDate':'2026-09-30','groups':[]},'items':[],'page':0,'pageSize':30,'total':0});
      if(request.url.path.endsWith('/reports/movements'))return answer(movements());
      return answer([]);
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(ReportsPage(api:api,canProjects:false),locale:'en'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payments and collections'));
    await tester.pumpAndSettle();
    expect(find.textContaining('-200'),findsWidgets);
    await tester.ensureVisible(find.text('Recovered from expenses'));
    await tester.tap(find.text('Recovered from expenses'));
    await tester.pumpAndSettle();
    final movement=paths.lastWhere((uri)=>uri.path.endsWith('/reports/movements'));
    expect(movement.queryParameters['movementType'],'REFUND');
    expect(movement.queryParameters['entryType'],'EXPENSE');
  });
  testWidgets('report group opens exactly matching equipment share rows',(tester)async{
    tester.view.physicalSize=const Size(800,1500);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final paths=<Uri>[];
    final api=Api(client:MockClient((request)async{
      paths.add(request.url);
      return answer({'summary':{'recordedIncome':'0.00','recordedExpenses':'700.00','recordedDifference':'-700.00',
        'fromDate':'2026-09-01','toDate':'2026-09-30','groups':[{'entryType':'EXPENSE','equipmentId':'eq-a','equipmentName':'Truck A','generalExpense':false,'amount':'700.00'}]},
        'items':[{'entryId':'e','entryType':'EXPENSE','operationDate':'2026-09-01','amount':'700.00','entryTotal':'1200.00','expenseScope':'SHARED'}],
        'page':0,'pageSize':30,'total':1});
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(ReportsPage(api:api,canProjects:false),locale:'en'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Truck A'));
    await tester.pumpAndSettle();
    expect(paths.last.queryParameters['equipmentId'],'eq-a');
    expect(paths.last.queryParameters['entryType'],'EXPENSE');
    expect(find.textContaining('Original entry total'),findsOneWidget);
  });
  testWidgets('dashboard omits finance and discards old workspace response',(tester)async{
    final old=Completer<http.Response>();
    final api=Api(client:MockClient((request)async{
      if(request.url.path.contains('/workspaces/old/'))return old.future;
      return answer({'month':'2026-09','fromDate':'2026-09-01','toDate':'2026-09-30','activeEquipmentCount':2});
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='old';
    await tester.pumpWidget(host(DashboardSection(key:const ValueKey('old'),api:api,canFinance:false,canManage:false,canSubmitReview:false)));
    api.workspace='new';
    await tester.pumpWidget(host(DashboardSection(key:const ValueKey('new'),api:api,canFinance:false,canManage:false,canSubmitReview:false)));
    await tester.pumpAndSettle();
    old.complete(answer(dashboard('999.00')));await tester.pumpAndSettle();
    expect(find.textContaining('999'),findsNothing);
    expect(find.text('2'),findsOneWidget);
    expect(find.byKey(const Key('recordedExpenseCard')),findsNothing);
  });
  testWidgets('finance-only member can see home card without report menu',(tester)async{
    tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final api=Api(client:MockClient((request)async{
      if(request.url.path.endsWith('/dashboard'))return answer(dashboard('100.00'));
      if(request.url.path.endsWith('/attention')||request.url.path.endsWith('/documents/incomplete'))return answer([]);
      if(request.url.path.endsWith('/notifications/unread-count'))return answer({'unreadCount':0});
      return answer({'items':[],'total':0});
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(WorkspacePage(api:api,user:{'name':'محاسب','workspaces':[{
      'id':'w','name':'مساحة','role':'ACCOUNTANT','financialMode':'DIRECT',
      'capabilities':['EQUIPMENT_VIEW','FINANCE_VIEW','DOCUMENT_VIEW']} ]},logout:(){})));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recordedExpenseCard')),findsOneWidget);
    await tester.tap(find.text('المزيد').last);await tester.pumpAndSettle();
    expect(find.text('التقارير'),findsNothing);
  });
  testWidgets('finance-only home skips equipment data and count',(tester)async{
    final requested=<String>[];
    final api=Api(client:MockClient((request)async{
      requested.add(request.url.path);
      if(request.url.path.endsWith('/dashboard'))return answer({...dashboard('100.00')}..remove('activeEquipmentCount'));
      if(request.url.path.endsWith('/attention'))return answer([]);
      if(request.url.path.endsWith('/notifications/unread-count'))return answer({'unreadCount':0});
      return answer({'items':[],'total':0});
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(WorkspacePage(api:api,user:{'name':'محاسب','workspaces':[
      {'id':'w','name':'مساحة','role':'ACCOUNTANT','financialMode':'DIRECT','capabilities':['FINANCE_VIEW']}
    ]},logout:(){})));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recordedExpenseCard')),findsOneWidget);
    expect(find.text('المعدات النشطة'),findsNothing);
    expect(find.byKey(const Key('addEquipment')),findsNothing);
    expect(requested.any((path)=>path.endsWith('/equipment')),false);
  });
  testWidgets('empty owner sees add equipment before attention',(tester)async{
    tester.view.physicalSize=const Size(390,2000);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final api=Api(client:MockClient((request)async{
      if(request.url.path.endsWith('/dashboard'))return answer(dashboard('0.00'));
      if(request.url.path.endsWith('/attention')||request.url.path.endsWith('/documents/incomplete'))return answer([]);
      if(request.url.path.endsWith('/notifications/unread-count'))return answer({'unreadCount':0});
      return answer({'items':[],'total':0});
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(WorkspacePage(api:api,user:{'name':'مالك','workspaces':[
      {'id':'w','name':'مساحة','role':'OWNER','financialMode':'DIRECT','capabilities':[]}
    ]},logout:(){})));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const Key('addEquipment'))).dy,
      lessThan(tester.getTopLeft(find.text('يحتاج انتباه')).dy));
  });
  testWidgets('month choice is month-only and recent empty is explicit',(tester)async{
    tester.view.physicalSize=const Size(800,1200);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final requested=<Uri>[];
    final api=Api(client:MockClient((request)async{requested.add(request.url);return answer(dashboard('100.00'));}),
      base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(DashboardSection(api:api,canFinance:true,canManage:false,canSubmitReview:false),locale:'en'));
    await tester.pumpAndSettle();
    expect(find.text('No recent financial entries yet.'),findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboardMonth')));await tester.pumpAndSettle();
    expect(find.text('January'),findsOneWidget);
    expect(find.byType(DatePickerDialog),findsNothing);
    await tester.tap(find.text('January'));await tester.pumpAndSettle();
    expect(requested.last.queryParameters['month'],endsWith('-01'));
  });
  testWidgets('issue attention remains when document permission is absent',(tester)async{
    final paths=<String>[];
    final api=Api(client:MockClient((request)async{
      paths.add(request.url.path);
      if(request.url.path.endsWith('/attention')) { return answer([{'entityType':'ISSUE','issueId':'issue',
        'equipmentName':'شاحنة','description':'عطل','equipmentStopped':true}]); }
      return answer([],404);
    }),base:'http://localhost/api/v1',persistNative:false)..workspace='w';
    await tester.pumpWidget(host(HomeDocumentAttention(api:api,showIncomplete:false)));
    await tester.pumpAndSettle();
    expect(find.textContaining('شاحنة'),findsOneWidget);
    expect(paths.any((path)=>path.endsWith('/documents/incomplete')),false);
  });
  for(final locale in ['ar','en','ur']){
    testWidgets('report choices have localized direction $locale',(tester)async{
      tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final api=Api(client:MockClient((_)async=>answer({'summary':{'recordedIncome':'0.00','recordedExpenses':'0.00','recordedDifference':'0.00','fromDate':'2026-09-01','toDate':'2026-09-30','groups':[]},'items':[],'page':0,'pageSize':30,'total':0})),
        base:'http://localhost/api/v1',persistNative:false)..workspace='w';
      await tester.pumpWidget(host(ReportsPage(api:api,canProjects:false),locale:locale));await tester.pumpAndSettle();
      expect(Directionality.of(tester.element(find.byType(ReportsPage))),locale=='en'?TextDirection.ltr:TextDirection.rtl);
      expect(find.byType(ChoiceChip),findsNWidgets(3));
      expect(find.textContaining('2026-09-01'),findsNothing);
      expect(tester.takeException(),isNull);
    });
  }
}
String _last(String month){final parts=month.split('-').map(int.parse).toList();return DateTime(parts[0],parts[1]+1,0).toIso8601String().substring(0,10);}
