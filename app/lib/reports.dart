import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api.dart';
import 'localization.dart';
import 'main.dart' show EntryDetail, LedgerPage, HistoryEquipmentPicker;
import 'projects.dart' show m6Rows;

String _month(String date) => date.substring(0, 7);
String _first(String month) => '$month-01';
String _last(String month) {
  final parts = month.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1] + 1, 0).toIso8601String().substring(0, 10);
}
String _todayMonth() => _month(todayRiyadh());

class DashboardSection extends StatefulWidget {
  final Api api;
  final bool canFinance, canEquipment, canManage, canSubmitReview;
  const DashboardSection({super.key, required this.api, required this.canFinance, this.canEquipment = true,
    required this.canManage, required this.canSubmitReview});
  @override
  State<DashboardSection> createState() => _DashboardSectionState();
}

class _DashboardSectionState extends State<DashboardSection> {
  String month = _todayMonth();
  Map<String, dynamic>? data;
  String? error;
  bool loading = true;
  int generation = 0;
  @override void initState() { super.initState(); load(); }
  @override void didUpdateWidget(DashboardSection old) {
    super.didUpdateWidget(old);
    if (old.api.workspace != widget.api.workspace) { data = null; load(); }
  }
  Future<void> load() async {
    final request = ++generation, workspace = widget.api.workspace;
    setState(() { loading = true; error = null; data = null; });
    try {
      final result = Map<String, dynamic>.from(await widget.api.json('GET',
        widget.api.scoped('/dashboard?month=$month')) as Map);
      if (mounted && request == generation && workspace == widget.api.workspace) {
        setState(() => data = result);
      }
    } catch (e) {
      if (mounted && request == generation && workspace == widget.api.workspace) {
        setState(() => error = localizedError(context, e));
      }
    } finally {
      if (mounted && request == generation && workspace == widget.api.workspace) {
        setState(() => loading = false);
      }
    }
  }
  Future<void> chooseMonth() async {
    final selected = await showDialog<String>(context: context,
      builder: (_) => _MonthPicker(initial: month));
    if (selected == null || !mounted) return;
    setState(() => month = selected);
    load();
  }
  void openLedger(String type) => Navigator.push(context, MaterialPageRoute(builder: (_) =>
    LedgerPage(api: widget.api, canManage: widget.canManage, canSubmitReview: widget.canSubmitReview,
      initialEntryType: type, initialFromDate: _first(month), initialToDate: _last(month))));
  @override Widget build(BuildContext context) {
    final loc = l10n(context);
    if (loading) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    if (error != null) { return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [Text(loc.m7LoadFailed), Text(error!),
      TextButton(onPressed: load, child: Text(loc.retry))]))); }
    final summary = data?['summary'] as Map<String, dynamic>?;
    final recent = data?['recentEntries'] as List<dynamic>? ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.canEquipment && data?.containsKey('activeEquipmentCount') == true)
        Card(child: ListTile(leading: const Icon(Icons.local_shipping_outlined),
          title: Text(loc.m7ActiveEquipment), trailing: Text('${data!['activeEquipmentCount']}'))),
      if (widget.canFinance && summary != null) ...[
        const SizedBox(height: 12),
        OutlinedButton.icon(key: const Key('dashboardMonth'), onPressed: chooseMonth,
          icon: const Icon(Icons.calendar_month_outlined), label: Text('${loc.m7ChooseMonth}: ${_localizedMonth(context, month)}')),
        Text(loc.m7EntryDateBasis, style: Theme.of(context).textTheme.bodySmall),
        Wrap(spacing: 12, runSpacing: 8, children: [
          _card(context, const Key('recordedExpenseCard'), loc.m7RecordedExpensesMonth,
            summary['recordedExpenses'], () => openLedger('EXPENSE')),
          _card(context, const Key('recordedIncomeCard'), loc.m7RecordedIncomeMonth,
            summary['recordedIncome'], () => openLedger('INCOME')),
        ]),
        const SizedBox(height: 14),
        Text(loc.m7RecentEntries, style: Theme.of(context).textTheme.titleMedium),
        if (recent.isEmpty) Text(loc.m7NoRecentEntries),
        for (final row in recent)
          ListTile(title: Text('${row['entryType'] == 'INCOME' ? loc.income : loc.expense} • ${localizedMoney(context, row['amount'])}'),
            subtitle: Text(localizedDate(context, row['operationDate'] as String?)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
              EntryDetail(api: widget.api, id: row['entryId'] as String)))),
      ],
    ]);
  }
  Widget _card(BuildContext context, Key key, String title, Object? amount, VoidCallback open) =>
    SizedBox(width: 245, child: Card(child: InkWell(key: key, onTap: open,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title), const SizedBox(height: 8), Text(localizedMoney(context, amount),
          style: Theme.of(context).textTheme.titleLarge)])))));
}

