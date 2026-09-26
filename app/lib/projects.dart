import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'file_export.dart';
import 'localization.dart';
import 'main.dart' show ExpenseForm, InlineError, brand;

List<Map<String, dynamic>> m6Rows(Object? value) =>
    (value as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

String? m6Id(Map<String, dynamic> row) => row['id']?.toString();

Future<List<Map<String, dynamic>>> m6AllEquipment(Api api) async {
  final result = <Map<String, dynamic>>[];
  for (var page = 0; ; page++) {
    final response = await api.json('GET', api.scoped('/equipment?page=$page'));
    result.addAll(m6Rows(response['items']));
    if (result.length >= (response['total'] as num).toInt()) return result;
  }
}

class OrganizationsPage extends StatefulWidget {
  final Api api;
  final bool canManage;
  const OrganizationsPage({
    super.key,
    required this.api,
    this.canManage = false,
  });
  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  List<Map<String, dynamic>> items = [];
  bool loading = true, archived = false;
  String? error;
  final search = TextEditingController();
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
    try {
      final rows = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/organizations?archived=$archived&search=${Uri.encodeQueryComponent(search.text)}',
        ),
      );
      if (mounted) setState(() => items = m6Rows(rows));
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> open(Map<String, dynamic>? item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => item == null
            ? OrganizationForm(api: widget.api)
            : OrganizationDetail(
                api: widget.api,
                id: m6Id(item)!,
                canManage: widget.canManage,
              ),
      ),
    );
    if (mounted) load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).m6Organizations),
      actions: [
        IconButton(
          onPressed: load,
          icon: const Icon(Icons.refresh),
          tooltip: l10n(context).refresh,
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
            child: TextButton(onPressed: load, child: Text(error!)),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n(context).m6OrganizationsOptional),
              const SizedBox(height: 16),
              TextField(
                controller: search,
                decoration: InputDecoration(
                  labelText: l10n(context).m6SearchOrganizations,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: load,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => load(),
              ),
              SwitchListTile(
                value: archived,
                title: Text(l10n(context).archived),
                onChanged: (v) {
                  setState(() => archived = v);
                  load();
                },
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(l10n(context).m6NoOrganizations),
                ),
              for (final item in items)
                Card(
                  child: ListTile(
                    key: Key('organization-${item['id']}'),
                    title: Text('${item['name']}'),
                    subtitle: Text(
                      '${l10n(context).equipment}: ${item['equipment_count']} • ${l10n(context).m6ProjectsContracts}: ${item['project_count']}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open(item),
                  ),
                ),
            ],
          ),
    floatingActionButton: widget.canManage
        ? FloatingActionButton.extended(
            key: const Key('addOrganization'),
            onPressed: () => open(null),
            icon: const Icon(Icons.add),
            label: Text(l10n(context).m6AddOrganization),
          )
        : null,
  );
}

class OrganizationForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? item;
  const OrganizationForm({super.key, required this.api, this.item});
  @override
  State<OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends State<OrganizationForm> {
  final name = TextEditingController(),
      identifier = TextEditingController(),
      notes = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      name.text = '${item['name'] ?? ''}';
      identifier.text = '${item['identifier'] ?? ''}';
      notes.text = '${item['notes'] ?? ''}';
    }
  }

  @override
  void dispose() {
    name.dispose();
    identifier.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = l10n(context).m6NameRequired);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        widget.item == null ? 'POST' : 'PUT',
        widget.api.scoped(
          widget.item == null
              ? '/organizations'
              : '/organizations/${widget.item!['id']}',
        ),
        body: {
          'name': name.text.trim(),
          'identifier': identifier.text.trim(),
          'notes': notes.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
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
        widget.item == null
            ? l10n(context).m6AddOrganization
            : l10n(context).edit,
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          key: const Key('organizationName'),
          controller: name,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: '${l10n(context).m6OrganizationName} *',
          ),
        ),
        TextField(
          controller: identifier,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: l10n(context).m6IdentifierOptional,
          ),
        ),
        TextField(
          controller: notes,
          maxLength: 1000,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n(context).uiNoteOptional),
        ),
        InlineError(error),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('saveOrganization'),
          onPressed: busy ? null : save,
          child: Text(l10n(context).save),
        ),
      ],
    ),
  );
}

