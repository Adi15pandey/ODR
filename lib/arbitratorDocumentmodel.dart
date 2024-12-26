class CaseData {
  final String id;
  final String caseId;
  final String clientName;
  final String clientId;
  final String clientEmail;
  final String clientAddress;
  final String clientMobile;
  final String respondentName;
  final String respondentAddress;
  final String respondentEmail;
  final String respondentMobile;
  final String amount;
  final String accountNumber;
  final String cardNo;
  final String disputeType;
  final bool isArbitratorAssigned;
  final bool isFileUpload;
  final String fileName;
  final List<Attachment> attachments;
  final List<Meeting> meetings;
  final List<dynamic> recordings;
  final List<dynamic> orderSheet;
  final List<String> awards;
  final String arbitratorId;
  final String arbitratorName;
  final String arbitratorEmail;
  final bool isFirstHearingDone;
  final bool isSecondHearingDone;
  final bool isMeetCompleted;
  final bool isAwardCompleted;
  final bool isCaseResolved;
  final String createdAt;
  final String updatedAt;

  CaseData({
    required this.id,
    required this.caseId,
    required this.clientName,
    required this.clientId,
    required this.clientEmail,
    required this.clientAddress,
    required this.clientMobile,
    required this.respondentName,
    required this.respondentAddress,
    required this.respondentEmail,
    required this.respondentMobile,
    required this.amount,
    required this.accountNumber,
    required this.cardNo,
    required this.disputeType,
    required this.isArbitratorAssigned,
    required this.isFileUpload,
    required this.fileName,
    required this.attachments,
    required this.meetings,
    required this.recordings,
    required this.orderSheet,
    required this.awards,
    required this.arbitratorId,
    required this.arbitratorName,
    required this.arbitratorEmail,
    required this.isFirstHearingDone,
    required this.isSecondHearingDone,
    required this.isMeetCompleted,
    required this.isAwardCompleted,
    required this.isCaseResolved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CaseData.fromJson(Map<String, dynamic> json) {
    var listAttachments = json['attachments'] as List;
    var listMeetings = json['meetings'] as List;
    var listAwards = json['awards'] as List;
    var listRecordings = json['recordings'] as List;
    var listOrderSheet = json['orderSheet'] as List;

    return CaseData(
      id: json['_id'],
      caseId: json['caseId'],
      clientName: json['clientName'],
      clientId: json['clientId'],
      clientEmail: json['clientEmail'],
      clientAddress: json['clientAddress'],
      clientMobile: json['clientMobile'],
      respondentName: json['respondentName'],
      respondentAddress: json['respondentAddress'],
      respondentEmail: json['respondentEmail'],
      respondentMobile: json['respondentMobile'],
      amount: json['amount'],
      accountNumber: json['accountNumber'],
      cardNo: json['cardNo'],
      disputeType: json['disputeType'],
      isArbitratorAssigned: json['isArbitratorAssigned'],
      isFileUpload: json['isFileUpload'],
      fileName: json['fileName'],
      attachments: listAttachments.map((item) => Attachment.fromJson(item)).toList(),
      meetings: listMeetings.map((item) => Meeting.fromJson(item)).toList(),
      recordings: listRecordings,
      orderSheet: listOrderSheet,
      awards: List<String>.from(listAwards),
      arbitratorId: json['arbitratorId'],
      arbitratorName: json['arbitratorName'],
      arbitratorEmail: json['arbitratorEmail'],
      isFirstHearingDone: json['isFirstHearingDone'],
      isSecondHearingDone: json['isSecondHearingDone'],
      isMeetCompleted: json['isMeetCompleted'],
      isAwardCompleted: json['isAwardCompleted'],
      isCaseResolved: json['isCaseResolved'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Attachment {
  final String name;
  final String url;

  Attachment({
    required this.name,
    required this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['name'],
      url: json['url'],
    );
  }
}

class Meeting {
  final String id;
  final String meetingNumber;
  final String title;
  final String password;
  final String phoneAndVideoSystemPassword;
  final String meetingType;
  final String state;
  final String timezone;
  final String start;
  final String end;
  final String hostUserId;
  final String hostDisplayName;
  final String hostEmail;
  final String hostKey;
  final String siteUrl;
  final String webLink;
  final String sipAddress;
  final String dialInIpAddress;
  final bool enabledAutoRecordMeeting;
  final bool allowAnyUserToBeCoHost;
  final bool allowFirstUserToBeCoHost;
  final bool allowAuthenticatedDevices;
  final bool enabledJoinBeforeHost;
  final int joinBeforeHostMinutes;
  final bool enableConnectAudioBeforeHost;
  final bool excludePassword;
  final bool publicMeeting;
  final bool enableAutomaticLock;
  final int automaticLockMinutes;
  final String unlockedMeetingJoinSecurity;
  final Telephony telephony;
  final MeetingOptions meetingOptions;
  final AttendeePrivileges attendeePrivileges;
  final int sessionTypeId;
  final String scheduledType;
  final bool simultaneousInterpretationEnabled;
  final bool enabledVisualWatermark;
  final bool enabledBreakoutSessions;
  final AudioConnectionOptions audioConnectionOptions;
  final bool enabledLiveStream;

  Meeting({
    required this.id,
    required this.meetingNumber,
    required this.title,
    required this.password,
    required this.phoneAndVideoSystemPassword,
    required this.meetingType,
    required this.state,
    required this.timezone,
    required this.start,
    required this.end,
    required this.hostUserId,
    required this.hostDisplayName,
    required this.hostEmail,
    required this.hostKey,
    required this.siteUrl,
    required this.webLink,
    required this.sipAddress,
    required this.dialInIpAddress,
    required this.enabledAutoRecordMeeting,
    required this.allowAnyUserToBeCoHost,
    required this.allowFirstUserToBeCoHost,
    required this.allowAuthenticatedDevices,
    required this.enabledJoinBeforeHost,
    required this.joinBeforeHostMinutes,
    required this.enableConnectAudioBeforeHost,
    required this.excludePassword,
    required this.publicMeeting,
    required this.enableAutomaticLock,
    required this.automaticLockMinutes,
    required this.unlockedMeetingJoinSecurity,
    required this.telephony,
    required this.meetingOptions,
    required this.attendeePrivileges,
    required this.sessionTypeId,
    required this.scheduledType,
    required this.simultaneousInterpretationEnabled,
    required this.enabledVisualWatermark,
    required this.enabledBreakoutSessions,
    required this.audioConnectionOptions,
    required this.enabledLiveStream,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      meetingNumber: json['meetingNumber'],
      title: json['title'],
      password: json['password'],
      phoneAndVideoSystemPassword: json['phoneAndVideoSystemPassword'],
      meetingType: json['meetingType'],
      state: json['state'],
      timezone: json['timezone'],
      start: json['start'],
      end: json['end'],
      hostUserId: json['hostUserId'],
      hostDisplayName: json['hostDisplayName'],
      hostEmail: json['hostEmail'],
      hostKey: json['hostKey'],
      siteUrl: json['siteUrl'],
      webLink: json['webLink'],
      sipAddress: json['sipAddress'],
      dialInIpAddress: json['dialInIpAddress'],
      enabledAutoRecordMeeting: json['enabledAutoRecordMeeting'],
      allowAnyUserToBeCoHost: json['allowAnyUserToBeCoHost'],
      allowFirstUserToBeCoHost: json['allowFirstUserToBeCoHost'],
      allowAuthenticatedDevices: json['allowAuthenticatedDevices'],
      enabledJoinBeforeHost: json['enabledJoinBeforeHost'],
      joinBeforeHostMinutes: json['joinBeforeHostMinutes'],
      enableConnectAudioBeforeHost: json['enableConnectAudioBeforeHost'],
      excludePassword: json['excludePassword'],
      publicMeeting: json['publicMeeting'],
      enableAutomaticLock: json['enableAutomaticLock'],
      automaticLockMinutes: json['automaticLockMinutes'],
      unlockedMeetingJoinSecurity: json['unlockedMeetingJoinSecurity'],
      telephony: Telephony.fromJson(json['telephony']),
      meetingOptions: MeetingOptions.fromJson(json['meetingOptions']),
      attendeePrivileges: AttendeePrivileges.fromJson(json['attendeePrivileges']),
      sessionTypeId: json['sessionTypeId'],
      scheduledType: json['scheduledType'],
      simultaneousInterpretationEnabled: json['simultaneousInterpretation']['enabled'],
      enabledVisualWatermark: json['enabledVisualWatermark'],
      enabledBreakoutSessions: json['enabledBreakoutSessions'],
      audioConnectionOptions: AudioConnectionOptions.fromJson(json['audioConnectionOptions']),
      enabledLiveStream: json['enabledLiveStream'],
    );
  }
}

class Telephony {
  final String accessCode;
  final List<CallInNumber> callInNumbers;

  Telephony({
    required this.accessCode,
    required this.callInNumbers,
  });

  factory Telephony.fromJson(Map<String, dynamic> json) {
    var list = json['callInNumbers'] as List;
    return Telephony(
      accessCode: json['accessCode'],
      callInNumbers: list.map((item) => CallInNumber.fromJson(item)).toList(),
    );
  }
}

class CallInNumber {
  final String label;
  final String callInNumber;
  final String tollType;

  CallInNumber({
    required this.label,
    required this.callInNumber,
    required this.tollType,
  });

  factory CallInNumber.fromJson(Map<String, dynamic> json) {
    return CallInNumber(
      label: json['label'],
      callInNumber: json['callInNumber'],
      tollType: json['tollType'],
    );
  }
}

class MeetingOptions {
  final bool enableJoinBeforeHost;
  final int joinBeforeHostMinutes;

  MeetingOptions({
    required this.enableJoinBeforeHost,
    required this.joinBeforeHostMinutes,
  });

  factory MeetingOptions.fromJson(Map<String, dynamic> json) {
    return MeetingOptions(
      enableJoinBeforeHost: json['enableJoinBeforeHost'],
      joinBeforeHostMinutes: json['joinBeforeHostMinutes'],
    );
  }
}

class AttendeePrivileges {
  final bool canUnmute;
  final bool canShareAudio;
  final bool canShareVideo;
  final bool canShareScreen;
  final bool canShareWhiteboard;
  final bool canRaiseHand;

  AttendeePrivileges({
    required this.canUnmute,
    required this.canShareAudio,
    required this.canShareVideo,
    required this.canShareScreen,
    required this.canShareWhiteboard,
    required this.canRaiseHand,
  });

  factory AttendeePrivileges.fromJson(Map<String, dynamic> json) {
    return AttendeePrivileges(
      canUnmute: json['canUnmute'],
      canShareAudio: json['canShareAudio'],
      canShareVideo: json['canShareVideo'],
      canShareScreen: json['canShareScreen'],
      canShareWhiteboard: json['canShareWhiteboard'],
      canRaiseHand: json['canRaiseHand'],
    );
  }
}

class AudioConnectionOptions {
  final bool allowJoinByAudioOnly;
  final bool allowJoinByVideoOnly;

  AudioConnectionOptions({
    required this.allowJoinByAudioOnly,
    required this.allowJoinByVideoOnly,
  });

  factory AudioConnectionOptions.fromJson(Map<String, dynamic> json) {
    return AudioConnectionOptions(
      allowJoinByAudioOnly: json['allowJoinByAudioOnly'],
      allowJoinByVideoOnly: json['allowJoinByVideoOnly'],
    );
  }
}
