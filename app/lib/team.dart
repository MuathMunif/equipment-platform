import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'documents.dart';
import 'localization.dart';
import 'maintenance.dart';

List<Map<String, dynamic>> records(Object? value) =>
    (value as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

String m5Role(BuildContext context, Object? value) => switch (value) {
  'OWNER' => l10n(context).m5Owner,
  'MANAGER' => l10n(context).m5Manager,
  'ACCOUNTANT' => l10n(context).m5Accountant,
  'DRIVER' => l10n(context).m5Driver,
  _ => l10n(context).m5Member,
};

String m5Status(BuildContext context, Object? value) => switch (value) {
  'PENDING_REVIEW' => l10n(context).m5Pending,
  'PENDING' => l10n(context).m5Pending,
  'ACCEPTED' => l10n(context).m5Accepted,
  'CANCELLED' => l10n(context).m5Cancelled,
  'EXPIRED' => l10n(context).m5Expired,
  'APPROVED' => l10n(context).m5Approved,
  'REJECTED' => l10n(context).m5Rejected,
  _ => l10n(context).m5Pending,
};

String m5Capability(BuildContext context, String value) {
  final loc = l10n(context);
  return switch (value) {
    'EQUIPMENT_VIEW' => loc.m5EquipmentView,
    'EQUIPMENT_MANAGE' => loc.m5EquipmentManage,
    'FINANCE_VIEW' => loc.m5FinanceView,
    'FINANCE_MANAGE' => loc.m5FinanceManage,
    'FINANCE_REVIEW' => loc.m5FinanceReview,
    'DOCUMENT_VIEW' => loc.m5DocumentView,
    'DOCUMENT_MANAGE' => loc.m5DocumentManage,
    'ISSUE_VIEW' => loc.m5IssueView,
    'ISSUE_MANAGE' => loc.m5IssueManage,
    'MAINTENANCE_VIEW' => loc.m5MaintenanceView,
    'MAINTENANCE_MANAGE' => loc.m5MaintenanceManage,
    'DRIVER_ASSIGNMENT_MANAGE' => loc.m5DriverAssignmentManage,
    'REPORT_VIEW' => loc.m5ReportView,
    'TEAM_MANAGE' => loc.m5TeamManage,
    _ => value,
  };
}

const m5CapabilityCodes = [
  'EQUIPMENT_VIEW',
  'EQUIPMENT_MANAGE',
  'FINANCE_VIEW',
  'FINANCE_MANAGE',
  'FINANCE_REVIEW',
  'DOCUMENT_VIEW',
  'DOCUMENT_MANAGE',
  'ISSUE_VIEW',
  'ISSUE_MANAGE',
  'MAINTENANCE_VIEW',
  'MAINTENANCE_MANAGE',
  'DRIVER_ASSIGNMENT_MANAGE',
  'REPORT_VIEW',
  'TEAM_MANAGE',
];

const m5CapabilityGroups = <String, List<String>>{
  'equipment': ['EQUIPMENT_VIEW', 'EQUIPMENT_MANAGE'],
  'finance': [
    'FINANCE_VIEW',
    'FINANCE_MANAGE',
    'FINANCE_REVIEW',
    'REPORT_VIEW',
  ],
  'documents': ['DOCUMENT_VIEW', 'DOCUMENT_MANAGE'],
  'issues': ['ISSUE_VIEW', 'ISSUE_MANAGE'],
  'maintenance': ['MAINTENANCE_VIEW', 'MAINTENANCE_MANAGE'],
  'team': ['DRIVER_ASSIGNMENT_MANAGE', 'TEAM_MANAGE'],
};

String m5Group(BuildContext context, String group) => switch (group) {
  'equipment' => l10n(context).equipment,
  'finance' => l10n(context).ledger,
  'documents' => l10n(context).documents,
  'issues' => l10n(context).m5Issues,
  'maintenance' => l10n(context).m4Hub,
  _ => l10n(context).m5Team,
};

const m5DefaultCapabilities = <String, Set<String>>{
  'MANAGER': {
    'EQUIPMENT_VIEW',
    'EQUIPMENT_MANAGE',
    'FINANCE_VIEW',
    'FINANCE_MANAGE',
    'FINANCE_REVIEW',
    'DOCUMENT_VIEW',
    'DOCUMENT_MANAGE',
    'ISSUE_VIEW',
    'ISSUE_MANAGE',
    'MAINTENANCE_VIEW',
    'MAINTENANCE_MANAGE',
    'DRIVER_ASSIGNMENT_MANAGE',
    'REPORT_VIEW',
  },
  'ACCOUNTANT': {
    'EQUIPMENT_VIEW',
    'FINANCE_VIEW',
    'FINANCE_MANAGE',
    'FINANCE_REVIEW',
    'DOCUMENT_VIEW',
    'DOCUMENT_MANAGE',
    'ISSUE_VIEW',
    'ISSUE_MANAGE',
    'MAINTENANCE_VIEW',
    'MAINTENANCE_MANAGE',
    'REPORT_VIEW',
  },
  'DRIVER': {
    'EQUIPMENT_VIEW',
    'ISSUE_VIEW',
    'ISSUE_MANAGE',
    'MAINTENANCE_VIEW',
    'FINANCE_MANAGE',
  },
};

Future<bool> m5Confirm(
  BuildContext context,
  String title,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n(dialog).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

class M5Loader extends StatelessWidget {
  final String? error;
  final VoidCallback retry;
  const M5Loader({super.key, required this.error, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
    child: error == null
        ? const CircularProgressIndicator()
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center),
              TextButton(onPressed: retry, child: Text(l10n(context).retry)),
            ],
          ),
  );
}

class AccountInvitationsPage extends StatefulWidget {
  final Api api;
  final Future<void> Function() changed;
  const AccountInvitationsPage({
    super.key,
    required this.api,
    required this.changed,
  });
  @override
  State<AccountInvitationsPage> createState() => _AccountInvitationsPageState();
}

