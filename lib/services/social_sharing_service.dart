import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/skill.dart';
import '../models/skill_status.dart';
import '../services/analytics_service.dart';
import '../services/enhanced_career_goals_service.dart';
import '../services/gamification_service.dart';

class ShareableProgress {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isPublic;
  final List<String> sharedWith; // Email addresses or user IDs
  final Map<String, dynamic> progressData;

  ShareableProgress({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.expiresAt,
    required this.isPublic,
    required this.sharedWith,
    required this.progressData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'progressData': progressData,
    };
  }

  factory ShareableProgress.fromJson(Map<String, dynamic> json) {
    return ShareableProgress(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isPublic: json['isPublic'],
      sharedWith: List<String>.from(json['sharedWith']),
      progressData: Map<String, dynamic>.from(json['progressData']),
    );
  }
}

class MentorInvitation {
  final String id;
  final String mentorEmail;
  final String mentorName;
  final String message;
  final String shareableLink;
  final DateTime sentAt;
  final bool isAccepted;
  final DateTime? acceptedAt;

  MentorInvitation({
    required this.id,
    required this.mentorEmail,
    required this.mentorName,
    required this.message,
    required this.shareableLink,
    required this.sentAt,
    this.isAccepted = false,
    this.acceptedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentorEmail': mentorEmail,
      'mentorName': mentorName,
      'message': message,
      'shareableLink': shareableLink,
      'sentAt': sentAt.toIso8601String(),
      'isAccepted': isAccepted,
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  factory MentorInvitation.fromJson(Map<String, dynamic> json) {
    return MentorInvitation(
      id: json['id'],
      mentorEmail: json['mentorEmail'],
      mentorName: json['mentorName'],
      message: json['message'],
      shareableLink: json['shareableLink'],
      sentAt: DateTime.parse(json['sentAt']),
      isAccepted: json['isAccepted'] ?? false,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
    );
  }
}

class CommunityUser {
  final String id;
  final String name;
  final String email;
  final int totalXP;
  final int level;
  final int badgesEarned;
  final int skillsCompleted;
  final String? profileImageUrl;
  final DateTime lastActive;
  final bool isPublic;

  CommunityUser({
    required this.id,
    required this.name,
    required this.email,
    required this.totalXP,
    required this.level,
    required this.badgesEarned,
    required this.skillsCompleted,
    this.profileImageUrl,
    required this.lastActive,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'totalXP': totalXP,
      'level': level,
      'badgesEarned': badgesEarned,
      'skillsCompleted': skillsCompleted,
      'profileImageUrl': profileImageUrl,
      'lastActive': lastActive.toIso8601String(),
      'isPublic': isPublic,
    };
  }

  factory CommunityUser.fromJson(Map<String, dynamic> json) {
    return CommunityUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      totalXP: json['totalXP'],
      level: json['level'],
      badgesEarned: json['badgesEarned'],
      skillsCompleted: json['skillsCompleted'],
      profileImageUrl: json['profileImageUrl'],
      lastActive: DateTime.parse(json['lastActive']),
      isPublic: json['isPublic'] ?? false,
    );
  }
}

class SocialSharingService extends ChangeNotifier {
  static const String _shareableProgressKey = 'shareable_progress';
  static const String _mentorInvitationsKey = 'mentor_invitations';
  static const String _communityUsersKey = 'community_users';
  static const String _baseUrl = 'https://devpath.app/share'; // Replace with actual domain

  final Uuid _uuid = const Uuid();

  List<ShareableProgress> _shareableProgress = [];
  List<MentorInvitation> _mentorInvitations = [];
  List<CommunityUser> _communityUsers = [];

  // Getters
  List<ShareableProgress> get shareableProgress => _shareableProgress;
  List<MentorInvitation> get mentorInvitations => _mentorInvitations;
  List<CommunityUser> get communityUsers => _communityUsers;

  /// Initialize the social sharing service
  Future<void> init() async {
    await _loadShareableProgress();
    await _loadMentorInvitations();
    await _loadCommunityUsers();
  }

