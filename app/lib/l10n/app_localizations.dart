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
  /// **'الأرقام التجريبية: 0500000001 أو 0500000002'**
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
