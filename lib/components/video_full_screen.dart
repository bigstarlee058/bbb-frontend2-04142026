import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:video_player/video_player.dart';

class VideoFullScreenView extends StatefulWidget {
  final Size media;
  final Size videoSize;
  final VideoPlayerController videoPlayerController;
  final ChewieController chewieController;
  final bool showControls;
  final bool isZoom;
  final bool isMute;
  final bool isFullscreen;
  final bool videoNotInitialized;

  final VoidCallback showControlsOnTap;
  final VoidCallback showControlsOnTapOfPause;
  final VoidCallback toggleFullscreen;
  final VoidCallback hideControls;
  final VoidCallback muteUnMute;
  final Function(bool) changeZoom;
  final ValueNotifier<Duration> videoProgressValue;
  final ProgressBarController controller;
  final VoidCallback makeRefresh;
  const VideoFullScreenView(
      {super.key,
      required this.media,
      required this.videoPlayerController,
      required this.chewieController,
      required this.videoSize,
      required this.showControls,
      required this.isZoom,
      required this.videoNotInitialized,
      required this.showControlsOnTap,
      required this.showControlsOnTapOfPause,
      required this.hideControls,
      required this.muteUnMute,
      required this.isMute,
      required this.videoProgressValue,
      required this.controller,
      required this.changeZoom,
      required this.isFullscreen,
      required this.toggleFullscreen,
      required this.makeRefresh});

  @override
  State<VideoFullScreenView> createState() => _VideoFullScreenViewState();
}

