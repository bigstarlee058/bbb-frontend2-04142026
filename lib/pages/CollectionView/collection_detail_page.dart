import 'package:bbb/components/back_arrow_widget.dart';
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
      final collection = ModalRoute.of(context)!.settings.arguments as Collections;
      await loadCollectionData(collection);
    });
    super.initState();
  }

  Future<void> loadCollectionData(Collections collection) async {
    await dataProvider?.fetchOneCollection(collection.id);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget equipmentCard(String title, String imageurl, String description, String link) {
    var media = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor: const Color(0xFFF3F3F3),
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
              side: const BorderSide(color: Color(0x12000000), width: 0.5),
            ),
            surfaceTintColor: Colors.transparent,
            overlayColor: Colors.grey.shade400,
            padding: EdgeInsets.zero),
        onPressed: () {
          _launchURL(link);
        },
        child: Container(
          width: media.width,
          height: ScreenUtil.verticalScale(11),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            // border: Border.all(color: AppColors.primaryColor),
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil.verticalScale(7)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                    bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  ),
                ),
                child: Center(
                  child: imageurl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                            bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                          ),
                          child: Image.network(
                            imageurl.startsWith('https://storage.cloud.google.com/')
                                ? imageurl.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                                : imageurl,
                            width: ScreenUtil.verticalScale(11),
                            height: ScreenUtil.verticalScale(11),
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                            bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                          ),
                          child: Image.asset(
                            'assets/img/warm-up-placeholder.png',
                            width: ScreenUtil.verticalScale(11),
                            height: ScreenUtil.verticalScale(11),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.verticalScale(2),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ScreenUtil.verticalScale(1)),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.verticalScale(1.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
              GestureDetector(
                onTap: null,
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil.verticalScale(0.6)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/shopping-bag.svg",
                    height: ScreenUtil.verticalScale(3),
                    colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
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
    final collectionData = ModalRoute.of(context)!.settings.arguments as Collections?;
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
                        Container(
                          height: media.height / 2.35,
                          width: media.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: collectionData!.photo.isNotEmpty
                                  ? NetworkImage(
                                      collectionData.photo.startsWith('https://storage.cloud.google.com/')
                                          ? collectionData.photo
                                              .replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                                          : collectionData.photo,
                                    )
                                  : const AssetImage('assets/img/back.jpg'),
                              fit: BoxFit.cover,
                              opacity: 1,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 2,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      BackArrowWidget(
                                        onPress: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Text(
                                        'Collection',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.verticalScale(3),
                                        ),
                                      ),
                                      const CommonStreakWithNotification(routeString: '/collectionDetail')
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    height: media.height / 5.6,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil.horizontalScale(15), vertical: ScreenUtil.verticalScale(3)),
                                    child: Center(
                                      child: Text(
                                        collectionData.title.isNotEmpty ? collectionData.title : 'Collection Title',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.horizontalScale(6.5),
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
                Consumer<DataProvider>(builder: (context, dataProvider, child) {
                  final List<Equipment> equipments = dataProvider.collectionData.equipments
                      .map<Equipment>((e) => Equipment.fromJson(e)) // or `e as Equipment`
                      .toList();
                  return equipments.isNotEmpty
                      ? Container(
                          margin: EdgeInsets.only(top: media.height / 2.8),
                          child: Container(
                            width: media.width,
                            padding: EdgeInsets.only(top: ScreenUtil.verticalScale(2)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ScreenUtil.horizontalScale(15)),
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
                              child: Column(
                                children: equipments.map((equipment) {
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
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: media.height / 2.8),
                          child: Container(
                            width: media.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ScreenUtil.horizontalScale(15)),
                              ),
                            ),
                            child: Container(
                                margin: EdgeInsets.only(top: media.height / 19, right: 20, left: 20),
                                child: const SizedBox(
                                  height: 100,
                                )),
                          ),
                        );
                }),
              ],
            ),
          ],
        ),
      ),
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
