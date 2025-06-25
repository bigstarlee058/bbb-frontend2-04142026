import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/models/faqs_model.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
// import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/screen_util.dart';

class FAQsPage extends StatefulWidget {
  const FAQsPage({super.key});

  @override
  State<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  DataProvider? dataProvider;
  final Map<int, bool> _expandedStates = {0: false};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async => await dataProvider?.getFAQs(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
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
                          image: dataProvider!.cachedImageMap["imageFaQs"],
                          imageKey: "imageFaQs",
                        ),
                        SizedBox(
                          height: media.height / 2.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1),
                                  surfaceTintColor: Colors.transparent,
                                  centerTitle: true,
                                  backgroundColor: Colors.transparent,
                                  leading: BackArrowWidget(
                                    onPress: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  title: Text(
                                    'FAQs',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(5.5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(
                                          routeString: '/equipmentLibrary'),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Frequently asked questions",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.verticalScale(2),
                                        ),
                                        textAlign: TextAlign.center,
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
                    constraints: BoxConstraints(
                        minHeight: media.height - (media.height / 4.6)),
                    width: media.width,
                    padding: EdgeInsets.only(top: ScreenUtil.verticalScale(3)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Consumer<DataProvider>(
                      builder: (context, value, child) {
                        return Container(
                          width: media.width,
                          margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(6))
                              .copyWith(bottom: 5),
                          child: value.faqLoader && value.faQsModel.isEmpty
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              : value.faQsModel.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No data found!",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    )
                                  : ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 15),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(
                                          top: 0,
                                          bottom:
                                              ScreenUtil.verticalScale(3.2)),
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: dataProvider!.faQsModel.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: ScreenUtil.verticalScale(
                                                dataProvider!.faQsModel.length -
                                                            1 ==
                                                        index
                                                    ? 2
                                                    : 0.5),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(4)),
                                            child: buildExpansionTileItem(
                                              index,
                                              dataProvider!.faQsModel[index],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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

  Widget buildExpansionTileItem(int index, FaQsModel item) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: ScreenUtil.horizontalScale(5),
          vertical: ScreenUtil.verticalScale(0.5),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.question ?? "",
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryColor,
                  fontSize: ScreenUtil.verticalScale(1.8),
                  fontWeight: FontWeight.bold,
                ),
                // maxLines: 1,
              ),
            ),
          ],
        ),
        initiallyExpanded: _expandedStates[index] ?? false,
        onExpansionChanged: (bool value) {
          setState(() {
            _expandedStates[index] = value;
          });

          if (value && index == dataProvider!.faQsModel.length - 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                  );
                }
              });
            });
          }
        },
        backgroundColor: AppColors.greyColor,
        collapsedBackgroundColor: AppColors.greyColor,
        childrenPadding: EdgeInsets.zero,
        clipBehavior: Clip.none,
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
                  _expandedStates[index] == true
                      ? Icons.keyboard_arrow_up_outlined
                      : Icons.keyboard_arrow_down_outlined,
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
                horizontal: ScreenUtil.horizontalScale(5),
              ).copyWith(bottom: ScreenUtil.verticalScale(1)),
              child: Text(
                item.answer ?? "",
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.7),
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(1))
        ],
      ),
    );
  }
}
