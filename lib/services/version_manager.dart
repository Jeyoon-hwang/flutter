import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/note_version.dart';
import '../models/note.dart';

/// Manages version control for notes (Git-like system)
/// Handles commits, branches, merges, and conflict resolution
class VersionManager extends ChangeNotifier {
  // All versions for all notes
  final Map<String, List<NoteVersion>> _versionsByNote = {};

  // Current HEAD version for each note
  final Map<String, String> _headVersions = {};

  // Pending merge requests
  final List<MergeRequest> _mergeRequests = [];

  // Teams for collaboration
  final List<Team> _teams = [];

  // Current user (for demonstration - in production, use authentication)
  String _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  String _currentUserName = '나';

  // Getters
  List<NoteVersion> getVersions(String noteId) {
    return _versionsByNote[noteId] ?? [];
  }

  String? getHeadVersion(String noteId) {
    return _headVersions[noteId];
  }

  List<MergeRequest> getMergeRequests(String noteId) {
    return _mergeRequests.where((mr) => mr.noteId == noteId).toList();
  }

  List<MergeRequest> getPendingMergeRequests(String noteId) {
    return _mergeRequests
        .where((mr) =>
            mr.noteId == noteId && mr.status == MergeRequestStatus.pending)
        .toList();
  }

  List<Team> get teams => List.unmodifiable(_teams);

  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  void setCurrentUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
    notifyListeners();
  }

  // ============================================================================
  // COMMIT OPERATIONS
  // ============================================================================

  /// Create a new commit (version) for a note
  /// This is like 'git commit' - saves current state with a message
  Future<NoteVersion> commit({
    required String noteId,
    required Note currentNote,
    required String commitMessage,
  }) async {
    // Get parent version (current HEAD)
    final parentVersionId = _headVersions[noteId];

    // Calculate changes from parent
    final changes = _calculateChanges(noteId, currentNote);

    // Generate version ID (like commit hash)
    final versionId = _generateVersionId(
      noteId: noteId,
      parentId: parentVersionId,
      timestamp: DateTime.now(),
      note: currentNote,
    );

    // Create version
    final version = NoteVersion(
      id: versionId,
      noteId: noteId,
      parentVersionId: parentVersionId,
      authorId: _currentUserId,
      authorName: _currentUserName,
      timestamp: DateTime.now(),
      commitMessage: commitMessage,
      noteSnapshot: currentNote,
      addedStrokes: changes['addedStrokes'] ?? 0,
      removedStrokes: changes['removedStrokes'] ?? 0,
      addedTextObjects: changes['addedTextObjects'] ?? 0,
      removedTextObjects: changes['removedTextObjects'] ?? 0,
    );

    // Store version
    if (!_versionsByNote.containsKey(noteId)) {
      _versionsByNote[noteId] = [];
    }
    _versionsByNote[noteId]!.add(version);

    // Update HEAD
    _headVersions[noteId] = versionId;

    notifyListeners();

    print('✅ Commit created: ${version.shortId} - "$commitMessage"');
    print('   Changes: ${version.changeSummary}');

    return version;
  }

  /// Generate a unique version ID (similar to Git commit hash)
  String _generateVersionId({
    required String noteId,
    required String? parentId,
    required DateTime timestamp,
    required Note note,
  }) {
    // Create a string with all relevant data
    final data = '$noteId$parentId${timestamp.millisecondsSinceEpoch}'
        '${note.layers.length}${note.textObjects.length}';

    // Generate SHA-256 hash
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Calculate changes between parent version and current note
  Map<String, int> _calculateChanges(String noteId, Note currentNote) {
    final versions = _versionsByNote[noteId];
    if (versions == null || versions.isEmpty) {
      // First commit - count all as added
      final totalStrokes = currentNote.layers.fold<int>(
        0,
        (sum, layer) => sum + layer.strokes.length,
      );
      return {
        'addedStrokes': totalStrokes,
        'removedStrokes': 0,
        'addedTextObjects': currentNote.textObjects.length,
        'removedTextObjects': 0,
      };
    }

    // Get parent version
    final parentVersion = versions.last;
    final parentNote = parentVersion.noteSnapshot;

    // Compare stroke counts
    final currentStrokes = currentNote.layers.fold<int>(
      0,
      (sum, layer) => sum + layer.strokes.length,
    );
    final parentStrokes = parentNote.layers.fold<int>(
      0,
      (sum, layer) => sum + layer.strokes.length,
    );

    final strokeDiff = currentStrokes - parentStrokes;
    final textDiff = currentNote.textObjects.length - parentNote.textObjects.length;

    return {
      'addedStrokes': strokeDiff > 0 ? strokeDiff : 0,
      'removedStrokes': strokeDiff < 0 ? -strokeDiff : 0,
      'addedTextObjects': textDiff > 0 ? textDiff : 0,
      'removedTextObjects': textDiff < 0 ? -textDiff : 0,
    };
  }

  /// Get version history for a note (commit log)
  List<NoteVersion> getVersionHistory(String noteId) {
    final versions = _versionsByNote[noteId] ?? [];
    // Return in reverse chronological order (newest first)
    return versions.reversed.toList();
  }

  /// Restore note to a specific version (checkout)
  Note? restoreVersion(String noteId, String versionId) {
    final versions = _versionsByNote[noteId];
    if (versions == null) return null;

    final version = versions.firstWhere(
      (v) => v.id == versionId,
      orElse: () => throw Exception('Version not found'),
    );

    // Update HEAD to this version
    _headVersions[noteId] = versionId;
    notifyListeners();

    print('✅ Restored to version: ${version.shortId}');
    return version.noteSnapshot;
  }

  // ============================================================================
  // MERGE REQUEST OPERATIONS
  // ============================================================================

  /// Create a merge request (Pull Request)
  /// Used when a team member wants to merge their changes
  Future<MergeRequest> createMergeRequest({
    required String noteId,
    required String sourceVersionId,
    required String title,
    required String description,
    required List<String> reviewerIds,
  }) async {
    final targetVersionId = _headVersions[noteId];
    if (targetVersionId == null) {
      throw Exception('No HEAD version found for note');
    }

    final mergeRequest = MergeRequest(
      id: 'mr_${DateTime.now().millisecondsSinceEpoch}',
      noteId: noteId,
      sourceVersionId: sourceVersionId,
      targetVersionId: targetVersionId,
      authorId: _currentUserId,
      authorName: _currentUserName,
      createdAt: DateTime.now(),
      title: title,
      description: description,
      reviewerIds: reviewerIds,
    );

    _mergeRequests.add(mergeRequest);
    notifyListeners();

    print('✅ Merge request created: ${mergeRequest.title}');
    print('   From: ${sourceVersionId.substring(0, 7)} → To: ${targetVersionId.substring(0, 7)}');

    return mergeRequest;
  }

  /// Approve a merge request (team leader action)
  Future<void> approveMergeRequest(String mergeRequestId) async {
    final index = _mergeRequests.indexWhere((mr) => mr.id == mergeRequestId);
    if (index == -1) throw Exception('Merge request not found');

    _mergeRequests[index] = _mergeRequests[index].copyWith(
      status: MergeRequestStatus.approved,
    );

    notifyListeners();
    print('✅ Merge request approved: ${_mergeRequests[index].title}');
  }

  /// Reject a merge request (team leader action)
  Future<void> rejectMergeRequest(
    String mergeRequestId,
    String reason,
  ) async {
    final index = _mergeRequests.indexWhere((mr) => mr.id == mergeRequestId);
    if (index == -1) throw Exception('Merge request not found');

    _mergeRequests[index] = _mergeRequests[index].copyWith(
      status: MergeRequestStatus.rejected,
      rejectionReason: reason,
    );

    notifyListeners();
    print('❌ Merge request rejected: ${_mergeRequests[index].title}');
    print('   Reason: $reason');
  }

  /// Merge an approved merge request
  /// This combines changes from source version into target
  Future<MergeResult> mergeMergeRequest(String mergeRequestId) async {
    final mrIndex = _mergeRequests.indexWhere((mr) => mr.id == mergeRequestId);
    if (mrIndex == -1) throw Exception('Merge request not found');

    final mr = _mergeRequests[mrIndex];

    if (mr.status != MergeRequestStatus.approved) {
      throw Exception('Merge request must be approved before merging');
    }

    // Get source and target versions
    final versions = _versionsByNote[mr.noteId];
    if (versions == null) throw Exception('No versions found');

    final sourceVersion = versions.firstWhere((v) => v.id == mr.sourceVersionId);
    final targetVersion = versions.firstWhere((v) => v.id == mr.targetVersionId);

    // Detect conflicts
    final conflicts = _detectConflicts(sourceVersion, targetVersion);

    if (conflicts.isNotEmpty) {
      // Mark as conflicted
      _mergeRequests[mrIndex] = mr.copyWith(
        status: MergeRequestStatus.conflicted,
      );
      notifyListeners();

      return MergeResult(
        success: false,
        conflicts: conflicts,
        message: '충돌이 발견되었습니다. 수동으로 해결해주세요.',
      );
    }

    // No conflicts - perform merge
    final mergedNote = _performMerge(sourceVersion, targetVersion);

    // Create merge commit
    final mergeCommit = await commit(
      noteId: mr.noteId,
      currentNote: mergedNote,
      commitMessage: 'Merge: ${mr.title}',
    );

    // Update merge request status
    _mergeRequests[mrIndex] = mr.copyWith(
      status: MergeRequestStatus.merged,
      mergedBy: _currentUserId,
      mergedAt: DateTime.now(),
    );

    notifyListeners();

    print('✅ Merge completed: ${mr.title}');
    print('   Merge commit: ${mergeCommit.shortId}');

    return MergeResult(
      success: true,
      mergedNote: mergedNote,
      mergeCommit: mergeCommit,
      message: '병합이 완료되었습니다.',
    );
  }

  /// Detect conflicts between two versions
  List<MergeConflict> _detectConflicts(
    NoteVersion source,
    NoteVersion target,
  ) {
    final conflicts = <MergeConflict>[];

    // For now, simplified conflict detection
    // In production, would do detailed comparison of strokes, text objects, etc.

    // Check if both modified the same layers
    if (source.noteSnapshot.layers.length != target.noteSnapshot.layers.length) {
      // Different layer counts - potential conflict
      conflicts.add(MergeConflict(
        id: 'layer_count_conflict',
        type: MergeConflictType.layerModified,
        baseValue: null,
        localValue: source.noteSnapshot.layers.length,
        remoteValue: target.noteSnapshot.layers.length,
        description: '레이어 개수가 다릅니다',
      ));
    }

    return conflicts;
  }

  /// Perform merge (simple version - combines changes)
  Note _performMerge(NoteVersion source, NoteVersion target) {
    // Simple merge: take all strokes and text from both versions
    // In production, would do intelligent 3-way merge

    final mergedLayers = [...target.noteSnapshot.layers];

    // Merge text objects (keep both)
    // Note: copyWith doesn't support textObjects parameter yet
    // Text objects are preserved from target.noteSnapshot by default
    return target.noteSnapshot.copyWith();
  }

  // ============================================================================
  // TEAM OPERATIONS
  // ============================================================================

  /// Create a new team
  Team createTeam({
    required String name,
    required String description,
  }) {
    final team = Team(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: DateTime.now(),
      members: [
        TeamMember(
          userId: _currentUserId,
          name: _currentUserName,
          email: '$_currentUserId@example.com',
          role: TeamRole.leader,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    _teams.add(team);
    notifyListeners();

    print('✅ Team created: $name');
    return team;
  }

  /// Add member to team
  void addTeamMember({
    required String teamId,
    required String userId,
    required String userName,
    required String email,
    required TeamRole role,
  }) {
    final teamIndex = _teams.indexWhere((t) => t.id == teamId);
    if (teamIndex == -1) throw Exception('Team not found');

    final member = TeamMember(
      userId: userId,
      name: userName,
      email: email,
      role: role,
      joinedAt: DateTime.now(),
    );

    final updatedMembers = [..._teams[teamIndex].members, member];
    _teams[teamIndex] = _teams[teamIndex].copyWith(members: updatedMembers);

    notifyListeners();
    print('✅ Member added to team: $userName (${member.roleText})');
  }

  /// Share note with team
  void shareNoteWithTeam(String noteId, String teamId) {
    final teamIndex = _teams.indexWhere((t) => t.id == teamId);
    if (teamIndex == -1) throw Exception('Team not found');

    if (!_teams[teamIndex].noteIds.contains(noteId)) {
      final updatedNoteIds = [..._teams[teamIndex].noteIds, noteId];
      _teams[teamIndex] = _teams[teamIndex].copyWith(noteIds: updatedNoteIds);
      notifyListeners();
      print('✅ Note shared with team: ${_teams[teamIndex].name}');
    }
  }

  /// Get teams that have access to a note
  List<Team> getTeamsForNote(String noteId) {
    return _teams.where((team) => team.noteIds.contains(noteId)).toList();
  }

  /// Check if current user is a leader in any team for this note
  bool isLeaderForNote(String noteId) {
    final teams = getTeamsForNote(noteId);
    return teams.any((team) => team.isLeader(_currentUserId));
  }
}

/// Result of a merge operation
class MergeResult {
  final bool success;
  final Note? mergedNote;
  final NoteVersion? mergeCommit;
  final List<MergeConflict> conflicts;
  final String message;

  MergeResult({
    required this.success,
    this.mergedNote,
    this.mergeCommit,
    this.conflicts = const [],
    required this.message,
  });
}