class OrganizationDetail extends StatefulWidget {
  final Api api;
  final String id;
  final bool canManage;
  const OrganizationDetail({
    super.key,
    required this.api,
    required this.id,
    required this.canManage,
  });
  @override
  State<OrganizationDetail> createState() => _OrganizationDetailState();
}

class _OrganizationDetailState extends State<OrganizationDetail> {
  Map<String, dynamic>? item;
  List<Map<String, dynamic>> equipment = [], projects = [];
  bool loading = true, busy = false;
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
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/organizations/${widget.id}'),
      );
      final equipmentResult = await m6AllEquipment(widget.api);
      final projectResult = await widget.api.json(
        'GET',
        widget.api.scoped('/projects?organizationId=${widget.id}'),
      );
      if (mounted) {
        setState(() {
          item = Map<String, dynamic>.from(result);
          equipment = equipmentResult
              .where((e) => e['organizationId'] == widget.id)
              .toList();
          projects = m6Rows(projectResult);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> transition() async {
    final isArchived = item?['archived_at'] != null;
    if (!isArchived &&
        !await m6Confirm(context, l10n(context).m6ArchiveOrganizationConfirm)) {
      return;
    }
    setState(() => busy = true);
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped(
          '/organizations/${widget.id}/${isArchived ? 'restore' : 'archive'}',
        ),
      );
      await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${item?['name'] ?? l10n(context).m6Organizations}'),
      actions: [
        if (widget.canManage && item != null)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n(context).edit,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrganizationForm(api: widget.api, item: item),
                ),
              );
              load();
            },
          ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null && item == null
        ? Center(
            child: TextButton(onPressed: load, child: Text(error!)),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (item?['identifier'] != null)
                Text(
                  '${l10n(context).m6IdentifierOptional}: ${item!['identifier']}',
                ),
              if (item?['notes'] != null) Text('${item!['notes']}'),
              const SizedBox(height: 16),
              Text(
                l10n(context).equipment,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('${item?['equipment_count'] ?? 0}'),
              for (final eq in equipment)
                ListTile(
                  title: Text('${eq['name']}'),
                  subtitle: Text('${eq['reference']}'),
                ),
              if (widget.canManage && item?['archived_at'] == null)
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EquipmentOrganizationPage(
                          api: widget.api,
                          organizationId: widget.id,
                        ),
                      ),
                    );
                    load();
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l10n(context).m6ManageEquipment),
                ),
              const SizedBox(height: 16),
              Text(
                l10n(context).m6ProjectsContracts,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final project in projects)
                ListTile(
                  title: Text('${project['name']}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetail(
                        api: widget.api,
                        id: '${project['id']}',
                        canManage: widget.canManage,
                        canFinance: true,
                      ),
                    ),
                  ),
                ),
              if (widget.canManage && item?['archived_at'] == null)
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectForm(
                          api: widget.api,
                          initialOrganizationId: widget.id,
                        ),
                      ),
                    );
                    load();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n(context).m6AddProject),
                ),
              const SizedBox(height: 20),
              if (widget.canManage)
                OutlinedButton(
                  key: const Key('toggleOrganizationArchive'),
                  onPressed: busy ? null : transition,
                  child: Text(
                    item?['archived_at'] == null
                        ? l10n(context).archive
                        : l10n(context).restoreDocument,
                  ),
                ),
              InlineError(error),
            ],
          ),
  );
}

class EquipmentOrganizationPage extends StatefulWidget {
  final Api api;
  final String? equipmentId, organizationId;
  const EquipmentOrganizationPage({
    super.key,
    required this.api,
    this.equipmentId,
    this.organizationId,
  });
  @override
  State<EquipmentOrganizationPage> createState() =>
      _EquipmentOrganizationPageState();
}

class EquipmentM6Context extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final bool canManage, canProjects, canFinance;
  const EquipmentM6Context({
    super.key,
    required this.api,
    required this.equipment,
    required this.canManage,
    required this.canProjects,
    required this.canFinance,
  });
  @override
  State<EquipmentM6Context> createState() => _EquipmentM6ContextState();
}

