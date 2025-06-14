import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/models/tutorial_model.dart';
import 'package:bbb/pages/Tools/tutorial_details_page.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/data_provider.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  DataProvider? dataProvider;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    getTutorials();
  }

  getTutorials() async {
    await dataProvider?.getAllTutorials();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Utils.appImage(
                          media,
                          image: dataProvider!.cachedImageMap["imageApparel"],
                          imageKey: "imageDashboard",
                        ),
                        SizedBox(
                          height: media.height / 2.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1), surfaceTintColor: Colors.transparent,
                                  centerTitle: true,
                                  backgroundColor: Colors.transparent,
                                  leading: BackArrowWidget(
                                    onPress: () {
                                      Navigator.pop(context);
                                    },
                                  ),

                                  /// IF NEED TO ADD STICKY BACK BUTTON THEN WRAP MAIN WIDGET INTO STACK AND COMMENT LOADING BUTTON AND ADD SIZED BOX AND ADD POSITION INTO BOTTOM
                                  // Positioned(
                                  //   left: 0,
                                  //   child: BackArrowWidget(
                                  //     onPress: () {
                                  //       Navigator.pop(context);
                                  //     },
                                  //   ),
                                  // leading: SizedBox(),
                                  title: Text(
                                    'Tutorials',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(routeString: '/equipmentLibrary'),
                                    )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(5),
                                  ),
                                  height: media.height * 0.097,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: ScreenUtil.horizontalScale(50),
                                        child: Text(
                                          "Here’s a quick tutorial\njust for you",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil.verticalScale(2),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 4.59,
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
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: media.height / 4.6),
                  child: Container(
                    width: media.width,
                    constraints: BoxConstraints(minHeight: (media.height - (media.height / 4.6))),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.horizontalScale(6), vertical: ScreenUtil.verticalScale(2)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Consumer<DataProvider>(
                      builder: (context, value, child) {
                        return ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(height: ScreenUtil.verticalScale(2)),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: value.tutorialList.length,
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(2)),
                          itemBuilder: (context, index) => tutorialCard(value.tutorialList[index]),
                        );
                      },
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

  Widget tutorialCard(TutorialModel data) {
    var media = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TutorialDetailsPage(tutorialModel: data)),
        );
      },
      child: Container(
        padding: EdgeInsets.only(right: ScreenUtil.horizontalScale(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(8)),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                appShimmerImage(
                  height: media.width / 4,
                  width: media.width / 4,
                  networkImageUrl: data.thumbnail!.startsWith('https://storage.cloud.google.com/')
                      ? data.thumbnail!
                          .replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                      : data.thumbnail!,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                    bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                  ),
                ),
                // Container(
                //   height: media.width / 4,
                //   width: media.width / 4,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: data.thumbnail!.isNotEmpty
                //           ? NetworkImage(data.thumbnail!.startsWith('https://storage.cloud.google.com/')
                //               ? data.thumbnail!
                //                   .replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                //               : data.thumbnail!)
                //           : const AssetImage('assets/img/library_placeholder.png'),
                //       fit: BoxFit.cover,
                //       opacity: 1,
                //     ),
                //     borderRadius: BorderRadius.only(
                //       topLeft: Radius.circular(ScreenUtil.verticalScale(8)),
                //       bottomLeft: Radius.circular(ScreenUtil.verticalScale(8)),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title ?? "",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: ScreenUtil.verticalScale(2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.verticalScale(0.7),
                vertical: ScreenUtil.verticalScale(0.7),
              ),
              decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: ScreenUtil.verticalScale(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
