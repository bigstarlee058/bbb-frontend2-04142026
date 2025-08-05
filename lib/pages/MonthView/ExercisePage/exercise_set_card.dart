import 'dart:async';
import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/choice_clip.dart';
import 'package:bbb/custom/expansion_panel.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/history_data_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/MonthView/ExercisePage/time_progress.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    required this.scrollController,
    required this.isExtraSet,
    required this.onRemovePress,
    required this.isKG,
  });

  final Color color;
  final String title;
  final String exerciseName;
  final ExtraDataModel extraDataModel;
  final bool isOpened;
  // final int exercise;
  final int set;
  final double weight;
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
  final VoidCallback onRemovePress;
  final bool isEditable;
  final bool available;
  final bool completed;
  final bool isFromNotification;
  final bool isExtraSet;
  final bool isKG;
  final ScrollController scrollController;

  @override
  State<ExerciseSetCard> createState() => _ExerciseSetCardState();
}

class _ExerciseSetCardState extends State<ExerciseSetCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  MonthProvider? monthProvider;
  bool _isExpanded = false;
  bool timerCompleted = false;
  bool _showTimer = false;
  bool setCompleted = false;
  bool isAvailable = false;

  double weight = 0;
  int reps = 0;
  int effort = 100;
  int _restDuration = 0;
  int type = 0;
  int load = 0;
  int index = 0;
  int subIndex = 0;
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();

  late TextEditingController _weightController;
  late TextEditingController _repsController;
  List<String> effortValue = ["0", "1", "2", "3", "4+"];
  String dataId = "";
  final GlobalKey _cardKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    weight = widget.weight;
    _weightController = TextEditingController(
        text: weight.toString().isEmpty
            ? "0"
            : widget.isKG
                ? Utils.formatDouble(weight * 0.45359237)
                : Utils.formatDouble(weight));
    reps = widget.reps;
    _repsController = TextEditingController(
        text: reps.toString().isEmpty ? "0" : reps.toString());
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
    String split = monthProvider?.monthDataModel
            ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";
    dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${monthProvider?.exerciseDetailModel?.sId}-$index-$subIndex-${monthProvider?.circuitIndex}";
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

    String split = monthProvider?.monthDataModel
            ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";
    dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${monthProvider?.exerciseDetailModel?.sId}-$index-$subIndex-${monthProvider?.circuitIndex}";
    HistoryDataModel? expandedDataHistory =
        monthProvider?.historyDataModel.firstWhere(
      (element) => element.dataId == dataId,
      orElse: () => HistoryDataModel(),
    );
    if (expandedDataHistory?.id != null && expandedDataHistory != null) {
      _repsController.text = expandedDataHistory.reps ?? "5";

      _weightController = TextEditingController(
          text: weight.toString().isEmpty
              ? "0"
              : widget.isKG
                  ? Utils.formatDouble(
                      double.parse(expandedDataHistory.weight ?? "5") *
                          0.45359237)
                  : Utils.formatDouble(
                      double.parse(expandedDataHistory.weight ?? "5")));

      effort = (expandedDataHistory.effort == null
          ? widget.repsInReverse
          : int.parse(expandedDataHistory.effort ?? "0"));
      weight = double.parse(expandedDataHistory.weight!.isEmpty
          ? "0"
          : Utils.formatDouble(
              double.parse(expandedDataHistory.weight ?? "5")));
      reps = int.parse(expandedDataHistory.reps!.isEmpty
          ? "0"
          : expandedDataHistory.reps ?? "5");
      // setCompleted = expandedDataHistory.status == "Completed";
    } else {
      _weightController = TextEditingController(
          text: weight.toString().isEmpty
              ? "0"
              : widget.isKG
                  ? Utils.formatDouble(weight * 0.45359237)
                  : Utils.formatDouble(weight));

      _repsController = TextEditingController(
          text: reps.toString().isEmpty ? "0" : reps.toString());
      effort = widget.repsInReverse;
      weight = widget.weight;
      reps = widget.reps;
      _restDuration = widget.restDuration;
    }
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      setState(() => isLoad = false);
    }
    // });

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
      _weightController.text = Utils.formatDouble(weight);
    });
  }

  void decrementWeight() {
    setState(() {
      int weight1 = int.tryParse(_weightController.text) ?? 0;
      weight = (weight1 > 5) ? weight1 - 5 : 0;
      _weightController.text = Utils.formatDouble(weight);
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
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => setState(() {}));
    widget.makeRefresh();
  }

  Future<void> _saveData() async {
    // HapticFeedBack.buttonClick();

    bool isKg = widget.isKG;

    _handleCloseTimer();
    monthProvider?.timerAddress = "";
    monthProvider?.timePassed = "";

    _showTimer = false;

    int lastDataMainIndex = widget.index;
    int lastDataSubIndex = widget.countIndex;
    if (lastDataSubIndex ==
        ((monthProvider!.selectedExercise!.extra![lastDataMainIndex].sets! -
                1) +
            (monthProvider!.selectedExercise!.extra![lastDataMainIndex].type ==
                    3
                ? (widget.extraSetLength)
                : 0))) {
      lastDataMainIndex += 1;
      if (lastDataMainIndex ==
              (monthProvider!.selectedExercise!.extra!.length) &&
          lastDataSubIndex == (widget.setCount - 1)) {
      } else {
        lastDataSubIndex = 0;
      }
    } else {
      lastDataSubIndex += 1;
    }
    monthProvider?.updateExpandedItem(
        "$lastDataMainIndex:$lastDataSubIndex:${monthProvider?.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}");

    reps = int.tryParse(_repsController.text) ?? 0;
    weight = double.tryParse(_weightController.text) ?? 0;

    String split = monthProvider?.monthDataModel
            ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    double weightValue = _weightController.text.isEmpty
        ? 0
        : widget.isKG
            ? (double.tryParse(_weightController.text) ?? 0) / 0.45359237
            : double.tryParse(_weightController.text) ?? 0;

    final body = {
      "dataId": dataId,
      "split": split,
      "exerciseId": monthProvider?.exerciseDetailModel?.sId.toString(),
      "extraId": widget.extraDataModel.id.toString(),
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider
          ?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "sets": widget.extraDataModel.sets.toString(),
      "reps":
          _repsController.text.isEmpty ? 0 : _repsController.text.toString(),
      "weight": weightValue.toString(),
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
      "dayId": monthProvider
          ?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "sets": widget.extraDataModel.sets.toString(),
      "reps":
          _repsController.text.isEmpty ? 0 : _repsController.text.toString(),
      "weight": weightValue.toString(),
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
    HistoryDataModel? matchingElement = monthProvider?.historyDataModel
        .firstWhere((element) => element.dataId == dataId,
            orElse: () => HistoryDataModel());

    final data1 = {
      "sets": widget.extraDataModel.sets.toString(),
      "reps":
          _repsController.text.isEmpty ? "0" : _repsController.text.toString(),
      "weight": weightValue.toString(),
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
      "reps":
          _repsController.text.isEmpty ? "0" : _repsController.text.toString(),
      "weight": weightValue.toString(),
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
      await DatabaseHelper().updateData(
          data: data1, tableName: DatabaseHelper.exerciseHistory, id: dataId);
    } else {
      ApiRepo.addExerciseHistory(body: apiReqBody);
      await DatabaseHelper()
          .insertData(data: body, tableName: DatabaseHelper.exerciseHistory);
    }

    monthProvider?.setShowTimerIndex(
        index, widget.countIndex, monthProvider!.selectedExIndex,
        removeVal: true);
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
    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => monthProvider?.fetchExerciseHistroy());
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.select((MonthProvider value) => value.currentExpandedItem);
    context.select((MonthProvider value) => value.timerAddress);
    context.select((MonthProvider value) => value.selectedExIndex);
    _isExpanded =
        "$index:${widget.countIndex}:${monthProvider!.selectedExIndex}:${monthProvider?.overviewCurrentWeek}:${monthProvider?.overviewCurrentDay}" ==
            monthProvider!.currentExpandedItem;
    if (monthProvider!.timerAddress.isNotEmpty &&
        _restDuration != 0 &&
        monthProvider!.timerAddress != "") {
      _showTimer = monthProvider!.timerAddress ==
          "$index-${widget.countIndex}-${monthProvider!.selectedExIndex}-${monthProvider!.overviewCurrentWeek}-${monthProvider!.overviewCurrentDay}";
      if (_showTimer) {
        monthProvider!.setShowTimerIndex(
            index, widget.countIndex, monthProvider!.selectedExIndex);
      }
    } else {
      _showTimer = false;
    }

    if (isLoad) {
      return SizedBox();
    } else {
      return Column(
        key: _cardKey,
        children: [
          Theme(
            data: ThemeData().copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
              child: ExpansionPanelList(
                sidePadding: false,
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
                    // monthProvider?.setShowTimerIndex(-1, -1, -1);

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
                      return ColorFiltered(
                        colorFilter: widget.available ||
                                widget.completed ||
                                setCompleted ||
                                _showTimer ||
                                timerCompleted ||
                                _isExpanded
                            ? ColorFilter.mode(
                                Colors.transparent, BlendMode.saturation)
                            : ColorFilter.mode(
                                Colors.white.withValues(alpha: 0.55),
                                BlendMode.saturation),
                        child: Container(
                          color: widget.color,
                          padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: ScreenUtil.horizontalScale(4)),
                          child: GestureDetector(
                            onTap: () async {
                              if (widget.available ||
                                  widget.completed ||
                                  setCompleted) {
                                _showTimer = false;
                                // await monthProvider?.setShowTimerIndex(
                                //     -1, -1, -1);
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          color: _isExpanded
                                              ? Colors.transparent
                                              : Colors.black38,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.completed ||
                                    timerCompleted ||
                                    setCompleted)
                                  Container(
                                    padding: EdgeInsets.all(
                                        ScreenUtil.verticalScale(0.5)),
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.green, width: 3),
                                      color: Colors.green,
                                    ),
                                    child: Icon(Icons.check,
                                        size: ScreenUtil.verticalScale(2.2),
                                        color: Colors.white),
                                  ),
                                Container(
                                  decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  child: Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_outlined
                                        : Icons.keyboard_arrow_down_outlined,
                                    color: Colors.white,
                                    size: 33,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    body: Container(
                      color: widget.color,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(4)),
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
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 13),
                                  ),
                                  Text(
                                    ' $load% ${widget.type == 1 ? "of the working load" : ""}',
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'WEIGHT (${widget.isKG ? "KG" : "LB"})',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        constraints: BoxConstraints(
                                            minWidth:
                                                ScreenUtil.horizontalScale(30)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ScreenUtil.horizontalScale(1.5),
                                          vertical:
                                              ScreenUtil.verticalScale(0.3),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    maxLines: 1,
                                                    maxLength: 6,
                                                    controller:
                                                        _weightController,
                                                    onTapOutside: (event) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      if (_weightController
                                                          .text.isEmpty) {
                                                        _weightController.text =
                                                            "0";
                                                        setState(() {});
                                                      }
                                                    },
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*')),
                                                    ],
                                                    keyboardType: /*Platform
                                                                .isAndroid
                                                            ?*/
                                                        TextInputType
                                                            .numberWithOptions(
                                                                decimal:
                                                                    true) /*
                                                            : const TextInputType
                                                                .numberWithOptions(
                                                                decimal: false,
                                                                signed: true)*/
                                                    ,
                                                    onSubmitted: (value) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    },
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    textAlign: TextAlign.center,
                                                    focusNode: _nodeText1,
                                                    cursorColor:
                                                        AppColors.primaryColor,
                                                    readOnly: widget.isEditable
                                                        ? false
                                                        : true,
                                                    decoration:
                                                        const InputDecoration(
                                                      counterText: '',
                                                      border: InputBorder.none,
                                                    ),
                                                    onTap: () async {
                                                      if (_weightController
                                                          .text.isEmpty) {
                                                        _weightController.text =
                                                            "0";
                                                        setState(() {});
                                                      }
                                                      // await weightOnTap(
                                                      //     context);
                                                    },
                                                    onEditingComplete: () {
                                                      if (_weightController
                                                          .text.isEmpty) {
                                                        _weightController.text =
                                                            "0";
                                                        setState(() {});
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      if (value.isNotEmpty &&
                                                          value[0] == "0") {
                                                        _weightController.text =
                                                            value.replaceFirst(
                                                                "0", "");
                                                      }

                                                      if (value.isEmpty) {
                                                        _weightController.text =
                                                            "0";
                                                        setState(() {});
                                                      }
                                                      if (_weightController
                                                          .text.isEmpty) {
                                                        _weightController.text =
                                                            "0";
                                                        setState(() {});
                                                      }
                                                    },
                                                    // inputFormatters: [
                                                    //   FilteringTextInputFormatter
                                                    //       .digitsOnly,
                                                    //   TextInputFormatter
                                                    //       .withFunction(
                                                    //     (oldValue,
                                                    //         newValue) {
                                                    //       String newText =
                                                    //           newValue.text;
                                                    //       if (newText
                                                    //           .isNotEmpty) {
                                                    //         newText = newText
                                                    //             .replaceFirst(
                                                    //                 RegExp(
                                                    //                     r'^0+'),
                                                    //                 '');
                                                    //       }
                                                    //       return TextEditingValue(
                                                    //         text: newText,
                                                    //         selection: TextSelection
                                                    //             .collapsed(
                                                    //                 offset:
                                                    //                     newText.length),
                                                    //       );
                                                    //     },
                                                    //   ),
                                                    // ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'REPS',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ScreenUtil.horizontalScale(1.5),
                                          vertical:
                                              ScreenUtil.verticalScale(0.3),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
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
                                                onPressed: widget.isEditable
                                                    ? decrementReps
                                                    : null,
                                              ),
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _repsController,
                                                focusNode: _nodeText2,
                                                maxLength: 6,
                                                cursorColor:
                                                    AppColors.primaryColor,
                                                keyboardType: /*Platform
                                                            .isAndroid
                                                        ?*/
                                                    TextInputType
                                                        .numberWithOptions(
                                                            decimal: true)
                                                /*: const TextInputType
                                                            .numberWithOptions(
                                                            decimal: false,
                                                            signed: true)*/
                                                ,
                                                textInputAction:
                                                    TextInputAction.done,
                                                textAlign: TextAlign.center,
                                                readOnly: false,
                                                decoration:
                                                    const InputDecoration(
                                                  counterText: '',
                                                  border: InputBorder.none,
                                                ),
                                                onChanged: (value) {
                                                  if (value.isNotEmpty &&
                                                      value[0] == "0") {
                                                    _repsController.text = value
                                                        .replaceFirst("0", "");
                                                  }
                                                  if (_repsController
                                                      .text.isEmpty) {
                                                    _repsController.text = "0";
                                                    setState(() {});
                                                  }
                                                  if (value.isEmpty) {
                                                    _repsController.text = "0";
                                                    setState(() {});
                                                  }
                                                },
                                                onFieldSubmitted: (value) {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  if (value.isEmpty) {
                                                    _repsController.text = "0";
                                                    setState(() {});
                                                  }
                                                },
                                                onTapOutside: (event) {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  if (_repsController
                                                      .text.isEmpty) {
                                                    _repsController.text = "0";
                                                    setState(() {});
                                                  }
                                                },
                                                onTap: () async {
                                                  await repsOnTap(context);
                                                },
                                                // inputFormatters: [
                                                //   FilteringTextInputFormatter
                                                //       .digitsOnly,
                                                //   TextInputFormatter
                                                //       .withFunction(
                                                //     (oldValue, newValue) {
                                                //       String newText =
                                                //           newValue.text;
                                                //       if (newText
                                                //           .isNotEmpty) {
                                                //         newText = newText
                                                //             .replaceFirst(
                                                //                 RegExp(
                                                //                     r'^0+'),
                                                //                 '');
                                                //       }
                                                //       return TextEditingValue(
                                                //         text: newText,
                                                //         selection: TextSelection
                                                //             .collapsed(
                                                //                 offset: newText
                                                //                     .length),
                                                //       );
                                                //     },
                                                //   ),
                                                // ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 38,
                                              child: IconButton(
                                                icon: const Icon(Icons.add),
                                                color: AppColors.primaryColor,
                                                onPressed: widget.isEditable
                                                    ? incrementReps
                                                    : null,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'REPS IN RESERVE',
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                backgroundColor: Colors.white,
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          5,
                                          (index) {
                                            return Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                ChoiceChip1(
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          6),
                                                  label: effortValue[index],
                                                  selected: effort == index,
                                                  onSelected: () {
                                                    widget.isEditable
                                                        ? selectEffort(
                                                            effort != index
                                                                ? index
                                                                : 100)
                                                        : null;
                                                  },
                                                  labelStyle: TextStyle(
                                                      color: effort == index
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                            if (widget.isEditable &&
                                monthProvider!.isCurrentMonth != "Future")
                              ButtonWidget(
                                text: _restDuration != 0
                                    ? "Save & start rest timer"
                                    : "Save",
                                // text: "Save",
                                textColor: Colors.white,
                                onPress: _saveData,
                                color: AppColors.primaryColor,
                                isLoading: false,
                              )
                            else
                              ButtonWidget(
                                text: _restDuration != 0
                                    ? "Save & start rest timer"
                                    : "Save",
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
          if (widget.isExtraSet)
            GestureDetector(
              onTap: () {
                widget.onRemovePress();
              },
              child: Container(
                margin: EdgeInsets.only(top: 4, right: 10),
                height: 20,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Remove set",
                      style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(1.5),
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade600,
                      ),
                    )),
              ),
            )
        ],
      );
    }
  }

  Future<void> repsOnTap(BuildContext context) async {
    if (_repsController.text == "0") {
      _repsController.clear();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (_cardKey.currentContext != null) {
      final box = _cardKey.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero, ancestor: null);
      final double safeAreaTop = MediaQuery.of(context).padding.top;
      final double appBarHeight =
          Scaffold.maybeOf(context)?.appBarMaxHeight ?? kToolbarHeight;
      final double desiredTop = safeAreaTop + appBarHeight + 8;
      final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final double offset = widget.scrollController.offset +
          position.dy -
          desiredTop +
          keyboardHeight;
      widget.scrollController.animateTo(
        offset < 0 ? 0 : offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> weightOnTap(BuildContext context) async {
    if (_weightController.text == "0") {
      _weightController.clear();
    }
    await repsOnTap(context);
  }
}