class ReportsPage extends StatefulWidget {
  final Api api;
  final bool canProjects;
  const ReportsPage({super.key, required this.api, required this.canProjects});
  @override State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int kind = 0, page = 0, total = 0, generation = 0;
  String fromDate = _first(_todayMonth()), toDate = _last(_todayMonth());
  String? equipmentId, projectId, entryType, movementType, selectedEquipmentName, selectedProjectName;
  bool generalExpense = false, loading = true;
  String? error;
  Map<String, dynamic>? summary;
  List<Map<String, dynamic>> items = [];
  @override void initState() { super.initState(); load(); }
  @override void didUpdateWidget(ReportsPage old) {
    super.didUpdateWidget(old);
    if (old.api.workspace != widget.api.workspace) { summary = null; items = []; load(); }
  }
  String get path {
    final params = <String,String>{'page':'$page'};
    if (kind != 2) { params['fromDate'] = fromDate; params['toDate'] = toDate; }
    if (equipmentId != null) params['equipmentId'] = equipmentId!;
    if (projectId != null) params['projectId'] = projectId!;
    if (entryType != null) params['entryType'] = entryType!;
    if (kind == 1 && movementType != null) params['movementType'] = movementType!;
    if (kind == 0 && generalExpense) params['generalExpense'] = 'true';
    return '/reports/${['recorded','movements','outstanding'][kind]}?${Uri(queryParameters: params).query}';
  }
  Future<void> load() async {
    final request = ++generation, workspace = widget.api.workspace;
    setState(() { loading = true; error = null; summary = null; items = []; });
    try {
      final result = await widget.api.json('GET', widget.api.scoped(path)) as Map;
      if (mounted && request == generation && workspace == widget.api.workspace) { setState(() {
        summary = Map<String,dynamic>.from(result['summary'] as Map);
        items = m6Rows(result['items']); total = (result['total'] as num).toInt();
      }); }
    } catch (e) {
      if (mounted && request == generation && workspace == widget.api.workspace) setState(() => error = localizedError(context,e));
    } finally {
      if (mounted && request == generation && workspace == widget.api.workspace) setState(() => loading = false);
    }
  }
  void change(VoidCallback update) { setState(() { update(); page = 0; }); load(); }
  Future<void> date(bool start) async {
    final current = DateTime.parse(start ? fromDate : toDate);
    final chosen = await showDatePicker(context: context, initialDate: current,
      firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (chosen == null || !mounted) return;
    final value = chosen.toIso8601String().substring(0,10);
    change(() { if (start) { fromDate = value; if (fromDate.compareTo(toDate)>0) toDate=value; }
      else { toDate=value; if (toDate.compareTo(fromDate)<0) fromDate=value; } });
  }
  void clear() => change(() { equipmentId=null;selectedEquipmentName=null;projectId=null;selectedProjectName=null;entryType=null;movementType=null;generalExpense=false; });
  Widget metric(String title, Object? value, {VoidCallback? onTap}) => SizedBox(width: 230, child: Card(child: InkWell(onTap:onTap,child: Padding(
    padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(title), const SizedBox(height: 6), Text(localizedMoney(context,value),
        style: Theme.of(context).textTheme.titleMedium)])))));
  @override Widget build(BuildContext context) {
    final loc=l10n(context);
    return Scaffold(appBar: AppBar(title: Text(loc.m7Reports)),body: ListView(
      padding: const EdgeInsets.all(16), children: [
        Wrap(spacing:8,runSpacing:6,children:[
          ChoiceChip(label:Text(loc.m7Recorded),selected:kind==0,onSelected:(_)=>change(()=>kind=0)),
          ChoiceChip(label:Text(loc.m7Movements),selected:kind==1,onSelected:(_)=>change(()=>kind=1)),
          ChoiceChip(label:Text(loc.m7Outstanding),selected:kind==2,onSelected:(_)=>change(()=>kind=2)),
        ]),
        const SizedBox(height: 12),
        Text(kind==0?loc.m7EntryDateBasis:kind==1?loc.m7MovementDateBasis:loc.m7CurrentBasis),
        if (kind!=2) Wrap(spacing:8,children:[
          OutlinedButton(key:const Key('reportFromDate'),onPressed:()=>date(true),child:Text('${loc.m7FromDate}: ${localizedDate(context, fromDate)}')),
          OutlinedButton(key:const Key('reportToDate'),onPressed:()=>date(false),child:Text('${loc.m7ToDate}: ${localizedDate(context, toDate)}')),
        ]),
        Wrap(spacing:8,runSpacing:8,children:[
          OutlinedButton.icon(key:const Key('reportEquipmentFilter'),icon:const Icon(Icons.local_shipping_outlined),
            label:Text(selectedEquipmentName ?? loc.m7FilterEquipment),onPressed:() async {
              final selected=await showDialog<Map<String,dynamic>>(context:context,
                builder:(_)=>HistoryEquipmentPicker(api:widget.api));
              if(selected!=null && mounted) { change(() {equipmentId=selected['id'] as String?;
                selectedEquipmentName=selected['name'] as String?;generalExpense=false;}); }
            }),
          if(widget.canProjects) OutlinedButton.icon(key:const Key('reportProjectFilter'),icon:const Icon(Icons.folder_outlined),
            label:Text(selectedProjectName ?? loc.m7FilterProject),onPressed:() async {
              final selected=await showDialog<Map<String,dynamic>>(context:context,
                builder:(_)=>_ProjectFilterPicker(api:widget.api));
              if(selected!=null && mounted) { change(() {projectId=selected['id'] as String?;
                selectedProjectName=selected['name'] as String?;}); }
            }),
          SizedBox(width:180,child:DropdownButtonFormField<String>(key:ValueKey('entryType:$entryType'),initialValue:entryType,
            decoration:InputDecoration(labelText:loc.uiEntryType),items:[
              DropdownMenuItem(value:'',child:Text(loc.uiAll)),
              DropdownMenuItem(value:'EXPENSE',child:Text(loc.expense)),
              DropdownMenuItem(value:'INCOME',child:Text(loc.income)),
            ],onChanged:(value)=>change(()=>entryType=value==''?null:value))),
          if(equipmentId!=null||projectId!=null||entryType!=null||movementType!=null||generalExpense)
            TextButton(onPressed:clear,child:Text(loc.m7ClearFilters)),
        ]),
        const SizedBox(height: 12),
        if(loading) const Center(child:CircularProgressIndicator())
        else if(error!=null) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
          Text(error!),TextButton(onPressed:load,child:Text(loc.retry))])))
        else if(summary!=null) ...[
          if(kind==0) ...[
            Wrap(spacing:8,children:[metric(loc.income,summary!['recordedIncome'],onTap:()=>change(()=>entryType='INCOME')),
              metric(loc.expense,summary!['recordedExpenses'],onTap:()=>change(()=>entryType='EXPENSE')),metric(loc.m7RecordedDifference,summary!['recordedDifference'],onTap:()=>change(()=>entryType=null))]),
            Text(loc.m7CurrentClassification,style:Theme.of(context).textTheme.bodySmall),
            for(final group in m6Rows(summary!['groups'])) ListTile(
              title:Text(group['generalExpense']==true?loc.m7GeneralExpenses:'${group['equipmentName']}'),
              subtitle:Text(group['entryType']=='INCOME'?loc.income:loc.expense),
              trailing:Text(localizedMoney(context,group['amount'])),onTap:()=>change(() {
                equipmentId=group['equipmentId'] as String?; selectedEquipmentName=group['equipmentName'] as String?; generalExpense=group['generalExpense']==true;
                entryType=group['entryType'] as String?;
              })),
          ] else if(kind==1) Wrap(spacing:8,children:[metric(loc.m7Collected,summary!['collected'],onTap:()=>change(() {entryType='INCOME';movementType='SETTLEMENT';})),
            metric(loc.m7IncomeRefunds,summary!['incomeRefunds'],onTap:()=>change(() {entryType='INCOME';movementType='REFUND';})),
            metric(loc.m7NetCollected,summary!['netCollected'],onTap:()=>change(() {entryType='INCOME';movementType=null;})),
            metric(loc.m7Paid,summary!['paid'],onTap:()=>change(() {entryType='EXPENSE';movementType='SETTLEMENT';})),
            metric(loc.m7ExpenseRefunds,summary!['expenseRefunds'],onTap:()=>change(() {entryType='EXPENSE';movementType='REFUND';})),
            metric(loc.m7NetPaid,summary!['netPaid'],onTap:()=>change(() {entryType='EXPENSE';movementType=null;}))])
          else Wrap(spacing:8,children:[metric(loc.m7Receivable,summary!['receivable'],onTap:()=>change(()=>entryType='INCOME')),metric(loc.m7Payable,summary!['payable'],onTap:()=>change(()=>entryType='EXPENSE'))]),
          if(items.isEmpty) Padding(padding:const EdgeInsets.all(24),child:Text(
            equipmentId!=null||projectId!=null||entryType!=null||generalExpense?loc.m7NoMatches:
              kind==2?loc.m7NoCurrentOutstanding:loc.m7NoPeriodRecords)),
          for(final item in items) Card(child:ListTile(
            title:Text('${item['entryType']=='INCOME'?loc.income:loc.expense} • ${localizedMoney(context,item[kind==2?'remaining':'amount'])}'),
            subtitle:Text(kind==1?'${localizedDate(context,item['movementDate'] as String?)} • ${item['movementType']=='REFUND'?loc.m7Refund:loc.m7Settlement}${item['amount']!=item['movementTotal']?' • ${loc.m7EquipmentShare}: ${localizedMoney(context,item['amount'])} • ${loc.m7OriginalMovement}: ${localizedMoney(context,item['movementTotal'])}':''}':
              '${localizedDate(context,item['operationDate'] as String?)}${kind==2?' • ${item['dueDate']==null?loc.m7NoDueDate:localizedDate(context,item['dueDate'] as String?)}':''}${item['amount']!=null && item['amount']!=item['entryTotal']?' • ${loc.m7EquipmentShare}: ${localizedMoney(context,item['amount'])} • ${loc.m7OriginalTotal}: ${localizedMoney(context,item['entryTotal'])}':''}'),
            onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>EntryDetail(api:widget.api,id:item['entryId'] as String))),
          )),
          if(total>30) Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            TextButton(onPressed:page>0?(){setState(()=>page--);load();}:null,child:Text(loc.previous)),
            Text('${page+1} / ${(total+29)~/30}'),
            TextButton(onPressed:(page+1)*30<total?(){setState(()=>page++);load();}:null,child:Text(loc.next)),
          ]),
        ],
      ]));
  }
}

