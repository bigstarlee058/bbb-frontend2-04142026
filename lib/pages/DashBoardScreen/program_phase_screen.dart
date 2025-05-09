import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgramPhaseScreen extends StatefulWidget {
  const ProgramPhaseScreen({super.key});

  @override
  State<ProgramPhaseScreen> createState() => _ProgramPhaseScreenState();
}

class _ProgramPhaseScreenState extends State<ProgramPhaseScreen> {
  final Map<int, bool> _expandedStates = {0: false};

  List<Map<String, dynamic>> items = [
    {
      "month": "Month 1 : ",
      "title": "Month 1 : Glute Squad Special",
      "subtitle":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
      "image": "assets/img/Glute Squad Special.png",
    },
    {
      "month": "Month 2 : ",
      "title": "Month 2 : Squat + Bench Press Focus",
      "subtitle":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
      "image": "assets/img/Squat and Bench Press Focus.png",
    },
    {
      "month": "Month 3 : ",
      "title": "Month 3 : Strong Lifting",
      "subtitle":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
      "image": "assets/img/Stronglifting.png",
    },
    {
      "month": "Month 4 : ",
      "title": "Month 4 : Deadlift + Chin-up Focus",
      "subtitle":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
      "image": "assets/img/Deadlift and Chin-Up Focus.png",
    },
    {
      "month": "Month 5 : ",
      "title": "Month 5 : Hip Thrust + Military Press Focus",
      "subtitle":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
      "image": "assets/img/Hip Thrust and Military Press Focus.png",
    },
  ];
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
                  height: ScreenUtil.verticalScale(65),
                  width: media.width,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE).withValues(alpha: 0.8),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: ScreenUtil.horizontalScale(4.5),
                        top: ScreenUtil.verticalScale(5.7),
                      ),
                      child: Image.asset(
                        "assets/img/program-phase.png",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(65),
                  width: media.width,
                  child: Align(
                    alignment: FractionalOffset.topLeft,
                    child: SafeArea(
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(4)),
                                  decoration: const BoxDecoration(
                                    color: Color(0XFFd18a9b),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SizedBox(
                                    width: ScreenUtil.verticalScale(4.65),
                                    height: ScreenUtil.verticalScale(4.65),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      iconSize: ScreenUtil.verticalScale(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(54.5),
                  width: media.width,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ClipPath(
                      clipper: DiagonalClipper(),
                      child: Container(
                        height: media.height / 11,
                        width: media.width / 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                top: ScreenUtil.verticalScale(54.49),
                bottom: ScreenUtil.verticalScale(2),
              ),
              child: Container(
                width: media.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(
                    top: ScreenUtil.verticalScale(3.2),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(2)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lorem title",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(3),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) => SizedBox(height: 15),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return buildExpansionTileItem(index, items[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ExpansionTileItem buildExpansionTileItem(int index, Map<String, dynamic> item) {
    return ExpansionTileItem(
      tilePadding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(5),
        vertical: ScreenUtil.verticalScale(0.5),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   item["month"],
          //   style: GoogleFonts.plusJakartaSans(
          //     color: AppColors.primaryColor,
          //     fontSize: ScreenUtil.verticalScale(1.9),
          //     fontWeight: FontWeight.bold,
          //   ),
          //   maxLines: 1,
          // ),
          Expanded(
            child: Text(
              item["title"],
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryColor,
                fontSize: ScreenUtil.verticalScale(1.9),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
      initiallyExpanded: _expandedStates[index] ?? false,
      onExpansionChanged: (bool value) {
        setState(() {
          _expandedStates[index] = value;
        });
      },
      backgroundColor: const Color(0xFF0D0D0D),
      collapsedBackgroundColor: const Color(0xFF0D0D0D),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
        color: Colors.grey[100],
      ),
      iconColor: AppColors.primaryColor,
      collapsedIconColor: Colors.white,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            child: Container(
              padding: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
                color: AppColors.primaryColor,
              ),
              child: Icon(
                _expandedStates[index] == true ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined,
                color: Colors.white,
                size: ScreenUtil.verticalScale(3),
              ),
            ),
          ),
        ],
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(1),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      item["image"],
                      color: AppColors.primaryColor,
                      height: ScreenUtil.verticalScale(16.3),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: ScreenUtil.verticalScale(16.9),
                        child: Text(
                          item["subtitle"],
                          maxLines: 7,
                          style: TextStyle(
                            fontSize: ScreenUtil.verticalScale(1.7),
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  "1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                  style: TextStyle(
                    fontSize: ScreenUtil.verticalScale(1.7),
                    color: const Color(0xFF888888),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 7)
      ],
    );
  }
}
