import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_small_daily_routine/constants/gaps.dart';
import 'package:a_small_daily_routine/constants/sizes.dart';
import 'package:a_small_daily_routine/features/authentication/repos/authentication_repo.dart';
import 'package:a_small_daily_routine/features/videos/models/video_model.dart';
import 'package:a_small_daily_routine/features/videos/view_models/playback_config_vm.dart';
import 'package:a_small_daily_routine/features/videos/view_models/video_post_view_models.dart';
import 'package:a_small_daily_routine/features/videos/views/widgets/event_button.dart';
import 'package:a_small_daily_routine/features/videos/views/widgets/video_comments.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPost extends ConsumerStatefulWidget {
  final Function onVideoFinished;
  final VideoModel videoData;
  final int index;

  const VideoPost({
    Key? key,
    required this.videoData,
    required this.onVideoFinished,
    required this.index,
  }) : super(key: key);

  @override
  VideoPostState createState() => VideoPostState();
}

class VideoPostState extends ConsumerState<VideoPost>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _videoPlayerController;

  final Duration _animationDuration = const Duration(milliseconds: 200);

  late final AnimationController _animationController;

  bool _isPaused = false;
  bool _isRefreshing = false;

  Future<void> _refreshVideoPost() async {
    setState(() {
      _isRefreshing = true;
    });

    // Add your logic to refresh the video post here.
    // For example, you can reload the video data or update any other necessary data.

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onVideoChange() {
    if (_videoPlayerController.value.isInitialized) {
      if (_videoPlayerController.value.duration ==
          _videoPlayerController.value.position) {
        widget.onVideoFinished();
      }
    }
  }

  void _initVideoPlayer() async {
    _videoPlayerController =
        VideoPlayerController.network(widget.videoData.fileUrl);
    await _videoPlayerController.initialize();
    if (kIsWeb) {
      if (!mounted) return;
      ref.read(playbackConfigProvider.notifier).setMuted(true);
      await _videoPlayerController.setVolume(0); // Mute the video
    }
    _videoPlayerController.addListener(_onVideoChange);
    _onPlaybackConfigChanged();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();

    _animationController = AnimationController(
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.5,
      value: 1.5,
      duration: _animationDuration,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPlaybackConfigChanged() {
    if (!mounted) return;
    final muted = ref.read(playbackConfigProvider).muted;
    ref.read(playbackConfigProvider.notifier).setMuted(!muted);
    if (muted) {
      _videoPlayerController.setVolume(1);
    } else {
      _videoPlayerController.setVolume(0);
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    if (info.visibleFraction == 0 &&
        !_isPaused &&
        !_videoPlayerController.value.isPlaying) {
      if (ref.read(playbackConfigProvider).autoplay) {
        _videoPlayerController.play();
      }
    }
    if (_videoPlayerController.value.isPlaying && info.visibleFraction == 1) {
      _onTogglePause();
    }
  }

  void _onTogglePause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      _animationController.reverse();
    } else {
      _videoPlayerController.play();
      _animationController.forward();
    }
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _onCommentsTap(BuildContext context, String commentId) async {
    if (_videoPlayerController.value.isPlaying) {
      _onTogglePause();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoComments(
        meetingId: commentId,
      ),
    );
    _onTogglePause();
  }

  void _onLikeTap() {
    ref.read(videoPostProvider(widget.videoData.id).notifier).likeVideo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshVideoPost,
      child: _isRefreshing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ref
              .watch(videoPostProvider(
                '${widget.videoData.id}000${ref.read(authRepo).user!.uid}',
              ))
              .when(
                data: (like) => VisibilityDetector(
                  key: Key("${widget.index}"),
                  onVisibilityChanged: _onVisibilityChanged,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _videoPlayerController.value.isInitialized
                            ? VideoPlayer(_videoPlayerController)
                            : Image.network(
                                widget.videoData.thumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _onTogglePause,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _animationController.value,
                                  child: child,
                                );
                              },
                              child: AnimatedOpacity(
                                opacity: _isPaused ? 0 : 1,
                                duration: _animationDuration,
                                child: const FaIcon(
                                  FontAwesomeIcons.play,
                                  color: Colors.white,
                                  size: Sizes.size52,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 40,
                        child: IconButton(
                          icon: FaIcon(
                            ref.watch(playbackConfigProvider).muted
                                ? FontAwesomeIcons.volumeOff
                                : FontAwesomeIcons.volumeHigh,
                            color: Colors.white,
                          ),
                          onPressed: _onPlaybackConfigChanged,
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('videos')
                            .doc(widget.videoData.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final data = snapshot.data;
                          final likes = data?['likes'] ?? 0;
                          return Positioned(
                            bottom: 20,
                            right: 10,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  backgroundImage:
                                      NetworkImage(data?['thumbnailUrl']),
                                ),
                                Gaps.v24,
                                GestureDetector(
                                  onTap: () => _onLikeTap(),
                                  child: EventButton(
                                    icon: FontAwesomeIcons.solidHeart,
                                    text: likes.toString(),
                                  ),
                                ),
                                Gaps.v24,
                                GestureDetector(
                                  onTap: () => _onCommentsTap(
                                      context, data?['description']),
                                  child: const EventButton(
                                    icon: FontAwesomeIcons.solidComment,
                                    text: '댓글',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'Could not load videos. $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
    );
  }
}
