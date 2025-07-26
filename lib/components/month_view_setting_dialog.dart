import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/radar_chart_info.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/choose_workoutday_popup.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../pages/MonthView/MonthViewPage/sections/choose_equipment_popup.dart';

class MonthSettingDialog extends StatefulWidget {
  const MonthSettingDialog({super.key, required this.monthProvider});
  final MonthProvider monthProvider;

  @override
  State<MonthSettingDialog> createState() => _MonthSettingDialogState();
}

class _MonthSettingDialogState extends State<MonthSettingDialog> {
  int splitIndex = 0;
  int equipments = 0;
  @override
  void initState() {
    String split = widget.monthProvider.splitType ?? "split3";
    String equipment = widget.monthProvider.equipmentType;
    splitIndex = split == "split3"
        ? 0
        : split == "split4"
            ? 1
            : 2;
    equipments = equipment == "A"
        ? 0
        : equipment == "B"
            ? 1
            : 2;
    super.initState();
  }

  updateSplitIndex(int index) {
    splitIndex = index;
    setState(() {});
  }

  updateEquipments(int index) {
    equipments = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.825,
                  maxHeight: MediaQuery.of(context).size.height * 0.825),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: ScreenUtil.verticalScale(1)),
                          Center(
                            child: Text(
                              "Set up your new month",
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(2.7),
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(2.5),
                                vertical: ScreenUtil.verticalScale(1.5)),
                            child: Center(
                              child: Text(
                                'Please set up the desired schedule and equipment availability for this month. Don\'t worry, these option can always be adjusted later in "Options".',
                                maxLines: 10,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: ScreenUtil.verticalScale(1.75),
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(0.8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    left: ScreenUtil.horizontalScale(3),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Choose workout frequency',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                          fontSize:
                                              ScreenUtil.verticalScale(1.5),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          AnimatedDialog.showAnimatedDialog(
                                            context: context,
                                            pageBuilder: (c1, anim1, anim2) =>
                                                ChooseWorkoutDayDialog(),
                                          );

                                          // showDialog(
                                          //   barrierDismissible: true,
                                          //   context: context,
                                          //   builder: (context) {
                                          //     return Dialog(
                                          //       shape: RoundedRectangleBorder(
                                          //         borderRadius: BorderRadius.circular(20),
                                          //       ),
                                          //       insetPadding:
                                          //           EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5)),
                                          //       child: ChooseWorkoutDayDialog(),
                                          //     );
                                          //   },
                                          // );
                                        },
                                        child: Center(
                                          child: Icon(
                                            Icons.info,
                                            size: ScreenUtil.verticalScale(2.3),
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(1.2)),
                                Consumer<MonthProvider>(
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.verticalScale(0.3)),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1.25)),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(5)),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: AppColors.greyColor,
                                            //     blurRadius: 10,
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                radius:
                                                    ScreenUtil.verticalScale(2),
                                                child: Text(
                                                  "3",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil
                                                        .verticalScale(2.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "3 days per week",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize:
                                                      ScreenUtil.verticalScale(
                                                          1.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () =>
                                                    updateSplitIndex(0),
                                                child: Container(
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: splitIndex == 0
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      size: ScreenUtil
                                                          .verticalScale(2.5),
                                                      color: splitIndex == 0
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.verticalScale(0.3)),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1.25)),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(5)),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: AppColors.greyColor,
                                            //     blurRadius: 10,
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                radius:
                                                    ScreenUtil.verticalScale(2),
                                                child: Text(
                                                  "4",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil
                                                        .verticalScale(2.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "4 days per week",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize:
                                                      ScreenUtil.verticalScale(
                                                          1.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () =>
                                                    updateSplitIndex(1),
                                                child: Container(
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  decoration: BoxDecoration(
                                                    color: splitIndex == 1
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      size: ScreenUtil
                                                          .verticalScale(2.5),
                                                      color: splitIndex == 1
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.verticalScale(0.3)),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1.25)),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(5)),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: AppColors.greyColor,
                                            //     blurRadius: 10,
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                radius:
                                                    ScreenUtil.verticalScale(2),
                                                child: Text(
                                                  "5",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil
                                                        .verticalScale(2.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "5 days per week",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize:
                                                      ScreenUtil.verticalScale(
                                                          1.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () =>
                                                    updateSplitIndex(2),
                                                child: Container(
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  decoration: BoxDecoration(
                                                    color: splitIndex == 2
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      size: ScreenUtil
                                                          .verticalScale(2.5),
                                                      color: splitIndex == 2
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(1.5)),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: ScreenUtil.horizontalScale(3)),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Choose equipment availability',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                          fontSize:
                                              ScreenUtil.verticalScale(1.5),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          AnimatedDialog.showAnimatedDialog(
                                            context: context,
                                            pageBuilder: (c1, anim1, anim2) =>
                                                ChooseEquipmentDialog(),
                                          );

                                          // showDialog(
                                          //   barrierDismissible: true,
                                          //   context: context,
                                          //   builder: (context) {
                                          //     return Dialog(
                                          //       shape: RoundedRectangleBorder(
                                          //         borderRadius: BorderRadius.circular(20),
                                          //       ),
                                          //       insetPadding:
                                          //           EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5)),
                                          //       child: ChooseEquipmentDialog(),
                                          //     );
                                          //   },
                                          // );
                                        },
                                        child: Center(
                                          child: Icon(
                                            Icons.info,
                                            size: ScreenUtil.verticalScale(2.3),
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(1.2)),
                                Consumer<MonthProvider>(
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.verticalScale(0.3)),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1.25)),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(5)),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: AppColors.greyColor,
                                            //     blurRadius: 10,
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                radius:
                                                    ScreenUtil.verticalScale(2),
                                                child: Text(
                                                  "A",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil
                                                        .verticalScale(2.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Fully equipped gym",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize:
                                                      ScreenUtil.verticalScale(
                                                          1.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () =>
                                                    updateEquipments(0),
                                                child: Container(
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  decoration: BoxDecoration(
                                                    color: equipments == 0
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      size: ScreenUtil
                                                          .verticalScale(2.5),
                                                      color: equipments == 0
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.verticalScale(0.3)),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1.25)),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(5)),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: AppColors.greyColor,
                                            //     blurRadius: 10,
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                radius:
                                                    ScreenUtil.verticalScale(2),
                                                child: Text(
                                                  "B",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil
                                                        .verticalScale(2.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Home gym",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize:
                                                      ScreenUtil.verticalScale(
                                                          1.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () =>
                                                    updateEquipments(1),
                                                child: Container(
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  decoration: BoxDecoration(
                                                    color: equipments == 1
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      size: ScreenUtil
                                                          .verticalScale(2.5),
                                                      color: equipments == 1
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.verticalScale(0.3)),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1.25)),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(5)),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: AppColors.greyColor,
                                            //     blurRadius: 10,
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                radius:
                                                    ScreenUtil.verticalScale(2),
                                                child: Text(
                                                  "C",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil
                                                        .verticalScale(2.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Dumbbells and bands",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize:
                                                      ScreenUtil.verticalScale(
                                                          1.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () =>
                                                    updateEquipments(2),
                                                child: Container(
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4),
                                                  decoration: BoxDecoration(
                                                    color: equipments == 2
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      size: ScreenUtil
                                                          .verticalScale(2.5),
                                                      color: equipments == 2
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(1.5)),
                                Consumer<MonthProvider>(
                                  builder: (context, value, child) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ScreenUtil.verticalScale(.8)),
                                      child: ButtonWidget(
                                        text: "Save",
                                        textColor: Colors.white,
                                        color: AppColors.primaryColor,
                                        onPress: () async {
                                          value.updateSettingLoader(true);

                                          String newValue1 = splitIndex == 0
                                              ? "3"
                                              : splitIndex == 1
                                                  ? "4"
                                                  : "5";

                                          String newValue2 = equipments == 0
                                              ? "A"
                                              : equipments == 1
                                                  ? "B"
                                                  : "C";

                                          await value.changeDaySplit(newValue1);
                                          value.changeEquipmentType(newValue2);
                                          await value.filterWorkouts();

                                          await value.updateLocalData();
                                          value.checkForPumpDay();
                                          value.manageStreak();
                                          value.getLiftedWeightGraphData();
                                          await preferences.putString(
                                              SharedPreference.monthSettingDone,
                                              value.monthDataModel?.id ?? "");
                                          await Future.delayed(
                                                  Duration(seconds: 1))
                                              .then(
                                            (v) {
                                              value.updateSettingLoader(false);
                                            },
                                          );

                                          Navigator.of(context).pop();

                                          Fluttertoast.showToast(
                                            msg: "Saved successfully!",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP_RIGHT,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                                AppColors.primaryColor,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        },
                                        isLoading: value.settingLoader,
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: ScreenUtil.verticalScale(0.7)),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       IconButton(
                    //         icon: const Icon(Icons.close),
                    //         onPressed: () {
                    //           Navigator.of(context).pop();
                    //         },
                    //       ),
                    //       SizedBox(width: ScreenUtil.horizontalScale(2)),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -ScreenUtil.verticalScale(1.2),
            top: -ScreenUtil.verticalScale(1.2),
            child: Align(
              alignment: Alignment.centerRight,
              child: Consumer<MonthProvider>(builder: (context, value, child) {
                return GestureDetector(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                      child: Icon(
                          size: ScreenUtil.verticalScale(2.5),
                          Icons.close,
                          color: Colors.white),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await preferences.putString(
                        SharedPreference.monthSettingDone,
                        value.monthDataModel?.id ?? "");
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
