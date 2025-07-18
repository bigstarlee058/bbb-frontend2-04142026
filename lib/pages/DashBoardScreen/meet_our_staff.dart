import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/models/staffs.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetOurStaff extends StatefulWidget {
  const MeetOurStaff({super.key});

  @override
  State<MeetOurStaff> createState() => _MeetOurStaffState();
}

class _MeetOurStaffState extends State<MeetOurStaff> {
  final today = DateTime.now();
  DataProvider? dataProvider;
  UserDataProvider? userData;
  int? week;
  int? day;

  bool isToday = true;
  bool isThisWeek = true;
  bool isSkipped = false;
  bool isCompleted = false;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    userData = Provider.of<UserDataProvider>(context, listen: false);

    super.initState();
  }

  Future<void> launchUrls(String urls) async {
    final Uri url = Uri.parse(urls);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final staffData = ModalRoute.of(context)?.settings.arguments as Staffs?;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Stack(
                  children: [
                    Container(
                      height: media.height / 1.7,
                      width: media.width,
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //     image: staffData != null
                      //         ? NetworkImage(staffData.photo.startsWith(
                      //                 'https://storage.cloud.google.com/')
                      //             ? staffData.photo.replaceFirst(
                      //                 'https://storage.cloud.google.com/',
                      //                 'https://storage.googleapis.com/')
                      //             : staffData.photo)
                      //         : const AssetImage('assets/img/back.jpg'),
                      //     fit: BoxFit.cover,
                      //     opacity: 1,
                      //   ),
                      // ),
                      child: appShimmerImage(
                        borderRadius: BorderRadius.circular(0),
                        fit: BoxFit.cover,
                        color: Colors.transparent,
                        networkImageUrl: (staffData?.photo ?? "")
                                .startsWith('https://storage.cloud.google.com/')
                            ? (staffData?.photo ?? "").replaceFirst(
                                'https://storage.cloud.google.com/',
                                'https://storage.googleapis.com/')
                            : (staffData?.photo ?? ""),
                      ),
                    ),
                    SizedBox(
                      height: media.height / 1.8,
                      width: media.width,
                      child: SafeArea(
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(4),
                                        ),
                                        decoration: BoxDecoration(
                                          color: //(isThisWeek && isCompleted)?
                                              // Color(0xFF8A2BE2):
                                              Color(0XFFd18a9b),
                                          shape: BoxShape.circle,
                                        ),
                                        child: SizedBox(
                                          width: ScreenUtil.verticalScale(4.65),
                                          height:
                                              ScreenUtil.verticalScale(4.65),
                                          child: IconButton(
                                            padding: EdgeInsets
                                                .zero, // Removes the default padding
                                            icon: const Icon(
                                              Icons.keyboard_arrow_left,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              // HapticFeedBack.buttonClick();
                                              Navigator.pop(context);
                                            },
                                            iconSize: ScreenUtil.verticalScale(
                                                4), // Icon size remains the same
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(7)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: ScreenUtil.verticalScale(1.5),
                                  ),
                                  SizedBox(height: ScreenUtil.verticalScale(4)),
                                ],
                              ),
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(2.5)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.height / 1.9, // 2.64,
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
                  constraints: BoxConstraints(
                      minHeight: (media.height -
                          (media.height / 2) -
                          (media.height * 0.12))),
                  margin: EdgeInsets.only(
                    top: media.height / 1.905, //2.65,
                  ),
                  width: media.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: ScreenUtil.verticalScale(3)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.horizontalScale(9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staffData != null ? staffData.title : 'Name',
                            style: TextStyle(
                              fontSize: ScreenUtil.verticalScale(3.5),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              staffData!.instagram.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, bottom: 10, top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await launchUrls(
                                              "https://www.instagram.com");
                                        },
                                        child: Container(
                                          height: ScreenUtil.verticalScale(4),
                                          width: ScreenUtil.verticalScale(4),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1)),
                                          decoration: BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/instagram.svg",
                                              color: Colors.white,
                                              height:
                                                  ScreenUtil.verticalScale(2.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              staffData.facebook.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, bottom: 10, top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await launchUrls(staffData.facebook);
                                        },
                                        child: Container(
                                          height: ScreenUtil.verticalScale(4),
                                          width: ScreenUtil.verticalScale(4),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1)),
                                          decoration: BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/facebook.svg",
                                              color: Colors.white,
                                              height:
                                                  ScreenUtil.verticalScale(2.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              staffData.twitter.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, bottom: 10, top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await launchUrls(staffData.twitter);
                                        },
                                        child: Container(
                                          height: ScreenUtil.verticalScale(4),
                                          width: ScreenUtil.verticalScale(4),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1)),
                                          decoration: BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: Image.asset(
                                              "assets/icons/twitter.png",
                                              color: Colors.white,
                                              height:
                                                  ScreenUtil.verticalScale(1.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              staffData.tiktok.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, bottom: 10, top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await launchUrls(staffData.tiktok);
                                        },
                                        child: Container(
                                          height: ScreenUtil.verticalScale(4),
                                          width: ScreenUtil.verticalScale(4),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1)),
                                          decoration: BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/tiktoksvg.svg",
                                              color: Colors.white,
                                              height:
                                                  ScreenUtil.verticalScale(2.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              staffData.linkedin.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, bottom: 10, top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await launchUrls(staffData.linkedin);
                                        },
                                        child: Container(
                                          height: ScreenUtil.verticalScale(4),
                                          width: ScreenUtil.verticalScale(4),
                                          padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1)),
                                          decoration: BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/linkedin.svg",
                                              color: Colors.white,
                                              height:
                                                  ScreenUtil.verticalScale(2.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              alignment: Alignment.centerLeft,
                              child: Builder(builder: (context) {
                                String bioContent = staffData.bio ?? "";

                                bool isPlainText = !bioContent
                                    .trim()
                                    .contains(RegExp(r"<[a-z][\s\S]*>"));

                                if (isPlainText) {
                                  bioContent = "<p>$bioContent</p>";
                                }
                                return Html(
                                  data: bioContent,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(
                                          ScreenUtil.verticalScale(1.8)),
                                      color: AppColors.appGreyColor,
                                    ),
                                    "p": Style(
                                      fontSize: FontSize(
                                          ScreenUtil.verticalScale(1.8)),
                                      color: AppColors.appGreyColor,
                                    ),
                                  },
                                );
                              })
                              // Text(
                              //   staffData.bio,
                              //   style: const TextStyle(
                              //       fontSize: 16, color: Colors.grey),
                              //   textAlign: TextAlign.left,
                              // ),
                              ),
                          staffData.link.isEmpty
                              ? SizedBox()
                              : Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil.verticalScale(1.8),
                                      bottom: ScreenUtil.verticalScale(3.2)),
                                  child: ButtonWidget(
                                    text: 'View Details',
                                    textColor: Colors.white,
                                    color: AppColors.primaryColor,
                                    onPress: () async {
                                      _launchURL(staffData.link);
                                    },
                                    isLoading: false,
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
