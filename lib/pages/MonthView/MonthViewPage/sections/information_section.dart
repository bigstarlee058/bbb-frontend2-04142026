import 'package:bbb/models/program_info_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/program_info_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InformationSection extends StatefulWidget {
  const InformationSection({
    super.key,
    required this.programInfoProvider,
    required this.scrollController,
    required this.monthProvider,
  });

  final ProgramInfoProvider programInfoProvider;
  final ScrollController scrollController;
  final MonthProvider monthProvider;

  @override
  State<InformationSection> createState() => _InformationSectionState();
}

class _InformationSectionState extends State<InformationSection> {
  final Map<int, bool> _expandedStates = {0: true, 1: true, 2: true};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        getData();
      },
    );
    super.initState();
  }

  Future<void> getData() async {
    await widget.programInfoProvider.getProgramInfo();
    for (var i = 0;
        i < widget.programInfoProvider.programInfoModel!.sections.length;
        i++) {
      if (widget.programInfoProvider.programInfoModel!.sections[i].title
          .contains("Recommended")) {
        _expandedStates[i] = true;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      children: [
        Consumer<ProgramInfoProvider>(
          builder: (context, value, child) {
            return Container(
              constraints: BoxConstraints(
                minHeight: (media.height -
                    (media.height / 2.55) -
                    (media.height * 0.12)),
              ),
              child: value.loading
                  ? Padding(
                      padding: EdgeInsets.only(bottom: media.height * 0.1),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryColor),
                      ),
                    )
                  : value.programInfoModel == null
                      ? SizedBox(
                          height: media.height / 3,
                          child: Center(
                            child: Text(
                              "No program info available!",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(6))
                              .copyWith(bottom: ScreenUtil.verticalScale(13)),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: value.programInfoModel!.sections.length,
                            itemBuilder: (context, index) {
                              return Builder(
                                key: value.tileKeys[index],
                                builder: (context) {
                                  return value.programInfoModel!.sections[index]
                                                  .formats !=
                                              null &&
                                          value.programInfoModel!
                                                  .sections[index].variations !=
                                              null &&
                                          value.programInfoModel!
                                              .sections[index].formats!
                                              .contains(widget.monthProvider
                                                  .equipmentType) &&
                                          value.programInfoModel!
                                              .sections[index].variations!
                                              .contains(widget
                                                  .monthProvider.splitType
                                                  ?.replaceAll("split", ""))
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(4)),
                                            child: buildExpansionTileItem(
                                                index,
                                                value.programInfoModel!
                                                    .sections[index],
                                                value.programInfoModel!.sections
                                                    .length,
                                                value),
                                          ),
                                        )
                                      : SizedBox();
                                },
                              );
                            },
                          ),
                        ),
            );
          },
        ),
      ],
    );
  }

  Widget buildExpansionTileItem(
      int index, Section item, int length, ProgramInfoProvider value) {
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
                item.title.capitalizeFirst(),
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryColor,
                  fontSize: ScreenUtil.verticalScale(2),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
        initiallyExpanded: _expandedStates[index] ?? false,
        onExpansionChanged: (bool v1) {
          setState(() {
            _expandedStates[index] = v1;
          });

          if (v1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToTile(index, value);
            });
          }

          // if (value == true && index == length - 1) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     Future.delayed(const Duration(milliseconds: 200), () {
          //       if (widget.scrollController.hasClients) {
          //         widget.scrollController.animateTo(
          //           widget.scrollController.position.maxScrollExtent,
          //           duration: const Duration(milliseconds: 100),
          //           curve: Curves.easeOut,
          //         );
          //       }
          //     });
          //   });
          // }
        },
        backgroundColor: Theme.of(context).cardColor,
        collapsedBackgroundColor: Theme.of(context).cardColor,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.horizontalScale(6)),
                    child: Builder(
                      builder: (context) {
                        String bioContent = item.description;

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
                              fontSize: FontSize(ScreenUtil.verticalScale(1.7)),
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            "p": Style(
                              fontSize: FontSize(ScreenUtil.verticalScale(1.7)),
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          },
                        );
                      },
                    )

                    // Text(
                    //   item.description.trim().capitalizeFirst(),
                    //   textAlign: TextAlign.start,
                    //   style: TextStyle(
                    //     fontSize: ScreenUtil.verticalScale(1.7),
                    //     color: const Color(0xFF888888),
                    //   ),
                    // ),
                    ),
              ),
              SizedBox(height: ScreenUtil.verticalScale(2)),
            ],
          )
        ],
      ),
    );
  }

  void _scrollToTile(int index, ProgramInfoProvider value) {
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

    final context = value.tileKeys[index].currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 200), () {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          final tileHeight = renderBox.size.height;
          final screenHeight = MediaQuery.of(context).size.height;
          final desiredOffset = widget.scrollController.offset +
              position.dy +
              tileHeight -
              screenHeight +
              100;
          final maxScroll = widget.scrollController.position.maxScrollExtent;
          widget.scrollController.animateTo(
            desiredOffset.clamp(0, maxScroll),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      });
    }
  }
}
