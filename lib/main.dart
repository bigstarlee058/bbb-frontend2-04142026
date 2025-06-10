import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:bbb/firebase_options.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/AuthScreen/login_page.dart';
import 'package:bbb/pages/AuthScreen/reset_password_page.dart';
import 'package:bbb/pages/AuthScreen/sign_up_screen.dart';
import 'package:bbb/pages/AuthScreen/splash_screen.dart';
import 'package:bbb/pages/CalenderPage/calendar_page.dart';
import 'package:bbb/pages/CalenderPage/streak_calendar.dart';
import 'package:bbb/pages/ChallengeView/joined_challeng_page.dart';
import 'package:bbb/pages/CollectionView/collection_detail_page.dart';
import 'package:bbb/pages/DashBoardScreen/join_the_challenge.dart';
import 'package:bbb/pages/DashBoardScreen/meet_our_staff.dart';
import 'package:bbb/pages/DashBoardScreen/program_phase_screen.dart';
import 'package:bbb/pages/IntroScreen/on_boarding_page.dart';
import 'package:bbb/pages/MonthView/DayCompletedPage/day_completed_page.dart';
import 'package:bbb/pages/MonthView/DayOverviewPage/day_overview.dart';
import 'package:bbb/pages/MonthView/ExercisePage/excerise_page.dart';
import 'package:bbb/pages/MonthView/TodayPage/today_page.dart';
import 'package:bbb/pages/Notification/notifications_page.dart';
import 'package:bbb/pages/ProfileAndSettings/language_page.dart';
import 'package:bbb/pages/ProfileAndSettings/myprofile_page.dart';
import 'package:bbb/pages/ProfileAndSettings/setting_page.dart';
import 'package:bbb/pages/Tools/GraphsReports/graph_and_reports_page.dart';
import 'package:bbb/pages/Tools/bonus_library_page.dart';
import 'package:bbb/pages/Tools/equipment_library_page.dart';
import 'package:bbb/pages/Tools/exercise_history.dart';
import 'package:bbb/pages/Tools/exercise_library_detail_page.dart';
import 'package:bbb/pages/Tools/exercise_library_page.dart';
import 'package:bbb/pages/Tools/faqs_page.dart';
import 'package:bbb/pages/Tools/nutrition_calculator_page.dart';
import 'package:bbb/pages/Tools/recalculate_page.dart';
import 'package:bbb/pages/Tools/tutorial_page.dart';
import 'package:bbb/pages/WatchTutorial/app_tutorial.dart';
import 'package:bbb/pages/WatchTutorial/watch_tutorial.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/location_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/program_info_provider.dart';
import 'package:bbb/providers/scroll_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'localstorage/month_database.dart';
import 'pages/SubscriptionPage/subscription_pay_wall.dart';
import 'pages/Tools/seeall_achievement_page_new.dart';
import 'providers/month_provider.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