class _VideoFullScreenViewState extends State<VideoFullScreenView>
    with TickerProviderStateMixin {
  bool isZoom = false;
  final ValueNotifier<Duration> videoProgressValue =
      ValueNotifier(Duration.zero);
  bool isMute = false;
  bool showControls = false;
  Timer? _hideControlsTimer;
  ProgressBarController? _controller;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        widget.videoPlayerController.addListener(() {
          final position = widget.videoPlayerController.value.position;
          final duration = widget.videoPlayerController.value.duration;
          if (duration != null && position >= duration) {
            AudioManager.abandonAudioFocus();
            if (Platform.isIOS) {
              widget.videoPlayerController.seekTo(Duration.zero);
              widget.videoPlayerController.play();
            }
          } else {
            AudioManager.requestAudioFocus();
          }
          videoProgressValue.value = position;
        });
        _controller = ProgressBarController(
          vsync: this,
          barAnimationDuration: const Duration(milliseconds: 300),
          thumbAnimationDuration: const Duration(milliseconds: 200),
          waitingDuration: const Duration(milliseconds: 1800),
        );
        isMute = widget.isMute;
        showControls = widget.showControls;
        setState(() {});
        hideControls();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _controller?.dispose();
        widget.toggleFullscreen();
      },
    );

    super.dispose();
  }

  Duration getBufferedPosition() {
    final position = widget.videoPlayerController.value.position;
    final buffered = widget.videoPlayerController.value.buffered;

    for (final range in buffered) {
      if (range.start <= position && position <= range.end) {
        return range.end;
      }
    }

    // fallback to last buffered range or zero
    return buffered.isNotEmpty ? buffered.last.end : Duration.zero;
  }

  changeZoom(value) {
    isZoom = value;
  }

  muteUnMute() async {
    isMute = !isMute;
    setState(() {});
  }

  void hideControls() {
    if (widget.videoPlayerController.value.isPlaying) {
      _hideControlsTimer?.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              setState(() => showControls = false);
            },
          );
        }
      });
    }
  }

  void showControlsOnTap() {
    if (widget.videoPlayerController.value.isPlaying) {
      setState(() => showControls = !showControls);
      if (widget.videoPlayerController.value.isPlaying) {
        hideControls();
      }
    } else {
      showControls = true;
      setState(() {});
    }
  }

  void showControlsOnTapOfPause() {
    _hideControlsTimer?.cancel();
    setState(() => showControls = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.loose,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.showControlsOnTap();
                showControlsOnTap();
              },
              child: Stack(
                children: [
                  /// VIDEO SECTION

                  videoSection(widget.media),

                  /// BACK BUTTON

                  backButton(widget.media, context),
                ],
              ),
            ),
          ],
        ),

        /// PLAY PAUSE REWIND CONTROL

        playPauseControl(),

        /// VIDEO PROGRESS

        videoProgress(widget.media, context),
      ],
    );
  }

  Widget videoSection(Size media) => Container(
        color: Colors.black,
        child: Stack(
          children: [
            SizedBox(
              height: media.height,
              width: media.width,
              child: Chewie(
                controller: widget.chewieController,
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              height: media.height,
              width: media.width,
              color: showControls ? Colors.black38 : Colors.transparent,
            ),
          ],
        ),
      );

  Widget backButton(Size media, BuildContext context) => Container(
        width: media.width,
        decoration: const BoxDecoration(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil.horizontalScale(4),
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0XFFd18a9b),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: ScreenUtil.verticalScale(4.65),
                    height: ScreenUtil.verticalScale(4.65),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: ScreenUtil.verticalScale(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget playPauseControl() => Positioned(
        bottom: ScreenUtil.verticalScale(48),
        left: 10,
        right: 10,
        child: AnimatedOpacity(
          opacity: showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Skip backward button
              IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white70,
                ),
                onPressed: showControls
                    ? () {
                        widget.videoPlayerController.seekTo(
                          widget.videoPlayerController.value.position -
                              const Duration(seconds: 10),
                        );
                        _controller?.forward();
                        setState(() {});
                      }
                    : null,
              ),
              IconButton(
                iconSize: 60,
                icon: Icon(
                  widget.videoPlayerController.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white70,
                ),
                onPressed: showControls
                    ? () async {
                        if (widget.videoPlayerController.value.isPlaying) {
                          widget.videoPlayerController.pause();
                          setState(() {});
                          widget.showControlsOnTapOfPause();
                          showControlsOnTapOfPause();
                          await Future.delayed(Duration(milliseconds: 100))
                              .then(
                            (value) {
                              AudioManager.abandonAudioFocus();
                              setState(() {});
                            },
                          );
                        } else {
                          widget.videoPlayerController.play();
                          widget.hideControls();
                          hideControls();
                          await Future.delayed(Duration(milliseconds: 100))
                              .then(
                            (value) {
                              AudioManager.requestAudioFocus();
                              setState(() {});
                            },
                          );
                        }
                      }
                    : null,
              ),

              IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white70,
                ),
                onPressed: showControls
                    ? () {
                        widget.videoPlayerController.seekTo(
                          widget.videoPlayerController.value.position +
                              const Duration(seconds: 10),
                        );
                        _controller?.forward();
                        setState(() {});
                      }
                    : null,
              ),
            ],
          ),
        ),
      );

  Widget videoProgress(Size media, BuildContext context) => Positioned(
        bottom: ScreenUtil.verticalScale(7),
        left: ScreenUtil.horizontalScale(3),
        right: ScreenUtil.horizontalScale(3),
        child: !widget.videoNotInitialized &&
                widget.chewieController.videoPlayerController.value
                        .isInitialized ==
                    true
            ? Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: ScreenUtil.verticalScale(6),
                        left: 20,
                        right: 20),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: ScreenUtil.verticalScale(0.8)),
                            AnimatedOpacity(
                              opacity: showControls ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              child: Row(
                                children: [
                                  Spacer(),
                                  GestureDetector(
                                    onTap: showControls
                                        ? () {
                                            Navigator.pop(context);
                                          }
                                        : null,
                                    child: Icon(
                                      !widget.isFullscreen
                                          ? Icons.fullscreen
                                          : Icons.fullscreen_exit,
                                      color: Colors.white70,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: showControls
                                        ? () {
                                            widget.muteUnMute();
                                            muteUnMute();
                                          }
                                        : null,
                                    child: Icon(
                                      isMute
                                          ? Icons.volume_up
                                          : Icons.volume_off,
                                      color: Colors.white70,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtil.verticalScale(1)),
                        ValueListenableBuilder<Duration>(
                          valueListenable: widget.videoProgressValue,
                          builder: (context, progress, _) {
                            return ProgressBar(
                              collapsedBufferedBarColor: Colors.white,
                              expandedBufferedBarColor: Colors.white,
                              buffered: getBufferedPosition(),
                              controller: _controller ?? widget.controller,
                              progress: progress,
                              total: Duration(
                                seconds: widget.videoPlayerController.value
                                    .duration.inSeconds,
                              ),
                              onChanged: (value) {
                                widget.videoPlayerController
                                    .seekTo(Duration(seconds: value.inSeconds));
                              },
                              onSeek: (value) {},
                              onChangeStart: (value) {
                                widget.videoPlayerController.pause();
                                widget.changeZoom(true);
                                changeZoom(true);
                                setState(() {});
                              },
                              onChangeEnd: (value) {
                                widget.videoPlayerController.play();
                                widget.changeZoom(false);
                                changeZoom(false);
                                setState(() {});
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      );
}
