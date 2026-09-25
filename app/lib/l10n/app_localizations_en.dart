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
      'Development numbers: 0500000000–0500000999, including invited members';

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

  @override
  String get m4Hub => 'Maintenance & issues';

  @override
  String get m4Issues => 'Issues';

  @override
  String get m4Maintenance => 'Maintenance records';

  @override
  String get m4NewIssue => 'New issue';

  @override
  String get m4AddMaintenance => 'Add maintenance';

  @override
  String get m4Problem => 'What is the problem?';

  @override
  String get m4WorkDone => 'What was done?';

  @override
  String get m4IssueType => 'Issue type (optional)';

  @override
  String get m4MaintenanceType => 'Maintenance type (optional)';

  @override
  String get m4Stopped => 'This problem stopped the equipment';

  @override
  String get m4StoppedBadge => 'Equipment stopped';

  @override
  String get m4Open => 'Open';

  @override
  String get m4InProgress => 'In progress';

  @override
  String get m4Closed => 'Closed';

  @override
  String get m4Start => 'Start processing';

  @override
  String get m4Close => 'Close issue';

  @override
  String get m4Reopen => 'Reopen issue';

  @override
  String get m4Resolution => 'Resolution';

  @override
  String get m4ResolutionRequired => 'Describe how the problem was resolved';

  @override
  String get m4Mechanical => 'Mechanical';

  @override
  String get m4Electrical => 'Electrical';

  @override
  String get m4Tires => 'Tires';

  @override
  String get m4Accident => 'Accident or damage';

  @override
  String get m4Repair => 'Repair';

  @override
  String get m4Periodic => 'Periodic service';

  @override
  String get m4Inspection => 'Inspection';

  @override
  String get m4Unclassified => 'Unclassified';

  @override
  String get m4Description => 'Work performed';

  @override
  String get m4Date => 'Maintenance date';

  @override
  String get m4Workshop => 'Workshop or service provider (optional)';

  @override
  String get m4LinkedIssue => 'Linked issue (optional)';

  @override
  String get m4IssueHistory => 'Closure history';

  @override
  String get m4RelatedMaintenance => 'Related maintenance';

  @override
  String get m4NoIssues => 'No issues for this equipment';

  @override
  String get m4NoMaintenance => 'No maintenance records for this equipment';

  @override
  String get m4NoResults => 'No matching records';

  @override
  String get m4IssueSearch => 'Search issues';

  @override
  String get m4MaintenanceSearch => 'Search maintenance';

  @override
  String get m4AllStatuses => 'All statuses';

  @override
  String get m4AllTypes => 'All types';

  @override
  String get m4OnlyStopped => 'Stopped equipment only';

  @override
  String get m4Cancelled => 'Cancelled record';

  @override
  String get m4ShowCancelled => 'Show cancelled';

  @override
  String get m4CancelMaintenance => 'Cancel maintenance record';

  @override
  String get m4CancelWarning =>
      'Cancelling maintenance will not cancel linked expenses.';

  @override
  String get m4CancellationReason => 'Cancellation reason';

  @override
  String get m4Expenses => 'Linked expenses';

  @override
  String get m4AddExpense => 'Add expense';

  @override
  String get m4LinkExpense => 'Link existing expense';

  @override
  String get m4UnlinkExpense => 'Unlink expense';

  @override
  String get m4ExpenseTotal => 'Active expense total';

  @override
  String get m4NetPaid => 'Net paid';

  @override
  String get m4Remaining => 'Remaining';

  @override
  String get m4NoEligible => 'No eligible expenses to link';

  @override
  String get m4NoAttachments => 'No attachments';

  @override
  String get m4CreateIssue => 'Save issue';

  @override
  String get m4SaveMaintenance => 'Save maintenance';

  @override
  String get m4IssueUpdated => 'Issue updated';

  @override
  String get m4AttentionEmpty => 'No issues or documents need attention now';

  @override
  String get m4AttentionOpenIssue => 'Open issue';

  @override
  String get m4ArchivedWarning =>
      'Issues and maintenance remain saved. Open issues leave Attention until equipment is restored.';

  @override
  String get m4SelectEquipment => 'Select equipment';

  @override
  String get m4IssueDetails => 'Issue details';

  @override
  String get m4MaintenanceDetails => 'Maintenance details';

  @override
  String get m4EditIssue => 'Edit issue';

  @override
  String get m4EditMaintenance => 'Edit maintenance';

  @override
  String get m4Required => 'This field is required';

  @override
  String get m4AllEquipment => 'All equipment';

  @override
  String get m4LinkedCount => 'Linked expenses';

  @override
  String get m4ViewHistory => 'View history';

  @override
  String get m4RemoveAttachment => 'Remove attachment';

  @override
  String get m4NoLinkedIssue => 'No linked issue';

  @override
  String get m4DateRange => 'Date range';

  @override
  String get m4ClearDateRange => 'Clear date range';

  @override
  String get m4NoIssuesGlobal => 'No issues yet';

  @override
  String get m4NoMaintenanceGlobal => 'No maintenance records yet';

  @override
  String get m4SelectIssue => 'Select issue';

  @override
  String get m4ClearIssue => 'Clear linked issue';

  @override
  String get m5Owner => 'Owner';

  @override
  String get m5Manager => 'Manager';

  @override
  String get m5Accountant => 'Accountant';

  @override
  String get m5Driver => 'Driver';

  @override
  String get m5Member => 'Member';

  @override
  String get m5Pending => 'Pending';

  @override
  String get m5Accepted => 'Accepted';

  @override
  String get m5Cancelled => 'Cancelled';

  @override
  String get m5Expired => 'Expired';

  @override
  String get m5Approved => 'Approved';

  @override
  String get m5Rejected => 'Rejected';

  @override
  String get m5EquipmentView => 'View equipment';

  @override
  String get m5EquipmentManage => 'Manage equipment';

  @override
  String get m5FinanceView => 'View finances';

  @override
  String get m5FinanceManage => 'Manage finances';

  @override
  String get m5FinanceReview => 'Review financial requests';

  @override
  String get m5DocumentView => 'View documents';

  @override
  String get m5DocumentManage => 'Manage documents';

  @override
  String get m5IssueView => 'View issues';

  @override
  String get m5IssueManage => 'Manage issues';

  @override
  String get m5MaintenanceView => 'View maintenance';

  @override
  String get m5MaintenanceManage => 'Manage maintenance';

  @override
  String get m5DriverAssignmentManage => 'Assign drivers';

  @override
  String get m5ReportView => 'View reports';

  @override
  String get m5TeamManage => 'Manage team';

  @override
  String get m5MyInvitations => 'My invitations';

  @override
  String get m5NoInvitations => 'No pending invitations';

  @override
  String get m5Expires => 'Expires';

  @override
  String get m5Accept => 'Accept invitation';

  @override
  String get m5Decline => 'Decline invitation';

  @override
  String get m5Team => 'Team';

  @override
  String get m5Members => 'Members';

  @override
  String get m5NoMembers => 'No members yet';

  @override
  String get m5Invitations => 'Invitations';

  @override
  String get m5InviteMember => 'Invite member';

  @override
  String get m5Resend => 'Resend';

  @override
  String get m5CancelInvitation => 'Cancel invitation?';

  @override
  String get m5ResendInvitation => 'Resend invitation?';

  @override
  String get m5EditMember => 'Edit member';

  @override
  String get m5Role => 'Role';

  @override
  String get m5Scope => 'Equipment scope';

  @override
  String get m5AllEquipment => 'All equipment';

  @override
  String get m5SelectedEquipment => 'Selected equipment';

  @override
  String get m5ChooseEquipment => 'Choose at least one equipment item';

  @override
  String get m5FinancialMode => 'Financial entry mode';

  @override
  String get m5ReviewMode => 'Send for review';

  @override
  String get m5DirectMode => 'Post directly';

  @override
  String get m5Capabilities => 'Permissions';

  @override
  String get m5CapabilitiesHint => 'Choose what this member can do.';

  @override
  String get m5NamePhoneRequired => 'Enter name and phone number';

  @override
  String get m5ConfirmPermissions => 'Save role or scope changes?';

  @override
  String get m5SendInvitation => 'Send invitation';

  @override
  String get m5MemberDetails => 'Member details';

  @override
  String get m5DriverAssignment => 'Driver assignment';

  @override
  String get m5RevokeConfirm => 'Revoke this member’s access?';

  @override
  String get m5RevokeAccess => 'Revoke access';

  @override
  String get m5CurrentAssignment => 'Current assignment';

  @override
  String get m5NoAssignment => 'No current assignment';

  @override
  String get m5ReplaceAssignmentConfirm =>
      'Change this driver’s assigned equipment?';

  @override
  String get m5Assign => 'Assign';

  @override
  String get m5Unassign => 'End assignment';

  @override
  String get m5UnassignConfirm => 'End this driver assignment?';

  @override
  String get m5AssignmentHistory => 'Assignment history';

  @override
  String get m5NoHistory => 'No previous assignments';

  @override
  String get m5DriverHome => 'Your work today';

  @override
  String get m5NoAssignmentDriver =>
      'No equipment is currently assigned to you.';

  @override
  String get m5ReportIssue => 'Report an issue';

  @override
  String get m5SubmitExpense => 'Submit expense';

  @override
  String get m5MyIssues => 'My issues';

  @override
  String get m5NoIssues => 'No issues for this equipment';

  @override
  String get m5MySubmissions => 'My financial requests';

  @override
  String get m5NoSubmissions => 'No financial requests yet';

  @override
  String get m5ReceiptOnly => 'Receipt without amount';

  @override
  String get m5SubmissionHint =>
      'Add an amount, note, or receipt. A reviewer checks it before posting the expense.';

  @override
  String get m5TransactionDate => 'Transaction date';

  @override
  String get m5Note => 'Note';

  @override
  String get m5AddReceipt => 'Add receipt';

  @override
  String get m5SubmissionNeedsContent => 'Add an amount, note, or receipt';

  @override
  String get m5SendForReview => 'Send for review';

  @override
  String get m5ReviewQueue => 'Review queue';

  @override
  String get m5ReviewQueueEmpty => 'No requests awaiting review';

  @override
  String get m5SubmissionDetails => 'Request details';

  @override
  String get m5Status => 'Status';

  @override
  String get m5SubmittedBy => 'Submitted by';

  @override
  String get m5RejectionReason => 'Rejection reason';

  @override
  String get m5ApprovedEntryCreated => 'Expense posted after approval';

  @override
  String get m5Approve => 'Approve';

  @override
  String get m5Reject => 'Reject';

  @override
  String get m5RejectSubmission => 'Reject request';

  @override
  String get m5ReasonRequired => 'Enter a rejection reason';

  @override
  String get m5ApproveExpense => 'Approve expense';

  @override
  String get m5ApprovalHint =>
      'Check the expense details before approval. It will appear once in the ledger.';

  @override
  String get m5Category => 'Category';

  @override
  String get m5PaymentStatus => 'Payment status';

  @override
  String get m5PaidOn => 'Payment date';

  @override
  String get m5DueDate => 'Due date';

  @override
  String get m5ChooseDate => 'Choose a date';

  @override
  String get m5PartyDueRequired => 'Enter party name and due date';

  @override
  String get m5PartialLessThanTotal =>
      'Partial payment must be less than the total';

  @override
  String get m5ApproveConfirm => 'Approve and post this expense?';

  @override
  String get m5SwitchWorkspace => 'Switch workspace';

  @override
  String get m5NotificationDriverAssigned => 'Equipment assigned to you';

  @override
  String get m5NotificationDriverIssue => 'New driver issue';

  @override
  String get m5NotificationSubmissionPending =>
      'Financial request needs review';

  @override
  String get m5NotificationSubmissionApproved =>
      'Your financial request was approved';

  @override
  String get m5NotificationSubmissionRejected =>
      'Your financial request was rejected';

  @override
  String get m5AttentionReview => 'Financial requests need review';

  @override
  String m5PendingReviewsCount(String count) {
    return '$count financial requests awaiting review';
  }

  @override
  String get m5RoleChangeResetsPermissions =>
      'Changing the role resets permissions to the new role defaults and removes previous customizations. Continue?';

  @override
  String get m5DirectExpenseHint =>
      'Complete the expense details and post it directly.';

  @override
  String get m5DirectExpenseConfirm => 'Post this expense?';

  @override
  String get m5InvitationPending =>
      'An invitation is already pending for this number.';

  @override
  String get m5InvitationClosed =>
      'Invitation closed or expired. Refresh the list.';

  @override
  String get m5AlreadyMember => 'This person is already a member.';

  @override
  String get m5SubmissionReviewed =>
      'This request was already reviewed. Refresh the list.';

  @override
  String get m5NoDriverAssignment => 'No equipment is assigned to you now.';

  @override
  String get m5Issues => 'Issues';

  @override
  String get m5DriverInviteHint =>
      'Assign equipment after the driver accepts the invitation.';

  @override
  String get m5AllScopeHint => 'Includes current and future equipment.';

  @override
  String get m5AssignMayReplace =>
      'This assignment may replace the equipment’s current driver. Continue?';

  @override
  String get m5ChooseDriver => 'Choose driver';

  @override
  String get m5NoEligibleDrivers =>
      'No drivers are available for this equipment';

  @override
  String m5DriverCurrentlyOnEquipment(String equipmentName) {
    return 'Currently assigned to $equipmentName';
  }

  @override
  String m5ConfirmAssignDriver(String driverName, String equipmentName) {
    return 'Assign $driverName to $equipmentName?';
  }

  @override
  String m5ConfirmReplaceDriver(
    String currentDriver,
    String newDriver,
    String equipmentName,
  ) {
    return 'Replace $currentDriver with $newDriver on $equipmentName?';
  }

  @override
  String m5ConfirmMoveDriver(String driverName, String sourceEquipment) {
    return '$driverName will no longer be assigned to $sourceEquipment.';
  }
}
