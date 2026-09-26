import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';

import 'api.dart';
import 'file_export.dart';
import 'documents.dart';
import 'maintenance.dart';
import 'team.dart';
import 'projects.dart';
import 'reports.dart';
import 'localization.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(EquipmentApp(api: Api()));
}

const brand = Color(0xff176c66);
const categoryCodes = ['FUEL', 'MAINTENANCE', 'OTHER'];

String localizedCategory(BuildContext context, Object? code) => switch (code) {
  'FUEL' => l10n(context).categoryFuel,
  'MAINTENANCE' => l10n(context).categoryMaintenance,
  _ => l10n(context).other,
};

String localizedFinancialStatus(
  BuildContext context,
  bool income,
  Object? code,
) {
  final loc = l10n(context);
  if (income) {
    return switch (code) {
      'PAID' => loc.receivedFull,
      'PARTIAL' => loc.receivedPartial,
      _ => loc.unreceived,
    };
  }
  return switch (code) {
    'PAID' => loc.paidFull,
    'PARTIAL' => loc.paidPartial,
    _ => loc.unpaid,
  };
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
  late Locale locale = initialLocale(
    null,
    WidgetsBinding.instance.platformDispatcher.locale,
  );
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
      locale = initialLocale(
        user?['preferredLocale'] as String?,
        WidgetsBinding.instance.platformDispatcher.locale,
      );
    } on ApiError catch (e) {
      if (e.status != 401) startupError = localizedErrorForLocale(locale, e);
    } catch (_) {
      startupError = lookupAppLocalizations(locale).restoreFailed;
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> loggedIn() async {
    final current = await widget.api.me();
    if (mounted) {
      setState(() {
        user = current;
        locale = initialLocale(
          current['preferredLocale'] as String?,
          WidgetsBinding.instance.platformDispatcher.locale,
        );
      });
    }
  }

  Future<void> changeLocale(String languageCode) async {
    final updated = await widget.api.updatePreferredLocale(languageCode);
    if (mounted) {
      setState(() {
        user = updated;
        locale = Locale(languageCode);
      });
    }
  }

  Future<void> reloadUser() async {
    final updated = await widget.api.me();
    if (mounted) setState(() => user = updated);
  }

  Future<void> selectWorkspace(String id) async {
    await widget.api.selectWorkspace(id);
    await reloadUser();
  }

  Future<void> logout() async {
    try {
      await widget.api.json('POST', '/auth/logout');
      await widget.api.clear();
      if (mounted) setState(() => user = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(navigator.currentContext!)
            .showSnackBar(SnackBar(content: Text(localizedError(context, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigator,
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => l10n(context).appTitle,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        : WorkspacePage(
            key: ValueKey(widget.api.workspace),
            api: widget.api,
            user: user!,
            logout: logout,
            changeLocale: changeLocale,
            reloadUser: reloadUser,
            selectWorkspace: selectWorkspace,
          ),
  );
}

class DevNotice extends StatelessWidget {
  const DevNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: const Color(0xffeef3de),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      l10n(context).devNotice,
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
          OutlinedButton(onPressed: retry, child: Text(l10n(context).retry)),
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
      setState(() => error = l10n(context).uiEnterYourNameToContinue);
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
      if (mounted) setState(() => error = localizedError(context, e));
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
                  l10n(context).appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n(context).uiYourEquipmentAndExpensesInOnePlace,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  needsName
                      ? l10n(context).uiWhatShouldWeCallYou
                      : challenge == null
                      ? l10n(context).uiStartWithYourMobileNumber
                      : l10n(context).uiEnterTheVerificationCode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                if (challenge == null) ...[
                  TextField(
                    key: const Key('phone'),
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: l10n(context).phoneNumber,
                      hintText: '0500000001',
                    ),
                    onSubmitted: (_) => busy ? null : submit(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n(context).uiDevelopmentNumbers0500000001Or0500000002,
                    textDirection: TextDirection.rtl,
                  ),
                ] else if (needsName)
                  TextField(
                    key: const Key('ownerName'),
                    controller: name,
                    autofocus: true,
                    maxLength: 100,
                    decoration: InputDecoration(labelText: l10n(context).name),
                    onSubmitted: (_) => busy ? null : submit(),
                  )
                else ...[
                  Text(l10n(context).verifyPhone(phone.text)),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('otp'),
                    controller: code,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    decoration: InputDecoration(
                      labelText: l10n(context).signInCode,
                      helperText: l10n(context).uiDevelopmentCodeOnly123456,
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
                        ? l10n(context).uiVerifying
                        : needsName
                        ? l10n(context).uiStartByAddingYourEquipment
                        : challenge == null
                        ? l10n(context).uiRequestVerificationCode
                        : l10n(context).uiConfirmCode,
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
                    child: Text(l10n(context).uiChangeNumberOrRequestANewCode),
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
  final Future<void> Function(String)? changeLocale;
  final Future<void> Function()? reloadUser;
  final Future<void> Function(String)? selectWorkspace;
  const WorkspacePage({
    super.key,
    required this.api,
    required this.user,
    required this.logout,
    this.changeLocale,
    this.reloadUser,
    this.selectWorkspace,
  });
  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  int selected = 0;
  int driverSelected = 0;
  int revision = 0;
  void openSettings() => Navigator.push(context, MaterialPageRoute(builder: (_) =>
    _SettingsPage(user: widget.user, api: widget.api,
      changeLocale: widget.changeLocale, selectWorkspace: widget.selectWorkspace)));
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final spaces = (widget.user['workspaces'] as List<dynamic>? ?? []);
    final active = spaces
        .where((space) => space['id'] == widget.api.workspace)
        .firstOrNull;
    final role = active?['role'];
    final capabilities = (active?['capabilities'] as List<dynamic>? ?? [])
        .toSet();
    final isDriver = role == 'DRIVER';
    final canEquipment = role == null || role == 'OWNER' || capabilities.contains('EQUIPMENT_VIEW');
    final canTeam = role == 'OWNER' || capabilities.contains('TEAM_MANAGE');
    final canAssignDrivers =
        role == 'OWNER' || capabilities.contains('DRIVER_ASSIGNMENT_MANAGE');
    final canReview =
        role == 'OWNER' || capabilities.contains('FINANCE_REVIEW');
    final canFinance =
        role == null ||
        role == 'OWNER' ||
        capabilities.contains('FINANCE_VIEW');
    final canDirectFinance =
        (role == null ||
            role == 'OWNER' ||
            capabilities.contains('FINANCE_MANAGE')) &&
        (active?['financialMode'] == null ||
            active?['financialMode'] == 'DIRECT');
    final canSubmitReview =
        capabilities.contains('FINANCE_MANAGE') &&
        active?['financialMode'] == 'REVIEW';
    final canMaintain =
        role == null ||
        role == 'OWNER' ||
        capabilities.contains('ISSUE_VIEW') ||
        capabilities.contains('MAINTENANCE_VIEW');
    final canOrganizations =
        role == 'OWNER' || capabilities.contains('ORGANIZATION_VIEW');
    final canProjects =
        role == 'OWNER' || capabilities.contains('PROJECT_VIEW');
    final canManageOrganizations =
        role == 'OWNER' || capabilities.contains('ORGANIZATION_MANAGE');
    final canManageProjects =
        role == 'OWNER' || capabilities.contains('PROJECT_MANAGE');
    final destinations = <(IconData, String, Widget)>[
      (
        Icons.home_outlined,
        l10n(context).home,
        EquipmentList(
          key: ValueKey('home-$revision'),
          api: widget.api,
          home: true,
          name: widget.user['name'],
          canManage:
              role == null ||
              role == 'OWNER' ||
              capabilities.contains('EQUIPMENT_MANAGE'),
          canFinance: canFinance,
          canEquipment: canEquipment,
          canFinanceManage: canDirectFinance,
          canSubmitReview: canSubmitReview,
          canDocuments:
              role == null ||
              role == 'OWNER' ||
              capabilities.contains('DOCUMENT_VIEW'),
          canMaintenance: canMaintain,
          canAssignDrivers: canAssignDrivers,
        ),
      ),
      if (canEquipment) (
        Icons.local_shipping_outlined,
        l10n(context).equipment,
        EquipmentList(
          key: ValueKey('equipment-$revision'),
          api: widget.api,
          home: false,
          name: widget.user['name'],
          canManage:
              role == null ||
              role == 'OWNER' ||
              capabilities.contains('EQUIPMENT_MANAGE'),
          canFinance: canFinance,
          canEquipment: canEquipment,
          canFinanceManage: canDirectFinance,
          canSubmitReview: canSubmitReview,
          canDocuments:
              role == null ||
              role == 'OWNER' ||
              capabilities.contains('DOCUMENT_VIEW'),
          canMaintenance: canMaintain,
          canAssignDrivers: canAssignDrivers,
        ),
      ),
      if (canFinance)
        (
          Icons.receipt_long_outlined,
          l10n(context).ledger,
          LedgerPage(
            key: ValueKey('ledger-$revision'),
            api: widget.api,
            canManage: canDirectFinance,
            canSubmitReview: canSubmitReview,
          ),
        ),
      (
        Icons.more_horiz,
        l10n(context).m7More,
        _MoreMenu(api: widget.api, canReports: canFinance && (role == 'OWNER' || capabilities.contains('REPORT_VIEW')),
          canMaintain: canMaintain, canOrganizations: canOrganizations, canProjects: canProjects,
          canManageOrganizations: canManageOrganizations, canManageProjects: canManageProjects,
          canFinance: canFinance, canTeam: canTeam, canReview: canReview,
          owner: role == 'OWNER', canAssignDrivers: canAssignDrivers, onSettings: openSettings),
      ),
    ];
    final current = selected.clamp(0, destinations.length - 1);
    final content = isDriver
        ? DriverHomePage(
            key: ValueKey('driver-$revision'),
            api: widget.api,
            financialMode: active?['financialMode'] as String? ?? 'REVIEW',
            userId: widget.user['userId'] as String?,
            section: driverSelected,
            onSettings: openSettings,
            reloadUser: widget.reloadUser,
          )
        : destinations[current].$3;
    return Scaffold(
      appBar: AppBar(
        title: Text(active?['name'] as String? ?? l10n(context).appTitle),
        actions: [
          PopupMenuButton<String>(
            key: const Key('workspaceMenu'),
            tooltip: l10n(context).settings,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              if (spaces.length > 1)
                PopupMenuItem(
                  value: 'switch',
                  key: const Key('switchWorkspace'),
                  child: Text(l10n(context).m5SwitchWorkspace),
                ),
              PopupMenuItem(
                value: 'invitations',
                key: const Key('myInvitations'),
                child: Text(l10n(context).m5MyInvitations),
              ),
              if (canTeam)
                PopupMenuItem(
                  value: 'team',
                  key: const Key('openTeam'),
                  child: Text(l10n(context).m5Team),
                ),
              if (canReview)
                PopupMenuItem(
                  value: 'review',
                  key: const Key('openReviewQueue'),
                  child: Text(l10n(context).m5ReviewQueue),
                ),
              PopupMenuItem(
                value: 'refresh',
                child: Text(l10n(context).refresh),
              ),
              PopupMenuItem(value: 'logout', child: Text(l10n(context).logout)),
            ],
            onSelected: (value) async {
              if (value == 'refresh') {
                setState(() => revision++);
                return;
              }
              if (value == 'logout') {
                widget.logout();
                return;
              }
              if (value == 'invitations') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccountInvitationsPage(
                      api: widget.api,
                      changed: widget.reloadUser ?? () async {},
                    ),
                  ),
                );
                return;
              }
              if (value == 'team') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamPage(
                      api: widget.api,
                      owner: role == 'OWNER',
                      canAssign:
                          role == 'OWNER' ||
                          capabilities.contains('DRIVER_ASSIGNMENT_MANAGE'),
                    ),
                  ),
                );
                return;
              }
              if (value == 'review') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewQueuePage(api: widget.api),
                  ),
                );
                return;
              }
              final choice = await showDialog<String>(
                context: context,
                builder: (dialog) => SimpleDialog(
                  title: Text(l10n(dialog).m5SwitchWorkspace),
                  children: [
                    for (final space in spaces)
                      SimpleDialogOption(
                        onPressed: () =>
                            Navigator.pop(dialog, space['id'] as String),
                        child: Text(
                          '${space['name']} • ${m5Role(dialog, space['role'])}',
                        ),
                      ),
                  ],
                ),
              );
              if (choice == null ||
                  choice == widget.api.workspace ||
                  !context.mounted) {
                return;
              }
              try {
                await widget.selectWorkspace?.call(choice);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizedError(context, e))),
                  );
                }
              }
            },
          ),
          NotificationButton(
            key: ValueKey('notifications-$revision'),
            api: widget.api,
          ),
          IconButton(
            key: const Key('languageSettings'),
            tooltip: l10n(context).language,
            onPressed: () async {
              final choice = await showDialog<String>(
                context: context,
                builder: (dialog) => SimpleDialog(
                  title: Text(l10n(dialog).language),
                  children: [
                    for (final (code, name) in [
                      ('ar', l10n(context).uiText102),
                      ('en', 'English'),
                      ('ur', l10n(context).uiText054),
                    ])
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(dialog, code),
                        child: Text(name),
                      ),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (choice == null ||
                  choice == Localizations.localeOf(context).languageCode) {
                return;
              }
              try {
                await widget.changeLocale?.call(choice);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizedError(context, e))),
                  );
                }
              }
            },
            icon: const Icon(Icons.language),
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
                if (wide && !isDriver)
                  NavigationRail(
                    extended: true,
                    selectedIndex: current,
                    onDestinationSelected: (i) => setState(() => selected = i),
                    destinations: [
                      for (final item in destinations)
                        NavigationRailDestination(
                          icon: Icon(item.$1),
                          label: Text(item.$2),
                        ),
                    ],
                  ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDriver
          ? NavigationBar(selectedIndex: driverSelected,
              onDestinationSelected: (i) => setState(() => driverSelected = i),
              destinations: [
                NavigationDestination(icon: const Icon(Icons.local_shipping_outlined), label: l10n(context).equipment),
                NavigationDestination(icon: const Icon(Icons.report_outlined), label: l10n(context).m5MyIssues),
                NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: l10n(context).m5MySubmissions),
                NavigationDestination(icon: const Icon(Icons.more_horiz), label: l10n(context).m7More),
              ])
          : wide ? null : NavigationBar(
              selectedIndex: current,
              onDestinationSelected: (i) => setState(() => selected = i),
              destinations: [
                for (final item in destinations)
                  NavigationDestination(icon: Icon(item.$1), label: item.$2),
              ],
            ),
    );
  }
}

