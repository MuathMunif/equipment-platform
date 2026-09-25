import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'file_export.dart';
import 'localization.dart';

const documentTypeCodes = [
  'REGISTRATION',
  'INSURANCE',
  'PERIODIC_INSPECTION',
  'LICENSE_PERMIT',
  'OTHER',
];

String localizedDocumentName(BuildContext context, Map<String, dynamic> doc) {
  final loc = l10n(context);
  if (doc['type'] == 'OTHER' &&
      (doc['customTypeName'] as String?)?.isNotEmpty == true) {
    return doc['customTypeName'] as String;
  }
  return switch (doc['type']) {
    'REGISTRATION' => loc.docRegistration,
    'INSURANCE' => loc.docInsurance,
    'PERIODIC_INSPECTION' => loc.docInspection,
    'LICENSE_PERMIT' => loc.docPermit,
    'OTHER' => loc.docOther,
    _ => loc.document,
  };
}

String localizedDocumentStatus(BuildContext context, Map<String, dynamic> doc) {
  final loc = l10n(context);
  return switch (doc['status']) {
    'ARCHIVED' => loc.archived,
    'PREVIOUS_VERSION' => loc.docPreviousVersion,
    'MISSING_EXPIRY' => loc.docMissingExpiry,
    'EXPIRED' => loc.docExpired,
    'EXPIRES_TODAY' => loc.docExpiresToday,
    'EXPIRING_SOON' => loc.docExpiringSoon,
    _ => loc.active,
  };
}

(String, String) localizedNotification(
  BuildContext context,
  Map<String, dynamic> item,
) {
  final loc = l10n(context);
  final template = item['templateKey'];
  final params = item['params'] is Map
      ? Map<String, dynamic>.from(item['params'] as Map)
      : <String, dynamic>{};
  final equipment = params['equipmentName'] as String? ?? '';
  final type = localizedDocumentName(context, {
    'type': params['documentType'],
    'customTypeName': params['customTypeName'],
  });
  final days = (params['daysRemaining'] as num?)?.toInt();
  final countdown = days == null
      ? loc.notificationDocumentExpiryBody
      : days < 0
      ? loc.documentExpiryPast
      : days == 0
      ? loc.documentExpiryToday
      : loc.documentExpiryInDays('$days');
  return switch (template) {
    'DOCUMENT_EXPIRY' => (
      loc.notificationDocumentExpiryTitle,
      '$type • $equipment — $countdown',
    ),
    'DOCUMENT_EXPIRED_WEEKLY' => (
      loc.notificationWeeklyTitle,
      loc.weeklyExpiredCount('${params['count'] ?? 0}'),
    ),
    _ => (
      item['title'] as String? ?? loc.notifications,
      item['body'] as String? ?? '',
    ),
  };
}

bool documentNeedsAttention(Map<String, dynamic> doc) =>
    {'EXPIRED', 'EXPIRES_TODAY', 'EXPIRING_SOON'}.contains(doc['status']);

Widget documentLoadFailure(BuildContext context, VoidCallback retry) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(l10n(context).docLoadFailed),
      TextButton(onPressed: retry, child: Text(l10n(context).retry)),
    ],
  ),
);

Future<void> openDocumentAttachment(
  BuildContext context,
  Api api,
  Map<String, dynamic> file,
) async {
  try {
    final response = await api.send(
      'GET',
      api.scoped('/attachments/${file['id']}/content'),
    );
    if (!context.mounted) return;
    if ((file['mediaType'] as String).startsWith('image/')) {
      await showDialog<void>(
        context: context,
        builder: (dialog) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(file['filename'] as String),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    tooltip: l10n(context).closeAttachment,
                    onPressed: () => Navigator.pop(dialog),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.memory(response.bodyBytes),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      await exportFile(
        response.bodyBytes,
        file['filename'] as String,
        file['mediaType'] as String,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(localizedError(context, e))));
    }
  }
}

class DocumentUpload {
  final String filename;
  final String mediaType;
  final Uint8List bytes;
  final String key = requestKey();
  String? id;
  DocumentUpload(this.filename, this.mediaType, this.bytes);
}

String documentFileType(XFile file) =>
    switch (file.name.split('.').last.toLowerCase()) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'pdf' => 'application/pdf',
      _ => throw const ApiError(
        400,
        'UNSUPPORTED_FILE',
        'اختر PNG أو JPEG أو PDF؛ حوّل HEIC إلى JPEG قبل الرفع',
      ),
    };

