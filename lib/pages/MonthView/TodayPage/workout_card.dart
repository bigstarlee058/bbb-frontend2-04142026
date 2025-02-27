import 'dart:convert';

import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/models/MonthResponseModel/excersie_detail_model.dart';
import 'package:bbb/models/MonthResponseModel/extra_set_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard({
    super.key,
    required this.isCompleted,
    required this.isSkipped,
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
  });

  final bool isSkipped;
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

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  String gImageUrl = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await getTotalSets());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => fetchImage());
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
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }
    if (widget.exercise.extra!.isNotEmpty) {
      for (var element in widget.exercise.extra!) {
        if (element.type != 1) {
          totalSets += int.parse(element.sets.toString());
        }
        if (element.type == 1) warmUpSetTotal += int.parse(element.sets.toString());
        if (element.type == 2) backOffSetTotal += int.parse(element.sets.toString());
        if (element.type == 3) workingSetTotal += int.parse(element.sets.toString());
      }
    }
    for (var element in extraSetModel) {
      if (element.type != 1) {
        totalSets += int.parse(element.sets.toString());
      }
      if (element.type == 1) warmUpSetTotal += int.parse(element.sets.toString());
      if (element.type == 2) backOffSetTotal += int.parse(element.sets.toString());
      if (element.type == 3) workingSetTotal += int.parse(element.sets.toString());
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    return authToken;
  }

  fetchImage() async {
    if (widget.isCircuit) {
      String? userIdToken = await getAuthToken();
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get/${widget.exerciseId}');
      url = Uri.http(url.authority, url.path);
      final response = await http.get(url, headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""});
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData != null) {
          ExerciseDetailModel exerciseDetailModelData = ExerciseDetailModel.fromJson(responseData);
          gImageUrl = exerciseDetailModelData.thumbnail ?? "placeholder";
        }
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {});
          });
        }
      }
    }
  }

  List<ExtraSetModel> extraSetModel = [];
  fetchExtraSetLocalData() async {
    final data = await DatabaseHelper().getDataFromTable(tableName: DatabaseHelper.extraSetHistory, where: 'dataId', id: widget.dataId);
    if (data.isNotEmpty) {
      extraSetModel = List<ExtraSetModel>.from(json.decode(jsonEncode(data)).map((x) => ExtraSetModel.fromJson(x)));
    } else {
      extraSetModel = [];
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Slidable(
      enabled: widget.isCircuit || widget.isDaySkipped || widget.isDayCompleted ? false : true,
      endActionPane: widget.isCircuit || widget.isDaySkipped || widget.isDayCompleted
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
                            onPressed: (context) => widget.onRemove(),
                            icon: Icons.close,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(0),
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
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
                            onPressed: (context) => widget.openSwapModal!(),
                            icon: Icons.swap_horiz,
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(0),
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
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
          onPressed: widget.enabled
              ? () async {
                  await getTotalSets();
                  final provider = Provider.of<MonthProvider>(context, listen: false);
                  widget.onPress!(
                    () async => await getTotalSets(),
                  );
                  provider.updateSetValue(warmUpSetTotal, backOffSetTotal, workingSetTotal);
                }
              : null,
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: const Color(0xFFF3F3F3),
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(ScreenUtil.verticalScale(12)),
                ),
                side: const BorderSide(
                  color: Color(0x12000000),
                  width: 0.5,
                ),
              ),
              padding: EdgeInsets.zero),
          child: Container(
            width: media.width,
            padding: EdgeInsets.only(right: ScreenUtil.verticalScale(2)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<MonthProvider>(builder: (context, value, child) {
                  return Row(
                    children: [
                      appShimmerImage(
                        height: media.width / 4,
                        width: media.width / 4,
                        networkImageUrl: widget.isCircuit ? gImageUrl : widget.image,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                          bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                        ),
                        child: Container(
                          decoration: widget.isCompleted
                              ? BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFAADDAA).withValues(alpha: 0.8),
                                      const Color(0xFFAADDAA).withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                    bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                  ),
                                )
                              : widget.isSkipped
                                  ? BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.secondColor.withValues(alpha: 0.8),
                                          AppColors.secondColor.withValues(alpha: 0.8),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                        bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      ),
                                    )
                                  : BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                        bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      ),
                                    ),
                          child: Icon(
                            widget.isCompleted ? Icons.check : Icons.close,
                            color: widget.isCompleted || widget.isSkipped ? Colors.white : Colors.transparent,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: media.width / 2.5,
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                color: (widget.exercise.isAddedUpdated ?? false) ? AppColors.skipDayColor : AppColors.primaryColor,
                                fontSize: widget.isCircuit ? ScreenUtil.horizontalScale(3) : ScreenUtil.horizontalScale(3.8),
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.verticalScale(1.5),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 8, 2),
                                child: SvgPicture.asset(
                                  "assets/icons/trend.svg",
                                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                                  width: 20,
                                ),
                              ),
                              Text(
                                "$totalSets working set${totalSets > 1 ? "s" : ""}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: widget.isCircuit ? ScreenUtil.verticalScale(1.3) : ScreenUtil.verticalScale(1.5),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  );
                }),
                if (widget.enabled) ...[
                  GestureDetector(
                    onTap: widget.enabled
                        ? () async {
                            await getTotalSets();
                            final provider = Provider.of<MonthProvider>(context, listen: false);
                            widget.onPress!(
                              () async => await getTotalSets(),
                            );
                            provider.updateSetValue(warmUpSetTotal, backOffSetTotal, workingSetTotal);
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
                      decoration: BoxDecoration(
                        color: (widget.exercise.isAddedUpdated ?? false) ? AppColors.skipDayColor : AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: ScreenUtil.verticalScale(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
