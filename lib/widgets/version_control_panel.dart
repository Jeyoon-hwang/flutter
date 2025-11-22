import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/note_version.dart';

/// Version control panel showing commit history and merge requests
/// Like a simplified Git UI within the app
class VersionControlPanel extends StatelessWidget {
  const VersionControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final currentNote = provider.noteService.currentNote;
        if (currentNote == null) {
          return const SizedBox.shrink();
        }

        final versions = provider.versionManager.getVersions(currentNote.id);
        final mergeRequests = provider.versionManager.getMergeRequests(currentNote.id);
        final isLeader = provider.versionManager.isLeaderForNote(currentNote.id);

        return Positioned(
          left: 20,
          top: 80,
          bottom: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: provider.isDarkMode
                        ? [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.5),
                          ]
                        : [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: provider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with tabs
                    _buildHeader(context, provider, isLeader),

                    // Content
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: [
                                Tab(text: '커밋 (${versions.length})'),
                                Tab(text: '병합 요청 (${mergeRequests.length})'),
                              ],
                              labelColor: provider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              unselectedLabelColor: provider.isDarkMode
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildVersionList(context, provider, versions),
                                  _buildMergeRequestList(
                                    context,
                                    provider,
                                    mergeRequests,
                                    isLeader,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DrawingProvider provider,
    bool isLeader,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.account_tree,
            size: 20,
            color: provider.isDarkMode
                ? Colors.white.withOpacity(0.9)
                : Colors.black.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Text(
            '버전 관리',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: provider.isDarkMode
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.8),
            ),
          ),
          if (isLeader) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '조장',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF9500),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Commit button
          GestureDetector(
            onTap: () => _showCommitDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.upload, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Commit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionList(
    BuildContext context,
    DrawingProvider provider,
    List<NoteVersion> versions,
  ) {
    if (versions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: provider.isDarkMode
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 커밋이 없습니다',
              style: TextStyle(
                color: provider.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 커밋을 만들어보세요!',
              style: TextStyle(
                fontSize: 12,
                color: provider.isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: versions.length,
      itemBuilder: (context, index) {
        final version = versions[index];
        final isHead = index == 0; // First item is HEAD

        return _buildVersionItem(context, provider, version, isHead);
      },
    );
  }

  Widget _buildVersionItem(
    BuildContext context,
    DrawingProvider provider,
    NoteVersion version,
    bool isHead,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: provider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: isHead
            ? Border.all(color: const Color(0xFF34C759), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Commit hash (short)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  version.shortId,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: provider.isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
              if (isHead) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HEAD',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                version.timeAgo,
                style: TextStyle(
                  fontSize: 11,
                  color: provider.isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Commit message
          Text(
            version.commitMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: provider.isDarkMode ? Colors.white : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Author
          Row(
            children: [
              Icon(
                Icons.person,
                size: 12,
                color: provider.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                version.authorName,
                style: TextStyle(
                  fontSize: 12,
                  color: provider.isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                version.changeSummary,
                style: TextStyle(
                  fontSize: 11,
                  color: provider.isDarkMode
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                ),
              ),
            ],
          ),
          // Restore button
          if (!isHead) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _restoreVersion(context, provider, version),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restore, size: 14, color: Color(0xFF007AFF)),
                    SizedBox(width: 4),
                    Text(
                      '이 버전으로 복원',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMergeRequestList(
    BuildContext context,
    DrawingProvider provider,
    List<MergeRequest> mergeRequests,
    bool isLeader,
  ) {
    if (mergeRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.merge_type,
              size: 48,
              color: provider.isDarkMode
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '병합 요청이 없습니다',
              style: TextStyle(
                color: provider.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mergeRequests.length,
      itemBuilder: (context, index) {
        final mr = mergeRequests[index];
        return _buildMergeRequestItem(context, provider, mr, isLeader);
      },
    );
  }

  Widget _buildMergeRequestItem(
    BuildContext context,
    DrawingProvider provider,
    MergeRequest mergeRequest,
    bool isLeader,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: provider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mergeRequest.statusColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  mergeRequest.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: provider.isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mergeRequest.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  mergeRequest.statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: mergeRequest.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Author and time
          Row(
            children: [
              Icon(
                Icons.person,
                size: 12,
                color: provider.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                mergeRequest.authorName,
                style: TextStyle(
                  fontSize: 12,
                  color: provider.isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.schedule,
                size: 12,
                color: provider.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(mergeRequest.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: provider.isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
          // Actions for leaders
          if (isLeader && mergeRequest.status == MergeRequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _approveMergeRequest(context, provider, mergeRequest),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          '승인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _rejectMergeRequest(context, provider, mergeRequest),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          '반려',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  void _showCommitDialog(BuildContext context, DrawingProvider provider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upload, color: Color(0xFF667EEA)),
            SizedBox(width: 8),
            Text('커밋 만들기'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '변경 사항을 설명하는 메시지를 작성하세요:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '예: 수학 공식 추가, 다이어그램 완성',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        '커밋이란?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '현재 작업 상태를 저장합니다. 나중에 이 시점으로 복원할 수 있습니다.',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = controller.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('커밋 메시지를 입력하세요')),
                );
                return;
              }

              final currentNote = provider.noteService.currentNote;
              if (currentNote == null) return;

              // Create commit
              await provider.versionManager.commit(
                noteId: currentNote.id,
                currentNote: currentNote,
                commitMessage: message,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('커밋 완료: $message'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF34C759),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
            ),
            child: const Text('커밋'),
          ),
        ],
      ),
    );
  }

  void _restoreVersion(
    BuildContext context,
    DrawingProvider provider,
    NoteVersion version,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore, color: Color(0xFF007AFF)),
            SizedBox(width: 8),
            Text('버전 복원'),
          ],
        ),
        content: Text(
          '이 버전으로 복원하시겠습니까?\n\n'
          '커밋: ${version.shortId}\n'
          '메시지: ${version.commitMessage}\n'
          '작성자: ${version.authorName}\n'
          '시간: ${version.timeAgo}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final currentNote = provider.noteService.currentNote;
              if (currentNote == null) return;

              final restoredNote = provider.versionManager.restoreVersion(
                currentNote.id,
                version.id,
              );

              if (restoredNote != null) {
                // TODO: Apply restored note to provider
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('버전 복원 완료: ${version.shortId}'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF007AFF),
                  ),
                );
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
            ),
            child: const Text('복원'),
          ),
        ],
      ),
    );
  }

  void _approveMergeRequest(
    BuildContext context,
    DrawingProvider provider,
    MergeRequest mergeRequest,
  ) async {
    await provider.versionManager.approveMergeRequest(mergeRequest.id);

    // Try to merge
    final result = await provider.versionManager.mergeMergeRequest(mergeRequest.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(result.message)),
          ],
        ),
        backgroundColor: result.success
            ? const Color(0xFF34C759)
            : const Color(0xFFFF9500),
      ),
    );
  }

  void _rejectMergeRequest(
    BuildContext context,
    DrawingProvider provider,
    MergeRequest mergeRequest,
  ) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('병합 요청 반려'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('반려 사유를 입력하세요:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '예: 내용 확인 필요, 충돌 발생',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('반려 사유를 입력하세요')),
                );
                return;
              }

              await provider.versionManager.rejectMergeRequest(
                mergeRequest.id,
                reason,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.block, color: Colors.white),
                      SizedBox(width: 8),
                      Text('병합 요청이 반려되었습니다'),
                    ],
                  ),
                  backgroundColor: Color(0xFFFF3B30),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
            ),
            child: const Text('반려'),
          ),
        ],
      ),
    );
  }
}
