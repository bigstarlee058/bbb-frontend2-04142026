import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../middleware/notification_service.dart';

class TimerWithProgressBar extends StatefulWidget {
  final int initialDuration; // Total duration of the timer in seconds.
  final VoidCallback onClose; // Callback when the close button is pressed.
  final VoidCallback onComplete;
  final String currentTime;
  final bool isTimerRunning; // Callback when the timer completes.

  const TimerWithProgressBar({
    super.key,
    required this.initialDuration,
    required this.onClose,
    required this.onComplete,
    required this.currentTime,
    required this.isTimerRunning,
  });

  @override
  _TimerWithProgressBarState createState() => _TimerWithProgressBarState();
}

class _TimerWithProgressBarState extends State<TimerWithProgressBar> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late int totalTime; // Total time in seconds (e.g., 5 minutes = 300 seconds).
  late int currentTime; // Current elapsed time in seconds.
  late AnimationController _controller; // Controls the animation progress.
  late Animation<double> _animation; // Animation for the progress bar.
  late String formattedTime; // Displayed time in mm:ss format.

  late UserDataProvider userDataProvider; // Provider to save data.
  Timer? _timer; // Timer for periodic updates.
  bool isPaused = false; // State to track if the timer is paused.
  bool animationCompleted = false;
  String? _previousData; // State to track if animation is done.

  @override
  void initState() {
    super.initState();
    NotificationService.clearNotification();
    totalTime = widget.initialDuration;
    WidgetsBinding.instance.addObserver(this);

    log("RUNNING TIMER ${widget.isTimerRunning}");

    // Set the total duration.
    currentTime = 0; // Start timer from 0 seconds.
    formattedTime = _formatTime(currentTime); // Format the initial time.

    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    _previousData = userDataProvider.currentExpandedItem;

    // Initialize animation controller with total duration.
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalTime),
    );

    // Define animation from 0 (start) to 1 (end).
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {}); // Update the widget on animation progress.
      });

    // Listen for animation status to trigger completion callback.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationCompleted = true; // Mark animation as completed.
        widget.onComplete();
      }
    });

    _startTimer(); // Start the timer.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        log('resumed :::::::::::::::::: ');
        NotificationService.clearNotification();
        userDataProvider.getPassedTime();
        if (userDataProvider.timePassed != "") {
          currentTime = 0;
          if (widget.isTimerRunning) {
            currentTime = int.parse(userDataProvider.timePassed);
          }
        }
        setState(() {});
        print("mode== app in resumed");
        break;
      case AppLifecycleState.inactive:
        log('inactive :::::::::::::::::: }');
        savePassedTime();
        break;
      case AppLifecycleState.paused:
        log('paused :::::::::::::::::: }');
        savePassedTime();
        break;
      case AppLifecycleState.detached:
        log('detached :::::::::::::::::: }');
        log("mode== app in detached");
        break;
      case AppLifecycleState.hidden:
        log('hidden :::::::::::::::::: }');
        break;
    }
  }

  savePassedTime() {
    userDataProvider.savePassedTime(widget.isTimerRunning ? currentTime.toString() : "0", widget.initialDuration, context);
  }

  @override
  void dispose() {
    ///it saves the time when user leaves the screen
    log("CALLED DISPOSE");
    savePassedTime();

    _controller.dispose(); // Dispose animation controller.
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel(); // Cancel the timer.
    super.dispose();
  }

  // Converts seconds into mm:ss format.
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Starts the periodic timer to update every second.
  void _startTimer() async {
    userDataProvider.getPassedTime();

    if (userDataProvider.timePassed != "") {
      if (widget.isTimerRunning) {
        currentTime = int.parse(userDataProvider.timePassed);
      }
    }
    // SharedPreferences preferences = SharedPreferences.getInstance();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          currentTime++; // Increment elapsed time.
          formattedTime = _formatTime(currentTime); // Update displayed time.

          // Forward animation only until it reaches total time.
          if (!animationCompleted && currentTime <= totalTime) {
            _controller.value = currentTime / totalTime;
          }
        });

        // Trigger animation completion when reaching total time.
        if (currentTime == totalTime && !animationCompleted) {
          _controller.forward(); // Complete the animation.
          widget.onComplete(); // Trigger completion callback.
        }
      }
    });
  }

  // Toggles the play/pause state of the timer.
  void _pauseOrResumeTimer() {
    setState(() {
      if (isPaused) {
        isPaused = false;
        if (!animationCompleted) {
          _controller.forward(); // Resume the animation if not completed.
        }
      } else {
        isPaused = true;
        _controller.stop(); // Pause the animation.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.select<UserDataProvider, String>((dataProvider) => dataProvider.currentExpandedItem);
    // Stop the timer only if the `data` value has changed
    if (_previousData != data) {
      _previousData = data;

      if (widget.isTimerRunning) {
        userDataProvider.setShowTimerIndex(-1, -1, -1);
        widget.onClose();
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        // Change color to green when 10% or less of the time remains.
        color: currentTime >= totalTime * 0.9 ? const Color(0xff008000) : AppColors.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          // Display the formatted time.
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(width: 5),
          // Progress bar indicating the elapsed time.
          Expanded(
            child: LinearProgressIndicator(
              value: currentTime <= totalTime ? currentTime / totalTime : 1.0, // Progress stops at 100%.
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 3,
            ),
          ),
          const SizedBox(width: 5),
          // Button to toggle play/pause state.
          SizedBox(
            width: 45,
            height: 30,
            child: ElevatedButton(
              onPressed: _pauseOrResumeTimer,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(20, 20),
              ),
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: AppColors.skipDayColor,
              ),
            ),
          ),
          // Close button to end the timer prematurely.
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Colors.white,
            ),
            onPressed: () {
              userDataProvider.setShowTimerIndex(-1, -1, -1);

              widget.onClose();
            },
          ),
        ],
      ),
    );
  }
}
