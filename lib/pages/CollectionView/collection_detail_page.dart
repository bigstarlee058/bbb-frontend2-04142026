import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/models/collections.dart';
import 'package:bbb/models/equipment.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CollectionDetailPage extends StatefulWidget {
  const CollectionDetailPage({super.key});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  DataProvider? dataProvider;
  UserDataProvider? userData;
  late MainPageProvider mainPageProvider;

  @override
  void initState() {
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final collection =
          ModalRoute.of(context)!.settings.arguments as Collections;
      await loadCollectionData(collection).then((_) {
        setState(() {
          if (dataProvider!.collectionData.equipments.isNotEmpty) {
            final List<Equipment>? equipments = dataProvider
                ?.collectionData.equipments
                .map<Equipment>((e) => Equipment.fromJson(e))
                .toList();
            _filteredEquipments = equipments!;
            _numPages = (_filteredEquipments.length / _itemsPerPage).ceil();
          } else {
            _numPages = 1;
          }
        });
      }).catchError((error) {
        debugPrint('Error fetching admin equipment: $error');
      });
    });
    super.initState();
  }

  bool loader = false;
  Future<void> loadCollectionData(Collections collection) async {
    setState(() => loader = true);
    await dataProvider?.fetchOneCollection(collection.id);
    setState(() => loader = false);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  int _currentPage = 0;
  final int _itemsPerPage = 10;
  int _numPages = 0;
  List<Equipment> _filteredEquipments = [];

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

  Widget equipmentCard(
      String title, String imageurl, String description, String link) {
    var media = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        // style: ElevatedButton.styleFrom(
        //     disabledBackgroundColor: const Color(0xFFF3F3F3),
        //     backgroundColor: Colors.white,
        //     elevation: 0,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.all(
        //         Radius.circular(ScreenUtil.verticalScale(12)),
        //       ),
        //       side: const BorderSide(color: Color(0x12000000), width: 0.5),
        //     ),
        //     surfaceTintColor: Colors.transparent,
        //     overlayColor: Colors.grey.shade400,
        //     padding: EdgeInsets.zero),
        onTap: () {
          _launchURL(link);
        },
        child: Container(
          width: media.width,
          height: ScreenUtil.verticalScale(11),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                offset: Offset(0, 1),
                color: Colors.black12,
                blurRadius: 5,
              ),
            ],
            // border: Border.all(color: AppColors.primaryColor),
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil.verticalScale(7)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              appShimmerImage(
                width: ScreenUtil.verticalScale(11),
                height: ScreenUtil.verticalScale(11),
                networkImageUrl:
                    imageurl.startsWith('https://storage.cloud.google.com/')
                        ? imageurl.replaceFirst(
                            'https://storage.cloud.google.com/',
                            'https://storage.googleapis.com/')
                        : imageurl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                ),
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.only(
              //       topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              //       bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              //     ),
              //   ),
              //   child: Center(
              //     child: imageurl.isNotEmpty
              //         ? ClipRRect(
              //             borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              //               bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              //             ),
              //             child: Image.network(
              //               imageurl.startsWith('https://storage.cloud.google.com/')
              //                   ? imageurl.replaceFirst(
              //                       'https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
              //                   : imageurl,
              //               width: ScreenUtil.verticalScale(11),
              //               height: ScreenUtil.verticalScale(11),
              //               fit: BoxFit.cover,
              //             ),
              //           )
              //         : ClipRRect(
              //             borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              //               bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              //             ),
              //             child: Image.asset(
              //               'assets/img/warm-up-placeholder.png',
              //               width: ScreenUtil.verticalScale(11),
              //               height: ScreenUtil.verticalScale(11),
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //   ),
              // ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: ScreenUtil.verticalScale(2),
                        fontWeight: FontWeight.bold,
                      ),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ),
                    // SizedBox(height: ScreenUtil.verticalScale(1)),
                    // Text(
                    //   description,
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: ScreenUtil.verticalScale(1.7),
                    //   ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                  ],
                ),
              ),
              SizedBox(width: 15),
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
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionData =
        ModalRoute.of(context)!.settings.arguments as Collections?;
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        appShimmerImage(
                          height: media.height / 2.35,
                          width: media.width,
                          networkImageUrl: (collectionData?.photo ?? "")
                                  .startsWith(
                                      'https://storage.cloud.google.com/')
                              ? (collectionData?.photo ?? "").replaceFirst(
                                  'https://storage.cloud.google.com/',
                                  'https://storage.googleapis.com/')
                              : (collectionData?.photo ?? ""),
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        SizedBox(
                          height: media.height / 2,
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
                                    'Collection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(5.5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(
                                          routeString: '/collectionDetail'),
                                    )
                                  ],
                                ),
                                Center(
                                  child: Container(
                                    height: media.height / 5.6,
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            ScreenUtil.horizontalScale(15),
                                        vertical: ScreenUtil.verticalScale(3)),
                                    child: Center(
                                      child: Text(
                                        (collectionData?.title ?? "").isNotEmpty
                                            ? collectionData?.title ?? ""
                                            : 'Collection Title',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              ScreenUtil.horizontalScale(6.5),
                                          fontWeight: FontWeight.bold,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 2.79,
                          width: media.width,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ClipPath(
                              clipper: DiagonalClipper(),
                              child: Container(
                                height: media.height / 11,
                                width: media.width / 6,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    return dataProvider.collectionData.equipments.isNotEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: media.height / 2.8),
                            width: media.width,
                            padding: EdgeInsets.only(
                                top: ScreenUtil.verticalScale(2)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    ScreenUtil.horizontalScale(15)),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(6)),
                              child: Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return Column(
                                    children: _getPaginatedEquipments()
                                        .map((equipment) {
                                      return Column(
                                        children: [
                                          equipmentCard(
                                            equipment.title,
                                            equipment.thumbnail,
                                            equipment.description,
                                            equipment.link,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(top: media.height / 2.8),
                            child: Container(
                              width: media.width,
                              height: media.height * 0.3,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                      ScreenUtil.horizontalScale(15)),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: loader
                                    ? CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      )
                                    : Text(
                                        "No Collection",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.color),
                                      ),
                              ),
                            ),
                          );
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      bottomSheet:
          Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return dataProvider.collectionData.equipments.isNotEmpty
            ? Container(
                alignment: Alignment.center,
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 65,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(bottom: 10),
                  child: _numPages > 0
                      ? NumberPaginator(
                          numberPages: _numPages,
                          config: const NumberPaginatorUIConfig(
                            height: 48,
                            buttonSelectedForegroundColor:
                                AppColors.primaryColor,
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
              )
            : SizedBox();
      }),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black54),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: media.width / 1.4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