BuildContext? c;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  const androidInitializationSetting =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInitializationSetting = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
      android: androidInitializationSetting, iOS: iosInitializationSetting);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    onDidReceiveNotificationResponse: (details) async {
      final isLastExerciseScreen =
          preferences.getString(SharedPreference.inTheExerciseScreenOrNot);
      if (isLastExerciseScreen == "NO") {
        await preferences.putString(
            SharedPreference.payload, details.payload ?? "{}");
        await preferences.putInt(SharedPreference.fromNotification, 1);
        navigatorKey.currentState?.pushNamed('/exercise');
      }
    },
  );

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final isLastExerciseScreen =
        preferences.getString(SharedPreference.inTheExerciseScreenOrNot);
    if (isLastExerciseScreen == "NO") {
      final String? payload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      await preferences.putString(SharedPreference.payload, payload ?? "{}");
      await preferences.putInt(SharedPreference.fromNotification, 1);
    }
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => MyApp(),
  //   ),
  // );
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final dataProvider = ChangeNotifierProvider<DataProvider>(
    create: (context) => DataProvider(),
  );
  final userDataProvider = ChangeNotifierProvider<UserDataProvider>(
    create: (context) => UserDataProvider(),
  );
  final programInfoProvider = ChangeNotifierProvider<ProgramInfoProvider>(
    create: (context) => ProgramInfoProvider(),
  );
  final locationProvider = ChangeNotifierProvider<LocationProvider>(
    create: (context) => LocationProvider(),
  );
  final mainPageProvider = ChangeNotifierProvider<MainPageProvider>(
    create: (context) => MainPageProvider(),
  );
  final monthProvider = ChangeNotifierProvider<MonthProvider>(
    create: (context) => MonthProvider(),
  );
  final scrollProvider = ChangeNotifierProvider<ScrollProvider>(
    create: (context) => ScrollProvider(),
  );

  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initialisation();
    _initDeepLinkListener();
    _initializeRevenueCat();
  }

  _initialisation() async {
    await preferences.init();
    await DatabaseHelper().initDatabase();
  }

  _initializeRevenueCat() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isIOS) {
        await Purchases.configure(
            PurchasesConfiguration('appl_ZBToJDBIilfrwIWaWFcKrwbUkAr'));
        Offerings offering = await Purchases.getOfferings();
        await preferences.putString(
            SharedPreference.offerings, jsonEncode(offering));
      }
    });
  }

  Future<void> _initDeepLinkListener() async {
    // Initialize AppLinks and handle the deep link in the callback
    // _appLinks = AppLinks(
    //   onAppLink: (Uri uri, String? stringUri) {
    //     _handleDeepLink(uri.toString());
    //   },
    // );
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri.toString());
    });
  }

  void _handleDeepLink(String? deepLink) {
    if (deepLink != null) {
      // Parse the deep link and navigate to the appropriate page
      Uri uri = Uri.parse(deepLink);
      // Check if the scheme and host are correct
      if (uri.scheme == 'https' && uri.host == 'bbbdev1.wpenginepowered.com') {
        // Example: Check the path
        Navigator.of(context).pushNamed(AppRoutes.mainScreen);
      } else {
        // Handle unsupported schemes or hosts if necessary
        debugPrint('Unsupported deep link: $deepLink');
      }
    }
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    c = context;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: MultiProvider(
        providers: [
          dataProvider,
          userDataProvider,
          locationProvider,
          mainPageProvider,
          programInfoProvider,
          monthProvider,
          scrollProvider,
        ],
        child: MaterialApp(
          navigatorObservers: <NavigatorObserver>[observer],
          navigatorKey: navigatorKey,
          locale: !kReleaseMode ? DevicePreview.locale(context) : null,
          builder: !kReleaseMode ? DevicePreview.appBuilder : null,
          title: 'Booty by Bret',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
                titleTextStyle: TextStyle(fontWeight: FontWeight.w400)),
            primaryColor: AppColors.primaryColor,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashScreen,
          routes: {
            AppRoutes.splashScreen: (context) => const SplashScreen(),
            AppRoutes.onBoardingScreen: (context) => const OnBoardingPage(),
            AppRoutes.mainScreen: (context) =>
                const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
            AppRoutes.loginScreen: (context) => const LoginPage(),
            AppRoutes.registerScreen: (context) => const SignupPage(image: ''),
            AppRoutes.nutritionCalculatorScreen: (context) =>
                const NutritionCalculatorPage(),
            AppRoutes.programPhaseScreen: (context) =>
                const ProgramPhaseScreen(),
            AppRoutes.graphAndReportsScreen: (context) =>
                const GraphAndReportsPage(),
            AppRoutes.exerciseHistory: (context) => const ExerciseHistoryPage(),
            AppRoutes.exerciseLibraryDetailScreen: (context) =>
                const ExerciseLibraryDetailPage(),
            AppRoutes.exerciseLibraryScreen: (context) =>
                const ExerciseLibraryPage(),
            AppRoutes.equipmentLibraryScreen: (context) =>
                const EquipmentLibraryPage(),
            AppRoutes.bonusLibraryScreen: (context) => const BonusLibraryPage(),
            AppRoutes.tutorialScreen: (context) => const TutorialPage(),
            AppRoutes.passwordresetScreen: (context) =>
                const ResetPasswordScreen(image: ''),
            // AppRoutes.emailVerificationScreen: (context) =>
            //     const EmailVerificationScreen(),
            AppRoutes.dayOverviewScreen: (context) => const DayOverviewPage(),
            AppRoutes.todayScreen: (context) => const TodayPage(),
            AppRoutes.dayCompletedScreen: (context) => const DayCompletedPage(),
            AppRoutes.exerciseScreen: (context) => const ExercisePage(),
            AppRoutes.recalculateScreen: (context) => const RecalculatePage(),
            // AppRoutes.streakScreen: (context) => const StreakPage(),
            AppRoutes.calendarScreen: (context) => const CalendarPage(),
            AppRoutes.watchTutorialScreen: (context) => const WatchTutorial(),
            AppRoutes.myProfileScreen: (context) => const MyProfilePage(),
            AppRoutes.languageScreen: (context) => const LanguagePage(),
            AppRoutes.streakCalendarScreen: (context) =>
                const StreakCalendarPage(),
            AppRoutes.notificationsScreen: (context) =>
                const NotificationsPage(),
            AppRoutes.joinChallengeScreen: (context) =>
                const JoinTheChallengePage(),
            AppRoutes.meetOurStaff: (context) => const MeetOurStaff(),
            AppRoutes.joinedChallengeScreen: (context) =>
                const JoinedChallengePage(),
            AppRoutes.collectionDetailScreen: (context) =>
                const CollectionDetailPage(),
            AppRoutes.appTutorialScreen: (context) => const AppTutorial(),
            AppRoutes.settingPage: (context) => const SettingPage(),
            AppRoutes.seeAllAchievementPage: (context) =>
                const SeeAllAchievementPage(),
            AppRoutes.faqsPage: (context) => const FAQsPage(),
            AppRoutes.paywall: (context) => const SubscriptionPayWall(),
          },
        ),
      ),
    );
  }
}