Future<DocumentUpload?> chooseDocumentFile(BuildContext context) async {
  final file = await openFile(
    acceptedTypeGroups: [
      XTypeGroup(
        label: l10n(context).fileTypes,
        extensions: ['jpg', 'jpeg', 'png', 'pdf'],
        mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
        uniformTypeIdentifiers: ['public.jpeg', 'public.png', 'com.adobe.pdf'],
      ),
    ],
  );
  if (file == null) return null;
  if (await file.length() > 10 * 1024 * 1024) {
    throw const ApiError(
      413,
      'FILE_TOO_LARGE',
      'اختر ملفًا لا يتجاوز 10 ميغابايت',
    );
  }
  return DocumentUpload(
    file.name,
    documentFileType(file),
    await file.readAsBytes(),
  );
}

Future<void> uploadDocumentFile(
  Api api,
  String documentId,
  String versionId,
  DocumentUpload file,
) async {
  if (file.id == null) {
    final result = await api.json(
      'POST',
      api.scoped('/documents/$documentId/versions/$versionId/attachments'),
      key: file.key,
      body: {
        'filename': file.filename,
        'mediaType': file.mediaType,
        'size': file.bytes.length,
      },
    ) as Map<String, dynamic>;
    file.id = result['id'] as String;
  }
  await api.send(
    'PUT',
    api.scoped('/attachments/${file.id}/content'),
    bytes: file.bytes,
    type: file.mediaType,
  );
}

class EquipmentDocumentsCard extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  const EquipmentDocumentsCard({
    super.key,
    required this.api,
    required this.equipment,
  });
  @override
  State<EquipmentDocumentsCard> createState() => _EquipmentDocumentsCardState();
}

class _EquipmentDocumentsCardState extends State<EquipmentDocumentsCard> {
  List<Map<String, dynamic>> docs = [];
  String? error;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    try {
      final items = await widget.api.json(
        'GET',
        widget.api.scoped('/equipment/${widget.equipment['id']}/documents'),
      ) as List<dynamic>;
      if (mounted) {
        setState(
          () => docs = items
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

  Future<void> openList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DocumentListPage(api: widget.api, equipment: widget.equipment),
      ),
    );
    if (mounted) load();
  }

