import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'file_export.dart';

const documentNames = <String, String>{
  'REGISTRATION': 'الاستمارة',
  'INSURANCE': 'التأمين',
  'PERIODIC_INSPECTION': 'الفحص الدوري',
  'LICENSE_PERMIT': 'ترخيص / تصريح',
  'OTHER': 'أخرى',
};

String documentName(Map<String, dynamic> doc) => doc['type'] == 'OTHER'
    ? (doc['customTypeName'] as String? ?? 'مستند آخر')
    : documentNames[doc['type']] ?? 'مستند';

String documentStatus(Map<String, dynamic> doc) => switch (doc['status']) {
  'ARCHIVED' => 'مؤرشف',
  'PREVIOUS_VERSION' => 'نسخة سابقة',
  'MISSING_EXPIRY' => 'تاريخ الانتهاء غير مضاف',
  'EXPIRED' => 'منتهي',
  'EXPIRES_TODAY' => 'ينتهي اليوم',
  'EXPIRING_SOON' => 'ينتهي قريبًا',
  _ => 'ساري',
};

bool documentNeedsAttention(Map<String, dynamic> doc) =>
    {'EXPIRED', 'EXPIRES_TODAY', 'EXPIRING_SOON'}.contains(doc['status']);

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
                    tooltip: 'إغلاق المرفق',
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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