class _AccountInvitationsPageState extends State<AccountInvitationsPage> {
  List<Map<String, dynamic>> items = [];
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
      final data = await widget.api.json('GET', '/account/invitations');
      if (mounted) setState(() => items = records(data));
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> act(Map<String, dynamic> item, bool accept) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        'POST',
        '/account/invitations/${item['id']}/${accept ? 'accept' : 'decline'}',
        key: requestKey(),
      );
      await widget.changed();
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).m5MyInvitations)),
    body: loading
        ? M5Loader(error: null, retry: load)
        : error != null && items.isEmpty
        ? M5Loader(error: error, retry: load)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (error != null) Text(error!),
              if (items.isEmpty) Text(l10n(context).m5NoInvitations),
              for (final item in items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['workspaceName']}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(m5Role(context, item['role'])),
                        Text(
                          '${l10n(context).m5Expires}: ${localizedDate(context, item['expiresAt'] as String?)}',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(
                              key: Key('accept-${item['id']}'),
                              onPressed: busy ? null : () => act(item, true),
                              child: Text(l10n(context).m5Accept),
                            ),
                            OutlinedButton(
                              onPressed: busy ? null : () => act(item, false),
                              child: Text(l10n(context).m5Decline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );
}

class TeamPage extends StatefulWidget {
  final Api api;
  final bool owner, canAssign;
  const TeamPage({
    super.key,
    required this.api,
    required this.owner,
    required this.canAssign,
  });
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Map<String, dynamic>> members = [], invitations = [];
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
      final values = await Future.wait([
        widget.api.json('GET', widget.api.scoped('/team/members')),
        if (widget.owner)
          widget.api.json('GET', widget.api.scoped('/team/invitations')),
      ]);
      if (mounted) {
        setState(() {
          members = records(values[0]);
          invitations = widget.owner ? records(values[1]) : [];
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) load();
  }

  Future<void> inviteAction(Map<String, dynamic> item, String action) async {
    if (!await m5Confirm(
      context,
      action == 'cancel'
          ? l10n(context).m5CancelInvitation
          : l10n(context).m5ResendInvitation,
      action == 'cancel' ? l10n(context).cancel : l10n(context).m5Resend,
    )) {
      return;
    }
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/team/invitations/${item['id']}/$action'),
        key: requestKey(),
      );
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).m5Team),
      actions: [
        IconButton(
          tooltip: l10n(context).refresh,
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: widget.owner
        ? FloatingActionButton.extended(
            key: const Key('inviteMember'),
            onPressed: () => open(TeamEditorPage(api: widget.api)),
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n(context).m5InviteMember),
          )
        : null,
    body: loading
        ? M5Loader(error: null, retry: load)
        : error != null && members.isEmpty && invitations.isEmpty
        ? M5Loader(error: error, retry: load)
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (error != null) Text(error!),
              Text(
                l10n(context).m5Members,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (members.isEmpty) Text(l10n(context).m5NoMembers),
              for (final member in members)
                Card(
                  child: ListTile(
                    key: Key('member-${member['userId']}'),
                    leading: const Icon(Icons.person_outline),
                    title: Text('${member['displayName']}'),
                    subtitle: Text(m5Role(context, member['role'])),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open(
                      MemberDetailPage(
                        api: widget.api,
                        userId: member['userId'] as String,
                        owner: widget.owner,
                        canAssign: widget.canAssign,
                      ),
                    ),
                  ),
                ),
              if (widget.owner) const SizedBox(height: 20),
              if (widget.owner)
                Text(
                  l10n(context).m5Invitations,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              if (widget.owner && invitations.isEmpty)
                Text(l10n(context).m5NoInvitations),
              for (final invitation in invitations)
                Card(
                  child: ListTile(
                    title: Text('${invitation['displayName']}'),
                    subtitle: Text(
                      '${invitation['phone']} • ${m5Role(context, invitation['role'])} • ${m5Status(context, invitation['status'])}',
                    ),
                    trailing: invitation['status'] == 'PENDING'
                        ? PopupMenuButton<String>(
                            onSelected: (value) =>
                                inviteAction(invitation, value),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'resend',
                                child: Text(l10n(context).m5Resend),
                              ),
                              PopupMenuItem(
                                value: 'cancel',
                                child: Text(l10n(context).cancel),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
            ],
          ),
  );
}

class TeamEditorPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? member;
  const TeamEditorPage({super.key, required this.api, this.member});
  @override
  State<TeamEditorPage> createState() => _TeamEditorPageState();
}

class _TeamEditorPageState extends State<TeamEditorPage> {
  final name = TextEditingController(), phone = TextEditingController();
  String role = 'DRIVER',
      scope = 'ASSIGNED_EQUIPMENT',
      financialMode = 'REVIEW';
  final Set<String> equipmentIds = {}, capabilities = {};
  List<Map<String, dynamic>> equipment = [];
  String equipmentSearch = '';
  bool loading = true, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      name.text = '${member['displayName'] ?? ''}';
      phone.text = '${member['phone'] ?? ''}';
      role = '${member['role'] ?? 'DRIVER'}';
      scope = '${member['scope'] ?? 'ALL'}';
      financialMode = '${member['financialMode'] ?? 'REVIEW'}';
      equipmentIds.addAll(
        (member['equipmentIds'] as List<dynamic>? ?? []).cast<String>(),
      );
      capabilities.addAll(
        (member['capabilities'] as List<dynamic>? ?? []).cast<String>(),
      );
    } else {
      capabilities.addAll(m5DefaultCapabilities['DRIVER']!);
    }
    loadEquipment();
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> loadEquipment() async {
    try {
      final all = <Map<String, dynamic>>[];
      var page = 0;
      while (true) {
        final response = await widget.api.json(
          'GET',
          widget.api.scoped('/equipment?page=$page'),
        ) as Map<String, dynamic>;
        all.addAll(records(response['items']));
        if (all.length >= (response['total'] as num).toInt()) break;
        page++;
      }
      if (mounted) setState(() => equipment = all);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> save() async {
    if (widget.member == null &&
        (name.text.trim().isEmpty || phone.text.trim().isEmpty)) {
      setState(() => error = l10n(context).m5NamePhoneRequired);
      return;
    }
    if (scope == 'SELECTED_EQUIPMENT' && equipmentIds.isEmpty) {
      setState(() => error = l10n(context).m5ChooseEquipment);
      return;
    }
    if (widget.member != null &&
        (role != widget.member!['role'] || scope != widget.member!['scope']) &&
        !await m5Confirm(
          context,
          role != widget.member!['role']
              ? l10n(context).m5RoleChangeResetsPermissions
              : l10n(context).m5ConfirmPermissions,
          l10n(context).save,
        )) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final body = {
        if (widget.member == null) 'displayName': name.text.trim(),
        if (widget.member == null) 'phone': normalizeDigits(phone.text.trim()),
        'role': role,
        'scope': role == 'DRIVER' ? 'ASSIGNED_EQUIPMENT' : scope,
        'equipmentIds': scope == 'SELECTED_EQUIPMENT' && role != 'DRIVER'
            ? equipmentIds.toList()
            : <String>[],
        'capabilities': capabilities.toList(),
        'financialMode': financialMode,
      };
      await widget.api.json(
        widget.member == null ? 'POST' : 'PUT',
        widget.api.scoped(
          widget.member == null
              ? '/team/invitations'
              : '/team/members/${widget.member!['userId']}',
        ),
        body: body,
        key: widget.member == null ? requestKey() : null,
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
        widget.member == null
            ? l10n(context).m5InviteMember
            : l10n(context).m5EditMember,
      ),
    ),
    body: loading
        ? M5Loader(error: null, retry: loadEquipment)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.member == null) ...[
                TextField(
                  key: const Key('inviteName'),
                  controller: name,
                  decoration: InputDecoration(labelText: l10n(context).name),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('invitePhone'),
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n(context).phoneNumber,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('teamRole'),
                initialValue: role,
                decoration: InputDecoration(labelText: l10n(context).m5Role),
                items: forRoles(context),
                onChanged: (value) => setState(() {
                  role = value!;
                  scope = role == 'DRIVER'
                      ? 'ASSIGNED_EQUIPMENT'
                      : 'ALL_EQUIPMENT';
                  financialMode = role == 'DRIVER' ? 'REVIEW' : 'DIRECT';
                  capabilities
                    ..clear()
                    ..addAll(m5DefaultCapabilities[role]!);
                }),
              ),
              const SizedBox(height: 12),
              if (role != 'DRIVER')
                DropdownButtonFormField<String>(
                  key: const Key('teamScope'),
                  initialValue: scope,
                  decoration: InputDecoration(labelText: l10n(context).m5Scope),
                  items: [
                    DropdownMenuItem(
                      value: 'ALL_EQUIPMENT',
                      child: Text(l10n(context).m5AllEquipment),
                    ),
                    DropdownMenuItem(
                      value: 'SELECTED_EQUIPMENT',
                      child: Text(l10n(context).m5SelectedEquipment),
                    ),
                  ],
                  onChanged: (value) => setState(() => scope = value!),
                ),
              if (role == 'DRIVER') Text(l10n(context).m5DriverInviteHint),
              if (scope == 'ALL_EQUIPMENT' && role != 'DRIVER')
                Text(l10n(context).m5AllScopeHint),
              if (scope == 'SELECTED_EQUIPMENT' && role != 'DRIVER') ...[
                const SizedBox(height: 12),
                Text(l10n(context).m5ChooseEquipment),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n(context).searchEquipment,
                  ),
                  onChanged: (value) => setState(
                    () => equipmentSearch = value.trim().toLowerCase(),
                  ),
                ),
                for (final item in equipment.where(
                  (e) => '${e['name']} ${e['reference']}'
                      .toLowerCase()
                      .contains(equipmentSearch),
                ))
                  CheckboxListTile(
                    title: Text('${item['name']} • ${item['reference']}'),
                    value: equipmentIds.contains(item['id']),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        equipmentIds.add(item['id'] as String);
                      } else {
                        equipmentIds.remove(item['id']);
                      }
                    }),
                  ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('financialMode'),
                initialValue: financialMode,
                decoration: InputDecoration(
                  labelText: l10n(context).m5FinancialMode,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'REVIEW',
                    child: Text(l10n(context).m5ReviewMode),
                  ),
                  DropdownMenuItem(
                    value: 'DIRECT',
                    child: Text(l10n(context).m5DirectMode),
                  ),
                ],
                onChanged: (value) => setState(() => financialMode = value!),
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: Text(l10n(context).m5Capabilities),
                subtitle: Text(l10n(context).m5CapabilitiesHint),
                children: [
                  for (final group in m5CapabilityGroups.entries) ...[
                    ListTile(
                      title: Text(
                        m5Group(context, group.key),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    for (final code in group.value)
                      CheckboxListTile(
                        key: Key('cap-$code'),
                        title: Text(m5Capability(context, code)),
                        value: capabilities.contains(code),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            capabilities.add(code);
                          } else {
                            capabilities.remove(code);
                          }
                        }),
                      ),
                  ],
                ],
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('saveTeamMember'),
                onPressed: busy ? null : save,
                child: Text(
                  widget.member == null
                      ? l10n(context).m5SendInvitation
                      : l10n(context).save,
                ),
              ),
              if (busy) const LinearProgressIndicator(),
            ],
          ),
  );
}

