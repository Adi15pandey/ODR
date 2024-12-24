class Case {
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
  final List<Award> awards;
  final String arbitratorId;
  final String arbitratorName;
  final String arbitratorEmail;
  final bool isFirstHearingDone;
  final bool isSecondHearingDone;
  final bool isMeetCompleted;
  final bool isAwardCompleted;
  final bool isCaseResolved;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isClickedForMultiple;

  Case({
    required this.id,
    this.isClickedForMultiple = false,
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

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['_id'] ?? '',
      caseId: json['caseId'] ?? '',
      isClickedForMultiple: json['isClickedForMultiple'] ?? false,
      clientName: json['clientName'] ?? '',
      clientId: json['clientId'] ?? '',
      clientEmail: json['clientEmail'] ?? '',
      clientAddress: json['clientAddress'] ?? '',
      clientMobile: json['clientMobile'] ?? '',
      respondentName: json['respondentName'] ?? '',
      respondentAddress: json['respondentAddress'] ?? '',
      respondentEmail: json['respondentEmail'] ?? '',
      respondentMobile: json['respondentMobile'] ?? '',
      amount: json['amount'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      cardNo: json['cardNo'] ?? '',
      disputeType: json['disputeType'] ?? '',
      isArbitratorAssigned: json['isArbitratorAssigned'] ?? false,
      isFileUpload: json['isFileUpload'] ?? false,
      fileName: json['fileName'] ?? '',
      attachments: json['attachments'] is List
          ? (json['attachments'] as List)
          .map((attachment) => Attachment.fromJson(attachment))
          .toList()
          : json['attachments'] is String
          ? [] // Handle the case where 'attachments' is a String (could be a URL or just a name)
          : [],
      meetings: json['meetings'] is List
          ? (json['meetings'] as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList()
          : json['meetings'] is String
          ? []
          : [],

      awards: json['awards'] is List
          ? (json['awards'] as List).map((award) {
        if (award is Map<String, dynamic>) {
          return Award.fromJson(award); // Handle as a Map and parse it
        } else if (award is String) {
          // Handle the case where the award is a string
          return Award(
            id: '',
            caseId: '',
            arbitratorId: '',
            title: award, // Treat the string as the title (or modify if it should be something else)
            description: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } else {

          return Award(
            id: '',
            caseId: '',
            arbitratorId: '',
            title: '',
            description: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }).toList()
          : json['awards'] is String
          ? [] // If 'awards' is just a string, return an empty list
          : [], // If 'awards' is neither a List nor String, return an empty list

      arbitratorId: json['arbitratorId'] ?? '',
      arbitratorName: json['arbitratorName'] ?? '',
      arbitratorEmail: json['arbitratorEmail'] ?? '',
      isFirstHearingDone: json['isFirstHearingDone'] ?? false,
      isSecondHearingDone: json['isSecondHearingDone'] ?? false,
      isMeetCompleted: json['isMeetCompleted'] ?? false,
      isAwardCompleted: json['isAwardCompleted'] ?? false,
      isCaseResolved: json['isCaseResolved'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
      name: json['name'] is String ? json['name'] : '',
      url: json['url'] is String ? json['url'] : '',
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
  final DateTime start;
  final DateTime end;
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
  final SimultaneousInterpretation simultaneousInterpretation;
  final bool enabledVisualWatermark;
  final bool enabledBreakoutSessions;
  final List<Link> links;
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
    required this.simultaneousInterpretation,
    required this.enabledVisualWatermark,
    required this.enabledBreakoutSessions,
    required this.links,
    required this.audioConnectionOptions,
    required this.enabledLiveStream,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] ?? '',
      meetingNumber: json['meetingNumber'] ?? '',
      title: json['title'] ?? '',
      password: json['password'] ?? '',
      phoneAndVideoSystemPassword: json['phoneAndVideoSystemPassword'] ?? '',
      meetingType: json['meetingType'] ?? '',
      state: json['state'] ?? '',
      timezone: json['timezone'] ?? '',
      start: DateTime.tryParse(json['start'] ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end'] ?? '') ?? DateTime.now(),
      hostUserId: json['hostUserId'] ?? '',
      hostDisplayName: json['hostDisplayName'] ?? '',
      hostEmail: json['hostEmail'] ?? '',
      hostKey: json['hostKey'] ?? '',
      siteUrl: json['siteUrl'] ?? '',
      webLink: json['webLink'] ?? '',
      sipAddress: json['sipAddress'] ?? '',
      dialInIpAddress: json['dialInIpAddress'] ?? '',
      enabledAutoRecordMeeting: json['enabledAutoRecordMeeting'] ?? false,
      allowAnyUserToBeCoHost: json['allowAnyUserToBeCoHost'] ?? false,
      allowFirstUserToBeCoHost: json['allowFirstUserToBeCoHost'] ?? false,
      allowAuthenticatedDevices: json['allowAuthenticatedDevices'] ?? false,
      enabledJoinBeforeHost: json['enabledJoinBeforeHost'] ?? false,
      joinBeforeHostMinutes: json['joinBeforeHostMinutes'] ?? 0,
      enableConnectAudioBeforeHost: json['enableConnectAudioBeforeHost'] ?? false,
      excludePassword: json['excludePassword'] ?? false,
      publicMeeting: json['publicMeeting'] ?? false,
      enableAutomaticLock: json['enableAutomaticLock'] ?? false,
      automaticLockMinutes: json['automaticLockMinutes'] ?? 0,
      unlockedMeetingJoinSecurity: json['unlockedMeetingJoinSecurity'] ?? '',
      telephony: Telephony.fromJson(json['telephony'] ?? {}),
      meetingOptions: MeetingOptions.fromJson(json['meetingOptions'] ?? {}),
      attendeePrivileges: AttendeePrivileges.fromJson(json['attendeePrivileges'] ?? {}),
      sessionTypeId: json['sessionTypeId'] ?? 0,
      scheduledType: json['scheduledType'] ?? '',
      simultaneousInterpretation: SimultaneousInterpretation.fromJson(json['simultaneousInterpretation'] ?? {}),
      enabledVisualWatermark: json['enabledVisualWatermark'] ?? false,
      enabledBreakoutSessions: json['enabledBreakoutSessions'] ?? false,
      links: (json['links'] as List)
          .map((link) => Link.fromJson(link))
          .toList(),
      audioConnectionOptions: AudioConnectionOptions.fromJson(json['audioConnectionOptions'] ?? {}),
      enabledLiveStream: json['enabledLiveStream'] ?? false,
    );
  }
}


class Telephony {
  // Add fields and constructor
  Telephony.fromJson(Map<String, dynamic> json) {
    // Parse fields from JSON
  }
}

class MeetingOptions {
  // Add fields and constructor
  MeetingOptions.fromJson(Map<String, dynamic> json) {
    // Parse fields from JSON
  }
}

class AttendeePrivileges {
  // Add fields and constructor
  AttendeePrivileges.fromJson(Map<String, dynamic> json) {
    // Parse fields from JSON
  }
}

class SimultaneousInterpretation {
  // Add fields and constructor
  SimultaneousInterpretation.fromJson(Map<String, dynamic> json) {
    // Parse fields from JSON
  }
}

class Link {
  // Add fields and constructor
  Link.fromJson(Map<String, dynamic> json) {
    // Parse fields from JSON
  }
}

class AudioConnectionOptions {
  // Add fields and constructor
  AudioConnectionOptions.fromJson(Map<String, dynamic> json) {
    // Parse fields from JSON
  }
}
class Award {
  final String id;
  final String caseId;
  final String arbitratorId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  Award({
    required this.id,
    required this.caseId,
    required this.arbitratorId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method for JSON deserialization
  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: json['_id'] ?? '', // Default to empty string if null
      caseId: json['caseId'] ?? '', // Default to empty string if null
      arbitratorId: json['arbitratorId'] ?? '', // Default to empty string if null
      title: json['title'] ?? '', // Default to empty string if null
      description: json['description'] ?? '', // Default to empty string if null
      createdAt: _parseDateTime(json['createdAt']), // Safe date parsing
      updatedAt: _parseDateTime(json['updatedAt']), // Safe date parsing
    );
  }

  // Helper method for safe DateTime parsing
  static DateTime _parseDateTime(String? dateTime) {
    if (dateTime == null) return DateTime.now(); // Fallback to current time
    return DateTime.tryParse(dateTime) ?? DateTime.now(); // Safe parsing
  }

  // Method to convert Award to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'caseId': caseId,
      'arbitratorId': arbitratorId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Override toString for better debug information
  @override
  String toString() {
    return 'Award(id: $id, caseId: $caseId, arbitratorId: $arbitratorId, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