  @override
  Widget build(BuildContext context) {
    final expired = docs.where((d) => d['status'] == 'EXPIRED').length;
    final near = docs
        .where(
          (d) =>
              d['status'] == 'EXPIRING_SOON' || d['status'] == 'EXPIRES_TODAY',
        )
        .length;
    final missing = docs.where((d) => d['status'] == 'MISSING_EXPIRY').length;
    final urgent = docs.where(documentNeedsAttention).toList()
      ..sort(
        (a, b) =>
            (a['expiryDate'] as String).compareTo(b['expiryDate'] as String),
      );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n(context).documents,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (loading) const LinearProgressIndicator(),
            if (error != null) ...[
              Text(l10n(context).uiCouldNotLoadDocumentsTryAgain161),
              TextButton(onPressed: load, child: Text(l10n(context).retry)),
            ],
            if (!loading && error == null) ...[
              const SizedBox(height: 8),
              if (docs.isEmpty)
                Text(l10n(context).noDocuments)
              else ...[
                Text(
                  l10n(context).documentSummary(
                    '${docs.length}',
                    '$expired',
                    '$near',
                    '$missing',
                  ),
                ),
                if (urgent.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${localizedDocumentName(context, urgent.first)} • ${localizedDocumentStatus(context, urgent.first)}',
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('openEquipmentDocuments'),
                onPressed: openList,
                icon: Icon(
                  docs.isEmpty ? Icons.add : Icons.description_outlined,
                ),
                label: Text(
                  docs.isEmpty
                      ? l10n(context).addDocument
                      : l10n(context).uiViewDocuments,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DocumentListPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  const DocumentListPage({
    super.key,
    required this.api,
    required this.equipment,
  });
  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  List<Map<String, dynamic>> current = [], archived = [];
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
      final base = '/equipment/${widget.equipment['id']}/documents';
      final active = await widget.api.json(
        'GET',
        widget.api.scoped(base),
      ) as List<dynamic>;
      final old = await widget.api.json(
        'GET',
        widget.api.scoped('$base?archived=true'),
      ) as List<dynamic>;
      if (mounted) {
        setState(() {
          current = active
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          archived = old
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DocumentFormPage(api: widget.api, equipment: widget.equipment),
      ),
    );
    if (!mounted || result == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DocumentDetailPage(api: widget.api, id: result['id'] as String),
      ),
    );
    if (mounted) load();
  }

  Future<void> open(Map<String, dynamic> doc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DocumentDetailPage(api: widget.api, id: doc['id'] as String),
      ),
    );
    if (mounted) load();
  }

  Widget section(String title, List<Map<String, dynamic>> docs) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 18),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      ...docs.map(
        (doc) => Card(
          child: ListTile(
            title: Text(localizedDocumentName(context, doc)),
            subtitle: Text(
              '${localizedDocumentStatus(context, doc)}${doc['expiryDate'] == null ? '' : ' • ${localizedDate(context, doc['expiryDate'] as String)}'}',
            ),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
            ),
            onTap: () => open(doc),
          ),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final urgent = current.where(documentNeedsAttention).toList();
    final others = current.where((d) => !documentNeedsAttention(d)).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n(context).equipmentDocumentsTitle('${widget.equipment['name']}'),
        ),
        actions: [
          IconButton(
            tooltip: l10n(context).refreshDocuments,
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!),
                  TextButton(onPressed: load, child: Text(l10n(context).retry)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton.icon(
                    key: const Key('addDocument'),
                    onPressed: add,
                    icon: const Icon(Icons.add),
                    label: Text(l10n(context).addDocument),
                  ),
                ),
                if (current.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n(context).noDocuments),
                  ),
                if (urgent.isNotEmpty)
                  section(l10n(context).uiNeedsAttention, urgent),
                if (others.isNotEmpty)
                  section(l10n(context).currentDocuments, others),
                if (archived.isNotEmpty)
                  ExpansionTile(
                    title: Text(l10n(context).uiArchivedRecords),
                    children: archived
                        .map(
                          (d) => ListTile(
                            title: Text(localizedDocumentName(context, d)),
                            subtitle: Text(l10n(context).archived),
                            onTap: () => open(d),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
    );
  }
}

class DocumentFormPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final Map<String, dynamic>? document;
  final bool renewal;
  final Future<DocumentUpload?> Function()? pickFile;
  const DocumentFormPage({
    super.key,
    required this.api,
    required this.equipment,
    this.document,
    this.renewal = false,
    this.pickFile,
  });
  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final form = GlobalKey<FormState>();
  late String type;
  late final TextEditingController custom, number, issue, expiry, notes;
  late final String saveKey;
  final List<DocumentUpload> files = [];
  Map<String, dynamic>? saved;
  bool busy = false, checkingDuplicate = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final d = widget.document;
    type = d?['type'] as String? ?? 'REGISTRATION';
    custom = TextEditingController(text: d?['customTypeName'] as String? ?? '');
    number = TextEditingController(text: d?['documentNumber'] as String? ?? '');
    issue = TextEditingController(text: d?['issueDate'] as String? ?? '');
    expiry = TextEditingController(
      text: widget.renewal ? '' : d?['expiryDate'] as String? ?? '',
    );
    notes = TextEditingController(
      text: widget.renewal ? '' : d?['notes'] as String? ?? '',
    );
    saveKey = requestKey();
  }

  @override
  void dispose() {
    custom.dispose();
    number.dispose();
    issue.dispose();
    expiry.dispose();
    notes.dispose();
    super.dispose();
  }

  String? dateError(String? value, {bool required = false}) {
    final text = normalizeDigits(value?.trim() ?? '');
    if (text.isEmpty) return required ? l10n(context).uiAddExpiryDate : null;
    try {
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
        throw const FormatException();
      }
      final parsed = DateTime.parse(text);
      if (parsed.toIso8601String().split('T').first != text) {
        throw const FormatException();
      }
      return null;
    } catch (_) {
      return l10n(context).uiEnterTheDateLike20260925;
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    final initial =
        DateTime.tryParse(normalizeDigits(controller.text)) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (date != null) {
      controller.text =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> addFile() async {
    try {
      final file = await (widget.pickFile != null
          ? widget.pickFile!()
          : chooseDocumentFile(context));
      if (file != null && mounted) {
        setState(() {
          files.add(file);
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  Map<String, dynamic> payload() => {
    if (!widget.renewal) 'type': type,
    if (!widget.renewal)
      'customTypeName': type == 'OTHER' ? custom.text.trim() : null,
    'documentNumber': number.text.trim().isEmpty ? null : number.text.trim(),
    'issueDate': issue.text.trim().isEmpty
        ? null
        : normalizeDigits(issue.text.trim()),
    'expiryDate': expiry.text.trim().isEmpty
        ? null
        : normalizeDigits(expiry.text.trim()),
    'notes': notes.text.trim(),
  };
  Future<bool> duplicateWarning() async {
    if (widget.document != null || checkingDuplicate) return true;
    setState(() => checkingDuplicate = true);
    try {
      final params = {
        'type': type,
        if (type == 'OTHER') 'customTypeName': custom.text.trim(),
      };
      final matches = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/equipment/${widget.equipment['id']}/documents/duplicates?${Uri(queryParameters: params).query}',
        ),
      ) as List<dynamic>;
      if (!mounted || matches.isEmpty) return true;
      final choice = await showDialog<String>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l10n(context).documentTypeExists),
          content: Text(
            l10n(context).documentAlreadyExists(
              localizedDocumentName(
                context,
                Map<String, dynamic>.from(matches.first as Map),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, 'cancel'),
              child: Text(l10n(context).back),
            ),
            TextButton(
              key: const Key('addSeparateDocument'),
              onPressed: () => Navigator.pop(dialog, 'separate'),
              child: Text(l10n(context).uiAddSeparateDocument),
            ),
            FilledButton(
              key: const Key('renewExistingDocument'),
              onPressed: () => Navigator.pop(dialog, 'renew'),
              child: Text(l10n(context).uiRenewCurrentDocument),
            ),
          ],
        ),
      );
      if (!mounted) return false;
      if (choice == 'renew') {
        final existing = Map<String, dynamic>.from(matches.first as Map);
        final renewed = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentFormPage(
              api: widget.api,
              equipment: widget.equipment,
              document: existing,
              renewal: true,
            ),
          ),
        );
        if (renewed != null && mounted) Navigator.pop(context, renewed);
        return false;
      }
      return choice == 'separate';
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
      return false;
    } finally {
      if (mounted) setState(() => checkingDuplicate = false);
    }
  }

