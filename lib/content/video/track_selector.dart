import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart';
import 'package:fvp/mdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/utils/text.dart';
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
    if (!_hasAnyTracks(controller.getMediaInfo())) {
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

  bool _hasAnyTracks(MediaInfo? mediaInfo) {
    if (mediaInfo == null) {
      return false;
    }

    return (mediaInfo.video != null && mediaInfo.video!.length > 1) ||
        (mediaInfo.audio != null && mediaInfo.audio!.length > 1);
  }
}

class _TrackSelectorDialog extends StatelessWidget {
  final VideoPlayerController controller;

  const _TrackSelectorDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final mediaInfo = controller.getMediaInfo()!;

    final audioTracks = mediaInfo.audio ?? [];
    final videoTracks = mediaInfo.video ?? [];

    return Dialog(
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
    );
  }

  Widget _buildAudioTracks(BuildContext context, List<AudioStreamInfo> tracks) {
    final currentTracks = controller.getActiveAudioTracks() ?? [];

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
        ...tracks.mapIndexed(
          (idx, track) => ListTile(
            leading: const Icon(Icons.videocam),
            onTap: () {
              controller.setAudioTracks([idx]);
              Navigator.of(context).pop();
            },
            title: Text(_audioTrackTitle(track)),
            trailing: currentTracks.contains(idx)
                ? const Icon(Icons.check)
                : null,
          ),
        ),
      ],
    );
  }

  String _audioTrackTitle(AudioStreamInfo track) {
    final Map<String, String> metadata = track.metadata;
    if (metadata["comment"] != null) {
      return metadata["comment"]!;
    } else if (metadata["language"] != null) {
      return metadata["language"]!;
    } else if (metadata["variant_bitrate"] != null) {
      final variantBitrate = metadata["variant_bitrate"]!;
      final formatBitrate = formatBytes(int.tryParse(variantBitrate) ?? 0);
      return "${formatBitrate}it/s";
    } else {
      return metadata.toString();
    }
  }

  Widget _buildVideoTracks(BuildContext context, List<VideoStreamInfo> tracks) {
    final currentTracks = controller.getActiveVideoTracks() ?? [];

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
        ...tracks.mapIndexed(
          (idx, track) => ListTile(
            leading: const Icon(Icons.videocam),
            onTap: () {
              controller.setVideoTracks([idx]);
              Navigator.of(context).pop();
            },
            title: Text(_videoTrackTitle(track)),
            trailing: currentTracks.contains(idx)
                ? const Icon(Icons.check)
                : null,
          ),
        ),
      ],
    );
  }

  String _videoTrackTitle(VideoStreamInfo track) {
    final codec = track.codec;
    return "${codec.width}x${codec.height}";
  }
}
