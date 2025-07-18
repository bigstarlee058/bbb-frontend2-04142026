import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterSortDialogShop extends StatefulWidget {
  final Function(String) onApplyFilters;
  final String selectedSortBy;

  const FilterSortDialogShop({
    super.key,
    required this.onApplyFilters,
    required this.selectedSortBy,
  });

  @override
  State<FilterSortDialogShop> createState() => _FilterSortDialogShopState();
}

class _FilterSortDialogShopState extends State<FilterSortDialogShop>
    with TickerProviderStateMixin {
  int? _expandedIndex = 0;
  String _selectedSortBy = '';
  @override
  void initState() {
    _selectedSortBy = widget.selectedSortBy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
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
                              setState(() => _selectedSortBy = value ?? "A-Z");
                            },
                            activeColor: const Color(0xFF9a354e),
                            hoverColor: Colors.white,
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
                        widget.onApplyFilters(_selectedSortBy);
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

  Widget _buildCustomTile(
      {required int index, required String title, required Widget child}) {
    final isOpen = _expandedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyColor,
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
                setState(() {
                  _expandedIndex = isOpen ? null : index;
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
