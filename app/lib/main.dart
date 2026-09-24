import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';

import 'api.dart';
import 'file_export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(EquipmentApp(api: Api()));
}

const brand = Color(0xff176c66);
const categories = {'FUEL': 'وقود', 'MAINTENANCE': 'صيانة', 'OTHER': 'أخرى'};

String riyadhDateTime(String value) {
  final date = DateTime.parse(value).toUtc().add(const Duration(hours: 3));
  String two(int number) => number.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
}

class EquipmentApp extends StatefulWidget {
  final Api api;
  const EquipmentApp({super.key, required this.api});
  @override
  State<EquipmentApp> createState() => _EquipmentAppState();
}

class _EquipmentAppState extends State<EquipmentApp> {
  final navigator = GlobalKey<NavigatorState>();
  Map<String, dynamic>? user;
  bool loading = true;
  String? startupError;
  @override
  void initState() {
    super.initState();
    widget.api.expired = () {
      if (!mounted) return;
      navigator.currentState?.popUntil((r) => r.isFirst);
      setState(() {
        user = null;
        loading = false;
      });
    };
    restore();
  }

  Future<void> restore() async {
    setState(() {
      loading = true;
      startupError = null;
    });
    try {
      await widget.api.restore();
      user = await widget.api.me();
    } on ApiError catch (e) {
      if (e.status != 401) startupError = e.message;
    } catch (_) {
      startupError = 'تعذر استعادة الجلسة؛ أعد المحاولة';
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> loggedIn() async {
    final current = await widget.api.me();
    if (mounted) setState(() => user = current);
  }

  Future<void> logout() async {
    try {
      await widget.api.json('POST', '/auth/logout');
      await widget.api.clear();
      if (mounted) setState(() => user = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(navigator.currentContext!)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigator,
    debugShowCheckedModeBanner: false,
    title: 'إدارة المعدات',
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brand),
      scaffoldBackgroundColor: const Color(0xfff4f7f7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xff173c3b),
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe1e9e8)),
        ),
      ),
    ),
    home: loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : startupError != null
        ? Scaffold(
            body: ErrorPanel(message: startupError!, retry: restore),
          )
        : user == null
        ? LoginPage(api: widget.api, completed: loggedIn)
        : WorkspacePage(api: widget.api, user: user!, logout: logout),
  );
}

class DevNotice extends StatelessWidget {
  const DevNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: const Color(0xffeef3de),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const Text(
      'بيئة تطوير محلية • لا تُرسل رسائل SMS',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Color(0xff52612f)),
    ),
  );
}

class ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const ErrorPanel({super.key, required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: retry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}

class InlineError extends StatelessWidget {
  final String? message;
  const InlineError(this.message, {super.key});
  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              message!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
}

class FormBody extends StatelessWidget {
  final List<Widget> children;
  const FormBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: ListView(padding: const EdgeInsets.all(24), children: children),
    ),
  );
}

