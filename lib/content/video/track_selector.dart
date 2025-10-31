import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/video_backend/extension.dart';
import 'package:strumok/video_backend/tracks.dart';
import 'package:video_player/video_player.dart';

class TrackSelector extends StatelessWidget {
  const TrackSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoContentController(context).playerController,
      builder: (context, value, _) => switch (value) {
        AsyncData(value: final controller) => _buildButton(context, controller),
        _ => SizedBox.shrink(),
      },
    );
  }

  Widget _buildButton(BuildContext context, VideoPlayerController controller) {
    if (!_hasAnyTracks(controller)) {
      return SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _TrackSelectorDialog(controller: controller),
        );
      },
      tooltip: AppLocalizations.of(context)!.videoPlayerBtnHintTracks,
      icon: const Icon(Icons.track_changes),
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
    );
  }

  bool _hasAnyTracks(VideoPlayerController controller) {
    return (controller.videoTracks.length > 1) ||
        (controller.audioTracks.length > 1);
  }
}

class _TrackSelectorDialog extends StatelessWidget {
  final VideoPlayerController controller;

  const _TrackSelectorDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final audioTracks = controller.audioTracks;
    final videoTracks = controller.videoTracks;

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
    final currentTrackId = controller.currentAudioTrackId;

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
              controller.currentAudioTrackId = track.id;
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
    final currentTrackId = controller.currentVideoTrackId;

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
              controller.currentVideoTrackId = track.id;
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
