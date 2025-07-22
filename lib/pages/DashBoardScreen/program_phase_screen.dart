import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/models/program_phase_model.dart';
import 'package:bbb/pages/DashBoardScreen/newspeper_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProgramPhaseScreen extends StatefulWidget {
  const ProgramPhaseScreen({super.key});

  @override
  State<ProgramPhaseScreen> createState() => _ProgramPhaseScreenState();
}

class _ProgramPhaseScreenState extends State<ProgramPhaseScreen> {
  final Map<int, bool> _expandedStates = {0: false};
  DataProvider? dataProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    _tileKeys.clear();
    final phaseCount = dataProvider?.programPhaseModel?.phases?.length ?? 0;
    for (int i = 0; i < phaseCount; i++) {
      _tileKeys.add(GlobalKey());
    }
    super.initState();
  }

  final List<GlobalKey> _tileKeys = [];

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<DataProvider>(builder: (context, value, c) {
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: [
              Stack(
                children: [
                  Container(
                    height: ScreenUtil.verticalScale(65),
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                        child: value.programPhaseModel != null
                            ? value.programPhaseModel!.phasesmaininfo!
                                    .thumbnail!.isEmpty
                                ? Image.asset(
                                    "assets/img/program-phase-1.png",
                                  )
                                : appShimmerImage(
                                    color: Colors.transparent,
                                    height: ScreenUtil.verticalScale(46),
                                    networkImageUrl: value.programPhaseModel!
                                            .phasesmaininfo!.thumbnail!
                                            .startsWith(
                                                'https://storage.cloud.google.com/')
                                        ? value.programPhaseModel!
                                            .phasesmaininfo!.thumbnail!
                                            .replaceFirst(
                                                'https://storage.cloud.google.com/',
                                                'https://storage.googleapis.com/')
                                        : value.programPhaseModel!
                                            .phasesmaininfo!.thumbnail!,
                                  )
                            : Image.asset(
                                "assets/img/program-phase-1.png",
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
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil.horizontalScale(4)),
                                    decoration: const BoxDecoration(
                                      color: Color(0XFFd18a9b),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(
                                      width: ScreenUtil.verticalScale(4.65),
                                      height: ScreenUtil.verticalScale(4.65),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_left,
                                            color: Colors.white),
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
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(6)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(2)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      value.programPhaseModel?.phasesmaininfo
                                              ?.contenttitle ??
                                          "",
                                      style: TextStyle(
                                        fontSize: ScreenUtil.verticalScale(3),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                          "${value.programPhaseModel?.phasesmaininfo?.description}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
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
                                physics: NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 15),
                                padding: EdgeInsets.symmetric(vertical: 12)
                                    .copyWith(
                                        bottom: ScreenUtil.verticalScale(3.2)),
                                itemCount:
                                    value.programPhaseModel?.phases?.length ??
                                        0,
                                itemBuilder: (context, index) {
                                  return buildExpansionTileItem(
                                      index,
                                      value.programPhaseModel!.phases![index],
                                      value.programPhaseModel?.phases?.length ??
                                          0);
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
        );
      }),
    );
  }

  void _scrollToTile(int index) {
    // final context = _tileKeys[index].currentContext;
    // if (context != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Future.delayed(const Duration(milliseconds: 200), () {
    //       if (_scrollController.hasClients) {
    //         Scrollable.ensureVisible(
    //           context,
    //           duration: const Duration(milliseconds: 200),
    //           curve: Curves.easeInOut,
    //           alignment: 0.1,
    //         );
    //       }
    //     });
    //   });
    // }

    final context = _tileKeys[index].currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 200), () {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          final tileHeight = renderBox.size.height;
          final screenHeight = MediaQuery.of(context).size.height;
          final desiredOffset = _scrollController.offset +
              position.dy +
              tileHeight -
              screenHeight +
              50;
          final maxScroll = _scrollController.position.maxScrollExtent;
          _scrollController.animateTo(
            desiredOffset.clamp(0, maxScroll),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      });
    }
  }

  ExpansionTileItem buildExpansionTileItem(int index, Phase item, int length) {
    return ExpansionTileItem(
      key: _tileKeys[index],
      tilePadding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(5),
        vertical: ScreenUtil.verticalScale(0.5),
      ),
      title: Padding(
        padding: EdgeInsets.only(
          top: ScreenUtil.verticalScale(1.5),
          bottom: _expandedStates[index] == true
              ? 0
              : ScreenUtil.verticalScale(1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.title ?? "",
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
      ),
      initiallyExpanded: _expandedStates[index] ?? false,
      onExpansionChanged: (bool value) {
        setState(() {
          _expandedStates[index] = value;
        });

        // if (value == true && index == length - 1) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     Future.delayed(const Duration(milliseconds: 200), () {
        //       if (_scrollController.hasClients) {
        //         _scrollController.animateTo(
        //           _scrollController.position.maxScrollExtent,
        //           duration: const Duration(milliseconds: 100),
        //           curve: Curves.easeOut,
        //         );
        //       }
        //     });
        //   });
        // }

        if (value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToTile(index);
          });
        }
      },
      backgroundColor: const Color(0xFF0D0D0D),
      collapsedBackgroundColor: const Color(0xFF0D0D0D),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
        color: Theme.of(context).cardColor,
      ),
      iconColor: AppColors.primaryColor,
      collapsedIconColor: Theme.of(context).cardColor,
      trailing: Padding(
        padding: EdgeInsets.only(
          bottom: _expandedStates[index] == true
              ? 0
              : ScreenUtil.verticalScale(1.5),
          top: ScreenUtil.verticalScale(1.5),
          right: ScreenUtil.horizontalScale(5),
        ),
        child: Row(
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
      ),
      childrenPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(0.7)),
      isDefaultVerticalPadding: false,
      children: [
        // Text(item.description ?? "")
        NewspaperLayoutWidget(
          text: item.description ?? "",
          imageUrl: (item.thumbnail ?? "")
                  .startsWith('https://storage.cloud.google.com/')
              ? (item.thumbnail ?? "").replaceFirst(
                  'https://storage.cloud.google.com/',
                  'https://storage.googleapis.com/')
              : (item.thumbnail ?? ""),
        ),
      ],
    );
  }
}
