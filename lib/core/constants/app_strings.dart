import 'app_constants.dart';

class AppStringsBundle {
  const AppStringsBundle({
    required this.customerDetailsSaved,
    required this.customerNotFoundDescription,
    required this.backToCustomers,
    required this.activityLog,
    required this.noRecordedActivities,
    required this.internalNotes,
    required this.internalNotesHint,
    required this.customerProfileCreated,
    required this.customerProfileCreatedDesc,
    required this.lastCustomerContactTitle,
    required this.lastCustomerContactDesc,
    required this.reasonLogged,
    required this.noJobTitle,
    required this.callActionCall,
    required this.callActionCompleted,
    required this.callActionUpcoming,
    required this.callActionInstantSuccess,
    required this.callActionScheduled,
    required this.callActionCalling,
    required this.callActionContactCustomer,
    required this.callActionNewOutgoingCall,
    required this.callActionSelectCustomer,
    required this.callActionChooseCustomerHint,
    required this.callActionCallNow,
    required this.callActionSchedule,
    required this.callActionStartInstantCall,
    required this.callActionChooseDate,
    required this.callActionToday,
    required this.callActionTomorrow,
    required this.callActionNextMonday,
    required this.callActionCustomDate,
    required this.callActionChooseTime,
    required this.callActionMorning,
    required this.callActionAfternoon,
    required this.callActionEvening,
    required this.callActionCustomTime,
    required this.callActionConfirmSchedule,
    required this.callActionInstantSuccessMsg,
    required this.callActionScheduledSuccessMsg,
    required this.emailFollowUpsHeadline,
    required this.emailFollowUpsNewTemplate,
    required this.emailFollowUpsComposeEmail,
    required this.emailFollowUpsTotalSent,
    required this.emailFollowUpsTemplates,
    required this.emailFollowUpsSuccessRate,
    required this.emailFollowUpsSentHistory,
    required this.emailFollowUpsSearchEmailsHint,
    required this.emailFollowUpsSearchTemplatesHint,
    required this.emailFollowUpsCreateTemplateTitle,
    required this.emailFollowUpsEditTemplateTitle,
    required this.emailFollowUpsTemplateNameLabel,
    required this.emailFollowUpsTemplateNameHint,
    required this.emailFollowUpsTemplateSubjectLabel,
    required this.emailFollowUpsTemplateSubjectHint,
    required this.emailFollowUpsTemplateBodyLabel,
    required this.emailFollowUpsTemplateBodyHint,
    required this.emailFollowUpsCancel,
    required this.emailFollowUpsSaveTemplate,
    required this.emailFollowUpsLiveTemplatePreview,
    required this.emailFollowUpsComposeTitle,
    required this.emailFollowUpsRecipientLabel,
    required this.emailFollowUpsTemplateSelectLabel,
    required this.emailFollowUpsCustomEmail,
    required this.emailFollowUpsSubjectLabel,
    required this.emailFollowUpsSubjectHint,
    required this.emailFollowUpsBodyLabel,
    required this.emailFollowUpsBodyHint,
    required this.emailFollowUpsSendEmail,
    required this.emailFollowUpsLiveEmailPreview,
    required this.emailFollowUpsNoCustomersWarning,
    required this.emailFollowUpsFillAllFieldsWarning,
    required this.emailFollowUpsTemplateCreated,
    required this.emailFollowUpsTemplateUpdated,
    required this.emailFollowUpsEmailSentSuccess,
    required this.emailFollowUpsPreviewTitle,
    required this.emailFollowUpsClose,
    required this.emailFollowUpsRecipient,
    required this.emailFollowUpsSubject,
    required this.emailFollowUpsTemplateUsed,
    required this.emailFollowUpsSentDateTime,
    required this.emailFollowUpsEmailBody,
    required this.emailFollowUpsNoEmailsYet,
    required this.emailFollowUpsNoEmailsHint,
    required this.emailFollowUpsNoTemplatesYet,
    required this.emailFollowUpsNoTemplatesHint,
    required this.emailFollowUpsTo,
    required this.emailFollowUpsFrom,
    required this.emailFollowUpsStartTypingHint,
    required this.emailFollowUpsNoSubject,
    required this.appTitle,
    required this.admin,
    required this.copyRight,
    required this.dashboardNavLabel,
    required this.customersNavLabel,
    required this.callNavLabel,
    required this.emailFollowupNavLabel,
    required this.settingsNavLabel,
    required this.changeThemeTooltip,
    required this.dashboardHeadline,
    required this.dashboardUpcomingCalls,
    required this.dashboardEmailFollowUps,
    required this.dashboardTotalCalls,
    required this.dashboardTotalCallsHint,
    required this.dashboardActiveAgents,
    required this.dashboardActiveAgentsHint,
    required this.dashboardAvgHandleTime,
    required this.filter,
    required this.dashboardAvgHandleTimeHint,
    required this.dashboardPlaceholderBody,
    required this.agentsPlaceholder,
    required this.settingsHeadline,
    required this.settingsThemeSystem,
    required this.settingsThemeLight,
    required this.settingsThemeDark,
    required this.successfull,
    required this.failed,
    required this.queued,
    required this.sent,
    required this.requiresResponse,
    required this.pending,
    required this.fullName,
    required this.dateTime,
    required this.searchHint,
    required this.import,
    required this.export,
    required this.email,
    required this.createdAt,
    required this.lastContact,
    required this.status,
    required this.actions,
    required this.phone,
    required this.customerInfo,
    required this.delete,
    required this.save,
    required this.active,
    required this.inactive,
    required this.profile,
    required this.firstName,
    required this.lastName,
    required this.reasonForContact,
    required this.jobTitle,
    required this.add,
    required this.newText,
    required this.assignee,
    required this.loginSuccessfulTitle,
    required this.loginSuccessfulMessage,
    required this.loginHeaderTitle,
    required this.loginUsernameLabel,
    required this.loginUsernameError,
    required this.loginPasswordLabel,
    required this.loginPasswordRequiredError,
    required this.loginPasswordLengthError,
    required this.loginRememberMe,
    required this.loginForgotPassword,
    required this.loginRecoverPasswordTitle,
    required this.loginRecoverPasswordMessage,
    required this.loginButtonLabel,
    required this.loginErrorTitle,
    required this.loginErrorInvalidCredentials,
    required this.loginErrorServerUnreachable,
    required this.loginErrorTimeout,
    required this.loginErrorGeneric,
    required this.logoutLabel,
    required this.logoutConfirmTitle,
    required this.logoutConfirmMessage,
    required this.logoutCancelButton,
    required this.logoutConfirmButton,
    required this.settingsAiAgentStatusTitle,
    required this.settingsAiAgentStatusSubtitle,
    required this.settingsAiAgentVoiceTitle,
    required this.settingsAiAgentVoiceSubtitle,
    required this.settingsVoiceBrian,
    required this.settingsVoiceEmma,
    required this.settingsVoiceJohn,
    required this.settingsVoiceSophia,
    required this.aiSettingsNavLabel,
    required this.aiSettingsTitle,
    required this.customerNotFound,
    required this.deleteCustomerConfirmTitle,
    required this.deleteCustomerConfirmMessage,
    required this.deleteCustomerSuccess,
    required this.addCustomerTitle,
    required this.invalidEmailError,
    required this.invalidPhoneError,
    required this.emptyNameError,
    required this.addCustomerSuccess,
    required this.appName,
    required this.dashboardWelcomeAdmin,
    required this.dashboardAiAssistantOnline,
    required this.dashboardAiAssistantOffline,
    required this.dashboardTotalCallsTitle,
    required this.dashboardSuccessRate,
    required this.dashboardActiveAiVoice,
    required this.dashboardPendingFollowUps,
    required this.dashboardRecentCallLogs,
    required this.dashboardEmailFollowUpsTitle,
    required this.dashboardQuickOperations,
    required this.dashboardAddNewCustomer,
    required this.dashboardManageVoiceEngine,
    required this.dashboardCustomerAdded,
    required this.dashboardAiCampaignStarted,
    required this.dashboardNoCustomersYet,
    required this.dashboardNoCallsYet,
    required this.dashboardNoEmailsYet,
    required this.dashboardViewAllCustomers,
    required this.dashboardViewAllCallLogs,
    required this.dashboardViewAllEmails,
    required this.callsTotalCalls,
    required this.callsCompletedCalls,
    required this.callsFailedCalls,
    required this.callsPendingUpcoming,
    required this.customersTotalCustomers,
    required this.customersActiveAccounts,
    required this.customersInactiveAccounts,
    required this.customersContactedToday,
    required this.customersNoCustomersFound,
    required this.customersImportCustomers,
    required this.customersSelectMockCustomers,
    required this.customersCancel,
    required this.customersImportSelected,
    required this.customersExportingData,
    required this.customersExportedSuccess,
    required this.settingsSystemPreferences,
    required this.settingsConfigureTheme,
  });
  final String customerDetailsSaved;
  final String customerNotFoundDescription;
  final String backToCustomers;
  final String activityLog;
  final String noRecordedActivities;
  final String internalNotes;
  final String internalNotesHint;
  final String customerProfileCreated;
  final String customerProfileCreatedDesc;
  final String lastCustomerContactTitle;
  final String lastCustomerContactDesc;
  final String reasonLogged;
  final String noJobTitle;
  final String callActionCall;