class LoginPage extends StatefulWidget {
  final Api api;
  final Future<void> Function() completed;
  const LoginPage({super.key, required this.api, required this.completed});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController();
  final code = TextEditingController();
  final name = TextEditingController();
  String? challenge, error;
  bool needsName = false, busy = false;
  @override
  void dispose() {
    phone.dispose();
    code.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (needsName && name.text.trim().isEmpty) {
      setState(() => error = 'اكتب الاسم للمتابعة');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (challenge == null) {
        final response = await widget.api.json(
          'POST',
          '/auth/challenges',
          body: {'phone': normalizeDigits(phone.text)},
        );
        if (mounted) setState(() => challenge = response['challengeId']);
      } else {
        final response = await widget.api.json(
          'POST',
          '/auth/verify',
          body: {
            'challengeId': challenge,
            'code': normalizeDigits(code.text),
            'name': needsName ? name.text : null,
            'client': kIsWeb ? 'WEB' : 'NATIVE',
          },
        );
        if (response['requiresName'] == true) {
          if (mounted) setState(() => needsName = true);
        } else {
          if (!kIsWeb) await widget.api.setToken(response['accessToken']);
          widget.api.csrf = response['csrfToken'];
          await widget.completed();
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          const DevNotice(),
          Expanded(
            child: FormBody(
              children: [
                const SizedBox(height: 36),
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 58,
                  color: brand,
                ),
                const SizedBox(height: 20),
                Text(
                  'إدارة المعدات',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'معداتك ومصروفاتك في مكان واحد',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  needsName
                      ? 'بماذا نناديك؟'
                      : challenge == null
                      ? 'ابدأ برقم جوالك'
                      : 'أدخل رمز التحقق',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                if (challenge == null) ...[
                  TextField(
                    key: const Key('phone'),
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'رقم الجوال',
                      hintText: '0500000001',
                    ),
                    onSubmitted: (_) => busy ? null : submit(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الأرقام التجريبية: 0500000001 أو 0500000002',
                    textDirection: TextDirection.rtl,
                  ),
                ] else if (needsName)
                  TextField(
                    key: const Key('ownerName'),
                    controller: name,
                    autofocus: true,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                    onSubmitted: (_) => busy ? null : submit(),
                  )
                else ...[
                  Text('التحقق من ${phone.text}'),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('otp'),
                    controller: code,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    decoration: const InputDecoration(
                      labelText: 'رمز التحقق',
                      helperText: 'رمز التطوير فقط: 123456',
                    ),
                    onSubmitted: (_) => busy ? null : submit(),
                  ),
                ],
                InlineError(error),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('loginContinue'),
                  onPressed: busy ? null : submit,
                  child: Text(
                    busy
                        ? 'جارٍ التحقق…'
                        : needsName
                        ? 'ابدأ بإضافة معداتك'
                        : challenge == null
                        ? 'طلب رمز التحقق'
                        : 'تأكيد الرمز',
                  ),
                ),
                if (challenge != null)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            challenge = null;
                            needsName = false;
                            error = null;
                            code.clear();
                          }),
                    child: const Text('تغيير الرقم أو طلب رمز جديد'),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class WorkspacePage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> user;
  final VoidCallback logout;
  const WorkspacePage({
    super.key,
    required this.api,
    required this.user,
    required this.logout,
  });
  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  int selected = 0;
  int revision = 0;
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final content = selected == 2
        ? LedgerPage(key: ValueKey('ledger-$revision'), api: widget.api)
        : EquipmentList(
            key: ValueKey('equipment-$revision'),
            api: widget.api,
            home: selected == 0,
            name: widget.user['name'],
          );
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المعدات'),
        actions: [
          IconButton(
            tooltip: 'تحديث البيانات',
            onPressed: () => setState(() => revision++),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: widget.logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const DevNotice(),
          Expanded(
            child: Row(
              children: [
                if (wide)
                  NavigationRail(
                    extended: true,
                    selectedIndex: selected,
                    onDestinationSelected: (i) => setState(() => selected = i),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        label: Text('الرئيسية'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.local_shipping_outlined),
                        label: Text('المعدات'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        label: Text('السجل'),
                      ),
                    ],
                  ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (i) => setState(() => selected = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  label: 'المعدات',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'السجل',
                ),
              ],
            ),
    );
  }
}

class EquipmentList extends StatefulWidget {
  final Api api;
  final bool home;
  final String name;
  const EquipmentList({
    super.key,
    required this.api,
    required this.home,
    required this.name,
  });
  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  List<dynamic> items = [];
  String? error;
  bool loading = true;
  int page = 0, total = 0;
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
      final response = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/equipment?page=$page&search=${Uri.encodeQueryComponent(search.text)}',
        ),
      );
      if (mounted) {
        setState(() {
          items = response['items'];
          total = response['total'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add() async {
    final created = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => EquipmentForm(api: widget.api)),
    );
    if (created != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EquipmentDetail(api: widget.api, equipment: created),
        ),
      );
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return ErrorPanel(message: error!, retry: load);
    return ListView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width > 850 ? 32 : 20),
      children: [
        Text(
          widget.home ? 'مرحبًا، ${widget.name}' : 'المعدات',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('كل معدة وسجلها، من أول عملية'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: search,
                decoration: const InputDecoration(
                  labelText: 'ابحث بالاسم أو الرقم الداخلي',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) {
                  page = 0;
                  load();
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: 'بحث',
              onPressed: () {
                page = 0;
                load();
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (items.isEmpty && search.text.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 64,
                    color: brand,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'أضف أول معدة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('ابدأ باسم المعدة وموديلها'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('addEquipment'),
                    onPressed: add,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة معدة'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: const Key('addEquipment'),
              onPressed: add,
              icon: const Icon(Icons.add),
              label: const Text('إضافة معدة'),
            ),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty) const Text('لا توجد معدات مطابقة للبحث'),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: constraints.maxWidth > 640
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EquipmentDetail(
                                api: widget.api,
                                equipment: item,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  color: brand,
                                  size: 30,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  item['name'],
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text('الموديل: ${item['model']}'),
                                const SizedBox(height: 12),
                                Text(
                                  item['reference'],
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'عرض السجل والعمليات ←',
                                  style: TextStyle(color: brand),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Pager(
            page: page,
            total: total,
            change: (value) {
              page = value;
              load();
            },
          ),
        ],
      ],
    );
  }
}

class Pager extends StatelessWidget {
  final int page, total;
  final ValueChanged<int> change;
  const Pager({
    super.key,
    required this.page,
    required this.total,
    required this.change,
  });
  @override
  Widget build(BuildContext context) => total <= 30
      ? const SizedBox.shrink()
      : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: page > 0 ? () => change(page - 1) : null,
              child: const Text('السابق'),
            ),
            Text('${page + 1}'),
            TextButton(
              onPressed: (page + 1) * 30 < total
                  ? () => change(page + 1)
                  : null,
              child: const Text('التالي'),
            ),
          ],
        );
}

Future<bool> confirmLeave(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هل تريد مغادرة النموذج؟'),
        content: const Text(
          'ستفقد البيانات غير المحفوظة. إذا لم يصل تأكيد الحفظ، راجع السجل قبل إنشاء طلب آخر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('متابعة الإدخال'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    ) ??
    false;

class EquipmentForm extends StatefulWidget {
  final Api api;
  const EquipmentForm({super.key, required this.api});
  @override
  State<EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<EquipmentForm> {
  final name = TextEditingController(), model = TextEditingController();
  final form = GlobalKey<FormState>();
  String key = requestKey();
  String? error;
  bool busy = false, uncertain = false, saved = false;
  @override
  void dispose() {
    name.dispose();
    model.dispose();
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
        'POST',
        widget.api.scoped('/equipment'),
        body: {'name': name.text.trim(), 'model': model.text.trim()},
        key: key,
      );
      if (mounted) {
        setState(() => saved = true);
        Navigator.pop(context, Map<String, dynamic>.from(result));
      }
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          uncertain = e.status == 0 || e.status == 409 || e.status >= 500;
          if (!uncertain) key = requestKey();
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: saved || (!busy && name.text.isEmpty && model.text.isEmpty),
    onPopInvokedWithResult: (didPop, result) async {
      if (!didPop && !busy && await confirmLeave(context) && context.mounted) {
        setState(() => saved = true);
        Navigator.pop(context);
      }
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('إضافة معدة')),
      body: Form(
        key: form,
        child: FormBody(
          children: [
            const Text(
              'الاسم والموديل يكفيان للبداية. نضيف رقمًا داخليًا تلقائيًا.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('equipmentName'),
              controller: name,
              enabled: !busy && !uncertain,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'اسم المعدة',
                hintText: 'قلاب ١',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'اكتب اسم المعدة' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('equipmentModel'),
              controller: model,
              enabled: !busy && !uncertain,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'الموديل',
                hintText: '2021 أو FH16',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'اكتب الموديل' : null,
              onChanged: (_) => setState(() {}),
            ),
            InlineError(error),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('saveEquipment'),
              onPressed: busy ? null : save,
              child: Text(
                busy
                    ? 'جارٍ حفظ المعدة…'
                    : uncertain
                    ? 'إعادة محاولة الحفظ نفسه'
                    : 'حفظ المعدة',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class EquipmentDetail extends StatelessWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  const EquipmentDetail({
    super.key,
    required this.api,
    required this.equipment,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(equipment['name'])),
    body: LedgerPage(api: api, equipment: equipment),
  );
}

class LedgerPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? equipment;
  const LedgerPage({super.key, required this.api, this.equipment});
  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  List<dynamic> items = [];
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
      final response = await widget.api.json(
        'GET',
        widget.api.scoped(
          '/entries?page=$page${widget.equipment == null ? '' : '&equipmentId=${widget.equipment!['id']}'}',
        ),
      );
      if (mounted) {
        setState(() {
          items = response['items'];
          total = response['total'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add({bool income = false}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ExpenseForm(
          api: widget.api,
          equipment: widget.equipment ?? {'id': null, 'name': 'مساحة العمل'},
          income: income,
          initialScope: widget.equipment == null ? 'GENERAL' : 'SINGLE',
        ),
      ),
    );
    if (result != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EntryDetail(api: widget.api, id: result['id']),
        ),
      );
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return ErrorPanel(message: error!, retry: load);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.equipment == null) ...[
          FilledButton.icon(
            key: const Key('addGeneralExpense'),
            onPressed: () => add(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة مصروف عام'),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.equipment != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.equipment!['name'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text('الموديل: ${widget.equipment!['model']}'),
                  Text(
                    widget.equipment!['reference'],
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('addExpense'),
                    onPressed: () => add(),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مصروف'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('addIncome'),
                    onPressed: () => add(income: true),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة إيراد'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.equipment == null ? 'السجل العام' : 'سجل المعدة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'تحديث السجل',
              onPressed: load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('كل عملية ودفعاتها ومرفقاتها في سجل واحد'),
        const SizedBox(height: 20),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('لا توجد عمليات مسجلة بعد'),
            ),
          ),
        ...items.map(
          (entry) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: const CircleAvatar(
                child: Icon(Icons.receipt_long_outlined),
              ),
              title: Text(
                '${entry['entryType'] == 'INCOME' ? 'إيراد' : categories[entry['category']]} • ${entry['expenseScope'] == 'GENERAL'
                    ? 'مصروف عام'
                    : entry['expenseScope'] == 'SHARED'
                    ? 'أكثر من معدة'
                    : entry['equipmentName']}',
              ),
              subtitle: Text(
                '${entry['operationDate']} ميلادي\n${entry['lifecycle'] == 'CANCELLED' ? 'عملية ملغاة' : (entry['entryType'] == 'INCOME' ? {'PAID': 'مستلم كاملًا', 'PARTIAL': 'مستلم جزئيًا', 'UNPAID': 'غير مستلم'} : {'PAID': 'مدفوع كاملًا', 'PARTIAL': 'مدفوع جزئيًا', 'UNPAID': 'غير مدفوع'})[entry['settlementStatus']] ?? 'حالة التسوية'}',
              ),
              isThreeLine: true,
              trailing: Text(
                '${entry['amount']}\nريال سعودي',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: brand,
                ),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EntryDetail(api: widget.api, id: entry['id']),
                ),
              ),
            ),
          ),
        ),
        Pager(
          page: page,
          total: total,
          change: (value) {
            page = value;
            load();
          },
        ),
      ],
    );
  }
}

class ExpenseForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final bool income;
  final String initialScope;
  const ExpenseForm({
    super.key,
    required this.api,
    required this.equipment,
    this.income = false,
    this.initialScope = 'SINGLE',
  });
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpensePart {
  String? equipmentId;
  final amount = TextEditingController();
  _ExpensePart(this.equipmentId);
  void dispose() => amount.dispose();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(),
      note = TextEditingController(),
      initialPaid = TextEditingController(),
      party = TextEditingController();
  String category = 'FUEL',
      date = todayRiyadh(),
      paidOn = todayRiyadh(),
      paymentStatus = 'FULL',
      key = requestKey();
  String? dueDate;
  String? error;
  bool busy = false, uncertain = false, saved = false;
  String expenseScope = 'SINGLE';
  final parts = <_ExpensePart>[];
  List<Map<String, dynamic>> equipmentChoices = [];
  bool loadingEquipment = false;
  @override
  void initState() {
    super.initState();
    expenseScope = widget.initialScope;
  }

  Future<void> loadEquipmentChoices() async {
    if (equipmentChoices.isNotEmpty || loadingEquipment) return;
    setState(() => loadingEquipment = true);
    try {
      final choices = <Map<String, dynamic>>[];
      var page = 0;
      while (true) {
        final response = await widget.api.json(
          'GET',
          widget.api.scoped('/equipment?page=$page'),
        );
        choices.addAll(
          (response['items'] as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
        if (choices.length >= (response['total'] as num).toInt()) break;
        page++;
      }
      if (mounted) setState(() => equipmentChoices = choices);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loadingEquipment = false);
    }
  }

  void changeScope(String value) {
    for (final part in parts) {
      part.dispose();
    }
    parts.clear();
    if (value == 'SHARED') {
      parts.add(_ExpensePart(widget.equipment['id'] as String));
      parts.add(_ExpensePart(null));
      loadEquipmentChoices();
    }
    setState(() {
      expenseScope = value;
      error = null;
    });
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    initialPaid.dispose();
    party.dispose();
    for (final part in parts) {
      part.dispose();
    }
    super.dispose();
  }

  Future<void> pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(dueDate ?? todayRiyadh()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => dueDate = selected.toIso8601String().split('T').first);
    }
  }

  Future<void> pickDate(bool payment) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(payment ? paidOn : date),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        final value = selected.toIso8601String().split('T').first;
        if (payment) {
          paidOn = value;
        } else {
          date = value;
        }
      });
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    if (!widget.income && expenseScope == 'SHARED') {
      final total = exactMoney(amount.text);
      final amounts = parts
          .map((part) => exactMoney(part.amount.text))
          .toList();
      final ids = parts.map((part) => part.equipmentId).toList();
      if (total == null ||
          amounts.any((value) => value == null) ||
          ids.any((id) => id == null) ||
          ids.toSet().length != ids.length ||
          amounts.fold<BigInt>(
                BigInt.zero,
                (sum, value) => sum + BigInt.parse(value!.replaceAll('.', '')),
              ) !=
              BigInt.parse(total.replaceAll('.', ''))) {
        setState(
          () => error =
              'حدد معدات مختلفة واجعل مجموع مبالغها يساوي إجمالي المصروف',
        );
        return;
      }
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.api.json(
        'POST',
        widget.api.scoped('/entries'),
        key: key,
        body: {
          if (widget.income || expenseScope == 'SINGLE')
            'equipmentId': widget.equipment['id'],
          if (!widget.income) 'expenseScope': expenseScope,
          if (!widget.income && expenseScope == 'SHARED')
            'allocations': parts
                .map(
                  (part) => {
                    'equipmentId': part.equipmentId,
                    'amount': exactMoney(part.amount.text),
                  },
                )
                .toList(),
          if (widget.income) 'entryType': 'INCOME',
          'amount': exactMoney(amount.text),
          if (!widget.income) 'category': category,
          'operationDate': date,
          if (paymentStatus != 'UNPAID') 'paidOn': paidOn,
          'paymentStatus': paymentStatus,
          if (paymentStatus == 'PARTIAL')
            'initialPaid': exactMoney(initialPaid.text),
          if (paymentStatus != 'FULL') 'partyName': party.text.trim(),
          if (paymentStatus != 'FULL' && dueDate != null) 'dueDate': dueDate,
          'note': note.text.trim(),
        },
      );
      if (mounted) {
        setState(() => saved = true);
        Navigator.pop(context, Map<String, dynamic>.from(result));
      }
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          uncertain = e.status == 0 || e.status == 409 || e.status >= 500;
          if (!uncertain) key = requestKey();
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: saved || (!busy && amount.text.isEmpty && note.text.isEmpty),
    onPopInvokedWithResult: (didPop, result) async {
      if (!didPop && !busy && await confirmLeave(context) && context.mounted) {
        setState(() => saved = true);
        Navigator.pop(context);
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.income ? 'إضافة إيراد' : 'إضافة مصروف'),
      ),
      body: Form(
        key: form,
        child: FormBody(
          children: [
            Text(
              widget.equipment['name'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (widget.income)
              const Text('يُسجّل هذا الإيراد على هذه المعدة')
            else if (widget.equipment['id'] == null)
              const Text('مصروف عام لمساحة العمل؛ لا يُحمّل على معدة')
            else ...[
              const Text('اختر المعدات التي يخصها المصروف'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('expenseScope'),
                initialValue: expenseScope,
                decoration: const InputDecoration(labelText: 'يخص المصروف'),
                items: const [
                  DropdownMenuItem(value: 'SINGLE', child: Text('معدة واحدة')),
                  DropdownMenuItem(
                    value: 'SHARED',
                    child: Text('أكثر من معدة'),
                  ),
                  DropdownMenuItem(value: 'GENERAL', child: Text('مصروف عام')),
                ],
                onChanged: busy || uncertain
                    ? null
                    : (value) {
                        if (value != null) changeScope(value);
                      },
              ),
            ],
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('expenseAmount'),
              controller: amount,
              enabled: !busy && !uncertain,
              textDirection: TextDirection.ltr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'المبلغ (ريال سعودي)',
                hintText: '350.00',
              ),
              validator: (v) => exactMoney(v ?? '') == null
                  ? 'اكتب مبلغًا أكبر من صفر، حتى منزلتين عشريتين'
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            if (!widget.income && expenseScope == 'SHARED') ...[
              const SizedBox(height: 16),
              Text(
                'مبلغ كل معدة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (loadingEquipment) const LinearProgressIndicator(),
              ...parts.asMap().entries.map(
                (item) => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: Key('allocationEquipment${item.key}'),
                        initialValue: item.value.equipmentId,
                        decoration: const InputDecoration(labelText: 'المعدة'),
                        items: [
                          if (!equipmentChoices.any(
                            (e) => e['id'] == widget.equipment['id'],
                          ))
                            DropdownMenuItem(
                              value: widget.equipment['id'] as String,
                              child: Text(widget.equipment['name'] as String),
                            ),
                          ...equipmentChoices.map(
                            (e) => DropdownMenuItem(
                              value: e['id'] as String,
                              child: Text(e['name'] as String),
                            ),
                          ),
                        ],
                        onChanged: busy || uncertain
                            ? null
                            : (value) => setState(
                                () => item.value.equipmentId = value,
                              ),
                        validator: (value) =>
                            value == null ? 'اختر معدة' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: Key('allocationAmount${item.key}'),
                        controller: item.value.amount,
                        textDirection: TextDirection.ltr,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: 'المبلغ'),
                        validator: (value) => exactMoney(value ?? '') == null
                            ? 'اكتب مبلغًا صحيحًا'
                            : null,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (parts.length > 2)
                      IconButton(
                        key: Key('removeAllocation${item.key}'),
                        tooltip: 'إزالة المعدة',
                        onPressed: busy || uncertain
                            ? null
                            : () => setState(() {
                                final removed = parts.removeAt(item.key);
                                removed.dispose();
                              }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                key: const Key('addAllocation'),
                onPressed: busy || uncertain
                    ? null
                    : () => setState(() => parts.add(_ExpensePart(null))),
                icon: const Icon(Icons.add),
                label: const Text('إضافة معدة'),
              ),
              Text(
                'المتبقي للتوزيع: ${(() {
                  final total = exactMoney(amount.text);
                  if (total == null) return '—';
                  final assigned = parts.map((p) => exactMoney(p.amount.text)).whereType<String>().fold<BigInt>(BigInt.zero, (s, v) => s + BigInt.parse(v.replaceAll('.', '')));
                  final difference = BigInt.parse(total.replaceAll('.', '')) - assigned;
                  final absolute = difference.abs().toString().padLeft(3, '0');
                  return '${difference.isNegative ? '-' : ''}${absolute.substring(0, absolute.length - 2)}.${absolute.substring(absolute.length - 2)}';
                })()} ريال سعودي',
                key: const Key('allocationRemaining'),
              ),
            ],
            const SizedBox(height: 20),
            if (!widget.income)
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'نوع المصروف'),
                items: categories.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: busy || uncertain
                    ? null
                    : (v) => setState(() => category = v!),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: busy || uncertain ? null : () => pickDate(false),
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('تاريخ العملية: $date ميلادي'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('paymentStatus'),
              initialValue: paymentStatus,
              decoration: InputDecoration(
                labelText: widget.income ? 'حالة الاستلام' : 'حالة الدفع',
              ),
              items: widget.income
                  ? const [
                      DropdownMenuItem(
                        value: 'FULL',
                        child: Text('استلمته كاملًا'),
                      ),
                      DropdownMenuItem(
                        value: 'PARTIAL',
                        child: Text('استلمت جزءًا'),
                      ),
                      DropdownMenuItem(
                        value: 'UNPAID',
                        child: Text('لم أستلمه'),
                      ),
                    ]
                  : const [
                      DropdownMenuItem(
                        value: 'FULL',
                        child: Text('دفعته كاملًا'),
                      ),
                      DropdownMenuItem(
                        value: 'PARTIAL',
                        child: Text('دفعت جزءًا'),
                      ),
                      DropdownMenuItem(
                        value: 'UNPAID',
                        child: Text('لم أدفعه'),
                      ),
                    ],
              onChanged: busy || uncertain
                  ? null
                  : (v) => setState(() => paymentStatus = v!),
            ),
            if (paymentStatus == 'PARTIAL') ...[
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('initialPaid'),
                controller: initialPaid,
                enabled: !busy && !uncertain,
                textDirection: TextDirection.ltr,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.income
                      ? 'المبلغ المستلم أولًا'
                      : 'المبلغ المدفوع أولًا',
                ),
                validator: (v) {
                  final first = exactMoney(v ?? '');
                  final total = exactMoney(amount.text);
                  if (first == null ||
                      total == null ||
                      BigInt.parse(first.replaceAll('.', '')) >=
                          BigInt.parse(total.replaceAll('.', ''))) {
                    return 'اكتب مبلغًا أكبر من صفر وأقل من الإجمالي';
                  }
                  return null;
                },
              ),
            ],
            if (paymentStatus != 'UNPAID') ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: busy || uncertain ? null : () => pickDate(true),
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${widget.income ? 'تاريخ الاستلام' : 'تاريخ الدفع'}: $paidOn ميلادي',
                ),
              ),
            ],
            if (paymentStatus != 'FULL') ...[
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('partyName'),
                controller: party,
                enabled: !busy && !uncertain,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: widget.income
                      ? 'اسم الطرف الذي سيدفع'
                      : 'اسم الطرف المستحق',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'اكتب اسم الطرف' : null,
              ),
              OutlinedButton.icon(
                onPressed: busy || uncertain ? null : pickDueDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  dueDate == null
                      ? 'موعد الاستحقاق (اختياري)'
                      : 'موعد الاستحقاق: $dueDate ميلادي',
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('expenseNote'),
              controller: note,
              enabled: !busy && !uncertain,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إرفاق صورة أو PDF بعد حفظ ${widget.income ? 'الإيراد' : 'المصروف'}.',
            ),
            InlineError(error),
            const SizedBox(height: 16),
            FilledButton(
              key: Key(widget.income ? 'saveIncome' : 'saveExpense'),
              onPressed: busy ? null : save,
              child: Text(
                busy
                    ? 'جارٍ حفظ ${widget.income ? 'الإيراد' : 'المصروف'}…'
                    : uncertain
                    ? 'إعادة محاولة الحفظ نفسه'
                    : 'حفظ ${widget.income ? 'الإيراد' : 'المصروف'}',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class EntryEditForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> entry;
  const EntryEditForm({super.key, required this.api, required this.entry});
  @override
  State<EntryEditForm> createState() => _EntryEditFormState();
}

class _EntryEditFormState extends State<EntryEditForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController amount, note, party;
  late String category, date;
  String? dueDate, error;
  bool busy = false;
  bool get income => widget.entry['entryType'] == 'INCOME';
  bool get shared => widget.entry['expenseScope'] == 'SHARED';
  bool get hasCash =>
      widget.entry['paid'] != '0.00' || widget.entry['refunded'] != '0.00';
  final parts = <_ExpensePart>[];
  List<Map<String, dynamic>> equipmentChoices = [];
  @override
  void initState() {
    super.initState();
    amount = TextEditingController(text: widget.entry['amount']);
    note = TextEditingController(text: widget.entry['note']);
    party = TextEditingController(text: widget.entry['partyName'] ?? '');
    category = widget.entry['category'];
    date = widget.entry['operationDate'];
    dueDate = widget.entry['dueDate'];
    if (shared) {
      for (final allocation in widget.entry['allocations'] as List) {
        final part = _ExpensePart(allocation['equipmentId'] as String);
        part.amount.text = allocation['amount'] as String;
        parts.add(part);
      }
      loadEquipmentChoices();
    }
  }

  Future<void> loadEquipmentChoices() async {
    try {
      final choices = <Map<String, dynamic>>[];
      var page = 0;
      while (true) {
        final response = await widget.api.json(
          'GET',
          widget.api.scoped('/equipment?page=$page'),
        );
        choices.addAll(
          (response['items'] as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
        if (choices.length >= (response['total'] as num).toInt()) break;
        page++;
      }
      if (mounted) setState(() => equipmentChoices = choices);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    party.dispose();
    for (final part in parts) {
      part.dispose();
    }
    super.dispose();
  }

  Future<void> pickDate({bool due = false}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.parse((due ? dueDate : date) ?? todayRiyadh()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        if (due) {
          dueDate = selected.toIso8601String().split('T').first;
        } else {
          date = selected.toIso8601String().split('T').first;
        }
      });
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    if (shared && !hasCash) {
      final totalAmount = exactMoney(amount.text);
      final assigned = parts
          .map((part) => exactMoney(part.amount.text))
          .toList();
      final ids = parts.map((part) => part.equipmentId).toList();
      if (parts.length < 2 ||
          totalAmount == null ||
          assigned.any((value) => value == null) ||
          ids.any((id) => id == null) ||
          ids.toSet().length != ids.length ||
          assigned.fold<BigInt>(
                BigInt.zero,
                (sum, value) => sum + BigInt.parse(value!.replaceAll('.', '')),
              ) !=
              BigInt.parse(totalAmount.replaceAll('.', ''))) {
        setState(
          () => error =
              'حدد معدات مختلفة واجعل مجموع مبالغها يساوي إجمالي المصروف',
        );
        return;
      }
    }
    final settled = BigInt.parse(
      (widget.entry['paid'] as String).replaceAll('.', ''),
    );
    final total = BigInt.parse(exactMoney(amount.text)!.replaceAll('.', ''));
    if (total < settled) {
      setState(() => error = 'الإجمالي لا يقل عن مجموع التسويات');
      return;
    }
    if (total == settled && dueDate != null) {
      setState(() => error = 'أزل موعد الاستحقاق عند سداد الإجمالي');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final updated = await widget.api.json(
        'PUT',
        widget.api.scoped('/entries/${widget.entry['id']}'),
        body: {
          'amount': exactMoney(amount.text),
          if (!income) 'category': category,
          'operationDate': date,
          'note': note.text.trim(),
          'partyName': party.text.trim(),
          'dueDate': dueDate,
          if (shared && !hasCash)
            'allocations': parts
                .map(
                  (part) => {
                    'equipmentId': part.equipmentId,
                    'amount': exactMoney(part.amount.text),
                  },
                )
                .toList(),
        },
      );
      if (mounted) Navigator.pop(context, Map<String, dynamic>.from(updated));
    } on ApiError catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(income ? 'تعديل الإيراد' : 'تعديل المصروف')),
    body: Form(
      key: form,
      child: FormBody(
        children: [
          Text(
            'التسويات السابقة محفوظة ولا تتغير بالتعديل.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('editAmount'),
            controller: amount,
            enabled: !busy && !(shared && hasCash),
            textDirection: TextDirection.ltr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'الإجمالي (ريال سعودي)',
            ),
            validator: (v) =>
                exactMoney(v ?? '') == null ? 'اكتب مبلغًا صحيحًا' : null,
          ),
          if (shared) ...[
            const SizedBox(height: 12),
            Text(
              hasCash
                  ? 'توزيع هذا المصروف محفوظ بعد تسجيل دفعة أو استرداد. يمكنك تعديل الوصف والبيانات الأخرى.'
                  : 'عدّل مبلغ كل معدة بحيث يساوي الإجمالي.',
            ),
            ...parts.asMap().entries.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: Key('editAllocationEquipment${item.key}'),
                        initialValue: item.value.equipmentId,
                        decoration: const InputDecoration(labelText: 'المعدة'),
                        items: [
                          if (item.value.equipmentId != null &&
                              !equipmentChoices.any(
                                (e) => e['id'] == item.value.equipmentId,
                              ))
                            DropdownMenuItem(
                              value: item.value.equipmentId,
                              child: Text(
                                (widget.entry['allocations'] as List)
                                        .firstWhere(
                                          (part) =>
                                              part['equipmentId'] ==
                                              item.value.equipmentId,
                                        )['equipmentName']
                                    as String,
                              ),
                            ),
                          ...equipmentChoices.map(
                            (e) => DropdownMenuItem(
                              value: e['id'] as String,
                              child: Text(e['name'] as String),
                            ),
                          ),
                        ],
                        onChanged: busy || hasCash
                            ? null
                            : (value) => setState(
                                () => item.value.equipmentId = value,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: Key('editAllocationAmount${item.key}'),
                        controller: item.value.amount,
                        enabled: !busy && !hasCash,
                        textDirection: TextDirection.ltr,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: 'المبلغ'),
                        validator: (value) => exactMoney(value ?? '') == null
                            ? 'اكتب مبلغًا صحيحًا'
                            : null,
                      ),
                    ),
                    if (!hasCash && parts.length > 2)
                      IconButton(
                        key: Key('removeEditAllocation${item.key}'),
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                final removed = parts.removeAt(item.key);
                                removed.dispose();
                              }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                  ],
                ),
              ),
            ),
            if (!hasCash)
              TextButton.icon(
                key: const Key('addEditAllocation'),
                onPressed: busy
                    ? null
                    : () => setState(() => parts.add(_ExpensePart(null))),
                icon: const Icon(Icons.add),
                label: const Text('إضافة معدة'),
              ),
          ],
          if (!income) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'نوع المصروف'),
              items: categories.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: busy ? null : (v) => setState(() => category = v!),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: busy ? null : () => pickDate(),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('تاريخ العملية: $date ميلادي'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('editParty'),
            controller: party,
            enabled: !busy,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: income ? 'اسم الطرف الذي سيدفع' : 'اسم الطرف المستحق',
            ),
            validator: (v) {
              final total = exactMoney(amount.text);
              if (total == null) return null;
              final settled = BigInt.parse(
                (widget.entry['paid'] as String).replaceAll('.', ''),
              );
              return BigInt.parse(total.replaceAll('.', '')) > settled &&
                      (v == null || v.trim().isEmpty)
                  ? 'اكتب اسم الطرف عند وجود متبقٍ'
                  : null;
            },
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => pickDate(due: true),
            icon: const Icon(Icons.event_outlined),
            label: Text(
              dueDate == null
                  ? 'موعد الاستحقاق (اختياري)'
                  : 'موعد الاستحقاق: $dueDate ميلادي',
            ),
          ),
          if (dueDate != null)
            TextButton(
              onPressed: busy ? null : () => setState(() => dueDate = null),
              child: const Text('إزالة موعد الاستحقاق'),
            ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('editNote'),
            controller: note,
            enabled: !busy,
            maxLength: 1000,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)'),
          ),
          InlineError(error),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('saveEntryEdit'),
            onPressed: busy ? null : save,
            child: Text(busy ? 'جارٍ حفظ التعديل…' : 'حفظ التعديل'),
          ),
        ],
      ),
    ),
  );
}

