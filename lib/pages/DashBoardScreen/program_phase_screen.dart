import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';

class ProgramPhaseScreen extends StatefulWidget {
  const ProgramPhaseScreen({super.key});

  @override
  State<ProgramPhaseScreen> createState() => _ProgramPhaseScreenState();
}

class _ProgramPhaseScreenState extends State<ProgramPhaseScreen> {
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
                ),
                AppBar(
                  toolbarHeight: ScreenUtil.verticalScale(5.1),
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: BackArrowWidget(
                    onPress: () {
                      Navigator.pop(context);
                    },
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
            Positioned(
              left: -ScreenUtil.horizontalScale(2),
              right: ScreenUtil.horizontalScale(2.5),
              top: ScreenUtil.verticalScale(5.7),
              child: Image.asset(
                "assets/img/program-phase.png",
              ),
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
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lorem title",
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(3.5),
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
                                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
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
}