class EquipmentList extends StatefulWidget {
  final Api api;
  final bool home;
  final String name;
  final bool canManage,
      canEquipment,
      canFinance,
      canFinanceManage,
      canSubmitReview,
      canDocuments,
      canMaintenance,
      canAssignDrivers;
  const EquipmentList({
    super.key,
    required this.api,
    required this.home,
    required this.name,
    this.canManage = true,
    this.canEquipment = true,
    this.canFinance = true,
    this.canFinanceManage = true,
    this.canSubmitReview = false,
    this.canDocuments = true,
    this.canMaintenance = true,
    this.canAssignDrivers = false,
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
    if (widget.canEquipment) { load(); } else { loading = false; }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> load() async {
    if (!widget.canEquipment) return;
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
      if (mounted) setState(() => error = localizedError(context, e));
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
          builder: (_) => EquipmentDetail(
            api: widget.api,
            equipment: created,
            canManage: widget.canManage,
            canFinance: widget.canFinance,
            canFinanceManage: widget.canFinanceManage,
            canSubmitReview: widget.canSubmitReview,
            canDocuments: widget.canDocuments,
            canMaintenance: widget.canMaintenance,
            canAssignDrivers: widget.canAssignDrivers,
          ),
        ),
      );
      load();
    }
  }

  Widget firstUseCard() => Card(
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
                    l10n(context).addFirstEquipment,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n(context).uiStartWithEquipmentNameAndModel),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('addEquipment'),
                    onPressed: add,
                    icon: const Icon(Icons.add),
                    label: Text(l10n(context).addEquipment),
                  ),
                ],
              ),
            ),
          );

  @override
  Widget build(BuildContext context) {
    if (loading && !widget.home) return const Center(child: CircularProgressIndicator());
    if (error != null && !widget.home) return ErrorPanel(message: error!, retry: load);
    return ListView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width > 850 ? 32 : 20),
      children: [
        Text(
          widget.home
              ? '${l10n(context).home} • ${widget.name}'
              : l10n(context).equipment,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (widget.canEquipment) Text(l10n(context).equipmentSubtitle),
        const SizedBox(height: 24),
        if (widget.home && widget.canEquipment && !loading && error == null && items.isEmpty && search.text.isEmpty && widget.canManage) ...[
          firstUseCard(),
          const SizedBox(height: 12),
        ],
        if (widget.home) ...[
          HomeDocumentAttention(api: widget.api, showIncomplete: widget.canDocuments),
          DashboardSection(api: widget.api, canFinance: widget.canFinance,
            canEquipment: widget.canEquipment, canManage: widget.canFinanceManage, canSubmitReview: widget.canSubmitReview),
          const SizedBox(height: 20),
        ],
        if (widget.canEquipment && loading) const Center(child: CircularProgressIndicator()),
        if (widget.canEquipment && error != null) ErrorPanel(message: error!, retry: load),
        if (widget.canEquipment && !loading && error == null) Row(
          children: [
            Expanded(
              child: TextField(
                controller: search,
                decoration: InputDecoration(
                  labelText: l10n(context).searchEquipment,
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
              tooltip: l10n(context).uiSearch,
              onPressed: () {
                page = 0;
                load();
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (!widget.home && !loading && error == null && items.isEmpty && search.text.isEmpty && widget.canManage)
          firstUseCard()
        else if (widget.canEquipment && !loading && error == null && !(widget.home && items.isEmpty && search.text.isEmpty && widget.canManage)) ...[
          if (widget.canManage)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                key: const Key('addEquipment'),
                onPressed: add,
                icon: const Icon(Icons.add),
                label: Text(l10n(context).addEquipment),
              ),
            ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            Text(
              search.text.isEmpty
                  ? l10n(context).noEquipmentMatches
                  : l10n(context).uiNoMatchingEquipment,
            ),
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
                                canManage: widget.canManage,
                                canFinance: widget.canFinance,
                                canFinanceManage: widget.canFinanceManage,
                                canSubmitReview: widget.canSubmitReview,
                                canDocuments: widget.canDocuments,
                                canMaintenance: widget.canMaintenance,
                                canAssignDrivers: widget.canAssignDrivers,
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
                                Text(
                                  l10n(context).modelValue('${item['model']}'),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item['reference'],
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n(context).uiViewRecordsAndEntries,
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
              child: Text(l10n(context).previous),
            ),
            Text('${page + 1}'),
            TextButton(
              onPressed: (page + 1) * 30 < total
                  ? () => change(page + 1)
                  : null,
              child: Text(l10n(context).next),
            ),
          ],
        );
}

Future<bool> confirmLeave(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n(context).uiLeaveThisForm),
        content: Text(l10n(context).uiUnsavedDataWillBeLostIfYou),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n(context).uiContinueEntry),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n(context).uiLeave),
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
          error = localizedError(context, e);
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
      appBar: AppBar(title: Text(l10n(context).addEquipment)),
      body: Form(
        key: form,
        child: FormBody(
          children: [
            Text(l10n(context).uiNameAndModelAreEnoughToStart),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('equipmentName'),
              controller: name,
              enabled: !busy && !uncertain,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: l10n(context).uiEquipmentName,
                hintText: l10n(context).uiTipper1,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n(context).uiEnterEquipmentName
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('equipmentModel'),
              controller: model,
              enabled: !busy && !uncertain,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: l10n(context).model,
                hintText: l10n(context).ui2021OrFh16,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n(context).uiEnterModel
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            InlineError(error),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('saveEquipment'),
              onPressed: busy ? null : save,
              child: Text(
                busy
                    ? l10n(context).uiSavingEquipment
                    : uncertain
                    ? l10n(context).uiRetryTheSameSave
                    : l10n(context).uiSaveEquipment,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class EquipmentDetail extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final bool canManage,
      canFinance,
      canFinanceManage,
      canSubmitReview,
      canDocuments,
      canMaintenance,
      canAssignDrivers;
  const EquipmentDetail({
    super.key,
    required this.api,
    required this.equipment,
    this.canManage = true,
    this.canFinance = true,
    this.canFinanceManage = true,
    this.canSubmitReview = false,
    this.canDocuments = true,
    this.canMaintenance = true,
    this.canAssignDrivers = false,
  });
  @override
  State<EquipmentDetail> createState() => _EquipmentDetailState();
}

class _EquipmentDetailState extends State<EquipmentDetail> {
  late Map<String, dynamic> equipment;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    equipment = Map<String, dynamic>.from(widget.equipment);
  }

  Future<void> toggleArchive() async {
    final archived = equipment['archivedAt'] != null;
    if (!archived) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l10n(context).uiArchiveEquipment007),
          content: Text(l10n(context).m4ArchivedWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(l10n(context).back),
            ),
            FilledButton(
              key: const Key('confirmEquipmentArchive'),
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(l10n(context).uiArchiveEquipment),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => busy = true);
    try {
      final result = await widget.api.json(
        'POST',
        widget.api.scoped(
          '/equipment/${equipment['id']}/${archived ? 'restore' : 'archive'}',
        ),
      ) as Map<String, dynamic>;
      if (mounted) setState(() => equipment = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizedError(context, e))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(equipment['name']),
      actions: [
        if (widget.canAssignDrivers && equipment['archivedAt'] == null)
          IconButton(
            key: const Key('openEquipmentDriverAssignment'),
            tooltip: l10n(context).m5DriverAssignment,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EquipmentDriverAssignmentPage(
                  api: widget.api,
                  equipment: equipment,
                ),
              ),
            ),
            icon: const Icon(Icons.person_pin_outlined),
          ),
        if (widget.canManage)
          TextButton(
            key: const Key('toggleEquipmentArchive'),
            onPressed: busy ? null : toggleArchive,
            child: Text(
              equipment['archivedAt'] == null
                  ? l10n(context).uiArchiveEquipment
                  : l10n(context).uiRestoreEquipment,
            ),
          ),
      ],
    ),
    body: widget.canFinance
        ? LedgerPage(
            api: widget.api,
            equipment: equipment,
            canManage: widget.canFinanceManage,
            canSubmitReview: widget.canSubmitReview,
            canDocuments: widget.canDocuments,
            canMaintenance: widget.canMaintenance,
          )
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '${equipment['name']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(l10n(context).modelValue('${equipment['model']}')),
              Text('${equipment['reference']}'),
              EquipmentM6Context(
                api: widget.api,
                equipment: equipment,
                canManage: widget.canManage,
                canProjects:
                    widget.api.capabilities?.contains('PROJECT_VIEW') ?? false,
                canFinance: widget.canFinance,
              ),
              if (widget.canSubmitReview)
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubmissionFormPage(
                        api: widget.api,
                        equipment: equipment,
                      ),
                    ),
                  ),
                  child: Text(l10n(context).m5SubmitExpense),
                ),
            ],
          ),
  );
}

class LedgerPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? equipment;
  final bool canManage;
  final bool canSubmitReview;
  final bool canDocuments, canMaintenance;
  final String? initialEntryType, initialFromDate, initialToDate;
  const LedgerPage({
    super.key,
    required this.api,
    this.equipment,
    this.canManage = true,
    this.canSubmitReview = false,
    this.canDocuments = true,
    this.canMaintenance = true,
    this.initialEntryType, this.initialFromDate, this.initialToDate,
  });
  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  List<dynamic> items = [];
  String? error;
  bool loading = true;
  int page = 0, total = 0;
  final searchController = TextEditingController();
  String search = '';
  String? entryType, lifecycle, settlementStatus;
  bool? generalExpense;
  DateTime? fromDate, toDate;
  Map<String, dynamic>? filterEquipment;
  bool filtersExpanded = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool get hasFilters =>
      search.isNotEmpty ||
      entryType != null ||
      lifecycle != null ||
      settlementStatus != null ||
      generalExpense != null ||
      fromDate != null ||
      toDate != null ||
      filterEquipment != null;

  void applyFilter() {
    page = 0;
    load();
  }

  void clearFilters() {
    searchController.clear();
    setState(() {
      search = '';
      entryType = null;
      lifecycle = null;
      settlementStatus = null;
      generalExpense = null;
      fromDate = null;
      toDate = null;
      filterEquipment = null;
    });
    applyFilter();
  }

  String get listPath {
    final params = <String, String>{'page': '$page'};
    final equipmentId = widget.equipment?['id'] ?? filterEquipment?['id'];
    if (equipmentId != null) params['equipmentId'] = '$equipmentId';
    if (search.isNotEmpty) params['search'] = search;
    if (entryType != null) params['entryType'] = entryType!;
    if (lifecycle != null) params['lifecycle'] = lifecycle!;
    if (settlementStatus != null) {
      params['settlementStatus'] = settlementStatus!;
    }
    if (generalExpense != null) params['generalExpense'] = '$generalExpense';
    if (fromDate != null) {
      params['fromDate'] = fromDate!.toIso8601String().split('T').first;
    }
    if (toDate != null) {
      params['toDate'] = toDate!.toIso8601String().split('T').first;
    }
    return '/entries?${Uri(queryParameters: params).query}';
  }

  @override
  void initState() {
    super.initState();
    entryType = widget.initialEntryType;
    fromDate = widget.initialFromDate == null ? null : DateTime.parse(widget.initialFromDate!);
    toDate = widget.initialToDate == null ? null : DateTime.parse(widget.initialToDate!);
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
        widget.api.scoped(listPath),
      );
      if (mounted) {
        setState(() {
          items = response['items'];
          total = response['total'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add({bool income = false}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ExpenseForm(
          api: widget.api,
          equipment:
              widget.equipment ??
              {'id': null, 'name': l10n(context).uiWorkspace},
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

  Future<void> captureDraft() async {
    if (widget.equipment == null) return;
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            DraftCapturePage(api: widget.api, equipment: widget.equipment!),
      ),
    );
    if (id != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DraftDetailPage(api: widget.api, id: id),
        ),
      );
      load();
    }
  }

  Future<void> showDrafts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DraftListPage(
          api: widget.api,
          equipmentId: widget.equipment?['id'] as String?,
        ),
      ),
    );
    if (mounted) load();
  }

  Future<void> chooseEquipmentFilter() async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => HistoryEquipmentPicker(api: widget.api),
    );
    if (selected != null && mounted) {
      setState(() => filterEquipment = selected);
      applyFilter();
    }
  }

  Future<void> chooseDateFilter({required bool start}) async {
    final first = start ? DateTime(1900) : fromDate ?? DateTime(1900);
    final last = start ? toDate ?? DateTime(2100) : DateTime(2100);
    final preferred = (start ? fromDate : toDate) ?? DateTime.now();
    final initial = preferred.isBefore(first)
        ? first
        : preferred.isAfter(last)
        ? last
        : preferred;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (selected != null && mounted) {
      setState(() {
        if (start) {
          fromDate = selected;
        } else {
          toDate = selected;
        }
      });
      applyFilter();
    }
  }

  Widget historyDropdown({
    required String keyName,
    required String label,
    required String? value,
    required Map<String, String> choices,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    key: Key('$keyName:$value'),
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    isExpanded: true,
    items: [
      DropdownMenuItem(value: '', child: Text(l10n(context).uiAll)),
      ...choices.entries.map(
        (choice) =>
            DropdownMenuItem(value: choice.key, child: Text(choice.value)),
      ),
    ],
    onChanged: (selected) => onChanged(selected == '' ? null : selected),
  );

  Widget historyFilters() => Card(
    child: ExpansionTile(
      key: const Key('historyFilters'),
      title: Text(l10n(context).uiFilterRecords),
      initiallyExpanded: filtersExpanded,
      onExpansionChanged: (expanded) => filtersExpanded = expanded,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        if (hasFilters)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('clearHistoryFilters'),
              onPressed: clearFilters,
              icon: const Icon(Icons.clear_all),
              label: Text(l10n(context).uiClearFilters),
            ),
          ),
        LayoutBuilder(
          builder: (context, box) {
            final width = box.maxWidth >= 760 ? 220.0 : box.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: historyDropdown(
                    keyName: 'filterEntryType',
                    label: l10n(context).uiEntryType,
                    value: entryType,
                    choices: {
                      'EXPENSE': l10n(context).expense,
                      'INCOME': l10n(context).income,
                    },
                    onChanged: (value) {
                      setState(() => entryType = value);
                      applyFilter();
                    },
                  ),
                ),
                SizedBox(
                  width: width,
                  child: historyDropdown(
                    keyName: 'filterLifecycle',
                    label: l10n(context).uiEntryStatus,
                    value: lifecycle,
                    choices: {
                      'POSTED': l10n(context).uiActive,
                      'CANCELLED': l10n(context).cancelled,
                    },
                    onChanged: (value) {
                      setState(() => lifecycle = value);
                      applyFilter();
                    },
                  ),
                ),
                SizedBox(
                  width: width,
                  child: historyDropdown(
                    keyName: 'filterSettlement',
                    label: l10n(context).uiSettlementStatus,
                    value: settlementStatus,
                    choices: {
                      'PAID': l10n(context).uiFullySettled,
                      'PARTIAL': l10n(context).uiPartiallySettled,
                      'UNPAID': l10n(context).uiUnsettled,
                    },
                    onChanged: (value) {
                      setState(() => settlementStatus = value);
                      applyFilter();
                    },
                  ),
                ),
                if (widget.equipment == null)
                  SizedBox(
                    width: width,
                    child: historyDropdown(
                      keyName: 'filterGeneral',
                      label: l10n(context).uiGeneralExpense,
                      value: generalExpense == null
                          ? null
                          : generalExpense!
                          ? 'GENERAL'
                          : 'OTHER',
                      choices: {
                        'GENERAL': l10n(context).uiGeneralExpensesOnly,
                        'OTHER': l10n(context).uiExcludeGeneralExpenses,
                      },
                      onChanged: (value) {
                        setState(
                          () => generalExpense = value == null
                              ? null
                              : value == 'GENERAL',
                        );
                        applyFilter();
                      },
                    ),
                  ),
                SizedBox(
                  width: width,
                  child: OutlinedButton.icon(
                    key: const Key('filterFromDate'),
                    onPressed: () => chooseDateFilter(start: true),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      fromDate == null
                          ? l10n(context).uiFromDate
                          : l10n(context).fromDateValue(
                              localizedDate(
                                context,
                                fromDate!.toIso8601String(),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: OutlinedButton.icon(
                    key: const Key('filterToDate'),
                    onPressed: () => chooseDateFilter(start: false),
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      toDate == null
                          ? l10n(context).uiToDate
                          : l10n(context).toDateValue(
                              localizedDate(context, toDate!.toIso8601String()),
                            ),
                    ),
                  ),
                ),
                if (widget.equipment == null)
                  SizedBox(
                    width: width,
                    child: OutlinedButton.icon(
                      key: const Key('filterEquipment'),
                      onPressed: chooseEquipmentFilter,
                      icon: const Icon(Icons.local_shipping_outlined),
                      label: Text(
                        filterEquipment?['name'] ??
                            l10n(context).uiSelectEquipment051,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return ErrorPanel(message: error!, retry: load);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.equipment == null) ...[
          if (widget.canManage)
            FilledButton.icon(
              key: const Key('addGeneralExpense'),
              onPressed: () => add(),
              icon: const Icon(Icons.add),
              label: Text(l10n(context).uiAddGeneralExpense),
            ),
          const SizedBox(height: 16),
          if (widget.canManage)
            OutlinedButton.icon(
              key: const Key('openDrafts'),
              onPressed: showDrafts,
              icon: const Icon(Icons.pending_actions_outlined),
              label: Text(l10n(context).uiAwaitingCompletion),
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
                  Text(
                    l10n(context).modelValue('${widget.equipment!['model']}'),
                  ),
                  Text(
                    widget.equipment!['reference'],
                    textDirection: TextDirection.ltr,
                  ),
                  EquipmentM6Context(
                    api: widget.api,
                    equipment: widget.equipment!,
                    canManage:
                        widget.api.capabilities?.contains('EQUIPMENT_MANAGE') ??
                        false,
                    canProjects:
                        widget.api.capabilities?.contains('PROJECT_VIEW') ??
                        false,
                    canFinance:
                        widget.api.capabilities?.contains('FINANCE_VIEW') ??
                        false,
                  ),
                  const SizedBox(height: 24),
                  if (widget.canManage)
                    FilledButton.icon(
                      key: const Key('addExpense'),
                      onPressed: () => add(),
                      icon: const Icon(Icons.add),
                      label: Text(l10n(context).addExpense),
                    ),
                  const SizedBox(height: 12),
                  if (widget.canManage)
                    OutlinedButton.icon(
                      key: const Key('addIncome'),
                      onPressed: () => add(income: true),
                      icon: const Icon(Icons.add),
                      label: Text(l10n(context).addIncome),
                    ),
                  const SizedBox(height: 12),
                  if (widget.canManage)
                    OutlinedButton.icon(
                      key: const Key('quickCapture'),
                      onPressed: captureDraft,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        l10n(context).uiSaveInvoiceNowAndCompleteDetailsLater,
                      ),
                    ),
                  if (widget.canSubmitReview)
                    FilledButton.icon(
                      key: const Key('submitExpenseForReview'),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmissionFormPage(
                              api: widget.api,
                              equipment: widget.equipment!,
                            ),
                          ),
                        );
                        if (mounted) load();
                      },
                      icon: const Icon(Icons.send_outlined),
                      label: Text(l10n(context).m5SubmitExpense),
                    ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    key: const Key('openEquipmentDrafts'),
                    onPressed: showDrafts,
                    icon: const Icon(Icons.pending_actions_outlined),
                    label: Text(l10n(context).uiAwaitingCompletion),
                  ),
                ],
              ),
            ),
          ),
        if (widget.equipment != null) ...[
          const SizedBox(height: 16),
          if (widget.canDocuments)
            EquipmentDocumentsCard(
              api: widget.api,
              equipment: widget.equipment!,
            ),
          if (widget.canMaintenance)
            EquipmentMaintenanceCard(
              api: widget.api,
              equipment: widget.equipment!,
            ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.equipment == null
                    ? l10n(context).uiGeneralRecords
                    : l10n(context).uiEquipmentHistory,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: l10n(context).uiRefreshRecords,
              onPressed: load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n(context).uiEachEntryItsPaymentsAndAttachmentsIn),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('historySearch'),
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: l10n(context).searchLedger,
                      hintText: l10n(context)
                          .uiEquipmentNameReferencePartyOrNote,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) {
                      setState(() => search = searchController.text.trim());
                      applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  key: const Key('applyHistorySearch'),
                  tooltip: l10n(context).uiSearch,
                  onPressed: () {
                    setState(() => search = searchController.text.trim());
                    applyFilter();
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        historyFilters(),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                hasFilters
                    ? l10n(context).uiNoEntriesMatchYourSearchOrFilters
                    : l10n(context).noEntries,
              ),
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
                '${entry['entryType'] == 'INCOME' ? l10n(context).income : localizedCategory(context, entry['category'])} • ${entry['expenseScope'] == 'GENERAL'
                    ? l10n(context).generalExpense
                    : entry['expenseScope'] == 'SHARED'
                    ? l10n(context).uiMultipleEquipment
                    : entry['equipmentName']}',
              ),
              subtitle: Text(
                l10n(context).entryDateStatus(
                  localizedDate(context, entry['operationDate'] as String),
                  entry['lifecycle'] == 'CANCELLED'
                      ? l10n(context).cancelled
                      : localizedFinancialStatus(
                          context,
                          entry['entryType'] == 'INCOME',
                          entry['settlementStatus'],
                        ),
                ),
              ),
              isThreeLine: true,
              trailing: Text(
                localizedMoney(context, entry['amount']),
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

class HistoryEquipmentPicker extends StatefulWidget {
  final Api api;
  const HistoryEquipmentPicker({super.key, required this.api});
  @override
  State<HistoryEquipmentPicker> createState() => _HistoryEquipmentPickerState();
}

class _HistoryEquipmentPickerState extends State<HistoryEquipmentPicker> {
  final controller = TextEditingController();
  List<dynamic> items = [];
  bool loading = true;
  int page = 0, total = 0;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final query = Uri(queryParameters: {'search': controller.text.trim(), 'page': '$page'})
          .query;
      final result = await widget.api.json(
        'GET',
        widget.api.scoped('/equipment?$query'),
      );
      if (mounted) setState(() { items = result['items']; total = result['total'] as int; });
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(l10n(context).uiSelectEquipment),
    content: SizedBox(
      width: 520,
      height: 420,
      child: Column(
        children: [
          TextField(
            key: const Key('equipmentFilterSearch'),
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: l10n(context).uiSearchByEquipmentNameOrReference,
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) { page = 0; load(); },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? ErrorPanel(message: error!, retry: load)
                : items.isEmpty
                ? Center(child: Text(l10n(context).noEquipmentMatches))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final equipment = items[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(equipment['name']),
                        subtitle: Text(equipment['reference']),
                        onTap: () => Navigator.pop(context, equipment),
                      );
                    },
                  ),
          ),
          if (total > 30) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(onPressed: page > 0 ? () { page--; load(); } : null, child: Text(l10n(context).previous)),
            TextButton(onPressed: (page + 1) * 30 < total ? () { page++; load(); } : null, child: Text(l10n(context).next)),
          ]),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n(context).uiClose),
      ),
    ],
  );
}

