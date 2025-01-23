import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../../values/app_colors.dart';

class CustomControls extends StatefulWidget {
  final BetterPlayerController controller;

  CustomControls(this.controller);

  @override
  _CustomControlsState createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  late BetterPlayerController controller;
  late ValueNotifier<Duration> _currentPositionNotifier;
  late ValueNotifier<Duration> _durationNotifier;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    _currentPositionNotifier = ValueNotifier(Duration.zero);
    _durationNotifier = ValueNotifier(Duration.zero);

    // Update the progress bar whenever the position changes
    controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        _currentPositionNotifier.value = event.parameters!['position'] ?? const Duration(seconds: 0);
        _durationNotifier.value = event.parameters!['duration'] ?? const Duration(seconds: 0);
      }
    });

    // Update progress continuously
    _startProgressUpdate();
  }

  // Method to periodically update the progress bar
  void _startProgressUpdate() {
    Future.delayed(const Duration(seconds: 1), () {
      if (controller.isPlaying() == true) {
        setState(() {
          _currentPositionNotifier.value = controller.videoPlayerController!.value.position;
        });
      }
      _startProgressUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Video progress bar
        Flexible(
          child: ValueListenableBuilder<Duration>(
            valueListenable: _currentPositionNotifier,
            builder: (context, currentPosition, child) {
              return ValueListenableBuilder<Duration>(
                valueListenable: _durationNotifier,
                builder: (context, totalDuration, child) {
                  return SliderTheme(
                    data: SliderThemeData(trackHeight: 3),
                    child: Slider(
                      value: controller.videoPlayerController!.value.position.inSeconds.toDouble(),
                      min: 0,
                      max: totalDuration.inSeconds.toDouble(),
                      activeColor: AppColors.primaryColor,
                      inactiveColor: AppColors.primaryColor.withOpacity(0.7),
                      onChanged: (value) {
                        final newPosition = Duration(seconds: value.toInt());
                        controller.seekTo(newPosition);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen, color: Colors.white, size: 25),
          onPressed: () {
            controller.toggleFullScreen();
          },
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  // Method to seek to a specific time (positive for forward, negative for backward)
  void _seekTo(BetterPlayerController controller, int seconds) {
    final currentPosition = controller.videoPlayerController?.value.position ?? Duration.zero;
    final targetPosition = currentPosition + Duration(seconds: seconds);
    controller.seekTo(targetPosition);
  }

  @override
  void dispose() {
    _currentPositionNotifier.dispose();
    _durationNotifier.dispose();
    super.dispose();
  }
}