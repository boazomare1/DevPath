class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime? lastSyncAt;
  final Map<String, dynamic> preferences;
  final List<String> devices;
  final String? timezone;
  final String? language;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.lastSyncAt,
    this.preferences = const {},
    this.devices = const [],
    this.timezone,
    this.language,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastSyncAt,
    Map<String, dynamic>? preferences,
    List<String>? devices,
    String? timezone,
    String? language,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      preferences: preferences ?? this.preferences,
      devices: devices ?? this.devices,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'preferences': preferences,
      'devices': devices,
      'timezone': timezone,
      'language': language,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      lastSyncAt: json['lastSyncAt'] != null ? DateTime.parse(json['lastSyncAt']) : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      devices: List<String>.from(json['devices'] ?? []),
      timezone: json['timezone'],
      language: json['language'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, displayName: $displayName)';
  }
}