  Future<void> save() async {
    if (!(form.currentState?.validate() ?? false)) return;
    if (issue.text.trim().isNotEmpty &&
        expiry.text.trim().isNotEmpty &&
        normalizeDigits(issue.text.trim())
                .compareTo(normalizeDigits(expiry.text.trim())) >
            0) {
      setState(() => error = l10n(context).uiIssueDateIsAfterExpiryDate);
      return;
    }
    if (saved == null && !await duplicateWarning()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (saved == null) {
        final id = widget.document?['id'] as String?;
        final path = widget.renewal
            ? '/documents/$id/renewals'
            : id != null
            ? '/documents/$id'
            : '/equipment/${widget.equipment['id']}/documents';
        final body = payload();
        if (widget.renewal || id != null) {
          body['expectedVersionId'] = widget.document!['currentVersionId'];
        }
        saved = await widget.api.json(
          widget.renewal || id == null ? 'POST' : 'PUT',
          widget.api.scoped(path),
          body: body,
          key: id == null && !widget.renewal ? saveKey : null,
        ) as Map<String, dynamic>;
      }
      for (final file in files) {
        await uploadDocumentFile(
          widget.api,
          saved!['id'] as String,
          saved!['versionId'] as String,
          file,
        );
      }
      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.document != null && !widget.renewal;
    final locked = edit && (widget.document!['versionNumber'] as int? ?? 1) > 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.renewal
              ? l10n(context).renewDocument
              : edit
              ? l10n(context).uiEditDocument
              : l10n(context).addDocument,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Form(
            key: form,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (widget.renewal)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        l10n(context).uiThePreviousDocumentWillBeKeptIn,
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    key: const Key('documentType'),
                    initialValue: type,
                    decoration: InputDecoration(
                      labelText: l10n(context).documentType,
                    ),
                    items: documentTypeCodes
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e == 'OTHER'
                                  ? l10n(context).other
                                  : localizedDocumentName(context, {'type': e}),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.renewal || locked || saved != null
                        ? null
                        : (value) => setState(() => type = value!),
                  ),
                  if (type == 'OTHER') ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('customDocumentName'),
                      controller: custom,
                      enabled: !widget.renewal && !locked && saved == null,
                      decoration: InputDecoration(
                        labelText: l10n(context).uiDocumentName,
                      ),
                      maxLength: 100,
                      validator: (_) =>
                          type == 'OTHER' && custom.text.trim().isEmpty
                          ? l10n(context).uiEnterDocumentName
                          : null,
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: number,
                    decoration: InputDecoration(
                      labelText: l10n(context).uiDocumentNumberOptional,
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('documentIssueDate'),
                          controller: issue,
                          decoration: InputDecoration(
                            labelText: l10n(context).uiIssueDateOptional,
                            hintText: '2026-09-25',
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: dateError,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n(context).uiSelectIssueDate,
                        onPressed: () => pickDate(issue),
                        icon: const Icon(Icons.event),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('documentExpiryDate'),
                          controller: expiry,
                          decoration: InputDecoration(
                            labelText: widget.renewal
                                ? l10n(context).newExpiryDate
                                : l10n(context).uiExpiryDateOptional,
                            hintText: '2026-09-25',
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (v) =>
                              dateError(v, required: widget.renewal),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n(context).uiSelectExpiryDate,
                        onPressed: () => pickDate(expiry),
                        icon: const Icon(Icons.event),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: notes,
                    decoration: InputDecoration(
                      labelText: l10n(context).uiNoteOptional,
                    ),
                    maxLength: 1000,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('selectDocumentAttachment'),
                    onPressed: busy || files.length >= 10 ? null : addFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(l10n(context).uiAddImageOrPdf),
                  ),
                  ...files.map(
                    (f) => ListTile(
                      title: Text(f.filename),
                      subtitle: Text(
                        f.id == null
                            ? l10n(context).uiReadyToUpload
                            : l10n(context).uiReadyToRetryUpload,
                      ),
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  FilledButton(
                    key: const Key('saveDocument'),
                    onPressed: busy ? null : save,
                    child: Text(
                      busy
                          ? l10n(context).uiSaving
                          : saved != null
                          ? l10n(context).uiRetryUploadingAttachments
                          : widget.renewal
                          ? l10n(context).renewDocument
                          : l10n(context).saveDocument,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentDetailPage extends StatefulWidget {
  final Api api;
  final String id;
  final Future<DocumentUpload?> Function()? pickFile;
  const DocumentDetailPage({
    super.key,
    required this.api,
    required this.id,
    this.pickFile,
  });
  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  Map<String, dynamic>? doc, equipment;
  List<Map<String, dynamic>> attachments = [];
  DocumentUpload? upload;
  bool loading = true, busy = false;
  String? error, uploadError;
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
        widget.api.scoped('/documents/${widget.id}'),
      ) as Map<String, dynamic>;
      final eq = await widget.api.json(
        'GET',
        widget.api.scoped('/equipment/${result['equipmentId']}'),
      ) as Map<String, dynamic>;
      final files = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/documents/${widget.id}/versions/${result['versionId']}/attachments',
        ),
      ) as List<dynamic>;
      if (mounted) {
        setState(() {
          doc = result;
          equipment = eq;
          attachments = files
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> edit({bool renewal = false}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentFormPage(
          api: widget.api,
          equipment: equipment!,
          document: doc!,
          renewal: renewal,
        ),
      ),
    );
    if (result != null && mounted) load();
  }

  Future<void> archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n(context).uiArchiveDocument005),
        content: Text(l10n(context).uiThisDocumentWillNoLongerAppearAmong),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n(context).back),
          ),
          FilledButton(
            key: const Key('confirmDocumentArchive'),
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n(context).archive),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await action('archive');
  }

  Future<void> action(String name) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/documents/${widget.id}/$name'),
      );
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> addAttachment() async {
    try {
      final selected = await (widget.pickFile != null
          ? widget.pickFile!()
          : chooseDocumentFile(context));
      if (selected == null) return;
      upload = selected;
      await retryUpload();
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
    }
  }

  Future<void> retryUpload() async {
    if (upload == null || doc == null) return;
    setState(() {
      busy = true;
      uploadError = null;
    });
    try {
      await uploadDocumentFile(
        widget.api,
        widget.id,
        doc!['versionId'] as String,
        upload!,
      );
      upload = null;
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = doc;
    final archived = d?['archivedAt'] != null;
    final expired = d?['status'] == 'EXPIRED';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          d == null
              ? l10n(context).uiDocument
              : localizedDocumentName(context, d),
        ),
        actions: [
          IconButton(
            tooltip: l10n(context).uiUpdateDocument,
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && d == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!),
                  TextButton(onPressed: load, child: Text(l10n(context).retry)),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      equipment?['name'] as String? ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedDocumentName(context, d!),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(localizedDocumentStatus(context, d)),
                            const SizedBox(height: 8),
                            Text(
                              d['expiryDate'] == null
                                  ? l10n(context).docMissingExpiry
                                  : l10n(context).expiryValue(
                                      localizedDate(
                                        context,
                                        d['expiryDate'] as String,
                                      ),
                                    ),
                            ),
                            if (d['documentNumber'] != null)
                              Text(
                                l10n(context)
                                    .numberValue('${d['documentNumber']}'),
                              ),
                            if (d['issueDate'] != null)
                              Text(
                                l10n(context).issueDateValue(
                                  localizedDate(
                                    context,
                                    d['issueDate'] as String,
                                  ),
                                ),
                              ),
                            if ((d['notes'] as String? ?? '').isNotEmpty)
                              Text(l10n(context).noteValue('${d['notes']}')),
                          ],
                        ),
                      ),
                    ),
                    if (error != null)
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (!archived) ...[
                      if (expired)
                        FilledButton.icon(
                          key: const Key('renewDocument'),
                          onPressed: busy ? null : () => edit(renewal: true),
                          icon: const Icon(Icons.autorenew),
                          label: Text(l10n(context).renewDocument),
                        ),
                      if (expired) const SizedBox(height: 8),
                      OutlinedButton.icon(
                        key: const Key('editDocument'),
                        onPressed: busy ? null : () => edit(),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n(context).edit),
                      ),
                      if (!expired) const SizedBox(height: 8),
                      if (!expired)
                        FilledButton.icon(
                          key: const Key('renewDocument'),
                          onPressed: busy ? null : () => edit(renewal: true),
                          icon: const Icon(Icons.autorenew),
                          label: Text(l10n(context).renewDocument),
                        ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        key: const Key('archiveDocument'),
                        onPressed: busy ? null : archive,
                        icon: const Icon(Icons.archive_outlined),
                        label: Text(l10n(context).uiArchiveDocument),
                      ),
                    ] else if (d['equipmentArchived'] != true)
                      FilledButton(
                        key: const Key('restoreDocument'),
                        onPressed: busy ? null : () => action('restore'),
                        child: Text(l10n(context).restoreDocument),
                      )
                    else
                      Text(
                        l10n(context)
                            .uiRestoreTheEquipmentBeforeRestoringThisDocument,
                      ),
                    const SizedBox(height: 24),
                    Text(
                      l10n(context).attachments,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (attachments.isEmpty) Text(l10n(context).noAttachments),
                    ...attachments.map(
                      (f) => ListTile(
                        title: Text(f['filename'] as String),
                        subtitle: Text(
                          f['state'] == 'READY'
                              ? l10n(context).uiReadyToView
                              : f['state'] == 'FAILED'
                              ? l10n(context).uiUploadFailed
                              : l10n(context).uiUploadIncomplete,
                        ),
                        onTap: f['state'] == 'READY'
                            ? () =>
                                  openDocumentAttachment(context, widget.api, f)
                            : null,
                      ),
                    ),
                    if (!archived)
                      OutlinedButton.icon(
                        key: const Key('addDocumentAttachment'),
                        onPressed: busy ? null : addAttachment,
                        icon: const Icon(Icons.attach_file),
                        label: Text(l10n(context).uiAddAttachment),
                      ),
                    if (upload != null && uploadError != null)
                      TextButton(
                        key: const Key('retryDocumentAttachment'),
                        onPressed: busy ? null : retryUpload,
                        child: Text(l10n(context).uiRetryFileUpload),
                      ),
                    if (uploadError != null)
                      Text(
                        uploadError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      key: const Key('documentHistory'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentHistoryPage(
                            api: widget.api,
                            documentId: widget.id,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.history),
                      label: Text(l10n(context).previousVersions),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class DocumentHistoryPage extends StatefulWidget {
  final Api api;
  final String documentId;
  const DocumentHistoryPage({
    super.key,
    required this.api,
    required this.documentId,
  });
  @override
  State<DocumentHistoryPage> createState() => _DocumentHistoryPageState();
}

class _DocumentHistoryPageState extends State<DocumentHistoryPage> {
  List<Map<String, dynamic>> versions = [];
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
      final data = await widget.api.json(
        'GET',
        widget.api.scoped('/documents/${widget.documentId}/versions'),
      ) as List<dynamic>;
      if (mounted) {
        setState(
          () => versions = data
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).previousVersions)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? documentLoadFailure(context, load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (versions.length <= 1)
                Text(l10n(context).uiNoPreviousVersionsYet),
              ...versions
                  .where((v) => v['status'] == 'PREVIOUS_VERSION')
                  .map(
                    (v) => Card(
                      child: ListTile(
                        title: Text(
                          l10n(context).versionNumber('${v['versionNumber']}'),
                        ),
                        subtitle: Text(
                          '${l10n(context).versionExpiry(v['expiryDate'] == null ? l10n(context).uiNoExpiryDate : localizedDate(context, v['expiryDate'] as String))}${v['issueDate'] == null ? '' : ' • ${l10n(context).versionIssue(localizedDate(context, v['issueDate'] as String))}'}',
                        ),
                        trailing: Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentVersionPage(
                              api: widget.api,
                              documentId: widget.documentId,
                              versionId: v['versionId'] as String,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
  );
}

class DocumentVersionPage extends StatefulWidget {
  final Api api;
  final String documentId, versionId;
  const DocumentVersionPage({
    super.key,
    required this.api,
    required this.documentId,
    required this.versionId,
  });
  @override
  State<DocumentVersionPage> createState() => _DocumentVersionPageState();
}

class _DocumentVersionPageState extends State<DocumentVersionPage> {
  Map<String, dynamic>? version;
  List<Map<String, dynamic>> attachments = [];
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
      final d = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/documents/${widget.documentId}/versions/${widget.versionId}',
        ),
      ) as Map<String, dynamic>;
      final files = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/documents/${widget.documentId}/versions/${widget.versionId}/attachments',
        ),
      ) as List<dynamic>;
      if (mounted) {
        setState(() {
          version = d;
          attachments = files
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
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
    appBar: AppBar(title: Text(l10n(context).docPreviousVersion)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? documentLoadFailure(context, load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n(context).uiPreviousVersionIsViewOnly),
              const SizedBox(height: 16),
              Text(
                localizedDocumentName(context, version!),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                l10n(context)
                    .versionNumberLabel('${version!['versionNumber']}'),
              ),
              if (version!['documentNumber'] != null)
                Text(
                  l10n(context)
                      .documentNumberLabel('${version!['documentNumber']}'),
                ),
              if (version!['issueDate'] != null)
                Text(
                  l10n(context).issueDateValue(
                    localizedDate(context, version!['issueDate'] as String),
                  ),
                ),
              Text(
                version!['expiryDate'] == null
                    ? l10n(context).docMissingExpiry
                    : l10n(context).expiryDateValue(
                        localizedDate(
                          context,
                          version!['expiryDate'] as String,
                        ),
                      ),
              ),
              if ((version!['notes'] as String? ?? '').isNotEmpty)
                Text(l10n(context).noteValue('${version!['notes']}')),
              const SizedBox(height: 20),
              Text(
                l10n(context).versionAttachments,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (attachments.isEmpty) Text(l10n(context).noAttachmentsShort),
              ...attachments.map(
                (f) => ListTile(
                  title: Text(f['filename'] as String),
                  onTap: f['state'] == 'READY'
                      ? () => openDocumentAttachment(context, widget.api, f)
                      : null,
                ),
              ),
            ],
          ),
  );
}

class HomeDocumentAttention extends StatefulWidget {
  final Api api;
  const HomeDocumentAttention({super.key, required this.api});
  @override
  State<HomeDocumentAttention> createState() => _HomeDocumentAttentionState();
}

class _HomeDocumentAttentionState extends State<HomeDocumentAttention> {
  List<Map<String, dynamic>> items = [], incomplete = [];
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
      final attention = await widget.api.json(
        'GET',
        widget.api.scoped('/attention/documents'),
      ) as List<dynamic>;
      final missing = await widget.api.json(
        'GET',
        widget.api.scoped('/documents/incomplete'),
      ) as List<dynamic>;
      if (mounted) {
        setState(() {
          items = attention
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          incomplete = missing
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
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
            l10n(context).uiNeedsAttention,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            TextButton(
              onPressed: load,
              child: Text(l10n(context).uiCouldNotLoadDocumentsTryAgain),
            ),
          if (!loading && error == null) ...[
            if (items.isEmpty)
              Text(l10n(context).uiNoDocumentsNeedAttentionNow),
            ...items
                .take(3)
                .map(
                  (d) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localizedDocumentName(context, d)),
                    subtitle: Text('${d['equipmentName']} • ${d['body']}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentDetailPage(
                          api: widget.api,
                          id: d['documentId'] as String,
                        ),
                      ),
                    ),
                  ),
                ),
            if (items.isNotEmpty)
              TextButton(
                key: const Key('openAttention'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttentionPage(api: widget.api),
                  ),
                ),
                child: Text(l10n(context).viewAll),
              ),
            const Divider(),
            Text(
              l10n(context).uiDetailsToComplete,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              incomplete.isEmpty
                  ? l10n(context).uiNoDocumentsHaveMissingInformation
                  : l10n(context).missingDocumentsCount('${incomplete.length}'),
            ),
            if (incomplete.isNotEmpty)
              TextButton(
                key: const Key('openIncompleteDocuments'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncompleteDocumentsPage(api: widget.api),
                  ),
                ),
                child: Text(l10n(context).uiViewDocuments),
              ),
          ],
        ],
      ),
    ),
  );
}

