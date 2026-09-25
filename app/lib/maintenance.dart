import 'package:flutter/material.dart';

import 'api.dart';
import 'documents.dart';
import 'localization.dart';
import 'main.dart' show ExpenseForm, EntryDetail;

const issueTypes = [
  'MECHANICAL',
  'ELECTRICAL',
  'TIRES',
  'ACCIDENT_DAMAGE',
  'OTHER',
];
const maintenanceTypes = ['REPAIR', 'PERIODIC_SERVICE', 'INSPECTION', 'OTHER'];

String issueTypeName(BuildContext context, String? type) => switch (type) {
  'MECHANICAL' => l10n(context).m4Mechanical,
  'ELECTRICAL' => l10n(context).m4Electrical,
  'TIRES' => l10n(context).m4Tires,
  'ACCIDENT_DAMAGE' => l10n(context).m4Accident,
  'OTHER' => l10n(context).other,
  _ => l10n(context).m4Unclassified,
};
String maintenanceTypeName(BuildContext context, String? type) =>
    switch (type) {
      'REPAIR' => l10n(context).m4Repair,
      'PERIODIC_SERVICE' => l10n(context).m4Periodic,
      'INSPECTION' => l10n(context).m4Inspection,
      'OTHER' => l10n(context).other,
      _ => l10n(context).m4Unclassified,
    };
String issueStatusName(BuildContext context, String? status) =>
    switch (status) {
      'OPEN' => l10n(context).m4Open,
      'IN_PROGRESS' => l10n(context).m4InProgress,
      _ => l10n(context).m4Closed,
    };
Color issueStatusColor(String? status, bool stopped) => status == 'CLOSED'
    ? Colors.green
    : stopped && status == 'OPEN'
    ? Colors.red
    : status == 'IN_PROGRESS'
    ? Colors.orange
    : Colors.blue;

Future<T?> m4Push<T>(BuildContext context, Widget page) =>
    Navigator.push<T>(context, MaterialPageRoute(builder: (_) => page));

EdgeInsets m4ContentPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final inset = width > 800 ? (width - 760) / 2 : 20.0;
  return EdgeInsets.fromLTRB(inset, 20, inset, 20);
}

class M4Picker extends StatefulWidget {
  final Api api;
  final bool issues;
  final String? equipmentId;
  const M4Picker({
    super.key,
    required this.api,
    required this.issues,
    this.equipmentId,
  });
  @override
  State<M4Picker> createState() => _M4PickerState();
}

