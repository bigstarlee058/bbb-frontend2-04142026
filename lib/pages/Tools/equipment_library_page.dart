import 'dart:developer';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/filter_sort_shop.dart';
import 'package:bbb/models/equipment.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/data_provider.dart';

class EquipmentLibraryPage extends StatefulWidget {
  const EquipmentLibraryPage({super.key});

  @override
  State<EquipmentLibraryPage> createState() => _EquipmentLibraryPageState();
}

class _EquipmentLibraryPageState extends State<EquipmentLibraryPage> {
  DataProvider? dataProvider;
  int _currentPage = 0;
  final int _itemsPerPage = 10; // Number of equipments per page
  int _numPages = 0;
  String _searchQuery = "";
  String _selectedSortBy = 'A-Z'; // Default sorting
  // List<String> _selectedEquipmentIds = [];
  // List<String> _selectedCategoryIds = [];
  late MainPageProvider mainPageProvider;
  List<Equipment> _filteredEquipments = [];

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    dataProvider?.fetchAdminEquipmentsData().then((_) {
      setState(() {
        // Calculate the number of pages based on the fetched equipments
        if (dataProvider!.adminEquipmentsData.isNotEmpty) {
          _filteredEquipments = dataProvider!.adminEquipmentsData;
          _numPages = (_filteredEquipments.length / _itemsPerPage).ceil();
        } else {
          _numPages = 1; // Handle the case when no equipments are available
        }
      });
    }).catchError((error) {
      debugPrint('Error fetching admin equipment: $error');
    });
  }

  List<Equipment> _getPaginatedEquipments() {
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;

    return _filteredEquipments.sublist(
      startIndex,
      endIndex > _filteredEquipments.length
          ? _filteredEquipments.length
          : endIndex,
    );
  }

  void _applyFilters() {
    setState(() {
      // Filter equipments based on selected equipment, category, and search query
      _filteredEquipments =
          dataProvider!.adminEquipmentsData.where((equipment) {
        bool matchesSearch = _searchQuery.isEmpty ||
            equipment.title.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesSearch;
      }).toList();

      // Sort equipments based on the selected sorting option
      if (_selectedSortBy == 'A-Z') {
        _filteredEquipments.sort((a, b) => a.title.compareTo(b.title));
      } else if (_selectedSortBy == 'Z-A') {
        _filteredEquipments.sort((a, b) => b.title.compareTo(a.title));
      } else if (_selectedSortBy == 'Newest added') {
        _filteredEquipments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_selectedSortBy == 'Oldest added') {
        _filteredEquipments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

      _numPages = (_filteredEquipments.length / _itemsPerPage).ceil();
      _currentPage = 0; // Reset to the first page
    });
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
                Stack(
                  children: [
                    AppImage.imageApparel(
                        // media,
                        // image: dataProvider!.allImageList
                        //     .where((element) => element["key"] == "imageApparel")
                        //     .first["image"],
                        // imageKey: "imageApparel",
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
                                'Shop',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil.horizontalScale(5),
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
                                horizontal: ScreenUtil.horizontalScale(7),
                              ),
                              height: media.height * 0.19,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: ScreenUtil.horizontalScale(1),
                                    ),
                                    SearchEquipmentField(
                                      onChanged: (query) {
                                        setState(() {
                                          _searchQuery =
                                              query; // Update the search query
                                          _currentPage = 0;
                                          _applyFilters(); // Reset pagination when searching
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: ScreenUtil.horizontalScale(3),
                                    ),
                                    FilterSortButton(
                                      selectedSortBy: _selectedSortBy,
                                      onApplyFilters: (String sortBy) {
                                        log('sortBy==========>>>>>${sortBy}');
                                        setState(() {
                                          _selectedSortBy = sortBy;
                                        });
                                        _applyFilters(); // Apply the filters and sorting
                                      },
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.height / 3.19,
                      width: media.width,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ClipPath(
                          clipper: DiagonalClipper(),
                          child: Container(
                            height: media.height / 11,
                            width: media.width / 6,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: media.height / 3.2),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: (media.height -
                          (media.height / 4) -
                          (media.height * 0.12)),
                    ),
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: media.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(55),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(6),
                              vertical: ScreenUtil.verticalScale(2),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: ScreenUtil.verticalScale(2),
                                ),
                                dataProvider == null ||
                                        dataProvider!
                                            .adminEquipmentsData.isEmpty ||
                                        _filteredEquipments.isEmpty
                                    ? Container(
                                        color: Colors.white,
                                        height: ScreenUtil.verticalScale(
                                            (media.height -
                                                media.height / 3.2)),
                                      )
                                    : Column(
                                        children: _getPaginatedEquipments()
                                            .map((equipment) {
                                          return Column(
                                            children: [
                                              equipmentCard(
                                                equipment, // Dynamically display equipment
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil.verticalScale(2),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        alignment: Alignment.center,
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 65,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 10),
          child: _numPages > 0
              ? NumberPaginator(
                  numberPages: _numPages,
                  config: const NumberPaginatorUIConfig(
                    height: 48,
                    buttonSelectedForegroundColor: AppColors.primaryColor,
                    buttonUnselectedForegroundColor: Colors.grey,
                    buttonUnselectedBackgroundColor: Colors.transparent,
                    buttonSelectedBackgroundColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    buttonTextStyle: TextStyle(fontSize: 15),
                  ),
                  onPageChange: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget equipmentCard(Equipment equipment) {
    var media = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        _launchURL(equipment.link);
      },
      child: Container(
        padding: EdgeInsets.only(right: ScreenUtil.horizontalScale(5)),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(8)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
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
                  networkImageUrl: equipment.thumbnail
                          .startsWith('https://storage.cloud.google.com/')
                      ? equipment.thumbnail.replaceFirst(
                          'https://storage.cloud.google.com/',
                          'https://storage.googleapis.com/')
                      : equipment.thumbnail,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                    bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    equipment.title,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: ScreenUtil.verticalScale(2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: null,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.all(ScreenUtil.verticalScale(0.85)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/shopping-bag.svg",
                  height: ScreenUtil.verticalScale(2.3),
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchEquipmentField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchEquipmentField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(3),
        vertical: ScreenUtil.horizontalScale(1),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6)),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search Equipment',
          hintStyle: TextStyle(
            color: Colors.black45,
            fontSize: ScreenUtil.verticalScale(2),
          ),
          suffixIcon: Icon(
            Icons.search,
            size: ScreenUtil.verticalScale(4),
            color: Colors.grey[300],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(2),
          ),
        ),
      ),
    );
  }
}

class FilterSortButton extends StatefulWidget {
  final String selectedSortBy;
  final Function(String selectedSortBy) onApplyFilters;

  const FilterSortButton({
    super.key,
    required this.selectedSortBy,
    required this.onApplyFilters,
  });

  @override
  State<FilterSortButton> createState() => _FilterSortButtonState();
}

class _FilterSortButtonState extends State<FilterSortButton> {
  String _selectedSortBy = 'A-Z';
  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.selectedSortBy;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return SizedBox(
      width: media.width,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => FilterSortDialogShop(
              selectedSortBy: _selectedSortBy,
              onApplyFilters: (sort) {
                widget.onApplyFilters(sort);
                _selectedSortBy = sort;
                setState(() {});
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9a354e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6)),
          ),
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil.horizontalScale(3.5),
            horizontal: ScreenUtil.horizontalScale(4),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.tune,
              color: Colors.white70,
              size: 25,
            ),
            const SizedBox(width: 20),
            Container(
              height: 35,
              width: 0.5,
              decoration: const BoxDecoration(color: Colors.white70),
            ),
            const SizedBox(width: 65),
            const Text(
              'Filter & Sort',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

// void _showFilterSortDialog(BuildContext context, double dialogWidth) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           List<bool> isExpanded = [true, false, false];
//           return Dialog(
//             insetPadding: const EdgeInsets.all(0),
//             backgroundColor: Colors.white, // Popup background color
//             child: SingleChildScrollView(
//               // Wrap the content in a SingleChildScrollView
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Container(
//                     width: ScreenUtil.horizontalScale(
//                         90), // Set the width of the popup to match the button
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 20, horizontal: 20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Filter & Sort Options',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Color(0xFF9a354e), // White text
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             // IconButton(
//                             //   icon: const Icon(Icons.close, color: Color(0xFF9a354e)),
//                             //   onPressed: () {
//                             //     Navigator.of(context).pop();
//                             //   },
//                             // ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//
//                         // "Sort by" ExpansionTile with Radio buttons
//                         ExpansionTile(
//                           title: const Text(
//                             'Sort by',
//                             style:
//                                 TextStyle(fontSize: 14), // Small white text
//                           ),
//                           textColor: const Color(0xFF9a354e),
//                           collapsedTextColor: Colors.black,
//                           collapsedShape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             side: const BorderSide(
//                                 color: Color.fromARGB(255, 252, 252, 252),
//                                 width: 1),
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             side: const BorderSide(
//                                 color: Color(0xFF9a354e), width: 1),
//                           ),
//                           iconColor: Colors.black,
//                           collapsedIconColor: const Color(0xFF9a354e),
//                           initiallyExpanded:
//                               isExpanded[0], // Set initial expanded state
//                           onExpansionChanged: (isExpandedState) {
//                             setState(() {
//                               // Set the current index to true and others to false
//                               isExpanded = [isExpandedState, false, false];
//                             });
//                           },
//                           children: <String>[
//                             'A-Z',
//                             'Z-A',
//                             'Newest added',
//                             'Oldest added'
//                           ].map((String option) {
//                             return RadioListTile<String>(
//                               title: Text(option,
//                                   style: const TextStyle(
//                                       fontSize: 14, color: Colors.black)),
//                               value: option,
//                               groupValue: _selectedSortBy,
//                               onChanged: (String? value) {
//                                 setState(() {
//                                   _selectedSortBy = value!;
//                                 });
//                               },
//                               activeColor: const Color(
//                                   0xFF9a354e), // Change the checked color here
//                               hoverColor: Colors.white,
//                             );
//                           }).toList(),
//                         ),
//
//                         const SizedBox(height: 20),
//                         // Apply now button
//
//                         ButtonWidget(
//                             text: "Apply now",
//                             textColor: Colors.white,
//                             color: AppColors.primaryColor,
//                             onPress: () {
//                               Navigator.of(context).pop();
//                               widget.onApplyFilters(
//                                 _selectedSortBy,
//                               );
//                             },
//                             isLoading: false),
//
//                         // SizedBox(
//                         //   width: double.infinity,
//                         //   height: ScreenUtil.verticalScale(7),
//                         //   child: ElevatedButton(
//                         //     style: ElevatedButton.styleFrom(
//                         //       backgroundColor: const Color(0xFF9a354e), // Apply now button color
//                         //       padding: const EdgeInsets.symmetric(vertical: 10),
//                         //     ),
//                         //     onPressed: () {
//                         //       Navigator.of(context).pop();
//                         //       widget.onApplyFilters(
//                         //         _selectedSortBy,
//                         //       );
//                         //     },
//                         //     child: const Text(
//                         //       'Apply now',
//                         //       style: TextStyle(color: Colors.white, fontSize: 16),
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     right: -ScreenUtil.verticalScale(1.2),
//                     top: -ScreenUtil.verticalScale(1.2),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: GestureDetector(
//                         child: Container(
//                           decoration: const BoxDecoration(
//                               color: AppColors.primaryColor,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(100))),
//                           child: Padding(
//                             padding:
//                                 EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
//                             child: Icon(
//                                 size: ScreenUtil.verticalScale(2.5),
//                                 Icons.close,
//                                 color: Colors.white),
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }
}