class AttentionPage extends StatefulWidget {
  final Api api;
  const AttentionPage({super.key, required this.api});
  @override
  State<AttentionPage> createState() => _AttentionPageState();
}

class _AttentionPageState extends State<AttentionPage> {
  List<Map<String, dynamic>> items = [];
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
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/attention/documents'),
      ) as List<dynamic>;
      if (mounted) {
        setState(
          () => items = result
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).uiNeedsAttention),
      actions: [
        IconButton(
          tooltip: l10n(context).update,
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? documentLoadFailure(context, load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (items.isEmpty)
                Text(l10n(context).uiNoDocumentsNeedAttentionNow),
              ...items.map(
                (d) => Card(
                  child: ListTile(
                    title: Text(localizedDocumentName(context, d)),
                    subtitle: Text('${d['equipmentName']} • ${d['body']}'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentDetailPage(
                            api: widget.api,
                            id: d['documentId'] as String,
                          ),
                        ),
                      );
                      if (context.mounted) load();
                    },
                  ),
                ),
              ),
            ],
          ),
  );
}

class IncompleteDocumentsPage extends StatefulWidget {
  final Api api;
  const IncompleteDocumentsPage({super.key, required this.api});
  @override
  State<IncompleteDocumentsPage> createState() =>
      _IncompleteDocumentsPageState();
}

