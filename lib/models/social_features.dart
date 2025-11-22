/// Social features inspired by 투두메이트 (Todo Mate)
/// Core concept: Share plans and achievements with friends
library;

class StudyFriend {
  final String id;
  final String username;
  final String? displayName;
  final String? profileImageUrl;
  final DateTime friendsSince;
  final int mutualFriends;

  StudyFriend({
    required this.id,
    required this.username,
    this.displayName,
    this.profileImageUrl,
    required this.friendsSince,
    this.mutualFriends = 0,
  });

  String get name => displayName ?? username;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'profileImageUrl': profileImageUrl,
    'friendsSince': friendsSince.toIso8601String(),
    'mutualFriends': mutualFriends,
  };

  factory StudyFriend.fromJson(Map<String, dynamic> json) => StudyFriend(
    id: json['id'],
    username: json['username'],
    displayName: json['displayName'],
    profileImageUrl: json['profileImageUrl'],
    friendsSince: DateTime.parse(json['friendsSince']),
    mutualFriends: json['mutualFriends'] ?? 0,
  );
}

/// Friend's today activity (친구의 오늘 활동)
class FriendActivity {
  final StudyFriend friend;
  final List<PlannerTask> todayTasks;
  final Duration todayStudyTime;
  final double todayAchievementRate;
  final String? currentActivity; // "수학 공부 중" or null
  final DateTime lastActive;

  FriendActivity({
    required this.friend,
    required this.todayTasks,
    required this.todayStudyTime,
    required this.todayAchievementRate,
    this.currentActivity,
    required this.lastActive,
  });

  bool get isStudyingNow => currentActivity != null;

  int get completedTasks => todayTasks.where((t) => t.isCompleted).length;
  int get totalTasks => todayTasks.length;

  String get formattedStudyTime {
    final hours = todayStudyTime.inHours;
    final minutes = todayStudyTime.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get activityStatus {
    if (isStudyingNow) return currentActivity!;

    final diff = DateTime.now().difference(lastActive);
    if (diff.inMinutes < 30) return '방금 활동';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전 활동';
    if (diff.inHours < 24) return '${diff.inHours}시간 전 활동';
    return '${diff.inDays}일 전 활동';
  }
}

/// Planner task (할 일)
class PlannerTask {
  final String id;
  final String title;
  final String? subject;
  final DateTime createdAt;
  final DateTime? dueTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final int reactionCount; // 친구들의 반응 수

  PlannerTask({
    required this.id,
    required this.title,
    this.subject,
    required this.createdAt,
    this.dueTime,
    this.isCompleted = false,
    this.completedAt,
    this.reactionCount = 0,
  });

  PlannerTask copyWith({
    String? title,
    String? subject,
    DateTime? dueTime,
    bool? isCompleted,
    DateTime? completedAt,
    int? reactionCount,
  }) {
    return PlannerTask(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      createdAt: createdAt,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      reactionCount: reactionCount ?? this.reactionCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'createdAt': createdAt.toIso8601String(),
    'dueTime': dueTime?.toIso8601String(),
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'reactionCount': reactionCount,
  };

  factory PlannerTask.fromJson(Map<String, dynamic> json) => PlannerTask(
    id: json['id'],
    title: json['title'],
    subject: json['subject'],
    createdAt: DateTime.parse(json['createdAt']),
    dueTime: json['dueTime'] != null ? DateTime.parse(json['dueTime']) : null,
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    reactionCount: json['reactionCount'] ?? 0,
  );
}

/// Reaction/emoji to friend's task (친구의 할 일에 대한 반응)
enum ReactionType {
  like,       // 👍 좋아요
  fire,       // 🔥 파이팅
  clap,       // 👏 박수
  star,       // ⭐ 멋져요
  muscle,     // 💪 힘내요
}

class TaskReaction {
  final String id;
  final String taskId;
  final String userId;
  final ReactionType type;
  final DateTime createdAt;

  TaskReaction({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  String get emoji {
    switch (type) {
      case ReactionType.like: return '👍';
      case ReactionType.fire: return '🔥';
      case ReactionType.clap: return '👏';
      case ReactionType.star: return '⭐';
      case ReactionType.muscle: return '💪';
    }
  }
}

/// Study group (스터디 그룹) - inspired by 열품타 group feature
class StudyGroup {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;
  final int maxMembers;

  StudyGroup({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.maxMembers = 50,
  });

  int get memberCount => memberIds.length;
  bool get isFull => memberCount >= maxMembers;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'memberIds': memberIds,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'maxMembers': maxMembers,
  };

  factory StudyGroup.fromJson(Map<String, dynamic> json) => StudyGroup(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    memberIds: List<String>.from(json['memberIds']),
    createdBy: json['createdBy'],
    createdAt: DateTime.parse(json['createdAt']),
    maxMembers: json['maxMembers'] ?? 50,
  );
}

/// Group member activity (그룹원 활동)
class GroupMemberActivity {
  final String userId;
  final String username;
  final Duration todayStudyTime;
  final double achievementRate;
  final int rank; // 그룹 내 순위

  GroupMemberActivity({
    required this.userId,
    required this.username,
    required this.todayStudyTime,
    required this.achievementRate,
    required this.rank,
  });

  String get formattedStudyTime {
    final hours = todayStudyTime.inHours;
    final minutes = todayStudyTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String get rankEmoji {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '$rank위';
    }
  }
}

/// Social feed item (소셜 피드)
enum FeedType {
  taskCompleted,      // 할 일 완료
  achievementUnlocked, // 업적 달성
  studyMilestone,     // 공부 마일스톤 (100시간 등)
  noteShared,         // 노트 공유
}

class SocialFeedItem {
  final String id;
  final String userId;
  final String username;
  final FeedType type;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final String? imageUrl;

  SocialFeedItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.type,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.imageUrl,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

/// User's public profile (공개 프로필)
class UserPublicProfile {
  final String id;
  final String username;
  final String? displayName;
  final String? bio;
  final String? profileImageUrl;
  final int totalStudyHours;
  final int studyStreak;
  final int friendCount;
  final List<String> badges; // 업적 뱃지들
  final DateTime memberSince;

  UserPublicProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.bio,
    this.profileImageUrl,
    required this.totalStudyHours,
    required this.studyStreak,
    required this.friendCount,
    required this.badges,
    required this.memberSince,
  });

  String get name => displayName ?? username;
}