class _EquipmentM6ContextState extends State<EquipmentM6Context> {
  List<Map<String, dynamic>> projects = [];
  String? organizationId, organizationName;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final equipment = await widget.api.json(
        'GET',
        widget.api.scoped('/equipment/${widget.equipment['id']}'),
      );
      final active = widget.canProjects
          ? await widget.api.json(
              'GET',
              widget.api.scoped(
                '/projects/equipment/${widget.equipment['id']}/active-projects',
              ),
            )
          : <dynamic>[];
      if (mounted) {
        setState(() {
          organizationId = equipment['organizationId']?.toString();
          organizationName = equipment['organizationName']?.toString();
          projects = m6Rows(active);
        });
      }
    } catch (_) {
      /* Existing equipment detail remains usable without M6 access. */
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n(context).m6Organizations),
        subtitle: Text(organizationName ?? l10n(context).m6NoOrganization),
        trailing: widget.canManage
            ? TextButton(
                key: const Key('changeEquipmentOrganization'),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipmentOrganizationPage(
                        api: widget.api,
                        equipmentId: '${widget.equipment['id']}',
                      ),
                    ),
                  );
                  load();
                },
                child: Text(l10n(context).edit),
              )
            : null,
      ),
      if (widget.canProjects) ...[
        Text(
          l10n(context).m6ActiveProjects,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (projects.isEmpty) Text(l10n(context).m6NoActiveProjects),
        for (final project in projects)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${project['name']}'),
            leading: const Icon(Icons.folder_outlined),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetail(
                  api: widget.api,
                  id: '${project['id']}',
                  canManage: widget.canManage,
                  canFinance: widget.canFinance,
                ),
              ),
            ),
          ),
      ],
    ],
  );
}

class _EquipmentOrganizationPageState extends State<EquipmentOrganizationPage> {
  List<Map<String, dynamic>> organizations = [], equipment = [];
  String? currentOrganization, originalOrganization, error;
  bool loading = true, busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final orgs = await widget.api.json(
        'GET',
        widget.api.scoped('/organizations'),
      );
      final eq = await m6AllEquipment(widget.api);
      if (mounted) {
        setState(() {
          organizations = m6Rows(orgs);
          equipment = eq;
          currentOrganization = widget.equipmentId == null
              ? widget.organizationId
              : equipment
                    .where((e) => e['id'] == widget.equipmentId)
                    .firstOrNull?['organizationId']
                    ?.toString();
          originalOrganization = currentOrganization;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> assign(String equipmentId, String? organizationId) async {
    if (originalOrganization != null &&
        originalOrganization != organizationId) {
      if (!await m6Confirm(context, l10n(context).m6MoveEquipmentConfirm)) {
        return;
      }
      if (!mounted) return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        'PUT',
        widget.api.scoped('/equipment/$equipmentId/organization'),
        body: {'organizationId': organizationId},
      );
      await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).m6AssignEquipment)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.equipmentId != null) ...[
                DropdownButtonFormField<String?>(
                  key: const Key('equipmentOrganizationChoice'),
                  initialValue: currentOrganization,
                  decoration: InputDecoration(
                    labelText: l10n(context).m6Organizations,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n(context).m6NoOrganization),
                    ),
                    for (final org in organizations)
                      DropdownMenuItem<String?>(
                        value: '${org['id']}',
                        child: Text('${org['name']}'),
                      ),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() => currentOrganization = v),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('saveEquipmentOrganization'),
                  onPressed: busy
                      ? null
                      : () => assign(widget.equipmentId!, currentOrganization),
                  child: Text(l10n(context).save),
                ),
              ] else ...[
                Text(l10n(context).m6ManageEquipment),
                for (final eq in equipment)
                  ListTile(
                    title: Text('${eq['name']}'),
                    subtitle: Text('${eq['reference']}'),
                    trailing: eq['organizationId'] == widget.organizationId
                        ? const Icon(Icons.check, color: brand)
                        : null,
                    onTap: busy
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EquipmentOrganizationPage(
                                  api: widget.api,
                                  equipmentId: '${eq['id']}',
                                ),
                              ),
                            );
                            if (mounted) load();
                          },
                  ),
              ],
              InlineError(error),
            ],
          ),
  );
}

Future<bool> m6Confirm(BuildContext context, String message) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n(dialog).m6ConfirmAction),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n(dialog).back),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n(dialog).save),
          ),
        ],
      ),
    ) ??
    false;

