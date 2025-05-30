import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/expansion_panel.dart' as com;
import 'package:bbb/pages/MonthView/MonthViewPage/sections/choose_equipment_popup.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/choose_workoutday_popup.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SettingSection extends StatefulWidget {
  const SettingSection({super.key, required this.monthProvider, required this.isSetting});
  final MonthProvider monthProvider;
  final bool isSetting;
  @override
  State<SettingSection> createState() => _SettingSectionState();
}

class _SettingSectionState extends State<SettingSection> {
  int splitIndex = 0;
  int equipments = 0;
  DataProvider? dataProvider;
  bool isSplit = false;
  bool isEquipment = false;
  int curExpandedIdx = 0;
  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await dataProvider?.fetchTutorialData());
    super.initState();
  }

  updateSplitIndex(int index) async {
    splitIndex = index;
    setState(() {});
    if (widget.isSetting) {
      String newValue1 = splitIndex == 0
          ? "3"
          : splitIndex == 1
              ? "4"
              : "5";

      await widget.monthProvider.changeDaySplit(newValue1);
      await widget.monthProvider.filterWorkouts();
      await widget.monthProvider.updateLocalData();
      await widget.monthProvider.checkForPumpDay();
      await widget.monthProvider.manageStreak();
      await widget.monthProvider.getLiftedWeightGraphData();
    }
  }

  updateEquipments(int index) async {
    equipments = index;
    setState(() {});
    if (widget.isSetting) {
      String newValue2 = equipments == 0
          ? "A"
          : equipments == 1
              ? "B"
              : "C";
      widget.monthProvider.changeEquipmentType(newValue2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSetting == true
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(3), vertical: ScreenUtil.verticalScale(2.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Theme(
                  data: ThemeData().copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(0)),
                    child: Padding(
                      padding: EdgeInsets.only(right: ScreenUtil.horizontalScale(3)),
                      child: com.ExpansionPanelList(
                        sidePadding: false,
                        animationDuration: Duration(milliseconds: 300),
                        expandIconColor: AppColors.primaryColor,
                        materialGapSize: 10,
                        expandedHeaderPadding: EdgeInsets.zero,
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            isSplit = isExpanded;
                            curExpandedIdx = isExpanded ? 0 : -1;
                          });
                        },
                        elevation: 0,
                        children: [
                          com.ExpansionPanel(
                              backgroundColor: Colors.white,
                              isExpanded: isSplit,
                              canTapOnHeader: true,
                              headerBuilder: (context, isExpanded) {
                                return Padding(
                                  padding: EdgeInsets.only(left: ScreenUtil.horizontalScale(0)),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(3),
                                        ),
                                        child: Text(
                                          'Default Split',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                    ],
                                  ),
                                );
                              },
                              body: Consumer<MonthProvider>(
                                builder: (context, value, child) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(3),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Choose workout day split',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: const Color(0xBB888888),
                                                fontSize: ScreenUtil.verticalScale(1.7),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  barrierDismissible: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      insetPadding: EdgeInsets.symmetric(horizontal: 25),
                                                      child: ChooseWorkoutDayDialog(),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Center(
                                                child: Icon(
                                                  Icons.info,
                                                  size: ScreenUtil.verticalScale(2.3),
                                                  color: const Color(0xBB888888),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                                        padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.greyColor,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppColors.primaryColor,
                                              radius: ScreenUtil.verticalScale(2),
                                              child: Text(
                                                "3",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.verticalScale(2.5),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "3 Days per Week",
                                              style: TextStyle(
                                                color: const Color(0xBB888888),
                                                fontSize: ScreenUtil.verticalScale(1.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () => updateSplitIndex(0),
                                              child: Container(
                                                height: ScreenUtil.verticalScale(4),
                                                width: ScreenUtil.verticalScale(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: splitIndex == 0 ? AppColors.primaryColor : Colors.transparent,
                                                  border: Border.all(color: AppColors.primaryColor),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.done,
                                                    size: ScreenUtil.verticalScale(2.5),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                                        padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.greyColor,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppColors.primaryColor,
                                              radius: ScreenUtil.verticalScale(2),
                                              child: Text(
                                                "4",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.verticalScale(2.5),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "4 Days per Week",
                                              style: TextStyle(
                                                color: const Color(0xBB888888),
                                                fontSize: ScreenUtil.verticalScale(1.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () => updateSplitIndex(1),
                                              child: Container(
                                                height: ScreenUtil.verticalScale(4),
                                                width: ScreenUtil.verticalScale(4),
                                                decoration: BoxDecoration(
                                                  color: splitIndex == 1 ? AppColors.primaryColor : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppColors.primaryColor),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.done,
                                                    size: ScreenUtil.verticalScale(2.5),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                                        padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.greyColor,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppColors.primaryColor,
                                              radius: ScreenUtil.verticalScale(2),
                                              child: Text(
                                                "5",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.verticalScale(2.5),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "5 Days per Week",
                                              style: TextStyle(
                                                color: const Color(0xBB888888),
                                                fontSize: ScreenUtil.verticalScale(1.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () => updateSplitIndex(2),
                                              child: Container(
                                                height: ScreenUtil.verticalScale(4),
                                                width: ScreenUtil.verticalScale(4),
                                                decoration: BoxDecoration(
                                                  color: splitIndex == 2 ? AppColors.primaryColor : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppColors.primaryColor),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.done,
                                                    size: ScreenUtil.verticalScale(2.5),
                                                    color: Colors.white,
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
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: EdgeInsets.fromLTRB(ScreenUtil.horizontalScale(3), 0, ScreenUtil.horizontalScale(3), 0),
                  child: Divider(
                    thickness: 0.3,
                    height: 0,
                  ),
                ),
                const SizedBox(height: 22),
                Theme(
                  data: ThemeData().copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(0)),
                    child: Padding(
                      padding: EdgeInsets.only(right: ScreenUtil.horizontalScale(3)),
                      child: com.ExpansionPanelList(
                        sidePadding: false,
                        animationDuration: Duration(milliseconds: 300),
                        expandIconColor: AppColors.primaryColor,
                        materialGapSize: 10,
                        expandedHeaderPadding: EdgeInsets.zero,
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            isEquipment = isExpanded;
                            curExpandedIdx = isExpanded ? 0 : -1;
                          });
                        },
                        elevation: 0,
                        children: [
                          com.ExpansionPanel(
                            backgroundColor: Colors.white,
                            isExpanded: isEquipment,
                            canTapOnHeader: true,
                            headerBuilder: (context, isExpanded) {
                              return Padding(
                                padding: EdgeInsets.only(left: ScreenUtil.horizontalScale(0)),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: ScreenUtil.horizontalScale(3),
                                      ),
                                      child: Text(
                                        'Default Equipment',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(width: 4),
                                  ],
                                ),
                              );
                            },
                            body: Consumer<MonthProvider>(
                              builder: (context, value, child) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: ScreenUtil.horizontalScale(3),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Choose equipment availability',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: const Color(0xBB888888),
                                              fontSize: ScreenUtil.verticalScale(1.7),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    insetPadding: EdgeInsets.symmetric(horizontal: 25),
                                                    child: ChooseWorkoutDayDialog(),
                                                  );
                                                },
                                              );
                                            },
                                            child: Center(
                                              child: Icon(
                                                Icons.info,
                                                size: ScreenUtil.verticalScale(2.3),
                                                color: const Color(0xBB888888),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                                      padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.greyColor,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primaryColor,
                                            radius: ScreenUtil.verticalScale(2),
                                            child: Text(
                                              "A",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2.5),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Fully equipped gym",
                                            style: TextStyle(
                                              color: const Color(0xBB888888),
                                              fontSize: ScreenUtil.verticalScale(1.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () => updateEquipments(0),
                                            child: Container(
                                              height: ScreenUtil.verticalScale(4),
                                              width: ScreenUtil.verticalScale(4),
                                              decoration: BoxDecoration(
                                                color: equipments == 0 ? AppColors.primaryColor : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.primaryColor),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.done,
                                                  size: ScreenUtil.verticalScale(2.5),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                                      padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.greyColor,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primaryColor,
                                            radius: ScreenUtil.verticalScale(2),
                                            child: Text(
                                              "B",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2.5),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Home gym",
                                            style: TextStyle(
                                              color: const Color(0xBB888888),
                                              fontSize: ScreenUtil.verticalScale(1.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () => updateEquipments(1),
                                            child: Container(
                                              height: ScreenUtil.verticalScale(4),
                                              width: ScreenUtil.verticalScale(4),
                                              decoration: BoxDecoration(
                                                color: equipments == 1 ? AppColors.primaryColor : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.primaryColor),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.done,
                                                  size: ScreenUtil.verticalScale(2.5),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                                      padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.greyColor,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primaryColor,
                                            radius: ScreenUtil.verticalScale(2),
                                            child: Text(
                                              "C",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2.5),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Dumbbells and bands",
                                            style: TextStyle(
                                              color: const Color(0xBB888888),
                                              fontSize: ScreenUtil.verticalScale(1.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () => updateEquipments(2),
                                            child: Container(
                                              height: ScreenUtil.verticalScale(4),
                                              width: ScreenUtil.verticalScale(4),
                                              decoration: BoxDecoration(
                                                color: equipments == 2 ? AppColors.primaryColor : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.primaryColor),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.done,
                                                  size: ScreenUtil.verticalScale(2.5),
                                                  color: Colors.white,
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
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil.horizontalScale(3),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Choose workout day split',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: const Color(0xBB888888),
                          fontSize: ScreenUtil.verticalScale(1.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                insetPadding: EdgeInsets.symmetric(horizontal: 25),
                                child: ChooseWorkoutDayDialog(),
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Icon(
                            Icons.info,
                            size: ScreenUtil.verticalScale(2.3),
                            color: const Color(0xBB888888),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<MonthProvider>(
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: ScreenUtil.verticalScale(2),
                                child: Text(
                                  "3",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "3 Days per Week",
                                style: TextStyle(
                                  color: const Color(0xBB888888),
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => updateSplitIndex(0),
                                child: Container(
                                  height: ScreenUtil.verticalScale(4),
                                  width: ScreenUtil.verticalScale(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: splitIndex == 0 ? AppColors.primaryColor : Colors.transparent,
                                    border: Border.all(color: AppColors.primaryColor),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.done,
                                      size: ScreenUtil.verticalScale(2.5),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: ScreenUtil.verticalScale(2),
                                child: Text(
                                  "4",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "4 Days per Week",
                                style: TextStyle(
                                  color: const Color(0xBB888888),
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => updateSplitIndex(1),
                                child: Container(
                                  height: ScreenUtil.verticalScale(4),
                                  width: ScreenUtil.verticalScale(4),
                                  decoration: BoxDecoration(
                                    color: splitIndex == 1 ? AppColors.primaryColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryColor),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.done,
                                      size: ScreenUtil.verticalScale(2.5),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: ScreenUtil.verticalScale(2),
                                child: Text(
                                  "5",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "5 Days per Week",
                                style: TextStyle(
                                  color: const Color(0xBB888888),
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => updateSplitIndex(2),
                                child: Container(
                                  height: ScreenUtil.verticalScale(4),
                                  width: ScreenUtil.verticalScale(4),
                                  decoration: BoxDecoration(
                                    color: splitIndex == 2 ? AppColors.primaryColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryColor),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.done,
                                      size: ScreenUtil.verticalScale(2.5),
                                      color: Colors.white,
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
                // Consumer<MonthProvider>(
                //   builder: (context, value, child) => SelectDropdown1(
                //     onChange: (String newValue) async {
                //       await value.changeDaySplit(newValue);
                //       await value.filterWorkouts();
                //       await value.updateLocalData();
                //       await value.checkForPumpDay();
                //       await value.manageStreak();
                //       await value.getLiftedWeightGraphData();
                //     },
                //   ),
                // ),
                const SizedBox(height: 25),
                Container(
                  margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(3)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Choose equipment availability',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: const Color(0xBB888888),
                          fontSize: ScreenUtil.verticalScale(1.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                insetPadding: EdgeInsets.symmetric(horizontal: 25),
                                child: ChooseEquipmentDialog(),
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Icon(
                            Icons.info,
                            size: ScreenUtil.verticalScale(2.3),
                            color: const Color(0xBB888888),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Consumer<MonthProvider>(
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: ScreenUtil.verticalScale(2),
                                child: Text(
                                  "A",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Fully equipped gym",
                                style: TextStyle(
                                  color: const Color(0xBB888888),
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => updateEquipments(0),
                                child: Container(
                                  height: ScreenUtil.verticalScale(4),
                                  width: ScreenUtil.verticalScale(4),
                                  decoration: BoxDecoration(
                                    color: equipments == 0 ? AppColors.primaryColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryColor),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.done,
                                      size: ScreenUtil.verticalScale(2.5),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: ScreenUtil.verticalScale(2),
                                child: Text(
                                  "B",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Home gym",
                                style: TextStyle(
                                  color: const Color(0xBB888888),
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => updateEquipments(1),
                                child: Container(
                                  height: ScreenUtil.verticalScale(4),
                                  width: ScreenUtil.verticalScale(4),
                                  decoration: BoxDecoration(
                                    color: equipments == 1 ? AppColors.primaryColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryColor),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.done,
                                      size: ScreenUtil.verticalScale(2.5),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: ScreenUtil.verticalScale(2),
                                child: Text(
                                  "C",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Dumbbells and bands",
                                style: TextStyle(
                                  color: const Color(0xBB888888),
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => updateEquipments(2),
                                child: Container(
                                  height: ScreenUtil.verticalScale(4),
                                  width: ScreenUtil.verticalScale(4),
                                  decoration: BoxDecoration(
                                    color: equipments == 2 ? AppColors.primaryColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryColor),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.done,
                                      size: ScreenUtil.verticalScale(2.5),
                                      color: Colors.white,
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

                Consumer<MonthProvider>(
                  builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                          await Future.delayed(Duration(seconds: 1)).then(
                            (v) {
                              value.updateSettingLoader(false);
                            },
                          );

                          Fluttertoast.showToast(
                            msg: "Saved successfully!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP_RIGHT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: AppColors.primaryColor,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );

                          await value.checkForPumpDay();
                          await value.manageStreak();
                          await value.getLiftedWeightGraphData();
                        },
                        isLoading: value.settingLoader,
                      ),
                    );
                  },
                ),

                // Consumer<MonthProvider>(
                //   builder: (context, value, child) => SelectDropdown(
                //     onChange: (String newValue) async {
                //       value.changeEquipmentType(newValue);
                //       await value.filterWorkouts();
                //       await value.updateLocalData();
                //     },
                //   ),
                // ),

                SizedBox(height: ScreenUtil.verticalScale(10))
              ],
            ),
          );
  }
}
