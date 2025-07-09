import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:strumok/l10n/app_localizations.dart';

class TrackChangeDialog extends StatefulWidget {
  final Player player;

  const TrackChangeDialog({super.key, required this.player});

  @override
  State<TrackChangeDialog> createState() => _TrackChangeDialogState();
}

class _TrackChangeDialogState extends State<TrackChangeDialog> {
  late List<AudioTrack> _audioTracks;
  late AudioTrack _currentAudioTrack;
  late List<VideoTrack> _videoTracks;
  late VideoTrack _currentVideoTrack;
  late final List<StreamSubscription> subs;

  @override
  void initState() {
    final player = widget.player;

    _audioTracks = player.state.tracks.audio;
    _currentAudioTrack = player.state.track.audio;
    _videoTracks = player.state.tracks.video;
    _currentVideoTrack = player.state.track.video;

    subs = [
      player.stream.tracks.listen((event) {
        setState(() {
          _audioTracks = event.audio;
          _videoTracks = event.video;
        });
      }),
      player.stream.track.listen((event) {
        setState(() {
          _currentAudioTrack = event.audio;
          _currentVideoTrack = event.video;
        });
      }),
    ];

    super.initState();
  }

  @override
  void dispose() {
    for (var sub in subs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAudioTracks =
        _audioTracks
            .where((track) => track.language != null || track.id == "auto")
            .toList();

    final filteredVideoTracks =
        _videoTracks.where((track) => track.id != "no").toList();

    return Dialog(
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (filteredVideoTracks.isNotEmpty)
                Expanded(
                  child: _buildVideoTrackList(context, filteredVideoTracks),
                ),
              if (filteredAudioTracks.length > 1)
                Expanded(
                  child: _buildAudioTrackList(context, filteredAudioTracks),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioTrackList(BuildContext context, List<AudioTrack> tracks) {
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
            leading: const Icon(Icons.audiotrack),
            onTap: () {
              widget.player.setAudioTrack(track);
              Navigator.of(context).pop();
            },
            title: Text(_audioTrackName(track)),
            trailing:
                _currentAudioTrack == track ? const Icon(Icons.check) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTrackList(BuildContext context, List<VideoTrack> tracks) {
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
              widget.player.setVideoTrack(track);
              Navigator.of(context).pop();
            },
            title: Text(_videoTrackName(track)),
            trailing:
                _currentVideoTrack == track ? const Icon(Icons.check) : null,
          ),
        ),
      ],
    );
  }

  String _audioTrackName(AudioTrack track) {
    return track.language ?? track.id;
  }

  String _videoTrackName(VideoTrack track) {
    // Return a quality label based on the width of the video track.
    final width = track.w;
    if (width == null) {
      return track.id;
    }

    if (width >= 3840) return '4K (${width}p)';
    if (width >= 2560) return '1440p (${width}p)';
    if (width >= 1920) return '1080p (${width}p)';
    if (width >= 1280) return '720p (${width}p)';
    if (width >= 854) return '480p (${width}p)';
    if (width >= 640) return '360p (${width}p)';
    if (width >= 426) return '240p (${width}p)';

    return '${width}p';
  }
}

class TrackSelector extends ConsumerWidget {
  const TrackSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = controller(context).player;

    if (_hasAnyTracks(player.state.tracks)) {
      return _buildButton(context, player);
    }

    return StreamBuilder(
      stream: player.stream.tracks,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !_hasAnyTracks(snapshot.data!)) {
          return SizedBox.shrink();
        } else {
          return _buildButton(context, player);
        }
      },
    );
  }

  bool _hasAnyTracks(Tracks tracks) {
    final hasAudioLanguage =
        tracks.audio.where((track) => track.language != null).isNotEmpty;
    final hasMultipleVideoTracks = tracks.video.length > 2;
    return hasAudioLanguage || hasMultipleVideoTracks;
  }

  Widget _buildButton(BuildContext context, Player player) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => TrackChangeDialog(player: player),
        );
      },
      tooltip: AppLocalizations.of(context)!.videoPlayerBtnHintTracks,
      icon: const Icon(Icons.track_changes),
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
    );
  }
}