  /// Load shareable progress from storage
  Future<void> _loadShareableProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_shareableProgressKey);
      if (progressJson != null) {
        final progressData = jsonDecode(progressJson) as List;
        _shareableProgress = progressData
            .map((progress) => ShareableProgress.fromJson(progress))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading shareable progress: $e');
    }
  }

  /// Load mentor invitations from storage
  Future<void> _loadMentorInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invitationsJson = prefs.getString(_mentorInvitationsKey);
      if (invitationsJson != null) {
        final invitationsData = jsonDecode(invitationsJson) as List;
        _mentorInvitations = invitationsData
            .map((invitation) => MentorInvitation.fromJson(invitation))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading mentor invitations: $e');
    }
  }

  /// Load community users from storage
  Future<void> _loadCommunityUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_communityUsersKey);
      if (usersJson != null) {
        final usersData = jsonDecode(usersJson) as List;
        _communityUsers = usersData
            .map((user) => CommunityUser.fromJson(user))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading community users: $e');
    }
  }

  /// Create a shareable progress link
  Future<String> createShareableProgress({
    required String title,
    required String description,
    required String userName,
    required bool isPublic,
    required List<String> sharedWith,
    required Map<String, dynamic> progressData,
    int expiresInDays = 30,
  }) async {
    final progressId = _uuid.v4();
    final shareableLink = '$_baseUrl/progress/$progressId';

    final progress = ShareableProgress(
      id: progressId,
      userId: 'current_user', // Replace with actual user ID
      userName: userName,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: expiresInDays)),
      isPublic: isPublic,
      sharedWith: sharedWith,
      progressData: progressData,
    );

    _shareableProgress.add(progress);
    await _saveShareableProgress();
    notifyListeners();

    return shareableLink;
  }

  /// Generate comprehensive progress data
  Future<Map<String, dynamic>> generateProgressData({
    required AnalyticsService analyticsService,
    required EnhancedCareerGoalsService careerGoalsService,
    required GamificationService gamificationService,
    required List<Skill> skills,
  }) async {
    final analyticsSummary = analyticsService.getAnalyticsSummary();
    final careerProgress = analyticsService.getCareerGoalsProgress();
    final weeklyActivity = analyticsService.getWeeklyLearningActivity();
    final skillTrends = analyticsService.getSkillCompletionTrends();
    final userStats = gamificationService.userStats;

    return {
      'summary': analyticsSummary,
      'careerGoals': careerProgress,
      'weeklyActivity': weeklyActivity,
      'skillTrends': skillTrends.take(7).toList(), // Last 7 days
      'skills': {
        'total': skills.length,
        'completed': skills.where((s) => s.status == SkillStatus.completed).length,
        'inProgress': skills.where((s) => s.status == SkillStatus.inProgress).length,
        'notStarted': skills.where((s) => s.status == SkillStatus.notStarted).length,
        'categories': _getSkillsByCategory(skills),
      },
      'gamification': {
        'totalXP': userStats.totalXP,
        'level': userStats.level,
        'badgesEarned': userStats.badgesEarned,
        'dailyStreak': userStats.dailyStreak,
        'weeklyStreak': userStats.weeklyStreak,
        'longestStreak': userStats.longestStreak,
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Export progress as PDF
  Future<String?> exportProgressAsPDF({
    required Map<String, dynamic> progressData,
    required String fileName,
  }) async {
    try {
      final pdf = await _generateProgressPDF(progressData);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdf);
      return file.path;
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      return null;
    }
  }

  /// Export progress as PNG (placeholder - would need proper screenshot implementation)
  Future<String?> exportProgressAsPNG({
    required String fileName,
  }) async {
    try {
      // For now, return null - would need proper screenshot implementation
      debugPrint('PNG export not implemented yet');
      return null;
    } catch (e) {
      debugPrint('Error exporting PNG: $e');
      return null;
    }
  }

  /// Share progress via native sharing
  Future<void> shareProgress({
    required String filePath,
    required String title,
    required String message,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: message,
        subject: title,
      );
    } catch (e) {
      debugPrint('Error sharing progress: $e');
    }
  }

  /// Invite mentor to view progress
  Future<String> inviteMentor({
    required String mentorEmail,
    required String mentorName,
    required String message,
    required String shareableLink,
  }) async {
    final invitationId = _uuid.v4();
    
    final invitation = MentorInvitation(
      id: invitationId,
      mentorEmail: mentorEmail,
      mentorName: mentorName,
      message: message,
      shareableLink: shareableLink,
      sentAt: DateTime.now(),
    );

    _mentorInvitations.add(invitation);
    await _saveMentorInvitations();
    notifyListeners();

    // In a real app, you would send an email here
    await _sendMentorInvitationEmail(invitation);

    return invitationId;
  }

  /// Get shareable progress by ID
  ShareableProgress? getShareableProgress(String id) {
    try {
      return _shareableProgress.firstWhere((progress) => progress.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get community leaderboard
  List<CommunityUser> getCommunityLeaderboard({int limit = 10}) {
    final sortedUsers = List<CommunityUser>.from(_communityUsers)
      ..sort((a, b) => b.totalXP.compareTo(a.totalXP));
    
    return sortedUsers.take(limit).toList();
  }

  /// Add user to community
  Future<void> addToCommunity({
    required String name,
    required String email,
    required int totalXP,
    required int level,
    required int badgesEarned,
    required int skillsCompleted,
    String? profileImageUrl,
    bool isPublic = false,
  }) async {
    final userId = _uuid.v4();
    
    final user = CommunityUser(
      id: userId,
      name: name,
      email: email,
      totalXP: totalXP,
      level: level,
      badgesEarned: badgesEarned,
      skillsCompleted: skillsCompleted,
      profileImageUrl: profileImageUrl,
      lastActive: DateTime.now(),
      isPublic: isPublic,
    );

    _communityUsers.add(user);
    await _saveCommunityUsers();
    notifyListeners();
  }

  /// Helper methods
  Map<String, int> _getSkillsByCategory(List<Skill> skills) {
    final categoryCount = <String, int>{};
    for (final skill in skills) {
      final category = skill.category.displayName;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount;
  }

  Future<Uint8List> _generateProgressPDF(Map<String, dynamic> progressData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Text(
              'DevPath Progress Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on ${DateTime.now().toString().split(' ')[0]}',
              style: pw.TextStyle(fontSize: 14),
            ),
          ];
        },
      ),
    );
    
    return pdf.save();
  }

  Widget _buildProgressScreenshot(GlobalKey key) {
    // This would build a widget for screenshot capture
    // For now, return a simple container
    return Container(
      key: key,
      width: 400,
      height: 600,
      color: Colors.white,
      child: const Center(
        child: Text('Progress Screenshot'),
      ),
    );
  }

  Future<void> _sendMentorInvitationEmail(MentorInvitation invitation) async {
    // In a real app, you would integrate with an email service
    debugPrint('Sending mentor invitation email to ${invitation.mentorEmail}');
    debugPrint('Link: ${invitation.shareableLink}');
    debugPrint('Message: ${invitation.message}');
  }

  /// Save methods
  Future<void> _saveShareableProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = _shareableProgress.map((progress) => progress.toJson()).toList();
      await prefs.setString(_shareableProgressKey, jsonEncode(progressJson));
    } catch (e) {
      debugPrint('Error saving shareable progress: $e');
    }
  }

  Future<void> _saveMentorInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invitationsJson = _mentorInvitations.map((invitation) => invitation.toJson()).toList();
      await prefs.setString(_mentorInvitationsKey, jsonEncode(invitationsJson));
    } catch (e) {
      debugPrint('Error saving mentor invitations: $e');
    }
  }

  Future<void> _saveCommunityUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = _communityUsers.map((user) => user.toJson()).toList();
      await prefs.setString(_communityUsersKey, jsonEncode(usersJson));
    } catch (e) {
      debugPrint('Error saving community users: $e');
    }
  }
}