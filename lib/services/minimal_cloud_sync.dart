import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MinimalCloudSync extends ChangeNotifier {
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

  MinimalCloudSync() {
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
      // Get local skills from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final localSkillsJson = prefs.getString('skills') ?? '[]';
      final localSkills = jsonDecode(localSkillsJson) as List;
      
      // Get cloud skills
      final skillsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .get();

      final cloudSkills = skillsSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Merge and resolve conflicts
      final mergedSkills = _mergeSkills(localSkills, cloudSkills);
      
      // Update local storage
      await prefs.setString('skills', jsonEncode(mergedSkills));
      
      // Update cloud storage
      final batch = _firestore.batch();
      for (final skill in mergedSkills) {
        final skillMap = skill as Map<String, dynamic>;
        final skillRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('skills')
            .doc(skillMap['id']);
        batch.set(skillRef, skillMap);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Sync skills error: $e');
    }
  }

  /// Sync GitHub data
  Future<void> _syncGitHubData(String userId) async {
    try {
      // Get local GitHub data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final localReposJson = prefs.getString('repositories') ?? '[]';
      final localRepos = jsonDecode(localReposJson) as List;
      
      // Get cloud GitHub data
      final reposSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('repositories')
          .get();

      final cloudRepos = reposSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Merge repositories
      final mergedRepos = _mergeRepositories(localRepos, cloudRepos);
      
      // Update local storage
      await prefs.setString('repositories', jsonEncode(mergedRepos));
      
      // Update cloud storage
      final batch = _firestore.batch();
      for (final repo in mergedRepos) {
        final repoMap = repo as Map<String, dynamic>;
        final repoRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('repositories')
            .doc(repoMap['id'].toString());
        batch.set(repoRef, repoMap);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Sync GitHub data error: $e');
    }
  }

  /// Merge skills with conflict resolution
  List<Map<String, dynamic>> _mergeSkills(List<dynamic> localSkills, List<Map<String, dynamic>> cloudSkills) {
    final Map<String, Map<String, dynamic>> skillMap = {};
    
    // Add local skills
    for (final skill in localSkills) {
      final skillMap = skill as Map<String, dynamic>;
      skillMap[skillMap['id']] = skillMap;
    }
    
    // Merge cloud skills
    for (final skill in cloudSkills) {
      if (skillMap.containsKey(skill['id'])) {
        // Resolve conflict - use the most recently updated
        final localSkill = skillMap[skill['id']]!;
        final localUpdated = DateTime.tryParse(localSkill['updatedAt'] ?? '') ?? DateTime(1970);
        final cloudUpdated = DateTime.tryParse(skill['updatedAt'] ?? '') ?? DateTime(1970);
        
        if (cloudUpdated.isAfter(localUpdated)) {
          skillMap[skill['id']] = skill;
        }
      } else {
        skillMap[skill['id']] = skill;
      }
    }
    
    return skillMap.values.toList();
  }

  /// Merge repositories with conflict resolution
  List<Map<String, dynamic>> _mergeRepositories(
    List<dynamic> localRepos,
    List<Map<String, dynamic>> cloudRepos,
  ) {
    final Map<String, Map<String, dynamic>> repoMap = {};
    
    // Add local repositories
    for (final repo in localRepos) {
      final repoMap = repo as Map<String, dynamic>;
      repoMap[repoMap['id'].toString()] = repoMap;
    }
    
    // Merge cloud repositories
    for (final repo in cloudRepos) {
      final repoId = repo['id'].toString();
      if (repoMap.containsKey(repoId)) {
        // Resolve conflict - use the most recently updated
        final localRepo = repoMap[repoId]!;
        final localUpdated = DateTime.tryParse(localRepo['updatedAt'] ?? '') ?? DateTime(1970);
        final cloudUpdated = DateTime.tryParse(repo['updatedAt'] ?? '') ?? DateTime(1970);
        
        if (cloudUpdated.isAfter(localUpdated)) {
          repoMap[repoId] = repo;
        }
      } else {
        repoMap[repoId] = repo;
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
    final prefs = await SharedPreferences.getInstance();
    final skillsJson = prefs.getString('skills') ?? '[]';
    final skills = jsonDecode(skillsJson) as List;
    
    final batch = _firestore.batch();
    for (final skill in skills) {
      final skillMap = skill as Map<String, dynamic>;
      final skillRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skillMap['id']);
      batch.set(skillRef, skillMap);
    }
    await batch.commit();
  }

  /// Upload repositories to cloud
  Future<void> _uploadRepositories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final reposJson = prefs.getString('repositories') ?? '[]';
    final repos = jsonDecode(reposJson) as List;
    
    final batch = _firestore.batch();
    for (final repo in repos) {
      final repoMap = repo as Map<String, dynamic>;
      final repoRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('repositories')
          .doc(repoMap['id'].toString());
      batch.set(repoRef, repoMap);
    }
    await batch.commit();
  }

  /// Download skills from cloud
  Future<void> _downloadSkills(String userId) async {
    final skillsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .get();

    final skills = skillsSnapshot.docs.map((doc) => doc.data()).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skills', jsonEncode(skills));
  }

  /// Download repositories from cloud
  Future<void> _downloadRepositories(String userId) async {
    final reposSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('repositories')
        .get();

    final repos = reposSnapshot.docs.map((doc) => doc.data()).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('repositories', jsonEncode(repos));
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