class _IncompleteDocumentsPageState extends State<IncompleteDocumentsPage> {
  List<Map<String, dynamic>> items = [];
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
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/documents/incomplete'),
      ) as List<dynamic>;
      if (mounted) {
        setState(
          () => items = result
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

  Future<void> addExpiry(Map<String, dynamic> document) async {
    try {
      final equipment = await widget.api.json(
        'GET',
        widget.api.scoped('/equipment/${document['equipmentId']}'),
      ) as Map<String, dynamic>;
      if (!mounted) return;
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentFormPage(
            api: widget.api,
            equipment: equipment,
            document: document,
          ),
        ),
      );
      if (result != null && mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).uiDetailsToComplete),
      actions: [
        IconButton(
          tooltip: l10n(context).update,
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? documentLoadFailure(context, load)
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (items.isEmpty)
                Text(l10n(context).uiNoDocumentsHaveMissingInformation),
              ...items.map(
                (d) => Card(
                  child: ListTile(
                    title: Text(localizedDocumentName(context, d)),
                    subtitle: Text(l10n(context).docMissingExpiry),
                    trailing: TextButton(
                      key: Key('addExpiry-${d['id']}'),
                      onPressed: () => addExpiry(d),
                      child: Text(l10n(context).addExpiryDate),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentDetailPage(
                            api: widget.api,
                            id: d['id'] as String,
                          ),
                        ),
                      );
                      if (context.mounted) load();
                    },
                  ),
                ),
              ),
            ],
          ),
  );
}

