import 'dart:async';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
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
    required this.exercise,
    required this.set,
    required this.weight,
    required this.reps,
    required this.repsInReverse,
    required this.restDuration,
    required this.type,
    required this.load,
    required this.index,
    required this.subIndex,
    required this.exerciseName,
    required this.color,
    required this.extraDataModel,
    required this.isCompleted,
    required this.makeRefresh,
    required this.isEditable,
  });

  final Color color;
  final String title;
  final String exerciseName;
  final ExtraDataModel extraDataModel;
  final bool isOpened;
  final bool isCompleted;
  final int exercise;
  final int set;
  final int weight;
  final int reps;
  final int repsInReverse;
  final int restDuration;
  final int type;
  final int load;
  final int index;
  final int subIndex;
  final VoidCallback makeRefresh;
  final bool isEditable;

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

  int weight = 5;
  int reps = 5;
  int effort = 100;
  int _restDuration = 30;
  int type = 1;
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
    _isExpanded = widget.isOpened;
    weight = widget.weight;
    _weightController = TextEditingController(text: weight.toString().isEmpty ? "0" : weight.toString());
    reps = widget.reps;
    _repsController = TextEditingController(text: reps.toString().isEmpty ? "0" : reps.toString());
    effort = widget.repsInReverse;
    _restDuration = widget.restDuration;
    type = widget.type;
    load = widget.load;
    index = widget.index;
    subIndex = widget.subIndex;
    monthProvider!.fetchTimerAddress();

    setData();
  }

  setData() async {
    await preferences.putString(SharedPreference.isPause, "false");
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    dataId =
        "$split-${monthProvider?.selectedExercise?.id}-${monthProvider?.exerciseDetailModel?.sId}-$index-$subIndex-${monthProvider?.circuitIndex}";

    await monthProvider?.fetchExerciseSingleSetLocalData(dataId);
    final expandedDataHistory = monthProvider?.expandedDataHistory;
    if (expandedDataHistory != null) {
      _repsController.text = expandedDataHistory.reps ?? "5";
      _weightController.text = expandedDataHistory.weight ?? "5";
      effort = (expandedDataHistory.effort == null ? widget.repsInReverse : int.parse(expandedDataHistory.effort ?? "0"));
      weight = int.parse(expandedDataHistory.weight!.isEmpty ? "0" : expandedDataHistory.weight ?? "5");
      reps = int.parse(expandedDataHistory.reps!.isEmpty ? "0" : expandedDataHistory.reps ?? "5");
    } else {
      _weightController = TextEditingController(text: weight.toString().isEmpty ? "0" : weight.toString());
      _repsController = TextEditingController(text: reps.toString().isEmpty ? "0" : reps.toString());
      effort = widget.repsInReverse;
      weight = widget.weight;
      reps = widget.reps;
      _restDuration = widget.restDuration;
    }
    setCompleted = widget.isCompleted;
    await monthProvider?.fetchExerciseHistoryLocalData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
  }

  /// TEMP COMMENT !!! DONT DELETE THIS

  // void _handleTimerComplete() {
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     setState(() {
  //       timerCompleted = true;
  //     });
  //   });
  // }

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

  /// TEMP COMMENT !!! DONT DELETE THIS

  // Future<void> _handleCloseTimer() async {
  //   _showTimer = false;
  //   await monthProvider?.setShowTimerIndex(-1, -1, -1);
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
  // }

  Future<void> _saveData() async {
    monthProvider?.timerAddress = "";
    monthProvider?.timePassed = "";
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
      "subIndex": widget.subIndex,
      "date": "${DateTime.now().toUtc()}",
      // "status": _restDuration == 0 ? Status.completed : Status.empty
      "status": Status.completed
    };

    final data1 = {
      "sets": widget.extraDataModel.sets.toString(),
      "reps": _repsController.text.isEmpty ? "0" : _repsController.text.toString(),
      "weight": _weightController.text.isEmpty ? "0" : _weightController.text.toString(),
      "rest": widget.extraDataModel.rest.toString(),
      "load": load.toString(),
      "type": widget.extraDataModel.type.toString(),
      "effort": effort.toString(),
      "date": "${DateTime.now().toUtc()}",
      // "status": _restDuration == 0 ? Status.completed : Status.empty
      "status": Status.completed
    };
    await monthProvider?.fetchExerciseHistoryLocalData();
    if (monthProvider!.historyDataModel.isNotEmpty) {
      if (monthProvider!.historyDataModel.any((element) => element.dataId == dataId)) {
        await DatabaseHelper().updateData(data: data1, tableName: DatabaseHelper.exerciseHistory, id: dataId);
      } else {
        await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.exerciseHistory);
      }
    } else {
      await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.exerciseHistory);
    }

    monthProvider?.setShowTimerIndex(index, subIndex, monthProvider!.selectedExIndex, removeVal: true);
    // if (_restDuration != 0) {
    //   _showTimer = true;
    // }
    // setCompleted = _restDuration == 0 ? true : false;

    _showTimer = false;
    setCompleted = true;

    setState(() {});
    await monthProvider?.fetchExerciseSingleSetLocalData(dataId);
    await monthProvider?.fetchExerciseHistoryLocalData();
  }

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
    _isExpanded = "$index:$subIndex" == monthProvider!.currentExpandedItem;

    if (monthProvider!.timerAddress.isNotEmpty && _restDuration != 0 && monthProvider!.timerAddress != "") {
      _showTimer = monthProvider!.timerAddress ==
          "$index-$subIndex-${monthProvider!.selectedExIndex}-${monthProvider!.overviewCurrentWeek}-${monthProvider!.overviewCurrentDay}";
      if (_showTimer) {
        monthProvider!.setShowTimerIndex(index, subIndex, monthProvider!.selectedExIndex);
      }
    } else {
      _showTimer = false;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: _showTimer
                ? BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                    color: widget.color,
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.color,
                  ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: ScreenUtil.horizontalScale(4)),
                  child: GestureDetector(
                    onTap: () async {
                      _showTimer = false;
                      await monthProvider?.setShowTimerIndex(-1, -1, -1);
                      await monthProvider?.updateExpandedItem(!_isExpanded ? "${widget.index}:${widget.subIndex}" : "");

                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
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
                                    "${widget.title} ${subIndex + 1}",
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
                                // _isExpanded ? "" : '$weight lbs       $reps reps',
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
                        if (timerCompleted || setCompleted)
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
                          decoration:
                              const BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(25))),
                          child: Icon(
                            _isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined,
                            color: Colors.white,
                            size: 33,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded)
                  Padding(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WEIGHT (LB)',
                                  style: TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Container(
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
                                    children: [
                                      SizedBox(
                                        width: 38,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove),
                                          color: AppColors.primaryColor,
                                          onPressed: widget.isEditable ? decrementWeight : null,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 35,
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
                                            onChanged: (value) {
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
                                      SizedBox(
                                        width: 38,
                                        child: IconButton(
                                          icon: const Icon(Icons.add),
                                          color: AppColors.primaryColor,
                                          onPressed: widget.isEditable ? incrementWeight : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
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
                                      SizedBox(
                                        width: 35,
                                        child: TextFormField(
                                          controller: _repsController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
                                          textInputAction: TextInputAction.done,
                                          textAlign: TextAlign.center,
                                          // readOnly: widget.isEditable ? false : true,
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
                                    children: List.generate(5, (index) {
                                      return ChoiceChip(
                                        label: Text(effortValue[index]),
                                        selected: effort == index,
                                        onSelected: (bool selected) {
                                          widget.isEditable ? selectEffort(selected ? index : 100) : null;
                                        },
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil.horizontalScale(2),
                                          vertical: ScreenUtil.verticalScale(2),
                                        ),
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.white,
                                        selectedColor: AppColors.primaryColor,
                                        labelStyle: TextStyle(
                                          color: effort == index ? Colors.white : Colors.black,
                                        ),
                                        checkmarkColor: Colors.white,
                                        showCheckmark: true,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                        if (widget.isEditable)
                          ButtonWidget(
                            // text: _restDuration != 0 ? "Save & start rest timer" : "Save",
                            text: "Save",
                            textColor: Colors.white,
                            onPress: _saveData,
                            color: AppColors.primaryColor,
                            isLoading: false,
                          )
                        else
                          ButtonWidget(
                            // text: _restDuration != 0 ? "Save & start rest timer" : "Save",
                            text: "Save",
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
              ],
            ),
          ),

          /// TEMP COMMENT !!! DONT DELETE THIS

          // if (_showTimer && _restDuration != 0) ...[
          //   TimerWithProgressBar(
          //     dataId: dataId,
          //     // isTimerRunning: widget.isTimerRunning,
          //     currentTime: monthProvider!.timePassed,
          //     initialDuration: _restDuration,
          //     onClose: _handleCloseTimer,
          //     onComplete: _handleTimerComplete,
          //   ),
          // ],
        ],
      ),
    );
  }
}