class _M4PickerState extends State<M4Picker> {
  final search = TextEditingController();
  int page = 0, total = 0;
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final query = {
      'page': '$page',
      'search': search.text.trim(),
      if (widget.issues) 'equipmentId': widget.equipmentId!,
    };
    try {
      final result = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/${widget.issues ? 'issues' : 'equipment'}?${Uri(queryParameters: query).query}',
        ),
      ) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          items = (result['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .where((e) => widget.issues || e['archivedAt'] == null)
              .toList();
          total = (result['total'] as num).toInt();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.issues
          ? l10n(context).m4LinkedIssue
          : l10n(context).m4SelectEquipment,
    ),
    content: SizedBox(
      width: 520,
      height: 420,
      child: Column(
        children: [
          TextField(
            controller: search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: widget.issues
                  ? l10n(context).m4IssueSearch
                  : l10n(context).searchEquipment,
            ),
            onSubmitted: (_) {
              page = 0;
              load();
            },
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null) TextButton(onPressed: load, child: Text(error!)),
          Expanded(
            child: ListView(
              children: [
                if (!loading && items.isEmpty) Text(l10n(context).m4NoResults),
                for (final item in items)
                  ListTile(
                    title: Text(
                      widget.issues
                          ? '${item['reference']} • ${item['description']}'
                          : item['name'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.pop(context, item),
                  ),
              ],
            ),
          ),
          if (total > 30)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: page == 0
                      ? null
                      : () {
                          page--;
                          load();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('${page + 1} / ${(total + 29) ~/ 30}'),
                IconButton(
                  onPressed: (page + 1) * 30 >= total
                      ? null
                      : () {
                          page++;
                          load();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n(context).back),
      ),
    ],
  );
}

class EquipmentMaintenanceCard extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  const EquipmentMaintenanceCard({
    super.key,
    required this.api,
    required this.equipment,
  });
  @override
  State<EquipmentMaintenanceCard> createState() =>
      _EquipmentMaintenanceCardState();
}

class _EquipmentMaintenanceCardState extends State<EquipmentMaintenanceCard> {
  Map<String, dynamic>? issue, maintenance;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final id = widget.equipment['id'];
      final results = await Future.wait([
        if (widget.api.can('ISSUE_VIEW'))
          widget.api.json(
            'GET',
            widget.api.scoped('/issues?equipmentId=$id&page=0'),
          )
        else
          Future.value({'items': <Object>[]}),
        if (widget.api.can('MAINTENANCE_VIEW'))
          widget.api.json(
            'GET',
            widget.api.scoped('/maintenance?equipmentId=$id&page=0'),
          )
        else
          Future.value({'items': <Object>[]}),
      ]);
      if (mounted) {
        setState(() {
          final issues = (results[0] as Map)['items'] as List;
          final records = (results[1] as Map)['items'] as List;
          issue = issues.isEmpty
              ? null
              : Map<String, dynamic>.from(issues.first as Map);
          maintenance = records.isEmpty
              ? null
              : Map<String, dynamic>.from(records.first as Map);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n(context).m4Hub,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            TextButton(onPressed: load, child: Text(l10n(context).retry)),
          if (!loading && error == null) ...[
            if (issue == null && maintenance == null)
              Text(l10n(context).m4NoIssues),
            if (issue != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  issue!['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  issueStatusName(context, issue!['status'] as String?),
                ),
                trailing:
                    issue!['equipmentStopped'] == true &&
                        issue!['status'] != 'CLOSED'
                    ? Icon(
                        Icons.error_outline,
                        color: issue!['status'] == 'OPEN'
                            ? Colors.red
                            : Colors.orange,
                      )
                    : null,
                onTap: () async {
                  await m4Push(
                    context,
                    IssueDetailPage(
                      api: widget.api,
                      id: issue!['id'] as String,
                    ),
                  );
                  if (mounted) load();
                },
              ),
            if (maintenance != null)
              Text(
                '${l10n(context).m4Maintenance}: ${localizedDate(context, maintenance!['maintenanceDate'] as String?)}',
              ),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () async {
                    await m4Push(
                      context,
                      MaintenanceHub(
                        api: widget.api,
                        equipment: widget.equipment,
                      ),
                    );
                    if (mounted) load();
                  },
                  child: Text(l10n(context).m4ViewHistory),
                ),
                if (widget.api.can('ISSUE_MANAGE') &&
                    widget.equipment['archivedAt'] == null)
                  TextButton(
                    onPressed: () async {
                      await m4Push(
                        context,
                        IssueFormPage(
                          api: widget.api,
                          equipment: widget.equipment,
                        ),
                      );
                      if (mounted) load();
                    },
                    child: Text(l10n(context).m4NewIssue),
                  ),
                if (widget.api.can('MAINTENANCE_MANAGE') &&
                    widget.equipment['archivedAt'] == null)
                  TextButton(
                    onPressed: () async {
                      await m4Push(
                        context,
                        MaintenanceFormPage(
                          api: widget.api,
                          equipment: widget.equipment,
                        ),
                      );
                      if (mounted) load();
                    },
                    child: Text(l10n(context).m4AddMaintenance),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

class MaintenanceHub extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? equipment;
  final int initialTab;
  const MaintenanceHub({
    super.key,
    required this.api,
    this.equipment,
    this.initialTab = 0,
  });
  @override
  State<MaintenanceHub> createState() => _MaintenanceHubState();
}

class _MaintenanceHubState extends State<MaintenanceHub> {
  late int tab = widget.initialTab;
  int page = 0, total = 0;
  String search = '', status = '', type = '';
  String? fromDate, toDate;
  bool stopped = false, cancelled = false, loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedEquipment;
  @override
  void initState() {
    super.initState();
    if (tab == 0 &&
        !widget.api.can('ISSUE_VIEW') &&
        widget.api.can('MAINTENANCE_VIEW')) {
      tab = 1;
    }
    selectedEquipment = widget.equipment;
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final query = <String, String>{
      'page': '$page',
      if (selectedEquipment != null)
        'equipmentId': '${selectedEquipment!['id']}',
      if (search.isNotEmpty) 'search': search,
      if (tab == 0 && status.isNotEmpty) 'status': status,
      if (tab == 0 && stopped) 'equipmentStopped': 'true',
      if (tab == 1 && type.isNotEmpty) 'type': type,
      if (tab == 1 && cancelled) 'cancelled': 'true',
      'fromDate': ?fromDate,
      'toDate': ?toDate,
    };
    try {
      final data = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/${tab == 0 ? 'issues' : 'maintenance'}?${Uri(queryParameters: query).query}',
        ),
      ) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          items = (data['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          total = (data['total'] as num).toInt();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> chooseEquipment() async {
    final chosen = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => M4Picker(api: widget.api, issues: false),
    );
    if (chosen != null && mounted) {
      setState(() => selectedEquipment = chosen);
      load();
    }
  }

  Future<void> add() async {
    if (selectedEquipment == null) await chooseEquipment();
    if (!mounted || selectedEquipment == null) return;
    await m4Push(
      context,
      tab == 0
          ? IssueFormPage(api: widget.api, equipment: selectedEquipment!)
          : MaintenanceFormPage(api: widget.api, equipment: selectedEquipment!),
    );
    if (mounted) load();
  }

  Future<void> pickRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: fromDate == null || toDate == null
          ? null
          : DateTimeRange(
              start: DateTime.parse(fromDate!),
              end: DateTime.parse(toDate!),
            ),
    );
    if (selected != null) {
      fromDate = selected.start.toIso8601String().split('T').first;
      toDate = selected.end.toIso8601String().split('T').first;
      page = 0;
      load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).m4Hub),
      actions: [
        IconButton(
          onPressed: load,
          tooltip: l10n(context).refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SegmentedButton<int>(
                segments: [
                  if (widget.api.can('ISSUE_VIEW'))
                    ButtonSegment(
                      value: 0,
                      label: Text(l10n(context).m4Issues),
                      icon: const Icon(Icons.report_outlined),
                    ),
                  if (widget.api.can('MAINTENANCE_VIEW'))
                    ButtonSegment(
                      value: 1,
                      label: Text(l10n(context).m4Maintenance),
                      icon: const Icon(Icons.build_outlined),
                    ),
                ],
                selected: {tab},
                onSelectionChanged: (selection) {
                  setState(() {
                    tab = selection.first;
                    page = 0;
                  });
                  load();
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.equipment == null)
                        InputChip(
                          label: Text(
                            selectedEquipment?['name'] as String? ??
                                l10n(context).m4AllEquipment,
                          ),
                          onPressed: chooseEquipment,
                          onDeleted: selectedEquipment == null
                              ? null
                              : () {
                                  setState(() => selectedEquipment = null);
                                  load();
                                },
                        ),
                      if (widget.api.can(
                        tab == 0 ? 'ISSUE_MANAGE' : 'MAINTENANCE_MANAGE',
                      ))
                        FilledButton.icon(
                          onPressed: add,
                          icon: const Icon(Icons.add),
                          label: Text(
                            tab == 0
                                ? l10n(context).m4NewIssue
                                : l10n(context).m4AddMaintenance,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: Key(tab == 0 ? 'issueSearch' : 'maintenanceSearch'),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: tab == 0
                          ? l10n(context).m4IssueSearch
                          : l10n(context).m4MaintenanceSearch,
                    ),
                    onSubmitted: (value) {
                      search = value.trim();
                      page = 0;
                      load();
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: pickRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          fromDate == null
                              ? l10n(context).m4DateRange
                              : '${localizedDate(context, fromDate)} – ${localizedDate(context, toDate)}',
                        ),
                      ),
                      if (fromDate != null)
                        TextButton(
                          onPressed: () {
                            fromDate = null;
                            toDate = null;
                            page = 0;
                            load();
                          },
                          child: Text(l10n(context).m4ClearDateRange),
                        ),
                    ],
                  ),
                  if (tab == 0)
                    Wrap(
                      spacing: 12,
                      children: [
                        DropdownButton<String>(
                          value: status,
                          items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text(l10n(context).m4AllStatuses),
                            ),
                            for (final value in [
                              'OPEN',
                              'IN_PROGRESS',
                              'CLOSED',
                            ])
                              DropdownMenuItem(
                                value: value,
                                child: Text(issueStatusName(context, value)),
                              ),
                          ],
                          onChanged: (value) {
                            status = value ?? '';
                            page = 0;
                            load();
                          },
                        ),
                        FilterChip(
                          label: Text(l10n(context).m4OnlyStopped),
                          selected: stopped,
                          onSelected: (value) {
                            stopped = value;
                            page = 0;
                            load();
                          },
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 12,
                      children: [
                        DropdownButton<String>(
                          value: type,
                          items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text(l10n(context).m4AllTypes),
                            ),
                            for (final value in maintenanceTypes)
                              DropdownMenuItem(
                                value: value,
                                child: Text(
                                  maintenanceTypeName(context, value),
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            type = value ?? '';
                            page = 0;
                            load();
                          },
                        ),
                        FilterChip(
                          label: Text(l10n(context).m4ShowCancelled),
                          selected: cancelled,
                          onSelected: (value) {
                            cancelled = value;
                            page = 0;
                            load();
                          },
                        ),
                      ],
                    ),
                  if (loading) const LinearProgressIndicator(),
                  if (error != null)
                    TextButton(onPressed: load, child: Text(error!)),
                  if (!loading && error == null) ...[
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          search.isNotEmpty
                              ? l10n(context).m4NoResults
                              : tab == 0
                              ? selectedEquipment == null
                                    ? l10n(context).m4NoIssuesGlobal
                                    : l10n(context).m4NoIssues
                              : selectedEquipment == null
                              ? l10n(context).m4NoMaintenanceGlobal
                              : l10n(context).m4NoMaintenance,
                        ),
                      ),
                    for (final item in items)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            tab == 0
                                ? Icons.report_outlined
                                : Icons.build_outlined,
                            color: tab == 0
                                ? issueStatusColor(
                                    item['status'] as String?,
                                    item['equipmentStopped'] == true,
                                  )
                                : null,
                          ),
                          title: Text(
                            item['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item['equipmentName']} • ${tab == 0 ? issueStatusName(context, item['status'] as String?) : localizedDate(context, item['maintenanceDate'] as String?)}',
                          ),
                          trailing:
                              tab == 0 &&
                                  item['equipmentStopped'] == true &&
                                  item['status'] != 'CLOSED'
                              ? Text(
                                  l10n(context).m4StoppedBadge,
                                  style: const TextStyle(color: Colors.red),
                                )
                              : null,
                          onTap: () async {
                            await m4Push(
                              context,
                              tab == 0
                                  ? IssueDetailPage(
                                      api: widget.api,
                                      id: item['id'] as String,
                                    )
                                  : MaintenanceDetailPage(
                                      api: widget.api,
                                      id: item['id'] as String,
                                    ),
                            );
                            if (mounted) load();
                          },
                        ),
                      ),
                    if (total > 30)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: page == 0
                                ? null
                                : () {
                                    page--;
                                    load();
                                  },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text('${page + 1} / ${(total + 29) ~/ 30}'),
                          IconButton(
                            onPressed: (page + 1) * 30 >= total
                                ? null
                                : () {
                                    page++;
                                    load();
                                  },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class IssueFormPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final Map<String, dynamic>? issue;
  const IssueFormPage({
    super.key,
    required this.api,
    required this.equipment,
    this.issue,
  });
  @override
  State<IssueFormPage> createState() => _IssueFormPageState();
}

class _IssueFormPageState extends State<IssueFormPage> {
  final form = GlobalKey<FormState>();
  final description = TextEditingController();
  String? type, error;
  bool stopped = false, busy = false;
  String key = requestKey();
  @override
  void initState() {
    super.initState();
    description.text = widget.issue?['description'] as String? ?? '';
    type = widget.issue?['type'] as String?;
    stopped = widget.issue?['equipmentStopped'] == true;
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        widget.issue == null ? 'POST' : 'PUT',
        widget.api.scoped(
          widget.issue == null
              ? '/equipment/${widget.equipment['id']}/issues'
              : '/issues/${widget.issue!['id']}',
        ),
        key: widget.issue == null ? key : null,
        body: {
          'description': description.text.trim(),
          'type': type,
          'equipmentStopped': stopped,
        },
      );
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.issue == null
            ? l10n(context).m4NewIssue
            : l10n(context).m4EditIssue,
      ),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: m4ContentPadding(context),
        children: [
          Text(
            widget.equipment['name'] as String,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('m4IssueDescription'),
            controller: description,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: l10n(context).m4Problem,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n(context).m4Required
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: InputDecoration(labelText: l10n(context).m4IssueType),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n(context).m4Unclassified),
              ),
              for (final value in issueTypes)
                DropdownMenuItem(
                  value: value,
                  child: Text(issueTypeName(context, value)),
                ),
            ],
            onChanged: (value) => setState(() => type = value),
          ),
          SwitchListTile(
            key: const Key('m4Stopped'),
            value: stopped,
            onChanged: (value) => setState(() => stopped = value),
            title: Text(l10n(context).m4Stopped),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('m4SaveIssue'),
            onPressed: busy ? null : save,
            child: Text(
              widget.issue == null
                  ? l10n(context).m4CreateIssue
                  : l10n(context).save,
            ),
          ),
          if (busy) const LinearProgressIndicator(),
        ],
      ),
    ),
  );
}

class MaintenanceFormPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final Map<String, dynamic>? maintenance;
  final String? issueId;
  const MaintenanceFormPage({
    super.key,
    required this.api,
    required this.equipment,
    this.maintenance,
    this.issueId,
  });
  @override
  State<MaintenanceFormPage> createState() => _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends State<MaintenanceFormPage> {
  final form = GlobalKey<FormState>();
  final description = TextEditingController(),
      workshop = TextEditingController();
  String? type, error, issueId;
  Map<String, dynamic>? selectedIssue;
  late String date;
  bool busy = false;
  String key = requestKey();
  @override
  void initState() {
    super.initState();
    description.text = widget.maintenance?['description'] as String? ?? '';
    workshop.text = widget.maintenance?['workshop'] as String? ?? '';
    date = widget.maintenance?['maintenanceDate'] as String? ?? todayRiyadh();
    type = widget.maintenance?['type'] as String?;
    issueId = widget.issueId ?? widget.maintenance?['issueId'] as String?;
    if (issueId != null) loadSelectedIssue();
  }

  Future<void> loadSelectedIssue() async {
    try {
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/issues/$issueId'),
      ) as Map<String, dynamic>;
      if (mounted) setState(() => selectedIssue = result);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  Future<void> chooseIssue() async {
    final chosen = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => M4Picker(
        api: widget.api,
        issues: true,
        equipmentId: widget.equipment['id'] as String,
      ),
    );
    if (chosen != null && mounted) {
      setState(() {
        selectedIssue = chosen;
        issueId = chosen['id'] as String;
      });
    }
  }

  @override
  void dispose() {
    description.dispose();
    workshop.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (chosen != null) {
      setState(() => date = chosen.toIso8601String().split('T').first);
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        widget.maintenance == null ? 'POST' : 'PUT',
        widget.api.scoped(
          widget.maintenance == null
              ? '/equipment/${widget.equipment['id']}/maintenance'
              : '/maintenance/${widget.maintenance!['id']}',
        ),
        key: widget.maintenance == null ? key : null,
        body: {
          'description': description.text.trim(),
          'maintenanceDate': date,
          'type': type,
          'workshop': workshop.text.trim().isEmpty
              ? null
              : workshop.text.trim(),
          'issueId': issueId,
        },
      );
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.maintenance == null
            ? l10n(context).m4AddMaintenance
            : l10n(context).m4EditMaintenance,
      ),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: m4ContentPadding(context),
        children: [
          Text(
            widget.equipment['name'] as String,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('m4MaintenanceDescription'),
            controller: description,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: l10n(context).m4Description,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n(context).m4Required
                : null,
          ),
          ListTile(
            title: Text(l10n(context).m4Date),
            subtitle: Text(localizedDate(context, date)),
            trailing: const Icon(Icons.calendar_today),
            onTap: pickDate,
          ),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: InputDecoration(
              labelText: l10n(context).m4MaintenanceType,
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n(context).m4Unclassified),
              ),
              for (final value in maintenanceTypes)
                DropdownMenuItem(
                  value: value,
                  child: Text(maintenanceTypeName(context, value)),
                ),
            ],
            onChanged: (value) => setState(() => type = value),
          ),
          TextFormField(
            controller: workshop,
            maxLength: 200,
            decoration: InputDecoration(labelText: l10n(context).m4Workshop),
          ),
          ListTile(
            title: Text(l10n(context).m4LinkedIssue),
            subtitle: Text(
              selectedIssue == null
                  ? l10n(context).m4NoLinkedIssue
                  : '${selectedIssue!['reference']} • ${selectedIssue!['description']}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n(context).m4SelectIssue,
                  onPressed: chooseIssue,
                  icon: const Icon(Icons.search),
                ),
                if (issueId != null)
                  IconButton(
                    tooltip: l10n(context).m4ClearIssue,
                    onPressed: () => setState(() {
                      issueId = null;
                      selectedIssue = null;
                    }),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('m4SaveMaintenance'),
            onPressed: busy ? null : save,
            child: Text(l10n(context).m4SaveMaintenance),
          ),
          if (busy) const LinearProgressIndicator(),
        ],
      ),
    ),
  );
}

