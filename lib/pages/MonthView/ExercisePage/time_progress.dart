import 'dart:async';

import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimerWithProgressBar extends StatefulWidget {
  final int initialDuration;
  final VoidCallback onClose;
  final VoidCallback onComplete;
  final VoidCallback makeRefresh;
  final String currentTime;
  final String dataId;
  final String index;
  final String subIndex;

  // final bool isTimerRunning;

  const TimerWithProgressBar({
    super.key,
    required this.initialDuration,
    required this.onClose,
    required this.onComplete,
    required this.currentTime,
    // required this.isTimerRunning,
    required this.dataId,
    required this.subIndex,
    required this.index,
    required this.makeRefresh,
  });

  @override
  State<TimerWithProgressBar> createState() => _TimerWithProgressBarState();
}

class _TimerWithProgressBarState extends State<TimerWithProgressBar> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late MonthProvider monthProvider;

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    timerOnInit();
    super.initState();
  }

  late int totalTime;
  late int currentTime;
  late AnimationController controller;
  late String formattedTime;

  Timer? timerTimer;
  bool isPaused = false;
  bool animationCompleted = false;
  String? previousData;

  timerOnInit() {
    NotificationService.clearNotification();
    totalTime = widget.initialDuration;
    WidgetsBinding.instance.addObserver(this);
    currentTime = 0;
    formattedTime = _formatTime(widget.initialDuration - currentTime);

    previousData = monthProvider.currentExpandedItem;

    controller = AnimationController(vsync: this, duration: Duration(seconds: totalTime));

    controller.addStatusListener(
      (status) async {
        if (status == AnimationStatus.completed) {
          animationCompleted = true;
          widget.onComplete();
          // ApiRepo.updateExerciseHistory(body: {"dataId": widget.dataId, "status": "Completed"});
          await DatabaseHelper()
              .updateSingleValue(
                  tableName: DatabaseHelper.exerciseHistory, id: widget.dataId, columnName: 'status', newValue: Status.completed)
              .then(
                (value) async => await monthProvider.fetchExerciseHistoryLocalData().then((value) => widget.makeRefresh()),
              );
        }
      },
    );

    startTimer();
  }

  void startTimer() async {
    await monthProvider.getPassedTime();
    if (monthProvider.timePassed != "") {
      currentTime = int.parse(monthProvider.timePassed);
    }
    if (widget.initialDuration > currentTime) {
      timerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isPaused) {
          formattedTime = _formatTime(widget.initialDuration - currentTime);

          currentTime++;
          if (!animationCompleted && currentTime <= totalTime) {
            controller.value = currentTime / totalTime;
          }
          setState(() {});
          if (currentTime == totalTime && !animationCompleted) {
            controller.forward();
            widget.onComplete();
          }
        }
        if (widget.initialDuration < currentTime) {
          isPaused = true;
          controller.stop();
        }
      });
    } else {
      // ApiRepo.updateExerciseHistory(body: {"dataId": widget.dataId, "status": "Completed"});
      await DatabaseHelper()
          .updateSingleValue(tableName: DatabaseHelper.exerciseHistory, id: widget.dataId, columnName: 'status', newValue: Status.completed)
          .then(
            (value) async => await monthProvider.fetchExerciseHistoryLocalData(),
          );

      formattedTime = _formatTime(widget.initialDuration - widget.initialDuration);
      isPaused = true;
      controller.stop();
      widget.makeRefresh();
    }

    setState(() {});
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> pauseOrResumeTimer() async {
    if (isPaused) {
      if (widget.initialDuration > currentTime) {
        isPaused = false;
        if (!animationCompleted) {
          controller.forward();
          await preferences.putString(SharedPreference.isPause, "false");
        }
      }
    } else {
      isPaused = true;
      controller.stop();
      await preferences.putString(SharedPreference.isPause, "true");
    }
    setState(() {});
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        NotificationService.clearNotification();
        await monthProvider.getPassedTime();
        if (monthProvider.timePassed != "") {
          currentTime = 0;

          currentTime = int.parse(monthProvider.timePassed);

          if (int.parse(monthProvider.timePassed) > totalTime) {
            // ApiRepo.updateExerciseHistory(body: {"dataId": widget.dataId, "status": "Completed"});
            await DatabaseHelper()
                .updateSingleValue(
                    tableName: DatabaseHelper.exerciseHistory, id: widget.dataId, columnName: 'status', newValue: Status.completed)
                .then(
                  (value) async => await monthProvider.fetchExerciseHistoryLocalData().then(
                        (value) => widget.makeRefresh(),
                      ),
                );
          }
        }
        setState(() {});
        break;
      case AppLifecycleState.inactive:
        monthProvider.savePassedTime(currentTime.toString(), widget.initialDuration, context, widget.dataId, widget.index, widget.subIndex);
        break;
      case AppLifecycleState.paused:
        monthProvider.savePassedTime(currentTime.toString(), widget.initialDuration, context, widget.dataId, widget.index, widget.subIndex);
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    monthProvider.savePassedTime(currentTime.toString(), widget.initialDuration, context, widget.dataId, widget.index, widget.subIndex);
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    timerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: currentTime >= totalTime * 0.9 ? const Color(0xff008000) : AppColors.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: LinearProgressIndicator(
              value: currentTime <= totalTime ? currentTime / totalTime : 1.0,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 3,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 45,
            height: 30,
            child: ElevatedButton(
              onPressed: pauseOrResumeTimer,
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
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Colors.white,
            ),
            onPressed: () async {
              currentTime = 0;
              setState(() {});
              widget.onClose();
            },
          ),
        ],
      ),
    );
  }
}