class _ProjectFilterPicker extends StatefulWidget {
  final Api api;
  const _ProjectFilterPicker({required this.api});
  @override State<_ProjectFilterPicker> createState()=>_ProjectFilterPickerState();
}
class _ProjectFilterPickerState extends State<_ProjectFilterPicker> {
  final search=TextEditingController();
  List<Map<String,dynamic>> items=[];
  bool archived=false,loading=true;
  String? error;
  int generation=0;
  @override void initState(){super.initState();load();}
  @override void dispose(){search.dispose();super.dispose();}
  Future<void> load() async {
    final request=++generation,workspace=widget.api.workspace;
    setState(() {loading=true;error=null;});
    try {
      final query=Uri(queryParameters:{'archived':'$archived','search':search.text.trim()}).query;
      final response=await widget.api.json('GET',widget.api.scoped('/projects?$query'));
      if(mounted&&request==generation&&workspace==widget.api.workspace) setState(()=>items=m6Rows(response));
    } catch(e){if(mounted&&request==generation&&workspace==widget.api.workspace) setState(()=>error=localizedError(context,e));}
    finally{if(mounted&&request==generation&&workspace==widget.api.workspace) setState(()=>loading=false);}
  }
  @override Widget build(BuildContext context)=>AlertDialog(
    title:Text(l10n(context).m7FilterProject),
    content:SizedBox(width:520,height:420,child:Column(children:[
      TextField(controller:search,decoration:InputDecoration(labelText:l10n(context).uiSearch),onSubmitted:(_)=>load()),
      SwitchListTile(title:Text(l10n(context).archived),value:archived,onChanged:(value){setState(()=>archived=value);load();}),
      Expanded(child:loading?const Center(child:CircularProgressIndicator()):error!=null?
        TextButton(onPressed:load,child:Text(error!)):
        ListView(children:[for(final item in items) ListTile(title:Text('${item['name']}'),
          onTap:()=>Navigator.pop(context,item))])),
    ])),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(l10n(context).uiClose))],
  );
}

