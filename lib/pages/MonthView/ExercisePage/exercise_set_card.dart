import 'dart:async';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/choice_clip.dart';
import 'package:bbb/components/expansion_panel.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/history_data_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/MonthView/ExercisePage/time_progress.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

import 'notes_slideout.dart';

class ExerciseSetCard extends StatefulWidget {
  const ExerciseSetCard({
    super.key,
    required this.title,
    required this.isOpened,
    // required this.exercise,
    required this.set,
    required this.weight,
    required this.reps,
    required this.repsInReverse,
    required this.restDuration,
    required this.type,
    required this.load,
    required this.index,
    required this.subIndex,
    required this.countIndex,
    required this.exerciseName,
    required this.color,
    required this.extraDataModel,
    required this.makeRefresh,
    required this.isEditable,
    required this.available,
    required this.completed,
    required this.isFromNotification,
    required this.setCount,
    required this.extraSetLength,
    required this.totalRIRSet,
  });

  final Color color;
  final String title;
  final String exerciseName;
  final ExtraDataModel extraDataModel;
  final bool isOpened;
  // final int exercise;
  final int set;
  final int weight;
  final int reps;
  final int countIndex;
  final int repsInReverse;
  final int restDuration;
  final int type;
  final int load;
  final int index;
  final int subIndex;
  final int setCount;
  final int extraSetLength;
  final int totalRIRSet;
  final VoidCallback makeRefresh;
  final bool isEditable;
  final bool available;
  final bool completed;
  final bool isFromNotification;

  @override
  State<ExerciseSetCard> createState() => _ExerciseSetCardState();
}

