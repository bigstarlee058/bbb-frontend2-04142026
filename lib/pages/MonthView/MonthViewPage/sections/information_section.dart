import 'package:bbb/models/program_info_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/program_info_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
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
  final Map<int, bool> _expandedStates = {0: false};

  @override
  void initState() {
    widget.programInfoProvider.getProgramInfo(context);
    super.initState();
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
                minHeight: (media.height - (media.height / 2.55) - (media.height * 0.12)),
              ),
              color: Colors.white,
              child: value.loading
                  ? Padding(
                      padding: EdgeInsets.only(bottom: media.height * 0.1),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor),
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
                          padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6))
                              .copyWith(bottom: ScreenUtil.verticalScale(13)),
                          child: ListView.separated(
                            separatorBuilder: (context, index) => SizedBox(height: 15),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: value.programInfoModel!.sections.length,
                            itemBuilder: (context, index) {
                              return value.programInfoModel!.sections[index].formats != null &&
                                      value.programInfoModel!.sections[index].variations != null &&
                                      value.programInfoModel!.sections[index].formats!.contains(widget.monthProvider.equipmentType) &&
                                      value.programInfoModel!.sections[index].variations!
                                          .contains(widget.monthProvider.splitType?.replaceAll("split", ""))
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4)),
                                      child: buildExpansionTileItem(
                                          index, value.programInfoModel!.sections[index], value.programInfoModel!.sections.length),
                                    )
                                  : SizedBox();
                            },
                          ),
                        ),
            );
          },
        ),
      ],
    );
  }

  Widget buildExpansionTileItem(int index, Section item, int length) {
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
        onExpansionChanged: (bool value) {
          setState(() {
            _expandedStates[index] = value;
          });
          if (value == true && index == length - 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (widget.scrollController.hasClients) {
                  widget.scrollController.animateTo(
                    widget.scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                  );
                }
              });
            });
          }
        },
        backgroundColor: AppColors.greyColor,
        collapsedBackgroundColor: AppColors.greyColor, childrenPadding: EdgeInsets.zero,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
        //   color: AppColors.greyColor,
        // ),
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
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
              child: Text(
                item.description.capitalizeFirst(),
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.7),
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(2))
        ],
      ),
    );
  }
}
