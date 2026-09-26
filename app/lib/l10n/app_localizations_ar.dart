// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إدارة المعدات';

  @override
  String get language => 'اللغة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get home => 'الرئيسية';

  @override
  String get equipment => 'المعدات';

  @override
  String get ledger => 'السجل';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get refresh => 'تحديث البيانات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get devNotice => 'بيئة تطوير محلية • لا تُرسل رسائل SMS';

  @override
  String get restoreFailed => 'تعذر استعادة الجلسة؛ أعد المحاولة';

  @override
  String get addFirstEquipment => 'أضف أول معدة';

  @override
  String get equipmentSubtitle => 'كل معدة وسجلها، من أول عملية';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get documents => 'المستندات';

  @override
  String get attention => 'الانتباه';

  @override
  String get income => 'إيراد';

  @override
  String get expense => 'مصروف';

  @override
  String get draft => 'مسودة';

  @override
  String get settlement => 'تسوية';

  @override
  String get refund => 'استرداد';

  @override
  String get archived => 'مؤرشف';

  @override
  String get active => 'ساري';

  @override
  String get docPreviousVersion => 'نسخة سابقة';

  @override
  String get docMissingExpiry => 'تاريخ الانتهاء غير مضاف';

  @override
  String get docExpired => 'منتهي';

  @override
  String get docExpiresToday => 'ينتهي اليوم';

  @override
  String get docExpiringSoon => 'ينتهي قريبًا';

  @override
  String get docRegistration => 'الاستمارة';

  @override
  String get docInsurance => 'التأمين';

  @override
  String get docInspection => 'الفحص الدوري';

  @override
  String get docPermit => 'ترخيص / تصريح';

  @override
  String get other => 'أخرى';

  @override
  String get docOther => 'مستند آخر';

  @override
  String get document => 'مستند';

  @override
  String get docLoadFailed => 'تعذر تحميل البيانات. حاول مرة أخرى.';

  @override
  String get closeAttachment => 'إغلاق المرفق';

  @override
  String get fileTypes => 'صور وملفات PDF';

  @override
  String get fileTooLarge => 'اختر ملفًا لا يتجاوز 10 ميغابايت';

  @override
  String get unsupportedFile =>
      'اختر PNG أو JPEG أو PDF؛ حوّل HEIC إلى JPEG قبل الرفع';

  @override
  String get networkError =>
      'تعذر الاتصال بالخادم؛ تحقق من تشغيله ثم أعد المحاولة';

  @override
  String get requestFailed => 'تعذر إكمال الطلب؛ أعد المحاولة';

  @override
  String get sessionRequired => 'سجّل الدخول للمتابعة';

  @override
  String get financialTotalLocked =>
      'لا يمكن تغيير الإجمالي بعد أول حركة مالية';

  @override
  String get documentAlreadyRenewed => 'جُدد هذا المستند بالفعل';

  @override
  String get accessDenied => 'لا تملك صلاحية الوصول لهذه البيانات';

  @override
  String get invalidInput => 'راجع البيانات المدخلة وأعد المحاولة';

  @override
  String get invalidOtp => 'الرمز غير صحيح أو انتهت صلاحيته؛ اطلب رمزًا جديدًا';

  @override
  String get sessionExpired => 'انتهت جلستك؛ سجّل الدخول من جديد';

  @override
  String get otpThrottled => 'انتظر قليلًا قبل طلب رمز جديد';

  @override
  String get recordNotFound => 'تعذر العثور على السجل المطلوب';

  @override
  String get documentVersionChanged =>
      'تغيرت نسخة المستند؛ حدّث الصفحة قبل التعديل';

  @override
  String get documentLocked => 'لا يمكن تعديل هذا المستند في حالته الحالية';

  @override
  String get fileUnavailable => 'الملف غير متاح الآن؛ أعد المحاولة لاحقًا';

  @override
  String get attachmentLimit => 'وصلت إلى الحد المسموح للمرفقات';

  @override
  String get idempotencyConflict =>
      'تغيرت بيانات الطلب؛ راجع السجل قبل إعادة الحفظ';

  @override
  String get immutableAttachment => 'المرفق محفوظ؛ أضف مرفقًا جديدًا لتغييره';

  @override
  String get unsupportedLocale => 'اختر لغة مدعومة';

  @override
  String get notificationDocumentExpiryTitle => 'مستند ينتهي قريبًا';

  @override
  String get notificationDocumentExpiryBody => 'راجع مستند المعدة';

  @override
  String get notificationWeeklyTitle => 'مستندات تحتاج انتباهك';

  @override
  String get notificationWeeklyBody => 'راجع المستندات المنتهية';

  @override
  String unreadNotifications(int count) {
    return 'الإشعارات • $count غير مقروء';
  }

  @override
  String get categoryFuel => 'وقود';

  @override
  String get categoryMaintenance => 'صيانة';

  @override
  String get paidFull => 'مدفوع كاملًا';

  @override
  String get paidPartial => 'مدفوع جزئيًا';

  @override
  String get unpaid => 'غير مدفوع';

  @override
  String get receivedFull => 'مستلم كاملًا';

  @override
  String get receivedPartial => 'مستلم جزئيًا';

  @override
  String get unreceived => 'غير مستلم';

  @override
  String get cancelled => 'ملغاة';

  @override
  String get generalExpense => 'مصروف عام';

  @override
  String get addEquipment => 'إضافة معدة';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addIncome => 'إضافة إيراد';

  @override
  String get addDocument => 'إضافة مستند';

  @override
  String get saveDocument => 'حفظ المستند';

  @override
  String get attachments => 'المرفقات';

  @override
  String get archive => 'أرشفة';

  @override
  String get restoreDocument => 'استعادة المستند';

  @override
  String get currentDocuments => 'المستندات الحالية';

  @override
  String get previousVersions => 'النسخ السابقة';

  @override
  String get noDocuments => 'لم تضف مستندات لهذه المعدة بعد';

  @override
  String get noAttachments => 'لا توجد مرفقات بعد';

  @override
  String get searchEquipment => 'ابحث بالاسم أو الرقم الداخلي';

  @override
  String get searchLedger => 'ابحث في السجل';

  @override
  String get noEquipmentMatches => 'لا توجد معدات تطابق البحث';

  @override
  String get noEntries => 'لا توجد عمليات مسجلة بعد';

  @override
  String get signInCode => 'رمز التحقق';

  @override
  String get phoneNumber => 'رقم الجوال';

  @override
  String get name => 'الاسم';

  @override
  String get model => 'الموديل';

  @override
  String get documentType => 'نوع المستند';

  @override
  String get newExpiryDate => 'تاريخ الانتهاء الجديد';

  @override
  String get renewDocument => 'تجديد المستند';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get edit => 'تعديل';

  @override
  String get update => 'تحديث';

  @override
  String get back => 'رجوع';

  @override
  String get general => 'عام';

  @override
  String get ui2021OrFh16 => '2021 أو FH16';

  @override
  String get uiEnterTheVerificationCode => 'أدخل رمز التحقق';

  @override
  String get uiArchiveDocument => 'أرشفة المستند';

  @override
  String get uiArchiveDocument005 => 'أرشفة المستند؟';

  @override
  String get uiArchiveEquipment => 'أرشفة المعدة';

  @override
  String get uiArchiveEquipment007 => 'أرشفة المعدة؟';

  @override
  String get uiRemoveTheDueDateOnceFullyPaid =>
      'أزل موعد الاستحقاق عند سداد الإجمالي';

  @override
  String get uiAddExpiryDate => 'أضف تاريخ الانتهاء';

  @override
  String get uiMultipleEquipment => 'أكثر من معدة';

  @override
  String get uiReturnedToTheCustomerOrOtherParty =>
      'أُعيد إلى العميل أو الطرف الآخر';

  @override
  String get uiTotalIncome => 'إجمالي الإيراد';

  @override
  String get uiTotalExpenses => 'إجمالي المصروف';

  @override
  String get uiRemoveEquipment => 'إزالة المعدة';

  @override
  String get uiRemoveDueDate => 'إزالة موعد الاستحقاق';

  @override
  String get uiAddReceipt => 'إضافة تحصيل';

  @override
  String get uiAddPayment => 'إضافة دفعة';

  @override
  String get uiAddImageOrPdf => 'إضافة صورة أو PDF';

  @override
  String get uiAddImageOrPdfOptional => 'إضافة صورة أو PDF (اختياري)';

  @override
  String get uiAddAttachment => 'إضافة مرفق';

  @override
  String get uiAddSeparateDocument => 'إضافة مستند منفصل';

  @override
  String get uiAddGeneralExpense => 'إضافة مصروف عام';

  @override
  String get uiUploadAttachmentAgain => 'إعادة رفع المرفق';

  @override
  String get uiRetryTheSameSave => 'إعادة محاولة الحفظ نفسه';

  @override
  String get uiRetryUploadingAttachments => 'إعادة محاولة رفع المرفقات';

  @override
  String get uiRetryFileUpload => 'إعادة محاولة رفع الملف';

  @override
  String get uiClose => 'إغلاق';

  @override
  String get uiCancelEntry => 'إلغاء العملية';

  @override
  String get uiToDate => 'إلى تاريخ';

  @override
  String get uiSearchByEquipmentNameOrReference => 'ابحث باسم المعدة أو مرجعها';

  @override
  String get uiStartByAddingYourEquipment => 'ابدأ بإضافة معداتك';

  @override
  String get uiStartWithEquipmentNameAndModel => 'ابدأ باسم المعدة وموديلها';

  @override
  String get uiStartWithYourMobileNumber => 'ابدأ برقم جوالك';

  @override
  String get uiSelectTheEquipmentThisExpenseBelongsTo =>
      'اختر المعدات التي يخصها المصروف';

  @override
  String get uiSelectEquipment => 'اختر المعدة';

  @override
  String get uiSelectIssueDate => 'اختر تاريخ الإصدار';

  @override
  String get uiSelectExpiryDate => 'اختر تاريخ الانتهاء';

  @override
  String get uiSelectEquipment051 => 'اختر معدة';

  @override
  String get uiChooseAnotherFile => 'اختيار ملف آخر';

  @override
  String get uiText054 => 'اردو';

  @override
  String get uiDiscardDraft => 'استبعاد المسودة';

  @override
  String get uiDiscardDraft056 => 'استبعاد المسودة؟';

  @override
  String get uiExcludeGeneralExpenses => 'استبعاد المصروف العام';

  @override
  String get uiRestoreEquipment => 'استعادة المعدة';

  @override
  String get uiRestoreTheEquipmentBeforeRestoringThisDocument =>
      'استعد المعدة أولًا لاستعادة المستند.';

  @override
  String get uiCompleteAsIncome => 'استكمال كإيراد';

  @override
  String get uiCompleteAsExpense => 'استكمال كمصروف';

  @override
  String get uiCompleteTheSavedInvoiceDetailsItsAttachments =>
      'استكمل بيانات الفاتورة المحفوظة؛ المرفقات ستبقى معها.';

  @override
  String get uiPartiallyReceived => 'استلمت جزءًا';

  @override
  String get uiReceivedInFull => 'استلمته كاملًا';

  @override
  String get uiReceived => 'استُلمت';

  @override
  String get uiNameOfThePartyWhoWillPay => 'اسم الطرف الذي سيدفع';

  @override
  String get uiNameOfThePartyOwed => 'اسم الطرف المستحق';

  @override
  String get uiCustomerName => 'اسم العميل';

  @override
  String get uiDocumentName => 'اسم المستند';

  @override
  String get uiEquipmentName => 'اسم المعدة';

  @override
  String get uiEquipmentNameReferencePartyOrNote =>
      'اسم المعدة أو مرجعها أو الطرف أو الملاحظة';

  @override
  String get uiSupplierOrPartyName => 'اسم المورد أو الطرف';

  @override
  String get uiEnterPartyName => 'اكتب اسم الطرف';

  @override
  String get uiEnterPartyNameWhenABalanceRemains =>
      'اكتب اسم الطرف عند وجود متبقٍ';

  @override
  String get uiEnterPartyNameABalanceWillRemain =>
      'اكتب اسم الطرف؛ بعد الاسترداد سيبقى مبلغ مستحق';

  @override
  String get uiEnterDocumentName => 'اكتب اسم المستند';

  @override
  String get uiEnterEquipmentName => 'اكتب اسم المعدة';

  @override
  String get uiEnterYourNameToContinue => 'اكتب الاسم للمتابعة';

  @override
  String get uiEnterTheDateLike20260925 =>
      'اكتب التاريخ بهذا الشكل: 2026-09-25';

  @override
  String get uiEnterModel => 'اكتب الموديل';

  @override
  String get uiEnterCancellationReason => 'اكتب سبب الإلغاء';

  @override
  String get uiEnterRefundReason => 'اكتب سبب الاسترداد';

  @override
  String get uiEnterAValidRefundAmount => 'اكتب مبلغ استرداد صحيحًا';

  @override
  String get uiEnterAnAmountAboveZeroAndBelow =>
      'اكتب مبلغًا أكبر من صفر وأقل من الإجمالي';

  @override
  String get uiEnterAnAmountAboveZeroUpTo =>
      'اكتب مبلغًا أكبر من صفر، حتى منزلتين عشريتين';

  @override
  String get uiEnterAValidAmount => 'اكتب مبلغًا صحيحًا';

  @override
  String get uiDevelopmentNumbers0500000001Or0500000002 =>
      'أرقام التطوير: 0500000000–0500000999، بما فيها أرقام المدعوين';

  @override
  String get uiTotalSar => 'الإجمالي (ريال سعودي)';

  @override
  String get uiRefunds => 'الاستردادات';

  @override
  String get uiNameAndModelAreEnoughToStart =>
      'الاسم والموديل يكفيان للبداية. نضيف رقمًا داخليًا تلقائيًا.';

  @override
  String get uiReceipts => 'التحصيلات';

  @override
  String get uiPreviousPaymentsAreKeptAndDoNot =>
      'التسويات السابقة محفوظة ولا تتغير بالتعديل.';

  @override
  String get uiPayments => 'الدفعات';

  @override
  String get uiGeneralRecords => 'السجل العام';

  @override
  String get uiArchivedRecords => 'السجل المؤرشف';

  @override
  String get uiText102 => 'العربية';

  @override
  String get uiAll => 'الكل';

  @override
  String get uiAmount => 'المبلغ';

  @override
  String get uiAmountSar => 'المبلغ (ريال سعودي)';

  @override
  String get uiInitialPayment => 'المبلغ المدفوع أولًا';

  @override
  String get uiInitialReceipt => 'المبلغ المستلم أولًا';

  @override
  String get uiBalanceYouOwe => 'المتبقي عليك';

  @override
  String get uiBalanceOwedToYou => 'المتبقي لك';

  @override
  String get uiTotalPaid => 'المدفوع إجمالًا';

  @override
  String get uiPaidAndRefundedAmountsBelowAreCalculated =>
      'المدفوع والمسترد أدناه حصص محسوبة؛ الدفعات والاستردادات الأصلية مسجلة مرة واحدة على المصروف.';

  @override
  String get uiRefundedBySupplier => 'المسترد من المورد';

  @override
  String get uiTotalReceived => 'المستلم إجمالًا';

  @override
  String get uiDocument => 'المستند';

  @override
  String get uiGeneralExpense => 'المصروف العام';

  @override
  String get uiExpenseAppliesTo => 'المصروف يخص';

  @override
  String get uiReturnedToCustomer => 'المعاد للعميل';

  @override
  String get uiEquipment => 'المعدة';

  @override
  String get uiAwaitingCompletion => 'بانتظار الاستكمال';

  @override
  String get uiAwaitingCompletionThisWillNotCountAs =>
      'بانتظار الاستكمال • لن تُحتسب كعملية مالية حتى تُدخل بياناتها لاحقًا.';

  @override
  String get uiSearch => 'بحث';

  @override
  String get uiNoExpiryDate => 'بدون تاريخ انتهاء';

  @override
  String get uiABalanceWillRemainAfterTheRefund =>
      'بعد الاسترداد سيبقى مبلغ مستحق؛ سجّل اسم الطرف للمتابعة.';

  @override
  String get uiWhatShouldWeCallYou => 'بماذا نناديك؟';

  @override
  String get uiDetailsToComplete => 'بيانات تحتاج استكمال';

  @override
  String get uiConfirmCancellation => 'تأكيد الإلغاء';

  @override
  String get uiConfirmCode => 'تأكيد الرمز';

  @override
  String get uiIssueDateOptional => 'تاريخ الإصدار (اختياري)';

  @override
  String get uiIssueDateIsAfterExpiryDate => 'تاريخ الإصدار بعد تاريخ الانتهاء';

  @override
  String get uiExpiryDateOptional => 'تاريخ الانتهاء (اختياري)';

  @override
  String get uiRenewCurrentDocument => 'تجديد الحالي';

  @override
  String get uiUpdateIncome => 'تحديث الإيراد';

  @override
  String get uiRefreshRecords => 'تحديث السجل';

  @override
  String get uiUpdateDocument => 'تحديث المستند';

  @override
  String get uiUpdateDraft => 'تحديث المسودة';

  @override
  String get uiUpdateExpense => 'تحديث المصروف';

  @override
  String get uiLocalDevelopmentStorageMalwareScanningIsNot =>
      'تخزين تطوير محلي. لم يُفعّل فحص البرمجيات الضارة.';

  @override
  String get uiRecordRefund => 'تسجيل استرداد';

  @override
  String get uiFilterRecords => 'تصفية السجل';

  @override
  String get uiUploadFailed => 'تعثر الرفع';

  @override
  String get uiUploadFailedTryAgain => 'تعثر الرفع؛ أعد المحاولة';

  @override
  String get uiAttachmentUploadFailed => 'تعثر رفع المرفق';

  @override
  String get uiEditIncome => 'تعديل الإيراد';

  @override
  String get uiEditDocument => 'تعديل المستند';

  @override
  String get uiEditExpense => 'تعديل المصروف';

  @override
  String get uiCouldNotLoadDocumentsTryAgain =>
      'تعذر تحميل المستندات • إعادة المحاولة';

  @override
  String get uiCouldNotLoadDocumentsTryAgain161 =>
      'تعذر تحميل المستندات. حاول مرة أخرى.';

  @override
  String get uiChangeNumberOrRequestANewCode => 'تغيير الرقم أو طلب رمز جديد';

  @override
  String get uiIncomeDetails => 'تفاصيل الإيراد';

  @override
  String get uiExpenseDetails => 'تفاصيل المصروف';

  @override
  String get uiDownloadPdf => 'تنزيل PDF';

  @override
  String get uiDownloadAttachment => 'تنزيل المرفق';

  @override
  String get uiCancelling => 'جارٍ الإلغاء…';

  @override
  String get uiVerifying => 'جارٍ التحقق…';

  @override
  String get uiSaving => 'جارٍ الحفظ...';

  @override
  String get uiSaving170 => 'جارٍ الحفظ…';

  @override
  String get uiSavingChanges => 'جارٍ حفظ التعديل…';

  @override
  String get uiSavingEquipment => 'جارٍ حفظ المعدة…';

  @override
  String get uiUploadingAndCheckingAttachment => 'جارٍ رفع المرفق والتحقق منه…';

  @override
  String get uiReadyToRetryUpload => 'جاهز لإعادة محاولة الرفع';

  @override
  String get uiReadyToUpload => 'جاهز للرفع';

  @override
  String get uiReadyToView => 'جاهز للعرض';

  @override
  String get uiReceiptStatus => 'حالة الاستلام';

  @override
  String get uiSettlementStatus => 'حالة التسوية';

  @override
  String get uiPaymentStatus => 'حالة الدفع';

  @override
  String get uiEntryStatus => 'حالة العملية';

  @override
  String get uiSelectDifferentEquipmentAndMakeTheirAmounts =>
      'حدد معدات مختلفة واجعل مجموع مبالغها يساوي إجمالي المصروف';

  @override
  String get uiSaveRefund => 'حفظ الاسترداد';

  @override
  String get uiSaveReceipt => 'حفظ التحصيل';

  @override
  String get uiSaveChanges => 'حفظ التعديل';

  @override
  String get uiSavePayment => 'حفظ الدفعة';

  @override
  String get uiSaveInvoiceNowAndCompleteDetailsLater =>
      'حفظ الفاتورة الآن وإكمال البيانات لاحقًا';

  @override
  String get uiSaveEquipment => 'حفظ المعدة';

  @override
  String get uiSaveInvoiceNow => 'حفظ فاتورة الآن';

  @override
  String get uiAttachmentSavedWithEntry => 'حُفظ المرفق داخل العملية';

  @override
  String get uiPaidPartOfIt => 'دفعت جزءًا';

  @override
  String get uiPaidInFull => 'دفعته كاملًا';

  @override
  String get uiPaid => 'دُفعت';

  @override
  String get uiDocumentNumberOptional => 'رقم المستند (اختياري)';

  @override
  String get uiDevelopmentCodeOnly123456 => 'رمز التطوير فقط: 123456';

  @override
  String get uiCancellationReason => 'سبب الإلغاء';

  @override
  String get uiRefundReason => 'سبب الاسترداد';

  @override
  String get uiPaymentsAndAttachmentsWillRemainInThe =>
      'ستبقى الدفعات والمرفقات في السجل. الإلغاء ليس استردادًا للمال.';

  @override
  String get uiUnsavedDataWillBeLostIfYou =>
      'ستفقد البيانات غير المحفوظة. إذا لم يصل تأكيد الحفظ، راجع السجل قبل إنشاء طلب آخر.';

  @override
  String get uiEquipmentHistory => 'سجل المعدة';

  @override
  String get uiEquipmentHistoryAndDocumentsWillRemainSaved =>
      'سيبقى سجل المعدة ومستنداتها محفوظًا، وتتوقف تنبيهات انتهاء مستنداتها حتى استعادتها.';

  @override
  String get uiThePreviousDocumentWillBeKeptIn =>
      'سيُحفظ المستند السابق في السجل. أضف تاريخ انتهاء جديدًا للمستند المجدد.';

  @override
  String get uiNetPaid => 'صافي المدفوع';

  @override
  String get uiNetReceived => 'صافي المستلم';

  @override
  String get uiImagesAndInvoicePdfs => 'صور وفواتير PDF';

  @override
  String get uiRequestVerificationCode => 'طلب رمز التحقق';

  @override
  String get uiReturnedToYouByTheOtherParty => 'عاد إليك من الطرف الآخر';

  @override
  String get uiSeveralEquipment => 'عدة معدات';

  @override
  String get uiAdjustEachEquipmentAmountToMatchThe =>
      'عدّل مبلغ كل معدة بحيث يساوي الإجمالي.';

  @override
  String get uiViewRecordsAndEntries => 'عرض السجل والعمليات ←';

  @override
  String get uiViewAttachment => 'عرض المرفق';

  @override
  String get uiViewDocuments => 'عرض المستندات';

  @override
  String get uiUnsettled => 'غير مسوّى';

  @override
  String get uiOpenPdf => 'فتح PDF';

  @override
  String get uiOpenSavedDraft => 'فتح المسودة المحفوظة';

  @override
  String get uiTipper1 => 'قلاب ١';

  @override
  String get uiEachEntryItsPaymentsAndAttachmentsIn =>
      'كل عملية ودفعاتها ومرفقاتها في سجل واحد';

  @override
  String get uiNoEntriesMatchYourSearchOrFilters =>
      'لا توجد عمليات تطابق البحث أو المرشحات. جرّب تغييرها أو مسحها.';

  @override
  String get uiNoInvoicesAwaitingCompletion =>
      'لا توجد فواتير بانتظار الاستكمال';

  @override
  String get uiNoDocumentsNeedAttentionNow =>
      'لا توجد مستندات تحتاج انتباه الآن';

  @override
  String get uiNoDocumentsHaveMissingInformation =>
      'لا توجد مستندات ناقصة البيانات';

  @override
  String get uiNoMatchingEquipment => 'لا توجد معدات مطابقة للبحث';

  @override
  String get uiNoPreviousVersionsYet => 'لا توجد نسخ سابقة بعد';

  @override
  String get uiTheTotalCannotChangeAfterAPayment =>
      'لا يمكن تغيير الإجمالي بعد تسجيل دفعة أو تحصيل أو استرداد';

  @override
  String get uiTheTotalCannotChangeBecauseAPayment =>
      'لا يمكن تغيير الإجمالي لوجود دفعة أو تحصيل أو استرداد.';

  @override
  String get uiNotPaid => 'لم أدفعه';

  @override
  String get uiNotReceived => 'لم أستلمه';

  @override
  String get uiUploadIncomplete => 'لم يكتمل الرفع';

  @override
  String get uiThisWillNotCountAsAFinancial =>
      'لن تُحتسب كعملية مالية. ستختفي المرفقات من القائمة بعد الاستبعاد.';

  @override
  String get uiThisDocumentWillNoLongerAppearAmong =>
      'لن يظهر المستند ضمن المستندات الحالية ولن تصلك تنبيهات انتهاء خاصة به. سيبقى محفوظًا في السجل.';

  @override
  String get uiRefundAmount => 'مبلغ الاسترداد';

  @override
  String get uiRefundAmountExceedsWhatIsAvailable =>
      'مبلغ الاسترداد أكبر من المتاح';

  @override
  String get uiAmountPerEquipment => 'مبلغ كل معدة';

  @override
  String get uiContinueEntry => 'متابعة الإدخال';

  @override
  String get uiWorkspace => 'مساحة العمل';

  @override
  String get uiClearFilters => 'مسح المرشحات';

  @override
  String get uiPartiallySettled => 'مسوّى جزئيًا';

  @override
  String get uiFullySettled => 'مسوّى كاملًا';

  @override
  String get uiGeneralExpensesOnly => 'مصروف عام فقط';

  @override
  String get uiAWorkspaceExpenseItIsNotAssigned =>
      'مصروف عام لمساحة العمل؛ لا يُحمّل على معدة';

  @override
  String get uiYourEquipmentAndExpensesInOnePlace =>
      'معداتك ومصروفاتك في مكان واحد';

  @override
  String get uiOneEquipment => 'معدة واحدة';

  @override
  String get uiLeave => 'مغادرة';

  @override
  String get uiNoteOptional => 'ملاحظة (اختياري)';

  @override
  String get uiFromDate => 'من تاريخ';

  @override
  String get uiDueDateOptional => 'موعد الاستحقاق (اختياري)';

  @override
  String get uiPreviousVersionIsViewOnly => 'نسخة سابقة للعرض فقط';

  @override
  String get uiActive => 'نشطة';

  @override
  String get uiSharePerEquipment => 'نصيب كل معدة';

  @override
  String get uiEntryType => 'نوع العملية';

  @override
  String get uiExpenseType => 'نوع المصروف';

  @override
  String get uiThisInvoiceIsSavedForLaterCompletion =>
      'هذه الفاتورة محفوظة بانتظار الاستكمال، ولا تدخل المجاميع المالية بعد.';

  @override
  String get uiLeaveThisForm => 'هل تريد مغادرة النموذج؟';

  @override
  String get uiNeedsAttention => 'يحتاج انتباه';

  @override
  String get uiExpenseAppliesTo276 => 'يخص المصروف';

  @override
  String get uiThisIncomeIsRecordedUnderThisEquipment =>
      'يُسجّل هذا الإيراد على هذه المعدة';

  @override
  String verifyPhone(String phone) {
    return 'التحقق من $phone';
  }

  @override
  String modelValue(String model) {
    return 'الموديل: $model';
  }

  @override
  String fromDateValue(String date) {
    return 'من $date';
  }

  @override
  String toDateValue(String date) {
    return 'إلى $date';
  }

  @override
  String entryDateStatus(String date, String status) {
    return '$date ميلادي\n$status';
  }

  @override
  String draftUploadFailed(String error) {
    return 'حُفظت المسودة، وتعذر رفع الملف. أعد المحاولة. $error';
  }

  @override
  String draftNote(String note) {
    return 'بانتظار الاستكمال\n$note';
  }

  @override
  String noteValue(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String allocationRemaining(String amount) {
    return 'المتبقي للتوزيع: $amount';
  }

  @override
  String operationDate(String date) {
    return 'تاريخ العملية: $date';
  }

  @override
  String paymentDate(String date) {
    return 'تاريخ الدفع: $date';
  }

  @override
  String receiptDate(String date) {
    return 'تاريخ الاستلام: $date';
  }

  @override
  String dueDateValue(String date) {
    return 'موعد الاستحقاق: $date';
  }

  @override
  String attachmentAfterSave(String kind) {
    return 'يمكنك إرفاق صورة أو PDF بعد حفظ $kind.';
  }

  @override
  String savingKind(String kind) {
    return 'جارٍ حفظ $kind…';
  }

  @override
  String saveKind(String kind) {
    return 'حفظ $kind';
  }

  @override
  String remainingValue(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String refundIncomeHelp(String amount) {
    return 'مبلغ أُعيد إلى العميل أو الطرف الآخر. المتاح للاسترداد: $amount';
  }

  @override
  String refundExpenseHelp(String amount) {
    return 'مبلغ عاد إليك من المورد أو الطرف الآخر. المتاح للاسترداد: $amount';
  }

  @override
  String refundDate(String date) {
    return 'تاريخ عودة المال: $date';
  }

  @override
  String entryUploadFailed(String error) {
    return 'حُفظت العملية، وتعذر رفع المرفق. $error';
  }

  @override
  String entryAttachmentLabel(String filename) {
    return 'مرفق العملية: $filename';
  }

  @override
  String cancelReasonValue(String reason) {
    return 'السبب: $reason';
  }

  @override
  String cancelDateValue(String date) {
    return 'تاريخ الإلغاء: $date';
  }

  @override
  String partAmount(String equipment, String amount) {
    return '$equipment: $amount';
  }

  @override
  String partNetRemaining(String paid, String remaining) {
    return 'حصة محسوبة من صافي المدفوع: $paid • المتبقي: $remaining';
  }

  @override
  String partyValue(String party) {
    return 'الطرف: $party';
  }

  @override
  String paidOn(String date) {
    return 'دُفعت في $date';
  }

  @override
  String receivedOn(String date) {
    return 'استُلمت في $date';
  }

  @override
  String refundRecord(String kind, String date, String reason) {
    return '$kind في $date\nالسبب: $reason';
  }

  @override
  String get filesHelp => 'صورة PNG أو JPEG، أو PDF • حتى 10 ميغابايت للملف';

  @override
  String get noEntryAttachments => 'لم تُضف مرفقات بعد؛ العملية محفوظة.';

  @override
  String documentSummary(
    String total,
    String expired,
    String soon,
    String missing,
  ) {
    return '$total مستندات • $expired منتهي • $soon ينتهي قريبًا • $missing بدون تاريخ انتهاء';
  }

  @override
  String equipmentDocumentsTitle(String equipment) {
    return 'مستندات $equipment';
  }

  @override
  String documentAlreadyExists(String document) {
    return 'يوجد $document حالي لهذه المعدة. هل تريد تجديده بدل إضافة مستند منفصل؟';
  }

  @override
  String expiryValue(String date) {
    return 'ينتهي في $date';
  }

  @override
  String numberValue(String number) {
    return 'الرقم: $number';
  }

  @override
  String issueDateValue(String date) {
    return 'تاريخ الإصدار: $date';
  }

  @override
  String versionNumber(String number) {
    return 'النسخة $number';
  }

  @override
  String versionExpiry(String expiry) {
    return 'انتهاء: $expiry';
  }

  @override
  String versionIssue(String date) {
    return 'إصدار: $date';
  }

  @override
  String versionNumberLabel(String number) {
    return 'رقم النسخة: $number';
  }

  @override
  String documentNumberLabel(String number) {
    return 'رقم المستند: $number';
  }

  @override
  String expiryDateValue(String date) {
    return 'تاريخ الانتهاء: $date';
  }

  @override
  String missingDocumentsCount(String count) {
    return '$count مستند بدون تاريخ انتهاء';
  }

  @override
  String get versionAttachments => 'مرفقات هذه النسخة';

  @override
  String get noAttachmentsShort => 'لا توجد مرفقات';

  @override
  String get addExpiryDate => 'إضافة تاريخ الانتهاء';

  @override
  String get documentTypeExists => 'يوجد مستند من هذا النوع';

  @override
  String get refreshDocuments => 'تحديث المستندات';

  @override
  String get cancelledAmountsHistory =>
      'المبالغ والتسويات أدناه محفوظة للسجل، ولا تدخل العملية في المجاميع النشطة.';

  @override
  String get cancelledEntry => 'عملية ملغاة';

  @override
  String get timeoutMessage =>
      'استغرق الطلب وقتًا طويلًا. إذا كنت تحفظ بيانات، راجع السجل قبل إعادة المحاولة.';

  @override
  String documentExpiryInDays(String days) {
    return 'ينتهي بعد $days أيام';
  }

  @override
  String get documentExpiryToday => 'ينتهي اليوم';

  @override
  String get documentExpiryPast => 'منتهي';

  @override
  String weeklyExpiredCount(String count) {
    return '$count مستندات منتهية تحتاج مراجعة';
  }

  @override
  String get uploadFailed => 'تعذر رفع الملف';

  @override
  String get sarUnit => 'ر.س';

  @override
  String get m4Hub => 'الصيانة والبلاغات';

  @override
  String get m4Issues => 'البلاغات';

  @override
  String get m4Maintenance => 'سجلات الصيانة';

  @override
  String get m4NewIssue => 'بلاغ جديد';

  @override
  String get m4AddMaintenance => 'إضافة صيانة';

  @override
  String get m4Problem => 'وش المشكلة؟';

  @override
  String get m4WorkDone => 'وش تم؟';

  @override
  String get m4IssueType => 'نوع المشكلة (اختياري)';

  @override
  String get m4MaintenanceType => 'نوع الصيانة (اختياري)';

  @override
  String get m4Stopped => 'المشكلة أوقفت المعدة عن العمل';

  @override
  String get m4StoppedBadge => 'المعدة متوقفة';

  @override
  String get m4Open => 'مفتوح';

  @override
  String get m4InProgress => 'جارٍ العمل';

  @override
  String get m4Closed => 'مغلق';

  @override
  String get m4Start => 'بدء المعالجة';

  @override
  String get m4Close => 'إغلاق البلاغ';

  @override
  String get m4Reopen => 'إعادة فتح البلاغ';

  @override
  String get m4Resolution => 'وصف الحل';

  @override
  String get m4ResolutionRequired => 'اكتب ما تم لحل المشكلة';

  @override
  String get m4Mechanical => 'ميكانيكي';

  @override
  String get m4Electrical => 'كهربائي';

  @override
  String get m4Tires => 'إطارات';

  @override
  String get m4Accident => 'حادث أو ضرر';

  @override
  String get m4Repair => 'إصلاح';

  @override
  String get m4Periodic => 'خدمة دورية';

  @override
  String get m4Inspection => 'فحص';

  @override
  String get m4Unclassified => 'دون تصنيف';

  @override
  String get m4Description => 'وصف العمل المنجز';

  @override
  String get m4Date => 'تاريخ الصيانة';

  @override
  String get m4Workshop => 'الورشة أو مقدم الخدمة (اختياري)';

  @override
  String get m4LinkedIssue => 'البلاغ المرتبط (اختياري)';

  @override
  String get m4IssueHistory => 'سجل الإغلاقات';

  @override
  String get m4RelatedMaintenance => 'الصيانة المرتبطة';

  @override
  String get m4NoIssues => 'لا توجد بلاغات لهذه المعدة';

  @override
  String get m4NoMaintenance => 'لا توجد سجلات صيانة لهذه المعدة';

  @override
  String get m4NoResults => 'لا توجد نتائج مطابقة';

  @override
  String get m4IssueSearch => 'ابحث في البلاغات';

  @override
  String get m4MaintenanceSearch => 'ابحث في الصيانة';

  @override
  String get m4AllStatuses => 'كل الحالات';

  @override
  String get m4AllTypes => 'كل الأنواع';

  @override
  String get m4OnlyStopped => 'المعدات المتوقفة فقط';

  @override
  String get m4Cancelled => 'سجل ملغى';

  @override
  String get m4ShowCancelled => 'عرض الملغى';

  @override
  String get m4CancelMaintenance => 'إلغاء سجل الصيانة';

  @override
  String get m4CancelWarning => 'إلغاء سجل الصيانة لن يلغي المصروفات المرتبطة.';

  @override
  String get m4CancellationReason => 'سبب الإلغاء';

  @override
  String get m4Expenses => 'المصروفات المرتبطة';

  @override
  String get m4AddExpense => 'إضافة مصروف';

  @override
  String get m4LinkExpense => 'ربط مصروف موجود';

  @override
  String get m4UnlinkExpense => 'فصل المصروف';

  @override
  String get m4ExpenseTotal => 'إجمالي المصروفات النشطة';

  @override
  String get m4NetPaid => 'الصافي المدفوع';

  @override
  String get m4Remaining => 'المتبقي';

  @override
  String get m4NoEligible => 'لا توجد مصروفات مناسبة للربط';

  @override
  String get m4NoAttachments => 'لا توجد مرفقات';

  @override
  String get m4CreateIssue => 'حفظ البلاغ';

  @override
  String get m4SaveMaintenance => 'حفظ الصيانة';

  @override
  String get m4IssueUpdated => 'تم تحديث البلاغ';

  @override
  String get m4AttentionEmpty =>
      'لا توجد بلاغات أو مستندات تحتاج انتباهًا الآن';

  @override
  String get m4AttentionOpenIssue => 'بلاغ مفتوح';

  @override
  String get m4ArchivedWarning =>
      'ستبقى البلاغات والصيانة محفوظة، لكن البلاغات المفتوحة ستختفي من الانتباه حتى استعادة المعدة.';

  @override
  String get m4SelectEquipment => 'اختر المعدة';

  @override
  String get m4IssueDetails => 'تفاصيل البلاغ';

  @override
  String get m4MaintenanceDetails => 'تفاصيل الصيانة';

  @override
  String get m4EditIssue => 'تعديل البلاغ';

  @override
  String get m4EditMaintenance => 'تعديل الصيانة';

  @override
  String get m4Required => 'هذا الحقل مطلوب';

  @override
  String get m4AllEquipment => 'كل المعدات';

  @override
  String get m4LinkedCount => 'مصروفات مرتبطة';

  @override
  String get m4ViewHistory => 'عرض السجل';

  @override
  String get m4RemoveAttachment => 'إزالة المرفق';

  @override
  String get m4NoLinkedIssue => 'دون بلاغ مرتبط';

  @override
  String get m4DateRange => 'الفترة الزمنية';

  @override
  String get m4ClearDateRange => 'مسح الفترة';

  @override
  String get m4NoIssuesGlobal => 'لا توجد بلاغات بعد';

  @override
  String get m4NoMaintenanceGlobal => 'لا توجد سجلات صيانة بعد';

  @override
  String get m4SelectIssue => 'اختيار بلاغ';

  @override
  String get m4ClearIssue => 'إزالة ربط البلاغ';

  @override
  String get m5Owner => 'المالك';

  @override
  String get m5Manager => 'مدير';

  @override
  String get m5Accountant => 'محاسب';

  @override
  String get m5Driver => 'سائق';

  @override
  String get m5Member => 'عضو';

  @override
  String get m5Pending => 'بانتظار المراجعة';

  @override
  String get m5Accepted => 'مقبولة';

  @override
  String get m5Cancelled => 'ملغاة';

  @override
  String get m5Expired => 'منتهية';

  @override
  String get m5Approved => 'معتمدة';

  @override
  String get m5Rejected => 'مرفوضة';

  @override
  String get m5EquipmentView => 'عرض المعدات';

  @override
  String get m5EquipmentManage => 'إدارة المعدات';

  @override
  String get m5FinanceView => 'عرض الماليات';

  @override
  String get m5FinanceManage => 'إدارة الماليات';

  @override
  String get m5FinanceReview => 'مراجعة الطلبات المالية';

  @override
  String get m5DocumentView => 'عرض المستندات';

  @override
  String get m5DocumentManage => 'إدارة المستندات';

  @override
  String get m5IssueView => 'عرض البلاغات';

  @override
  String get m5IssueManage => 'إدارة البلاغات';

  @override
  String get m5MaintenanceView => 'عرض الصيانة';

  @override
  String get m5MaintenanceManage => 'إدارة الصيانة';

  @override
  String get m5DriverAssignmentManage => 'تعيين السائقين';

  @override
  String get m5ReportView => 'عرض التقارير';

  @override
  String get m5TeamManage => 'إدارة الفريق';

  @override
  String get m5MyInvitations => 'دعواتي';

  @override
  String get m5NoInvitations => 'لا توجد دعوات معلقة';

  @override
  String get m5Expires => 'تنتهي';

  @override
  String get m5Accept => 'قبول الدعوة';

  @override
  String get m5Decline => 'رفض الدعوة';

  @override
  String get m5Team => 'الفريق';

  @override
  String get m5Members => 'الأعضاء';

  @override
  String get m5NoMembers => 'لا يوجد أعضاء بعد';

  @override
  String get m5Invitations => 'الدعوات';

  @override
  String get m5InviteMember => 'دعوة عضو';

  @override
  String get m5Resend => 'إعادة إرسال';

  @override
  String get m5CancelInvitation => 'إلغاء الدعوة؟';

  @override
  String get m5ResendInvitation => 'إعادة إرسال الدعوة؟';

  @override
  String get m5EditMember => 'تعديل العضو';

  @override
  String get m5Role => 'الدور';

  @override
  String get m5Scope => 'نطاق المعدات';

  @override
  String get m5AllEquipment => 'كل المعدات';

  @override
  String get m5SelectedEquipment => 'معدات محددة';

  @override
  String get m5ChooseEquipment => 'اختر معدة واحدة على الأقل';

  @override
  String get m5FinancialMode => 'وضع الإدخال المالي';

  @override
  String get m5ReviewMode => 'يرسل للمراجعة';

  @override
  String get m5DirectMode => 'يسجل مباشرة';

  @override
  String get m5Capabilities => 'الصلاحيات';

  @override
  String get m5CapabilitiesHint => 'حدّد ما يمكن لهذا العضو فعله.';

  @override
  String get m5NamePhoneRequired => 'أدخل الاسم ورقم الجوال';

  @override
  String get m5ConfirmPermissions => 'حفظ تغييرات الدور أو النطاق؟';

  @override
  String get m5SendInvitation => 'إرسال الدعوة';

  @override
  String get m5MemberDetails => 'تفاصيل العضو';

  @override
  String get m5DriverAssignment => 'تعيين السائق';

  @override
  String get m5RevokeConfirm => 'إيقاف وصول هذا العضو؟';

  @override
  String get m5RevokeAccess => 'إيقاف الوصول';

  @override
  String get m5CurrentAssignment => 'التعيين الحالي';

  @override
  String get m5NoAssignment => 'لا يوجد تعيين حالي';

  @override
  String get m5ReplaceAssignmentConfirm => 'تغيير المعدة المعينة لهذا السائق؟';

  @override
  String get m5Assign => 'تعيين';

  @override
  String get m5Unassign => 'إنهاء التعيين';

  @override
  String get m5UnassignConfirm => 'إنهاء تعيين هذا السائق؟';

  @override
  String get m5AssignmentHistory => 'سجل التعيينات';

  @override
  String get m5NoHistory => 'لا توجد تعيينات سابقة';

  @override
  String get m5DriverHome => 'عملك اليوم';

  @override
  String get m5NoAssignmentDriver => 'لا توجد معدة معيّنة لك حاليًا.';

  @override
  String get m5ReportIssue => 'الإبلاغ عن عطل';

  @override
  String get m5SubmitExpense => 'إرسال مصروف';

  @override
  String get m5MyIssues => 'بلاغاتي';

  @override
  String get m5NoIssues => 'لا توجد بلاغات لهذه المعدة';

  @override
  String get m5MySubmissions => 'طلباتي المالية';

  @override
  String get m5NoSubmissions => 'لم ترسل طلبات مالية بعد';

  @override
  String get m5ReceiptOnly => 'إيصال دون مبلغ';

  @override
  String get m5SubmissionHint =>
      'أضف المبلغ أو الملاحظة أو الإيصال؛ يراجعه المسؤول قبل تسجيل المصروف.';

  @override
  String get m5TransactionDate => 'تاريخ العملية';

  @override
  String get m5Note => 'ملاحظة';

  @override
  String get m5AddReceipt => 'إضافة إيصال';

  @override
  String get m5SubmissionNeedsContent => 'أضف مبلغًا أو ملاحظة أو إيصالًا';

  @override
  String get m5SendForReview => 'إرسال للمراجعة';

  @override
  String get m5ReviewQueue => 'طلبات المراجعة';

  @override
  String get m5ReviewQueueEmpty => 'لا توجد طلبات بانتظار المراجعة';

  @override
  String get m5SubmissionDetails => 'تفاصيل الطلب';

  @override
  String get m5Status => 'الحالة';

  @override
  String get m5SubmittedBy => 'أرسله';

  @override
  String get m5RejectionReason => 'سبب الرفض';

  @override
  String get m5ApprovedEntryCreated => 'سُجل المصروف بعد الاعتماد';

  @override
  String get m5Approve => 'اعتماد';

  @override
  String get m5Reject => 'رفض';

  @override
  String get m5RejectSubmission => 'رفض الطلب';

  @override
  String get m5Resubmit => 'إعادة الإرسال';

  @override
  String get m5ReasonRequired => 'اكتب سبب الرفض';

  @override
  String get m5ApproveExpense => 'اعتماد المصروف';

  @override
  String get m5ApprovalHint =>
      'راجع بيانات المصروف قبل اعتماده. سيظهر في السجل مرة واحدة.';

  @override
  String get m5Category => 'التصنيف';

  @override
  String get m5PaymentStatus => 'حالة الدفع';

  @override
  String get m5PaidOn => 'تاريخ الدفع';

  @override
  String get m5DueDate => 'تاريخ الاستحقاق';

  @override
  String get m5ChooseDate => 'اختر تاريخًا';

  @override
  String get m5PartyDueRequired => 'أدخل اسم الطرف وتاريخ الاستحقاق';

  @override
  String get m5PartialLessThanTotal =>
      'المدفوع جزئيًا يجب أن يكون أقل من الإجمالي';

  @override
  String get m5ApproveConfirm => 'اعتماد هذا المصروف وتسجيله؟';

  @override
  String get m5SwitchWorkspace => 'تبديل المساحة';

  @override
  String get m5NotificationDriverAssigned => 'عُيّنت لك معدة';

  @override
  String get m5NotificationDriverIssue => 'بلاغ جديد من السائق';

  @override
  String get m5NotificationSubmissionPending => 'طلب مالي ينتظر مراجعتك';

  @override
  String get m5NotificationSubmissionApproved => 'اعتُمد طلبك المالي';

  @override
  String get m5NotificationSubmissionRejected => 'رُفض طلبك المالي';

  @override
  String get m5AttentionReview => 'طلبات مالية تحتاج مراجعة';

  @override
  String m5PendingReviewsCount(String count) {
    return '$count طلبات مالية بانتظار المراجعة';
  }

  @override
  String get m5RoleChangeResetsPermissions =>
      'تغيير الدور سيعيد الصلاحيات إلى إعدادات الدور الجديد ويلغي تخصيصاتها السابقة. هل تريد المتابعة؟';

  @override
  String get m5DirectExpenseHint => 'أكمل بيانات المصروف وسجله مباشرة.';

  @override
  String get m5DirectExpenseConfirm => 'تسجيل هذا المصروف؟';

  @override
  String get m5InvitationPending => 'توجد دعوة معلقة لهذا الرقم';

  @override
  String get m5InvitationClosed => 'أُغلقت الدعوة أو انتهت؛ حدّث القائمة';

  @override
  String get m5AlreadyMember => 'هذا الشخص عضو بالفعل';

  @override
  String get m5SubmissionReviewed => 'تمت مراجعة الطلب؛ حدّث القائمة';

  @override
  String get m5NoDriverAssignment => 'لا توجد معدة معيّنة لك حاليًا';

  @override
  String get m5Issues => 'البلاغات';

  @override
  String get m5DriverInviteHint => 'يمكن تعيين معدة للسائق بعد قبوله الدعوة.';

  @override
  String get m5AllScopeHint => 'يشمل المعدات الحالية وأي معدات تضاف لاحقًا.';

  @override
  String get m5AssignMayReplace =>
      'قد يحل هذا التعيين محل سائق المعدة الحالي. متابعة؟';

  @override
  String get m5ChooseDriver => 'اختر السائق';

  @override
  String get m5NoEligibleDrivers => 'لا يوجد سائقون متاحون لهذه المعدة';

  @override
  String m5DriverCurrentlyOnEquipment(String equipmentName) {
    return 'السائق معيّن حاليًا على $equipmentName';
  }

  @override
  String m5ConfirmAssignDriver(String driverName, String equipmentName) {
    return 'تعيين $driverName على $equipmentName؟';
  }

  @override
  String m5ConfirmReplaceDriver(
    String currentDriver,
    String newDriver,
    String equipmentName,
  ) {
    return 'استبدال $currentDriver بـ $newDriver على $equipmentName؟';
  }

  @override
  String m5ConfirmMoveDriver(String driverName, String sourceEquipment) {
    return 'سينتهي تعيين $driverName الحالي على $sourceEquipment.';
  }

  @override
  String get m6Organizations => 'المؤسسات';

  @override
  String get m6OrganizationsOptional =>
      'المؤسسات اختيارية. يمكنك استخدام التطبيق كاملًا دون إنشاء مؤسسة.';

  @override
  String get m6SearchOrganizations => 'ابحث عن مؤسسة';

  @override
  String get m6NoOrganizations =>
      'لا توجد مؤسسات بعد. يمكنك البدء بالمعدات مباشرة.';

  @override
  String get m6AddOrganization => 'إضافة مؤسسة';

  @override
  String get m6OrganizationName => 'اسم المؤسسة';

  @override
  String get m6IdentifierOptional => 'رقم التعريف (اختياري)';

  @override
  String get m6NameRequired => 'أدخل الاسم للمتابعة';

  @override
  String get m6ProjectsContracts => 'المشاريع والعقود';

  @override
  String get m6ManageEquipment => 'إدارة المعدات المرتبطة';

  @override
  String get m6AddProject => 'إضافة مشروع أو عقد';

  @override
  String get m6ArchiveOrganizationConfirm =>
      'أرشفة المؤسسة تحفظ تاريخها. يجب أولًا إزالة تعيين المعدات وأرشفة المشاريع والعقود غير المؤرشفة.';

  @override
  String get m6NoOrganization => 'بدون مؤسسة';

  @override
  String get m6AssignEquipment => 'تعيين مؤسسة للمعدة';

  @override
  String get m6ConfirmAction => 'تأكيد الإجراء';

  @override
  String get m6ProjectsOptional =>
      'اربط المشاريع والعقود عند الحاجة؛ يمكنك إدارة المعدات والمال دونها.';

  @override
  String get m6SearchProjects => 'ابحث بالاسم أو العميل أو رقم العقد';

  @override
  String get m6All => 'الكل';

  @override
  String get m6Completed => 'مكتمل';

  @override
  String get m6NoProjects => 'لا توجد مشاريع أو عقود تطابق العرض';

  @override
  String get m6Project => 'مشروع';

  @override
  String get m6Contract => 'عقد';

  @override
  String get m6RecordKind => 'نوع السجل';

  @override
  String get m6OrganizationOptional => 'المؤسسة (اختياري)';

  @override
  String get m6ClientOptional => 'العميل (اختياري)';

  @override
  String get m6ContractNumberOptional => 'رقم العقد (اختياري)';

  @override
  String get m6StartDateOptional => 'تاريخ البداية (اختياري)';

  @override
  String get m6EndDateOptional => 'تاريخ النهاية (اختياري)';

  @override
  String get m6DateOrder => 'يجب أن يسبق تاريخ البداية تاريخ النهاية أو يساويه';

  @override
  String get m6CompleteConfirm =>
      'سيكتمل المشروع وتنتهي روابط المعدات النشطة. تبقى العمليات المالية والمرفقات والتاريخ محفوظة.';

  @override
  String get m6ArchiveProjectConfirm =>
      'الأرشفة تخفي السجل من القوائم العادية وتحفظ المال والمرفقات والتاريخ.';

  @override
  String get m6FinancialSummary => 'ملخص مالي مشتق';

  @override
  String get m6RecordedIncome => 'الإيرادات المسجلة';

  @override
  String get m6RecordedExpenses => 'المصروفات المسجلة';

  @override
  String get m6RecordedDifference => 'الفرق بين الإيرادات والمصروفات المسجلة';

  @override
  String get m6Collected => 'المحصّل';

  @override
  String get m6Paid => 'المدفوع';

  @override
  String get m6ReceivablesRemaining => 'المتبقي للتحصيل';

  @override
  String get m6PayablesRemaining => 'المتبقي للدفع';

  @override
  String get m6LinkEquipmentFirst => 'اربط معدة بالمشروع أولًا لإضافة إيراد';

  @override
  String get m6Complete => 'إكمال المشروع';

  @override
  String get m6Reopen => 'إعادة فتح المشروع';

  @override
  String get m6WorkspaceProjectEquipment =>
      'يمكن ربط معدات من مؤسسات مختلفة أو بدون مؤسسة.';

  @override
  String get m6OrganizationProjectEquipment =>
      'تظهر المعدات التابعة حاليًا لمؤسسة المشروع فقط.';

  @override
  String get m6ProjectClassification => 'المشروع أو العقد (اختياري)';

  @override
  String get m6AdditionalDetails => 'تفاصيل إضافية';

  @override
  String get m6ScopeOrganizations => 'مؤسسات محددة';

  @override
  String get m6ScopeOrganizationsHint =>
      'يشمل معدات هذه المؤسسات الآن وكل معدة تنضم إليها مستقبلًا. لا يشمل المعدات غير التابعة لمؤسسة.';

  @override
  String get m6ChooseOrganizations => 'اختر مؤسسة واحدة على الأقل';

  @override
  String get m6OrganizationProjectBlocked =>
      'افصل المعدة من المشروع النشط قبل نقلها إلى مؤسسة أخرى';

  @override
  String get m6OrganizationInUse =>
      'تعذر أرشفة المؤسسة لوجود معدات معيّنة أو مشاريع وعقود غير مؤرشفة';

  @override
  String get m6ProjectInactive => 'المشروع غير نشط لهذا الإجراء';

  @override
  String get m6ProjectMismatch => 'المعدة لا تتبع مؤسسة المشروع الحالية';

  @override
  String get m6ActiveProjects => 'المشاريع والعقود النشطة';

  @override
  String get m6NoActiveProjects => 'لا توجد روابط مشاريع نشطة';

  @override
  String get m6RetrySameFile => 'اختر الملف نفسه لإعادة الرفع';

  @override
  String get m6MoveEquipmentConfirm =>
      'سيُنهي هذا الإجراء تعيين المعدة الحالي وينقلها أو يتركها دون مؤسسة. سيبقى تاريخ التعيين محفوظًا.';

  @override
  String get m7Reports => 'التقارير';

  @override
  String get m7More => 'المزيد';

  @override
  String get m7Recorded => 'العمليات المسجلة';

  @override
  String get m7Movements => 'الدفع والاستلام';

  @override
  String get m7Outstanding => 'المتبقي لك وعليك';

  @override
  String get m7RecordedExpensesMonth => 'المصروفات المسجلة هذا الشهر';

  @override
  String get m7RecordedIncomeMonth => 'الإيرادات المسجلة هذا الشهر';

  @override
  String get m7EntryDateBasis =>
      'بحسب تاريخ العملية، وليس تاريخ الدفع أو الاستلام.';

  @override
  String get m7MovementDateBasis => 'بحسب تاريخ كل دفعة أو استرداد.';

  @override
  String get m7CurrentBasis => 'المتبقي الحالي من جميع الفترات.';

  @override
  String get m7RecordedDifference => 'الفرق بين الإيرادات والمصروفات المسجلة';

  @override
  String get m7Collected => 'المستلم';

  @override
  String get m7IncomeRefunds => 'المعاد للطرف الآخر';

  @override
  String get m7NetCollected => 'صافي المستلم';

  @override
  String get m7Paid => 'المدفوع';

  @override
  String get m7ExpenseRefunds => 'المسترد من المصروفات';

  @override
  String get m7NetPaid => 'صافي المدفوع';

  @override
  String get m7Receivable => 'المتبقي لك';

  @override
  String get m7Payable => 'المتبقي عليك';

  @override
  String get m7RecentEntries => 'أحدث العمليات المالية';

  @override
  String get m7ActiveEquipment => 'المعدات النشطة';

  @override
  String get m7NoPeriodRecords => 'لا توجد عمليات في هذه الفترة.';

  @override
  String get m7NoCurrentOutstanding => 'لا توجد مبالغ متبقية حاليًا.';

  @override
  String get m7NoMatches => 'لا توجد نتائج لهذه الفلاتر.';

  @override
  String get m7ClearFilters => 'مسح الفلاتر';

  @override
  String get m7LoadFailed => 'تعذر تحميل الملخص.';

  @override
  String get m7WithinScope => 'الأرقام المعروضة ضمن نطاق صلاحياتك.';

  @override
  String get m7CurrentClassification => 'تعرض السجلات بحسب تصنيفها الحالي.';

  @override
  String get m7NoDueDate => 'موعد السداد غير محدد';

  @override
  String get m7GeneralExpenses => 'مصروفات عامة';

  @override
  String get m7EquipmentShare => 'حصة المعدة';

  @override
  String get m7OriginalTotal => 'إجمالي العملية الأصلية';

  @override
  String get m7ChoosePeriod => 'اختر الفترة';

  @override
  String get m7ChooseMonth => 'اختر الشهر';

  @override
  String get m7FilterEquipment => 'فلترة بالمعدة';

  @override
  String get m7FilterProject => 'فلترة بالمشروع';

  @override
  String get m7AllEquipment => 'كل المعدات';

  @override
  String get m7AllProjects => 'كل المشاريع';

  @override
  String get m7FromDate => 'من';

  @override
  String get m7ToDate => 'إلى';

  @override
  String get m7Movement => 'حركة مالية';

  @override
  String get m7Refund => 'استرداد';

  @override
  String get m7Settlement => 'تسوية';

  @override
  String get m7NoReportsPermission => 'لا تملك صلاحية عرض التقارير.';

  @override
  String get m7OriginalMovement => 'إجمالي الحركة الأصلية';

  @override
  String get m7AccountInfo => 'معلومات الحساب';

  @override
  String get m7NoRecentEntries => 'لا توجد عمليات مالية حديثة بعد.';
}
