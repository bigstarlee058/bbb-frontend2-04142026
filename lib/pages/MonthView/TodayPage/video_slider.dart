import 'package:bbb/pages/MonthView/TodayPage/slider_video_page.dart';
import 'package:bbb/routes/fade_page_route.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class VideoSlider extends StatefulWidget {
  const VideoSlider({super.key});

  @override
  State<VideoSlider> createState() => _VideoSliderState();
}

class _VideoSliderState extends State<VideoSlider> {
  int currentVideoIndex = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ScreenUtil.verticalScale(4)),
          ),
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: pageController,
              itemCount: 3,
              onPageChanged: (v) {
                currentVideoIndex = v;
                setState(() {});
              },
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/img/pp_4.png"),
                  ),
                ),
                margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(3)),
                child: Center(
                  child: IconButton(
                    iconSize: 60,
                    icon: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        FadePageRoute(
                          page: const SliderVideoPage(
                              videoUrl:
                                  'https://player.vimeo.com/progressive_redirect/playback/1046944756/rendition/1440p/file.mp4?loc=external&oauth2_token_id=1782285824&signature=0a8c7ae81c9e71258d2ec9446e16be900d8e8ef4792a4006041d5b27c9604ec0'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.horizontalScale(2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentVideoIndex == index ? AppColors.primaryColor : Colors.transparent,
                  border: Border.all(color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:bbb/pages/MonthView/TodayPage/slider_video_page.dart';
// import 'package:bbb/routes/fade_page_route.dart';
// import 'package:bbb/utils/screen_util.dart';
// import 'package:bbb/values/app_colors.dart';
// import 'package:flutter/material.dart';
//
// class VideoSlider extends StatefulWidget {
//   const VideoSlider({super.key});
//
//   @override
//   State<VideoSlider> createState() => _VideoSliderState();
// }
//
// class _VideoSliderState extends State<VideoSlider> {
//   int currentVideoIndex = 0;
//   PageController pageController = PageController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(ScreenUtil.verticalScale(6)),
//           ),
//           child: SizedBox(
//             height: 270,
//             child: PageView.builder(
//               controller: pageController,
//               itemCount: 3,
//               onPageChanged: (v) {
//                 currentVideoIndex = v;
//                 setState(() {});
//               },
//               itemBuilder: (context, index) => Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: AssetImage("assets/img/pp_4.png"),
//                   ),
//                 ),
//                 child: Center(
//                   child: IconButton(
//                     iconSize: 60,
//                     icon: Icon(
//                       Icons.play_circle_filled,
//                       color: Colors.white70,
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         FadePageRoute(
//                           page: const SliderVideoPage(
//                               videoUrl:
//                               'https://player.vimeo.com/progressive_redirect/playback/1046944756/rendition/1440p/file.mp4?loc=external&oauth2_token_id=1782285824&signature=0a8c7ae81c9e71258d2ec9446e16be900d8e8ef4792a4006041d5b27c9604ec0'),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: ScreenUtil.horizontalScale(2),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             3,
//                 (index) => Padding(
//               padding: const EdgeInsets.all(5),
//               child: Container(
//                 height: 10,
//                 width: 10,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: currentVideoIndex == index ? AppColors.primaryColor : Colors.transparent,
//                   border: Border.all(color: AppColors.primaryColor),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
