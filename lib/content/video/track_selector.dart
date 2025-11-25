import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/video_backend/video_backend.dart';
import 'package:strumok/video_backend/tracks.dart';

class TrackSelector extends StatelessWidget {
  const TrackSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoContentController(context).videoBackend,
      builder: (context, value, _) => switch (value) {
        AsyncData(value: final videoBackend) => _buildButton(
          context,
          videoBackend,
        ),
        _ => SizedBox.shrink(),
      },
    );
  }

  Widget _buildButton(BuildContext context, VideoBackend videoBackend) {
    if (!_hasAnyTracks(videoBackend.value)) {
      return SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) =>
              _TrackSelectorDialog(videoBackend: videoBackend),
        );
      },
      tooltip: AppLocalizations.of(context)!.videoPlayerBtnHintTracks,
      icon: const Icon(Icons.track_changes),
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
    );
  }

  bool _hasAnyTracks(VideoBackendState videoBackendState) {
    return (videoBackendState.videoTracks.length > 1) ||
        (videoBackendState.audioTracks.length > 1);
  }
}

class _TrackSelectorDialog extends StatelessWidget {
  final VideoBackend videoBackend;

  const _TrackSelectorDialog({required this.videoBackend});

  @override
  Widget build(BuildContext context) {
    final audioTracks = videoBackend.value.audioTracks;
    final videoTracks = videoBackend.value.videoTracks;

    return AppTheme(
      child: Dialog(
        child: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (videoTracks.isNotEmpty)
                  Expanded(child: _buildVideoTracks(context, videoTracks)),
                if (audioTracks.isNotEmpty)
                  Expanded(child: _buildAudioTracks(context, audioTracks)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioTracks(BuildContext context, List<AudioTrack> tracks) {
    final currentTrackId = videoBackend.value.currentAudioTrackId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.videoPlayerAudioTracks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        ...tracks.map(
          (track) => ListTile(
            leading: const Icon(Icons.videocam),
            onTap: () {
              videoBackend.setAudioTrack(track.id);
              Navigator.of(context).pop();
            },
            title: Text(track.name),
            trailing: currentTrackId == track.id
                ? const Icon(Icons.check)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTracks(BuildContext context, List<VideoTrack> tracks) {
    final currentTrackId = videoBackend.value.currentVideoTrackId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.videoPlayerVideoTracks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        ...tracks.map(
          (track) => ListTile(
            leading: const Icon(Icons.videocam),
            onTap: () {
              videoBackend.setVideoTrack(track.id);
              Navigator.of(context).pop();
            },
            title: Text(track.name),
            trailing: currentTrackId == track.id
                ? const Icon(Icons.check)
                : null,
          ),
        ),
      ],
    );
  }
}