Future<XFile?> pickReceiptFile(BuildContext context) => openFile(
  acceptedTypeGroups: [
    XTypeGroup(
      label: l10n(context).uiImagesAndInvoicePdfs,
      extensions: ['jpg', 'jpeg', 'png', 'pdf'],
      mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
      uniformTypeIdentifiers: ['public.jpeg', 'public.png', 'com.adobe.pdf'],
    ),
  ],
);

String receiptMediaType(BuildContext context, XFile file) {
  final extension = file.name.split('.').last.toLowerCase();
  final type = {
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'pdf': 'application/pdf',
  }[extension];
  if (type == null) {
    throw ApiError(400, 'UNSUPPORTED_FILE', l10n(context).unsupportedFile);
  }
  return type;
}

class DraftCapturePage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final Future<XFile?> Function()? pickFile;
  const DraftCapturePage({
    super.key,
    required this.api,
    required this.equipment,
    this.pickFile,
  });
  @override
  State<DraftCapturePage> createState() => _DraftCapturePageState();
}

class _DraftCapturePageState extends State<DraftCapturePage> {
  final note = TextEditingController();
  final draftKey = requestKey();
  String attachmentKey = requestKey();
  String? draftId, attachmentId, error, filename, mediaType, submittedNote;
  Uint8List? bytes;
  bool busy = false;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> chooseFile() async {
    try {
      final file = await (widget.pickFile?.call() ?? pickReceiptFile(context));
      if (file == null) return;
      final fileSize = await file.length();
      if (!mounted) return;
      if (fileSize > 10 * 1024 * 1024) {
        throw ApiError(413, 'FILE_TOO_LARGE', l10n(context).fileTooLarge);
      }
      if (!mounted) return;
      final type = receiptMediaType(context, file);
      final contents = await file.readAsBytes();
      if (mounted) {
        setState(() {
          filename = file.name;
          mediaType = type;
          bytes = contents;
          attachmentKey = requestKey();
          attachmentId = null;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (draftId == null) {
        submittedNote ??= note.text.trim();
        final draft = await widget.api.json(
          'POST',
          widget.api.scoped('/drafts'),
          key: draftKey,
          body: {'equipmentId': widget.equipment['id'], 'note': submittedNote},
        );
        draftId = draft['id'] as String;
      }
      if (bytes != null) {
        if (attachmentId == null) {
          final file = await widget.api.json(
            'POST',
            widget.api.scoped('/entries/$draftId/attachments'),
            key: attachmentKey,
            body: {
              'filename': filename,
              'mediaType': mediaType,
              'size': bytes!.length,
            },
          );
          attachmentId = file['id'] as String;
        }
        await widget.api.send(
          'PUT',
          widget.api.scoped('/attachments/$attachmentId/content'),
          bytes: bytes,
          type: mediaType,
        );
      }
      if (mounted) Navigator.pop(context, draftId);
    } catch (e) {
      if (draftId == null && e is ApiError && e.status > 0 && e.status < 409) {
        submittedNote = null;
      }
      if (mounted) {
        setState(
          () => error = draftId == null
              ? localizedError(context, e)
              : l10n(context).draftUploadFailed(localizedError(context, e)),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n(context).uiSaveInvoiceNow)),
    body: FormBody(
      children: [
        Text(
          widget.equipment['name'] as String,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(l10n(context).uiAwaitingCompletionThisWillNotCountAs),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const Key('pickDraftAttachment'),
          onPressed: busy || submittedNote != null ? null : chooseFile,
          icon: const Icon(Icons.attach_file),
          label: Text(
            filename == null
                ? l10n(context).uiAddImageOrPdfOptional
                : filename!,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('draftNote'),
          controller: note,
          enabled: !busy && submittedNote == null,
          maxLength: 1000,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n(context).uiNoteOptional),
        ),
        InlineError(error),
        FilledButton(
          key: const Key('saveDraft'),
          onPressed: busy ? null : save,
          child: Text(
            busy
                ? l10n(context).uiSaving170
                : draftId == null
                ? l10n(context).uiSaveInvoiceNowAndCompleteDetailsLater
                : l10n(context).uiRetryFileUpload,
          ),
        ),
        if (draftId != null)
          TextButton(
            key: const Key('openSavedDraft'),
            onPressed: () => Navigator.pop(context, draftId),
            child: Text(l10n(context).uiOpenSavedDraft),
          ),
      ],
    ),
  );
}

class DraftListPage extends StatefulWidget {
  final Api api;
  final String? equipmentId;
  const DraftListPage({super.key, required this.api, this.equipmentId});
  @override
  State<DraftListPage> createState() => _DraftListPageState();
}

class _DraftListPageState extends State<DraftListPage> {
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
          '/drafts?page=$page${widget.equipmentId == null ? '' : '&equipmentId=${widget.equipmentId}'}',
        ),
      );
      if (mounted) {
        setState(() {
          items = response['items'] as List;
          total = response['total'] as int;
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
    appBar: AppBar(title: Text(l10n(context).uiAwaitingCompletion)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? ErrorPanel(message: error!, retry: load)
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (items.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(l10n(context).uiNoInvoicesAwaitingCompletion),
                  ),
                ),
              ...items.map(
                (draft) => Card(
                  child: ListTile(
                    title: Text(draft['equipmentName'] as String),
                    subtitle: Text(
                      (draft['note'] as String).isEmpty
                          ? l10n(context).uiAwaitingCompletion
                          : l10n(context).draftNote(draft['note'] as String),
                    ),
                    isThreeLine: (draft['note'] as String).isNotEmpty,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DraftDetailPage(
                            api: widget.api,
                            id: draft['id'] as String,
                          ),
                        ),
                      );
                      if (mounted) load();
                    },
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
          ),
  );
}

class DraftDetailPage extends StatefulWidget {
  final Api api;
  final String id;
  final Future<XFile?> Function()? pickFile;
  const DraftDetailPage({
    super.key,
    required this.api,
    required this.id,
    this.pickFile,
  });
  @override
  State<DraftDetailPage> createState() => _DraftDetailPageState();
}

class _DraftDetailPageState extends State<DraftDetailPage> {
  Map<String, dynamic>? draft;
  List<dynamic> attachments = [];
  String? error, uploadError, attachmentId, filename, mediaType;
  Uint8List? bytes;
  String attachmentKey = requestKey();
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
      final found = await widget.api.json(
        'GET',
        widget.api.scoped('/drafts/${widget.id}'),
      );
      final files = await widget.api.json(
        'GET',
        widget.api.scoped('/entries/${widget.id}/attachments'),
      );
      if (mounted) {
        setState(() {
          draft = Map<String, dynamic>.from(found);
          attachments = files as List;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> addAttachment() async {
    try {
      final file = await (widget.pickFile?.call() ?? pickReceiptFile(context));
      if (file == null) return;
      final fileSize = await file.length();
      if (!mounted) return;
      if (fileSize > 10 * 1024 * 1024) {
        throw ApiError(413, 'FILE_TOO_LARGE', l10n(context).fileTooLarge);
      }
      if (!mounted) return;
      final type = receiptMediaType(context, file);
      bytes = await file.readAsBytes();
      filename = file.name;
      mediaType = type;
      attachmentId = null;
      attachmentKey = requestKey();
      await upload();
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
    }
  }

  Future<void> upload() async {
    setState(() {
      busy = true;
      uploadError = null;
    });
    try {
      if (attachmentId == null) {
        final result = await widget.api.json(
          'POST',
          widget.api.scoped('/entries/${widget.id}/attachments'),
          key: attachmentKey,
          body: {
            'filename': filename,
            'mediaType': mediaType,
            'size': bytes!.length,
          },
        );
        attachmentId = result['id'] as String;
      }
      await widget.api.send(
        'PUT',
        widget.api.scoped('/attachments/$attachmentId/content'),
        bytes: bytes,
        type: mediaType,
      );
      bytes = null;
      attachmentId = null;
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> openAttachment(Map<String, dynamic> file) async {
    try {
      final response = await widget.api.send(
        'GET',
        widget.api.scoped('/attachments/${file['id']}/content'),
      );
      if (!mounted) return;
      if ((file['mediaType'] as String).startsWith('image/')) {
        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(file['filename'] as String),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: l10n(context).closeAttachment,
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizedError(context, e))));
      }
    }
  }

  Future<void> complete({bool income = false}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ExpenseForm(
          api: widget.api,
          equipment: {
            'id': draft!['equipmentId'],
            'name': draft!['equipmentName'],
          },
          income: income,
          draftId: widget.id,
          draftNote: draft!['note'] as String,
        ),
      ),
    );
    if (result != null && mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EntryDetail(api: widget.api, id: widget.id),
        ),
      );
    }
  }

  Future<void> discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n(context).uiDiscardDraft056),
        content: Text(l10n(context).uiThisWillNotCountAsAFinancial),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n(context).back),
          ),
          FilledButton(
            key: const Key('confirmDiscardDraft'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n(context).uiDiscardDraft),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.json(
        'DELETE',
        widget.api.scoped('/drafts/${widget.id}'),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l10n(context).uiAwaitingCompletion),
      actions: [
        IconButton(
          onPressed: load,
          icon: const Icon(Icons.refresh),
          tooltip: l10n(context).uiUpdateDraft,
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
                draft!['equipmentName'] as String,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(l10n(context).uiThisInvoiceIsSavedForLaterCompletion),
              if ((draft!['note'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(l10n(context).noteValue('${draft!['note']}')),
                ),
              const SizedBox(height: 24),
              Text(
                l10n(context).attachments,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (attachments.isEmpty) Text(l10n(context).noAttachments),
              ...attachments.map(
                (file) => ListTile(
                  title: Text(file['filename'] as String),
                  subtitle: Text(
                    file['state'] == 'READY'
                        ? l10n(context).uiReadyToView
                        : file['state'] == 'FAILED'
                        ? l10n(context).uiUploadFailedTryAgain
                        : l10n(context).uiUploadIncomplete,
                  ),
                  onTap: file['state'] == 'READY'
                      ? () => openAttachment(Map<String, dynamic>.from(file))
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('addDraftAttachment'),
                onPressed: busy ? null : addAttachment,
                icon: const Icon(Icons.attach_file),
                label: Text(l10n(context).uiAddAttachment),
              ),
              if (bytes != null && uploadError != null)
                TextButton(
                  key: const Key('retryDraftAttachment'),
                  onPressed: busy ? null : upload,
                  child: Text(l10n(context).uiRetryFileUpload),
                ),
              InlineError(uploadError),
              const SizedBox(height: 28),
              FilledButton(
                key: const Key('completeDraftExpense'),
                onPressed: busy ? null : () => complete(),
                child: Text(l10n(context).uiCompleteAsExpense),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('completeDraftIncome'),
                onPressed: busy ? null : () => complete(income: true),
                child: Text(l10n(context).uiCompleteAsIncome),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('discardDraft'),
                onPressed: busy ? null : discard,
                child: Text(l10n(context).uiDiscardDraft),
              ),
            ],
          ),
  );
}

class ExpenseForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> equipment;
  final bool income;
  final String initialScope;
  final String? draftId;
  final String? draftNote;
  final String? maintenanceId;
  final String? initialProjectId;
  const ExpenseForm({
    super.key,
    required this.api,
    required this.equipment,
    this.income = false,
    this.initialScope = 'SINGLE',
    this.draftId,
    this.draftNote,
    this.maintenanceId,
    this.initialProjectId,
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
  List<Map<String, dynamic>> projectChoices = [];
  String? projectId;
  bool loadingEquipment = false;
  @override
  void initState() {
    super.initState();
    expenseScope = widget.initialScope;
    if (widget.maintenanceId != null) category = 'MAINTENANCE';
    if (widget.draftNote != null) note.text = widget.draftNote!;
    projectId = widget.initialProjectId;
    if (projectId != null) loadProjectChoices();
  }

  Future<void> loadProjectChoices() async {
    try {
      final response = await widget.api.json(
        'GET',
        widget.api.scoped('/projects'),
      );
      if (mounted) setState(() => projectChoices = m6Rows(response));
    } catch (_) {
      /* Optional classification remains usable without PROJECT_VIEW. */
    }
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
      if (mounted) setState(() => error = localizedError(context, e));
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
          () =>
              error = l10n(context)
                  .uiSelectDifferentEquipmentAndMakeTheirAmounts,
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
        widget.api.scoped(
          widget.draftId == null
              ? widget.maintenanceId == null
                    ? '/entries'
                    : '/maintenance/${widget.maintenanceId}/expenses'
              : '/drafts/${widget.draftId}/completion',
        ),
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
          if (projectId != null) 'projectId': projectId,
        },
      );
      if (mounted) {
        setState(() => saved = true);
        Navigator.pop(context, Map<String, dynamic>.from(result));
      }
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          error = localizedError(context, e);
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
        title: Text(
          widget.income ? l10n(context).addIncome : l10n(context).addExpense,
        ),
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
              Text(l10n(context).uiThisIncomeIsRecordedUnderThisEquipment)
            else if (widget.draftId != null)
              Text(l10n(context).uiCompleteTheSavedInvoiceDetailsItsAttachments)
            else if (widget.equipment['id'] == null)
              Text(l10n(context).uiAWorkspaceExpenseItIsNotAssigned)
            else ...[
              Text(l10n(context).uiSelectTheEquipmentThisExpenseBelongsTo),
              const SizedBox(height: 12),
              if (widget.maintenanceId == null)
                DropdownButtonFormField<String>(
                  key: const Key('expenseScope'),
                  initialValue: expenseScope,
                  decoration: InputDecoration(
                    labelText: l10n(context).uiExpenseAppliesTo276,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'SINGLE',
                      child: Text(l10n(context).uiOneEquipment),
                    ),
                    DropdownMenuItem(
                      value: 'SHARED',
                      child: Text(l10n(context).uiMultipleEquipment),
                    ),
                    DropdownMenuItem(
                      value: 'GENERAL',
                      child: Text(l10n(context).generalExpense),
                    ),
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
              decoration: InputDecoration(
                labelText: l10n(context).uiAmountSar,
                hintText: '350.00',
              ),
              validator: (v) => exactMoney(v ?? '') == null
                  ? l10n(context).uiEnterAnAmountAboveZeroUpTo
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            if (!widget.income && expenseScope == 'SHARED') ...[
              const SizedBox(height: 16),
              Text(
                l10n(context).uiAmountPerEquipment,
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
                        decoration: InputDecoration(
                          labelText: l10n(context).uiEquipment,
                        ),
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
                        validator: (value) => value == null
                            ? l10n(context).uiSelectEquipment051
                            : null,
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
                        decoration: InputDecoration(
                          labelText: l10n(context).uiAmount,
                        ),
                        validator: (value) => exactMoney(value ?? '') == null
                            ? l10n(context).uiEnterAValidAmount
                            : null,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (parts.length > 2)
                      IconButton(
                        key: Key('removeAllocation${item.key}'),
                        tooltip: l10n(context).uiRemoveEquipment,
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
                label: Text(l10n(context).addEquipment),
              ),
              Text(
                l10n(context).allocationRemaining(
                  localizedMoney(
                    context,
                    (() {
                      final total = exactMoney(amount.text);
                      if (total == null) return '—';
                      final assigned = parts
                          .map((p) => exactMoney(p.amount.text))
                          .whereType<String>()
                          .fold<BigInt>(
                            BigInt.zero,
                            (s, v) => s + BigInt.parse(v.replaceAll('.', '')),
                          );
                      final difference =
                          BigInt.parse(total.replaceAll('.', '')) - assigned;
                      final absolute = difference.abs().toString().padLeft(
                        3,
                        '0',
                      );
                      return '${difference.isNegative ? '-' : ''}${absolute.substring(0, absolute.length - 2)}.${absolute.substring(absolute.length - 2)}';
                    })(),
                  ),
                ),
                key: const Key('allocationRemaining'),
              ),
            ],
            const SizedBox(height: 20),
            if (!widget.income)
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: l10n(context).uiExpenseType,
                ),
                items: categoryCodes
                    .map(
                      (code) => DropdownMenuItem(
                        value: code,
                        child: Text(localizedCategory(context, code)),
                      ),
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
              label: Text(
                l10n(context).operationDate(localizedDate(context, date)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('paymentStatus'),
              initialValue: paymentStatus,
              decoration: InputDecoration(
                labelText: widget.income
                    ? l10n(context).uiReceiptStatus
                    : l10n(context).uiPaymentStatus,
              ),
              items: widget.income
                  ? [
                      DropdownMenuItem(
                        value: 'FULL',
                        child: Text(l10n(context).uiReceivedInFull),
                      ),
                      DropdownMenuItem(
                        value: 'PARTIAL',
                        child: Text(l10n(context).uiPartiallyReceived),
                      ),
                      DropdownMenuItem(
                        value: 'UNPAID',
                        child: Text(l10n(context).uiNotReceived),
                      ),
                    ]
                  : [
                      DropdownMenuItem(
                        value: 'FULL',
                        child: Text(l10n(context).uiPaidInFull),
                      ),
                      DropdownMenuItem(
                        value: 'PARTIAL',
                        child: Text(l10n(context).uiPaidPartOfIt),
                      ),
                      DropdownMenuItem(
                        value: 'UNPAID',
                        child: Text(l10n(context).uiNotPaid),
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
                      ? l10n(context).uiInitialReceipt
                      : l10n(context).uiInitialPayment,
                ),
                validator: (v) {
                  final first = exactMoney(v ?? '');
                  final total = exactMoney(amount.text);
                  if (first == null ||
                      total == null ||
                      BigInt.parse(first.replaceAll('.', '')) >=
                          BigInt.parse(total.replaceAll('.', ''))) {
                    return l10n(context).uiEnterAnAmountAboveZeroAndBelow;
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
                  widget.income
                      ? l10n(context)
                            .receiptDate(localizedDate(context, paidOn))
                      : l10n(context)
                            .paymentDate(localizedDate(context, paidOn)),
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
                      ? l10n(context).uiNameOfThePartyWhoWillPay
                      : l10n(context).uiNameOfThePartyOwed,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n(context).uiEnterPartyName
                    : null,
              ),
              OutlinedButton.icon(
                onPressed: busy || uncertain ? null : pickDueDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  dueDate == null
                      ? l10n(context).uiDueDateOptional
                      : l10n(context)
                            .dueDateValue(localizedDate(context, dueDate)),
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
              decoration: InputDecoration(
                labelText: l10n(context).uiNoteOptional,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (widget.maintenanceId == null)
              ExpansionTile(
                title: Text(l10n(context).m6AdditionalDetails),
                onExpansionChanged: (expanded) {
                  if (expanded) loadProjectChoices();
                },
                children: [
                  DropdownButtonFormField<String?>(
                    key: const Key('financeProject'),
                    initialValue: projectId,
                    decoration: InputDecoration(
                      labelText: l10n(context).m6ProjectClassification,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n(context).m6NoProjects),
                      ),
                      if (projectId != null &&
                          !projectChoices.any((p) => p['id'] == projectId))
                        DropdownMenuItem<String?>(
                          value: projectId,
                          child: Text(l10n(context).m6ProjectsContracts),
                        ),
                      for (final project in projectChoices)
                        DropdownMenuItem<String?>(
                          value: '${project['id']}',
                          child: Text('${project['name']}'),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (v) => setState(() => projectId = v),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              l10n(context).attachmentAfterSave(
                widget.income ? l10n(context).income : l10n(context).expense,
              ),
            ),
            InlineError(error),
            const SizedBox(height: 16),
            FilledButton(
              key: Key(widget.income ? 'saveIncome' : 'saveExpense'),
              onPressed: busy ? null : save,
              child: Text(
                busy
                    ? l10n(context).savingKind(
                        widget.income
                            ? l10n(context).income
                            : l10n(context).expense,
                      )
                    : uncertain
                    ? l10n(context).uiRetryTheSameSave
                    : l10n(context).saveKind(
                        widget.income
                            ? l10n(context).income
                            : l10n(context).expense,
                      ),
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
  late String category, date, expenseScope;
  String? selectedEquipment;
  String? dueDate, error;
  bool busy = false;
  bool get income => widget.entry['entryType'] == 'INCOME';
  bool get shared => expenseScope == 'SHARED';
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
    expenseScope = widget.entry['expenseScope'] ?? 'SINGLE';
    selectedEquipment = widget.entry['equipmentId'];
    if (shared) {
      for (final allocation in widget.entry['allocations'] as List) {
        final part = _ExpensePart(allocation['equipmentId'] as String);
        part.amount.text = allocation['amount'] as String;
        parts.add(part);
      }
    }
    if (!income) loadEquipmentChoices();
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
      if (mounted) setState(() => error = localizedError(context, e));
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
    if (shared) {
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
          () =>
              error = l10n(context)
                  .uiSelectDifferentEquipmentAndMakeTheirAmounts,
        );
        return;
      }
    }
    final settled = BigInt.parse(
      (widget.entry['netPaid'] as String).replaceAll('.', ''),
    );
    final total = BigInt.parse(exactMoney(amount.text)!.replaceAll('.', ''));
    if (hasCash && exactMoney(amount.text) != widget.entry['amount']) {
      setState(() => error = l10n(context).uiTheTotalCannotChangeAfterAPayment);
      return;
    }
    if (total == settled && dueDate != null) {
      setState(() => error = l10n(context).uiRemoveTheDueDateOnceFullyPaid);
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
          if (!income) 'expenseScope': expenseScope,
          if (!income && expenseScope == 'SINGLE')
            'equipmentId': selectedEquipment,
          if (shared)
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
      if (mounted) setState(() => error = localizedError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        income ? l10n(context).uiEditIncome : l10n(context).uiEditExpense,
      ),
    ),
    body: Form(
      key: form,
      child: FormBody(
        children: [
          Text(
            l10n(context).uiPreviousPaymentsAreKeptAndDoNot,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('editAmount'),
            controller: amount,
            enabled: !busy && !hasCash,
            textDirection: TextDirection.ltr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n(context).uiTotalSar),
            validator: (v) => exactMoney(v ?? '') == null
                ? l10n(context).uiEnterAValidAmount
                : null,
          ),
          if (hasCash)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(l10n(context).uiTheTotalCannotChangeBecauseAPayment),
            ),
          if (!income) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('editExpenseScope'),
              initialValue: expenseScope,
              decoration: InputDecoration(
                labelText: l10n(context).uiExpenseAppliesTo,
              ),
              items: [
                DropdownMenuItem(
                  value: 'SINGLE',
                  child: Text(l10n(context).uiOneEquipment),
                ),
                DropdownMenuItem(
                  value: 'SHARED',
                  child: Text(l10n(context).uiSeveralEquipment),
                ),
                DropdownMenuItem(
                  value: 'GENERAL',
                  child: Text(l10n(context).generalExpense),
                ),
              ],
              onChanged: busy
                  ? null
                  : (value) => setState(() {
                      expenseScope = value!;
                      if (value == 'SHARED' && parts.isEmpty) {
                        parts.addAll([
                          _ExpensePart(selectedEquipment),
                          _ExpensePart(null),
                        ]);
                      }
                    }),
            ),
          ],
          if (!income && expenseScope == 'SINGLE') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('editSingleEquipment'),
              initialValue: selectedEquipment,
              decoration: InputDecoration(labelText: l10n(context).uiEquipment),
              items: [
                if (selectedEquipment != null &&
                    !equipmentChoices.any((e) => e['id'] == selectedEquipment))
                  DropdownMenuItem(
                    value: selectedEquipment,
                    child: Text(
                      widget.entry['equipmentName'] ??
                          l10n(context).uiEquipment,
                    ),
                  ),
                ...equipmentChoices.map(
                  (e) => DropdownMenuItem(
                    value: e['id'] as String,
                    child: Text(e['name'] as String),
                  ),
                ),
              ],
              onChanged: busy
                  ? null
                  : (value) => setState(() => selectedEquipment = value),
            ),
          ],
          if (shared) ...[
            const SizedBox(height: 12),
            Text(l10n(context).uiAdjustEachEquipmentAmountToMatchThe),
            ...parts.asMap().entries.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: Key('editAllocationEquipment${item.key}'),
                        initialValue: item.value.equipmentId,
                        decoration: InputDecoration(
                          labelText: l10n(context).uiEquipment,
                        ),
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
                        onChanged: busy
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
                        enabled: !busy,
                        textDirection: TextDirection.ltr,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n(context).uiAmount,
                        ),
                        validator: (value) => exactMoney(value ?? '') == null
                            ? l10n(context).uiEnterAValidAmount
                            : null,
                      ),
                    ),
                    if (parts.length > 2)
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
            TextButton.icon(
              key: const Key('addEditAllocation'),
              onPressed: busy
                  ? null
                  : () => setState(() => parts.add(_ExpensePart(null))),
              icon: const Icon(Icons.add),
              label: Text(l10n(context).addEquipment),
            ),
          ],
          if (!income) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: InputDecoration(
                labelText: l10n(context).uiExpenseType,
              ),
              items: categoryCodes
                  .map(
                    (code) => DropdownMenuItem(
                      value: code,
                      child: Text(localizedCategory(context, code)),
                    ),
                  )
                  .toList(),
              onChanged: busy ? null : (v) => setState(() => category = v!),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: busy ? null : () => pickDate(),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              l10n(context).operationDate(localizedDate(context, date)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('editParty'),
            controller: party,
            enabled: !busy,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: income
                  ? l10n(context).uiNameOfThePartyWhoWillPay
                  : l10n(context).uiNameOfThePartyOwed,
            ),
            validator: (v) {
              final total = exactMoney(amount.text);
              if (total == null) return null;
              final settled = BigInt.parse(
                (widget.entry['netPaid'] as String).replaceAll('.', ''),
              );
              return BigInt.parse(total.replaceAll('.', '')) > settled &&
                      (v == null || v.trim().isEmpty)
                  ? l10n(context).uiEnterPartyNameWhenABalanceRemains
                  : null;
            },
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => pickDate(due: true),
            icon: const Icon(Icons.event_outlined),
            label: Text(
              dueDate == null
                  ? l10n(context).uiDueDateOptional
                  : l10n(context).dueDateValue(localizedDate(context, dueDate)),
            ),
          ),
          if (dueDate != null)
            TextButton(
              onPressed: busy ? null : () => setState(() => dueDate = null),
              child: Text(l10n(context).uiRemoveDueDate),
            ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('editNote'),
            controller: note,
            enabled: !busy,
            maxLength: 1000,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n(context).uiNoteOptional,
            ),
          ),
          InlineError(error),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('saveEntryEdit'),
            onPressed: busy ? null : save,
            child: Text(
              busy
                  ? l10n(context).uiSavingChanges
                  : l10n(context).uiSaveChanges,
            ),
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
  List<Map<String, dynamic>> projectChoices = [];
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
          title: Text(l10n(context).uiCancelEntry),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n(context).uiPaymentsAndAttachmentsWillRemainInThe),
              TextField(
                key: const Key('cancellationReason'),
                onChanged: (value) => reason = value,
                maxLength: 500,
                maxLines: 2,
                enabled: !saving,
                decoration: InputDecoration(
                  labelText: l10n(context).uiCancellationReason,
                ),
              ),
              InlineError(validation),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: Text(l10n(context).back),
            ),
            FilledButton(
              key: const Key('confirmCancellation'),
              onPressed: saving
                  ? null
                  : () async {
                      if (reason.trim().isEmpty) {
                        update(
                          () =>
                              validation = l10n(context)
                                  .uiEnterCancellationReason,
                        );
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
                          update(() => validation = localizedError(context, e));
                        }
                      } finally {
                        if (dialogContext.mounted) update(() => saving = false);
                      }
                    },
              child: Text(
                saving
                    ? l10n(context).uiCancelling
                    : l10n(context).uiConfirmCancellation,
              ),
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
          title: Text(
            income ? l10n(context).uiAddReceipt : l10n(context).uiAddPayment,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n(context).remainingValue(
                  income
                      ? l10n(context).uiBalanceOwedToYou
                      : l10n(context).uiBalanceYouOwe,
                  localizedMoney(context, entry!['remaining']),
                ),
              ),
              TextField(
                onChanged: (value) => paymentAmount = value,
                enabled: !saving,
                textDirection: TextDirection.ltr,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: income
                      ? l10n(context).uiInitialReceipt
                      : l10n(context).uiInitialPayment,
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
                  income
                      ? l10n(context)
                            .receiptDate(localizedDate(context, paidOn))
                      : l10n(context)
                            .paymentDate(localizedDate(context, paidOn)),
                ),
              ),
              InlineError(paymentError),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: Text(l10n(context).cancel),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final value = exactMoney(paymentAmount);
                      if (value == null) {
                        update(
                          () =>
                              paymentError = l10n(context).uiEnterAValidAmount,
                        );
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
                        update(() => paymentError = localizedError(context, e));
                      } finally {
                        if (dialogContext.mounted) update(() => saving = false);
                      }
                    },
              child: Text(
                saving
                    ? l10n(context).uiSaving170
                    : income
                    ? l10n(context).uiSaveReceipt
                    : l10n(context).uiSavePayment,
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
    String partyName = '';
    final needsParty =
        entry!['partyName'] == null ||
        (entry!['partyName'] as String).trim().isEmpty;
    String? refundError;
    bool saving = false;
    final refundKey = requestKey();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          scrollable: true,
          title: Text(l10n(context).uiRecordRefund),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                income
                    ? l10n(context).refundIncomeHelp(
                        localizedMoney(context, entry!['refundable']),
                      )
                    : l10n(context).refundExpenseHelp(
                        localizedMoney(context, entry!['refundable']),
                      ),
              ),
              TextField(
                key: const Key('refundAmount'),
                onChanged: (value) => refundAmount = value,
                enabled: !saving,
                textDirection: TextDirection.ltr,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n(context).uiRefundAmount,
                ),
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
                child: Text(
                  l10n(context).refundDate(localizedDate(context, refundedOn)),
                ),
              ),
              TextField(
                key: const Key('refundReason'),
                onChanged: (value) => reason = value,
                enabled: !saving,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n(context).uiRefundReason,
                ),
              ),
              if (needsParty) ...[
                Text(l10n(context).uiABalanceWillRemainAfterTheRefund),
                TextField(
                  key: const Key('refundPartyName'),
                  onChanged: (value) => partyName = value,
                  enabled: !saving,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: income
                        ? l10n(context).uiCustomerName
                        : l10n(context).uiSupplierOrPartyName,
                  ),
                ),
              ],
              InlineError(refundError),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: Text(l10n(context).back),
            ),
            FilledButton(
              key: const Key('saveRefund'),
              onPressed: saving
                  ? null
                  : () async {
                      final value = exactMoney(refundAmount);
                      if (value == null) {
                        update(
                          () =>
                              refundError = l10n(context)
                                  .uiEnterAValidRefundAmount,
                        );
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
                          () =>
                              refundError = l10n(context)
                                  .uiRefundAmountExceedsWhatIsAvailable,
                        );
                        return;
                      }
                      if (reason.trim().isEmpty) {
                        update(
                          () => refundError = l10n(context).uiEnterRefundReason,
                        );
                        return;
                      }
                      if (needsParty && partyName.trim().isEmpty) {
                        update(
                          () =>
                              refundError = l10n(context)
                                  .uiEnterPartyNameABalanceWillRemain,
                        );
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
                            if (needsParty) 'partyName': partyName.trim(),
                          },
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (mounted) await load();
                      } on ApiError catch (e) {
                        if (dialogContext.mounted) {
                          update(
                            () => refundError = localizedError(context, e),
                          );
                        }
                      } finally {
                        if (dialogContext.mounted) update(() => saving = false);
                      }
                    },
              child: Text(
                saving ? l10n(context).uiSaving170 : l10n(context).uiSaveRefund,
              ),
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
      if (widget.api.canPostFinance && data['projectId'] != null) {
        try {
          projectChoices = m6Rows(
            await widget.api.json('GET', widget.api.scoped('/projects')),
          );
        } catch (_) {
          projectChoices = [];
        }
      }
      if (mounted) {
        setState(() {
          entry = data;
          attachments = files;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = localizedError(context, e));
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
                  XTypeGroup(
                    label: l10n(context).uiImagesAndInvoicePdfs,
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
      final fileSize = await file.length();
      if (!mounted) return;
      if (fileSize > 10 * 1024 * 1024) {
        throw ApiError(413, 'FILE_TOO_LARGE', l10n(context).fileTooLarge);
      }
      if (!mounted) return;
      final extension = file.name.split('.').last.toLowerCase();
      final type = {
        'png': 'image/png',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'pdf': 'application/pdf',
      }[extension];
      if (type == null) {
        throw ApiError(400, 'UNSUPPORTED_FILE', l10n(context).unsupportedFile);
      }
      pendingBytes = await file.readAsBytes();
      pendingName = file.name;
      pendingType = type;
      uploadId = retry?['id'];
      uploadKey = requestKey();
      await upload();
    } catch (e) {
      if (mounted) setState(() => uploadError = localizedError(context, e));
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
          SnackBar(content: Text(l10n(context).uiAttachmentSavedWithEntry)),
        );
        await load();
      }
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              uploadError = l10n(context)
                  .entryUploadFailed(localizedError(context, e)),
        );
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
                        tooltip: l10n(context).closeAttachment,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Flexible(
                    child: InteractiveViewer(
                      child: Image.memory(
                        response.bodyBytes,
                        semanticLabel: l10n(context)
                            .entryAttachmentLabel('${file['filename']}'),
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
            .showSnackBar(SnackBar(content: Text(localizedError(context, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        income ? l10n(context).uiIncomeDetails : l10n(context).uiExpenseDetails,
      ),
      actions: [
        IconButton(
          tooltip: income
              ? l10n(context).uiUpdateIncome
              : l10n(context).uiUpdateExpense,
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
                '${income ? l10n(context).income : localizedCategory(context, entry!['category'])} • ${entry!['expenseScope'] == 'GENERAL'
                    ? l10n(context).generalExpense
                    : entry!['expenseScope'] == 'SHARED'
                    ? l10n(context).uiMultipleEquipment
                    : entry!['equipmentName']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(localizedDate(context, entry!['operationDate'] as String)),
              if (cancelled) ...[
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n(context).cancelledEntry,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n(context).cancelReasonValue(
                            '${entry!['cancellationReason']}',
                          ),
                        ),
                        Text(
                          l10n(context).cancelDateValue(
                            localizedRiyadhDateTime(
                              context,
                              entry!['cancelledAt'] as String,
                            ),
                          ),
                        ),
                        Text(l10n(context).cancelledAmountsHistory),
                      ],
                    ),
                  ),
                ),
              ] else if (widget.api.canPostFinance) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('editEntry'),
                      onPressed: editEntry,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n(context).edit),
                    ),
                    TextButton.icon(
                      key: const Key('cancelEntry'),
                      onPressed: cancelEntry,
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(l10n(context).uiCancelEntry),
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
                        income
                            ? l10n(context).uiTotalIncome
                            : l10n(context).uiTotalExpenses,
                        entry!['amount'],
                      ),
                      const Divider(height: 32),
                      moneyRow(
                        income
                            ? l10n(context).uiTotalReceived
                            : l10n(context).uiTotalPaid,
                        entry!['paid'],
                      ),
                      if (entry!['refunded'] != null &&
                          entry!['refunded'] != '0.00') ...[
                        const SizedBox(height: 16),
                        moneyRow(
                          income
                              ? l10n(context).uiReturnedToCustomer
                              : l10n(context).uiRefundedBySupplier,
                          entry!['refunded'],
                        ),
                        const SizedBox(height: 16),
                        moneyRow(
                          income
                              ? l10n(context).uiNetReceived
                              : l10n(context).uiNetPaid,
                          entry!['netPaid'],
                        ),
                      ],
                      const SizedBox(height: 16),
                      moneyRow(
                        income
                            ? l10n(context).uiBalanceOwedToYou
                            : l10n(context).uiBalanceYouOwe,
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
                            localizedFinancialStatus(
                              context,
                              income,
                              entry!['settlementStatus'],
                            ),
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
                  l10n(context).uiSharePerEquipment,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(l10n(context).uiPaidAndRefundedAmountsBelowAreCalculated),
                ...((entry!['allocations'] as List).map(
                  (part) => Card(
                    child: ListTile(
                      title: Text(
                        l10n(context).partAmount(
                          '${part['equipmentName']}',
                          localizedMoney(context, part['amount']),
                        ),
                      ),
                      subtitle: Text(
                        l10n(context).partNetRemaining(
                          localizedMoney(context, part['netPaidShare']),
                          localizedMoney(context, part['remainingShare']),
                        ),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (entry!['projectId'] != null ||
                  (!cancelled && widget.api.canPostFinance)) ...[
                const SizedBox(height: 12),
                ListTile(
                  title: Text(l10n(context).m6ProjectClassification),
                  subtitle: Text(
                    projectChoices
                            .where((p) => p['id'] == entry!['projectId'])
                            .firstOrNull?['name']
                            ?.toString() ??
                        (entry!['projectId'] == null
                            ? l10n(context).m6NoProjects
                            : '${entry!['projectId']}'),
                  ),
                  trailing: cancelled || !widget.api.canPostFinance
                      ? null
                      : const Icon(Icons.edit_outlined),
                  onTap: cancelled || !widget.api.canPostFinance
                      ? null
                      : () async {
                          try {
                            projectChoices = m6Rows(
                              await widget.api.json(
                                'GET',
                                widget.api.scoped('/projects'),
                              ),
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizedError(context, e)),
                                ),
                              );
                            }
                            return;
                          }
                          if (!context.mounted) return;
                          final selected = await showDialog<String?>(
                            context: context,
                            builder: (dialog) => SimpleDialog(
                              title: Text(l10n(dialog).m6ProjectClassification),
                              children: [
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(dialog, ''),
                                  child: Text(l10n(dialog).m6NoProjects),
                                ),
                                for (final project in projectChoices)
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(
                                      dialog,
                                      '${project['id']}',
                                    ),
                                    child: Text('${project['name']}'),
                                  ),
                              ],
                            ),
                          );
                          if (selected == null || !mounted) return;
                          try {
                            await widget.api.json(
                              'PUT',
                              widget.api.scoped(
                                '/entries/${widget.id}/project',
                              ),
                              body: {
                                'projectId': selected.isEmpty ? null : selected,
                              },
                            );
                            await load();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizedError(context, e)),
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
              if (entry!['partyName'] != null)
                Text(l10n(context).partyValue('${entry!['partyName']}')),
              if (entry!['dueDate'] != null)
                Text(
                  l10n(context).dueDateValue(
                    localizedDate(context, entry!['dueDate'] as String),
                  ),
                ),
              if (widget.api.canPostFinance &&
                  !cancelled &&
                  entry!['settlementStatus'] != 'PAID') ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: addPayment,
                  icon: const Icon(Icons.add),
                  label: Text(
                    income
                        ? l10n(context).uiAddReceipt
                        : l10n(context).uiAddPayment,
                  ),
                ),
              ],
              if (widget.api.canPostFinance && canRefund) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('addRefund'),
                  onPressed: addRefund,
                  icon: const Icon(Icons.undo_outlined),
                  label: Text(l10n(context).uiRecordRefund),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                income ? l10n(context).uiReceipts : l10n(context).uiPayments,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ...((entry!['settlements'] as List).map(
                (s) => ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(localizedMoney(context, s['amount'])),
                  subtitle: Text(
                    income
                        ? l10n(context).receivedOn(
                            localizedDate(context, s['paidOn'] as String),
                          )
                        : l10n(context).paidOn(
                            localizedDate(context, s['paidOn'] as String),
                          ),
                  ),
                ),
              )),
              if ((entry!['refunds'] as List?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 24),
                Text(
                  l10n(context).uiRefunds,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ...((entry!['refunds'] as List).map(
                  (r) => ListTile(
                    leading: const Icon(Icons.undo_outlined),
                    title: Text(localizedMoney(context, r['amount'])),
                    subtitle: Text(
                      l10n(context).refundRecord(
                        income
                            ? l10n(context).uiReturnedToTheCustomerOrOtherParty
                            : l10n(context).uiReturnedToYouByTheOtherParty,
                        localizedDate(context, r['refundedOn'] as String),
                        '${r['reason']}',
                      ),
                    ),
                  ),
                )),
              ],
              if (entry!['note'] != '') ...[
                const Divider(),
                Text(l10n(context).noteValue('${entry!['note']}')),
              ],
              const SizedBox(height: 24),
              Text(
                l10n(context).attachments,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(l10n(context).filesHelp),
              const SizedBox(height: 12),
              if (attachments.isEmpty) Text(l10n(context).noEntryAttachments),
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
                              ? l10n(context).uiReadyToView
                              : file['state'] == 'FAILED'
                              ? l10n(context).uiAttachmentUploadFailed
                              : l10n(context).uiUploadIncomplete,
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
                                      ? (kIsWeb
                                            ? l10n(context).uiDownloadPdf
                                            : l10n(context).uiOpenPdf)
                                      : l10n(context).uiViewAttachment,
                                ),
                              ),
                              if (kIsWeb &&
                                  file['mediaType'] != 'application/pdf')
                                TextButton.icon(
                                  onPressed: uploading
                                      ? null
                                      : () => open(file, download: true),
                                  icon: const Icon(Icons.download_outlined),
                                  label: Text(
                                    l10n(context).uiDownloadAttachment,
                                  ),
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
                            child: Text(l10n(context).uiUploadAttachmentAgain),
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
                Text(l10n(context).uiUploadingAndCheckingAttachment),
              ] else if (pendingBytes != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: upload,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n(context).uiUploadAttachmentAgain),
                    ),
                    OutlinedButton(
                      onPressed: () => select(),
                      child: Text(l10n(context).uiChooseAnotherFile),
                    ),
                  ],
                )
              else if (widget.api.canPostFinance)
                OutlinedButton.icon(
                  key: const Key('addAttachment'),
                  onPressed: () => select(),
                  icon: const Icon(Icons.attach_file),
                  label: Text(l10n(context).uiAddAttachment),
                ),
              const SizedBox(height: 16),
              Text(
                l10n(context).uiLocalDevelopmentStorageMalwareScanningIsNot,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
  );
  Widget moneyRow(String label, String amount) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(
        localizedMoney(context, amount),
        textDirection: Directionality.of(context),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ],
  );
}

