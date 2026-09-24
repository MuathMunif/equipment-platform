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
        const Text('كل معدة وسجلها، من أول مصروف'),
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
                                  'عرض السجل والمصروفات ←',
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

  Future<void> add() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) =>
            ExpenseForm(api: widget.api, equipment: widget.equipment!),
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
                    onPressed: add,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مصروف'),
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
        const Text('المصروف والدفعة والمرفقات في عملية واحدة'),
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
                '${categories[entry['category']]} • ${entry['equipmentName']}',
              ),
              subtitle: Text('${entry['operationDate']} ميلادي\nمدفوع كاملًا'),
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
  const ExpenseForm({super.key, required this.api, required this.equipment});
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(), note = TextEditingController();
  String category = 'FUEL',
      date = todayRiyadh(),
      paidOn = todayRiyadh(),
      key = requestKey();
  String? error;
  bool busy = false, uncertain = false, saved = false;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
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
          'equipmentId': widget.equipment['id'],
          'amount': exactMoney(amount.text),
          'category': category,
          'operationDate': date,
          'paidOn': paidOn,
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
      appBar: AppBar(title: const Text('إضافة مصروف')),
      body: Form(
        key: form,
        child: FormBody(
          children: [
            Text(
              widget.equipment['name'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('يُسجّل هذا المصروف على هذه المعدة'),
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
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'نوع المصروف'),
              items: categories.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
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
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: brand),
                title: Text('دفعته كاملًا'),
                subtitle: Text('تُحفظ دفعة بقيمة المصروف داخل العملية'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: busy || uncertain ? null : () => pickDate(true),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('تاريخ الدفع: $paidOn ميلادي'),
            ),
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
            const Text('يمكنك إرفاق صورة الفاتورة أو PDF بعد حفظ المصروف.'),
            InlineError(error),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('saveExpense'),
              onPressed: busy ? null : save,
              child: Text(
                busy
                    ? 'جارٍ حفظ المصروف…'
                    : uncertain
                    ? 'إعادة محاولة الحفظ نفسه'
                    : 'حفظ المصروف',
              ),
            ),
          ],
        ),
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
  List<dynamic> attachments = [];
  String? error, uploadError, uploadId;
  bool loading = true, uploading = false;
  Uint8List? pendingBytes;
  String? pendingName, pendingType;
  String uploadKey = requestKey();
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
          const SnackBar(content: Text('حُفظ المرفق داخل المصروف')),
        );
        await load();
      }
    } catch (e) {
      if (mounted) {
        setState(() => uploadError = 'حُفظ المصروف، وتعذر رفع المرفق. $e');
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
                        semanticLabel: 'مرفق المصروف: ${file['filename']}',
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
      title: const Text('تفاصيل المصروف'),
      actions: [
        IconButton(
          tooltip: 'تحديث المصروف',
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
                '${categories[entry!['category']]} • ${entry!['equipmentName']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${entry!['operationDate']} ميلادي'),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      moneyRow('إجمالي المصروف', entry!['amount']),
                      const Divider(height: 32),
                      moneyRow('المدفوع', entry!['paid']),
                      const SizedBox(height: 16),
                      moneyRow('المتبقي عليك', entry!['remaining']),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Chip(
                          avatar: Icon(
                            Icons.check_circle_outline,
                            color: brand,
                          ),
                          label: Text('مدفوع كاملًا'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('الدفعات', style: Theme.of(context).textTheme.titleLarge),
              ...((entry!['settlements'] as List).map(
                (s) => ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text('${s['amount']} ريال سعودي'),
                  subtitle: Text('دُفعت في ${s['paidOn']} ميلادي'),
                ),
              )),
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
                const Text('لم تُضف مرفقات بعد؛ المصروف محفوظ.'),
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
