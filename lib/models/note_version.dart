import 'package:flutter/material.dart';
import 'note.dart';

/// Represents a single commit/version of a note
/// Similar to Git commits, each version has:
/// - Unique ID (commit hash)
/// - Parent version ID (previous commit)
/// - Author information
/// - Timestamp
/// - Commit message
/// - Snapshot of the note at this point
class NoteVersion {
  final String id; // Unique version ID (like Git commit hash)
  final String noteId; // The note this version belongs to
  final String? parentVersionId; // Previous version (null for first commit)
  final String authorId; // Who made this commit
  final String authorName; // Display name
  final DateTime timestamp;
  final String commitMessage; // User's description of changes
  final Note noteSnapshot; // Complete state of note at this version

  // Statistics for this version
  final int addedStrokes;
  final int removedStrokes;
  final int addedTextObjects;
  final int removedTextObjects;

  NoteVersion({
    required this.id,
    required this.noteId,
    this.parentVersionId,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    required this.commitMessage,
    required this.noteSnapshot,
    this.addedStrokes = 0,
    this.removedStrokes = 0,
    this.addedTextObjects = 0,
    this.removedTextObjects = 0,
  });

  /// Get a short version ID (first 7 characters, like Git)
  String get shortId => id.substring(0, 7);

  /// Get formatted timestamp
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}개월 전';
    return '${(diff.inDays / 365).floor()}년 전';
  }

  /// Get summary of changes
  String get changeSummary {
    final changes = <String>[];
    if (addedStrokes > 0) changes.add('+$addedStrokes획');
    if (removedStrokes > 0) changes.add('-$removedStrokes획');
    if (addedTextObjects > 0) changes.add('+$addedTextObjects텍스트');
    if (removedTextObjects > 0) changes.add('-$removedTextObjects텍스트');

    return changes.isEmpty ? '변경 없음' : changes.join(', ');
  }

  NoteVersion copyWith({
    String? id,
    String? noteId,
    String? parentVersionId,
    String? authorId,
    String? authorName,
    DateTime? timestamp,
    String? commitMessage,
    Note? noteSnapshot,
    int? addedStrokes,
    int? removedStrokes,
    int? addedTextObjects,
    int? removedTextObjects,
  }) {
    return NoteVersion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      timestamp: timestamp ?? this.timestamp,
      commitMessage: commitMessage ?? this.commitMessage,
      noteSnapshot: noteSnapshot ?? this.noteSnapshot,
      addedStrokes: addedStrokes ?? this.addedStrokes,
      removedStrokes: removedStrokes ?? this.removedStrokes,
      addedTextObjects: addedTextObjects ?? this.addedTextObjects,
      removedTextObjects: removedTextObjects ?? this.removedTextObjects,
    );
  }
}

/// Represents a merge request (Pull Request in Git terms)
/// Used for team collaboration - members request changes to be merged
class MergeRequest {
  final String id;
  final String noteId;
  final String sourceVersionId; // The version to merge from
  final String targetVersionId; // The version to merge into (usually HEAD)
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String title;
  final String description;
  final MergeRequestStatus status;
  final List<String> reviewerIds; // Team leader(s) who can approve
  final String? mergedBy; // Who approved and merged
  final DateTime? mergedAt;
  final String? rejectionReason;

  MergeRequest({
    required this.id,
    required this.noteId,
    required this.sourceVersionId,
    required this.targetVersionId,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.title,
    required this.description,
    this.status = MergeRequestStatus.pending,
    this.reviewerIds = const [],
    this.mergedBy,
    this.mergedAt,
    this.rejectionReason,
  });

  String get statusText {
    switch (status) {
      case MergeRequestStatus.pending:
        return '검토 대기 중';
      case MergeRequestStatus.approved:
        return '승인됨';
      case MergeRequestStatus.merged:
        return '병합 완료';
      case MergeRequestStatus.rejected:
        return '반려됨';
      case MergeRequestStatus.conflicted:
        return '충돌 발생';
    }
  }

