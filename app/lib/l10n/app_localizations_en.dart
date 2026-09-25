// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Equipment Manager';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get equipment => 'Equipment';

  @override
  String get ledger => 'Records';

  @override
  String get notifications => 'Notifications';

  @override
  String get refresh => 'Refresh';

  @override
  String get logout => 'Sign out';

  @override
  String get retry => 'Try again';

  @override
  String get devNotice => 'Local development environment • No SMS is sent';

  @override
  String get restoreFailed => 'Could not restore your session. Try again.';

  @override
  String get addFirstEquipment => 'Add your first equipment';

  @override
  String get equipmentSubtitle => 'Keep each equipment record in one place';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get documents => 'Documents';

  @override
  String get attention => 'Attention';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get draft => 'Draft';

  @override
  String get settlement => 'Settlement';

  @override
  String get refund => 'Refund';

  @override
  String get archived => 'Archived';

  @override
  String get active => 'Active';

  @override
  String get docPreviousVersion => 'Previous version';

  @override
  String get docMissingExpiry => 'No expiry date';

  @override
  String get docExpired => 'Expired';

  @override
  String get docExpiresToday => 'Expires today';

  @override
  String get docExpiringSoon => 'Expiring soon';

  @override
  String get docRegistration => 'Registration';

  @override
  String get docInsurance => 'Insurance';

  @override
  String get docInspection => 'Periodic inspection';

  @override
  String get docPermit => 'License / permit';

  @override
  String get other => 'Other';

  @override
  String get docOther => 'Other document';

  @override
  String get document => 'Document';

  @override
  String get docLoadFailed => 'Could not load the data. Try again.';

  @override
  String get closeAttachment => 'Close attachment';

  @override
  String get fileTypes => 'Images and PDF files';

  @override
  String get fileTooLarge => 'Choose a file smaller than 10 MB';

  @override
  String get unsupportedFile =>
      'Choose PNG, JPEG, or PDF. Convert HEIC to JPEG before uploading.';

  @override
  String get networkError =>
      'Could not connect to the server. Check that it is running, then try again.';

  @override
  String get requestFailed => 'Could not complete the request. Try again.';

  @override
  String get sessionRequired => 'Sign in to continue';

  @override
  String get financialTotalLocked =>
      'The total is locked after the first payment or refund';

  @override
  String get documentAlreadyRenewed => 'This document has already been renewed';

  @override
  String get accessDenied => 'You do not have access to this information';

  @override
  String get invalidInput => 'Check the information you entered and try again';

  @override
  String get invalidOtp =>
      'The code is incorrect or expired. Request a new code';

  @override
  String get sessionExpired => 'Your session has expired. Sign in again';

  @override
  String get otpThrottled => 'Wait a moment before requesting another code';

  @override
  String get recordNotFound => 'The requested record could not be found';

  @override
  String get documentVersionChanged =>
      'This document changed. Refresh before editing';

  @override
  String get documentLocked =>
      'This document cannot be edited in its current state';

  @override
  String get fileUnavailable => 'The file is unavailable. Try again later';

  @override
  String get attachmentLimit => 'You have reached the attachment limit';

  @override
  String get idempotencyConflict =>
      'The request changed. Check the records before saving again';

  @override
  String get immutableAttachment =>
      'This attachment is saved. Add a new one to replace it';

  @override
  String get unsupportedLocale => 'Choose a supported language';

  @override
  String get notificationDocumentExpiryTitle => 'Document expiring soon';

  @override
  String get notificationDocumentExpiryBody => 'Review the equipment document';

  @override
  String get notificationWeeklyTitle => 'Documents need your attention';

  @override
  String get notificationWeeklyBody => 'Review expired documents';

  @override
  String unreadNotifications(int count) {
    return 'Notifications • $count unread';
  }

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryMaintenance => 'Maintenance';

  @override
  String get paidFull => 'Paid in full';

  @override
  String get paidPartial => 'Partially paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get receivedFull => 'Received in full';

  @override
  String get receivedPartial => 'Partially received';

  @override
  String get unreceived => 'Not received';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get generalExpense => 'General expense';

  @override
  String get addEquipment => 'Add equipment';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addIncome => 'Add income';

  @override
  String get addDocument => 'Add document';

  @override
  String get saveDocument => 'Save document';

  @override
  String get attachments => 'Attachments';

  @override
  String get archive => 'Archive';

  @override
  String get restoreDocument => 'Restore document';

  @override
  String get currentDocuments => 'Current documents';

  @override
  String get previousVersions => 'Previous versions';

  @override
  String get noDocuments => 'No documents for this equipment yet';

  @override
  String get noAttachments => 'No attachments yet';

  @override
  String get searchEquipment => 'Search by name or reference';

  @override
  String get searchLedger => 'Search records';

  @override
  String get noEquipmentMatches => 'No equipment matches your search';

  @override
  String get noEntries => 'No records yet';

  @override
  String get signInCode => 'Verification code';

  @override
  String get phoneNumber => 'Mobile number';

  @override
  String get name => 'Name';

  @override
  String get model => 'Model';

  @override
  String get documentType => 'Document type';

  @override
  String get newExpiryDate => 'New expiry date';

  @override
  String get renewDocument => 'Renew document';

  @override
  String get viewAll => 'View all';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get back => 'Back';

  @override
  String get general => 'General';

  @override
  String get ui2021OrFh16 => '2021 or FH16';

  @override
  String get uiEnterTheVerificationCode => 'Enter the verification code';

  @override
  String get uiArchiveDocument => 'Archive document';

  @override
  String get uiArchiveDocument005 => 'Archive document?';

  @override
  String get uiArchiveEquipment => 'Archive equipment';

  @override
  String get uiArchiveEquipment007 => 'Archive equipment?';

  @override
  String get uiRemoveTheDueDateOnceFullyPaid =>
      'Remove the due date once fully paid';

  @override
  String get uiAddExpiryDate => 'Add expiry date';

  @override
  String get uiMultipleEquipment => 'Multiple equipment';

  @override
  String get uiReturnedToTheCustomerOrOtherParty =>
      'Returned to the customer or other party';

  @override
  String get uiTotalIncome => 'Total income';

  @override
  String get uiTotalExpenses => 'Total expenses';

  @override
  String get uiRemoveEquipment => 'Remove equipment';

  @override
  String get uiRemoveDueDate => 'Remove due date';

  @override
  String get uiAddReceipt => 'Add receipt';

  @override
  String get uiAddPayment => 'Add payment';

  @override
  String get uiAddImageOrPdf => 'Add image or PDF';

  @override
  String get uiAddImageOrPdfOptional => 'Add image or PDF (optional)';

  @override
  String get uiAddAttachment => 'Add attachment';

  @override
  String get uiAddSeparateDocument => 'Add separate document';

  @override
  String get uiAddGeneralExpense => 'Add general expense';

  @override
  String get uiUploadAttachmentAgain => 'Upload attachment again';

  @override
  String get uiRetryTheSameSave => 'Retry the same save';

  @override
  String get uiRetryUploadingAttachments => 'Retry uploading attachments';

  @override
  String get uiRetryFileUpload => 'Retry file upload';

  @override
  String get uiClose => 'Close';

  @override
  String get uiCancelEntry => 'Cancel entry';

  @override
  String get uiToDate => 'To date';

  @override
  String get uiSearchByEquipmentNameOrReference =>
      'Search by equipment name or reference';

  @override
  String get uiStartByAddingYourEquipment => 'Start by adding your equipment';

  @override
  String get uiStartWithEquipmentNameAndModel =>
      'Start with equipment name and model';

  @override
  String get uiStartWithYourMobileNumber => 'Start with your mobile number';

  @override
  String get uiSelectTheEquipmentThisExpenseBelongsTo =>
      'Select the equipment this expense belongs to';

  @override
  String get uiSelectEquipment => 'Select equipment';

  @override
  String get uiSelectIssueDate => 'Select issue date';

  @override
  String get uiSelectExpiryDate => 'Select expiry date';

  @override
  String get uiSelectEquipment051 => 'Select equipment';

  @override
  String get uiChooseAnotherFile => 'Choose another file';

  @override
  String get uiText054 => 'اردو';

  @override
  String get uiDiscardDraft => 'Discard draft';

  @override
  String get uiDiscardDraft056 => 'Discard draft?';

  @override
  String get uiExcludeGeneralExpenses => 'Exclude general expenses';

  @override
  String get uiRestoreEquipment => 'Restore equipment';

  @override
  String get uiRestoreTheEquipmentBeforeRestoringThisDocument =>
      'Restore the equipment before restoring this document.';

  @override
  String get uiCompleteAsIncome => 'Complete as income';

  @override
  String get uiCompleteAsExpense => 'Complete as expense';

  @override
  String get uiCompleteTheSavedInvoiceDetailsItsAttachments =>
      'Complete the saved invoice details; its attachments will stay with it.';

  @override
  String get uiPartiallyReceived => 'Partially received';

  @override
  String get uiReceivedInFull => 'Received in full';

  @override
  String get uiReceived => 'Received';

  @override
  String get uiNameOfThePartyWhoWillPay => 'Name of the party who will pay';

  @override
  String get uiNameOfThePartyOwed => 'Name of the party owed';

  @override
  String get uiCustomerName => 'Customer name';

  @override
  String get uiDocumentName => 'Document name';

  @override
  String get uiEquipmentName => 'Equipment name';

  @override
  String get uiEquipmentNameReferencePartyOrNote =>
      'Equipment name, reference, party, or note';

  @override
  String get uiSupplierOrPartyName => 'Supplier or party name';

  @override
  String get uiEnterPartyName => 'Enter party name';

  @override
  String get uiEnterPartyNameWhenABalanceRemains =>
      'Enter party name when a balance remains';

  @override
  String get uiEnterPartyNameABalanceWillRemain =>
      'Enter party name; a balance will remain after the refund';

  @override
  String get uiEnterDocumentName => 'Enter document name';

  @override
  String get uiEnterEquipmentName => 'Enter equipment name';

  @override
  String get uiEnterYourNameToContinue => 'Enter your name to continue';

  @override
  String get uiEnterTheDateLike20260925 => 'Enter the date like 2026-09-25';

  @override
  String get uiEnterModel => 'Enter model';

  @override
  String get uiEnterCancellationReason => 'Enter cancellation reason';

  @override
  String get uiEnterRefundReason => 'Enter refund reason';

  @override
  String get uiEnterAValidRefundAmount => 'Enter a valid refund amount';

  @override
  String get uiEnterAnAmountAboveZeroAndBelow =>
      'Enter an amount above zero and below the total';

  @override
  String get uiEnterAnAmountAboveZeroUpTo =>
      'Enter an amount above zero, up to two decimal places';

  @override
  String get uiEnterAValidAmount => 'Enter a valid amount';

  @override
  String get uiDevelopmentNumbers0500000001Or0500000002 =>
      'Development numbers: 0500000001 or 0500000002';

  @override
  String get uiTotalSar => 'Total (SAR)';

  @override
  String get uiRefunds => 'Refunds';

  @override
  String get uiNameAndModelAreEnoughToStart =>
      'Name and model are enough to start. We add a reference automatically.';

  @override
  String get uiReceipts => 'Receipts';

  @override
  String get uiPreviousPaymentsAreKeptAndDoNot =>
      'Previous payments are kept and do not change when editing.';

  @override
  String get uiPayments => 'Payments';

  @override
  String get uiGeneralRecords => 'General records';

  @override
  String get uiArchivedRecords => 'Archived records';

  @override
  String get uiText102 => 'العربية';

  @override
  String get uiAll => 'All';

  @override
  String get uiAmount => 'Amount';

  @override
  String get uiAmountSar => 'Amount (SAR)';

  @override
  String get uiInitialPayment => 'Initial payment';

  @override
  String get uiInitialReceipt => 'Initial receipt';

  @override
  String get uiBalanceYouOwe => 'Balance you owe';

  @override
  String get uiBalanceOwedToYou => 'Balance owed to you';

  @override
  String get uiTotalPaid => 'Total paid';

  @override
  String get uiPaidAndRefundedAmountsBelowAreCalculated =>
      'Paid and refunded amounts below are calculated shares; original payments and refunds are recorded once on the expense.';

  @override
  String get uiRefundedBySupplier => 'Refunded by supplier';

  @override
  String get uiTotalReceived => 'Total received';

  @override
  String get uiDocument => 'Document';

  @override
  String get uiGeneralExpense => 'General expense';

  @override
  String get uiExpenseAppliesTo => 'Expense applies to';

  @override
  String get uiReturnedToCustomer => 'Returned to customer';

  @override
  String get uiEquipment => 'Equipment';

  @override
  String get uiAwaitingCompletion => 'Awaiting completion';

  @override
  String get uiAwaitingCompletionThisWillNotCountAs =>
      'Awaiting completion • This will not count as a financial entry until you add its details.';

  @override
  String get uiSearch => 'Search';

  @override
  String get uiNoExpiryDate => 'No expiry date';

  @override
  String get uiABalanceWillRemainAfterTheRefund =>
      'A balance will remain after the refund; record the party name for follow-up.';

  @override
  String get uiWhatShouldWeCallYou => 'What should we call you?';

  @override
  String get uiDetailsToComplete => 'Details to complete';

  @override
  String get uiConfirmCancellation => 'Confirm cancellation';

  @override
  String get uiConfirmCode => 'Confirm code';

  @override
  String get uiIssueDateOptional => 'Issue date (optional)';

  @override
  String get uiIssueDateIsAfterExpiryDate => 'Issue date is after expiry date';

  @override
  String get uiExpiryDateOptional => 'Expiry date (optional)';

  @override
  String get uiRenewCurrentDocument => 'Renew current document';

  @override
  String get uiUpdateIncome => 'Update income';

  @override
  String get uiRefreshRecords => 'Refresh records';

  @override
  String get uiUpdateDocument => 'Update document';

  @override
  String get uiUpdateDraft => 'Update draft';

  @override
  String get uiUpdateExpense => 'Update expense';

  @override
  String get uiLocalDevelopmentStorageMalwareScanningIsNot =>
      'Local development storage. Malware scanning is not enabled.';

  @override
  String get uiRecordRefund => 'Record refund';

  @override
  String get uiFilterRecords => 'Filter records';

  @override
  String get uiUploadFailed => 'Upload failed';

  @override
  String get uiUploadFailedTryAgain => 'Upload failed; try again';

  @override
  String get uiAttachmentUploadFailed => 'Attachment upload failed';

  @override
  String get uiEditIncome => 'Edit income';

  @override
  String get uiEditDocument => 'Edit document';

  @override
  String get uiEditExpense => 'Edit expense';

  @override
  String get uiCouldNotLoadDocumentsTryAgain =>
      'Could not load documents • Try again';

  @override
  String get uiCouldNotLoadDocumentsTryAgain161 =>
      'Could not load documents. Try again.';

  @override
  String get uiChangeNumberOrRequestANewCode =>
      'Change number or request a new code';

  @override
  String get uiIncomeDetails => 'Income details';

  @override
  String get uiExpenseDetails => 'Expense details';

  @override
  String get uiDownloadPdf => 'Download PDF';

  @override
  String get uiDownloadAttachment => 'Download attachment';

  @override
  String get uiCancelling => 'Cancelling…';

  @override
  String get uiVerifying => 'Verifying…';

  @override
  String get uiSaving => 'Saving...';

  @override
  String get uiSaving170 => 'Saving…';

  @override
  String get uiSavingChanges => 'Saving changes…';

  @override
  String get uiSavingEquipment => 'Saving equipment…';

  @override
  String get uiUploadingAndCheckingAttachment =>
      'Uploading and checking attachment…';

  @override
  String get uiReadyToRetryUpload => 'Ready to retry upload';

  @override
  String get uiReadyToUpload => 'Ready to upload';

  @override
  String get uiReadyToView => 'Ready to view';

  @override
  String get uiReceiptStatus => 'Receipt status';

  @override
  String get uiSettlementStatus => 'Settlement status';

  @override
  String get uiPaymentStatus => 'Payment status';

  @override
  String get uiEntryStatus => 'Entry status';

  @override
  String get uiSelectDifferentEquipmentAndMakeTheirAmounts =>
      'Select different equipment and make their amounts add up to the expense total';

  @override
  String get uiSaveRefund => 'Save refund';

  @override
  String get uiSaveReceipt => 'Save receipt';

  @override
  String get uiSaveChanges => 'Save changes';

  @override
  String get uiSavePayment => 'Save payment';

  @override
  String get uiSaveInvoiceNowAndCompleteDetailsLater =>
      'Save invoice now and complete details later';

  @override
  String get uiSaveEquipment => 'Save equipment';

  @override
  String get uiSaveInvoiceNow => 'Save invoice now';

  @override
  String get uiAttachmentSavedWithEntry => 'Attachment saved with entry';

  @override
  String get uiPaidPartOfIt => 'Paid part of it';

  @override
  String get uiPaidInFull => 'Paid in full';

  @override
  String get uiPaid => 'Paid';

  @override
  String get uiDocumentNumberOptional => 'Document number (optional)';

  @override
  String get uiDevelopmentCodeOnly123456 => 'Development code only: 123456';

  @override
  String get uiCancellationReason => 'Cancellation reason';

  @override
  String get uiRefundReason => 'Refund reason';

  @override
  String get uiPaymentsAndAttachmentsWillRemainInThe =>
      'Payments and attachments will remain in the record. Cancelling does not refund money.';

  @override
  String get uiUnsavedDataWillBeLostIfYou =>
      'Unsaved data will be lost. If you did not receive save confirmation, check records before creating another request.';

  @override
  String get uiEquipmentHistory => 'Equipment history';

  @override
  String get uiEquipmentHistoryAndDocumentsWillRemainSaved =>
      'Equipment history and documents will remain saved. Expiry reminders stop until restoration.';

  @override
  String get uiThePreviousDocumentWillBeKeptIn =>
      'The previous document will be kept in history. Add a new expiry date for the renewed document.';

  @override
  String get uiNetPaid => 'Net paid';

  @override
  String get uiNetReceived => 'Net received';

  @override
  String get uiImagesAndInvoicePdfs => 'Images and invoice PDFs';

  @override
  String get uiRequestVerificationCode => 'Request verification code';

  @override
  String get uiReturnedToYouByTheOtherParty =>
      'Returned to you by the other party';

  @override
  String get uiSeveralEquipment => 'Several equipment';

  @override
  String get uiAdjustEachEquipmentAmountToMatchThe =>
      'Adjust each equipment amount to match the total.';

  @override
  String get uiViewRecordsAndEntries => 'View records and entries →';

  @override
  String get uiViewAttachment => 'View attachment';

  @override
  String get uiViewDocuments => 'View documents';

  @override
  String get uiUnsettled => 'Unsettled';

  @override
  String get uiOpenPdf => 'Open PDF';

  @override
  String get uiOpenSavedDraft => 'Open saved draft';

  @override
  String get uiTipper1 => 'Tipper 1';

  @override
  String get uiEachEntryItsPaymentsAndAttachmentsIn =>
      'Each entry, its payments, and attachments in one record';

  @override
  String get uiNoEntriesMatchYourSearchOrFilters =>
      'No entries match your search or filters. Change or clear them.';

  @override
  String get uiNoInvoicesAwaitingCompletion =>
      'No invoices awaiting completion';

  @override
  String get uiNoDocumentsNeedAttentionNow => 'No documents need attention now';

  @override
  String get uiNoDocumentsHaveMissingInformation =>
      'No documents have missing information';

  @override
  String get uiNoMatchingEquipment => 'No matching equipment';

  @override
  String get uiNoPreviousVersionsYet => 'No previous versions yet';

  @override
  String get uiTheTotalCannotChangeAfterAPayment =>
      'The total cannot change after a payment, receipt, or refund is recorded';

  @override
  String get uiTheTotalCannotChangeBecauseAPayment =>
      'The total cannot change because a payment, receipt, or refund exists.';

  @override
  String get uiNotPaid => 'Not paid';

  @override
  String get uiNotReceived => 'Not received';

  @override
  String get uiUploadIncomplete => 'Upload incomplete';

  @override
  String get uiThisWillNotCountAsAFinancial =>
      'This will not count as a financial entry. Attachments will disappear from the list after discard.';

  @override
  String get uiThisDocumentWillNoLongerAppearAmong =>
      'This document will no longer appear among current documents or receive expiry reminders. It remains in history.';

  @override
  String get uiRefundAmount => 'Refund amount';

  @override
  String get uiRefundAmountExceedsWhatIsAvailable =>
      'Refund amount exceeds what is available';

  @override
  String get uiAmountPerEquipment => 'Amount per equipment';

  @override
  String get uiContinueEntry => 'Continue entry';

  @override
  String get uiWorkspace => 'Workspace';

  @override
  String get uiClearFilters => 'Clear filters';

  @override
  String get uiPartiallySettled => 'Partially settled';

  @override
  String get uiFullySettled => 'Fully settled';

  @override
  String get uiGeneralExpensesOnly => 'General expenses only';

  @override
  String get uiAWorkspaceExpenseItIsNotAssigned =>
      'A workspace expense; it is not assigned to equipment';

  @override
  String get uiYourEquipmentAndExpensesInOnePlace =>
      'Your equipment and expenses in one place';

  @override
  String get uiOneEquipment => 'One equipment';

  @override
  String get uiLeave => 'Leave';

  @override
  String get uiNoteOptional => 'Note (optional)';

  @override
  String get uiFromDate => 'From date';

  @override
  String get uiDueDateOptional => 'Due date (optional)';

  @override
  String get uiPreviousVersionIsViewOnly => 'Previous version is view only';

  @override
  String get uiActive => 'Active';

  @override
  String get uiSharePerEquipment => 'Share per equipment';

  @override
  String get uiEntryType => 'Entry type';

  @override
  String get uiExpenseType => 'Expense type';

  @override
  String get uiThisInvoiceIsSavedForLaterCompletion =>
      'This invoice is saved for later completion and is not yet included in financial totals.';

  @override
  String get uiLeaveThisForm => 'Leave this form?';

  @override
  String get uiNeedsAttention => 'Needs attention';

  @override
  String get uiExpenseAppliesTo276 => 'Expense applies to';

  @override
  String get uiThisIncomeIsRecordedUnderThisEquipment =>
      'This income is recorded under this equipment';

  @override
  String verifyPhone(String phone) {
    return 'Verify $phone';
  }

  @override
  String modelValue(String model) {
    return 'Model: $model';
  }

  @override
  String fromDateValue(String date) {
    return 'From $date';
  }

  @override
  String toDateValue(String date) {
    return 'To $date';
  }

  @override
  String entryDateStatus(String date, String status) {
    return '$date\n$status';
  }

  @override
  String draftUploadFailed(String error) {
    return 'Draft saved, but the file could not be uploaded. Try again. $error';
  }

  @override
  String draftNote(String note) {
    return 'Awaiting completion\n$note';
  }

  @override
  String noteValue(String note) {
    return 'Note: $note';
  }

  @override
  String allocationRemaining(String amount) {
    return 'Remaining to allocate: $amount';
  }

  @override
  String operationDate(String date) {
    return 'Entry date: $date';
  }

  @override
  String paymentDate(String date) {
    return 'Payment date: $date';
  }

  @override
  String receiptDate(String date) {
    return 'Receipt date: $date';
  }

  @override
  String dueDateValue(String date) {
    return 'Due date: $date';
  }

  @override
  String attachmentAfterSave(String kind) {
    return 'You can add an image or PDF after saving $kind.';
  }

  @override
  String savingKind(String kind) {
    return 'Saving $kind…';
  }

  @override
  String saveKind(String kind) {
    return 'Save $kind';
  }

  @override
  String remainingValue(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String refundIncomeHelp(String amount) {
    return 'Money returned to the customer or other party. Available to refund: $amount';
  }

  @override
  String refundExpenseHelp(String amount) {
    return 'Money returned to you by the supplier or other party. Available to refund: $amount';
  }

  @override
  String refundDate(String date) {
    return 'Refund date: $date';
  }

  @override
  String entryUploadFailed(String error) {
    return 'Entry saved, but the attachment upload failed. $error';
  }

  @override
  String entryAttachmentLabel(String filename) {
    return 'Entry attachment: $filename';
  }

  @override
  String cancelReasonValue(String reason) {
    return 'Reason: $reason';
  }

  @override
  String cancelDateValue(String date) {
    return 'Cancelled: $date';
  }

  @override
  String partAmount(String equipment, String amount) {
    return '$equipment: $amount';
  }

  @override
  String partNetRemaining(String paid, String remaining) {
    return 'Calculated share of net paid: $paid • Remaining: $remaining';
  }

  @override
  String partyValue(String party) {
    return 'Party: $party';
  }

  @override
  String paidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String receivedOn(String date) {
    return 'Received on $date';
  }

  @override
  String refundRecord(String kind, String date, String reason) {
    return '$kind on $date\nReason: $reason';
  }

  @override
  String get filesHelp => 'PNG or JPEG image, or PDF • up to 10 MB per file';

  @override
  String get noEntryAttachments =>
      'No attachments added yet; the entry is saved.';

  @override
  String documentSummary(
    String total,
    String expired,
    String soon,
    String missing,
  ) {
    return '$total documents • $expired expired • $soon expiring soon • $missing without expiry date';
  }

  @override
  String equipmentDocumentsTitle(String equipment) {
    return '$equipment documents';
  }

  @override
  String documentAlreadyExists(String document) {
    return 'A current $document already exists for this equipment. Renew it instead of adding a separate document?';
  }

  @override
  String expiryValue(String date) {
    return 'Expires on $date';
  }

  @override
  String numberValue(String number) {
    return 'Number: $number';
  }

  @override
  String issueDateValue(String date) {
    return 'Issue date: $date';
  }

  @override
  String versionNumber(String number) {
    return 'Version $number';
  }

  @override
  String versionExpiry(String expiry) {
    return 'Expiry: $expiry';
  }

  @override
  String versionIssue(String date) {
    return 'Issued: $date';
  }

  @override
  String versionNumberLabel(String number) {
    return 'Version number: $number';
  }

  @override
  String documentNumberLabel(String number) {
    return 'Document number: $number';
  }

  @override
  String expiryDateValue(String date) {
    return 'Expiry date: $date';
  }

  @override
  String missingDocumentsCount(String count) {
    return '$count documents without an expiry date';
  }

  @override
  String get versionAttachments => 'Attachments for this version';

  @override
  String get noAttachmentsShort => 'No attachments';

  @override
  String get addExpiryDate => 'Add expiry date';

  @override
  String get documentTypeExists => 'A document of this type exists';

  @override
  String get refreshDocuments => 'Refresh documents';

  @override
  String get cancelledAmountsHistory =>
      'The amounts and settlements below remain in history and are excluded from active totals.';

  @override
  String get cancelledEntry => 'Cancelled entry';

  @override
  String get timeoutMessage =>
      'The request took too long. If you were saving, check the records before trying again.';

  @override
  String documentExpiryInDays(String days) {
    return 'Expires in $days days';
  }

  @override
  String get documentExpiryToday => 'Expires today';

  @override
  String get documentExpiryPast => 'Expired';

  @override
  String weeklyExpiredCount(String count) {
    return '$count expired documents need review';
  }

  @override
  String get uploadFailed => 'Could not upload the file';

  @override
  String get sarUnit => 'SAR';
}