class NotificationButton extends StatefulWidget {
  final Api api;
  const NotificationButton({super.key, required this.api});
  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  int unread = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/notifications/unread-count'),
      ) as Map<String, dynamic>;
      if (mounted) setState(() => unread = result['unreadCount'] as int);
    } catch (_) {
      /* Other screens still show their own retry state. */
    }
  }

  Future<void> open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationCenterPage(api: widget.api),
      ),
    );
    if (mounted) load();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    key: const Key('openNotifications'),
    tooltip: unread == 0
        ? l10n(context).notifications
        : l10n(context).unreadNotifications(unread),
    onPressed: open,
    icon: Badge(
      isLabelVisible: unread > 0,
      label: Text('$unread'),
      child: const Icon(Icons.notifications_outlined),
    ),
  );
}

class NotificationCenterPage extends StatefulWidget {
  final Api api;
  const NotificationCenterPage({super.key, required this.api});
  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  List<Map<String, dynamic>> items = [];
  int page = 0, total = 0;
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
        widget.api.scoped('/notifications?page=$page'),
      ) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          items = (result['items'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          total = result['total'] as int;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> read(Map<String, dynamic> item) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (item['readAt'] == null) {
        await widget.api.json(
          'POST',
          widget.api.scoped('/notifications/${item['id']}/read'),
        );
      }
      if (!mounted) return;
      if (item['entityType'] == 'DOCUMENT' && item['entityId'] != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentDetailPage(
              api: widget.api,
              id: item['entityId'] as String,
            ),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AttentionPage(api: widget.api)),
        );
      }
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> readAll() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.json(
        'POST',
        widget.api.scoped('/notifications/read-all'),
      );
      if (mounted) load();
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).notifications),
      actions: [
        TextButton(
          key: const Key('markAllNotificationsRead'),
          onPressed: busy ? null : readAll,
          child: Text(l10n(context).markAllRead),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null && items.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error!),
                TextButton(onPressed: load, child: Text(l10n(context).retry)),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (items.isEmpty) Text(l10n(context).noNotifications),
              ...items.map(
                (item) => Card(
                  child: ListTile(
                    leading: Icon(
                      item['readAt'] == null
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_none,
                    ),
                    title: Text(
                      localizedNotification(context, item).$1,
                      style: TextStyle(
                        fontWeight: item['readAt'] == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(localizedNotification(context, item).$2),
                    trailing: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                    ),
                    onTap: busy ? null : () => read(item),
                  ),
                ),
              ),
              if (total > 30)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text('${page + 1}'),
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
