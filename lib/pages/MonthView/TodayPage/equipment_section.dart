import 'package:bbb/providers/month_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/screen_util.dart';
import '../../../../values/app_colors.dart';

class EquipmentSection extends StatefulWidget {
  const EquipmentSection({super.key});

  @override
  State<EquipmentSection> createState() => _EquipmentSectionState();
}

class _EquipmentSectionState extends State<EquipmentSection> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Consumer<MonthProvider>(builder: (context, monthProvider, child) {
      return monthProvider.usedEquipments.isEmpty
          ? SizedBox()
          : Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  width: media.width,
                  color: Colors.black12,
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipment used',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: List.generate(
                    monthProvider.usedEquipments.length,
                        (index) => Column(
                      children: [
                        equipmentCard(
                          monthProvider.usedEquipments[index].title!,
                          monthProvider
                              .usedEquipments[index].description!,
                          monthProvider.usedEquipments[index].link!,
                          monthProvider.usedEquipments[0].thumbnail!,
                        ),
                        if (index <
                            monthProvider.usedEquipments.length - 1)
                          const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
    });
  }

  Widget equipmentCard(
      String title, String description, String link, String image) {
    return ElevatedButton(
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
        _launchURL(link); // Launch the external URL when tapped
      },
      child: Container(
        width: ScreenUtil.horizontalScale(100),
        height: ScreenUtil.verticalScale(11),

        // Padding around the background
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(7)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil.verticalScale(11),
              height: ScreenUtil.verticalScale(11),

              // Padding around the background
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                ),
                image: DecorationImage(
                  image: image.isNotEmpty
                      ? NetworkImage(
                          image.startsWith('https://storage.cloud.google.com/')
                              ? image.replaceFirst(
                                  'https://storage.cloud.google.com/',
                                  'https://storage.googleapis.com/')
                              : image)
                      : const AssetImage('assets/img/back.jpg'),
                  fit: BoxFit.cover,
                  opacity: 1,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
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
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