class _ExerciseSetCardState extends State<ExerciseSetCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  MonthProvider? monthProvider;
  bool _isExpanded = false;
  bool timerCompleted = false;
  bool _showTimer = false;
  bool setCompleted = false;
  bool isAvailable = false;

  int weight = 0;
  int reps = 0;
  int effort = 100;
  int _restDuration = 0;
  int type = 0;
  int load = 0;
  int index = 0;
  int subIndex = 0;
  final FocusNode _nodeText1 = FocusNode();

  late TextEditingController _weightController;
  late TextEditingController _repsController;
  List<String> effortValue = ["0", "1", "2", "3", "4+"];
  String dataId = "";
  @override
  void initState() {
    super.initState();

    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    weight = widget.weight;
    _weightController = TextEditingController(text: weight.toString().isEmpty ? "0" : weight.toString());
    reps = widget.reps;
    _repsController = TextEditingController(text: reps.toString().isEmpty ? "0" : reps.toString());
    effort = widget.repsInReverse;
    _restDuration = widget.restDuration;
    type = widget.type;
    load = widget.load;
    index = widget.index;
    subIndex = widget.countIndex;
    monthProvider!.fetchTimerAddress();
    setCompletedOrNot();

    setData();
  }

  bool isLoad = false;
  String indexString = "";

  setCompletedOrNot() async {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
    dataId =
        "$split-${monthProvider?.selectedExercise?.id}-${monthProvider?.exerciseDetailModel?.sId}-$index-$subIndex-${monthProvider?.circuitIndex}";
    await monthProvider?.fetchSingleSetLocalData(dataId).then(
      (value) {
        if (value?.status == Status.completed) {
          setCompleted = true;
        }
      },
    );
  }

  setData() async {
    isLoad = true;
    indexString = "";
    setState(() {});
    await monthProvider?.fetchExerciseHistoryLocalData();

    await preferences.putString(SharedPreference.isPause, "false");

    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
    dataId =
        "$split-${monthProvider?.selectedExercise?.id}-${monthProvider?.exerciseDetailModel?.sId}-$index-$subIndex-${monthProvider?.circuitIndex}";
    HistoryDataModel? expandedDataHistory = monthProvider?.historyDataModel.firstWhere(
      (element) => element.dataId == dataId,
      orElse: () => HistoryDataModel(),
    );
    if (expandedDataHistory?.id != null && expandedDataHistory != null) {
      _repsController.text = expandedDataHistory.reps ?? "5";
      _weightController.text = expandedDataHistory.weight ?? "5";
      effort = (expandedDataHistory.effort == null ? widget.repsInReverse : int.parse(expandedDataHistory.effort ?? "0"));
      weight = int.parse(expandedDataHistory.weight!.isEmpty ? "0" : expandedDataHistory.weight ?? "5");
      reps = int.parse(expandedDataHistory.reps!.isEmpty ? "0" : expandedDataHistory.reps ?? "5");
      // setCompleted = expandedDataHistory.status == "Completed";
    } else {
      _weightController = TextEditingController(text: weight.toString().isEmpty ? "0" : weight.toString());
      _repsController = TextEditingController(text: reps.toString().isEmpty ? "0" : reps.toString());
      effort = widget.repsInReverse;
      weight = widget.weight;
      reps = widget.reps;
      _restDuration = widget.restDuration;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => isLoad = false);
      }
    });

    widget.makeRefresh();
    // if (widget.isFromNotification) {
    //   await fromNotification();
    // }
  }

  void _handleTimerComplete() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        timerCompleted = true;
      });
      widget.makeRefresh();
    });
  }

  void incrementWeight() {
    setState(() {
      int weight1 = int.tryParse(_weightController.text) ?? 0;
      weight = weight1 + 5;
      _weightController.text = '$weight';
    });
  }

  void decrementWeight() {
    setState(() {
      int weight1 = int.tryParse(_weightController.text) ?? 0;
      weight = (weight1 > 5) ? weight1 - 5 : 0;
      _weightController.text = '$weight';
    });
  }

  void decrementLoad() {
    setState(() {
      load = (load > 5) ? load - 5 : 0;
    });
  }

  void incrementLoad() {
    setState(() {
      load = load + 5;
    });
  }

  void incrementReps() {
    setState(() {
      int reps1 = int.tryParse(_repsController.text) ?? 0;
      reps = reps1 + 1;
      _repsController.text = '$reps';
    });
  }

  void decrementReps() {
    setState(() {
      int reps1 = int.tryParse(_repsController.text) ?? 0;
      reps = (reps1 > 5) ? reps1 - 1 : 0;
      _repsController.text = '$reps';
    });
  }

  void selectEffort(int value) {
    setState(() {
      effort = value;
    });
  }

  Future<void> _handleCloseTimer() async {
    _showTimer = false;
    await monthProvider?.setShowTimerIndex(-1, -1, -1);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    widget.makeRefresh();
  }

  Future<void> _saveData() async {
    HapticFeedBack.buttonClick();
    _handleCloseTimer();
    monthProvider?.timerAddress = "";
    monthProvider?.timePassed = "";

    _showTimer = false;

    int lastDataMainIndex = widget.index;
    int lastDataSubIndex = widget.countIndex;
    if (lastDataSubIndex ==
        ((monthProvider!.selectedExercise!.extra![lastDataMainIndex].sets! - 1) +
            (monthProvider!.selectedExercise!.extra![lastDataMainIndex].type == 3 ? (widget.extraSetLength) : 0))) {
      lastDataMainIndex += 1;
      if (lastDataMainIndex == (monthProvider!.selectedExercise!.extra!.length) && lastDataSubIndex == (widget.setCount - 1)) {
      } else {
        lastDataSubIndex = 0;
      }
    } else {
      lastDataSubIndex += 1;
    }
    monthProvider?.updateExpandedItem(
        "$lastDataMainIndex:$lastDataSubIndex:${monthProvider?.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}");

    reps = int.tryParse(_repsController.text) ?? 0;
    weight = int.tryParse(_weightController.text) ?? 0;

    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    final body = {
      "dataId": dataId,
      "split": split,
      "exerciseId": monthProvider?.exerciseDetailModel?.sId.toString(),
      "extraId": widget.extraDataModel.id.toString(),
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "sets": widget.extraDataModel.sets.toString(),
      "reps": _repsController.text.isEmpty ? 0 : _repsController.text.toString(),
      "weight": _weightController.text.isEmpty ? 0 : _weightController.text.toString(),
      "rest": widget.extraDataModel.rest.toString(),
      "load": load.toString(),
      "type": widget.extraDataModel.type.toString(),
      "effort": effort.toString(),
      "index": widget.index,
      "subIndex": widget.countIndex,
      "date": "${DateTime.now().toUtc()}",
      "status": Status.completed,
      "totalSet": widget.totalRIRSet
      // "status": _restDuration == 0 ? Status.completed : Status.empty
    };

    final apiReqBody = {
      "dataId": dataId,
      "split": split,
      "exerciseId": monthProvider?.exerciseDetailModel?.sId.toString(),
      "extraId": widget.extraDataModel.id.toString(),
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "sets": widget.extraDataModel.sets.toString(),
      "reps": _repsController.text.isEmpty ? 0 : _repsController.text.toString(),
      "weight": _weightController.text.isEmpty ? 0 : _weightController.text.toString(),
      "rest": widget.extraDataModel.rest.toString(),
      "load": load.toString(),
      "type": widget.extraDataModel.type.toString(),
      "effort": effort.toString(),
      "index": "${widget.index}",
      "subIndex": "${widget.countIndex}",
      "date": "${DateTime.now().toUtc()}",
      "status": Status.completed,
      "totalSet": widget.totalRIRSet.toString(),
      // "status": _restDuration == 0 ? Status.completed : Status.empty
    };

    await monthProvider?.fetchExerciseHistoryLocalData();
    HistoryDataModel? matchingElement =
        monthProvider?.historyDataModel.firstWhere((element) => element.dataId == dataId, orElse: () => HistoryDataModel());

    final data1 = {
      "sets": widget.extraDataModel.sets.toString(),
      "reps": _repsController.text.isEmpty ? "0" : _repsController.text.toString(),
      "weight": _weightController.text.isEmpty ? "0" : _weightController.text.toString(),
      "rest": widget.extraDataModel.rest.toString(),
      "load": load.toString(),
      "type": widget.extraDataModel.type.toString(),
      "effort": effort.toString(),
      "date": "${DateTime.now().toUtc()}",
      "status": Status.completed,
      "totalSet": widget.totalRIRSet
      // "status": matchingElement?.status ?? (_restDuration == 0 ? Status.completed : Status.empty)
    };

    final apiReqBody1 = {
      "sets": widget.extraDataModel.sets.toString(),
      "reps": _repsController.text.isEmpty ? "0" : _repsController.text.toString(),
      "weight": _weightController.text.isEmpty ? "0" : _weightController.text.toString(),
      "rest": widget.extraDataModel.rest.toString(),
      "load": load.toString(),
      "type": widget.extraDataModel.type.toString(),
      "effort": effort.toString(),
      "date": "${DateTime.now().toUtc()}",
      "status": Status.completed,
      "totalSet": widget.totalRIRSet.toString(),
      "dataId": dataId,
      // "status": matchingElement?.status ?? (_restDuration == 0 ? Status.completed : Status.empty)
    };

    if (matchingElement?.id != null) {
      ApiRepo.updateExerciseHistory(body: apiReqBody1);
      await DatabaseHelper().updateData(data: data1, tableName: DatabaseHelper.exerciseHistory, id: dataId);
    } else {
      ApiRepo.addExerciseHistory(body: apiReqBody);
      await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.exerciseHistory);
    }

    monthProvider?.setShowTimerIndex(index, widget.countIndex, monthProvider!.selectedExIndex, removeVal: true);
    if (_restDuration != 0) {
      _showTimer = true;
      setCompleted = true;
      setState(() {});
      await monthProvider?.fetchExerciseSingleSetLocalData(dataId);
      await monthProvider?.fetchExerciseHistoryLocalData();
    } else {
      setCompleted = true;
      setState(() {});
      await monthProvider?.fetchExerciseSingleSetLocalData(dataId);
      await monthProvider?.fetchExerciseHistoryLocalData();
    }
  }

  // Future<void> fromNotification() async {
  //   await monthProvider?.fetchExerciseHistoryLocalData();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
  //   widget.makeRefresh();
  // }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.white,
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          displayArrows: false,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.primaryColor),
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.select((MonthProvider value) => value.currentExpandedItem);
    context.select((MonthProvider value) => value.timerAddress);
    context.select((MonthProvider value) => value.selectedExIndex);
    _isExpanded =
        "$index:${widget.countIndex}:${monthProvider!.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}" ==
            monthProvider!.currentExpandedItem;

    if (monthProvider!.timerAddress.isNotEmpty && _restDuration != 0 && monthProvider!.timerAddress != "") {
      _showTimer = monthProvider!.timerAddress ==
          "$index-${widget.countIndex}-${monthProvider!.selectedExIndex}-${monthProvider!.overviewCurrentWeek}-${monthProvider!.overviewCurrentDay}";
      if (_showTimer) {
        monthProvider!.setShowTimerIndex(index, widget.countIndex, monthProvider!.selectedExIndex);
      }
    } else {
      _showTimer = false;
    }

    return isLoad
        ? SizedBox()
        : Column(
            children: [
              ColorFiltered(
                colorFilter: widget.available || widget.completed || setCompleted || _showTimer || timerCompleted || _isExpanded
                    ? ColorFilter.mode(Colors.transparent, BlendMode.saturation)
                    : ColorFilter.mode(Colors.white.withValues(alpha: 0.55), BlendMode.saturation),
                child: Theme(
                  data: ThemeData().copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
                    child: ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 900),
                      expandIconColor: widget.color,
                      materialGapSize: 10,
                      expandedHeaderPadding: EdgeInsets.zero,
                      expansionCallback: (panelIndex, isExpanded) {
                        if (widget.available || widget.completed || setCompleted) {
                          // _showTimer = false;
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                          monthProvider?.setShowTimerIndex(-1, -1, -1);
                          monthProvider?.updateExpandedItem(!_isExpanded
                              ? "${widget.index}:${widget.countIndex}:${monthProvider!.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}"
                              : "");
                          setState(() {});
                        }
                      },
                      elevation: 1,
                      children: [
                        ExpansionPanel(
                          highlightColor: widget.color,
                          backgroundColor: widget.color,
                          splashColor: widget.color,
                          isTrailing: false,
                          isExpanded: _isExpanded,
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) {
                            return Container(
                              color: widget.color,
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: ScreenUtil.horizontalScale(4)),
                              child: GestureDetector(
                                onTap: () async {
                                  if (widget.available || widget.completed || setCompleted) {
                                    _showTimer = false;
                                    await monthProvider?.setShowTimerIndex(-1, -1, -1);
                                    await monthProvider?.updateExpandedItem(!_isExpanded
                                        ? "${widget.index}:${widget.countIndex}:${monthProvider!.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}"
                                        : "");

                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${widget.title} ${widget.subIndex + 1}",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          Text(
                                            _isExpanded ? "" : '$reps reps',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: _isExpanded ? Colors.transparent : Colors.black38,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.completed || timerCompleted || setCompleted)
                                      Container(
                                        padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.green, width: 3),
                                          color: Colors.green,
                                        ),
                                        child: Icon(Icons.check, size: ScreenUtil.verticalScale(2.2), color: Colors.white),
                                      ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: AppColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(25))),
                                      child: Icon(
                                        _isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined,
                                        color: Colors.white,
                                        size: 33,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          body: Container(
                            color: widget.color,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(4)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (load == 0 && widget.type == 3)
                                    SizedBox()
                                  else ...[
                                    Row(
                                      children: [
                                        const Text(
                                          'LOAD :',
                                          style: TextStyle(color: Colors.black54, fontSize: 13),
                                        ),
                                        Text(
                                          ' $load% ${widget.type == 1 ? "of the working load" : ""}',
                                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'WEIGHT (LB)',
                                              style: TextStyle(color: Colors.black54, fontSize: 13),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              constraints: BoxConstraints(minWidth: ScreenUtil.horizontalScale(30)),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.03),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: ScreenUtil.horizontalScale(1.5),
                                                vertical: ScreenUtil.verticalScale(0.3),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // SizedBox(
                                                  //   width: 38,
                                                  //   child: IconButton(
                                                  //     icon: const Icon(Icons.remove),
                                                  //     color: AppColors.primaryColor,
                                                  //     onPressed: widget.isEditable ? decrementWeight : null,
                                                  //   ),
                                                  // ),
                                                  Expanded(
                                                    child: KeyboardActions(
                                                      autoScroll: false,
                                                      config: _buildConfig(context),
                                                      child: TextField(
                                                        controller: _weightController,
                                                        keyboardType: TextInputType.number,
                                                        onSubmitted: (value) {
                                                          FocusScope.of(context).unfocus();
                                                        },
                                                        textInputAction: TextInputAction.done,
                                                        textAlign: TextAlign.center,
                                                        focusNode: _nodeText1,
                                                        readOnly: widget.isEditable ? false : true,
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                        ),
                                                        onTap: () {
                                                          if (_weightController.text == "0") {
                                                            _weightController.clear();
                                                          }
                                                        },
                                                        onEditingComplete: () {
                                                          if (_weightController.text == "0") {
                                                            _weightController.clear();
                                                          }
                                                          if (_weightController.text.isEmpty) {
                                                            _weightController.text = "0";
                                                            setState(() {});
                                                          }
                                                        },
                                                        onChanged: (value) {
                                                          if (value == "0") {
                                                            _weightController.clear();
                                                          }
                                                          if (value.isEmpty) {
                                                            _weightController.text = "0";
                                                            setState(() {});
                                                          }
                                                        },
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.digitsOnly,
                                                          TextInputFormatter.withFunction(
                                                            (oldValue, newValue) {
                                                              String newText = newValue.text;
                                                              if (newText.isNotEmpty) {
                                                                newText = newText.replaceFirst(RegExp(r'^0+'), '');
                                                              }
                                                              return TextEditingValue(
                                                                text: newText,
                                                                selection: TextSelection.collapsed(offset: newText.length),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // SizedBox(
                                                  //   width: 38,
                                                  //   child: IconButton(
                                                  //     icon: const Icon(Icons.add),
                                                  //     color: AppColors.primaryColor,
                                                  //     onPressed: widget.isEditable ? incrementWeight : null,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'REPS',
                                              style: TextStyle(color: Colors.black54, fontSize: 13),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: ScreenUtil.horizontalScale(1.5),
                                                vertical: ScreenUtil.verticalScale(0.3),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.03),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 38,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.remove),
                                                      color: AppColors.primaryColor,
                                                      onPressed: widget.isEditable ? decrementReps : null,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: _repsController,
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
                                                      textInputAction: TextInputAction.done,
                                                      textAlign: TextAlign.center,
                                                      readOnly: true,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                      ),
                                                      onChanged: (value) {
                                                        if (value.isEmpty) {
                                                          _repsController.text = "0";
                                                          setState(() {});
                                                        }
                                                      },
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                        TextInputFormatter.withFunction(
                                                          (oldValue, newValue) {
                                                            String newText = newValue.text;
                                                            if (newText.isNotEmpty) {
                                                              newText = newText.replaceFirst(RegExp(r'^0+'), '');
                                                            }
                                                            return TextEditingValue(
                                                              text: newText,
                                                              selection: TextSelection.collapsed(offset: newText.length),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 38,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.add),
                                                      color: AppColors.primaryColor,
                                                      onPressed: widget.isEditable ? incrementReps : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  widget.type == 1
                                      ? SizedBox()
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'REPS IN RESERVE',
                                                  style: TextStyle(color: Colors.black54, fontSize: 13),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      backgroundColor: Colors.white,
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return const NotesSlideout();
                                                      },
                                                    );
                                                  },
                                                  child: const Text(
                                                    "WHAT'S RIR?",
                                                    style: TextStyle(
                                                      color: AppColors.skipDayColor,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: List.generate(
                                                5,
                                                (index) {
                                                  return Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      ChoiceChip1(
                                                        width: ScreenUtil.verticalScale(6),
                                                        label: effortValue[index],
                                                        selected: effort == index,
                                                        onSelected: () {
                                                          widget.isEditable ? selectEffort(effort != index ? index : 100) : null;
                                                        },
                                                        labelStyle: TextStyle(color: effort == index ? Colors.white : Colors.black),
                                                      ),
                                                      // Positioned(
                                                      //   top: 0.5,
                                                      //   left: index == 4 ? 0.5 : 3,
                                                      //   child: RotatedBox(
                                                      //     quarterTurns: 2,
                                                      //     child: CustomPaint(
                                                      //       size: Size(index == 4 ? 50 : 42, 12),
                                                      //       painter: TrianglePainter(),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                          ],
                                        ),
                                  if (widget.isEditable)
                                    ButtonWidget(
                                      text: _restDuration != 0 ? "Save & start rest timer" : "Save",
                                      // text: "Save",
                                      textColor: Colors.white,
                                      onPress: _saveData,
                                      color: AppColors.primaryColor,
                                      isLoading: false,
                                    )
                                  else
                                    ButtonWidget(
                                      text: _restDuration != 0 ? "Save & start rest timer" : "Save",
                                      // text: "Save",
                                      textColor: Colors.white,
                                      onPress: null,
                                      color: AppColors.primaryColor,
                                      isLoading: false,
                                    ),
                                  SizedBox(
                                    height: ScreenUtil.verticalScale(2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ColorFiltered(
              //   colorFilter: widget.available || widget.completed || setCompleted || _showTimer || timerCompleted
              //       ? ColorFilter.mode(Colors.transparent, BlendMode.saturation)
              //       : ColorFilter.mode(Colors.white.withValues(alpha: 0.45), BlendMode.saturation),
              //   child: Container(
              //     decoration: /*_showTimer
              //         ? BoxDecoration(
              //             borderRadius: const BorderRadius.only(
              //               topLeft: Radius.circular(30),
              //               topRight: Radius.circular(30),
              //               bottomLeft: Radius.zero,
              //               bottomRight: Radius.zero,
              //             ),
              //             color: widget.color,
              //           )
              //         :*/
              //         BoxDecoration(
              //       borderRadius: BorderRadius.circular(30),
              //       color: widget.color,
              //     ),
              //     child: Column(
              //       children: [
              //         Container(
              //           padding: EdgeInsets.symmetric(vertical: 15, horizontal: ScreenUtil.horizontalScale(4)),
              //           child: GestureDetector(
              //             onTap: () async {
              //               if (widget.available || widget.completed || setCompleted) {
              //                 _showTimer = false;
              //                 await monthProvider?.setShowTimerIndex(-1, -1, -1);
              //                 await monthProvider?.updateExpandedItem(!_isExpanded
              //                     ? "${widget.index}:${widget.countIndex}:${monthProvider!.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}"
              //                     : "");
              //
              //                 setState(() {
              //                   _isExpanded = !_isExpanded;
              //                 });
              //               }
              //             },
              //             child: Row(
              //               children: [
              //                 Expanded(
              //                   child: Row(
              //                     children: [
              //                       Column(
              //                         crossAxisAlignment: CrossAxisAlignment.start,
              //                         children: [
              //                           Text(
              //                             "${widget.title} ${widget.subIndex + 1}",
              //                             style: GoogleFonts.plusJakartaSans(
              //                               color: AppColors.primaryColor,
              //                               fontSize: 13,
              //                               fontWeight: FontWeight.bold,
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                       const SizedBox(width: 20),
              //                       Text(
              //                         _isExpanded ? "" : '$reps reps',
              //                         style: GoogleFonts.plusJakartaSans(
              //                           color: _isExpanded ? Colors.transparent : Colors.black38,
              //                           fontSize: 13,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //                 if (widget.completed || timerCompleted || setCompleted)
              //                   Container(
              //                     padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
              //                     margin: const EdgeInsets.only(right: 10),
              //                     decoration: BoxDecoration(
              //                       shape: BoxShape.circle,
              //                       border: Border.all(color: Colors.green, width: 3),
              //                       color: Colors.green,
              //                     ),
              //                     child: Icon(Icons.check, size: ScreenUtil.verticalScale(2.2), color: Colors.white),
              //                   ),
              //                 Container(
              //                   decoration: const BoxDecoration(
              //                       color: AppColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(25))),
              //                   child: Icon(
              //                     _isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined,
              //                     color: Colors.white,
              //                     size: 33,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //         if (_isExpanded)
              //           Padding(
              //             padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(4)),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 if (load == 0 && widget.type == 3)
              //                   SizedBox()
              //                 else ...[
              //                   Row(
              //                     children: [
              //                       const Text(
              //                         'LOAD :',
              //                         style: TextStyle(color: Colors.black54, fontSize: 13),
              //                       ),
              //                       Text(
              //                         ' $load% ${widget.type == 1 ? "of the working load" : ""}',
              //                         style: const TextStyle(color: Colors.black54, fontSize: 14),
              //                       ),
              //                     ],
              //                   ),
              //                   const SizedBox(height: 20),
              //                 ],
              //                 Row(
              //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         const Text(
              //                           'WEIGHT (LB)',
              //                           style: TextStyle(color: Colors.black54, fontSize: 13),
              //                         ),
              //                         const SizedBox(height: 8),
              //                         Container(
              //                           decoration: BoxDecoration(
              //                             color: Colors.white,
              //                             boxShadow: [
              //                               BoxShadow(
              //                                 color: Colors.black.withValues(alpha: 0.03),
              //                                 spreadRadius: 2,
              //                                 blurRadius: 5,
              //                                 offset: const Offset(0, 3),
              //                               ),
              //                             ],
              //                           ),
              //                           padding: EdgeInsets.symmetric(
              //                             horizontal: ScreenUtil.horizontalScale(1.5),
              //                             vertical: ScreenUtil.verticalScale(0.3),
              //                           ),
              //                           child: Row(
              //                             children: [
              //                               SizedBox(
              //                                 width: 38,
              //                                 child: IconButton(
              //                                   icon: const Icon(Icons.remove),
              //                                   color: AppColors.primaryColor,
              //                                   onPressed: widget.isEditable ? decrementWeight : null,
              //                                 ),
              //                               ),
              //                               SizedBox(
              //                                 width: 35,
              //                                 child: KeyboardActions(
              //                                   autoScroll: false,
              //                                   config: _buildConfig(context),
              //                                   child: TextField(
              //                                     controller: _weightController,
              //                                     keyboardType: TextInputType.number,
              //                                     onSubmitted: (value) {
              //                                       FocusScope.of(context).unfocus();
              //                                     },
              //                                     textInputAction: TextInputAction.done,
              //                                     textAlign: TextAlign.center,
              //                                     focusNode: _nodeText1,
              //                                     readOnly: widget.isEditable ? false : true,
              //                                     decoration: const InputDecoration(
              //                                       border: InputBorder.none,
              //                                     ),
              //                                     onChanged: (value) {
              //                                       if (value.isEmpty) {
              //                                         _weightController.text = "0";
              //                                         setState(() {});
              //                                       }
              //                                     },
              //                                     inputFormatters: [
              //                                       FilteringTextInputFormatter.digitsOnly,
              //                                       TextInputFormatter.withFunction(
              //                                         (oldValue, newValue) {
              //                                           String newText = newValue.text;
              //                                           if (newText.isNotEmpty) {
              //                                             newText = newText.replaceFirst(RegExp(r'^0+'), '');
              //                                           }
              //                                           return TextEditingValue(
              //                                             text: newText,
              //                                             selection: TextSelection.collapsed(offset: newText.length),
              //                                           );
              //                                         },
              //                                       ),
              //                                     ],
              //                                   ),
              //                                 ),
              //                               ),
              //                               SizedBox(
              //                                 width: 38,
              //                                 child: IconButton(
              //                                   icon: const Icon(Icons.add),
              //                                   color: AppColors.primaryColor,
              //                                   onPressed: widget.isEditable ? incrementWeight : null,
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                     Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         const Text(
              //                           'REPS',
              //                           style: TextStyle(color: Colors.black54, fontSize: 13),
              //                         ),
              //                         const SizedBox(height: 8),
              //                         Container(
              //                           padding: EdgeInsets.symmetric(
              //                             horizontal: ScreenUtil.horizontalScale(1.5),
              //                             vertical: ScreenUtil.verticalScale(0.3),
              //                           ),
              //                           decoration: BoxDecoration(
              //                             color: Colors.white,
              //                             boxShadow: [
              //                               BoxShadow(
              //                                 color: Colors.black.withValues(alpha: 0.03),
              //                                 spreadRadius: 2,
              //                                 blurRadius: 5,
              //                                 offset: const Offset(0, 3),
              //                               ),
              //                             ],
              //                           ),
              //                           child: Row(
              //                             children: [
              //                               SizedBox(
              //                                 width: 38,
              //                                 child: IconButton(
              //                                   icon: const Icon(Icons.remove),
              //                                   color: AppColors.primaryColor,
              //                                   onPressed: widget.isEditable ? decrementReps : null,
              //                                 ),
              //                               ),
              //                               SizedBox(
              //                                 width: 35,
              //                                 child: TextFormField(
              //                                   controller: _repsController,
              //                                   keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
              //                                   textInputAction: TextInputAction.done,
              //                                   textAlign: TextAlign.center,
              //                                   readOnly: true,
              //                                   decoration: const InputDecoration(
              //                                     border: InputBorder.none,
              //                                   ),
              //                                   onChanged: (value) {
              //                                     if (value.isEmpty) {
              //                                       _repsController.text = "0";
              //                                       setState(() {});
              //                                     }
              //                                   },
              //                                   inputFormatters: [
              //                                     FilteringTextInputFormatter.digitsOnly,
              //                                     TextInputFormatter.withFunction(
              //                                       (oldValue, newValue) {
              //                                         String newText = newValue.text;
              //                                         if (newText.isNotEmpty) {
              //                                           newText = newText.replaceFirst(RegExp(r'^0+'), '');
              //                                         }
              //                                         return TextEditingValue(
              //                                           text: newText,
              //                                           selection: TextSelection.collapsed(offset: newText.length),
              //                                         );
              //                                       },
              //                                     ),
              //                                   ],
              //                                 ),
              //                               ),
              //                               SizedBox(
              //                                 width: 38,
              //                                 child: IconButton(
              //                                   icon: const Icon(Icons.add),
              //                                   color: AppColors.primaryColor,
              //                                   onPressed: widget.isEditable ? incrementReps : null,
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ],
              //                 ),
              //                 const SizedBox(height: 24),
              //                 widget.type == 1
              //                     ? SizedBox()
              //                     : Column(
              //                         children: [
              //                           Row(
              //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                             children: [
              //                               const Text(
              //                                 'REPS IN RESERVE',
              //                                 style: TextStyle(color: Colors.black54, fontSize: 13),
              //                               ),
              //                               GestureDetector(
              //                                 onTap: () {
              //                                   showModalBottomSheet(
              //                                     backgroundColor: Colors.white,
              //                                     context: context,
              //                                     isScrollControlled: true,
              //                                     builder: (BuildContext context) {
              //                                       return const NotesSlideout();
              //                                     },
              //                                   );
              //                                 },
              //                                 child: const Text(
              //                                   "WHAT'S RIR?",
              //                                   style: TextStyle(
              //                                     color: AppColors.skipDayColor,
              //                                     fontSize: 13,
              //                                   ),
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                           const SizedBox(height: 8),
              //                           Row(
              //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                             children: List.generate(
              //                               5,
              //                               (index) {
              //                                 return Stack(
              //                                   clipBehavior: Clip.none,
              //                                   children: [
              //                                     ChoiceChip(
              //                                       label: Text(effortValue[index]),
              //                                       selected: effort == index,
              //                                       onSelected: (bool selected) {
              //                                         widget.isEditable ? selectEffort(selected ? index : 100) : null;
              //                                       },
              //                                       padding: EdgeInsets.symmetric(
              //                                         horizontal: ScreenUtil.horizontalScale(2),
              //                                         vertical: ScreenUtil.verticalScale(2),
              //                                       ),
              //                                       shape: const RoundedRectangleBorder(
              //                                         side: BorderSide(color: Colors.white),
              //                                       ),
              //                                       backgroundColor: Colors.white,
              //                                       selectedColor: AppColors.primaryColor,
              //                                       labelStyle: TextStyle(
              //                                         color: effort == index ? Colors.white : Colors.black,
              //                                       ),
              //                                       checkmarkColor: Colors.white,
              //                                       showCheckmark: true,
              //                                     ),
              //                                     // Positioned(
              //                                     //   top: 0.5,
              //                                     //   left: index == 4 ? 0.5 : 3,
              //                                     //   child: RotatedBox(
              //                                     //     quarterTurns: 2,
              //                                     //     child: CustomPaint(
              //                                     //       size: Size(index == 4 ? 50 : 42, 12),
              //                                     //       painter: TrianglePainter(),
              //                                     //     ),
              //                                     //   ),
              //                                     // ),
              //                                   ],
              //                                 );
              //                               },
              //                             ),
              //                           ),
              //                           const SizedBox(height: 30),
              //                         ],
              //                       ),
              //                 if (widget.isEditable)
              //                   ButtonWidget(
              //                     text: _restDuration != 0 ? "Save & start rest timer" : "Save",
              //                     // text: "Save",
              //                     textColor: Colors.white,
              //                     onPress: _saveData,
              //                     color: AppColors.primaryColor,
              //                     isLoading: false,
              //                   )
              //                 else
              //                   ButtonWidget(
              //                     text: _restDuration != 0 ? "Save & start rest timer" : "Save",
              //                     // text: "Save",
              //                     textColor: Colors.white,
              //                     onPress: null,
              //                     color: AppColors.primaryColor,
              //                     isLoading: false,
              //                   ),
              //                 SizedBox(
              //                   height: ScreenUtil.verticalScale(2),
              //                 ),
              //               ],
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),
              if (_showTimer && _restDuration != 0) ...[
                TimerWithProgressBar(
                  makeRefresh: () {
                    widget.makeRefresh();
                  },
                  index: "${widget.index}",
                  subIndex: "${widget.countIndex}",
                  dataId: dataId,
                  currentTime: monthProvider!.timePassed,
                  initialDuration: _restDuration,
                  onClose: _handleCloseTimer,
                  onComplete: () {
                    _handleTimerComplete();
                    widget.makeRefresh();
                  },
                ),
              ],
            ],
          );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