class ProjectsPage extends StatefulWidget {
  final Api api;
  final bool canManage, canFinance;
  const ProjectsPage({
    super.key,
    required this.api,
    this.canManage = false,
    this.canFinance = false,
  });
  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Map<String, dynamic>> items = [], organizations = [];
  bool loading = true;
  String? error, organizationId;
  String status = 'ALL', kind = 'ALL';
  final search = TextEditingController();
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
    try {
      final query = <String, String>{
        'archived': '${status == 'ARCHIVED'}',
        'search': search.text,
      };
      if (status == 'ACTIVE' || status == 'COMPLETED') query['status'] = status;
      if (kind != 'ALL') query['kind'] = kind;
      if (organizationId != null) query['organizationId'] = organizationId!;
      final projects = await widget.api.json(
        'GET',
        widget.api.scoped('/projects?${Uri(queryParameters: query).query}'),
      );
      List<Map<String, dynamic>> orgs = [];
      try {
        orgs = m6Rows(
          await widget.api.json('GET', widget.api.scoped('/organizations')),
        );
      } catch (_) {
        /* Project access may be granted without organization list access. */
      }
      if (mounted) {
        setState(() {
          items = m6Rows(projects);
          organizations = orgs;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).m6ProjectsContracts),
      actions: [
        IconButton(
          onPressed: load,
          icon: const Icon(Icons.refresh),
          tooltip: l10n(context).refresh,
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
            child: TextButton(onPressed: load, child: Text(error!)),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n(context).m6ProjectsOptional),
              const SizedBox(height: 12),
              TextField(
                controller: search,
                decoration: InputDecoration(
                  labelText: l10n(context).m6SearchProjects,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: load,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => load(),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'ALL', label: Text(l10n(context).m6All)),
                  ButtonSegment(
                    value: 'ACTIVE',
                    label: Text(l10n(context).active),
                  ),
                  ButtonSegment(
                    value: 'COMPLETED',
                    label: Text(l10n(context).m6Completed),
                  ),
                  ButtonSegment(
                    value: 'ARCHIVED',
                    label: Text(l10n(context).archived),
                  ),
                ],
                selected: {status},
                onSelectionChanged: (v) {
                  status = v.first;
                  load();
                },
              ),
              DropdownButtonFormField<String>(
                key: const Key('projectKindFilter'),
                initialValue: kind,
                decoration: InputDecoration(
                  labelText: l10n(context).m6RecordKind,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'ALL',
                    child: Text(l10n(context).m6All),
                  ),
                  DropdownMenuItem(
                    value: 'PROJECT',
                    child: Text(l10n(context).m6Project),
                  ),
                  DropdownMenuItem(
                    value: 'CONTRACT',
                    child: Text(l10n(context).m6Contract),
                  ),
                ],
                onChanged: (v) {
                  kind = v!;
                  load();
                },
              ),
              if (organizations.isNotEmpty)
                DropdownButtonFormField<String?>(
                  initialValue: organizationId,
                  decoration: InputDecoration(
                    labelText: l10n(context).m6Organizations,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n(context).m6All),
                    ),
                    for (final org in organizations)
                      DropdownMenuItem<String?>(
                        value: '${org['id']}',
                        child: Text('${org['name']}'),
                      ),
                  ],
                  onChanged: (v) {
                    organizationId = v;
                    load();
                  },
                ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(l10n(context).m6NoProjects),
                ),
              for (final project in items)
                Card(
                  child: ListTile(
                    key: Key('project-${project['id']}'),
                    title: Text('${project['name']}'),
                    subtitle: Text(
                      '${project['kind'] == 'CONTRACT' ? l10n(context).m6Contract : l10n(context).m6Project} • ${project['status'] == 'COMPLETED' ? l10n(context).m6Completed : l10n(context).active}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetail(
                            api: widget.api,
                            id: '${project['id']}',
                            canManage: widget.canManage,
                            canFinance: widget.canFinance,
                          ),
                        ),
                      );
                      if (mounted) load();
                    },
                  ),
                ),
            ],
          ),
    floatingActionButton: widget.canManage
        ? FloatingActionButton.extended(
            key: const Key('addProject'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProjectForm(api: widget.api)),
              );
              if (mounted) load();
            },
            icon: const Icon(Icons.add),
            label: Text(l10n(context).m6AddProject),
          )
        : null,
  );
}

class ProjectForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? item;
  final String? initialOrganizationId;
  const ProjectForm({
    super.key,
    required this.api,
    this.item,
    this.initialOrganizationId,
  });
  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final name = TextEditingController(),
      client = TextEditingController(),
      number = TextEditingController(),
      notes = TextEditingController();
  List<Map<String, dynamic>> organizations = [];
  String kind = 'PROJECT';
  String? organizationId, startDate, endDate, error;
  bool busy = false,
      loadingOrganizations = true,
      organizationLoadFailed = false;
  @override
  void initState() {
    super.initState();
    final row = widget.item;
    kind = '${row?['kind'] ?? 'PROJECT'}';
    organizationId =
        widget.initialOrganizationId ?? row?['organization_id']?.toString();
    name.text = '${row?['name'] ?? ''}';
    client.text = '${row?['client_name'] ?? ''}';
    number.text = '${row?['contract_number'] ?? ''}';
    notes.text = '${row?['notes'] ?? ''}';
    startDate = row?['start_date']?.toString();
    endDate = row?['end_date']?.toString();
    loadOrganizations();
  }

  @override
  void dispose() {
    name.dispose();
    client.dispose();
    number.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> loadOrganizations() async {
    setState(() {
      loadingOrganizations = true;
      organizationLoadFailed = false;
    });
    try {
      final response = await widget.api.json(
        'GET',
        widget.api.scoped('/organizations'),
      );
      if (mounted) {
        setState(() {
          organizations = m6Rows(response);
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          organizationLoadFailed = true;
          error = localizedError(context, e);
        });
      }
    } finally {
      if (mounted) setState(() => loadingOrganizations = false);
    }
  }

  Future<void> pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse((start ? startDate : endDate) ?? '') ??
          DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          startDate = picked.toIso8601String().split('T').first;
        } else {
          endDate = picked.toIso8601String().split('T').first;
        }
      });
    }
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = l10n(context).m6NameRequired);
      return;
    }
    if (startDate != null &&
        endDate != null &&
        startDate!.compareTo(endDate!) > 0) {
      setState(() => error = l10n(context).m6DateOrder);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        widget.item == null ? 'POST' : 'PUT',
        widget.api.scoped(
          widget.item == null ? '/projects' : '/projects/${widget.item!['id']}',
        ),
        body: {
          'kind': kind,
          'name': name.text.trim(),
          'organizationId': organizationId,
          'clientName': client.text.trim(),
          'contractNumber': number.text.trim(),
          'startDate': startDate,
          'endDate': endDate,
          'notes': notes.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
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
        widget.item == null ? l10n(context).m6AddProject : l10n(context).edit,
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          key: const Key('projectKind'),
          initialValue: kind,
          decoration: InputDecoration(labelText: l10n(context).m6RecordKind),
          items: [
            DropdownMenuItem(
              value: 'PROJECT',
              child: Text(l10n(context).m6Project),
            ),
            DropdownMenuItem(
              value: 'CONTRACT',
              child: Text(l10n(context).m6Contract),
            ),
          ],
          onChanged: (v) => setState(() => kind = v!),
        ),
        TextField(
          key: const Key('projectName'),
          controller: name,
          maxLength: 100,
          decoration: InputDecoration(labelText: '${l10n(context).name} *'),
        ),
        if (loadingOrganizations)
          const LinearProgressIndicator()
        else
          DropdownButtonFormField<String?>(
            key: const Key('projectOrganization'),
            initialValue: organizationId,
            decoration: InputDecoration(
              labelText: l10n(context).m6OrganizationOptional,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n(context).m6NoOrganization),
              ),
              if (organizationId != null &&
                  !organizations.any((o) => o['id'] == organizationId))
                DropdownMenuItem<String?>(
                  value: organizationId,
                  child: Text(
                    '${widget.item?['organization_name'] ?? l10n(context).m6Organizations}',
                  ),
                ),
              for (final org in organizations)
                DropdownMenuItem<String?>(
                  value: '${org['id']}',
                  child: Text('${org['name']}'),
                ),
            ],
            onChanged: organizationLoadFailed
                ? null
                : (v) => setState(() => organizationId = v),
          ),
        if (organizationLoadFailed)
          TextButton.icon(
            onPressed: loadOrganizations,
            icon: const Icon(Icons.refresh),
            label: Text(l10n(context).retry),
          ),
        TextField(
          controller: client,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: l10n(context).m6ClientOptional,
          ),
        ),
        TextField(
          controller: number,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: l10n(context).m6ContractNumberOptional,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => pickDate(true),
          icon: const Icon(Icons.event),
          label: Text(
            startDate == null
                ? l10n(context).m6StartDateOptional
                : localizedDate(context, startDate),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => pickDate(false),
          icon: const Icon(Icons.event),
          label: Text(
            endDate == null
                ? l10n(context).m6EndDateOptional
                : localizedDate(context, endDate),
          ),
        ),
        TextField(
          controller: notes,
          maxLength: 1000,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n(context).uiNoteOptional),
        ),
        InlineError(error),
        FilledButton(
          key: const Key('saveProject'),
          onPressed:
              busy ||
                  loadingOrganizations ||
                  (organizationLoadFailed && organizationId != null)
              ? null
              : save,
          child: Text(l10n(context).save),
        ),
      ],
    ),
  );
}