List<DropdownMenuItem<String>> forRoles(BuildContext context) => [
  for (final role in ['MANAGER', 'ACCOUNTANT', 'DRIVER'])
    DropdownMenuItem(value: role, child: Text(m5Role(context, role))),
];

class MemberDetailPage extends StatefulWidget {
  final Api api;
  final String userId;
  final bool owner, canAssign;
  const MemberDetailPage({
    super.key,
    required this.api,
    required this.userId,
    required this.owner,
    required this.canAssign,
  });
  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  Map<String, dynamic>? member;
  List<String> scopeEquipmentNames = [];
  String? error;
  bool loading = true;
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
      final data = await widget.api.json(
        'GET',
        widget.api.scoped('/team/members/${widget.userId}'),
      );
      final detail = Map<String, dynamic>.from(data as Map);
      final selectedIds = (detail['equipmentIds'] as List<dynamic>? ?? [])
          .map((id) => '$id')
          .toSet();
      final names = <String>[];
      if (detail['scope'] == 'SELECTED_EQUIPMENT' && selectedIds.isNotEmpty) {
        var page = 0;
        while (true) {
          final response = await widget.api.json(
            'GET',
            widget.api.scoped('/equipment?page=$page'),
          ) as Map<String, dynamic>;
          for (final equipment in records(response['items'])) {
            if (selectedIds.contains('${equipment['id']}')) {
              names.add('${equipment['name']} • ${equipment['reference']}');
            }
          }
          if ((page + 1) * 30 >= (response['total'] as num).toInt()) break;
          page++;
        }
      }
      if (mounted) {
        setState(() {
          member = detail;
          scopeEquipmentNames = names;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> revoke() async {
    if (!await m5Confirm(
      context,
      l10n(context).m5RevokeConfirm,
      l10n(context).m5RevokeAccess,
    )) {
      return;
    }
    try {
      await widget.api.json(
        'DELETE',
        widget.api.scoped('/team/members/${widget.userId}'),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).m5MemberDetails)),
    body: loading || member == null
        ? M5Loader(error: error, retry: load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${member!['displayName']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('${member!['phone']}'),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n(context).m5Role),
                subtitle: Text(m5Role(context, member!['role'])),
              ),
              ListTile(
                title: Text(l10n(context).m5Scope),
                subtitle: Text(
                  member!['scope'] == 'ALL_EQUIPMENT'
                      ? l10n(context).m5AllEquipment
                      : member!['scope'] == 'ASSIGNED_EQUIPMENT'
                      ? l10n(context).m5CurrentAssignment
                      : l10n(context).m5SelectedEquipment,
                ),
              ),
              if (member!['scope'] == 'SELECTED_EQUIPMENT')
                for (final name in scopeEquipmentNames)
                  ListTile(dense: true, title: Text(name)),
              ListTile(
                title: Text(l10n(context).m5FinancialMode),
                subtitle: Text(
                  member!['financialMode'] == 'DIRECT'
                      ? l10n(context).m5DirectMode
                      : l10n(context).m5ReviewMode,
                ),
              ),
              Text(
                l10n(context).m5Capabilities,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final code
                  in (member!['capabilities'] as List<dynamic>? ?? []))
                ListTile(
                  dense: true,
                  title: Text(m5Capability(context, '$code')),
                ),
              if (member!['role'] == 'DRIVER' && widget.canAssign)
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverAssignmentPage(
                          api: widget.api,
                          driver: member!,
                        ),
                      ),
                    );
                    if (mounted) load();
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: Text(l10n(context).m5DriverAssignment),
                ),
              const SizedBox(height: 12),
              if (widget.owner && member!['role'] != 'OWNER')
                FilledButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TeamEditorPage(api: widget.api, member: member),
                      ),
                    );
                    if (mounted) load();
                  },
                  child: Text(l10n(context).edit),
                ),
              const SizedBox(height: 8),
              if (widget.owner && member!['role'] != 'OWNER')
                OutlinedButton(
                  onPressed: revoke,
                  child: Text(l10n(context).m5RevokeAccess),
                ),
              if (error != null) Text(error!),
            ],
          ),
  );
}

class DriverAssignmentPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> driver;
  const DriverAssignmentPage({
    super.key,
    required this.api,
    required this.driver,
  });
  @override
  State<DriverAssignmentPage> createState() => _DriverAssignmentPageState();
}

/// Equipment-first assignment flow. It uses only assignment permission and
/// never reads the team directory or member details.
class EquipmentDriverAssignmentPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  const EquipmentDriverAssignmentPage({
    super.key,
    required this.api,
    required this.equipment,
  });

  @override
  State<EquipmentDriverAssignmentPage> createState() =>
      _EquipmentDriverAssignmentPageState();
}

class _EquipmentDriverAssignmentPageState
    extends State<EquipmentDriverAssignmentPage> {
  Map<String, dynamic>? current;
  List<Map<String, dynamic>> eligible = [];
  String? selectedId, error;
  bool loading = true, busy = false;

  String get equipmentId => widget.equipment['id'] as String;
  String get equipmentName => widget.equipment['name'] as String;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<Map<String, dynamic>> fetchCurrent() async =>
      Map<String, dynamic>.from(
        await widget.api.json(
          'GET',
          widget.api.scoped('/drivers/equipment/$equipmentId/assignment'),
        ) as Map,
      );

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final assignment = await fetchCurrent();
      final candidates = records(
        await widget.api.json(
          'GET',
          widget.api.scoped('/drivers/eligible?equipmentId=$equipmentId'),
        ),
      );
      if (mounted) {
        setState(() {
          current = assignment;
          eligible = candidates;
          if (!eligible.any((item) => item['userId'] == selectedId) ||
              assignment['driverUserId'] == selectedId) {
            selectedId = null;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> assign() async {
    final driver = eligible
        .where((item) => item['userId'] == selectedId)
        .firstOrNull;
    if (driver == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      // Read again before confirmation so the dialog names the current driver.
      final latest = await fetchCurrent();
      if (!mounted) return;
      setState(() => current = latest);
      if (latest['driverUserId'] == selectedId) {
        await load();
        return;
      }
      final loc = l10n(context);
      final name = driver['displayName'] as String;
      final source = driver['currentEquipmentName'] as String?;
      final incumbent = latest['driverName'] as String?;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(loc.m5DriverAssignment),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                incumbent == null
                    ? loc.m5ConfirmAssignDriver(name, equipmentName)
                    : loc.m5ConfirmReplaceDriver(
                        incumbent,
                        name,
                        equipmentName,
                      ),
              ),
              if (source != null &&
                  driver['currentEquipmentId'] != equipmentId) ...[
                const SizedBox(height: 12),
                Text(loc.m5ConfirmMoveDriver(name, source)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              key: const Key('confirmEquipmentDriverAssignment'),
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(loc.m5Assign),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await widget.api.json(
        'POST',
        widget.api.scoped('/drivers/assignments'),
        body: {'driverUserId': selectedId, 'equipmentId': equipmentId},
        key: requestKey(),
      );
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).m5DriverAssignment)),
    body: loading
        ? M5Loader(error: error, retry: load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                equipmentName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(l10n(context).m5CurrentAssignment),
              ListTile(
                key: const Key('currentEquipmentDriver'),
                title: Text(
                  current?['driverName'] as String? ??
                      l10n(context).m5NoAssignment,
                ),
                subtitle: current?['startedAt'] == null
                    ? null
                    : Text(
                        localizedDate(
                          context,
                          current!['startedAt'] as String?,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              if (eligible.isEmpty)
                Text(l10n(context).m5NoEligibleDrivers)
              else ...[
                DropdownButtonFormField<String>(
                  key: const Key('eligibleDriverPicker'),
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    labelText: l10n(context).m5ChooseDriver,
                  ),
                  items: [
                    for (final driver in eligible)
                      DropdownMenuItem(
                        value: driver['userId'] as String,
                        child: Text(driver['displayName'] as String),
                      ),
                  ],
                  onChanged: busy
                      ? null
                      : (value) => setState(() => selectedId = value),
                ),
                if (selectedId != null &&
                    eligible
                            .where((item) => item['userId'] == selectedId)
                            .firstOrNull?['currentEquipmentName'] !=
                        null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n(context).m5DriverCurrentlyOnEquipment(
                      eligible
                              .where((item) => item['userId'] == selectedId)
                              .first['currentEquipmentName']
                          as String,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('assignEligibleDriver'),
                  onPressed: busy || selectedId == null ? null : assign,
                  child: Text(l10n(context).m5Assign),
                ),
              ],
              if (error != null) Text(error!),
            ],
          ),
  );
}

class _DriverAssignmentPageState extends State<DriverAssignmentPage> {
  List<Map<String, dynamic>> history = [], equipment = [];
  String? selectedId, error;
  bool loading = true, busy = false;
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
      final historyValue = await widget.api.json(
        'GET',
        widget.api.scoped('/drivers/${widget.driver['userId']}/assignments'),
      );
      final all = <Map<String, dynamic>>[];
      var page = 0;
      while (true) {
        final value = await widget.api.json(
          'GET',
          widget.api.scoped('/equipment?page=$page'),
        ) as Map<String, dynamic>;
        all.addAll(records(value['items']));
        if (all.length >= (value['total'] as num).toInt()) break;
        page++;
      }
      if (mounted) {
        setState(() {
          history = records(historyValue);
          equipment = all.where((item) => item['archivedAt'] == null).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> assign() async {
    if (selectedId == null) {
      setState(() => error = l10n(context).m5ChooseEquipment);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final target = Map<String, dynamic>.from(
        await widget.api.json(
          'GET',
          widget.api.scoped('/drivers/equipment/$selectedId/assignment'),
        ) as Map,
      );
      if (!mounted) return;
      if (target['driverUserId'] == widget.driver['userId']) {
        await load();
        return;
      }
      final loc = l10n(context);
      final name = widget.driver['displayName'] as String;
      final selectedEquipment = equipment
          .where((item) => item['id'] == selectedId)
          .first;
      final targetName = selectedEquipment['name'] as String;
      final currentEquipment = history
          .where((item) => item['endedAt'] == null)
          .firstOrNull;
      final sourceName =
          currentEquipment == null ||
              currentEquipment['equipmentId'] == selectedId
          ? null
          : currentEquipment['equipmentName'] as String?;
      final incumbent = target['driverName'] as String?;
      final message = incumbent == null
          ? loc.m5ConfirmAssignDriver(name, targetName)
          : loc.m5ConfirmReplaceDriver(incumbent, name, targetName);
      if (!await m5Confirm(
        context,
        sourceName == null
            ? message
            : '$message\n\n${loc.m5ConfirmMoveDriver(name, sourceName)}',
        loc.m5Assign,
      )) {
        return;
      }
      await widget.api.json(
        'POST',
        widget.api.scoped('/drivers/assignments'),
        body: {
          'driverUserId': widget.driver['userId'],
          'equipmentId': selectedId,
        },
        key: requestKey(),
      );
      await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> unassign(String id) async {
    if (!await m5Confirm(
      context,
      l10n(context).m5UnassignConfirm,
      l10n(context).m5Unassign,
    )) {
      return;
    }
    try {
      await widget.api.json(
        'DELETE',
        widget.api.scoped('/drivers/equipment/$id/assignment'),
      );
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = history
        .where((item) => item['endedAt'] == null)
        .firstOrNull;
    String equipmentName(String? id) =>
        equipment.where((e) => e['id'] == id).firstOrNull?['name'] as String? ??
        history
                .where((e) => e['equipmentId'] == id)
                .firstOrNull?['equipmentName']
            as String? ??
        l10n(context).equipment;
    return Scaffold(
      appBar: AppBar(title: Text(l10n(context).m5DriverAssignment)),
      body: loading
          ? M5Loader(error: null, retry: load)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '${widget.driver['displayName']}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n(context).m5CurrentAssignment,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                current == null
                    ? Text(l10n(context).m5NoAssignment)
                    : Card(
                        child: ListTile(
                          title: Text(
                            equipmentName(current['equipmentId'] as String?),
                          ),
                          subtitle: Text(
                            localizedDate(
                              context,
                              current['startedAt'] as String?,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () =>
                                unassign(current['equipmentId'] as String),
                            child: Text(l10n(context).m5Unassign),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: const Key('assignmentEquipment'),
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    labelText: l10n(context).m5ChooseEquipment,
                  ),
                  items: [
                    for (final item in equipment)
                      DropdownMenuItem(
                        value: item['id'] as String,
                        child: Text('${item['name']} • ${item['reference']}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => selectedId = value),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('assignDriver'),
                  onPressed: busy ? null : assign,
                  child: Text(l10n(context).m5Assign),
                ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  l10n(context).m5AssignmentHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (history.isEmpty) Text(l10n(context).m5NoHistory),
                for (final item in history)
                  ListTile(
                    title: Text(equipmentName(item['equipmentId'] as String?)),
                    subtitle: Text(
                      '${localizedDate(context, item['startedAt'] as String?)} — ${item['endedAt'] == null ? l10n(context).active : localizedDate(context, item['endedAt'] as String?)}',
                    ),
                  ),
              ],
            ),
    );
  }
}

class DriverHomePage extends StatefulWidget {
  final Api api;
  final String financialMode;
  final String? userId;
  const DriverHomePage({
    super.key,
    required this.api,
    required this.financialMode,
    this.userId,
  });
  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  Map<String, dynamic>? equipment;
  List<Map<String, dynamic>> submissions = [], issues = [];
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
      final assignment = await widget.api.json(
        'GET',
        widget.api.scoped('/drivers/me/assignment'),
      ) as Map<String, dynamic>;
      Map<String, dynamic>? found;
      List<Map<String, dynamic>> foundIssues = [];
      if (assignment['equipmentId'] != null) {
        found = Map<String, dynamic>.from(
          await widget.api.json(
            'GET',
            widget.api.scoped('/equipment/${assignment['equipmentId']}'),
          ) as Map,
        );
        final issuePage = await widget.api.json(
          'GET',
          widget.api.scoped(
            '/issues?equipmentId=${assignment['equipmentId']}&page=0',
          ),
        ) as Map<String, dynamic>;
        foundIssues = records(issuePage['items'])
            .where(
              (issue) =>
                  widget.userId == null || issue['createdBy'] == widget.userId,
            )
            .toList();
      }
      final submissionPage = await widget.api.json(
        'GET',
        widget.api.scoped('/financial-submissions/mine?page=0'),
      ) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          equipment = found;
          issues = foundIssues;
          submissions = records(submissionPage['items']);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) load();
  }

  @override
  Widget build(BuildContext context) => loading || error != null
      ? M5Loader(error: error, retry: load)
      : RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n(context).m5DriverHome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (equipment == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(l10n(context).m5NoAssignmentDriver),
                  ),
                )
              else ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text('${equipment!['name']}'),
                    subtitle: Text('${equipment!['model']}'),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('driverIssue'),
                  onPressed: () => open(
                    IssueFormPage(api: widget.api, equipment: equipment!),
                  ),
                  icon: const Icon(Icons.report_outlined),
                  label: Text(l10n(context).m5ReportIssue),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('driverSubmission'),
                  onPressed: () => open(
                    widget.financialMode == 'DIRECT'
                        ? ApprovalPage(
                            api: widget.api,
                            direct: true,
                            submission: {
                              'equipmentId': equipment!['id'],
                              'transactionDate': todayRiyadh(),
                            },
                          )
                        : SubmissionFormPage(
                            api: widget.api,
                            equipment: equipment!,
                          ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(
                    widget.financialMode == 'DIRECT'
                        ? l10n(context).addExpense
                        : l10n(context).m5SubmitExpense,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n(context).m5MyIssues,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (issues.isEmpty) Text(l10n(context).m5NoIssues),
                for (final issue in issues)
                  Card(
                    child: ListTile(
                      title: Text('${issue['description']}'),
                      subtitle: Text(
                        localizedDate(context, issue['reportedAt'] as String?),
                      ),
                      onTap: () => open(
                        IssueDetailPage(
                          api: widget.api,
                          id: issue['id'] as String,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              Text(
                l10n(context).m5MySubmissions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (submissions.isEmpty) Text(l10n(context).m5NoSubmissions),
              for (final item in submissions)
                Card(
                  child: ListTile(
                    title: Text(
                      item['amount'] == null
                          ? l10n(context).m5ReceiptOnly
                          : localizedMoney(context, item['amount']),
                    ),
                    subtitle: Text(
                      '${m5Status(context, item['status'])} • ${item['equipmentName']}',
                    ),
                    onTap: () => open(
                      SubmissionDetailPage(
                        api: widget.api,
                        id: item['id'] as String,
                        reviewer: false,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
}

class SubmissionFormPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  const SubmissionFormPage({
    super.key,
    required this.api,
    required this.equipment,
  });
  @override
  State<SubmissionFormPage> createState() => _SubmissionFormPageState();
}

class _SubmissionFormPageState extends State<SubmissionFormPage> {
  final amount = TextEditingController(), note = TextEditingController();
  String date = todayRiyadh(), key = requestKey();
  XFile? file;
  String? error;
  bool busy = false;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    try {
      final selected = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: l10n(context).fileTypes,
            extensions: ['jpg', 'jpeg', 'png', 'pdf'],
            mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
          ),
        ],
      );
      if (selected == null) return;
      if (await selected.length() > 10 * 1024 * 1024) {
        throw const ApiError(413, 'FILE_TOO_LARGE', '');
      }
      if (mounted) setState(() => file = selected);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  Future<void> pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(date),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (value != null) {
      setState(() => date = value.toIso8601String().split('T').first);
    }
  }

  Future<void> save() async {
    final money = amount.text.trim().isEmpty ? null : exactMoney(amount.text);
    if (amount.text.trim().isNotEmpty && money == null) {
      setState(() => error = l10n(context).uiEnterAValidAmount);
      return;
    }
    if (money == null && note.text.trim().isEmpty && file == null) {
      setState(() => error = l10n(context).m5SubmissionNeedsContent);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final receipt = file == null
          ? null
          : {
              'filename': file!.name,
              'mediaType': switch (file!.name.split('.').last.toLowerCase()) {
                'jpg' || 'jpeg' => 'image/jpeg',
                'png' => 'image/png',
                _ => 'application/pdf',
              },
              'base64': base64Encode(await file!.readAsBytes()),
            };
      await widget.api.json(
        'POST',
        widget.api.scoped('/financial-submissions'),
        key: key,
        body: {
          'equipmentId': widget.equipment['id'],
          'amount': money,
          'transactionDate': date,
          'note': note.text.trim().isEmpty ? null : note.text.trim(),
          'receipt': receipt,
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
    appBar: AppBar(title: Text(l10n(context).m5SubmitExpense)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${widget.equipment['name']}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(l10n(context).m5SubmissionHint),
        const SizedBox(height: 16),
        TextField(
          key: const Key('submissionAmount'),
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n(context).uiAmountSar),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: Text(l10n(context).m5TransactionDate),
          subtitle: Text(localizedDate(context, date)),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: pickDate,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('submissionNote'),
          controller: note,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n(context).m5Note),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('submissionReceipt'),
          onPressed: pick,
          icon: const Icon(Icons.attach_file),
          label: Text(file?.name ?? l10n(context).m5AddReceipt),
        ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('sendSubmission'),
          onPressed: busy ? null : save,
          child: Text(l10n(context).m5SendForReview),
        ),
        if (busy) const LinearProgressIndicator(),
      ],
    ),
  );
}

class ReviewQueuePage extends StatefulWidget {
  final Api api;
  const ReviewQueuePage({super.key, required this.api});
  @override
  State<ReviewQueuePage> createState() => _ReviewQueuePageState();
}

class _ReviewQueuePageState extends State<ReviewQueuePage> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String? error;
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
      final value = await widget.api.json(
        'GET',
        widget.api.scoped('/financial-submissions/review-queue?page=$page'),
      ) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          items = records(value['items']);
          total = (value['total'] as num).toInt();
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
      title: Text(l10n(context).m5ReviewQueue),
      actions: [
        IconButton(
          tooltip: l10n(context).refresh,
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading || error != null
        ? M5Loader(error: error, retry: load)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (items.isEmpty) Text(l10n(context).m5ReviewQueueEmpty),
              for (final item in items)
                Card(
                  child: ListTile(
                    key: Key('review-${item['id']}'),
                    leading: const Icon(Icons.fact_check_outlined),
                    title: Text(
                      item['amount'] == null
                          ? l10n(context).m5ReceiptOnly
                          : localizedMoney(context, item['amount']),
                    ),
                    subtitle: Text(
                      '${item['submitterName']} • ${item['equipmentName']} • ${localizedDate(context, item['transactionDate'] as String?)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmissionDetailPage(
                            api: widget.api,
                            id: item['id'] as String,
                            reviewer: true,
                          ),
                        ),
                      );
                      if (mounted) load();
                    },
                  ),
                ),
              if (page > 0 || (page + 1) * 30 < total)
                Row(
                  children: [
                    TextButton(
                      onPressed: page == 0
                          ? null
                          : () {
                              page--;
                              load();
                            },
                      child: Text(l10n(context).previous),
                    ),
                    TextButton(
                      onPressed: (page + 1) * 30 >= total
                          ? null
                          : () {
                              page++;
                              load();
                            },
                      child: Text(l10n(context).next),
                    ),
                  ],
                ),
            ],
          ),
  );
}

class SubmissionDetailPage extends StatefulWidget {
  final Api api;
  final String id;
  final bool reviewer;
  const SubmissionDetailPage({
    super.key,
    required this.api,
    required this.id,
    required this.reviewer,
  });
  @override
  State<SubmissionDetailPage> createState() => _SubmissionDetailPageState();
}

class _SubmissionDetailPageState extends State<SubmissionDetailPage> {
  Map<String, dynamic>? item;
  String? error;
  bool loading = true;
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
      final value = await widget.api.json(
        'GET',
        widget.api.scoped('/financial-submissions/${widget.id}'),
      );
      if (mounted) {
        setState(() => item = Map<String, dynamic>.from(value as Map));
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> reject() async {
    var reason = '';
    final value = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n(dialog).m5RejectSubmission),
        content: TextField(
          key: const Key('rejectionReason'),
          onChanged: (value) => reason = value,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n(dialog).m5RejectionReason,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n(dialog).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, reason.trim()),
            child: Text(l10n(dialog).m5Reject),
          ),
        ],
      ),
    );
    if (value == null) return;
    if (value.isEmpty) {
      setState(() => error = l10n(context).m5ReasonRequired);
      return;
    }
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/financial-submissions/${widget.id}/reject'),
        body: {'reason': value},
        key: requestKey(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).m5SubmissionDetails)),
    body: loading || item == null
        ? M5Loader(error: error, retry: load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${item!['equipmentName']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ListTile(
                title: Text(l10n(context).m5Status),
                subtitle: Text(m5Status(context, item!['status'])),
              ),
              ListTile(
                title: Text(l10n(context).m5SubmittedBy),
                subtitle: Text('${item!['submitterName']}'),
              ),
              if (item!['amount'] != null)
                ListTile(
                  title: Text(l10n(context).uiAmountSar),
                  subtitle: Text(localizedMoney(context, item!['amount'])),
                ),
              ListTile(
                title: Text(l10n(context).m5TransactionDate),
                subtitle: Text(
                  localizedDate(context, item!['transactionDate'] as String?),
                ),
              ),
              if (item!['note'] != null)
                ListTile(
                  title: Text(l10n(context).m5Note),
                  subtitle: Text('${item!['note']}'),
                ),
              if (item!['rejectionReason'] != null)
                ListTile(
                  title: Text(l10n(context).m5RejectionReason),
                  subtitle: Text('${item!['rejectionReason']}'),
                ),
              if (item!['approvedFinancialEntryId'] != null)
                Text(l10n(context).m5ApprovedEntryCreated),
              Text(
                l10n(context).attachments,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (records(item!['attachments']).isEmpty)
                Text(l10n(context).noAttachments),
              for (final file in records(item!['attachments']))
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text('${file['filename']}'),
                  onTap: () =>
                      openDocumentAttachment(context, widget.api, file),
                ),
              if (widget.reviewer && item!['status'] == 'PENDING_REVIEW') ...[
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('approveSubmission'),
                  onPressed: () async {
                    final approved = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ApprovalPage(api: widget.api, submission: item!),
                      ),
                    );
                    if (approved == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(l10n(context).m5Approve),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('rejectSubmission'),
                  onPressed: reject,
                  child: Text(l10n(context).m5Reject),
                ),
              ],
              if (error != null) Text(error!),
            ],
          ),
  );
}

class ApprovalPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> submission;
  final bool direct;
  const ApprovalPage({
    super.key,
    required this.api,
    required this.submission,
    this.direct = false,
  });
  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final approvalKey = requestKey();
  final amount = TextEditingController(),
      note = TextEditingController(),
      initialPaid = TextEditingController(),
      party = TextEditingController();
  String category = 'OTHER',
      status = 'FULL',
      date = todayRiyadh(),
      paidOn = todayRiyadh();
  String? dueDate, error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    amount.text = '${widget.submission['amount'] ?? ''}';
    note.text = '${widget.submission['note'] ?? ''}';
    date = widget.submission['transactionDate'] as String? ?? todayRiyadh();
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    initialPaid.dispose();
    party.dispose();
    super.dispose();
  }

  Future<void> dateSelect(bool due) async {
    final current = due ? dueDate ?? date : date;
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(current),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (value != null) {
      setState(() {
        if (due) {
          dueDate = value.toIso8601String().split('T').first;
        } else {
          date = value.toIso8601String().split('T').first;
        }
      });
    }
  }

  Future<void> approve() async {
    final total = exactMoney(amount.text);
    final paid = status == 'FULL'
        ? total
        : status == 'UNPAID'
        ? null
        : exactMoney(initialPaid.text);
    if (total == null || (status == 'PARTIAL' && paid == null)) {
      setState(() => error = l10n(context).uiEnterAValidAmount);
      return;
    }
    if (status != 'FULL' && (party.text.trim().isEmpty || dueDate == null)) {
      setState(() => error = l10n(context).m5PartyDueRequired);
      return;
    }
    if (status == 'PARTIAL' &&
        BigInt.parse(paid!.replaceAll('.', '')) >=
            BigInt.parse(total.replaceAll('.', ''))) {
      setState(() => error = l10n(context).m5PartialLessThanTotal);
      return;
    }
    if (!await m5Confirm(
      context,
      widget.direct
          ? l10n(context).m5DirectExpenseConfirm
          : l10n(context).m5ApproveConfirm,
      widget.direct ? l10n(context).save : l10n(context).m5Approve,
    )) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped(
          widget.direct
              ? '/entries'
              : '/financial-submissions/${widget.submission['id']}/approve',
        ),
        key: approvalKey,
        body: {
          'equipmentId': widget.submission['equipmentId'],
          'expenseScope': 'SINGLE',
          'entryType': 'EXPENSE',
          'amount': total,
          'category': category,
          'operationDate': date,
          'paymentStatus': status,
          'initialPaid': status == 'PARTIAL' ? paid : null,
          'paidOn': status == 'UNPAID' ? null : paidOn,
          'partyName': status == 'FULL' ? null : party.text.trim(),
          'dueDate': status == 'FULL' ? null : dueDate,
          'note': note.text.trim().isEmpty ? null : note.text.trim(),
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
        widget.direct
            ? l10n(context).addExpense
            : l10n(context).m5ApproveExpense,
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.direct
              ? l10n(context).m5DirectExpenseHint
              : l10n(context).m5ApprovalHint,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('approvalAmount'),
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n(context).uiAmountSar),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: InputDecoration(labelText: l10n(context).m5Category),
          items: [
            DropdownMenuItem(
              value: 'FUEL',
              child: Text(l10n(context).categoryFuel),
            ),
            DropdownMenuItem(
              value: 'MAINTENANCE',
              child: Text(l10n(context).categoryMaintenance),
            ),
            DropdownMenuItem(value: 'OTHER', child: Text(l10n(context).other)),
          ],
          onChanged: (value) => setState(() => category = value!),
        ),
        ListTile(
          title: Text(l10n(context).m5TransactionDate),
          subtitle: Text(localizedDate(context, date)),
          onTap: () => dateSelect(false),
        ),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: InputDecoration(labelText: l10n(context).m5PaymentStatus),
          items: [
            DropdownMenuItem(
              value: 'FULL',
              child: Text(l10n(context).paidFull),
            ),
            DropdownMenuItem(
              value: 'PARTIAL',
              child: Text(l10n(context).paidPartial),
            ),
            DropdownMenuItem(
              value: 'UNPAID',
              child: Text(l10n(context).unpaid),
            ),
          ],
          onChanged: (value) => setState(() => status = value!),
        ),
        if (status == 'PARTIAL')
          TextField(
            controller: initialPaid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n(context).uiInitialPayment,
            ),
          ),
        if (status != 'UNPAID')
          ListTile(
            title: Text(l10n(context).m5PaidOn),
            subtitle: Text(localizedDate(context, paidOn)),
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(paidOn),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (value != null) {
                setState(
                  () => paidOn = value.toIso8601String().split('T').first,
                );
              }
            },
          ),
        if (status != 'FULL') ...[
          TextField(
            controller: party,
            decoration: InputDecoration(
              labelText: l10n(context).uiSupplierOrPartyName,
            ),
          ),
          ListTile(
            title: Text(l10n(context).m5DueDate),
            subtitle: Text(
              dueDate == null
                  ? l10n(context).m5ChooseDate
                  : localizedDate(context, dueDate),
            ),
            onTap: () => dateSelect(true),
          ),
        ],
        TextField(
          controller: note,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n(context).m5Note),
        ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('confirmApproval'),
          onPressed: busy ? null : approve,
          child: Text(
            widget.direct ? l10n(context).save : l10n(context).m5Approve,
          ),
        ),
        if (busy) const LinearProgressIndicator(),
      ],
    ),
  );
}
