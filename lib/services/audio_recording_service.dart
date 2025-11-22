import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

/// Audio recording timestamp sync point
class AudioSyncPoint {
  final int timestamp; // milliseconds since recording started
  final int strokeIndex; // index of stroke in the drawing
  final String description; // optional description

  AudioSyncPoint({
    required this.timestamp,
    required this.strokeIndex,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'strokeIndex': strokeIndex,
        'description': description,
      };

  factory AudioSyncPoint.fromJson(Map<String, dynamic> json) => AudioSyncPoint(
        timestamp: json['timestamp'],
        strokeIndex: json['strokeIndex'],
        description: json['description'] ?? '',
      );
}

/// Audio recording with synchronized note-taking
class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  bool _isRecording = false;
  bool _isPlaying = false;
  final List<AudioSyncPoint> _syncPoints = [];

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;
  List<AudioSyncPoint> get syncPoints => _syncPoints;

  /// Start recording audio
  Future<bool> startRecording() async {
    try {
      // Check and request permission
      if (await _recorder.hasPermission()) {
        // Get temporary directory
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${directory.path}/recording_$timestamp.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        _currentRecordingPath = path;
        _recordingStartTime = DateTime.now();
        _isRecording = true;
        _syncPoints.clear();

        return true;
      }
      return false;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  /// Add sync point (when user draws a stroke)
  void addSyncPoint(int strokeIndex, {String description = ''}) {
    if (_recordingStartTime != null) {
      final timestamp = DateTime.now().difference(_recordingStartTime!).inMilliseconds;
      _syncPoints.add(AudioSyncPoint(
        timestamp: timestamp,
        strokeIndex: strokeIndex,
        description: description,
      ));
    }
  }

  /// Play recorded audio
  Future<void> playRecording(String path) async {
    try {
      await _player.play(DeviceFileSource(path));
      _isPlaying = true;

      // Listen for completion
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      print('Error pausing playback: $e');
    }
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      print('Error resuming playback: $e');
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  /// Seek to specific timestamp
  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  /// Get current playback position
  Future<Duration?> getCurrentPosition() async {
    try {
      return await _player.getCurrentPosition();
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }

  /// Get total duration
  Future<Duration?> getDuration() async {
    try {
      return await _player.getDuration();
    } catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }

  /// Find stroke at specific timestamp
  int? getStrokeAtTimestamp(int timestamp) {
    // Find the last sync point before or at the timestamp
    AudioSyncPoint? lastPoint;
    for (final point in _syncPoints) {
      if (point.timestamp <= timestamp) {
        lastPoint = point;
      } else {
        break;
      }
    }
    return lastPoint?.strokeIndex;
  }

  /// Delete recording file
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