String _localizedMonth(BuildContext context,String month) {
  final parts=month.split('-').map(int.parse).toList();
  return DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(DateTime(parts[0],parts[1]));
}
class _MonthPicker extends StatefulWidget {
  final String initial;
  const _MonthPicker({required this.initial});
  @override State<_MonthPicker> createState()=>_MonthPickerState();
}
class _MonthPickerState extends State<_MonthPicker> {
  late int year=int.parse(widget.initial.substring(0,4));
  @override Widget build(BuildContext context) {
    final language=Localizations.localeOf(context).languageCode;
    return AlertDialog(title:Text(l10n(context).m7ChooseMonth),content:SizedBox(width:360,height:330,
      child:Column(children:[
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          IconButton(onPressed:year>1900?()=>setState(()=>year--):null,icon:const Icon(Icons.chevron_left)),
          Text('$year',style:Theme.of(context).textTheme.titleLarge),
          IconButton(onPressed:year<2100?()=>setState(()=>year++):null,icon:const Icon(Icons.chevron_right)),
        ]),
        Expanded(child:GridView.count(crossAxisCount:3,childAspectRatio:1.7,
          children:[for(var m=1;m<=12;m++) TextButton(
            onPressed:()=>Navigator.pop(context,'$year-${m.toString().padLeft(2,'0')}'),
            child:Text(DateFormat.MMMM(language).format(DateTime(year,m))))])),
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(l10n(context).uiClose))]);
  }
}