Future<DocumentUpload?> chooseDocumentFile() async {
  final file = await openFile(
    acceptedTypeGroups: [
      const XTypeGroup(
        label: 'صور وملفات PDF',
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
      if (mounted) setState(() => error = '$e');
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
            Text('المستندات', style: Theme.of(context).textTheme.titleLarge),
            if (loading) const LinearProgressIndicator(),
            if (error != null) ...[
              Text(error!),
              TextButton(onPressed: load, child: const Text('إعادة المحاولة')),
            ],
            if (!loading && error == null) ...[
              const SizedBox(height: 8),
              if (docs.isEmpty)
                const Text('لم تضف مستندات لهذه المعدة بعد')
              else ...[
                Text(
                  '${docs.length} مستندات • $expired منتهي • $near ينتهي قريبًا • $missing بدون تاريخ انتهاء',
                ),
                if (urgent.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${documentName(urgent.first)} • ${documentStatus(urgent.first)}',
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
                label: Text(docs.isEmpty ? 'إضافة مستند' : 'عرض المستندات'),
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
      if (mounted) setState(() => error = '$e');
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
            title: Text(documentName(doc)),
            subtitle: Text(
              '${documentStatus(doc)}${doc['expiryDate'] == null ? '' : ' • ${doc['expiryDate']}'}',
            ),
            trailing: const Icon(Icons.chevron_left),
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
        title: Text('مستندات ${widget.equipment['name']}'),
        actions: [
          IconButton(
            tooltip: 'تحديث المستندات',
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
                  TextButton(
                    onPressed: load,
                    child: const Text('إعادة المحاولة'),
                  ),
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
                    label: const Text('إضافة مستند'),
                  ),
                ),
                if (current.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('لم تضف مستندات لهذه المعدة بعد'),
                  ),
                if (urgent.isNotEmpty) section('يحتاج انتباه', urgent),
                if (others.isNotEmpty) section('المستندات الحالية', others),
                if (archived.isNotEmpty)
                  ExpansionTile(
                    title: const Text('السجل المؤرشف'),
                    children: archived
                        .map(
                          (d) => ListTile(
                            title: Text(documentName(d)),
                            subtitle: const Text('مؤرشف'),
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
    if (text.isEmpty) return required ? 'أضف تاريخ الانتهاء' : null;
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
      return 'اكتب التاريخ بهذا الشكل: 2026-09-25';
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
      final file = await (widget.pickFile ?? chooseDocumentFile)();
      if (file != null && mounted) {
        setState(() {
          files.add(file);
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
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
          title: const Text('يوجد مستند من هذا النوع'),
          content: Text(
            'يوجد ${documentName(Map<String, dynamic>.from(matches.first as Map))} حالي لهذه المعدة. هل تريد تجديده بدل إضافة مستند منفصل؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, 'cancel'),
              child: const Text('رجوع'),
            ),
            TextButton(
              key: const Key('addSeparateDocument'),
              onPressed: () => Navigator.pop(dialog, 'separate'),
              child: const Text('إضافة مستند منفصل'),
            ),
            FilledButton(
              key: const Key('renewExistingDocument'),
              onPressed: () => Navigator.pop(dialog, 'renew'),
              child: const Text('تجديد الحالي'),
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
      if (mounted) setState(() => error = '$e');
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
      setState(() => error = 'تاريخ الإصدار بعد تاريخ الانتهاء');
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
        if (widget.renewal) {
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
      if (mounted) setState(() => error = '$e');
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
              ? 'تجديد المستند'
              : edit
              ? 'تعديل المستند'
              : 'إضافة مستند',
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
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'سيُحفظ المستند السابق في السجل. أضف تاريخ انتهاء جديدًا للمستند المجدد.',
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    key: const Key('documentType'),
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'نوع المستند'),
                    items: documentNames.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
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
                      decoration: const InputDecoration(
                        labelText: 'اسم المستند',
                      ),
                      maxLength: 100,
                      validator: (_) =>
                          type == 'OTHER' && custom.text.trim().isEmpty
                          ? 'اكتب اسم المستند'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: number,
                    decoration: const InputDecoration(
                      labelText: 'رقم المستند (اختياري)',
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
                          decoration: const InputDecoration(
                            labelText: 'تاريخ الإصدار (اختياري)',
                            hintText: '2026-09-25',
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: dateError,
                        ),
                      ),
                      IconButton(
                        tooltip: 'اختر تاريخ الإصدار',
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
                                ? 'تاريخ الانتهاء الجديد'
                                : 'تاريخ الانتهاء (اختياري)',
                            hintText: '2026-09-25',
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (v) =>
                              dateError(v, required: widget.renewal),
                        ),
                      ),
                      IconButton(
                        tooltip: 'اختر تاريخ الانتهاء',
                        onPressed: () => pickDate(expiry),
                        icon: const Icon(Icons.event),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظة (اختياري)',
                    ),
                    maxLength: 1000,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('selectDocumentAttachment'),
                    onPressed: busy || files.length >= 10 ? null : addFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('إضافة صورة أو PDF'),
                  ),
                  ...files.map(
                    (f) => ListTile(
                      title: Text(f.filename),
                      subtitle: Text(
                        f.id == null
                            ? 'جاهز للرفع'
                            : 'جاهز لإعادة محاولة الرفع',
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
                          ? 'جارٍ الحفظ...'
                          : saved != null
                          ? 'إعادة محاولة رفع المرفقات'
                          : widget.renewal
                          ? 'تجديد المستند'
                          : 'حفظ المستند',
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
      if (mounted) setState(() => error = '$e');
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
        title: const Text('أرشفة المستند؟'),
        content: const Text(
          'لن يظهر المستند ضمن المستندات الحالية ولن تصلك تنبيهات انتهاء خاصة به. سيبقى محفوظًا في السجل.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            key: const Key('confirmDocumentArchive'),
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('أرشفة'),
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
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> addAttachment() async {
    try {
      final selected = await (widget.pickFile ?? chooseDocumentFile)();
      if (selected == null) return;
      upload = selected;
      await retryUpload();
    } catch (e) {
      if (mounted) setState(() => uploadError = '$e');
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
      if (mounted) setState(() => uploadError = '$e');
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
        title: Text(d == null ? 'المستند' : documentName(d)),
        actions: [
          IconButton(
            tooltip: 'تحديث المستند',
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
                  TextButton(
                    onPressed: load,
                    child: const Text('إعادة المحاولة'),
                  ),
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
                              documentName(d!),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(documentStatus(d)),
                            const SizedBox(height: 8),
                            Text(
                              d['expiryDate'] == null
                                  ? 'تاريخ الانتهاء غير مضاف'
                                  : 'ينتهي في ${d['expiryDate']}',
                            ),
                            if (d['documentNumber'] != null)
                              Text('الرقم: ${d['documentNumber']}'),
                            if (d['issueDate'] != null)
                              Text('تاريخ الإصدار: ${d['issueDate']}'),
                            if ((d['notes'] as String? ?? '').isNotEmpty)
                              Text('ملاحظة: ${d['notes']}'),
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
                          label: const Text('تجديد المستند'),
                        ),
                      if (expired) const SizedBox(height: 8),
                      OutlinedButton.icon(
                        key: const Key('editDocument'),
                        onPressed: busy ? null : () => edit(),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('تعديل'),
                      ),
                      if (!expired) const SizedBox(height: 8),
                      if (!expired)
                        FilledButton.icon(
                          key: const Key('renewDocument'),
                          onPressed: busy ? null : () => edit(renewal: true),
                          icon: const Icon(Icons.autorenew),
                          label: const Text('تجديد المستند'),
                        ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        key: const Key('archiveDocument'),
                        onPressed: busy ? null : archive,
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('أرشفة المستند'),
                      ),
                    ] else if (d['equipmentArchived'] != true)
                      FilledButton(
                        key: const Key('restoreDocument'),
                        onPressed: busy ? null : () => action('restore'),
                        child: const Text('استعادة المستند'),
                      )
                    else
                      const Text('استعد المعدة أولًا لاستعادة المستند.'),
                    const SizedBox(height: 24),
                    Text(
                      'المرفقات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (attachments.isEmpty) const Text('لا توجد مرفقات بعد'),
                    ...attachments.map(
                      (f) => ListTile(
                        title: Text(f['filename'] as String),
                        subtitle: Text(
                          f['state'] == 'READY'
                              ? 'جاهز للعرض'
                              : f['state'] == 'FAILED'
                              ? 'تعثر الرفع'
                              : 'لم يكتمل الرفع',
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
                        label: const Text('إضافة مرفق'),
                      ),
                    if (upload != null && uploadError != null)
                      TextButton(
                        key: const Key('retryDocumentAttachment'),
                        onPressed: busy ? null : retryUpload,
                        child: const Text('إعادة محاولة رفع الملف'),
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
                      label: const Text('النسخ السابقة'),
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
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('النسخ السابقة')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (versions.length <= 1) const Text('لا توجد نسخ سابقة بعد'),
              ...versions
                  .where((v) => v['status'] == 'PREVIOUS_VERSION')
                  .map(
                    (v) => Card(
                      child: ListTile(
                        title: Text('النسخة ${v['versionNumber']}'),
                        subtitle: Text(
                          'انتهاء: ${v['expiryDate'] ?? 'بدون تاريخ انتهاء'}${v['issueDate'] == null ? '' : ' • إصدار: ${v['issueDate']}'}',
                        ),
                        trailing: const Icon(Icons.chevron_left),
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
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('نسخة سابقة')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('نسخة سابقة للعرض فقط'),
              const SizedBox(height: 16),
              Text(
                documentName(version!),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('رقم النسخة: ${version!['versionNumber']}'),
              if (version!['documentNumber'] != null)
                Text('رقم المستند: ${version!['documentNumber']}'),
              if (version!['issueDate'] != null)
                Text('تاريخ الإصدار: ${version!['issueDate']}'),
              Text(
                version!['expiryDate'] == null
                    ? 'تاريخ الانتهاء غير مضاف'
                    : 'تاريخ الانتهاء: ${version!['expiryDate']}',
              ),
              if ((version!['notes'] as String? ?? '').isNotEmpty)
                Text('ملاحظة: ${version!['notes']}'),
              const SizedBox(height: 20),
              Text(
                'مرفقات هذه النسخة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (attachments.isEmpty) const Text('لا توجد مرفقات'),
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
      if (mounted) setState(() => error = '$e');
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
          Text('يحتاج انتباه', style: Theme.of(context).textTheme.titleLarge),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            TextButton(
              onPressed: load,
              child: Text('تعذر تحميل المستندات • إعادة المحاولة'),
            ),
          if (!loading && error == null) ...[
            if (items.isEmpty) const Text('لا توجد مستندات تحتاج انتباه الآن'),
            ...items
                .take(3)
                .map(
                  (d) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      d['type'] == 'OTHER'
                          ? d['customTypeName'] as String? ?? 'مستند'
                          : documentNames[d['type']] ?? 'مستند',
                    ),
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
                child: const Text('عرض الكل'),
              ),
            const Divider(),
            Text(
              'بيانات تحتاج استكمال',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              incomplete.isEmpty
                  ? 'لا توجد مستندات ناقصة البيانات'
                  : '${incomplete.length} مستند بدون تاريخ انتهاء',
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
                child: const Text('عرض المستندات'),
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
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('يحتاج انتباه'),
      actions: [
        IconButton(
          tooltip: 'تحديث',
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (items.isEmpty)
                const Text('لا توجد مستندات تحتاج انتباه الآن'),
              ...items.map(
                (d) => Card(
                  child: ListTile(
                    title: Text(
                      d['type'] == 'OTHER'
                          ? d['customTypeName'] as String? ?? 'مستند'
                          : documentNames[d['type']] ?? 'مستند',
                    ),
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
      if (mounted) setState(() => error = '$e');
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
      if (mounted) setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('بيانات تحتاج استكمال'),
      actions: [
        IconButton(
          tooltip: 'تحديث',
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (items.isEmpty) const Text('لا توجد مستندات ناقصة البيانات'),
              ...items.map(
                (d) => Card(
                  child: ListTile(
                    title: Text(documentName(d)),
                    subtitle: const Text('تاريخ الانتهاء غير مضاف'),
                    trailing: TextButton(
                      key: Key('addExpiry-${d['id']}'),
                      onPressed: () => addExpiry(d),
                      child: const Text('إضافة تاريخ الانتهاء'),
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
    tooltip: unread == 0 ? 'الإشعارات' : 'الإشعارات • $unread غير مقروء',
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
      if (mounted) setState(() => error = '$e');
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
      if (mounted) setState(() => error = '$e');
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
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('الإشعارات'),
      actions: [
        TextButton(
          key: const Key('markAllNotificationsRead'),
          onPressed: busy ? null : readAll,
          child: const Text('تحديد الكل كمقروء'),
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
                TextButton(
                  onPressed: load,
                  child: const Text('إعادة المحاولة'),
                ),
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
              if (items.isEmpty) const Text('لا توجد إشعارات بعد'),
              ...items.map(
                (item) => Card(
                  child: ListTile(
                    leading: Icon(
                      item['readAt'] == null
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_none,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontWeight: item['readAt'] == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(item['body'] as String),
                    trailing: const Icon(Icons.chevron_left),
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
                      child: const Text('السابق'),
                    ),
                    Text('${page + 1}'),
                    TextButton(
                      onPressed: (page + 1) * 30 >= total
                          ? null
                          : () {
                              page++;
                              load();
                            },
                      child: const Text('التالي'),
                    ),
                  ],
                ),
            ],
          ),
  );
}