  final String callActionCompleted;
  final String callActionUpcoming;
  final String callActionInstantSuccess;
  final String callActionScheduled;
  final String callActionCalling;
  final String callActionContactCustomer;
  final String callActionNewOutgoingCall;
  final String callActionSelectCustomer;
  final String callActionChooseCustomerHint;
  final String callActionCallNow;
  final String callActionSchedule;
  final String callActionStartInstantCall;
  final String callActionChooseDate;
  final String callActionToday;
  final String callActionTomorrow;
  final String callActionNextMonday;
  final String callActionCustomDate;
  final String callActionChooseTime;
  final String callActionMorning;
  final String callActionAfternoon;
  final String callActionEvening;
  final String callActionCustomTime;
  final String callActionConfirmSchedule;
  final String callActionInstantSuccessMsg;
  final String callActionScheduledSuccessMsg;

  final String emailFollowUpsHeadline;
  final String emailFollowUpsNewTemplate;
  final String emailFollowUpsComposeEmail;
  final String emailFollowUpsTotalSent;
  final String emailFollowUpsTemplates;
  final String emailFollowUpsSuccessRate;
  final String emailFollowUpsSentHistory;
  final String emailFollowUpsSearchEmailsHint;
  final String emailFollowUpsSearchTemplatesHint;
  final String emailFollowUpsCreateTemplateTitle;
  final String emailFollowUpsEditTemplateTitle;
  final String emailFollowUpsTemplateNameLabel;
  final String emailFollowUpsTemplateNameHint;
  final String emailFollowUpsTemplateSubjectLabel;
  final String emailFollowUpsTemplateSubjectHint;
  final String emailFollowUpsTemplateBodyLabel;
  final String emailFollowUpsTemplateBodyHint;
  final String emailFollowUpsCancel;
  final String emailFollowUpsSaveTemplate;
  final String emailFollowUpsLiveTemplatePreview;
  final String emailFollowUpsComposeTitle;
  final String emailFollowUpsRecipientLabel;
  final String emailFollowUpsTemplateSelectLabel;
  final String emailFollowUpsCustomEmail;
  final String emailFollowUpsSubjectLabel;
  final String emailFollowUpsSubjectHint;
  final String emailFollowUpsBodyLabel;
  final String emailFollowUpsBodyHint;
  final String emailFollowUpsSendEmail;
  final String emailFollowUpsLiveEmailPreview;
  final String emailFollowUpsNoCustomersWarning;
  final String emailFollowUpsFillAllFieldsWarning;
  final String emailFollowUpsTemplateCreated;
  final String emailFollowUpsTemplateUpdated;
  final String emailFollowUpsEmailSentSuccess;
  final String emailFollowUpsPreviewTitle;
  final String emailFollowUpsClose;
  final String emailFollowUpsRecipient;
  final String emailFollowUpsSubject;
  final String emailFollowUpsTemplateUsed;
  final String emailFollowUpsSentDateTime;
  final String emailFollowUpsEmailBody;
  final String emailFollowUpsNoEmailsYet;
  final String emailFollowUpsNoEmailsHint;
  final String emailFollowUpsNoTemplatesYet;
  final String emailFollowUpsNoTemplatesHint;
  final String emailFollowUpsTo;
  final String emailFollowUpsFrom;
  final String emailFollowUpsStartTypingHint;
  final String emailFollowUpsNoSubject;
  final String appTitle;
  final String email;
  final String createdAt;
  final String lastContact;
  final String status;
  final String assignee;
  final String phone;
  final String actions;
  final String searchHint;
  final String admin;
  final String copyRight;
  final String import;
  final String export;
  final String successfull;
  final String fullName;
  final String dateTime;
  final String queued;
  final String dashboardNavLabel;
  final String customersNavLabel;
  final String callNavLabel;
  final String emailFollowupNavLabel;
  final String settingsNavLabel;
  final String changeThemeTooltip;
  final String dashboardHeadline;
  final String dashboardTotalCalls;
  final String dashboardUpcomingCalls;
  final String dashboardEmailFollowUps;
  final String dashboardTotalCallsHint;
  final String dashboardActiveAgents;
  final String dashboardActiveAgentsHint;
  final String dashboardAvgHandleTime;
  final String dashboardAvgHandleTimeHint;
  final String dashboardPlaceholderBody;
  final String agentsPlaceholder;
  final String settingsHeadline;
  final String settingsThemeSystem;
  final String settingsThemeLight;
  final String settingsThemeDark;
  final String failed;
  final String requiresResponse;
  final String pending;
  final String sent;
  final String filter;
  final String customerInfo;
  final String delete;
  final String save;
  final String active;
  final String inactive;
  final String profile;
  final String firstName;
  final String lastName;
  final String reasonForContact;
  final String customerNotFound;
  final String jobTitle;
  final String add;
  final String newText;
  final String loginSuccessfulTitle;
  final String loginSuccessfulMessage;
  final String loginHeaderTitle;
  final String loginUsernameLabel;
  final String loginUsernameError;
  final String loginPasswordLabel;
  final String loginPasswordRequiredError;
  final String loginPasswordLengthError;
  final String loginRememberMe;
  final String loginForgotPassword;
  final String loginRecoverPasswordTitle;
  final String loginRecoverPasswordMessage;
  final String loginButtonLabel;
  final String loginErrorTitle;
  final String loginErrorInvalidCredentials;
  final String loginErrorServerUnreachable;
  final String loginErrorTimeout;
  final String loginErrorGeneric;
  final String logoutLabel;
  final String logoutConfirmTitle;
  final String logoutConfirmMessage;
  final String logoutCancelButton;
  final String logoutConfirmButton;
  final String settingsAiAgentStatusTitle;
  final String settingsAiAgentStatusSubtitle;
  final String settingsAiAgentVoiceTitle;
  final String settingsAiAgentVoiceSubtitle;
  final String settingsVoiceBrian;
  final String settingsVoiceEmma;
  final String settingsVoiceJohn;
  final String settingsVoiceSophia;
  final String aiSettingsNavLabel;
  final String aiSettingsTitle;
  final String deleteCustomerConfirmTitle;
  final String deleteCustomerConfirmMessage;
  final String deleteCustomerSuccess;
  final String addCustomerTitle;
  final String invalidEmailError;
  final String invalidPhoneError;
  final String emptyNameError;
  final String addCustomerSuccess;
  final String appName;
  final String dashboardWelcomeAdmin;
  final String dashboardAiAssistantOnline;
  final String dashboardAiAssistantOffline;
  final String dashboardTotalCallsTitle;
  final String dashboardSuccessRate;
  final String dashboardActiveAiVoice;
  final String dashboardPendingFollowUps;
  final String dashboardRecentCallLogs;
  final String dashboardEmailFollowUpsTitle;
  final String dashboardQuickOperations;
  final String dashboardAddNewCustomer;
  final String dashboardManageVoiceEngine;
  final String dashboardCustomerAdded;
  final String dashboardAiCampaignStarted;
  final String dashboardNoCustomersYet;
  final String dashboardNoCallsYet;
  final String dashboardNoEmailsYet;
  final String dashboardViewAllCustomers;
  final String dashboardViewAllCallLogs;
  final String dashboardViewAllEmails;
  final String callsTotalCalls;
  final String callsCompletedCalls;
  final String callsFailedCalls;
  final String callsPendingUpcoming;
  final String customersTotalCustomers;
  final String customersActiveAccounts;
  final String customersInactiveAccounts;
  final String customersContactedToday;
  final String customersNoCustomersFound;
  final String customersImportCustomers;
  final String customersSelectMockCustomers;
  final String customersCancel;
  final String customersImportSelected;
  final String customersExportingData;
  final String customersExportedSuccess;
  final String settingsSystemPreferences;
  final String settingsConfigureTheme;
}

