import 'package:bbb/models/program_info_model.dart';
import 'package:bbb/providers/program_info_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InformationSection extends StatefulWidget {
  const InformationSection({super.key, required this.programInfoProvider});

  final ProgramInfoProvider programInfoProvider;

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
                  ? SizedBox(
                      height: media.height / 3,
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
                          child: ExpansionTileGroup(
                            spaceBetweenItem: 15,
                            children: List.generate(
                              value.programInfoModel!.sections.length,
                              (index) {
                                return buildExpansionTileItem(index, value.programInfoModel!.sections[index]);
                              },
                            ),
                          ),
                        ),
            );
          },
        ),
      ],
    );
  }

  ExpansionTileItem buildExpansionTileItem(int index, Section item) {
    return ExpansionTileItem(
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
    );
  }
}