class ProjectDetail extends StatefulWidget {
  final Api api;
  final String id;
  final bool canManage, canFinance;
  const ProjectDetail({
    super.key,
    required this.api,
    required this.id,
    required this.canManage,
    required this.canFinance,
  });
  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  Map<String, dynamic>? item, summary;
  List<Map<String, dynamic>> links = [];
  bool loading = true, busy = false;
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
      final p = await widget.api.json(
        'GET',
        widget.api.scoped('/projects/${widget.id}'),
      );
      final l = await widget.api.json(
        'GET',
        widget.api.scoped('/projects/${widget.id}/equipment'),
      );
      Map<String, dynamic>? s;
      if (widget.canFinance) {
        try {
          s = Map<String, dynamic>.from(
            await widget.api.json(
              'GET',
              widget.api.scoped('/projects/${widget.id}/financial-summary'),
            ),
          );
        } catch (_) {
          /* Backend enforces separate FINANCE_VIEW. */
        }
      }
      if (mounted) {
        setState(() {
          item = Map<String, dynamic>.from(p);
          links = m6Rows(l);
          summary = s;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> transition(String action) async {
    final loc = l10n(context);
    if (action == 'complete' &&
        !await m6Confirm(context, loc.m6CompleteConfirm)) {
      return;
    }
    if (!mounted) return;
    if (action == 'archive' &&
        !await m6Confirm(context, loc.m6ArchiveProjectConfirm)) {
      return;
    }
    if (!mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/projects/${widget.id}/$action'),
      );
      await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> addFinance(bool income) async {
    try {
      final active = links.where((l) => l['unlinked_at'] == null).toList();
      Map<String, dynamic>? equipment;
      final choices = await m6AllEquipment(widget.api);
      if (!mounted) return;
      final rows = choices;
      final allowed = rows
          .where((e) => active.any((l) => l['equipment_id'] == e['id']))
          .toList();
      if (!income) {
        allowed.insert(0, {'id': null, 'name': l10n(context).generalExpense});
      }
      if (allowed.isEmpty) {
        setState(() => error = l10n(context).m6LinkEquipmentFirst);
        return;
      }
      equipment = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialog) => SimpleDialog(
          title: Text(l10n(dialog).uiSelectEquipment),
          children: [
            for (final choice in allowed)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialog, choice),
                child: Text('${choice['name']}'),
              ),
          ],
        ),
      );
      if (equipment == null || !mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExpenseForm(
            api: widget.api,
            equipment: equipment!,
            income: income,
            initialScope: equipment['id'] == null ? 'GENERAL' : 'SINGLE',
            initialProjectId: widget.id,
          ),
        ),
      );
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = item;
    final archived = row?['archived_at'] != null;
    return Scaffold(
      appBar: AppBar(
        title: Text('${row?['name'] ?? l10n(context).m6ProjectsContracts}'),
        actions: [
          if (row != null && widget.canManage && !archived)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n(context).edit,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectForm(api: widget.api, item: row),
                  ),
                );
                load();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n(context).refresh,
            onPressed: load,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && row == null
          ? Center(
              child: TextButton(onPressed: load, child: Text(error!)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  row?['kind'] == 'CONTRACT'
                      ? l10n(context).m6Contract
                      : l10n(context).m6Project,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  archived
                      ? l10n(context).archived
                      : row?['status'] == 'COMPLETED'
                      ? l10n(context).m6Completed
                      : l10n(context).active,
                ),
                const SizedBox(height: 12),
                _detail(
                  context,
                  l10n(context).m6Organizations,
                  row?['organization_id'] == null
                      ? l10n(context).m6NoOrganization
                      : '${row?['organization_name'] ?? l10n(context).m6Organizations}',
                ),
                _detail(
                  context,
                  l10n(context).m6ClientOptional,
                  row?['client_name'],
                ),
                _detail(
                  context,
                  l10n(context).m6ContractNumberOptional,
                  row?['contract_number'],
                ),
                _detail(
                  context,
                  l10n(context).m6StartDateOptional,
                  row?['start_date'] == null
                      ? null
                      : localizedDate(context, '${row?['start_date']}'),
                ),
                _detail(
                  context,
                  l10n(context).m6EndDateOptional,
                  row?['end_date'] == null
                      ? null
                      : localizedDate(context, '${row?['end_date']}'),
                ),
                _detail(context, l10n(context).uiNoteOptional, row?['notes']),
                const SizedBox(height: 20),
                Text(
                  l10n(context).equipment,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final link in links.where((l) => l['unlinked_at'] == null))
                  ListTile(title: Text('${link['equipment_name']}')),
                if (widget.canManage && !archived && row?['status'] == 'ACTIVE')
                  OutlinedButton.icon(
                    key: const Key('manageProjectEquipment'),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectEquipmentPage(
                            api: widget.api,
                            project: row!,
                          ),
                        ),
                      );
                      load();
                    },
                    icon: const Icon(Icons.link),
                    label: Text(l10n(context).m6ManageEquipment),
                  ),
                if (summary != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n(context).m6FinancialSummary,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _money(
                    context,
                    l10n(context).m6RecordedIncome,
                    summary!['recordedIncome'],
                  ),
                  _money(
                    context,
                    l10n(context).m6RecordedExpenses,
                    summary!['recordedExpenses'],
                  ),
                  _money(
                    context,
                    l10n(context).m6RecordedDifference,
                    summary!['recordedDifference'],
                  ),
                  _money(
                    context,
                    l10n(context).m6Collected,
                    summary!['collected'],
                  ),
                  _money(context, l10n(context).m6Paid, summary!['paid']),
                  _money(
                    context,
                    l10n(context).m6ReceivablesRemaining,
                    summary!['receivablesRemaining'],
                  ),
                  _money(
                    context,
                    l10n(context).m6PayablesRemaining,
                    summary!['payablesRemaining'],
                  ),
                ],
                if (widget.canFinance && !archived)
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => addFinance(false),
                        icon: const Icon(Icons.remove_circle_outline),
                        label: Text(l10n(context).addExpense),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => addFinance(true),
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(l10n(context).addIncome),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ProjectAttachments(
                  api: widget.api,
                  projectId: widget.id,
                  canManage: widget.canManage && !archived,
                ),
                if (widget.canManage) ...[
                  const SizedBox(height: 20),
                  if (!archived)
                    OutlinedButton(
                      key: const Key('projectComplete'),
                      onPressed: busy
                          ? null
                          : () => transition(
                              row?['status'] == 'ACTIVE'
                                  ? 'complete'
                                  : 'reopen',
                            ),
                      child: Text(
                        row?['status'] == 'ACTIVE'
                            ? l10n(context).m6Complete
                            : l10n(context).m6Reopen,
                      ),
                    ),
                  OutlinedButton(
                    key: const Key('projectArchive'),
                    onPressed: busy
                        ? null
                        : () => transition(archived ? 'restore' : 'archive'),
                    child: Text(
                      archived
                          ? l10n(context).restoreDocument
                          : l10n(context).archive,
                    ),
                  ),
                ],
                InlineError(error),
              ],
            ),
    );
  }

  Widget _detail(BuildContext context, String title, Object? value) =>
      value == null || '$value'.isEmpty
      ? const SizedBox.shrink()
      : ListTile(title: Text(title), subtitle: Text('$value'));
  Widget _money(BuildContext context, String title, Object? value) => ListTile(
    title: Text(title),
    trailing: Text(localizedMoney(context, value)),
  );
}

class ProjectEquipmentPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> project;
  const ProjectEquipmentPage({
    super.key,
    required this.api,
    required this.project,
  });
  @override
  State<ProjectEquipmentPage> createState() => _ProjectEquipmentPageState();
}

class _ProjectEquipmentPageState extends State<ProjectEquipmentPage> {
  List<Map<String, dynamic>> equipment = [], links = [];
  String? error;
  bool loading = true, busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final response = await m6AllEquipment(widget.api);
      final linked = await widget.api.json(
        'GET',
        widget.api.scoped('/projects/${widget.project['id']}/equipment'),
      );
      if (mounted) {
        setState(() {
          equipment = response;
          links = m6Rows(linked);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> toggle(String id, bool linked) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        linked ? 'DELETE' : 'POST',
        widget.api.scoped('/projects/${widget.project['id']}/equipment/$id'),
      );
      await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectOrg = widget.project['organization_id'];
    final eligible = equipment.where(
      (e) => projectOrg == null || e['organizationId'] == projectOrg,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n(context).m6ManageEquipment)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  projectOrg == null
                      ? l10n(context).m6WorkspaceProjectEquipment
                      : l10n(context).m6OrganizationProjectEquipment,
                ),
                for (final eq in eligible)
                  CheckboxListTile(
                    key: Key('projectEquipment-${eq['id']}'),
                    title: Text('${eq['name']}'),
                    subtitle: Text('${eq['reference']}'),
                    value: links.any(
                      (l) =>
                          l['equipment_id'] == eq['id'] &&
                          l['unlinked_at'] == null,
                    ),
                    onChanged: busy
                        ? null
                        : (v) => toggle('${eq['id']}', v == false),
                  ),
                InlineError(error),
              ],
            ),
    );
  }
}

