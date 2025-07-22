import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/models/MonthResponseModel/extra_set_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard({
    super.key,
    required this.isCompleted,
    required this.isSkipped,
    required this.isEditMode,
    required this.exerciseIndex,
    this.onPress,
    required this.openSwapModal,
    required this.name,
    required this.exercise,
    required this.onRemove,
    required this.enabled,
    required this.exerciseData,
    required this.isCircuit,
    this.roundIndex,
    required this.exerciseId,
    required this.isDayCompleted,
    required this.isDaySkipped,
    required this.dataId,
    required this.image,
    this.exerciseList,
  });

  final bool isSkipped;
  final bool isEditMode;
  final bool isCompleted;
  final int exerciseIndex;
  final void Function(Function())? onPress;
  final void Function()? openSwapModal;
  final String name;
  final ExerciseDataModel exercise;
  final VoidCallback onRemove;
  final bool enabled;
  final bool isCircuit;
  final String exerciseData;
  final String dataId;
  final String exerciseId;
  final bool isDayCompleted;
  final bool isDaySkipped;
  final int? roundIndex;
  final String image;
  final List<ExerciseDataModel>? exerciseList;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) async => await getTotalSets());
    super.initState();
  }

  num totalSets = 0;
  int warmUpSetTotal = 0;
  int workingSetTotal = 0;
  int backOffSetTotal = 0;

  Future<void> getTotalSets() async {
    await fetchExtraSetLocalData();
    totalSets = 0;
    warmUpSetTotal = 0;
    workingSetTotal = 0;
    backOffSetTotal = 0;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {});
      }
    });

    if (widget.exercise.extra?.isNotEmpty ?? false) {
      for (var element in widget.exercise.extra!) {
        if (element.type != 1) {
          totalSets += int.parse(element.sets.toString());
        }
        if (element.type == 1) {
          warmUpSetTotal += int.parse(element.sets.toString());
        }
        if (element.type == 2) {
          backOffSetTotal += int.parse(element.sets.toString());
        }
        if (element.type == 3) {
          workingSetTotal += int.parse(element.sets.toString());
        }
      }
    }
    for (var element in extraSetModel) {
      if (element.type != 1) {
        totalSets += int.parse(element.sets.toString());
      }
      if (element.type == 1) {
        warmUpSetTotal += int.parse(element.sets.toString());
      }
      if (element.type == 2) {
        backOffSetTotal += int.parse(element.sets.toString());
      }
      if (element.type == 3) {
        workingSetTotal += int.parse(element.sets.toString());
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<ExtraSetModel> extraSetModel = [];
  fetchExtraSetLocalData() async {
    final data = await DatabaseHelper().getDataFromTable(
        tableName: DatabaseHelper.extraSetHistory,
        where: 'dataId',
        id: "EXTRA-ADDED${widget.dataId}");
    if (data.isNotEmpty) {
      extraSetModel = List<ExtraSetModel>.from(
          json.decode(jsonEncode(data)).map((x) => ExtraSetModel.fromJson(x)));
    } else {
      extraSetModel = [];
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Slidable(
      enabled: widget.isCircuit || widget.isDaySkipped || widget.isDayCompleted
          ? false
          : true,
      endActionPane: widget.isEditMode
          ? null
          : widget.isCircuit || widget.isDaySkipped || widget.isDayCompleted
              ? null
              : widget.enabled
                  ? ActionPane(
                      extentRatio: 0.35,
                      motion: const ScrollMotion(),
                      children: [
                        SizedBox(
                          width: ScreenUtil.horizontalScale(5),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(4),
                          width: ScreenUtil.verticalScale(4),
                          child: Row(
                            children: [
                              SlidableAction(
                                onPressed: (context) => widget.openSwapModal!(),
                                icon: Icons.swap_horiz,
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(0),
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil.verticalScale(3)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil.horizontalScale(5),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(4),
                          width: ScreenUtil.verticalScale(4),
                          child: Row(
                            children: [
                              SlidableAction(
                                onPressed: (context) => widget.onRemove(),
                                icon: Icons.close,
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(0),
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil.verticalScale(3)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(12)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.isEditMode
              ? () => widget.openSwapModal!()
              : widget.enabled && widget.onPress != null
                  ? () async {
                      await getTotalSets();
                      final provider =
                          Provider.of<MonthProvider>(context, listen: false);
                      widget.onPress!(
                        () async => await getTotalSets(),
                      );
                      provider.updateSetValue(
                          warmUpSetTotal, backOffSetTotal, workingSetTotal);
                    }
                  : null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).disabledColor,
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
              side: const BorderSide(color: Color(0x12000000), width: 0.5),
            ),
            surfaceTintColor: Colors.transparent,
            overlayColor: Colors.grey.shade400,
            padding: EdgeInsets.zero,
          ),
          child: Container(
            width: media.width,
            padding: EdgeInsets.only(right: ScreenUtil.verticalScale(2)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
            ),
            child: Consumer<MonthProvider>(builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  appShimmerImage(
                    height: media.width / 4,
                    width: media.width / 4,
                    networkImageUrl: widget.image,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                      bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                    ),
                    child: Container(
                      decoration: widget.isCompleted
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFAADDAA)
                                      .withValues(alpha: 0.8),
                                  const Color(0xFFAADDAA)
                                      .withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    ScreenUtil.verticalScale(12)),
                                bottomLeft: Radius.circular(
                                    ScreenUtil.verticalScale(12)),
                              ),
                            )
                          : widget.isSkipped
                              ? BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.secondColor
                                          .withValues(alpha: 0.8),
                                      AppColors.secondColor
                                          .withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        ScreenUtil.verticalScale(12)),
                                    bottomLeft: Radius.circular(
                                        ScreenUtil.verticalScale(12)),
                                  ),
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        ScreenUtil.verticalScale(12)),
                                    bottomLeft: Radius.circular(
                                        ScreenUtil.verticalScale(12)),
                                  ),
                                ),
                      child: Icon(
                        widget.isCompleted ? Icons.check : Icons.close,
                        color: widget.isCompleted || widget.isSkipped
                            ? Colors.white
                            : Colors.transparent,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(builder: (context) {
                          final data = widget.exerciseList!.where((element) =>
                              element.exerciseId != widget.exerciseId);
                          return Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            widget.name,
                            style: TextStyle(
                                color: ((widget.exercise.isAddedUpdated ??
                                                false) &&
                                            data.isNotEmpty) ||
                                        (widget.exercise.newAddedExercise ??
                                            false)
                                    ? AppColors.skipDayColor
                                    : AppColors.primaryColor,
                                fontSize: ScreenUtil.horizontalScale(3.8),
                                fontWeight: FontWeight.bold,
                                height: 1.2),
                          );
                        }),
                        /*widget.isCircuit
                            ? SizedBox()
                            : */
                        Padding(
                          padding:
                              EdgeInsets.only(top: ScreenUtil.verticalScale(1)),
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/icons/trend.svg",
                                  colorFilter: const ColorFilter.mode(
                                      Colors.grey, BlendMode.srcIn),
                                  width: ScreenUtil.verticalScale(1.8)),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "$totalSets Working set${(totalSets > 1 || totalSets == 0) ? "s" : ""}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ScreenUtil.verticalScale(1.45),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.enabled && !widget.isEditMode) ...[
                    Builder(builder: (context) {
                      final data = widget.exerciseList!.where(
                          (element) => element.exerciseId != widget.exerciseId);
                      return GestureDetector(
                        onTap: widget.enabled
                            ? () async {
                                await getTotalSets();
                                final provider = Provider.of<MonthProvider>(
                                    context,
                                    listen: false);
                                widget.onPress!(
                                  () async => await getTotalSets(),
                                );
                                provider.updateSetValue(warmUpSetTotal,
                                    backOffSetTotal, workingSetTotal);
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5))
                              .copyWith(right: 5),
                          decoration: BoxDecoration(
                            color: ((widget.exercise.isAddedUpdated ?? false) &&
                                        data.isNotEmpty) ||
                                    (widget.exercise.newAddedExercise ?? false)
                                ? AppColors.skipDayColor
                                : AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: ScreenUtil.verticalScale(3),
                          ),
                        ),
                      );
                    }),
                  ],
                  if (widget.isEditMode && !widget.isCircuit) ...[
                    Row(
                      children: [
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => widget.onRemove(),
                          child: Container(
                            padding:
                                EdgeInsets.all(ScreenUtil.verticalScale(0.8)),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: ScreenUtil.verticalScale(2.5),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => widget.openSwapModal!(),
                          child: Container(
                            padding:
                                EdgeInsets.all(ScreenUtil.verticalScale(0.8)),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: ScreenUtil.verticalScale(2.5),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
