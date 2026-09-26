import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المعدات'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @equipment.
  ///
  /// In ar, this message translates to:
  /// **'المعدات'**
  String get equipment;

  /// No description provided for @ledger.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get ledger;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث البيانات'**
  String get refresh;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @devNotice.
  ///
  /// In ar, this message translates to:
  /// **'بيئة تطوير محلية • لا تُرسل رسائل SMS'**
  String get devNotice;

  /// No description provided for @restoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر استعادة الجلسة؛ أعد المحاولة'**
  String get restoreFailed;

  /// No description provided for @addFirstEquipment.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول معدة'**
  String get addFirstEquipment;

  /// No description provided for @equipmentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كل معدة وسجلها، من أول عملية'**
  String get equipmentSubtitle;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات بعد'**
  String get noNotifications;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @documents.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get documents;

  /// No description provided for @attention.
  ///
  /// In ar, this message translates to:
  /// **'الانتباه'**
  String get attention;

  /// No description provided for @income.
  ///
  /// In ar, this message translates to:
  /// **'إيراد'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get expense;

  /// No description provided for @draft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get draft;

  /// No description provided for @settlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية'**
  String get settlement;

  /// No description provided for @refund.
  ///
  /// In ar, this message translates to:
  /// **'استرداد'**
  String get refund;

  /// No description provided for @archived.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get archived;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'ساري'**
  String get active;

  /// No description provided for @docPreviousVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة سابقة'**
  String get docPreviousVersion;

  /// No description provided for @docMissingExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء غير مضاف'**
  String get docMissingExpiry;

  /// No description provided for @docExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get docExpired;

  /// No description provided for @docExpiresToday.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي اليوم'**
  String get docExpiresToday;

  /// No description provided for @docExpiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريبًا'**
  String get docExpiringSoon;

  /// No description provided for @docRegistration.
  ///
  /// In ar, this message translates to:
  /// **'الاستمارة'**
  String get docRegistration;

  /// No description provided for @docInsurance.
  ///
  /// In ar, this message translates to:
  /// **'التأمين'**
  String get docInsurance;

  /// No description provided for @docInspection.
  ///
  /// In ar, this message translates to:
  /// **'الفحص الدوري'**
  String get docInspection;

  /// No description provided for @docPermit.
  ///
  /// In ar, this message translates to:
  /// **'ترخيص / تصريح'**
  String get docPermit;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// No description provided for @docOther.
  ///
  /// In ar, this message translates to:
  /// **'مستند آخر'**
  String get docOther;

  /// No description provided for @document.
  ///
  /// In ar, this message translates to:
  /// **'مستند'**
  String get document;

  /// No description provided for @docLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل البيانات. حاول مرة أخرى.'**
  String get docLoadFailed;

  /// No description provided for @closeAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق المرفق'**
  String get closeAttachment;

  /// No description provided for @fileTypes.
  ///
  /// In ar, this message translates to:
  /// **'صور وملفات PDF'**
  String get fileTypes;

  /// No description provided for @fileTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملفًا لا يتجاوز 10 ميغابايت'**
  String get fileTooLarge;

  /// No description provided for @unsupportedFile.
  ///
  /// In ar, this message translates to:
  /// **'اختر PNG أو JPEG أو PDF؛ حوّل HEIC إلى JPEG قبل الرفع'**
  String get unsupportedFile;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالخادم؛ تحقق من تشغيله ثم أعد المحاولة'**
  String get networkError;

  /// No description provided for @requestFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إكمال الطلب؛ أعد المحاولة'**
  String get requestFailed;

  /// No description provided for @sessionRequired.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للمتابعة'**
  String get sessionRequired;

  /// No description provided for @financialTotalLocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير الإجمالي بعد أول حركة مالية'**
  String get financialTotalLocked;

  /// No description provided for @documentAlreadyRenewed.
  ///
  /// In ar, this message translates to:
  /// **'جُدد هذا المستند بالفعل'**
  String get documentAlreadyRenewed;

  /// No description provided for @accessDenied.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية الوصول لهذه البيانات'**
  String get accessDenied;

  /// No description provided for @invalidInput.
  ///
  /// In ar, this message translates to:
  /// **'راجع البيانات المدخلة وأعد المحاولة'**
  String get invalidInput;

  /// No description provided for @invalidOtp.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح أو انتهت صلاحيته؛ اطلب رمزًا جديدًا'**
  String get invalidOtp;

  /// No description provided for @sessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك؛ سجّل الدخول من جديد'**
  String get sessionExpired;

  /// No description provided for @otpThrottled.
  ///
  /// In ar, this message translates to:
  /// **'انتظر قليلًا قبل طلب رمز جديد'**
  String get otpThrottled;

  /// No description provided for @recordNotFound.
  ///
  /// In ar, this message translates to:
  /// **'تعذر العثور على السجل المطلوب'**
  String get recordNotFound;

  /// No description provided for @documentVersionChanged.
  ///
  /// In ar, this message translates to:
  /// **'تغيرت نسخة المستند؛ حدّث الصفحة قبل التعديل'**
  String get documentVersionChanged;

  /// No description provided for @documentLocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعديل هذا المستند في حالته الحالية'**
  String get documentLocked;

  /// No description provided for @fileUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير متاح الآن؛ أعد المحاولة لاحقًا'**
  String get fileUnavailable;

  /// No description provided for @attachmentLimit.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى الحد المسموح للمرفقات'**
  String get attachmentLimit;

  /// No description provided for @idempotencyConflict.
  ///
  /// In ar, this message translates to:
  /// **'تغيرت بيانات الطلب؛ راجع السجل قبل إعادة الحفظ'**
  String get idempotencyConflict;

  /// No description provided for @immutableAttachment.
  ///
  /// In ar, this message translates to:
  /// **'المرفق محفوظ؛ أضف مرفقًا جديدًا لتغييره'**
  String get immutableAttachment;

  /// No description provided for @unsupportedLocale.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة مدعومة'**
  String get unsupportedLocale;

  /// No description provided for @notificationDocumentExpiryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستند ينتهي قريبًا'**
  String get notificationDocumentExpiryTitle;

  /// No description provided for @notificationDocumentExpiryBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع مستند المعدة'**
  String get notificationDocumentExpiryBody;

  /// No description provided for @notificationWeeklyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستندات تحتاج انتباهك'**
  String get notificationWeeklyTitle;

  /// No description provided for @notificationWeeklyBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع المستندات المنتهية'**
  String get notificationWeeklyBody;

  /// No description provided for @unreadNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات • {count} غير مقروء'**
  String unreadNotifications(int count);

  /// No description provided for @categoryFuel.
  ///
  /// In ar, this message translates to:
  /// **'وقود'**
  String get categoryFuel;

  /// No description provided for @categoryMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة'**
  String get categoryMaintenance;

  /// No description provided for @paidFull.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع كاملًا'**
  String get paidFull;

  /// No description provided for @paidPartial.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع جزئيًا'**
  String get paidPartial;

  /// No description provided for @unpaid.
  ///
  /// In ar, this message translates to:
  /// **'غير مدفوع'**
  String get unpaid;

  /// No description provided for @receivedFull.
  ///
  /// In ar, this message translates to:
  /// **'مستلم كاملًا'**
  String get receivedFull;

  /// No description provided for @receivedPartial.
  ///
  /// In ar, this message translates to:
  /// **'مستلم جزئيًا'**
  String get receivedPartial;

  /// No description provided for @unreceived.
  ///
  /// In ar, this message translates to:
  /// **'غير مستلم'**
  String get unreceived;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get cancelled;

  /// No description provided for @generalExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف عام'**
  String get generalExpense;

  /// No description provided for @addEquipment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة معدة'**
  String get addEquipment;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إيراد'**
  String get addIncome;

  /// No description provided for @addDocument.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستند'**
  String get addDocument;

  /// No description provided for @saveDocument.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المستند'**
  String get saveDocument;

  /// No description provided for @attachments.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات'**
  String get attachments;

  /// No description provided for @archive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get archive;

  /// No description provided for @restoreDocument.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المستند'**
  String get restoreDocument;

  /// No description provided for @currentDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات الحالية'**
  String get currentDocuments;

  /// No description provided for @previousVersions.
  ///
  /// In ar, this message translates to:
  /// **'النسخ السابقة'**
  String get previousVersions;

  /// No description provided for @noDocuments.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف مستندات لهذه المعدة بعد'**
  String get noDocuments;

  /// No description provided for @noAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات بعد'**
  String get noAttachments;

  /// No description provided for @searchEquipment.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو الرقم الداخلي'**
  String get searchEquipment;

  /// No description provided for @searchLedger.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في السجل'**
  String get searchLedger;

  /// No description provided for @noEquipmentMatches.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدات تطابق البحث'**
  String get noEquipmentMatches;

  /// No description provided for @noEntries.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات مسجلة بعد'**
  String get noEntries;

  /// No description provided for @signInCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get signInCode;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneNumber;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @model.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get model;

  /// No description provided for @documentType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المستند'**
  String get documentType;

  /// No description provided for @newExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء الجديد'**
  String get newExpiryDate;

  /// No description provided for @renewDocument.
  ///
  /// In ar, this message translates to:
  /// **'تجديد المستند'**
  String get renewDocument;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @general.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get general;

  /// No description provided for @ui2021OrFh16.
  ///
  /// In ar, this message translates to:
  /// **'2021 أو FH16'**
  String get ui2021OrFh16;

  /// No description provided for @uiEnterTheVerificationCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get uiEnterTheVerificationCode;

  /// No description provided for @uiArchiveDocument.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المستند'**
  String get uiArchiveDocument;

  /// No description provided for @uiArchiveDocument005.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المستند؟'**
  String get uiArchiveDocument005;

  /// No description provided for @uiArchiveEquipment.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المعدة'**
  String get uiArchiveEquipment;

  /// No description provided for @uiArchiveEquipment007.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المعدة؟'**
  String get uiArchiveEquipment007;

  /// No description provided for @uiRemoveTheDueDateOnceFullyPaid.
  ///
  /// In ar, this message translates to:
  /// **'أزل موعد الاستحقاق عند سداد الإجمالي'**
  String get uiRemoveTheDueDateOnceFullyPaid;

  /// No description provided for @uiAddExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'أضف تاريخ الانتهاء'**
  String get uiAddExpiryDate;

  /// No description provided for @uiMultipleEquipment.
  ///
  /// In ar, this message translates to:
  /// **'أكثر من معدة'**
  String get uiMultipleEquipment;

  /// No description provided for @uiReturnedToTheCustomerOrOtherParty.
  ///
  /// In ar, this message translates to:
  /// **'أُعيد إلى العميل أو الطرف الآخر'**
  String get uiReturnedToTheCustomerOrOtherParty;

  /// No description provided for @uiTotalIncome.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيراد'**
  String get uiTotalIncome;

  /// No description provided for @uiTotalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروف'**
  String get uiTotalExpenses;

  /// No description provided for @uiRemoveEquipment.
  ///
  /// In ar, this message translates to:
  /// **'إزالة المعدة'**
  String get uiRemoveEquipment;

  /// No description provided for @uiRemoveDueDate.
  ///
  /// In ar, this message translates to:
  /// **'إزالة موعد الاستحقاق'**
  String get uiRemoveDueDate;

  /// No description provided for @uiAddReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تحصيل'**
  String get uiAddReceipt;

  /// No description provided for @uiAddPayment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دفعة'**
  String get uiAddPayment;

  /// No description provided for @uiAddImageOrPdf.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة أو PDF'**
  String get uiAddImageOrPdf;

  /// No description provided for @uiAddImageOrPdfOptional.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة أو PDF (اختياري)'**
  String get uiAddImageOrPdfOptional;

  /// No description provided for @uiAddAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مرفق'**
  String get uiAddAttachment;

  /// No description provided for @uiAddSeparateDocument.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستند منفصل'**
  String get uiAddSeparateDocument;

  /// No description provided for @uiAddGeneralExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف عام'**
  String get uiAddGeneralExpense;

  /// No description provided for @uiUploadAttachmentAgain.
  ///
  /// In ar, this message translates to:
  /// **'إعادة رفع المرفق'**
  String get uiUploadAttachmentAgain;

  /// No description provided for @uiRetryTheSameSave.
  ///
  /// In ar, this message translates to:
  /// **'إعادة محاولة الحفظ نفسه'**
  String get uiRetryTheSameSave;

  /// No description provided for @uiRetryUploadingAttachments.
  ///
  /// In ar, this message translates to:
  /// **'إعادة محاولة رفع المرفقات'**
  String get uiRetryUploadingAttachments;

  /// No description provided for @uiRetryFileUpload.
  ///
  /// In ar, this message translates to:
  /// **'إعادة محاولة رفع الملف'**
  String get uiRetryFileUpload;

  /// No description provided for @uiClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get uiClose;

  /// No description provided for @uiCancelEntry.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء العملية'**
  String get uiCancelEntry;

  /// No description provided for @uiToDate.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get uiToDate;

  /// No description provided for @uiSearchByEquipmentNameOrReference.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم المعدة أو مرجعها'**
  String get uiSearchByEquipmentNameOrReference;

  /// No description provided for @uiStartByAddingYourEquipment.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة معداتك'**
  String get uiStartByAddingYourEquipment;

  /// No description provided for @uiStartWithEquipmentNameAndModel.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ باسم المعدة وموديلها'**
  String get uiStartWithEquipmentNameAndModel;

  /// No description provided for @uiStartWithYourMobileNumber.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ برقم جوالك'**
  String get uiStartWithYourMobileNumber;

  /// No description provided for @uiSelectTheEquipmentThisExpenseBelongsTo.
  ///
  /// In ar, this message translates to:
  /// **'اختر المعدات التي يخصها المصروف'**
  String get uiSelectTheEquipmentThisExpenseBelongsTo;

  /// No description provided for @uiSelectEquipment.
  ///
  /// In ar, this message translates to:
  /// **'اختر المعدة'**
  String get uiSelectEquipment;

  /// No description provided for @uiSelectIssueDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ الإصدار'**
  String get uiSelectIssueDate;

  /// No description provided for @uiSelectExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ الانتهاء'**
  String get uiSelectExpiryDate;

  /// No description provided for @uiSelectEquipment051.
  ///
  /// In ar, this message translates to:
  /// **'اختر معدة'**
  String get uiSelectEquipment051;

  /// No description provided for @uiChooseAnotherFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف آخر'**
  String get uiChooseAnotherFile;

  /// No description provided for @uiText054.
  ///
  /// In ar, this message translates to:
  /// **'اردو'**
  String get uiText054;

  /// No description provided for @uiDiscardDraft.
  ///
  /// In ar, this message translates to:
  /// **'استبعاد المسودة'**
  String get uiDiscardDraft;

  /// No description provided for @uiDiscardDraft056.
  ///
  /// In ar, this message translates to:
  /// **'استبعاد المسودة؟'**
  String get uiDiscardDraft056;

  /// No description provided for @uiExcludeGeneralExpenses.
  ///
  /// In ar, this message translates to:
  /// **'استبعاد المصروف العام'**
  String get uiExcludeGeneralExpenses;

  /// No description provided for @uiRestoreEquipment.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المعدة'**
  String get uiRestoreEquipment;

  /// No description provided for @uiRestoreTheEquipmentBeforeRestoringThisDocument.
  ///
  /// In ar, this message translates to:
  /// **'استعد المعدة أولًا لاستعادة المستند.'**
  String get uiRestoreTheEquipmentBeforeRestoringThisDocument;

  /// No description provided for @uiCompleteAsIncome.
  ///
  /// In ar, this message translates to:
  /// **'استكمال كإيراد'**
  String get uiCompleteAsIncome;

  /// No description provided for @uiCompleteAsExpense.
  ///
  /// In ar, this message translates to:
  /// **'استكمال كمصروف'**
  String get uiCompleteAsExpense;

  /// No description provided for @uiCompleteTheSavedInvoiceDetailsItsAttachments.
  ///
  /// In ar, this message translates to:
  /// **'استكمل بيانات الفاتورة المحفوظة؛ المرفقات ستبقى معها.'**
  String get uiCompleteTheSavedInvoiceDetailsItsAttachments;

  /// No description provided for @uiPartiallyReceived.
  ///
  /// In ar, this message translates to:
  /// **'استلمت جزءًا'**
  String get uiPartiallyReceived;

  /// No description provided for @uiReceivedInFull.
  ///
  /// In ar, this message translates to:
  /// **'استلمته كاملًا'**
  String get uiReceivedInFull;

  /// No description provided for @uiReceived.
  ///
  /// In ar, this message translates to:
  /// **'استُلمت'**
  String get uiReceived;

  /// No description provided for @uiNameOfThePartyWhoWillPay.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطرف الذي سيدفع'**
  String get uiNameOfThePartyWhoWillPay;

  /// No description provided for @uiNameOfThePartyOwed.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطرف المستحق'**
  String get uiNameOfThePartyOwed;

  /// No description provided for @uiCustomerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get uiCustomerName;

  /// No description provided for @uiDocumentName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستند'**
  String get uiDocumentName;

  /// No description provided for @uiEquipmentName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعدة'**
  String get uiEquipmentName;

  /// No description provided for @uiEquipmentNameReferencePartyOrNote.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعدة أو مرجعها أو الطرف أو الملاحظة'**
  String get uiEquipmentNameReferencePartyOrNote;

  /// No description provided for @uiSupplierOrPartyName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المورد أو الطرف'**
  String get uiSupplierOrPartyName;

  /// No description provided for @uiEnterPartyName.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم الطرف'**
  String get uiEnterPartyName;

  /// No description provided for @uiEnterPartyNameWhenABalanceRemains.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم الطرف عند وجود متبقٍ'**
  String get uiEnterPartyNameWhenABalanceRemains;

  /// No description provided for @uiEnterPartyNameABalanceWillRemain.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم الطرف؛ بعد الاسترداد سيبقى مبلغ مستحق'**
  String get uiEnterPartyNameABalanceWillRemain;

  /// No description provided for @uiEnterDocumentName.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المستند'**
  String get uiEnterDocumentName;

  /// No description provided for @uiEnterEquipmentName.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المعدة'**
  String get uiEnterEquipmentName;

  /// No description provided for @uiEnterYourNameToContinue.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الاسم للمتابعة'**
  String get uiEnterYourNameToContinue;

  /// No description provided for @uiEnterTheDateLike20260925.
  ///
  /// In ar, this message translates to:
  /// **'اكتب التاريخ بهذا الشكل: 2026-09-25'**
  String get uiEnterTheDateLike20260925;

  /// No description provided for @uiEnterModel.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الموديل'**
  String get uiEnterModel;

  /// No description provided for @uiEnterCancellationReason.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الإلغاء'**
  String get uiEnterCancellationReason;

  /// No description provided for @uiEnterRefundReason.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الاسترداد'**
  String get uiEnterRefundReason;

  /// No description provided for @uiEnterAValidRefundAmount.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مبلغ استرداد صحيحًا'**
  String get uiEnterAValidRefundAmount;

  /// No description provided for @uiEnterAnAmountAboveZeroAndBelow.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مبلغًا أكبر من صفر وأقل من الإجمالي'**
  String get uiEnterAnAmountAboveZeroAndBelow;

  /// No description provided for @uiEnterAnAmountAboveZeroUpTo.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مبلغًا أكبر من صفر، حتى منزلتين عشريتين'**
  String get uiEnterAnAmountAboveZeroUpTo;

  /// No description provided for @uiEnterAValidAmount.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مبلغًا صحيحًا'**
  String get uiEnterAValidAmount;

  /// No description provided for @uiDevelopmentNumbers0500000001Or0500000002.
  ///
  /// In ar, this message translates to:
  /// **'أرقام التطوير: 0500000000–0500000999، بما فيها أرقام المدعوين'**
  String get uiDevelopmentNumbers0500000001Or0500000002;

  /// No description provided for @uiTotalSar.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي (ريال سعودي)'**
  String get uiTotalSar;

  /// No description provided for @uiRefunds.
  ///
  /// In ar, this message translates to:
  /// **'الاستردادات'**
  String get uiRefunds;

  /// No description provided for @uiNameAndModelAreEnoughToStart.
  ///
  /// In ar, this message translates to:
  /// **'الاسم والموديل يكفيان للبداية. نضيف رقمًا داخليًا تلقائيًا.'**
  String get uiNameAndModelAreEnoughToStart;

  /// No description provided for @uiReceipts.
  ///
  /// In ar, this message translates to:
  /// **'التحصيلات'**
  String get uiReceipts;

  /// No description provided for @uiPreviousPaymentsAreKeptAndDoNot.
  ///
  /// In ar, this message translates to:
  /// **'التسويات السابقة محفوظة ولا تتغير بالتعديل.'**
  String get uiPreviousPaymentsAreKeptAndDoNot;

  /// No description provided for @uiPayments.
  ///
  /// In ar, this message translates to:
  /// **'الدفعات'**
  String get uiPayments;

  /// No description provided for @uiGeneralRecords.
  ///
  /// In ar, this message translates to:
  /// **'السجل العام'**
  String get uiGeneralRecords;

  /// No description provided for @uiArchivedRecords.
  ///
  /// In ar, this message translates to:
  /// **'السجل المؤرشف'**
  String get uiArchivedRecords;

  /// No description provided for @uiText102.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get uiText102;

  /// No description provided for @uiAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get uiAll;

  /// No description provided for @uiAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get uiAmount;

  /// No description provided for @uiAmountSar.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ (ريال سعودي)'**
  String get uiAmountSar;

  /// No description provided for @uiInitialPayment.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدفوع أولًا'**
  String get uiInitialPayment;

  /// No description provided for @uiInitialReceipt.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المستلم أولًا'**
  String get uiInitialReceipt;

  /// No description provided for @uiBalanceYouOwe.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي عليك'**
  String get uiBalanceYouOwe;

  /// No description provided for @uiBalanceOwedToYou.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي لك'**
  String get uiBalanceOwedToYou;

  /// No description provided for @uiTotalPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع إجمالًا'**
  String get uiTotalPaid;

  /// No description provided for @uiPaidAndRefundedAmountsBelowAreCalculated.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع والمسترد أدناه حصص محسوبة؛ الدفعات والاستردادات الأصلية مسجلة مرة واحدة على المصروف.'**
  String get uiPaidAndRefundedAmountsBelowAreCalculated;

  /// No description provided for @uiRefundedBySupplier.
  ///
  /// In ar, this message translates to:
  /// **'المسترد من المورد'**
  String get uiRefundedBySupplier;

  /// No description provided for @uiTotalReceived.
  ///
  /// In ar, this message translates to:
  /// **'المستلم إجمالًا'**
  String get uiTotalReceived;

  /// No description provided for @uiDocument.
  ///
  /// In ar, this message translates to:
  /// **'المستند'**
  String get uiDocument;

  /// No description provided for @uiGeneralExpense.
  ///
  /// In ar, this message translates to:
  /// **'المصروف العام'**
  String get uiGeneralExpense;

  /// No description provided for @uiExpenseAppliesTo.
  ///
  /// In ar, this message translates to:
  /// **'المصروف يخص'**
  String get uiExpenseAppliesTo;

  /// No description provided for @uiReturnedToCustomer.
  ///
  /// In ar, this message translates to:
  /// **'المعاد للعميل'**
  String get uiReturnedToCustomer;

  /// No description provided for @uiEquipment.
  ///
  /// In ar, this message translates to:
  /// **'المعدة'**
  String get uiEquipment;

  /// No description provided for @uiAwaitingCompletion.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاستكمال'**
  String get uiAwaitingCompletion;

  /// No description provided for @uiAwaitingCompletionThisWillNotCountAs.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاستكمال • لن تُحتسب كعملية مالية حتى تُدخل بياناتها لاحقًا.'**
  String get uiAwaitingCompletionThisWillNotCountAs;

  /// No description provided for @uiSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get uiSearch;

  /// No description provided for @uiNoExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'بدون تاريخ انتهاء'**
  String get uiNoExpiryDate;

  /// No description provided for @uiABalanceWillRemainAfterTheRefund.
  ///
  /// In ar, this message translates to:
  /// **'بعد الاسترداد سيبقى مبلغ مستحق؛ سجّل اسم الطرف للمتابعة.'**
  String get uiABalanceWillRemainAfterTheRefund;

  /// No description provided for @uiWhatShouldWeCallYou.
  ///
  /// In ar, this message translates to:
  /// **'بماذا نناديك؟'**
  String get uiWhatShouldWeCallYou;

  /// No description provided for @uiDetailsToComplete.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تحتاج استكمال'**
  String get uiDetailsToComplete;

  /// No description provided for @uiConfirmCancellation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get uiConfirmCancellation;

  /// No description provided for @uiConfirmCode.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز'**
  String get uiConfirmCode;

  /// No description provided for @uiIssueDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإصدار (اختياري)'**
  String get uiIssueDateOptional;

  /// No description provided for @uiIssueDateIsAfterExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإصدار بعد تاريخ الانتهاء'**
  String get uiIssueDateIsAfterExpiryDate;

  /// No description provided for @uiExpiryDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء (اختياري)'**
  String get uiExpiryDateOptional;

  /// No description provided for @uiRenewCurrentDocument.
  ///
  /// In ar, this message translates to:
  /// **'تجديد الحالي'**
  String get uiRenewCurrentDocument;

  /// No description provided for @uiUpdateIncome.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الإيراد'**
  String get uiUpdateIncome;

  /// No description provided for @uiRefreshRecords.
  ///
  /// In ar, this message translates to:
  /// **'تحديث السجل'**
  String get uiRefreshRecords;

  /// No description provided for @uiUpdateDocument.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المستند'**
  String get uiUpdateDocument;

  /// No description provided for @uiUpdateDraft.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المسودة'**
  String get uiUpdateDraft;

  /// No description provided for @uiUpdateExpense.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المصروف'**
  String get uiUpdateExpense;

  /// No description provided for @uiLocalDevelopmentStorageMalwareScanningIsNot.
  ///
  /// In ar, this message translates to:
  /// **'تخزين تطوير محلي. لم يُفعّل فحص البرمجيات الضارة.'**
  String get uiLocalDevelopmentStorageMalwareScanningIsNot;

  /// No description provided for @uiRecordRefund.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل استرداد'**
  String get uiRecordRefund;

  /// No description provided for @uiFilterRecords.
  ///
  /// In ar, this message translates to:
  /// **'تصفية السجل'**
  String get uiFilterRecords;

  /// No description provided for @uiUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعثر الرفع'**
  String get uiUploadFailed;

  /// No description provided for @uiUploadFailedTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'تعثر الرفع؛ أعد المحاولة'**
  String get uiUploadFailedTryAgain;

  /// No description provided for @uiAttachmentUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعثر رفع المرفق'**
  String get uiAttachmentUploadFailed;

  /// No description provided for @uiEditIncome.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإيراد'**
  String get uiEditIncome;

  /// No description provided for @uiEditDocument.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المستند'**
  String get uiEditDocument;

  /// No description provided for @uiEditExpense.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المصروف'**
  String get uiEditExpense;

  /// No description provided for @uiCouldNotLoadDocumentsTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المستندات • إعادة المحاولة'**
  String get uiCouldNotLoadDocumentsTryAgain;

  /// No description provided for @uiCouldNotLoadDocumentsTryAgain161.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المستندات. حاول مرة أخرى.'**
  String get uiCouldNotLoadDocumentsTryAgain161;

  /// No description provided for @uiChangeNumberOrRequestANewCode.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم أو طلب رمز جديد'**
  String get uiChangeNumberOrRequestANewCode;

  /// No description provided for @uiIncomeDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإيراد'**
  String get uiIncomeDetails;

  /// No description provided for @uiExpenseDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المصروف'**
  String get uiExpenseDetails;

  /// No description provided for @uiDownloadPdf.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل PDF'**
  String get uiDownloadPdf;

  /// No description provided for @uiDownloadAttachment.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل المرفق'**
  String get uiDownloadAttachment;

  /// No description provided for @uiCancelling.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإلغاء…'**
  String get uiCancelling;

  /// No description provided for @uiVerifying.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحقق…'**
  String get uiVerifying;

  /// No description provided for @uiSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ...'**
  String get uiSaving;

  /// No description provided for @uiSaving170.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ…'**
  String get uiSaving170;

  /// No description provided for @uiSavingChanges.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ التعديل…'**
  String get uiSavingChanges;

  /// No description provided for @uiSavingEquipment.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ المعدة…'**
  String get uiSavingEquipment;

  /// No description provided for @uiUploadingAndCheckingAttachment.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ رفع المرفق والتحقق منه…'**
  String get uiUploadingAndCheckingAttachment;

  /// No description provided for @uiReadyToRetryUpload.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لإعادة محاولة الرفع'**
  String get uiReadyToRetryUpload;

  /// No description provided for @uiReadyToUpload.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للرفع'**
  String get uiReadyToUpload;

  /// No description provided for @uiReadyToView.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للعرض'**
  String get uiReadyToView;

  /// No description provided for @uiReceiptStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاستلام'**
  String get uiReceiptStatus;

  /// No description provided for @uiSettlementStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة التسوية'**
  String get uiSettlementStatus;

  /// No description provided for @uiPaymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get uiPaymentStatus;

  /// No description provided for @uiEntryStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة العملية'**
  String get uiEntryStatus;

  /// No description provided for @uiSelectDifferentEquipmentAndMakeTheirAmounts.
  ///
  /// In ar, this message translates to:
  /// **'حدد معدات مختلفة واجعل مجموع مبالغها يساوي إجمالي المصروف'**
  String get uiSelectDifferentEquipmentAndMakeTheirAmounts;

  /// No description provided for @uiSaveRefund.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الاسترداد'**
  String get uiSaveRefund;

  /// No description provided for @uiSaveReceipt.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التحصيل'**
  String get uiSaveReceipt;

  /// No description provided for @uiSaveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديل'**
  String get uiSaveChanges;

  /// No description provided for @uiSavePayment.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الدفعة'**
  String get uiSavePayment;

  /// No description provided for @uiSaveInvoiceNowAndCompleteDetailsLater.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفاتورة الآن وإكمال البيانات لاحقًا'**
  String get uiSaveInvoiceNowAndCompleteDetailsLater;

  /// No description provided for @uiSaveEquipment.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المعدة'**
  String get uiSaveEquipment;

  /// No description provided for @uiSaveInvoiceNow.
  ///
  /// In ar, this message translates to:
  /// **'حفظ فاتورة الآن'**
  String get uiSaveInvoiceNow;

  /// No description provided for @uiAttachmentSavedWithEntry.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ المرفق داخل العملية'**
  String get uiAttachmentSavedWithEntry;

  /// No description provided for @uiPaidPartOfIt.
  ///
  /// In ar, this message translates to:
  /// **'دفعت جزءًا'**
  String get uiPaidPartOfIt;

  /// No description provided for @uiPaidInFull.
  ///
  /// In ar, this message translates to:
  /// **'دفعته كاملًا'**
  String get uiPaidInFull;

  /// No description provided for @uiPaid.
  ///
  /// In ar, this message translates to:
  /// **'دُفعت'**
  String get uiPaid;

  /// No description provided for @uiDocumentNumberOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم المستند (اختياري)'**
  String get uiDocumentNumberOptional;

  /// No description provided for @uiDevelopmentCodeOnly123456.
  ///
  /// In ar, this message translates to:
  /// **'رمز التطوير فقط: 123456'**
  String get uiDevelopmentCodeOnly123456;

  /// No description provided for @uiCancellationReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get uiCancellationReason;

  /// No description provided for @uiRefundReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الاسترداد'**
  String get uiRefundReason;

  /// No description provided for @uiPaymentsAndAttachmentsWillRemainInThe.
  ///
  /// In ar, this message translates to:
  /// **'ستبقى الدفعات والمرفقات في السجل. الإلغاء ليس استردادًا للمال.'**
  String get uiPaymentsAndAttachmentsWillRemainInThe;

  /// No description provided for @uiUnsavedDataWillBeLostIfYou.
  ///
  /// In ar, this message translates to:
  /// **'ستفقد البيانات غير المحفوظة. إذا لم يصل تأكيد الحفظ، راجع السجل قبل إنشاء طلب آخر.'**
  String get uiUnsavedDataWillBeLostIfYou;

  /// No description provided for @uiEquipmentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المعدة'**
  String get uiEquipmentHistory;

  /// No description provided for @uiEquipmentHistoryAndDocumentsWillRemainSaved.
  ///
  /// In ar, this message translates to:
  /// **'سيبقى سجل المعدة ومستنداتها محفوظًا، وتتوقف تنبيهات انتهاء مستنداتها حتى استعادتها.'**
  String get uiEquipmentHistoryAndDocumentsWillRemainSaved;

  /// No description provided for @uiThePreviousDocumentWillBeKeptIn.
  ///
  /// In ar, this message translates to:
  /// **'سيُحفظ المستند السابق في السجل. أضف تاريخ انتهاء جديدًا للمستند المجدد.'**
  String get uiThePreviousDocumentWillBeKeptIn;

  /// No description provided for @uiNetPaid.
  ///
  /// In ar, this message translates to:
  /// **'صافي المدفوع'**
  String get uiNetPaid;

  /// No description provided for @uiNetReceived.
  ///
  /// In ar, this message translates to:
  /// **'صافي المستلم'**
  String get uiNetReceived;

  /// No description provided for @uiImagesAndInvoicePdfs.
  ///
  /// In ar, this message translates to:
  /// **'صور وفواتير PDF'**
  String get uiImagesAndInvoicePdfs;

  /// No description provided for @uiRequestVerificationCode.
  ///
  /// In ar, this message translates to:
  /// **'طلب رمز التحقق'**
  String get uiRequestVerificationCode;

  /// No description provided for @uiReturnedToYouByTheOtherParty.
  ///
  /// In ar, this message translates to:
  /// **'عاد إليك من الطرف الآخر'**
  String get uiReturnedToYouByTheOtherParty;

  /// No description provided for @uiSeveralEquipment.
  ///
  /// In ar, this message translates to:
  /// **'عدة معدات'**
  String get uiSeveralEquipment;

  /// No description provided for @uiAdjustEachEquipmentAmountToMatchThe.
  ///
  /// In ar, this message translates to:
  /// **'عدّل مبلغ كل معدة بحيث يساوي الإجمالي.'**
  String get uiAdjustEachEquipmentAmountToMatchThe;

  /// No description provided for @uiViewRecordsAndEntries.
  ///
  /// In ar, this message translates to:
  /// **'عرض السجل والعمليات ←'**
  String get uiViewRecordsAndEntries;

  /// No description provided for @uiViewAttachment.
  ///
  /// In ar, this message translates to:
  /// **'عرض المرفق'**
  String get uiViewAttachment;

  /// No description provided for @uiViewDocuments.
  ///
  /// In ar, this message translates to:
  /// **'عرض المستندات'**
  String get uiViewDocuments;

  /// No description provided for @uiUnsettled.
  ///
  /// In ar, this message translates to:
  /// **'غير مسوّى'**
  String get uiUnsettled;

  /// No description provided for @uiOpenPdf.
  ///
  /// In ar, this message translates to:
  /// **'فتح PDF'**
  String get uiOpenPdf;

  /// No description provided for @uiOpenSavedDraft.
  ///
  /// In ar, this message translates to:
  /// **'فتح المسودة المحفوظة'**
  String get uiOpenSavedDraft;

  /// No description provided for @uiTipper1.
  ///
  /// In ar, this message translates to:
  /// **'قلاب ١'**
  String get uiTipper1;

  /// No description provided for @uiEachEntryItsPaymentsAndAttachmentsIn.
  ///
  /// In ar, this message translates to:
  /// **'كل عملية ودفعاتها ومرفقاتها في سجل واحد'**
  String get uiEachEntryItsPaymentsAndAttachmentsIn;

  /// No description provided for @uiNoEntriesMatchYourSearchOrFilters.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات تطابق البحث أو المرشحات. جرّب تغييرها أو مسحها.'**
  String get uiNoEntriesMatchYourSearchOrFilters;

  /// No description provided for @uiNoInvoicesAwaitingCompletion.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير بانتظار الاستكمال'**
  String get uiNoInvoicesAwaitingCompletion;

  /// No description provided for @uiNoDocumentsNeedAttentionNow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مستندات تحتاج انتباه الآن'**
  String get uiNoDocumentsNeedAttentionNow;

  /// No description provided for @uiNoDocumentsHaveMissingInformation.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مستندات ناقصة البيانات'**
  String get uiNoDocumentsHaveMissingInformation;

  /// No description provided for @uiNoMatchingEquipment.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدات مطابقة للبحث'**
  String get uiNoMatchingEquipment;

  /// No description provided for @uiNoPreviousVersionsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نسخ سابقة بعد'**
  String get uiNoPreviousVersionsYet;

  /// No description provided for @uiTheTotalCannotChangeAfterAPayment.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير الإجمالي بعد تسجيل دفعة أو تحصيل أو استرداد'**
  String get uiTheTotalCannotChangeAfterAPayment;

  /// No description provided for @uiTheTotalCannotChangeBecauseAPayment.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير الإجمالي لوجود دفعة أو تحصيل أو استرداد.'**
  String get uiTheTotalCannotChangeBecauseAPayment;

  /// No description provided for @uiNotPaid.
  ///
  /// In ar, this message translates to:
  /// **'لم أدفعه'**
  String get uiNotPaid;

  /// No description provided for @uiNotReceived.
  ///
  /// In ar, this message translates to:
  /// **'لم أستلمه'**
  String get uiNotReceived;

  /// No description provided for @uiUploadIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'لم يكتمل الرفع'**
  String get uiUploadIncomplete;

  /// No description provided for @uiThisWillNotCountAsAFinancial.
  ///
  /// In ar, this message translates to:
  /// **'لن تُحتسب كعملية مالية. ستختفي المرفقات من القائمة بعد الاستبعاد.'**
  String get uiThisWillNotCountAsAFinancial;

  /// No description provided for @uiThisDocumentWillNoLongerAppearAmong.
  ///
  /// In ar, this message translates to:
  /// **'لن يظهر المستند ضمن المستندات الحالية ولن تصلك تنبيهات انتهاء خاصة به. سيبقى محفوظًا في السجل.'**
  String get uiThisDocumentWillNoLongerAppearAmong;

  /// No description provided for @uiRefundAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الاسترداد'**
  String get uiRefundAmount;

  /// No description provided for @uiRefundAmountExceedsWhatIsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الاسترداد أكبر من المتاح'**
  String get uiRefundAmountExceedsWhatIsAvailable;

  /// No description provided for @uiAmountPerEquipment.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ كل معدة'**
  String get uiAmountPerEquipment;

  /// No description provided for @uiContinueEntry.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الإدخال'**
  String get uiContinueEntry;

  /// No description provided for @uiWorkspace.
  ///
  /// In ar, this message translates to:
  /// **'مساحة العمل'**
  String get uiWorkspace;

  /// No description provided for @uiClearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح المرشحات'**
  String get uiClearFilters;

  /// No description provided for @uiPartiallySettled.
  ///
  /// In ar, this message translates to:
  /// **'مسوّى جزئيًا'**
  String get uiPartiallySettled;

  /// No description provided for @uiFullySettled.
  ///
  /// In ar, this message translates to:
  /// **'مسوّى كاملًا'**
  String get uiFullySettled;

  /// No description provided for @uiGeneralExpensesOnly.
  ///
  /// In ar, this message translates to:
  /// **'مصروف عام فقط'**
  String get uiGeneralExpensesOnly;

  /// No description provided for @uiAWorkspaceExpenseItIsNotAssigned.
  ///
  /// In ar, this message translates to:
  /// **'مصروف عام لمساحة العمل؛ لا يُحمّل على معدة'**
  String get uiAWorkspaceExpenseItIsNotAssigned;

  /// No description provided for @uiYourEquipmentAndExpensesInOnePlace.
  ///
  /// In ar, this message translates to:
  /// **'معداتك ومصروفاتك في مكان واحد'**
  String get uiYourEquipmentAndExpensesInOnePlace;

  /// No description provided for @uiOneEquipment.
  ///
  /// In ar, this message translates to:
  /// **'معدة واحدة'**
  String get uiOneEquipment;

  /// No description provided for @uiLeave.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة'**
  String get uiLeave;

  /// No description provided for @uiNoteOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get uiNoteOptional;

  /// No description provided for @uiFromDate.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get uiFromDate;

  /// No description provided for @uiDueDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'موعد الاستحقاق (اختياري)'**
  String get uiDueDateOptional;

  /// No description provided for @uiPreviousVersionIsViewOnly.
  ///
  /// In ar, this message translates to:
  /// **'نسخة سابقة للعرض فقط'**
  String get uiPreviousVersionIsViewOnly;

  /// No description provided for @uiActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get uiActive;

  /// No description provided for @uiSharePerEquipment.
  ///
  /// In ar, this message translates to:
  /// **'نصيب كل معدة'**
  String get uiSharePerEquipment;

  /// No description provided for @uiEntryType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العملية'**
  String get uiEntryType;

  /// No description provided for @uiExpenseType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المصروف'**
  String get uiExpenseType;

  /// No description provided for @uiThisInvoiceIsSavedForLaterCompletion.
  ///
  /// In ar, this message translates to:
  /// **'هذه الفاتورة محفوظة بانتظار الاستكمال، ولا تدخل المجاميع المالية بعد.'**
  String get uiThisInvoiceIsSavedForLaterCompletion;

  /// No description provided for @uiLeaveThisForm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مغادرة النموذج؟'**
  String get uiLeaveThisForm;

  /// No description provided for @uiNeedsAttention.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج انتباه'**
  String get uiNeedsAttention;

  /// No description provided for @uiExpenseAppliesTo276.
  ///
  /// In ar, this message translates to:
  /// **'يخص المصروف'**
  String get uiExpenseAppliesTo276;

  /// No description provided for @uiThisIncomeIsRecordedUnderThisEquipment.
  ///
  /// In ar, this message translates to:
  /// **'يُسجّل هذا الإيراد على هذه المعدة'**
  String get uiThisIncomeIsRecordedUnderThisEquipment;

  /// No description provided for @verifyPhone.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من {phone}'**
  String verifyPhone(String phone);

  /// No description provided for @modelValue.
  ///
  /// In ar, this message translates to:
  /// **'الموديل: {model}'**
  String modelValue(String model);

  /// No description provided for @fromDateValue.
  ///
  /// In ar, this message translates to:
  /// **'من {date}'**
  String fromDateValue(String date);

  /// No description provided for @toDateValue.
  ///
  /// In ar, this message translates to:
  /// **'إلى {date}'**
  String toDateValue(String date);

  /// No description provided for @entryDateStatus.
  ///
  /// In ar, this message translates to:
  /// **'{date} ميلادي\n{status}'**
  String entryDateStatus(String date, String status);

  /// No description provided for @draftUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت المسودة، وتعذر رفع الملف. أعد المحاولة. {error}'**
  String draftUploadFailed(String error);

  /// No description provided for @draftNote.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاستكمال\n{note}'**
  String draftNote(String note);

  /// No description provided for @noteValue.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة: {note}'**
  String noteValue(String note);

  /// No description provided for @allocationRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي للتوزيع: {amount}'**
  String allocationRemaining(String amount);

  /// No description provided for @operationDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ العملية: {date}'**
  String operationDate(String date);

  /// No description provided for @paymentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الدفع: {date}'**
  String paymentDate(String date);

  /// No description provided for @receiptDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستلام: {date}'**
  String receiptDate(String date);

  /// No description provided for @dueDateValue.
  ///
  /// In ar, this message translates to:
  /// **'موعد الاستحقاق: {date}'**
  String dueDateValue(String date);

  /// No description provided for @attachmentAfterSave.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إرفاق صورة أو PDF بعد حفظ {kind}.'**
  String attachmentAfterSave(String kind);

  /// No description provided for @savingKind.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ {kind}…'**
  String savingKind(String kind);

  /// No description provided for @saveKind.
  ///
  /// In ar, this message translates to:
  /// **'حفظ {kind}'**
  String saveKind(String kind);

  /// No description provided for @remainingValue.
  ///
  /// In ar, this message translates to:
  /// **'{label}: {amount}'**
  String remainingValue(String label, String amount);

  /// No description provided for @refundIncomeHelp.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ أُعيد إلى العميل أو الطرف الآخر. المتاح للاسترداد: {amount}'**
  String refundIncomeHelp(String amount);

  /// No description provided for @refundExpenseHelp.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ عاد إليك من المورد أو الطرف الآخر. المتاح للاسترداد: {amount}'**
  String refundExpenseHelp(String amount);

  /// No description provided for @refundDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ عودة المال: {date}'**
  String refundDate(String date);

  /// No description provided for @entryUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت العملية، وتعذر رفع المرفق. {error}'**
  String entryUploadFailed(String error);

  /// No description provided for @entryAttachmentLabel.
  ///
  /// In ar, this message translates to:
  /// **'مرفق العملية: {filename}'**
  String entryAttachmentLabel(String filename);

  /// No description provided for @cancelReasonValue.
  ///
  /// In ar, this message translates to:
  /// **'السبب: {reason}'**
  String cancelReasonValue(String reason);

  /// No description provided for @cancelDateValue.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإلغاء: {date}'**
  String cancelDateValue(String date);

  /// No description provided for @partAmount.
  ///
  /// In ar, this message translates to:
  /// **'{equipment}: {amount}'**
  String partAmount(String equipment, String amount);

  /// No description provided for @partNetRemaining.
  ///
  /// In ar, this message translates to:
  /// **'حصة محسوبة من صافي المدفوع: {paid} • المتبقي: {remaining}'**
  String partNetRemaining(String paid, String remaining);

  /// No description provided for @partyValue.
  ///
  /// In ar, this message translates to:
  /// **'الطرف: {party}'**
  String partyValue(String party);

  /// No description provided for @paidOn.
  ///
  /// In ar, this message translates to:
  /// **'دُفعت في {date}'**
  String paidOn(String date);

  /// No description provided for @receivedOn.
  ///
  /// In ar, this message translates to:
  /// **'استُلمت في {date}'**
  String receivedOn(String date);

  /// No description provided for @refundRecord.
  ///
  /// In ar, this message translates to:
  /// **'{kind} في {date}\nالسبب: {reason}'**
  String refundRecord(String kind, String date, String reason);

  /// No description provided for @filesHelp.
  ///
  /// In ar, this message translates to:
  /// **'صورة PNG أو JPEG، أو PDF • حتى 10 ميغابايت للملف'**
  String get filesHelp;

  /// No description provided for @noEntryAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف مرفقات بعد؛ العملية محفوظة.'**
  String get noEntryAttachments;

  /// No description provided for @documentSummary.
  ///
  /// In ar, this message translates to:
  /// **'{total} مستندات • {expired} منتهي • {soon} ينتهي قريبًا • {missing} بدون تاريخ انتهاء'**
  String documentSummary(
    String total,
    String expired,
    String soon,
    String missing,
  );

  /// No description provided for @equipmentDocumentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستندات {equipment}'**
  String equipmentDocumentsTitle(String equipment);

  /// No description provided for @documentAlreadyExists.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {document} حالي لهذه المعدة. هل تريد تجديده بدل إضافة مستند منفصل؟'**
  String documentAlreadyExists(String document);

  /// No description provided for @expiryValue.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي في {date}'**
  String expiryValue(String date);

  /// No description provided for @numberValue.
  ///
  /// In ar, this message translates to:
  /// **'الرقم: {number}'**
  String numberValue(String number);

  /// No description provided for @issueDateValue.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإصدار: {date}'**
  String issueDateValue(String date);

  /// No description provided for @versionNumber.
  ///
  /// In ar, this message translates to:
  /// **'النسخة {number}'**
  String versionNumber(String number);

  /// No description provided for @versionExpiry.
  ///
  /// In ar, this message translates to:
  /// **'انتهاء: {expiry}'**
  String versionExpiry(String expiry);

  /// No description provided for @versionIssue.
  ///
  /// In ar, this message translates to:
  /// **'إصدار: {date}'**
  String versionIssue(String date);

  /// No description provided for @versionNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم النسخة: {number}'**
  String versionNumberLabel(String number);

  /// No description provided for @documentNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم المستند: {number}'**
  String documentNumberLabel(String number);

  /// No description provided for @expiryDateValue.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء: {date}'**
  String expiryDateValue(String date);

  /// No description provided for @missingDocumentsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مستند بدون تاريخ انتهاء'**
  String missingDocumentsCount(String count);

  /// No description provided for @versionAttachments.
  ///
  /// In ar, this message translates to:
  /// **'مرفقات هذه النسخة'**
  String get versionAttachments;

  /// No description provided for @noAttachmentsShort.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات'**
  String get noAttachmentsShort;

  /// No description provided for @addExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تاريخ الانتهاء'**
  String get addExpiryDate;

  /// No description provided for @documentTypeExists.
  ///
  /// In ar, this message translates to:
  /// **'يوجد مستند من هذا النوع'**
  String get documentTypeExists;

  /// No description provided for @refreshDocuments.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المستندات'**
  String get refreshDocuments;

  /// No description provided for @cancelledAmountsHistory.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ والتسويات أدناه محفوظة للسجل، ولا تدخل العملية في المجاميع النشطة.'**
  String get cancelledAmountsHistory;

  /// No description provided for @cancelledEntry.
  ///
  /// In ar, this message translates to:
  /// **'عملية ملغاة'**
  String get cancelledEntry;

  /// No description provided for @timeoutMessage.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الطلب وقتًا طويلًا. إذا كنت تحفظ بيانات، راجع السجل قبل إعادة المحاولة.'**
  String get timeoutMessage;

  /// No description provided for @documentExpiryInDays.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي بعد {days} أيام'**
  String documentExpiryInDays(String days);

  /// No description provided for @documentExpiryToday.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي اليوم'**
  String get documentExpiryToday;

  /// No description provided for @documentExpiryPast.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get documentExpiryPast;

  /// No description provided for @weeklyExpiredCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مستندات منتهية تحتاج مراجعة'**
  String weeklyExpiredCount(String count);

  /// No description provided for @uploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر رفع الملف'**
  String get uploadFailed;

  /// No description provided for @sarUnit.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get sarUnit;

  /// No description provided for @m4Hub.
  ///
  /// In ar, this message translates to:
  /// **'الصيانة والبلاغات'**
  String get m4Hub;

  /// No description provided for @m4Issues.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات'**
  String get m4Issues;

  /// No description provided for @m4Maintenance.
  ///
  /// In ar, this message translates to:
  /// **'سجلات الصيانة'**
  String get m4Maintenance;

  /// No description provided for @m4NewIssue.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ جديد'**
  String get m4NewIssue;

  /// No description provided for @m4AddMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صيانة'**
  String get m4AddMaintenance;

  /// No description provided for @m4Problem.
  ///
  /// In ar, this message translates to:
  /// **'وش المشكلة؟'**
  String get m4Problem;

  /// No description provided for @m4WorkDone.
  ///
  /// In ar, this message translates to:
  /// **'وش تم؟'**
  String get m4WorkDone;

  /// No description provided for @m4IssueType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المشكلة (اختياري)'**
  String get m4IssueType;

  /// No description provided for @m4MaintenanceType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الصيانة (اختياري)'**
  String get m4MaintenanceType;

  /// No description provided for @m4Stopped.
  ///
  /// In ar, this message translates to:
  /// **'المشكلة أوقفت المعدة عن العمل'**
  String get m4Stopped;

  /// No description provided for @m4StoppedBadge.
  ///
  /// In ar, this message translates to:
  /// **'المعدة متوقفة'**
  String get m4StoppedBadge;

  /// No description provided for @m4Open.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get m4Open;

  /// No description provided for @m4InProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ العمل'**
  String get m4InProgress;

  /// No description provided for @m4Closed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get m4Closed;

  /// No description provided for @m4Start.
  ///
  /// In ar, this message translates to:
  /// **'بدء المعالجة'**
  String get m4Start;

  /// No description provided for @m4Close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق البلاغ'**
  String get m4Close;

  /// No description provided for @m4Reopen.
  ///
  /// In ar, this message translates to:
  /// **'إعادة فتح البلاغ'**
  String get m4Reopen;

  /// No description provided for @m4Resolution.
  ///
  /// In ar, this message translates to:
  /// **'وصف الحل'**
  String get m4Resolution;

  /// No description provided for @m4ResolutionRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ما تم لحل المشكلة'**
  String get m4ResolutionRequired;

  /// No description provided for @m4Mechanical.
  ///
  /// In ar, this message translates to:
  /// **'ميكانيكي'**
  String get m4Mechanical;

  /// No description provided for @m4Electrical.
  ///
  /// In ar, this message translates to:
  /// **'كهربائي'**
  String get m4Electrical;

  /// No description provided for @m4Tires.
  ///
  /// In ar, this message translates to:
  /// **'إطارات'**
  String get m4Tires;

  /// No description provided for @m4Accident.
  ///
  /// In ar, this message translates to:
  /// **'حادث أو ضرر'**
  String get m4Accident;

  /// No description provided for @m4Repair.
  ///
  /// In ar, this message translates to:
  /// **'إصلاح'**
  String get m4Repair;

  /// No description provided for @m4Periodic.
  ///
  /// In ar, this message translates to:
  /// **'خدمة دورية'**
  String get m4Periodic;

  /// No description provided for @m4Inspection.
  ///
  /// In ar, this message translates to:
  /// **'فحص'**
  String get m4Inspection;

  /// No description provided for @m4Unclassified.
  ///
  /// In ar, this message translates to:
  /// **'دون تصنيف'**
  String get m4Unclassified;

  /// No description provided for @m4Description.
  ///
  /// In ar, this message translates to:
  /// **'وصف العمل المنجز'**
  String get m4Description;

  /// No description provided for @m4Date.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الصيانة'**
  String get m4Date;

  /// No description provided for @m4Workshop.
  ///
  /// In ar, this message translates to:
  /// **'الورشة أو مقدم الخدمة (اختياري)'**
  String get m4Workshop;

  /// No description provided for @m4LinkedIssue.
  ///
  /// In ar, this message translates to:
  /// **'البلاغ المرتبط (اختياري)'**
  String get m4LinkedIssue;

  /// No description provided for @m4IssueHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الإغلاقات'**
  String get m4IssueHistory;

  /// No description provided for @m4RelatedMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'الصيانة المرتبطة'**
  String get m4RelatedMaintenance;

  /// No description provided for @m4NoIssues.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات لهذه المعدة'**
  String get m4NoIssues;

  /// No description provided for @m4NoMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات صيانة لهذه المعدة'**
  String get m4NoMaintenance;

  /// No description provided for @m4NoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get m4NoResults;

  /// No description provided for @m4IssueSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في البلاغات'**
  String get m4IssueSearch;

  /// No description provided for @m4MaintenanceSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الصيانة'**
  String get m4MaintenanceSearch;

  /// No description provided for @m4AllStatuses.
  ///
  /// In ar, this message translates to:
  /// **'كل الحالات'**
  String get m4AllStatuses;

  /// No description provided for @m4AllTypes.
  ///
  /// In ar, this message translates to:
  /// **'كل الأنواع'**
  String get m4AllTypes;

  /// No description provided for @m4OnlyStopped.
  ///
  /// In ar, this message translates to:
  /// **'المعدات المتوقفة فقط'**
  String get m4OnlyStopped;

  /// No description provided for @m4Cancelled.
  ///
  /// In ar, this message translates to:
  /// **'سجل ملغى'**
  String get m4Cancelled;

  /// No description provided for @m4ShowCancelled.
  ///
  /// In ar, this message translates to:
  /// **'عرض الملغى'**
  String get m4ShowCancelled;

  /// No description provided for @m4CancelMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء سجل الصيانة'**
  String get m4CancelMaintenance;

  /// No description provided for @m4CancelWarning.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء سجل الصيانة لن يلغي المصروفات المرتبطة.'**
  String get m4CancelWarning;

  /// No description provided for @m4CancellationReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get m4CancellationReason;

  /// No description provided for @m4Expenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات المرتبطة'**
  String get m4Expenses;

  /// No description provided for @m4AddExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get m4AddExpense;

  /// No description provided for @m4LinkExpense.
  ///
  /// In ar, this message translates to:
  /// **'ربط مصروف موجود'**
  String get m4LinkExpense;

  /// No description provided for @m4UnlinkExpense.
  ///
  /// In ar, this message translates to:
  /// **'فصل المصروف'**
  String get m4UnlinkExpense;

  /// No description provided for @m4ExpenseTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات النشطة'**
  String get m4ExpenseTotal;

  /// No description provided for @m4NetPaid.
  ///
  /// In ar, this message translates to:
  /// **'الصافي المدفوع'**
  String get m4NetPaid;

  /// No description provided for @m4Remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get m4Remaining;

  /// No description provided for @m4NoEligible.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصروفات مناسبة للربط'**
  String get m4NoEligible;

  /// No description provided for @m4NoAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات'**
  String get m4NoAttachments;

  /// No description provided for @m4CreateIssue.
  ///
  /// In ar, this message translates to:
  /// **'حفظ البلاغ'**
  String get m4CreateIssue;

  /// No description provided for @m4SaveMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الصيانة'**
  String get m4SaveMaintenance;

  /// No description provided for @m4IssueUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث البلاغ'**
  String get m4IssueUpdated;

  /// No description provided for @m4AttentionEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات أو مستندات تحتاج انتباهًا الآن'**
  String get m4AttentionEmpty;

  /// No description provided for @m4AttentionOpenIssue.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ مفتوح'**
  String get m4AttentionOpenIssue;

  /// No description provided for @m4ArchivedWarning.
  ///
  /// In ar, this message translates to:
  /// **'ستبقى البلاغات والصيانة محفوظة، لكن البلاغات المفتوحة ستختفي من الانتباه حتى استعادة المعدة.'**
  String get m4ArchivedWarning;

  /// No description provided for @m4SelectEquipment.
  ///
  /// In ar, this message translates to:
  /// **'اختر المعدة'**
  String get m4SelectEquipment;

  /// No description provided for @m4IssueDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل البلاغ'**
  String get m4IssueDetails;

  /// No description provided for @m4MaintenanceDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الصيانة'**
  String get m4MaintenanceDetails;

  /// No description provided for @m4EditIssue.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البلاغ'**
  String get m4EditIssue;

  /// No description provided for @m4EditMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الصيانة'**
  String get m4EditMaintenance;

  /// No description provided for @m4Required.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get m4Required;

  /// No description provided for @m4AllEquipment.
  ///
  /// In ar, this message translates to:
  /// **'كل المعدات'**
  String get m4AllEquipment;

  /// No description provided for @m4LinkedCount.
  ///
  /// In ar, this message translates to:
  /// **'مصروفات مرتبطة'**
  String get m4LinkedCount;

  /// No description provided for @m4ViewHistory.
  ///
  /// In ar, this message translates to:
  /// **'عرض السجل'**
  String get m4ViewHistory;

  /// No description provided for @m4RemoveAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إزالة المرفق'**
  String get m4RemoveAttachment;

  /// No description provided for @m4NoLinkedIssue.
  ///
  /// In ar, this message translates to:
  /// **'دون بلاغ مرتبط'**
  String get m4NoLinkedIssue;

  /// No description provided for @m4DateRange.
  ///
  /// In ar, this message translates to:
  /// **'الفترة الزمنية'**
  String get m4DateRange;

  /// No description provided for @m4ClearDateRange.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفترة'**
  String get m4ClearDateRange;

  /// No description provided for @m4NoIssuesGlobal.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات بعد'**
  String get m4NoIssuesGlobal;

  /// No description provided for @m4NoMaintenanceGlobal.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات صيانة بعد'**
  String get m4NoMaintenanceGlobal;

  /// No description provided for @m4SelectIssue.
  ///
  /// In ar, this message translates to:
  /// **'اختيار بلاغ'**
  String get m4SelectIssue;

  /// No description provided for @m4ClearIssue.
  ///
  /// In ar, this message translates to:
  /// **'إزالة ربط البلاغ'**
  String get m4ClearIssue;

  /// No description provided for @m5Owner.
  ///
  /// In ar, this message translates to:
  /// **'المالك'**
  String get m5Owner;

  /// No description provided for @m5Manager.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get m5Manager;

  /// No description provided for @m5Accountant.
  ///
  /// In ar, this message translates to:
  /// **'محاسب'**
  String get m5Accountant;

  /// No description provided for @m5Driver.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get m5Driver;

  /// No description provided for @m5Member.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get m5Member;

  /// No description provided for @m5Pending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get m5Pending;

  /// No description provided for @m5Accepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get m5Accepted;

  /// No description provided for @m5Cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get m5Cancelled;

  /// No description provided for @m5Expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهية'**
  String get m5Expired;

  /// No description provided for @m5Approved.
  ///
  /// In ar, this message translates to:
  /// **'معتمدة'**
  String get m5Approved;

  /// No description provided for @m5Rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get m5Rejected;

  /// No description provided for @m5EquipmentView.
  ///
  /// In ar, this message translates to:
  /// **'عرض المعدات'**
  String get m5EquipmentView;

  /// No description provided for @m5EquipmentManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المعدات'**
  String get m5EquipmentManage;

  /// No description provided for @m5FinanceView.
  ///
  /// In ar, this message translates to:
  /// **'عرض الماليات'**
  String get m5FinanceView;

  /// No description provided for @m5FinanceManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الماليات'**
  String get m5FinanceManage;

  /// No description provided for @m5FinanceReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الطلبات المالية'**
  String get m5FinanceReview;

  /// No description provided for @m5DocumentView.
  ///
  /// In ar, this message translates to:
  /// **'عرض المستندات'**
  String get m5DocumentView;

  /// No description provided for @m5DocumentManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستندات'**
  String get m5DocumentManage;

  /// No description provided for @m5IssueView.
  ///
  /// In ar, this message translates to:
  /// **'عرض البلاغات'**
  String get m5IssueView;

  /// No description provided for @m5IssueManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة البلاغات'**
  String get m5IssueManage;

  /// No description provided for @m5MaintenanceView.
  ///
  /// In ar, this message translates to:
  /// **'عرض الصيانة'**
  String get m5MaintenanceView;

  /// No description provided for @m5MaintenanceManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الصيانة'**
  String get m5MaintenanceManage;

  /// No description provided for @m5DriverAssignmentManage.
  ///
  /// In ar, this message translates to:
  /// **'تعيين السائقين'**
  String get m5DriverAssignmentManage;

  /// No description provided for @m5ReportView.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقارير'**
  String get m5ReportView;

  /// No description provided for @m5TeamManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفريق'**
  String get m5TeamManage;

  /// No description provided for @m5MyInvitations.
  ///
  /// In ar, this message translates to:
  /// **'دعواتي'**
  String get m5MyInvitations;

  /// No description provided for @m5NoInvitations.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دعوات معلقة'**
  String get m5NoInvitations;

  /// No description provided for @m5Expires.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي'**
  String get m5Expires;

  /// No description provided for @m5Accept.
  ///
  /// In ar, this message translates to:
  /// **'قبول الدعوة'**
  String get m5Accept;

  /// No description provided for @m5Decline.
  ///
  /// In ar, this message translates to:
  /// **'رفض الدعوة'**
  String get m5Decline;

  /// No description provided for @m5Team.
  ///
  /// In ar, this message translates to:
  /// **'الفريق'**
  String get m5Team;

  /// No description provided for @m5Members.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get m5Members;

  /// No description provided for @m5NoMembers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أعضاء بعد'**
  String get m5NoMembers;

  /// No description provided for @m5Invitations.
  ///
  /// In ar, this message translates to:
  /// **'الدعوات'**
  String get m5Invitations;

  /// No description provided for @m5InviteMember.
  ///
  /// In ar, this message translates to:
  /// **'دعوة عضو'**
  String get m5InviteMember;

  /// No description provided for @m5Resend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال'**
  String get m5Resend;

  /// No description provided for @m5CancelInvitation.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الدعوة؟'**
  String get m5CancelInvitation;

  /// No description provided for @m5ResendInvitation.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الدعوة؟'**
  String get m5ResendInvitation;

  /// No description provided for @m5EditMember.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العضو'**
  String get m5EditMember;

  /// No description provided for @m5Role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get m5Role;

  /// No description provided for @m5Scope.
  ///
  /// In ar, this message translates to:
  /// **'نطاق المعدات'**
  String get m5Scope;

  /// No description provided for @m5AllEquipment.
  ///
  /// In ar, this message translates to:
  /// **'كل المعدات'**
  String get m5AllEquipment;

  /// No description provided for @m5SelectedEquipment.
  ///
  /// In ar, this message translates to:
  /// **'معدات محددة'**
  String get m5SelectedEquipment;

  /// No description provided for @m5ChooseEquipment.
  ///
  /// In ar, this message translates to:
  /// **'اختر معدة واحدة على الأقل'**
  String get m5ChooseEquipment;

  /// No description provided for @m5FinancialMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع الإدخال المالي'**
  String get m5FinancialMode;

  /// No description provided for @m5ReviewMode.
  ///
  /// In ar, this message translates to:
  /// **'يرسل للمراجعة'**
  String get m5ReviewMode;

  /// No description provided for @m5DirectMode.
  ///
  /// In ar, this message translates to:
  /// **'يسجل مباشرة'**
  String get m5DirectMode;

  /// No description provided for @m5Capabilities.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get m5Capabilities;

  /// No description provided for @m5CapabilitiesHint.
  ///
  /// In ar, this message translates to:
  /// **'حدّد ما يمكن لهذا العضو فعله.'**
  String get m5CapabilitiesHint;

  /// No description provided for @m5NamePhoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم ورقم الجوال'**
  String get m5NamePhoneRequired;

  /// No description provided for @m5ConfirmPermissions.
  ///
  /// In ar, this message translates to:
  /// **'حفظ تغييرات الدور أو النطاق؟'**
  String get m5ConfirmPermissions;

  /// No description provided for @m5SendInvitation.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الدعوة'**
  String get m5SendInvitation;

  /// No description provided for @m5MemberDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العضو'**
  String get m5MemberDetails;

  /// No description provided for @m5DriverAssignment.
  ///
  /// In ar, this message translates to:
  /// **'تعيين السائق'**
  String get m5DriverAssignment;

  /// No description provided for @m5RevokeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف وصول هذا العضو؟'**
  String get m5RevokeConfirm;

  /// No description provided for @m5RevokeAccess.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف الوصول'**
  String get m5RevokeAccess;

  /// No description provided for @m5CurrentAssignment.
  ///
  /// In ar, this message translates to:
  /// **'التعيين الحالي'**
  String get m5CurrentAssignment;

  /// No description provided for @m5NoAssignment.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تعيين حالي'**
  String get m5NoAssignment;

  /// No description provided for @m5ReplaceAssignmentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تغيير المعدة المعينة لهذا السائق؟'**
  String get m5ReplaceAssignmentConfirm;

  /// No description provided for @m5Assign.
  ///
  /// In ar, this message translates to:
  /// **'تعيين'**
  String get m5Assign;

  /// No description provided for @m5Unassign.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء التعيين'**
  String get m5Unassign;

  /// No description provided for @m5UnassignConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء تعيين هذا السائق؟'**
  String get m5UnassignConfirm;

  /// No description provided for @m5AssignmentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل التعيينات'**
  String get m5AssignmentHistory;

  /// No description provided for @m5NoHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تعيينات سابقة'**
  String get m5NoHistory;

  /// No description provided for @m5DriverHome.
  ///
  /// In ar, this message translates to:
  /// **'عملك اليوم'**
  String get m5DriverHome;

  /// No description provided for @m5NoAssignmentDriver.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدة معيّنة لك حاليًا.'**
  String get m5NoAssignmentDriver;

  /// No description provided for @m5ReportIssue.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن عطل'**
  String get m5ReportIssue;

  /// No description provided for @m5SubmitExpense.
  ///
  /// In ar, this message translates to:
  /// **'إرسال مصروف'**
  String get m5SubmitExpense;

  /// No description provided for @m5MyIssues.
  ///
  /// In ar, this message translates to:
  /// **'بلاغاتي'**
  String get m5MyIssues;

  /// No description provided for @m5NoIssues.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات لهذه المعدة'**
  String get m5NoIssues;

  /// No description provided for @m5MySubmissions.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي المالية'**
  String get m5MySubmissions;

  /// No description provided for @m5NoSubmissions.
  ///
  /// In ar, this message translates to:
  /// **'لم ترسل طلبات مالية بعد'**
  String get m5NoSubmissions;

  /// No description provided for @m5ReceiptOnly.
  ///
  /// In ar, this message translates to:
  /// **'إيصال دون مبلغ'**
  String get m5ReceiptOnly;

  /// No description provided for @m5SubmissionHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف المبلغ أو الملاحظة أو الإيصال؛ يراجعه المسؤول قبل تسجيل المصروف.'**
  String get m5SubmissionHint;

  /// No description provided for @m5TransactionDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ العملية'**
  String get m5TransactionDate;

  /// No description provided for @m5Note.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get m5Note;

  /// No description provided for @m5AddReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إيصال'**
  String get m5AddReceipt;

  /// No description provided for @m5SubmissionNeedsContent.
  ///
  /// In ar, this message translates to:
  /// **'أضف مبلغًا أو ملاحظة أو إيصالًا'**
  String get m5SubmissionNeedsContent;

  /// No description provided for @m5SendForReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمراجعة'**
  String get m5SendForReview;

  /// No description provided for @m5ReviewQueue.
  ///
  /// In ar, this message translates to:
  /// **'طلبات المراجعة'**
  String get m5ReviewQueue;

  /// No description provided for @m5ReviewQueueEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بانتظار المراجعة'**
  String get m5ReviewQueueEmpty;

  /// No description provided for @m5SubmissionDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get m5SubmissionDetails;

  /// No description provided for @m5Status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get m5Status;

  /// No description provided for @m5SubmittedBy.
  ///
  /// In ar, this message translates to:
  /// **'أرسله'**
  String get m5SubmittedBy;

  /// No description provided for @m5RejectionReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get m5RejectionReason;

  /// No description provided for @m5ApprovedEntryCreated.
  ///
  /// In ar, this message translates to:
  /// **'سُجل المصروف بعد الاعتماد'**
  String get m5ApprovedEntryCreated;

  /// No description provided for @m5Approve.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد'**
  String get m5Approve;

  /// No description provided for @m5Reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get m5Reject;

  /// No description provided for @m5RejectSubmission.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get m5RejectSubmission;

  /// No description provided for @m5Resubmit.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get m5Resubmit;

  /// No description provided for @m5ReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الرفض'**
  String get m5ReasonRequired;

  /// No description provided for @m5ApproveExpense.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد المصروف'**
  String get m5ApproveExpense;

  /// No description provided for @m5ApprovalHint.
  ///
  /// In ar, this message translates to:
  /// **'راجع بيانات المصروف قبل اعتماده. سيظهر في السجل مرة واحدة.'**
  String get m5ApprovalHint;

  /// No description provided for @m5Category.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get m5Category;

  /// No description provided for @m5PaymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get m5PaymentStatus;

  /// No description provided for @m5PaidOn.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الدفع'**
  String get m5PaidOn;

  /// No description provided for @m5DueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get m5DueDate;

  /// No description provided for @m5ChooseDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخًا'**
  String get m5ChooseDate;

  /// No description provided for @m5PartyDueRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الطرف وتاريخ الاستحقاق'**
  String get m5PartyDueRequired;

  /// No description provided for @m5PartialLessThanTotal.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع جزئيًا يجب أن يكون أقل من الإجمالي'**
  String get m5PartialLessThanTotal;

  /// No description provided for @m5ApproveConfirm.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد هذا المصروف وتسجيله؟'**
  String get m5ApproveConfirm;

  /// No description provided for @m5SwitchWorkspace.
  ///
  /// In ar, this message translates to:
  /// **'تبديل المساحة'**
  String get m5SwitchWorkspace;

  /// No description provided for @m5NotificationDriverAssigned.
  ///
  /// In ar, this message translates to:
  /// **'عُيّنت لك معدة'**
  String get m5NotificationDriverAssigned;

  /// No description provided for @m5NotificationDriverIssue.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ جديد من السائق'**
  String get m5NotificationDriverIssue;

  /// No description provided for @m5NotificationSubmissionPending.
  ///
  /// In ar, this message translates to:
  /// **'طلب مالي ينتظر مراجعتك'**
  String get m5NotificationSubmissionPending;

  /// No description provided for @m5NotificationSubmissionApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتُمد طلبك المالي'**
  String get m5NotificationSubmissionApproved;

  /// No description provided for @m5NotificationSubmissionRejected.
  ///
  /// In ar, this message translates to:
  /// **'رُفض طلبك المالي'**
  String get m5NotificationSubmissionRejected;

  /// No description provided for @m5AttentionReview.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مالية تحتاج مراجعة'**
  String get m5AttentionReview;

  /// No description provided for @m5PendingReviewsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلبات مالية بانتظار المراجعة'**
  String m5PendingReviewsCount(String count);

  /// No description provided for @m5RoleChangeResetsPermissions.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الدور سيعيد الصلاحيات إلى إعدادات الدور الجديد ويلغي تخصيصاتها السابقة. هل تريد المتابعة؟'**
  String get m5RoleChangeResetsPermissions;

  /// No description provided for @m5DirectExpenseHint.
  ///
  /// In ar, this message translates to:
  /// **'أكمل بيانات المصروف وسجله مباشرة.'**
  String get m5DirectExpenseHint;

  /// No description provided for @m5DirectExpenseConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل هذا المصروف؟'**
  String get m5DirectExpenseConfirm;

  /// No description provided for @m5InvitationPending.
  ///
  /// In ar, this message translates to:
  /// **'توجد دعوة معلقة لهذا الرقم'**
  String get m5InvitationPending;

  /// No description provided for @m5InvitationClosed.
  ///
  /// In ar, this message translates to:
  /// **'أُغلقت الدعوة أو انتهت؛ حدّث القائمة'**
  String get m5InvitationClosed;

  /// No description provided for @m5AlreadyMember.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشخص عضو بالفعل'**
  String get m5AlreadyMember;

  /// No description provided for @m5SubmissionReviewed.
  ///
  /// In ar, this message translates to:
  /// **'تمت مراجعة الطلب؛ حدّث القائمة'**
  String get m5SubmissionReviewed;

  /// No description provided for @m5NoDriverAssignment.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدة معيّنة لك حاليًا'**
  String get m5NoDriverAssignment;

  /// No description provided for @m5Issues.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات'**
  String get m5Issues;

  /// No description provided for @m5DriverInviteHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكن تعيين معدة للسائق بعد قبوله الدعوة.'**
  String get m5DriverInviteHint;

  /// No description provided for @m5AllScopeHint.
  ///
  /// In ar, this message translates to:
  /// **'يشمل المعدات الحالية وأي معدات تضاف لاحقًا.'**
  String get m5AllScopeHint;

  /// No description provided for @m5AssignMayReplace.
  ///
  /// In ar, this message translates to:
  /// **'قد يحل هذا التعيين محل سائق المعدة الحالي. متابعة؟'**
  String get m5AssignMayReplace;

  /// No description provided for @m5ChooseDriver.
  ///
  /// In ar, this message translates to:
  /// **'اختر السائق'**
  String get m5ChooseDriver;

  /// No description provided for @m5NoEligibleDrivers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائقون متاحون لهذه المعدة'**
  String get m5NoEligibleDrivers;

  /// No description provided for @m5DriverCurrentlyOnEquipment.
  ///
  /// In ar, this message translates to:
  /// **'السائق معيّن حاليًا على {equipmentName}'**
  String m5DriverCurrentlyOnEquipment(String equipmentName);

  /// No description provided for @m5ConfirmAssignDriver.
  ///
  /// In ar, this message translates to:
  /// **'تعيين {driverName} على {equipmentName}؟'**
  String m5ConfirmAssignDriver(String driverName, String equipmentName);

  /// No description provided for @m5ConfirmReplaceDriver.
  ///
  /// In ar, this message translates to:
  /// **'استبدال {currentDriver} بـ {newDriver} على {equipmentName}؟'**
  String m5ConfirmReplaceDriver(
    String currentDriver,
    String newDriver,
    String equipmentName,
  );

  /// No description provided for @m5ConfirmMoveDriver.
  ///
  /// In ar, this message translates to:
  /// **'سينتهي تعيين {driverName} الحالي على {sourceEquipment}.'**
  String m5ConfirmMoveDriver(String driverName, String sourceEquipment);

  /// No description provided for @m6Organizations.
  ///
  /// In ar, this message translates to:
  /// **'المؤسسات'**
  String get m6Organizations;

  /// No description provided for @m6OrganizationsOptional.
  ///
  /// In ar, this message translates to:
  /// **'المؤسسات اختيارية. يمكنك استخدام التطبيق كاملًا دون إنشاء مؤسسة.'**
  String get m6OrganizationsOptional;

  /// No description provided for @m6SearchOrganizations.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مؤسسة'**
  String get m6SearchOrganizations;

  /// No description provided for @m6NoOrganizations.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مؤسسات بعد. يمكنك البدء بالمعدات مباشرة.'**
  String get m6NoOrganizations;

  /// No description provided for @m6AddOrganization.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مؤسسة'**
  String get m6AddOrganization;

  /// No description provided for @m6OrganizationName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المؤسسة'**
  String get m6OrganizationName;

  /// No description provided for @m6IdentifierOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم التعريف (اختياري)'**
  String get m6IdentifierOptional;

  /// No description provided for @m6NameRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم للمتابعة'**
  String get m6NameRequired;

  /// No description provided for @m6ProjectsContracts.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع والعقود'**
  String get m6ProjectsContracts;

  /// No description provided for @m6ManageEquipment.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المعدات المرتبطة'**
  String get m6ManageEquipment;

  /// No description provided for @m6AddProject.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مشروع أو عقد'**
  String get m6AddProject;

  /// No description provided for @m6ArchiveOrganizationConfirm.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المؤسسة تحفظ تاريخها. يجب أولًا إزالة تعيين المعدات وأرشفة المشاريع والعقود غير المؤرشفة.'**
  String get m6ArchiveOrganizationConfirm;

  /// No description provided for @m6NoOrganization.
  ///
  /// In ar, this message translates to:
  /// **'بدون مؤسسة'**
  String get m6NoOrganization;

  /// No description provided for @m6AssignEquipment.
  ///
  /// In ar, this message translates to:
  /// **'تعيين مؤسسة للمعدة'**
  String get m6AssignEquipment;

  /// No description provided for @m6ConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإجراء'**
  String get m6ConfirmAction;

  /// No description provided for @m6ProjectsOptional.
  ///
  /// In ar, this message translates to:
  /// **'اربط المشاريع والعقود عند الحاجة؛ يمكنك إدارة المعدات والمال دونها.'**
  String get m6ProjectsOptional;

  /// No description provided for @m6SearchProjects.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو العميل أو رقم العقد'**
  String get m6SearchProjects;

  /// No description provided for @m6All.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get m6All;

  /// No description provided for @m6Completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get m6Completed;

  /// No description provided for @m6NoProjects.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاريع أو عقود تطابق العرض'**
  String get m6NoProjects;

  /// No description provided for @m6Project.
  ///
  /// In ar, this message translates to:
  /// **'مشروع'**
  String get m6Project;

  /// No description provided for @m6Contract.
  ///
  /// In ar, this message translates to:
  /// **'عقد'**
  String get m6Contract;

  /// No description provided for @m6RecordKind.
  ///
  /// In ar, this message translates to:
  /// **'نوع السجل'**
  String get m6RecordKind;

  /// No description provided for @m6OrganizationOptional.
  ///
  /// In ar, this message translates to:
  /// **'المؤسسة (اختياري)'**
  String get m6OrganizationOptional;

  /// No description provided for @m6ClientOptional.
  ///
  /// In ar, this message translates to:
  /// **'العميل (اختياري)'**
  String get m6ClientOptional;

  /// No description provided for @m6ContractNumberOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم العقد (اختياري)'**
  String get m6ContractNumberOptional;

  /// No description provided for @m6StartDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية (اختياري)'**
  String get m6StartDateOptional;

  /// No description provided for @m6EndDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النهاية (اختياري)'**
  String get m6EndDateOptional;

  /// No description provided for @m6DateOrder.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يسبق تاريخ البداية تاريخ النهاية أو يساويه'**
  String get m6DateOrder;

  /// No description provided for @m6CompleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيكتمل المشروع وتنتهي روابط المعدات النشطة. تبقى العمليات المالية والمرفقات والتاريخ محفوظة.'**
  String get m6CompleteConfirm;

  /// No description provided for @m6ArchiveProjectConfirm.
  ///
  /// In ar, this message translates to:
  /// **'الأرشفة تخفي السجل من القوائم العادية وتحفظ المال والمرفقات والتاريخ.'**
  String get m6ArchiveProjectConfirm;

  /// No description provided for @m6FinancialSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص مالي مشتق'**
  String get m6FinancialSummary;

  /// No description provided for @m6RecordedIncome.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات المسجلة'**
  String get m6RecordedIncome;

  /// No description provided for @m6RecordedExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات المسجلة'**
  String get m6RecordedExpenses;

  /// No description provided for @m6RecordedDifference.
  ///
  /// In ar, this message translates to:
  /// **'الفرق بين الإيرادات والمصروفات المسجلة'**
  String get m6RecordedDifference;

  /// No description provided for @m6Collected.
  ///
  /// In ar, this message translates to:
  /// **'المحصّل'**
  String get m6Collected;

  /// No description provided for @m6Paid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get m6Paid;

  /// No description provided for @m6ReceivablesRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي للتحصيل'**
  String get m6ReceivablesRemaining;

  /// No description provided for @m6PayablesRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي للدفع'**
  String get m6PayablesRemaining;

  /// No description provided for @m6LinkEquipmentFirst.
  ///
  /// In ar, this message translates to:
  /// **'اربط معدة بالمشروع أولًا لإضافة إيراد'**
  String get m6LinkEquipmentFirst;

  /// No description provided for @m6Complete.
  ///
  /// In ar, this message translates to:
  /// **'إكمال المشروع'**
  String get m6Complete;

  /// No description provided for @m6Reopen.
  ///
  /// In ar, this message translates to:
  /// **'إعادة فتح المشروع'**
  String get m6Reopen;

  /// No description provided for @m6WorkspaceProjectEquipment.
  ///
  /// In ar, this message translates to:
  /// **'يمكن ربط معدات من مؤسسات مختلفة أو بدون مؤسسة.'**
  String get m6WorkspaceProjectEquipment;

  /// No description provided for @m6OrganizationProjectEquipment.
  ///
  /// In ar, this message translates to:
  /// **'تظهر المعدات التابعة حاليًا لمؤسسة المشروع فقط.'**
  String get m6OrganizationProjectEquipment;

  /// No description provided for @m6ProjectClassification.
  ///
  /// In ar, this message translates to:
  /// **'المشروع أو العقد (اختياري)'**
  String get m6ProjectClassification;

  /// No description provided for @m6AdditionalDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية'**
  String get m6AdditionalDetails;

  /// No description provided for @m6ScopeOrganizations.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسات محددة'**
  String get m6ScopeOrganizations;

  /// No description provided for @m6ScopeOrganizationsHint.
  ///
  /// In ar, this message translates to:
  /// **'يشمل معدات هذه المؤسسات الآن وكل معدة تنضم إليها مستقبلًا. لا يشمل المعدات غير التابعة لمؤسسة.'**
  String get m6ScopeOrganizationsHint;

  /// No description provided for @m6ChooseOrganizations.
  ///
  /// In ar, this message translates to:
  /// **'اختر مؤسسة واحدة على الأقل'**
  String get m6ChooseOrganizations;

  /// No description provided for @m6OrganizationProjectBlocked.
  ///
  /// In ar, this message translates to:
  /// **'افصل المعدة من المشروع النشط قبل نقلها إلى مؤسسة أخرى'**
  String get m6OrganizationProjectBlocked;

  /// No description provided for @m6OrganizationInUse.
  ///
  /// In ar, this message translates to:
  /// **'تعذر أرشفة المؤسسة لوجود معدات معيّنة أو مشاريع وعقود غير مؤرشفة'**
  String get m6OrganizationInUse;

  /// No description provided for @m6ProjectInactive.
  ///
  /// In ar, this message translates to:
  /// **'المشروع غير نشط لهذا الإجراء'**
  String get m6ProjectInactive;

  /// No description provided for @m6ProjectMismatch.
  ///
  /// In ar, this message translates to:
  /// **'المعدة لا تتبع مؤسسة المشروع الحالية'**
  String get m6ProjectMismatch;

  /// No description provided for @m6ActiveProjects.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع والعقود النشطة'**
  String get m6ActiveProjects;

  /// No description provided for @m6NoActiveProjects.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد روابط مشاريع نشطة'**
  String get m6NoActiveProjects;

  /// No description provided for @m6RetrySameFile.
  ///
  /// In ar, this message translates to:
  /// **'اختر الملف نفسه لإعادة الرفع'**
  String get m6RetrySameFile;

  /// No description provided for @m6MoveEquipmentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُنهي هذا الإجراء تعيين المعدة الحالي وينقلها أو يتركها دون مؤسسة. سيبقى تاريخ التعيين محفوظًا.'**
  String get m6MoveEquipmentConfirm;

  /// No description provided for @m7Reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get m7Reports;

  /// No description provided for @m7More.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get m7More;

  /// No description provided for @m7Recorded.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المسجلة'**
  String get m7Recorded;

  /// No description provided for @m7Movements.
  ///
  /// In ar, this message translates to:
  /// **'الدفع والاستلام'**
  String get m7Movements;

  /// No description provided for @m7Outstanding.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي لك وعليك'**
  String get m7Outstanding;

  /// No description provided for @m7RecordedExpensesMonth.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات المسجلة هذا الشهر'**
  String get m7RecordedExpensesMonth;

  /// No description provided for @m7RecordedIncomeMonth.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات المسجلة هذا الشهر'**
  String get m7RecordedIncomeMonth;

  /// No description provided for @m7EntryDateBasis.
  ///
  /// In ar, this message translates to:
  /// **'بحسب تاريخ العملية، وليس تاريخ الدفع أو الاستلام.'**
  String get m7EntryDateBasis;

  /// No description provided for @m7MovementDateBasis.
  ///
  /// In ar, this message translates to:
  /// **'بحسب تاريخ كل دفعة أو استرداد.'**
  String get m7MovementDateBasis;

  /// No description provided for @m7CurrentBasis.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي الحالي من جميع الفترات.'**
  String get m7CurrentBasis;

  /// No description provided for @m7RecordedDifference.
  ///
  /// In ar, this message translates to:
  /// **'الفرق بين الإيرادات والمصروفات المسجلة'**
  String get m7RecordedDifference;

  /// No description provided for @m7Collected.
  ///
  /// In ar, this message translates to:
  /// **'المستلم'**
  String get m7Collected;

  /// No description provided for @m7IncomeRefunds.
  ///
  /// In ar, this message translates to:
  /// **'المعاد للطرف الآخر'**
  String get m7IncomeRefunds;

  /// No description provided for @m7NetCollected.
  ///
  /// In ar, this message translates to:
  /// **'صافي المستلم'**
  String get m7NetCollected;

  /// No description provided for @m7Paid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get m7Paid;

  /// No description provided for @m7ExpenseRefunds.
  ///
  /// In ar, this message translates to:
  /// **'المسترد من المصروفات'**
  String get m7ExpenseRefunds;

  /// No description provided for @m7NetPaid.
  ///
  /// In ar, this message translates to:
  /// **'صافي المدفوع'**
  String get m7NetPaid;

  /// No description provided for @m7Receivable.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي لك'**
  String get m7Receivable;

  /// No description provided for @m7Payable.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي عليك'**
  String get m7Payable;

  /// No description provided for @m7RecentEntries.
  ///
  /// In ar, this message translates to:
  /// **'أحدث العمليات المالية'**
  String get m7RecentEntries;

  /// No description provided for @m7ActiveEquipment.
  ///
  /// In ar, this message translates to:
  /// **'المعدات النشطة'**
  String get m7ActiveEquipment;

  /// No description provided for @m7NoPeriodRecords.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات في هذه الفترة.'**
  String get m7NoPeriodRecords;

  /// No description provided for @m7NoCurrentOutstanding.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مبالغ متبقية حاليًا.'**
  String get m7NoCurrentOutstanding;

  /// No description provided for @m7NoMatches.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لهذه الفلاتر.'**
  String get m7NoMatches;

  /// No description provided for @m7ClearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get m7ClearFilters;

  /// No description provided for @m7LoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الملخص.'**
  String get m7LoadFailed;

  /// No description provided for @m7WithinScope.
  ///
  /// In ar, this message translates to:
  /// **'الأرقام المعروضة ضمن نطاق صلاحياتك.'**
  String get m7WithinScope;

  /// No description provided for @m7CurrentClassification.
  ///
  /// In ar, this message translates to:
  /// **'تعرض السجلات بحسب تصنيفها الحالي.'**
  String get m7CurrentClassification;

  /// No description provided for @m7NoDueDate.
  ///
  /// In ar, this message translates to:
  /// **'موعد السداد غير محدد'**
  String get m7NoDueDate;

  /// No description provided for @m7GeneralExpenses.
  ///
  /// In ar, this message translates to:
  /// **'مصروفات عامة'**
  String get m7GeneralExpenses;

  /// No description provided for @m7EquipmentShare.
  ///
  /// In ar, this message translates to:
  /// **'حصة المعدة'**
  String get m7EquipmentShare;

  /// No description provided for @m7OriginalTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العملية الأصلية'**
  String get m7OriginalTotal;

  /// No description provided for @m7ChoosePeriod.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفترة'**
  String get m7ChoosePeriod;

  /// No description provided for @m7ChooseMonth.
  ///
  /// In ar, this message translates to:
  /// **'اختر الشهر'**
  String get m7ChooseMonth;

  /// No description provided for @m7FilterEquipment.
  ///
  /// In ar, this message translates to:
  /// **'فلترة بالمعدة'**
  String get m7FilterEquipment;

  /// No description provided for @m7FilterProject.
  ///
  /// In ar, this message translates to:
  /// **'فلترة بالمشروع'**
  String get m7FilterProject;

  /// No description provided for @m7AllEquipment.
  ///
  /// In ar, this message translates to:
  /// **'كل المعدات'**
  String get m7AllEquipment;

  /// No description provided for @m7AllProjects.
  ///
  /// In ar, this message translates to:
  /// **'كل المشاريع'**
  String get m7AllProjects;

  /// No description provided for @m7FromDate.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get m7FromDate;

  /// No description provided for @m7ToDate.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get m7ToDate;

  /// No description provided for @m7Movement.
  ///
  /// In ar, this message translates to:
  /// **'حركة مالية'**
  String get m7Movement;

  /// No description provided for @m7Refund.
  ///
  /// In ar, this message translates to:
  /// **'استرداد'**
  String get m7Refund;

  /// No description provided for @m7Settlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية'**
  String get m7Settlement;

  /// No description provided for @m7NoReportsPermission.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية عرض التقارير.'**
  String get m7NoReportsPermission;

  /// No description provided for @m7OriginalMovement.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الحركة الأصلية'**
  String get m7OriginalMovement;

  /// No description provided for @m7AccountInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحساب'**
  String get m7AccountInfo;

  /// No description provided for @m7NoRecentEntries.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات مالية حديثة بعد.'**
  String get m7NoRecentEntries;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