class _MoreMenu extends StatelessWidget {
  final Api api;
  final VoidCallback onSettings;
  final bool canReports, canMaintain, canOrganizations, canProjects,
      canManageOrganizations, canManageProjects, canFinance, canTeam,
      canReview, owner, canAssignDrivers;
  const _MoreMenu({required this.api, required this.canReports,
    required this.canMaintain, required this.canOrganizations,
    required this.canProjects, required this.canManageOrganizations,
    required this.canManageProjects, required this.canFinance,
    required this.canTeam, required this.canReview, required this.owner,
    required this.canAssignDrivers, required this.onSettings});
  @override Widget build(BuildContext context) {
    void open(Widget page) => Navigator.push(context,MaterialPageRoute(builder:(_)=>page));
    return ListView(padding:const EdgeInsets.all(20),children:[
      Text(l10n(context).m7More,style:Theme.of(context).textTheme.headlineSmall),
      if(canReports) ListTile(leading:const Icon(Icons.analytics_outlined),
        title:Text(l10n(context).m7Reports),onTap:()=>open(ReportsPage(api:api,canProjects:canProjects))),
      if(canMaintain) ListTile(leading:const Icon(Icons.build_outlined),
        title:Text(l10n(context).m4Hub),onTap:()=>open(MaintenanceHub(api:api))),
      if(canOrganizations) ListTile(leading:const Icon(Icons.business_outlined),
        title:Text(l10n(context).m6Organizations),onTap:()=>open(OrganizationsPage(api:api,canManage:canManageOrganizations))),
      if(canProjects) ListTile(leading:const Icon(Icons.folder_copy_outlined),
        title:Text(l10n(context).m6ProjectsContracts),onTap:()=>open(ProjectsPage(api:api,canManage:canManageProjects,canFinance:canFinance))),
      if(canTeam) ListTile(leading:const Icon(Icons.group_outlined),
        title:Text(l10n(context).m5Team),onTap:()=>open(TeamPage(api:api,owner:owner,canAssign:canAssignDrivers))),
      if(canReview) ListTile(leading:const Icon(Icons.fact_check_outlined),
        title:Text(l10n(context).m5ReviewQueue),onTap:()=>open(ReviewQueuePage(api:api))),
      ListTile(leading:const Icon(Icons.settings_outlined),
        title:Text(l10n(context).settings),onTap:onSettings),
    ]);
  }
}

