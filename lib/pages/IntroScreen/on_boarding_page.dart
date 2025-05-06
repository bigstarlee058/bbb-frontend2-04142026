import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/models/welcome_content_model.dart';
import 'package:bbb/pages/AuthScreen/login_page.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/utils/cache_image_manager.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Add this for shared preferences
import 'package:video_player/video_player.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int currentIndex = 0;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadWelcomeContent();
    _checkLoginStatus();
    _videoController =
        VideoPlayerController.asset('assets/videos/welcome_new.mp4', videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
              _videoController.setLooping(true);
              _videoController.play();
            });
          });
  }

  isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
    }
  }

  late WelcomeContentModel welcomeContentModel;

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(
            welcomeDescription: '',
            welcomeImageUrl: '',
          ),
        ),
      );
      await isFromNotification();
    }
  }

  void loadWelcomeContent() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      final descriptionResponse = await http.get(
        Uri.parse('${AppConstants.serverUrl}/api/screens/get_screens'), // replace with actual endpoint
      );

      if (descriptionResponse.statusCode == 200) {
        welcomeContentModel = welcomeContentModelFromJson(descriptionResponse.body);
        final image = CustomCacheManager().cacheImage(welcomeContentModel.imgUrl);
        prefs.setString("login_image", welcomeContentModel.imgUrl);
        // bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
      } else {
        showBottomAlert(context, 'Failed to load description');
        debugPrint('this is login page ${descriptionResponse.statusCode}');
      }
    } catch (e) {
      showBottomAlert(context, 'An error occurred');
      debugPrint('this is login page $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    var media = MediaQuery.of(context).size;

    void onPressCreateAccount() async {
      if (!isLoading) {
        Navigator.pushNamed(context, AppRoutes.registerScreen);
      }
      // final Uri url = Uri.parse('https://bbbdev1.wpenginepowered.com/shop');
      //
      // try {
      //   if (await canLaunchUrl(url)) {
      //     await launchUrl(
      //       url,
      //       mode: LaunchMode.externalApplication, // Ensures the URL opens in a browser
      //     );
      //   } else {
      //     debugPrint('Cannot launch the URL, not supported or no suitable app found.');
      //   }
      // } catch (e) {
      //   debugPrint('Error launching URL: $e');
      // }
    }

    void onPressLogin() {
      if (!isLoading) {
        Navigator.pushNamed(context, AppRoutes.loginScreen);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _isVideoInitialized
              ? SizedBox(height: media.height / 1.37, child: VideoPlayer(_videoController))
              : SizedBox(
                  width: ScreenUtil.horizontalScale(100),
                  child: Image.asset(
                    "assets/img/back.jpg",
                    fit: BoxFit.cover,
                  )),
          Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: media.width,
                  height: media.height / 6,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/img/bbb-logo.png'), fit: BoxFit.fitHeight, opacity: 1),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.horizontalScale(media.height / 10),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: Container(
              width: media.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil.verticalScale(8)),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 0,
                    top: -(media.height / 9.8) + 0.3,
                    child: ClipPath(
                      clipper: DiagonalClipper(),
                      child: Container(
                        height: media.height / 9.8,
                        width: media.width / 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(4.4)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: ScreenUtil.horizontalScale(2),
                        ),
                        isLoading
                            ? SizedBox(
                                height: media.height * .28,
                              )
                            : TextSlider(
                                slide: welcomeContentModel.slides,
                              ),
                        ButtonWidget(
                          text: 'Sign in',
                          textColor: Colors.white,
                          color: AppColors.primaryColor,
                          onPress: onPressLogin,
                          isLoading: false,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xff888888),
                              ),
                            ),
                            TextButton(
                              onPressed: onPressCreateAccount,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(65, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.center),
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.horizontalScale(7.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: ScreenUtil.horizontalScale(2.3),
      width: ScreenUtil.horizontalScale(2.3),
      margin: EdgeInsets.only(right: ScreenUtil.horizontalScale(3.6)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? AppColors.primaryColor : Colors.white,
      ),
    );
  }
}

class TextSlider extends StatefulWidget {
  final List<Slide> slide;

  const TextSlider({super.key, required this.slide});

  @override
  State<TextSlider> createState() => _TextSliderState();
}

class _TextSliderState extends State<TextSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method to build indicators (dots or numbers)
  Widget buildIndicator(int index) {
    bool isSelected = index == _currentIndex;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: isSelected
          ? Container(
              height: 8, //ScreenUtil.horizontalScale(5),
              width: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor),
            )
          : Container(
              height: ScreenUtil.horizontalScale(5),
              width: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor.withValues(alpha: .2)),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          // color: Colors.green,
          height: ScreenUtil.horizontalScale(44),
          child: Center(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.slide.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.slide[index].title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(2.6),
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        widget.slide[index].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScreenUtil.verticalScale(1.65),
                          height: 1.5,
                          color: Color(0xff6f6f6f),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.slide.length,
            (index) => buildIndicator(index),
          ),
        ),
        SizedBox(
          height: ScreenUtil.horizontalScale(3.5),
        ),
      ],
    );
  }
}
