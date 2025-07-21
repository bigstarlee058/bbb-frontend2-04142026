import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterSortDialog extends StatefulWidget {
  final List<Map<String, String>> equipments;
  final List<Map<String, String>> categories;
  final Function(List<String>, List<String>, String) onApplyFilters;
  final String selectedSortBy;
  final List<String> selectedEquipmentIds;
  final List<String> selectedCategoryIds;

  const FilterSortDialog({
    super.key,
    required this.equipments,
    required this.categories,
    required this.onApplyFilters,
    required this.selectedEquipmentIds,
    required this.selectedCategoryIds,
    required this.selectedSortBy,
  });

  @override
  State<FilterSortDialog> createState() => _FilterSortDialogState();
}

class _FilterSortDialogState extends State<FilterSortDialog>
    with TickerProviderStateMixin {
  int? _expandedIndex = 0;
  String _selectedSortBy = '';
  List<String> _selectedEquipmentIds = [];
  List<String> _selectedCategoryIds = [];

  @override
  void initState() {
    _selectedSortBy = widget.selectedSortBy;
    _selectedEquipmentIds = widget.selectedEquipmentIds;
    _selectedCategoryIds = widget.selectedCategoryIds;
    super.initState();
  }

  ScrollController scrollController = ScrollController();
  final List<GlobalKey> _tileKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Theme.of(context).cardColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: Container(
              width: ScreenUtil.horizontalScale(90),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter & Sort Options',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9a354e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTile(
                      key: _tileKeys[0],
                      index: 0,
                      title: "Sort by",
                      child: Column(
                        children: <String>[
                          'A-Z',
                          'Z-A',
                          'Newest added',
                          'Oldest added'
                        ].map((String option) {
                          return RadioListTile<String>(
                            title: Text(option,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            value: option,
                            groupValue: _selectedSortBy,
                            onChanged: (String? value) {
                              setState(() => _selectedSortBy = option);
                            },
                            activeColor: const Color(0xFF9a354e),
                            hoverColor: Colors.white,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTile(
                        key: _tileKeys[1],
                        index: 1,
                        title: "Filter by Equipment",
                        child: Column(
                          children: widget.equipments.map((equipment) {
                            final isChecked =
                                _selectedEquipmentIds.contains(equipment['id']);
                            return ListTile(
                              title: Text(
                                equipment['title']!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.only(
                                right: ScreenUtil.horizontalScale(5),
                                left: ScreenUtil.horizontalScale(3.5),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isChecked) {
                                      _selectedEquipmentIds
                                          .remove(equipment['id']);
                                    } else {
                                      _selectedEquipmentIds
                                          .add(equipment['id']!);
                                    }
                                  });
                                },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: isChecked
                                            ? AppColors.primaryColor
                                            : Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.grey.shade800
                                                : AppColors.backOffSetColor
                                                    .withValues(alpha: 0.9),
                                        width: 1.8),
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isChecked
                                            ? const Color(0xFF9a354e)
                                            : Theme.of(context).canvasColor,
                                      ),
                                      child: Center(
                                        child: isChecked
                                            ? const Icon(Icons.check,
                                                size: 13, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  if (isChecked) {
                                    _selectedEquipmentIds
                                        .remove(equipment['id']);
                                  } else {
                                    _selectedEquipmentIds.add(equipment['id']!);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        )
                        //   child: Column(
                        //   children: widget.equipments
                        //       .map((Map<String, String> equipment) {
                        //     return CheckboxListTile(
                        //       shape: CircleBorder(),
                        //       title: Text(equipment['title']!,
                        //           style: const TextStyle(
                        //               fontSize: 14, color: Colors.black)),
                        //       value:
                        //           _selectedEquipmentIds.contains(equipment['id']),
                        //       onChanged: (bool? value) {
                        //         setState(() {
                        //           if (value == true) {
                        //             _selectedEquipmentIds.add(equipment['id']!);
                        //           } else {
                        //             _selectedEquipmentIds.remove(equipment['id']);
                        //           }
                        //         });
                        //       },
                        //       activeColor: const Color(0xFF9a354e),
                        //       checkColor: Colors.white,
                        //     );
                        //   }).toList(),
                        // ),
                        ),
                    const SizedBox(height: 20),
                    _buildCustomTile(
                      key: _tileKeys[2],
                      index: 2,
                      title: "Filter by Categories",
                      child: Column(
                        children: widget.categories.map((category) {
                          final isChecked =
                              _selectedCategoryIds.contains(category['id']);
                          return ListTile(
                            title: Text(
                              category['title']!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.only(
                              right: ScreenUtil.horizontalScale(5),
                              left: ScreenUtil.horizontalScale(3.5),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isChecked) {
                                    _selectedCategoryIds.remove(category['id']);
                                  } else {
                                    _selectedCategoryIds.add(category['id']!);
                                  }
                                });
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: isChecked
                                          ? AppColors.primaryColor
                                          : Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.grey.shade800
                                              : AppColors.backOffSetColor
                                                  .withValues(alpha: 0.9),
                                      width: 1.8),
                                  color: Theme.of(context).canvasColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isChecked
                                          ? const Color(0xFF9a354e)
                                          : Theme.of(context).canvasColor,
                                    ),
                                    child: Center(
                                      child: isChecked
                                          ? const Icon(Icons.check,
                                              size: 13, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if (isChecked) {
                                  _selectedCategoryIds.remove(category['id']);
                                } else {
                                  _selectedCategoryIds.add(category['id']!);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonWidget(
                      text: "Apply now",
                      textColor: Colors.white,
                      color: AppColors.primaryColor,
                      onPress: () {
                        widget.onApplyFilters(
                          _selectedEquipmentIds,
                          _selectedCategoryIds,
                          _selectedSortBy,
                        );
                        Navigator.of(context).pop();
                      },
                      isLoading: false,
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -ScreenUtil.verticalScale(1.2),
            top: -ScreenUtil.verticalScale(1.2),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: const BoxDecoration(
                    color: AppColors.primaryColor, shape: BoxShape.circle),
                padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                child: Icon(
                  Icons.close,
                  size: ScreenUtil.verticalScale(2.5),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToTile(int index) {
    final context = _tileKeys[index].currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 200), () {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          final tileHeight = renderBox.size.height;
          final screenHeight = MediaQuery.of(context).size.height;
          final desiredOffset = scrollController.offset +
              position.dy +
              tileHeight -
              screenHeight +
              50;
          final maxScroll = scrollController.position.minScrollExtent;
          scrollController.animateTo(
            desiredOffset.clamp(0, maxScroll),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      });
    }
  }

  Widget _buildCustomTile(
      {required int index,
      required String title,
      required Widget child,
      required key}) {
    final isOpen = _expandedIndex == index;
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil.verticalScale(0.5),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5)),
            title: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryColor,
                fontSize: ScreenUtil.verticalScale(1.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: InkWell(
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _expandedIndex = isOpen ? null : index;
                  });
                  _scrollToTile(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                ),
                child: Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              setState(() {
                _expandedIndex = isOpen ? null : index;
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            child: isOpen
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