class _SettingsPage extends StatefulWidget {
  final Map<String,dynamic> user;
  final Api api;
  final Future<void> Function(String)? changeLocale, selectWorkspace;
  const _SettingsPage({required this.user,required this.api,this.changeLocale,this.selectWorkspace});
  @override State<_SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<_SettingsPage> {
  bool busy=false;
  String? error;
  @override Widget build(BuildContext context) {
    final spaces=widget.user['workspaces'] as List<dynamic>? ?? [];
    return Scaffold(appBar:AppBar(title:Text(l10n(context).settings)),body:ListView(padding:const EdgeInsets.all(20),children:[
      Text(l10n(context).m7AccountInfo,style:Theme.of(context).textTheme.titleMedium),
      ListTile(title:Text('${widget.user['name'] ?? ''}'),
        subtitle:widget.user['phone']==null?null:Text('${widget.user['phone']}')),
      ListTile(leading:const Icon(Icons.language),title:Text(l10n(context).language),
        onTap:busy?null:()async{
          final selected=await showDialog<String>(context:context,builder:(dialog)=>SimpleDialog(
            title:Text(l10n(dialog).language),children:[
              for(final (code,name) in [('ar',l10n(context).uiText102),('en','English'),('ur',l10n(context).uiText054)])
                SimpleDialogOption(onPressed:()=>Navigator.pop(dialog,code),child:Text(name)),
            ]));
          if(selected==null||!mounted)return;
          setState(() {busy=true;error=null;});
          try{await widget.changeLocale?.call(selected);}catch(e){if(mounted)setState(()=>error=localizedError(context,e));}
          finally{if(mounted)setState(()=>busy=false);}
        }),
      if(spaces.length>1) ListTile(leading:const Icon(Icons.swap_horiz),
        title:Text(l10n(context).m5SwitchWorkspace),onTap:busy?null:()async{
          final selected=await showDialog<String>(context:context,builder:(dialog)=>SimpleDialog(
            title:Text(l10n(dialog).m5SwitchWorkspace),children:[
              for(final space in spaces) SimpleDialogOption(onPressed:()=>Navigator.pop(dialog,space['id'] as String),
                child:Text('${space['name']}')),
            ]));
          if(selected==null||selected==widget.api.workspace||!mounted)return;
          setState(() {busy=true;error=null;});
          try{await widget.selectWorkspace?.call(selected);if(context.mounted)Navigator.pop(context);}
          catch(e){if(mounted)setState(()=>error=localizedError(context,e));}
          finally{if(mounted)setState(()=>busy=false);}
        }),
      if(busy)const LinearProgressIndicator(),
      if(error!=null)Text(error!),
    ]));
  }
}