class ProjectAttachments extends StatefulWidget {
  final Api api;
  final String projectId;
  final bool canManage;
  const ProjectAttachments({
    super.key,
    required this.api,
    required this.projectId,
    required this.canManage,
  });
  @override
  State<ProjectAttachments> createState() => _ProjectAttachmentsState();
}

class _ProjectAttachmentsState extends State<ProjectAttachments> {
  List<Map<String, dynamic>> items = [];
  String? loadError, uploadError;
  bool busy = false, loading = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final response = await widget.api.json(
        'GET',
        widget.api.scoped('/projects/${widget.projectId}/attachments'),
      );
      if (mounted) setState(() => items = m6Rows(response));
    } catch (e) {
      if (mounted) setState(() => loadError = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add([Map<String, dynamic>? retry]) async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: l10n(context).fileTypes,
          extensions: ['jpg', 'jpeg', 'png', 'pdf'],
          mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
        ),
      ],
    );
    if (file == null) return;
    final size = await file.length();
    if (!mounted) return;
    if (size > 10 * 1024 * 1024) {
      setState(() => uploadError = l10n(context).fileTooLarge);
      return;
    }
    final type = switch (file.name.split('.').last.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => null,
    };
    if (type == null) {
      setState(() => uploadError = l10n(context).unsupportedFile);
      return;
    }
    if (retry != null &&
        (retry['filename'] != file.name ||
            retry['size'] != size ||
            retry['mediaType'] != type)) {
      setState(() => uploadError = l10n(context).m6RetrySameFile);
      return;
    }
    setState(() {
      busy = true;
      uploadError = null;
    });
    try {
      final created =
          retry ??
          await widget.api.json(
            'POST',
            widget.api.scoped('/projects/${widget.projectId}/attachments'),
            key: requestKey(),
            body: {'filename': file.name, 'mediaType': type, 'size': size},
          );
      await widget.api.send(
        'PUT',
        widget.api.scoped('/attachments/${created['id']}/content'),
        bytes: await file.readAsBytes(),
        type: type,
      );
      await load();
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> open(Map<String, dynamic> file) async {
    try {
      final response = await widget.api.send(
        'GET',
        widget.api.scoped('/attachments/${file['id']}/content'),
      );
      await exportFile(
        response.bodyBytes,
        '${file['filename']}',
        '${file['mediaType']}',
      );
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
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
      if (loadError != null)
        TextButton.icon(
          onPressed: load,
          icon: const Icon(Icons.refresh),
          label: Text(loadError!),
        ),
      if (!loading && loadError == null)
        for (final file in items)
          ListTile(
            title: Text('${file['filename']}'),
            subtitle: Text('${file['state']}'),
            onTap: file['state'] == 'READY' ? () => open(file) : null,
            trailing: widget.canManage && file['state'] != 'READY'
                ? TextButton(
                    onPressed: busy ? null : () => add(file),
                    child: Text(l10n(context).retry),
                  )
                : null,
          ),
      if (!loading && loadError == null && items.isEmpty)
        Text(l10n(context).noAttachments),
      if (widget.canManage)
        OutlinedButton.icon(
          key: const Key('addProjectAttachment'),
          onPressed: busy ? null : add,
          icon: const Icon(Icons.attach_file),
          label: Text(l10n(context).uiAddAttachment),
        ),
      InlineError(uploadError),
    ],
  );
}