  Color get statusColor {
    switch (status) {
      case MergeRequestStatus.pending:
        return const Color(0xFFFF9500); // Orange
      case MergeRequestStatus.approved:
        return const Color(0xFF34C759); // Green
      case MergeRequestStatus.merged:
        return const Color(0xFF007AFF); // Blue
      case MergeRequestStatus.rejected:
        return const Color(0xFFFF3B30); // Red
      case MergeRequestStatus.conflicted:
        return const Color(0xFFFF9500); // Orange
    }
  }

  MergeRequest copyWith({
    String? id,
    String? noteId,
    String? sourceVersionId,
    String? targetVersionId,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    String? title,
    String? description,
    MergeRequestStatus? status,
    List<String>? reviewerIds,
    String? mergedBy,
    DateTime? mergedAt,
    String? rejectionReason,
  }) {
    return MergeRequest(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      sourceVersionId: sourceVersionId ?? this.sourceVersionId,
      targetVersionId: targetVersionId ?? this.targetVersionId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      reviewerIds: reviewerIds ?? this.reviewerIds,
      mergedBy: mergedBy ?? this.mergedBy,
      mergedAt: mergedAt ?? this.mergedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

enum MergeRequestStatus {
  pending, // Waiting for review
  approved, // Approved but not merged yet
  merged, // Successfully merged
  rejected, // Rejected by reviewer
  conflicted, // Has conflicts that need resolution
}

/// Represents a team for collaborative note-taking
class Team {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<TeamMember> members;
  final List<String> noteIds; // Notes shared with this team

  Team({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.members = const [],
    this.noteIds = const [],
  });

  /// Get team leader(s)
  List<TeamMember> get leaders {
    return members.where((m) => m.role == TeamRole.leader).toList();
  }

  /// Get regular members
  List<TeamMember> get regularMembers {
    return members.where((m) => m.role == TeamRole.member).toList();
  }

  /// Check if user is a leader
  bool isLeader(String userId) {
    return members.any((m) => m.userId == userId && m.role == TeamRole.leader);
  }

  Team copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<TeamMember>? members,
    List<String>? noteIds,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      noteIds: noteIds ?? this.noteIds,
    );
  }
}

class TeamMember {
  final String userId;
  final String name;
  final String email;
  final TeamRole role;
  final DateTime joinedAt;

  TeamMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  String get roleText {
    switch (role) {
      case TeamRole.leader:
        return '조장';
      case TeamRole.member:
        return '조원';
      case TeamRole.viewer:
        return '뷰어';
    }
  }

  Color get roleColor {
    switch (role) {
      case TeamRole.leader:
        return const Color(0xFFFF9500); // Orange
      case TeamRole.member:
        return const Color(0xFF007AFF); // Blue
      case TeamRole.viewer:
        return const Color(0xFF8E8E93); // Gray
    }
  }

  TeamMember copyWith({
    String? userId,
    String? name,
    String? email,
    TeamRole? role,
    DateTime? joinedAt,
  }) {
    return TeamMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

enum TeamRole {
  leader, // Can approve/reject merge requests
  member, // Can create commits and merge requests
  viewer, // Read-only access
}

/// Conflict detected during merge
class MergeConflict {
  final String id;
  final MergeConflictType type;
  final dynamic baseValue; // Original value
  final dynamic localValue; // Your changes
  final dynamic remoteValue; // Their changes
  final String description;

  MergeConflict({
    required this.id,
    required this.type,
    required this.baseValue,
    required this.localValue,
    required this.remoteValue,
    required this.description,
  });
}

enum MergeConflictType {
  strokeModified, // Same stroke modified by both
  strokeDeleted, // One deleted, one modified
  textModified, // Same text object modified
  textDeleted, // One deleted, one modified
  layerModified, // Layer properties changed
}

/// Resolution chosen by user for a conflict
enum ConflictResolution {
  keepLocal, // Keep my changes
  keepRemote, // Accept their changes
  keepBoth, // Keep both (create copy)
  manual, // Manually resolved
}
