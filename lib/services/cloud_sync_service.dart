import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';
import '../models/github_user.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class CloudSyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();
  
  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  CloudSyncService() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _isOnline = result != ConnectivityResult.none;
        notifyListeners();
        
        if (_isOnline) {
          _syncData();
        }
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Initialize cloud sync
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;
      
      if (_isOnline) {
        await _syncData();
      }
    } catch (e) {
      debugPrint('Cloud sync initialization error: $e');
    }
  }

  /// Sync all data with cloud
  Future<void> _syncData() async {
    if (!_isOnline || _isSyncing) return;
    
    try {
      _isSyncing = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return;

      // Sync skills
      await _syncSkills(user.uid);
      
      // Sync GitHub data
      await _syncGitHubData(user.uid);
      
      // Sync user profile
      await _syncUserProfile(user.uid);
      
      // Sync analytics data
      await _syncAnalyticsData(user.uid);
      
      // Sync gamification data
      await _syncGamificationData(user.uid);
      
      // Sync career goals
      await _syncCareerGoals(user.uid);
      
      // Sync social sharing data
      await _syncSocialSharingData(user.uid);

      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Cloud sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync skills data
  Future<void> _syncSkills(String userId) async {
    try {
      // Get local skills
      final localSkills = StorageService.getAllSkills();
      
      // Get cloud skills
      final skillsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .get();

      final cloudSkills = skillsSnapshot.docs
          .map((doc) => Skill.fromJson(doc.data()))
          .toList();

      // Merge and resolve conflicts
      final mergedSkills = _mergeSkills(localSkills, cloudSkills);
      
      // Update local storage
      for (final skill in mergedSkills) {
        await StorageService.updateSkill(skill);
      }
      
      // Update cloud storage
      final batch = _firestore.batch();
      for (final skill in mergedSkills) {
        final skillRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('skills')
            .doc(skill.id);
        batch.set(skillRef, skill.toJson());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Sync skills error: $e');
    }
  }

  /// Sync GitHub data
  Future<void> _syncGitHubData(String userId) async {
    try {
      // Get local GitHub data
      final localRepos = StorageService.getAllRepositories();
      final localUser = StorageService.getCurrentUser();
      
      // Get cloud GitHub data
      final reposSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('repositories')
          .get();

      final cloudRepos = reposSnapshot.docs
          .map((doc) => GitHubRepository.fromJson(doc.data()))
          .toList();

      // Merge repositories
      final mergedRepos = _mergeRepositories(localRepos, cloudRepos);
      
      // Update local storage
      for (final repo in mergedRepos) {
        await StorageService.updateRepository(repo);
      }
      
      // Update cloud storage
      final batch = _firestore.batch();
      for (final repo in mergedRepos) {
        final repoRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('repositories')
            .doc(repo.id.toString());
        batch.set(repoRef, repo.toJson());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Sync GitHub data error: $e');
    }
  }

  /// Sync user profile
  Future<void> _syncUserProfile(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final cloudProfile = UserProfile.fromJson(userDoc.data()!);
        // Update local profile if needed
        // This would integrate with your user profile service
      }
    } catch (e) {
      debugPrint('Sync user profile error: $e');
    }
  }

  /// Sync analytics data
  Future<void> _syncAnalyticsData(String userId) async {
    try {
      // This would sync analytics data
      // Implementation depends on your analytics service structure
    } catch (e) {
      debugPrint('Sync analytics data error: $e');
    }
  }

  /// Sync gamification data
  Future<void> _syncGamificationData(String userId) async {
    try {
      // This would sync gamification data
      // Implementation depends on your gamification service structure
    } catch (e) {
      debugPrint('Sync gamification data error: $e');
    }
  }

  /// Sync career goals
  Future<void> _syncCareerGoals(String userId) async {
    try {
      // This would sync career goals data
      // Implementation depends on your career goals service structure
    } catch (e) {
      debugPrint('Sync career goals error: $e');
    }
  }

  /// Sync social sharing data
  Future<void> _syncSocialSharingData(String userId) async {
    try {
      // This would sync social sharing data
      // Implementation depends on your social sharing service structure
    } catch (e) {
      debugPrint('Sync social sharing data error: $e');
    }
  }

  /// Merge skills with conflict resolution
  List<Skill> _mergeSkills(List<Skill> localSkills, List<Skill> cloudSkills) {
    final Map<String, Skill> skillMap = {};
    
    // Add local skills
    for (final skill in localSkills) {
      skillMap[skill.id] = skill;
    }
    
    // Merge cloud skills
    for (final skill in cloudSkills) {
      if (skillMap.containsKey(skill.id)) {
        // Resolve conflict - use the most recently updated
        final localSkill = skillMap[skill.id]!;
        if (skill.updatedAt.isAfter(localSkill.updatedAt)) {
          skillMap[skill.id] = skill;
        }
      } else {
        skillMap[skill.id] = skill;
      }
    }
    
    return skillMap.values.toList();
  }

  /// Merge repositories with conflict resolution
  List<GitHubRepository> _mergeRepositories(
    List<GitHubRepository> localRepos,
    List<GitHubRepository> cloudRepos,
  ) {
    final Map<int, GitHubRepository> repoMap = {};
    
    // Add local repositories
    for (final repo in localRepos) {
      repoMap[repo.id] = repo;
    }
    
    // Merge cloud repositories
    for (final repo in cloudRepos) {
      if (repoMap.containsKey(repo.id)) {
        // Resolve conflict - use the most recently updated
        final localRepo = repoMap[repo.id]!;
        if (repo.updatedAt.isAfter(localRepo.updatedAt)) {
          repoMap[repo.id] = repo;
        }
      } else {
        repoMap[repo.id] = repo;
      }
    }
    
    return repoMap.values.toList();
  }

  /// Force sync all data
  Future<void> forceSync() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    await _syncData();
  }

  /// Upload local data to cloud
  Future<void> uploadToCloud() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isSyncing = true;
      notifyListeners();

      // Upload all local data
      await _uploadSkills(user.uid);
      await _uploadRepositories(user.uid);
      await _uploadUserProfile(user.uid);
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Upload to cloud error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Download cloud data to local
  Future<void> downloadFromCloud() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isSyncing = true;
      notifyListeners();

      // Download all cloud data
      await _downloadSkills(user.uid);
      await _downloadRepositories(user.uid);
      await _downloadUserProfile(user.uid);
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Download from cloud error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Upload skills to cloud
  Future<void> _uploadSkills(String userId) async {
    final skills = StorageService.getAllSkills();
    final batch = _firestore.batch();
    
    for (final skill in skills) {
      final skillRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skill.id);
      batch.set(skillRef, skill.toJson());
    }
    
    await batch.commit();
  }

  /// Upload repositories to cloud
  Future<void> _uploadRepositories(String userId) async {
    final repos = StorageService.getAllRepositories();
    final batch = _firestore.batch();
    
    for (final repo in repos) {
      final repoRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('repositories')
          .doc(repo.id.toString());
      batch.set(repoRef, repo.toJson());
    }
    
    await batch.commit();
  }

  /// Upload user profile to cloud
  Future<void> _uploadUserProfile(String userId) async {
    // This would upload user profile data
    // Implementation depends on your user profile service
  }

  /// Download skills from cloud
  Future<void> _downloadSkills(String userId) async {
    final skillsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .get();

    for (final doc in skillsSnapshot.docs) {
      final skill = Skill.fromJson(doc.data());
      await StorageService.updateSkill(skill);
    }
  }

  /// Download repositories from cloud
  Future<void> _downloadRepositories(String userId) async {
    final reposSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('repositories')
        .get();

    for (final doc in reposSnapshot.docs) {
      final repo = GitHubRepository.fromJson(doc.data());
      await StorageService.updateRepository(repo);
    }
  }

  /// Download user profile from cloud
  Future<void> _downloadUserProfile(String userId) async {
    // This would download user profile data
    // Implementation depends on your user profile service
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
    };
  }
}