class EntryDetail extends StatefulWidget {
  final Api api;
  final String id;
  final Future<XFile?> Function()? pickFile;
  const EntryDetail({
    super.key,
    required this.api,
    required this.id,
    this.pickFile,
  });
  @override
  State<EntryDetail> createState() => _EntryDetailState();
}

class _EntryDetailState extends State<EntryDetail> {
  Map<String, dynamic>? entry;
  bool get income => entry?['entryType'] == 'INCOME';
  bool get cancelled => entry?['lifecycle'] == 'CANCELLED';
  bool get canRefund =>
      !cancelled &&
      entry?['refundable'] is String &&
      entry!['refundable'] != '0.00';
  List<dynamic> attachments = [];
  String? error, uploadError, uploadId;
  bool loading = true, uploading = false;
  Uint8List? pendingBytes;
  String? pendingName, pendingType;
  String uploadKey = requestKey();
  Future<void> editEntry() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EntryEditForm(api: widget.api, entry: entry!),
      ),
    );
    if (updated != null && mounted) await load();
  }

  Future<void> cancelEntry() async {
    String reason = '';
    String? validation;
    bool saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          scrollable: true,
          title: const Text('إلغاء العملية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ستبقى الدفعات والمرفقات في السجل. الإلغاء ليس استردادًا للمال.',
              ),
              TextField(
                key: const Key('cancellationReason'),
                onChanged: (value) => reason = value,
                maxLength: 500,
                maxLines: 2,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'سبب الإلغاء'),
              ),
              InlineError(validation),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('رجوع'),
            ),
            FilledButton(
              key: const Key('confirmCancellation'),
              onPressed: saving
                  ? null
                  : () async {
                      if (reason.trim().isEmpty) {
                        update(() => validation = 'اكتب سبب الإلغاء');
                        return;
                      }
                      update(() {
                        saving = true;
                        validation = null;
                      });
                      try {
                        await widget.api.json(
                          'POST',
                          widget.api.scoped(
                            '/entries/${widget.id}/cancellation',
                          ),
                          body: {'reason': reason.trim()},
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (mounted) await load();
                      } on ApiError catch (e) {
                        if (dialogContext.mounted) {
                          update(() => validation = e.message);
                        }
                      } finally {
                        if (dialogContext.mounted) update(() => saving = false);
                      }
                    },
              child: Text(saving ? 'جارٍ الإلغاء…' : 'تأكيد الإلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addPayment() async {
    String paymentAmount = '';
    String paidOn = todayRiyadh();
    String? paymentError;
    bool saving = false;
    final paymentKey = requestKey();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          scrollable: true,
          title: Text(income ? 'إضافة تحصيل' : 'إضافة دفعة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${income ? 'المتبقي لك' : 'المتبقي عليك'}: ${entry!['remaining']} ريال سعودي',
              ),
              TextField(
                onChanged: (value) => paymentAmount = value,
                enabled: !saving,
                textDirection: TextDirection.ltr,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: income ? 'مبلغ التحصيل' : 'مبلغ الدفعة',
                ),
              ),
              OutlinedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(paidOn),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          update(
                            () => paidOn = date
                                .toIso8601String()
                                .split('T')
                                .first,
                          );
                        }
                      },
                child: Text(
                  '${income ? 'تاريخ التحصيل' : 'تاريخ الدفع'}: $paidOn ميلادي',
                ),
              ),
              InlineError(paymentError),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final value = exactMoney(paymentAmount);
                      if (value == null) {
                        update(() => paymentError = 'اكتب مبلغًا صحيحًا');
                        return;
                      }
                      update(() {
                        saving = true;
                        paymentError = null;
                      });
                      try {
                        await widget.api.json(
                          'POST',
                          widget.api.scoped(
                            '/entries/${widget.id}/settlements',
                          ),
                          key: paymentKey,
                          body: {'amount': value, 'paidOn': paidOn},
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (mounted) await load();
                      } on ApiError catch (e) {
                        update(() => paymentError = e.message);
                      } finally {
                        if (dialogContext.mounted) update(() => saving = false);
                      }
                    },
              child: Text(
                saving
                    ? 'جارٍ الحفظ…'
                    : income
                    ? 'حفظ التحصيل'
                    : 'حفظ الدفعة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addRefund() async {
    String refundAmount = '';
    String refundedOn = todayRiyadh();
    String reason = '';
    String? refundError;
    bool saving = false;
    final refundKey = requestKey();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          scrollable: true,
          title: const Text('تسجيل استرداد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                income
                    ? 'مبلغ أُعيد إلى العميل أو الطرف الآخر. المتاح للاسترداد: ${entry!['refundable']} ريال سعودي'
                    : 'مبلغ عاد إليك من المورد أو الطرف الآخر. المتاح للاسترداد: ${entry!['refundable']} ريال سعودي',
              ),
              TextField(
                key: const Key('refundAmount'),
                onChanged: (value) => refundAmount = value,
                enabled: !saving,
                textDirection: TextDirection.ltr,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'مبلغ الاسترداد'),
              ),
              OutlinedButton(
                key: const Key('refundDate'),
                onPressed: saving
                    ? null
                    : () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(refundedOn),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          update(
                            () => refundedOn = date
                                .toIso8601String()
                                .split('T')
                                .first,
                          );
                        }
                      },
                child: Text('تاريخ عودة المال: $refundedOn ميلادي'),
              ),
              TextField(
                key: const Key('refundReason'),
                onChanged: (value) => reason = value,
                enabled: !saving,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'سبب الاسترداد'),
              ),
              InlineError(refundError),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('رجوع'),
            ),
            FilledButton(
              key: const Key('saveRefund'),
              onPressed: saving
                  ? null
                  : () async {
                      final value = exactMoney(refundAmount);
                      if (value == null) {
                        update(() => refundError = 'اكتب مبلغ استرداد صحيحًا');
                        return;
                      }
                      if (BigInt.parse(value.replaceAll('.', '')) >
                          BigInt.parse(
                            (entry!['refundable'] as String).replaceAll(
                              '.',
                              '',
                            ),
                          )) {
                        update(
                          () => refundError = 'مبلغ الاسترداد أكبر من المتاح',
                        );
                        return;
                      }
                      if (reason.trim().isEmpty) {
                        update(() => refundError = 'اكتب سبب الاسترداد');
                        return;
                      }
                      update(() {
                        saving = true;
                        refundError = null;
                      });
                      try {
                        await widget.api.json(
                          'POST',
                          widget.api.scoped('/entries/${widget.id}/refunds'),
                          key: refundKey,
                          body: {
                            'amount': value,
                            'refundedOn': refundedOn,
                            'reason': reason.trim(),
                          },
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (mounted) await load();
                      } on ApiError catch (e) {
                        if (dialogContext.mounted) {
                          update(() => refundError = e.message);
                        }
                      } finally {
                        if (dialogContext.mounted) update(() => saving = false);
                      }
                    },
              child: Text(saving ? 'جارٍ الحفظ…' : 'حفظ الاسترداد'),
            ),
          ],
        ),
      ),
    );
  }

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
        widget.api.scoped('/entries/${widget.id}'),
      );
      final files = await widget.api.json(
        'GET',
        widget.api.scoped('/entries/${widget.id}/attachments'),
      );
      if (mounted) {
        setState(() {
          entry = data;
          attachments = files;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> select({Map<String, dynamic>? retry}) async {
    try {
      final file =
          await (widget.pickFile?.call() ??
              openFile(
                acceptedTypeGroups: [
                  const XTypeGroup(
                    label: 'صور وفواتير PDF',
                    extensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
                    uniformTypeIdentifiers: [
                      'public.jpeg',
                      'public.png',
                      'com.adobe.pdf',
                    ],
                  ),
                ],
              ));
      if (file == null) return;
      if (await file.length() > 10 * 1024 * 1024) {
        throw const ApiError(
          413,
          'FILE_TOO_LARGE',
          'اختر ملفًا لا يتجاوز 10 ميغابايت',
        );
      }
      final extension = file.name.split('.').last.toLowerCase();
      final type = {
        'png': 'image/png',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'pdf': 'application/pdf',
      }[extension];
      if (type == null) {
        throw const ApiError(
          400,
          'UNSUPPORTED_FILE',
          'اختر PNG أو JPEG أو PDF؛ حوّل HEIC إلى JPEG قبل الرفع',
        );
      }
      pendingBytes = await file.readAsBytes();
      pendingName = file.name;
      pendingType = type;
      uploadId = retry?['id'];
      uploadKey = requestKey();
      await upload();
    } catch (e) {
      if (mounted) setState(() => uploadError = '$e');
    }
  }

  Future<void> upload() async {
    setState(() {
      uploading = true;
      uploadError = null;
    });
    try {
      if (uploadId == null) {
        final file = await widget.api.json(
          'POST',
          widget.api.scoped('/entries/${widget.id}/attachments'),
          key: uploadKey,
          body: {
            'filename': pendingName,
            'mediaType': pendingType,
            'size': pendingBytes!.length,
          },
        );
        uploadId = file['id'];
      }
      await widget.api.send(
        'PUT',
        widget.api.scoped('/attachments/$uploadId/content'),
        bytes: pendingBytes,
        type: pendingType,
      );
      pendingBytes = null;
      uploadId = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حُفظ المرفق داخل العملية')),
        );
        await load();
      }
    } catch (e) {
      if (mounted) {
        setState(() => uploadError = 'حُفظت العملية، وتعذر رفع المرفق. $e');
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> open(Map<String, dynamic> file, {bool download = false}) async {
    try {
      final response = await widget.api.send(
        'GET',
        widget.api.scoped('/attachments/${file['id']}/content'),
      );
      if (!mounted) return;
      if (file['mediaType'].toString().startsWith('image/') && !download) {
        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(file['filename']),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        tooltip: 'إغلاق المرفق',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Flexible(
                    child: InteractiveViewer(
                      child: Image.memory(
                        response.bodyBytes,
                        semanticLabel: 'مرفق العملية: ${file['filename']}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        await exportFile(
          response.bodyBytes,
          file['filename'],
          file['mediaType'],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(income ? 'تفاصيل الإيراد' : 'تفاصيل المصروف'),
      actions: [
        IconButton(
          tooltip: income ? 'تحديث الإيراد' : 'تحديث المصروف',
          onPressed: uploading ? null : load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? ErrorPanel(message: error!, retry: load)
        : FormBody(
            children: [
              Text(
                '${income ? 'إيراد' : categories[entry!['category']]} • ${entry!['expenseScope'] == 'GENERAL'
                    ? 'مصروف عام'
                    : entry!['expenseScope'] == 'SHARED'
                    ? 'أكثر من معدة'
                    : entry!['equipmentName']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${entry!['operationDate']} ميلادي'),
              if (cancelled) ...[
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'عملية ملغاة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('السبب: ${entry!['cancellationReason']}'),
                        Text(
                          'تاريخ الإلغاء: ${riyadhDateTime(entry!['cancelledAt'])} ميلادي بتوقيت الرياض',
                        ),
                        const Text(
                          'المبالغ والتسويات أدناه محفوظة للسجل، ولا تدخل العملية في المجاميع النشطة.',
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('editEntry'),
                      onPressed: editEntry,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('تعديل'),
                    ),
                    TextButton.icon(
                      key: const Key('cancelEntry'),
                      onPressed: cancelEntry,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('إلغاء العملية'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      moneyRow(
                        income ? 'إجمالي الإيراد' : 'إجمالي المصروف',
                        entry!['amount'],
                      ),
                      const Divider(height: 32),
                      moneyRow(
                        income ? 'المستلم إجمالًا' : 'المدفوع إجمالًا',
                        entry!['paid'],
                      ),
                      if (entry!['refunded'] != null &&
                          entry!['refunded'] != '0.00') ...[
                        const SizedBox(height: 16),
                        moneyRow('المسترد', entry!['refunded']),
                        const SizedBox(height: 16),
                        moneyRow(
                          income ? 'صافي المستلم' : 'صافي المدفوع',
                          entry!['netPaid'],
                        ),
                      ],
                      const SizedBox(height: 16),
                      moneyRow(
                        income ? 'المتبقي لك' : 'المتبقي عليك',
                        entry!['remaining'],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Chip(
                          avatar: const Icon(
                            Icons.payments_outlined,
                            color: brand,
                          ),
                          label: Text(
                            (income
                                    ? {
                                        'PAID': 'مستلم كاملًا',
                                        'PARTIAL': 'مستلم جزئيًا',
                                        'UNPAID': 'غير مستلم',
                                      }
                                    : {
                                        'PAID': 'مدفوع كاملًا',
                                        'PARTIAL': 'مدفوع جزئيًا',
                                        'UNPAID': 'غير مدفوع',
                                      })[entry!['settlementStatus']] ??
                                'حالة التسوية',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!income && entry!['expenseScope'] == 'SHARED') ...[
                Text(
                  'نصيب كل معدة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'المدفوع والمسترد أدناه حصص محسوبة؛ الدفعات والاستردادات الأصلية مسجلة مرة واحدة على المصروف.',
                ),
                ...((entry!['allocations'] as List).map(
                  (part) => Card(
                    child: ListTile(
                      title: Text(
                        '${part['equipmentName']}: ${part['amount']} ريال سعودي',
                      ),
                      subtitle: Text(
                        'حصة محسوبة من صافي المدفوع: ${part['netPaidShare']} • المتبقي: ${part['remainingShare']} ريال سعودي',
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (entry!['partyName'] != null)
                Text('الطرف: ${entry!['partyName']}'),
              if (entry!['dueDate'] != null)
                Text('موعد الاستحقاق: ${entry!['dueDate']} ميلادي'),
              if (!cancelled && entry!['settlementStatus'] != 'PAID') ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: addPayment,
                  icon: const Icon(Icons.add),
                  label: Text(income ? 'إضافة تحصيل' : 'إضافة دفعة'),
                ),
              ],
              if (canRefund) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('addRefund'),
                  onPressed: addRefund,
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('تسجيل استرداد'),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                income ? 'التحصيلات' : 'الدفعات',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ...((entry!['settlements'] as List).map(
                (s) => ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text('${s['amount']} ريال سعودي'),
                  subtitle: Text(
                    '${income ? 'استُلمت' : 'دُفعت'} في ${s['paidOn']} ميلادي',
                  ),
                ),
              )),
              if ((entry!['refunds'] as List?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 24),
                Text(
                  'الاستردادات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ...((entry!['refunds'] as List).map(
                  (r) => ListTile(
                    leading: const Icon(Icons.undo_outlined),
                    title: Text('${r['amount']} ريال سعودي'),
                    subtitle: Text(
                      '${income ? 'أُعيد إلى العميل أو الطرف الآخر' : 'عاد إليك من الطرف الآخر'} في ${r['refundedOn']} ميلادي\nالسبب: ${r['reason']}',
                    ),
                  ),
                )),
              ],
              if (entry!['note'] != '') ...[
                const Divider(),
                Text('ملاحظة: ${entry!['note']}'),
              ],
              const SizedBox(height: 24),
              Text('المرفقات', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('صورة PNG أو JPEG، أو PDF • حتى 10 ميغابايت للملف'),
              const SizedBox(height: 12),
              if (attachments.isEmpty)
                const Text('لم تُضف مرفقات بعد؛ العملية محفوظة.'),
              ...attachments.map(
                (file) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file['filename'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          file['state'] == 'READY'
                              ? 'جاهز للعرض'
                              : file['state'] == 'FAILED'
                              ? 'تعثر رفع المرفق'
                              : 'لم يكتمل الرفع',
                        ),
                        if (file['state'] == 'READY')
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: uploading ? null : () => open(file),
                                icon: const Icon(Icons.visibility_outlined),
                                label: Text(
                                  file['mediaType'] == 'application/pdf'
                                      ? (kIsWeb ? 'تنزيل PDF' : 'فتح PDF')
                                      : 'عرض المرفق',
                                ),
                              ),
                              if (kIsWeb &&
                                  file['mediaType'] != 'application/pdf')
                                TextButton.icon(
                                  onPressed: uploading
                                      ? null
                                      : () => open(file, download: true),
                                  icon: const Icon(Icons.download_outlined),
                                  label: const Text('تنزيل المرفق'),
                                ),
                            ],
                          )
                        else
                          TextButton(
                            onPressed: uploading
                                ? null
                                : () => select(
                                    retry: Map<String, dynamic>.from(file),
                                  ),
                            child: const Text('إعادة رفع المرفق'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              InlineError(uploadError),
              if (uploading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
                const Text('جارٍ رفع المرفق والتحقق منه…'),
              ] else if (pendingBytes != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: upload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة رفع المرفق'),
                    ),
                    OutlinedButton(
                      onPressed: () => select(),
                      child: const Text('اختيار ملف آخر'),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  key: const Key('addAttachment'),
                  onPressed: () => select(),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('إضافة مرفق'),
                ),
              const SizedBox(height: 16),
              const Text(
                'تخزين تطوير محلي. لم يُفعّل فحص البرمجيات الضارة.',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
  );
  Widget moneyRow(String label, String amount) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(
        '$amount ريال',
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ],
  );
}