class OperationalAttachments extends StatefulWidget {
  final Api api;
  final String id;
  final bool issue, readOnly;
  final Future<DocumentUpload?> Function()? pickFile;
  const OperationalAttachments({
    super.key,
    required this.api,
    required this.id,
    required this.issue,
    required this.readOnly,
    this.pickFile,
  });
  @override
  State<OperationalAttachments> createState() => _OperationalAttachmentsState();
}

class _OperationalAttachmentsState extends State<OperationalAttachments> {
  List<Map<String, dynamic>> files = [];
  String? error;
  bool loading = true, busy = false;
  DocumentUpload? pending;
  String get path =>
      '/${widget.issue ? 'issues' : 'maintenance'}/${widget.id}/attachments';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final list =
          await widget.api.json('GET', widget.api.scoped(path)) as List;
      if (mounted) {
        setState(
          () => files = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add() async {
    try {
      final file = await (widget.pickFile != null
          ? widget.pickFile!()
          : chooseDocumentFile(context));
      if (file == null) return;
      if (widget.issue && file.mediaType == 'application/pdf') {
        throw const ApiError(400, 'UNSUPPORTED_FILE', '');
      }
      pending = file;
      await upload();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  Future<void> upload() async {
    final file = pending;
    if (file == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (file.id == null) {
        final result = await widget.api.json(
          'POST',
          widget.api.scoped(path),
          key: file.key,
          body: {
            'filename': file.filename,
            'mediaType': file.mediaType,
            'size': file.bytes.length,
          },
        ) as Map<String, dynamic>;
        file.id = result['id'] as String;
      }
      await widget.api.send(
        'PUT',
        widget.api.scoped('/attachments/${file.id}/content'),
        bytes: file.bytes,
        type: file.mediaType,
      );
      pending = null;
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> remove(String id) async {
    try {
      await widget.api.send('DELETE', widget.api.scoped('$path/$id'));
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l10n(context).attachments,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (loading) const LinearProgressIndicator(),
      if (!loading && files.isEmpty) Text(l10n(context).m4NoAttachments),
      for (final file in files)
        ListTile(
          title: Text(file['filename'] as String),
          subtitle: Text(
            file['state'] == 'READY'
                ? l10n(context).uiReadyToView
                : file['state'] == 'FAILED'
                ? l10n(context).uiUploadFailed
                : l10n(context).uiUploadIncomplete,
          ),
          onTap: file['state'] == 'READY'
              ? () => openDocumentAttachment(context, widget.api, file)
              : null,
          trailing: widget.readOnly
              ? null
              : IconButton(
                  tooltip: l10n(context).m4RemoveAttachment,
                  onPressed: () => remove(file['id'] as String),
                  icon: const Icon(Icons.delete_outline),
                ),
        ),
      if (!widget.readOnly)
        TextButton.icon(
          onPressed: busy ? null : add,
          icon: const Icon(Icons.attach_file),
          label: Text(l10n(context).uiAddAttachment),
        ),
      if (pending != null) ...[
        Text(
          '${pending!.filename} • ${error == null ? l10n(context).uiUploadIncomplete : l10n(context).uiUploadFailed}',
        ),
        TextButton(
          onPressed: busy ? null : upload,
          child: Text(l10n(context).uiRetryFileUpload),
        ),
      ],
      if (error != null)
        Text(
          error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
    ],
  );
}

class IssueDetailPage extends StatefulWidget {
  final Api api;
  final String id;
  const IssueDetailPage({super.key, required this.api, required this.id});
  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  final resolutionController = TextEditingController();
  Map<String, dynamic>? issue;
  bool loading = true, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    resolutionController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/issues/${widget.id}'),
      ) as Map<String, dynamic>;
      if (mounted) setState(() => issue = result);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> transition(String action, {Map<String, dynamic>? body}) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        'POST',
        widget.api.scoped('/issues/${widget.id}/$action'),
        body: body,
      );
      if (mounted) {
        setState(() => issue = Map<String, dynamic>.from(result as Map));
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> close() async {
    resolutionController.clear();
    final result = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n(dialog).m4Close),
        content: TextField(
          key: const Key('m4Resolution'),
          controller: resolutionController,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n(dialog).m4Resolution),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n(dialog).back),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialog, resolutionController.text.trim()),
            child: Text(l10n(dialog).m4Close),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    if (result.isEmpty) {
      setState(() => error = l10n(context).m4ResolutionRequired);
      return;
    }
    await transition('close', body: {'resolution': result});
  }

  Map<String, dynamic> equipment() => {
    'id': issue!['equipmentId'],
    'name': issue!['equipmentName'],
    'archivedAt': issue!['equipmentArchived'] == true ? 'archived' : null,
  };
  @override
  Widget build(BuildContext context) {
    final d = issue;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n(context).m4IssueDetails),
        actions: [
          IconButton(
            onPressed: load,
            tooltip: l10n(context).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && d == null
          ? Center(
              child: TextButton(onPressed: load, child: Text(error!)),
            )
          : d == null
          ? const SizedBox.shrink()
          : ListView(
              padding: m4ContentPadding(context),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d['reference'] as String,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    Chip(
                      label: Text(
                        issueStatusName(context, d['status'] as String?),
                      ),
                      backgroundColor: issueStatusColor(
                        d['status'] as String?,
                        d['equipmentStopped'] == true,
                      ).withValues(alpha: .12),
                    ),
                  ],
                ),
                Text(
                  d['equipmentName'] as String,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (d['equipmentStopped'] == true && d['status'] != 'CLOSED')
                  Card(
                    color: d['status'] == 'OPEN'
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                    child: ListTile(
                      leading: Icon(
                        Icons.error_outline,
                        color: d['status'] == 'OPEN'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      title: Text(l10n(context).m4StoppedBadge),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  d['description'] as String,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(issueTypeName(context, d['type'] as String?)),
                Text(localizedDate(context, d['createdAt'] as String?)),
                if (d['status'] == 'CLOSED' && d['resolution'] != null) ...[
                  const Divider(),
                  Text(
                    l10n(context).m4Resolution,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(d['resolution'] as String),
                ],
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.api.can('ISSUE_MANAGE') && d['status'] == 'OPEN')
                      FilledButton.icon(
                        key: const Key('m4Start'),
                        onPressed: busy ? null : () => transition('start'),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n(context).m4Start),
                      ),
                    if (widget.api.can('ISSUE_MANAGE') &&
                        (d['status'] == 'OPEN' || d['status'] == 'IN_PROGRESS'))
                      FilledButton.icon(
                        key: const Key('m4Close'),
                        onPressed: busy ? null : close,
                        icon: const Icon(Icons.check),
                        label: Text(l10n(context).m4Close),
                      ),
                    if (widget.api.can('ISSUE_MANAGE') &&
                        d['status'] == 'CLOSED')
                      FilledButton.icon(
                        key: const Key('m4Reopen'),
                        onPressed: busy ? null : () => transition('reopen'),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(l10n(context).m4Reopen),
                      ),
                    if (widget.api.can('ISSUE_MANAGE') &&
                        d['status'] != 'CLOSED')
                      OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () async {
                                await m4Push(
                                  context,
                                  IssueFormPage(
                                    api: widget.api,
                                    equipment: equipment(),
                                    issue: d,
                                  ),
                                );
                                if (mounted) load();
                              },
                        icon: const Icon(Icons.edit),
                        label: Text(l10n(context).m4EditIssue),
                      ),
                    if (widget.api.can('MAINTENANCE_MANAGE') &&
                        d['equipmentArchived'] != true)
                      OutlinedButton.icon(
                        onPressed: () async {
                          await m4Push(
                            context,
                            MaintenanceFormPage(
                              api: widget.api,
                              equipment: equipment(),
                              issueId: widget.id,
                            ),
                          );
                          if (mounted) load();
                        },
                        icon: const Icon(Icons.build),
                        label: Text(l10n(context).m4AddMaintenance),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                OperationalAttachments(
                  key: ValueKey('issue-files-${d['status']}'),
                  api: widget.api,
                  id: widget.id,
                  issue: true,
                  readOnly:
                      d['status'] == 'CLOSED' ||
                      !widget.api.can('ISSUE_MANAGE'),
                ),
                const Divider(height: 32),
                Text(
                  l10n(context).m4RelatedMaintenance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final item in (d['maintenance'] as List? ?? []))
                  ListTile(
                    title: Text(item['description'] as String),
                    subtitle: Text(
                      localizedDate(
                        context,
                        item['maintenanceDate'] as String?,
                      ),
                    ),
                    onTap: () async {
                      await m4Push(
                        context,
                        MaintenanceDetailPage(
                          api: widget.api,
                          id: item['id'] as String,
                        ),
                      );
                      if (mounted) load();
                    },
                  ),
                const Divider(height: 32),
                Text(
                  l10n(context).m4IssueHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final closure in (d['closures'] as List? ?? []))
                  ListTile(
                    title: Text(closure['resolution'] as String),
                    subtitle: Text(
                      localizedDate(context, '${closure['closedAt']}'),
                    ),
                  ),
              ],
            ),
    );
  }
}

class MaintenanceDetailPage extends StatefulWidget {
  final Api api;
  final String id;
  const MaintenanceDetailPage({super.key, required this.api, required this.id});
  @override
  State<MaintenanceDetailPage> createState() => _MaintenanceDetailPageState();
}

class _MaintenanceDetailPageState extends State<MaintenanceDetailPage> {
  final cancellationController = TextEditingController();
  Map<String, dynamic>? record;
  bool loading = true, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    cancellationController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/maintenance/${widget.id}'),
      ) as Map<String, dynamic>;
      if (mounted) setState(() => record = result);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Map<String, dynamic> equipment() => {
    'id': record!['equipmentId'],
    'name': record!['equipmentName'],
    'archivedAt': record!['equipmentArchived'] == true ? 'archived' : null,
  };
  Future<void> cancel() async {
    cancellationController.clear();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n(dialog).m4CancelMaintenance),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n(dialog).m4CancelWarning),
            TextField(
              controller: cancellationController,
              decoration: InputDecoration(
                labelText: l10n(dialog).m4CancellationReason,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n(dialog).back),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialog, cancellationController.text.trim()),
            child: Text(l10n(dialog).m4CancelMaintenance),
          ),
        ],
      ),
    );
    if (!mounted || reason == null) return;
    if (reason.isEmpty) {
      setState(() => error = l10n(context).m4Required);
      return;
    }
    setState(() => busy = true);
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/maintenance/${widget.id}/cancellation'),
        body: {'reason': reason},
      );
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> unlink(String id) async {
    try {
      await widget.api.json(
        'DELETE',
        widget.api.scoped('/maintenance/${widget.id}/expenses/$id'),
      );
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  Future<void> link() async {
    await m4Push(
      context,
      EligibleExpensePage(api: widget.api, maintenanceId: widget.id),
    );
    if (mounted) load();
  }

  Future<void> addExpense() async {
    await m4Push(
      context,
      ExpenseForm(
        api: widget.api,
        equipment: equipment(),
        maintenanceId: widget.id,
      ),
    );
    if (mounted) load();
  }

  @override
  Widget build(BuildContext context) {
    final d = record;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n(context).m4MaintenanceDetails),
        actions: [
          IconButton(
            onPressed: load,
            tooltip: l10n(context).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && d == null
          ? Center(
              child: TextButton(onPressed: load, child: Text(error!)),
            )
          : d == null
          ? const SizedBox.shrink()
          : ListView(
              padding: m4ContentPadding(context),
              children: [
                Text(
                  d['description'] as String,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(d['equipmentName'] as String),
                Text(
                  '${l10n(context).m4Date}: ${localizedDate(context, d['maintenanceDate'] as String?)}',
                ),
                Text(
                  '${l10n(context).m4MaintenanceType}: ${maintenanceTypeName(context, d['type'] as String?)}',
                ),
                if (d['workshop'] != null)
                  Text('${l10n(context).m4Workshop}: ${d['workshop']}'),
                if (d['cancelledAt'] != null)
                  Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      title: Text(l10n(context).m4Cancelled),
                      subtitle: Text(d['cancellationReason'] as String? ?? ''),
                    ),
                  ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 12),
                if (d['issueId'] != null)
                  ListTile(
                    leading: const Icon(Icons.report_outlined),
                    title: Text(l10n(context).m4LinkedIssue),
                    onTap: () => m4Push(
                      context,
                      IssueDetailPage(
                        api: widget.api,
                        id: d['issueId'] as String,
                      ),
                    ),
                  ),
                if (d['cancelledAt'] == null &&
                    widget.api.can('MAINTENANCE_MANAGE'))
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () async {
                                await m4Push(
                                  context,
                                  MaintenanceFormPage(
                                    api: widget.api,
                                    equipment: equipment(),
                                    maintenance: d,
                                  ),
                                );
                                if (mounted) load();
                              },
                        icon: const Icon(Icons.edit),
                        label: Text(l10n(context).m4EditMaintenance),
                      ),
                      TextButton.icon(
                        onPressed: busy ? null : cancel,
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(l10n(context).m4CancelMaintenance),
                      ),
                    ],
                  ),
                const Divider(height: 32),
                OperationalAttachments(
                  api: widget.api,
                  id: widget.id,
                  issue: false,
                  readOnly:
                      d['cancelledAt'] != null ||
                      !widget.api.can('MAINTENANCE_MANAGE'),
                ),
                if (d['financialSummary'] != null) const Divider(height: 32),
                if (d['financialSummary'] != null)
                  Text(
                    l10n(context).m4Expenses,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (d['financialSummary'] != null)
                  Builder(
                    builder: (context) {
                      final summary =
                          d['financialSummary'] as Map<String, dynamic>;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n(context).m4LinkedCount}: ${summary['linkedExpenseCount']}',
                              ),
                              Text(
                                '${l10n(context).m4ExpenseTotal}: ${localizedMoney(context, summary['totalActiveExpenseAmount'])}',
                              ),
                              Text(
                                '${l10n(context).m4NetPaid}: ${localizedMoney(context, summary['netPaid'])}',
                              ),
                              Text(
                                '${l10n(context).m4Remaining}: ${localizedMoney(context, summary['remaining'])}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                for (final raw in (d['expenses'] as List? ?? []))
                  Builder(
                    builder: (context) {
                      final expense = Map<String, dynamic>.from(raw as Map);
                      return ListTile(
                        title: Text(expense['note'] as String? ?? ''),
                        subtitle: Text(
                          localizedMoney(context, expense['amount']),
                        ),
                        trailing:
                            d['cancelledAt'] == null &&
                                widget.api.canPostFinance
                            ? IconButton(
                                tooltip: l10n(context).m4UnlinkExpense,
                                onPressed: () =>
                                    unlink(expense['id'] as String),
                                icon: const Icon(Icons.link_off),
                              )
                            : null,
                        onTap: () async {
                          await m4Push(
                            context,
                            EntryDetail(
                              api: widget.api,
                              id: expense['id'] as String,
                            ),
                          );
                          if (mounted) load();
                        },
                      );
                    },
                  ),
                if (d['cancelledAt'] == null && widget.api.canPostFinance)
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: addExpense,
                        icon: const Icon(Icons.add),
                        label: Text(l10n(context).m4AddExpense),
                      ),
                      OutlinedButton.icon(
                        onPressed: link,
                        icon: const Icon(Icons.link),
                        label: Text(l10n(context).m4LinkExpense),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class EligibleExpensePage extends StatefulWidget {
  final Api api;
  final String maintenanceId;
  const EligibleExpensePage({
    super.key,
    required this.api,
    required this.maintenanceId,
  });
  @override
  State<EligibleExpensePage> createState() => _EligibleExpensePageState();
}

class _EligibleExpensePageState extends State<EligibleExpensePage> {
  List<Map<String, dynamic>> items = [];
  String? error;
  bool loading = true;
  int page = 0, total = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/maintenance/${widget.maintenanceId}/eligible-expenses?page=$page',
        ),
      ) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          items = (result['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          total = (result['total'] as num).toInt();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> link(String id) async {
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/maintenance/${widget.maintenanceId}/expenses/$id'),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).m4LinkExpense)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: m4ContentPadding(context),
            children: [
              if (error != null)
                TextButton(onPressed: load, child: Text(error!)),
              if (items.isEmpty) Text(l10n(context).m4NoEligible),
              for (final item in items)
                Card(
                  child: ListTile(
                    title: Text(item['note'] as String? ?? ''),
                    subtitle: Text(localizedMoney(context, item['amount'])),
                    trailing: const Icon(Icons.link),
                    onTap: () => link(item['id'] as String),
                  ),
                ),
              if (total > 30)
                Row(
                  children: [
                    IconButton(
                      onPressed: page == 0
                          ? null
                          : () {
                              page--;
                              load();
                            },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('${page + 1}'),
                    IconButton(
                      onPressed: (page + 1) * 30 >= total
                          ? null
                          : () {
                              page++;
                              load();
                            },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
            ],
          ),
  );
}