class AppStrings {
  const AppStrings._();

  static String languageCode = 'en';

  static final Map<String, AppStringsBundle> _bundles = {
    'en': AppStringsBundle(
      customerDetailsSaved: 'Customer details saved successfully.',
      customerNotFoundDescription:
          'The customer you are looking for does not exist or may have been deleted.',
      backToCustomers: 'BACK TO CUSTOMERS',
      activityLog: 'ACTIVITY LOG',
      noRecordedActivities: 'No recorded activities.',
      internalNotes: 'INTERNAL NOTES',
      internalNotesHint:
          'Type internal notes for this customer here... Click Save at the top to commit changes.',
      customerProfileCreated: 'Customer Profile Created',
      customerProfileCreatedDesc: 'Account added to the admin portal.',
      lastCustomerContactTitle: 'Last Customer Contact',
      lastCustomerContactDesc: 'Inquiry handled by active agent.',
      reasonLogged: 'Reason Logged',
      noJobTitle: 'No Job Title',
      callActionCall: 'CALL',
      callActionCompleted: 'Completed',
      callActionUpcoming: 'Upcoming',
      callActionInstantSuccess: 'Instant outgoing call completed successfully.',
      callActionScheduled: 'Scheduled call.',
      callActionCalling: 'Calling',
      callActionContactCustomer: 'CONTACT CUSTOMER',
      callActionNewOutgoingCall: 'NEW OUTGOING CALL',
      callActionSelectCustomer: 'SELECT CUSTOMER',
      callActionChooseCustomerHint: 'Choose a customer...',
      callActionCallNow: 'CALL NOW',
      callActionSchedule: 'SCHEDULE',
      callActionStartInstantCall: 'START INSTANT CALL',
      callActionChooseDate: 'CHOOSE DATE',
      callActionToday: 'Today',
      callActionTomorrow: 'Tomorrow',
      callActionNextMonday: 'Next Monday',
      callActionCustomDate: 'Custom Date...',
      callActionChooseTime: 'CHOOSE TIME',
      callActionMorning: 'Morning (09:00 AM)',
      callActionAfternoon: 'Afternoon (02:00 PM)',
      callActionEvening: 'Evening (05:00 PM)',
      callActionCustomTime: 'Custom Time...',
      callActionConfirmSchedule: 'CONFIRM SCHEDULE',
      callActionInstantSuccessMsg: 'Instant call with {name} completed.',
      callActionScheduledSuccessMsg: 'Call scheduled for {date} at {time}.',
      emailFollowUpsHeadline: "Email follow ups",
      emailFollowUpsNewTemplate: "NEW TEMPLATE",
      emailFollowUpsComposeEmail: "COMPOSE EMAIL",
      emailFollowUpsTotalSent: "TOTAL SENT",
      emailFollowUpsTemplates: "TEMPLATES",
      emailFollowUpsSuccessRate: "SUCCESS RATE",
      emailFollowUpsSentHistory: "SENT HISTORY",
      emailFollowUpsSearchEmailsHint: "Search emails...",
      emailFollowUpsSearchTemplatesHint: "Search templates...",
      emailFollowUpsCreateTemplateTitle: "CREATE NEW TEMPLATE",
      emailFollowUpsEditTemplateTitle: "EDIT TEMPLATE",
      emailFollowUpsTemplateNameLabel: "TEMPLATE NAME",
      emailFollowUpsTemplateNameHint:
          "e.g. Sales Onboarding, Pricing Follow-up",
      emailFollowUpsTemplateSubjectLabel: "DEFAULT SUBJECT",
      emailFollowUpsTemplateSubjectHint:
          "Use {name} for dynamic customer name injection",
      emailFollowUpsTemplateBodyLabel: "TEMPLATE BODY (HTML SUPPORT)",
      emailFollowUpsTemplateBodyHint:
          "Write template body here. Use {name} for automatic customer name injection...",
      emailFollowUpsCancel: "CANCEL",
      emailFollowUpsSaveTemplate: "SAVE TEMPLATE",
      emailFollowUpsLiveTemplatePreview: "LIVE TEMPLATE PREVIEW",
      emailFollowUpsComposeTitle: "SEND NEW EMAIL FOLLOW-UP",
      emailFollowUpsRecipientLabel: "RECIPIENT",
      emailFollowUpsTemplateSelectLabel: "EMAIL TEMPLATE",
      emailFollowUpsCustomEmail: "Custom Email (No Template)",
      emailFollowUpsSubjectLabel: "SUBJECT",
      emailFollowUpsSubjectHint: "Enter email subject...",
      emailFollowUpsBodyLabel: "EMAIL CONTENT (HTML SUPPORT)",
      emailFollowUpsBodyHint:
          "Write your email body here. Highlight text to format or insert tags...",
      emailFollowUpsSendEmail: "SEND EMAIL",
      emailFollowUpsLiveEmailPreview: "LIVE EMAIL PREVIEW",
      emailFollowUpsNoCustomersWarning:
          "No customers available. Please add a customer first.",
      emailFollowUpsFillAllFieldsWarning: "Please fill in all fields.",
      emailFollowUpsTemplateCreated: "Template created successfully!",
      emailFollowUpsTemplateUpdated: "Template updated successfully!",
      emailFollowUpsEmailSentSuccess: "Email sent successfully to {name}!",
      emailFollowUpsPreviewTitle: "SENT EMAIL PREVIEW",
      emailFollowUpsClose: "CLOSE",
      emailFollowUpsRecipient: "Recipient",
      emailFollowUpsSubject: "Subject",
      emailFollowUpsTemplateUsed: "Template Used",
      emailFollowUpsSentDateTime: "Sent Date & Time",
      emailFollowUpsEmailBody: "EMAIL BODY",
      emailFollowUpsNoEmailsYet: "No emails sent yet.",
      emailFollowUpsNoEmailsHint:
          "Compose a new email follow-up to get started.",
      emailFollowUpsNoTemplatesYet: "No templates available.",
      emailFollowUpsNoTemplatesHint:
          "Create a template to speed up your workflow.",
      emailFollowUpsTo: "To",
      emailFollowUpsFrom: "From",
      emailFollowUpsStartTypingHint:
          "Start typing on the left to see the live rendering here...",
      emailFollowUpsNoSubject: "(No Subject)",
      appTitle: AppConstants.appName,
      firstName: 'First Name',
      assignee: 'Assignee',
      add: 'Add',
      newText: 'New',
      customerNotFound: 'Customer not found.',
      lastName: 'Last Name',
      jobTitle: 'Job Title',
      reasonForContact: 'Reason For Contact',
      admin: 'admin',
      profile: 'Profile',
      inactive: 'Inactive',
      active: 'Active',
      customerInfo: 'Customer-info',
      save: 'Save',
      actions: 'Actions',
      createdAt: 'Created At',
      email: 'Email',
      lastContact: 'Last Contact',
      delete: 'Delete',
      phone: 'Phone',
      status: 'Status',
      import: 'Import',
      export: 'Export',
      copyRight: 'XARTA©',
      dashboardNavLabel: 'Dashboard',
      customersNavLabel: 'Customers',
      successfull: 'successfull',
      dateTime: 'Date - Time',
      fullName: 'FullName',
      failed: 'failed',
      callNavLabel: 'Calls',
      queued: 'queued',
      sent: 'sent',
      pending: 'queued',
      requiresResponse: 'requires response',
      emailFollowupNavLabel: 'Email Follow-ups',
      settingsNavLabel: 'Settings',
      changeThemeTooltip: 'Change theme',
      dashboardHeadline: 'Service overview',
      searchHint: "Search...",
      filter: "Filter",
      dashboardTotalCalls: 'Total calls',
      dashboardUpcomingCalls: 'Upcoming calls',
      dashboardEmailFollowUps: 'Email follow ups',
      dashboardTotalCallsHint: 'Unique calls handled in the last 24 hours',
      dashboardActiveAgents: 'Active agents',
      dashboardActiveAgentsHint: 'Agents logged in and available',
      dashboardAvgHandleTime: 'Avg. handle time',
      dashboardAvgHandleTimeHint: 'Average talk time across all queues',
      dashboardPlaceholderBody:
          'Connect your analytics source to replace this sample content.',
      agentsPlaceholder:
          'Connect your data API to list agents, filter and manage skills.',
      settingsHeadline: 'Workspace settings',
      settingsThemeSystem: 'System',
      settingsThemeLight: 'Light',
      settingsThemeDark: 'Dark',
      loginSuccessfulTitle: 'Success',
      loginSuccessfulMessage: 'Login successful.',
      loginHeaderTitle: 'Sign In',
      loginUsernameLabel: 'Email or Username',
      loginUsernameError: 'Please enter your email or username',
      loginPasswordLabel: 'Password',
      loginPasswordRequiredError: 'Please enter your password',
      loginPasswordLengthError: 'Password must be at least 6 characters',
      loginRememberMe: 'Remember me',
      loginForgotPassword: 'Forgot password?',
      loginRecoverPasswordTitle: 'Password Recovery',
      loginRecoverPasswordMessage:
          'This feature is not active in this version.',
      loginButtonLabel: 'Sign In',
      loginErrorTitle: 'Login failed',
      loginErrorInvalidCredentials:
          'Invalid email or password. Please try again.',
      loginErrorServerUnreachable:
          'Cannot reach the server. Please check your connection.',
      loginErrorTimeout: 'The request timed out. Please try again.',
      loginErrorGeneric: 'Something went wrong. Please try again.',
      logoutLabel: 'Logout',
      logoutConfirmTitle: 'Confirm Logout',
      logoutConfirmMessage:
          'Are you sure you want to log out from the admin console?',
      logoutCancelButton: 'Cancel',
      logoutConfirmButton: 'Logout',
      settingsAiAgentStatusTitle: 'AI Agent Status',
      settingsAiAgentStatusSubtitle:
          'Enable or disable the conversational AI agent.',
      settingsAiAgentVoiceTitle: 'AI Agent Voice',
      settingsAiAgentVoiceSubtitle:
          'Choose the voice characteristics for the AI agent.',
      settingsVoiceBrian: 'Male - Brian (Professional & Deep)',
      settingsVoiceEmma: 'Female - Emma (Warm & Friendly)',
      settingsVoiceJohn: 'Male - John (Clear & Corporate)',
      settingsVoiceSophia: 'Female - Sophia (Soft & Natural)',
      aiSettingsNavLabel: 'AI Settings',
      aiSettingsTitle: 'AI SETTINGS',
      deleteCustomerConfirmTitle: 'Delete Customer',
      deleteCustomerConfirmMessage:
          'Are you sure you want to delete this customer? This action cannot be undone.',
      deleteCustomerSuccess: 'Customer deleted successfully.',
      addCustomerTitle: 'Add New Customer',
      invalidEmailError: 'Please enter a valid email address',
      invalidPhoneError: 'Please enter a valid phone number',
      emptyNameError: 'Please enter the customer\'s name',
      addCustomerSuccess: 'Customer added successfully.',
      appName: 'CallX AI',
      dashboardWelcomeAdmin: 'Welcome back, Admin',
      dashboardAiAssistantOnline: 'AI ASSISTANT ONLINE',
      dashboardAiAssistantOffline: 'AI ASSISTANT OFFLINE',
      dashboardTotalCallsTitle: 'TOTAL CALLS',
      dashboardSuccessRate: 'SUCCESS RATE',
      dashboardActiveAiVoice: 'ACTIVE AI VOICE',
      dashboardPendingFollowUps: 'PENDING FOLLOW-UPS',
      dashboardRecentCallLogs: 'RECENT CALLS LOGS',
      dashboardEmailFollowUpsTitle: 'EMAIL FOLLOW-UPS',
      dashboardQuickOperations: 'QUICK OPERATIONS',
      dashboardAddNewCustomer: 'Add New Customer',
      dashboardManageVoiceEngine: 'Manage Voice Engine',
      dashboardCustomerAdded: 'Customer Added',
      dashboardAiCampaignStarted: 'AI Campaign Started',
      dashboardNoCustomersYet: 'No customers registered yet.',
      dashboardNoCallsYet: 'No call records logged yet.',
      dashboardNoEmailsYet: 'No email follow-ups registered.',
      dashboardViewAllCustomers: 'View all customers',
      dashboardViewAllCallLogs: 'View all call logs',
      dashboardViewAllEmails: 'View all emails',
      callsTotalCalls: 'Total Calls',
      callsCompletedCalls: 'Completed Calls',
      callsFailedCalls: 'Failed Calls',
      callsPendingUpcoming: 'Pending & Upcoming',
      customersTotalCustomers: 'Total Customers',
      customersActiveAccounts: 'Active Accounts',
      customersInactiveAccounts: 'Inactive Accounts',
      customersContactedToday: 'Contacted Today',
      customersNoCustomersFound: 'No customers found',
      customersImportCustomers: 'Import Customers',
      customersSelectMockCustomers: 'Select mock customers...',
      customersCancel: 'CANCEL',
      customersImportSelected: 'IMPORT SELECTED',
      customersExportingData: 'Exporting customer data...',
      customersExportedSuccess: 'Customer directory exported...',
      settingsSystemPreferences: 'System Preferences',
      settingsConfigureTheme: 'Configure interface theme settings.',
    ),
  };

  static AppStringsBundle get current =>
      _bundles[languageCode] ?? _bundles['en']!;

  static void useLanguage(String code) {
    languageCode = code;
  }

  static void registerBundle(String code, AppStringsBundle bundle) {
    _bundles[code] = bundle;
  }
}
