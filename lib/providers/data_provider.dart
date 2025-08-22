import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/month_response_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/SyncDataResponseModel/avhievements_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_notes_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_set_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/removed_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/swap_exercise_data_model.dart';
import 'package:bbb/models/bonuses.dart';
import 'package:bbb/models/category.dart';
import 'package:bbb/models/challenges.dart';
import 'package:bbb/models/choose_equipment_data_model.dart';
import 'package:bbb/models/choose_workout_data_model.dart';
import 'package:bbb/models/collections.dart';
import 'package:bbb/models/equipment.dart';
import 'package:bbb/models/equipmenttitle.dart';
import 'package:bbb/models/exerciselibrary.dart';
import 'package:bbb/models/faqs_model.dart';
import 'package:bbb/models/get_all_achivements.dart';
import 'package:bbb/models/new_version_model.dart';
import 'package:bbb/models/program_phase_model.dart';
import 'package:bbb/models/screen_bg_model.dart';
import 'package:bbb/models/staffs.dart';
import 'package:bbb/models/tutorial_details_model.dart';
import 'package:bbb/models/tutorial_model.dart';
import 'package:bbb/models/tutorials.dart';
import 'package:bbb/models/vimeo_to_video_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/cache_image_manager.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:path/path.dart';

import '../models/exercise_model.dart';

class DataProvider extends ChangeNotifier {
  List<ExerciseLibrary> adminExercises = [];
  List<CategoryTitle> adminCategory = [];
  List<EquipmentTitle> adminEquipment = [];
  List<Equipment> adminEquipmentsData = [];
  List<Bonuses> adminBonusesData = [];
  MonthProvider? monthProvider;

  List<Staffs> staffsData = [];
  List<dynamic> selectWeekBasedOnSplit = [];
  List<Staffs> athletesData = [];
  List<Collections> collectionsData = [];
  String equipmentCheckpoint = '';
  String bonusCheckpoint = '';
  String workoutCheckpoint = '';
  bool equipmentCheckpointState = false;
  bool bonusCheckpointState = false;
  bool workoutCheckpointState = false;

  GetChooseWorkoutModel? getChooseWorkoutModel;
  ScreenBackgroundResponse? screenBackgroundModel;
  GetChooseEquipmentModel? getChooseEquipmentModel;
  List<FaQsModel> faQsModel = [];
  bool faqLoader = false;

  bool openDaySinceJoin = false;

  updateOpenDaySinceJoin(bool val) {
    openDaySinceJoin = val;
    notifyListeners();
  }

  Collections collectionData = Collections(
      id: "", title: "", description: "", photo: "", equipments: []);
  Exercise currentExerciseObj = Exercise(
      videoThumbnail: "",
      id: "",
      title: "",
      vimeoId: "",
      thumbnail: "",
      description: "",
      guide: "",
      relatedExercises: [],
      categories: [],
      usedEquipments: [],
      files: []);
  late List<Exercise> currentRelatedExercises = [];

  Challenges featureChallengeData =
      Challenges(id: '', title: '', description: '', photo: '');
  Tutorials tutorialData =
      Tutorials(id: "", title: "", description: "", photo: "", files: []);

  NewVersionModel? newVersionModel;

  Future<void> fetchAppVersion() async {
    final Dio dio = Dio();
    final String url = '${AppConstants.serverUrl}/api/version/get_version';
    String? userIdToken = await getAuthToken();

    try {
      final response = await dio.get(url,
          options: Options(headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'AUTH_TOKEN': userIdToken
          }));
      if (response.statusCode == 200 && response.data != null) {
        newVersionModel = NewVersionModel.fromJson(response.data);
        notifyListeners();
      } else {
        throw Exception('Failed to get app version');
      }
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get app version');
    } catch (e) {
      debugPrint('General error: $e');
      throw Exception('Failed to get app version');
    }
  }

  List<Map<String, dynamic>> allImageList = [];
  Future<void> getAppBGs() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/screens/get_screens');

    String? userIdToken = await getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null) {
          screenBackgroundModel = ScreenBackgroundResponse.fromJson(data);
          notifyListeners();

          allImageList = [
            {
              "image": screenBackgroundModel?.imageDashboard ?? "",
              "key": "imageDashboard"
            },
            {
              "image": screenBackgroundModel?.imageLogin ?? "",
              "key": "imageLogin"
            },
            {
              "image": screenBackgroundModel?.imageSignup ?? "",
              "key": "imageSignup"
            },
            {
              "image": screenBackgroundModel?.imageEmailConfirm ?? "",
              "key": "imageEmailConfirm"
            },
            {
              "image": screenBackgroundModel?.imageAchievement ?? "",
              "key": "imageAchievement"
            },
            {
              "image": screenBackgroundModel?.imageApparel ?? "",
              "key": "imageApparel"
            },
            {
              "image": screenBackgroundModel?.imageExerciseLibrary ?? "",
              "key": "imageExerciseLibrary"
            },
            {
              "image": screenBackgroundModel?.imageFaQs ?? "",
              "key": "imageFaQs"
            },
            {
              "image": screenBackgroundModel?.imageForgot ?? "",
              "key": "imageForgot"
            },
            {
              "image": screenBackgroundModel?.imageGraphs ?? "",
              "key": "imageGraphs"
            },
            {
              "image": screenBackgroundModel?.imageMonthView ?? "",
              "key": "imageMonthView"
            },
            {
              "image": screenBackgroundModel?.imageMyProfle ?? "",
              "key": "imageMyProfle"
            },
            {
              "image": screenBackgroundModel?.imageProfile ?? "",
              "key": "imageProfile"
            },
            {
              "image": screenBackgroundModel?.imageSetting ?? "",
              "key": "imageSetting"
            },
            {
              "image": screenBackgroundModel?.imageStreakCalendar ?? "",
              "key": "imageStreakCalendar"
            },
            {
              "image": screenBackgroundModel?.imageToday ?? "",
              "key": "imageToday"
            },
            {
              "image": screenBackgroundModel?.imageTools ?? "",
              "key": "imageTools"
            },
          ];
        }

        await preloadAndCacheImages();
        // allImages = allImageList;
      } else {
        throw Exception('Failed to get screen bg data');
      }
    } catch (e) {
      throw Exception('Failed to get screen bg data');
    } finally {
      notifyListeners();
    }
  }

  bool loader = false;

  List<AchievementModel> achievementList = [];

  Future getAllAchievement(bool value) async {
    if (value) {
      loader = true;
      notifyListeners();
    }

    List<AchievementsDataModel> achievementsData =
        await ApiRepo.fetchAchievementsList();
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/achievements-group/get');
    String? userIdToken = await getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        achievementList = List<AchievementModel>.from(
            data.map((x) => AchievementModel.fromJson(x)));
        for (var element in achievementList) {
          if (element.achievements!.isNotEmpty) {
            for (var ele in element.achievements!) {
              if (achievementsData.isEmpty) {
                if ((ele.achievementAchievementId?.value ?? 0) <=
                    (element.currentValue ?? 0)) {
                  DateTime now = await NTP.now();

                  await ApiRepo.addAchievementsList(
                      body: UpdateAchievementsRequest(
                    achievementsDate: now.toString(),
                    achievementsTitle:
                        ele.achievementAchievementId?.achievementIdId ?? "",
                    achievementsSubtitle: "SYNC",
                  ).toJson1());

                  ele.achieved = true;
                  ele.achievedDate = now.toString();
                }
              } else if (achievementsData.isNotEmpty &&
                  (achievementsData.any((z) =>
                          z.achievementsTitle ==
                          ele.achievementAchievementId?.achievementIdId) ==
                      false)) {
                DateTime now = await NTP.now();
                if ((ele.achievementAchievementId!.value)! <=
                    (element.currentValue!)) {
                  final data = UpdateAchievementsRequest(
                    achievementsDate: now.toString(),
                    achievementsTitle:
                        ele.achievementAchievementId?.achievementIdId ?? "",
                    achievementsSubtitle: "SYNC",
                  );
                  await ApiRepo.addAchievementsList(body: data.toJson1());

                  ele.achieved = true;
                  ele.achievedDate = now.toString();
                }
              } else {
                if (achievementsData.isNotEmpty) {
                  AchievementsDataModel? data = achievementsData.firstWhere(
                      (demo) =>
                          demo.achievementsTitle ==
                          (ele.achievementAchievementId?.achievementIdId ??
                              ""));
                  ele.achieved = true;
                  ele.achievedDate = data.achievementsDate.toString();
                }
              }
            }
          }
        }

        if (achievementList.isNotEmpty) {
          achievementList.sort((a, b) {
            final aAchievedCount =
                (a.achievements)?.where((item) => item.achieved == true).length;
            final bAchievedCount =
                (b.achievements)?.where((item) => item.achieved == true).length;

            if (bAchievedCount != aAchievedCount) {
              return bAchievedCount!.compareTo(aAchievedCount!);
            }

            final aTitle = a.title?.toString().toLowerCase() ?? '';
            final bTitle = b.title?.toString().toLowerCase() ?? '';
            return aTitle.compareTo(bTitle);
          });
        }
      } else {
        throw Exception('Failed to get achievementList');
      }
    } catch (e) {
      throw Exception('Failed to get achievementList');
    } finally {
      if (value) {
        loader = false;
      }
      notifyListeners();
    }
  }

  List<TutorialModel> tutorialList = [];
  bool tutorialLoader = false;
  Future getAllTutorials() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/tutorials/get');
    String? userIdToken = await getAuthToken();
    if (tutorialList.isEmpty) {
      tutorialLoader = true;
      notifyListeners();
    }
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        tutorialList = List<TutorialModel>.from(
            data.map((x) => TutorialModel.fromJson(x)));
        notifyListeners();
      } else {
        throw Exception('Failed to get tutorialList');
      }
    } catch (e) {
      throw Exception('Failed to get tutorialList');
    } finally {
      tutorialLoader = false;
      notifyListeners();
    }
  }

  TutorialDataModel? tutorialDataModel;
  Future getTutorialDetails({required String id}) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/tutorials/get/$id');
    String? userIdToken = await getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        tutorialDataModel = TutorialDataModel.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to get tutorialDataModel');
      }
    } catch (e) {
      throw Exception('Failed to get tutorialDataModel');
    }
  }

  ProgramPhaseModel? programPhaseModel;
  Future getProgramPhaseDetails() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/phases/get');
    String? userIdToken = await getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        programPhaseModel = ProgramPhaseModel.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to get programPhaseModel');
      }
    } catch (e) {
      throw Exception('Failed to get programPhaseModel');
    }
  }

  VimeoToVideoModel? videoModel;
  Future getVideoUsingVimeo(String vimeoId) async {
    Uri url = Uri.parse(
        '${AppConstants.serverUrl}/api/workouts/getVideoUrl/$vimeoId');
    String? userIdToken = await getAuthToken();
    videoModel = null;
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        videoModel = VimeoToVideoModel.fromJson(data);

        notifyListeners();
      } else {
        throw Exception('Failed to get videoModel');
      }
    } catch (e) {
      throw Exception('Failed to get videoModel');
    }
  }

  Map<String, FileImage> cachedImageMap = {};

  Future<void> preloadAndCacheImages() async {
    for (var element in allImageList) {
      String url = element["image"];
      String key = element["key"];

      final processedUrl = url.startsWith('https://storage.cloud.google.com/')
          ? url.replaceFirst('https://storage.cloud.google.com/',
              'https://storage.googleapis.com/')
          : url;

      try {
        final file = await CustomCacheManager().getSingleFile(processedUrl);
        cachedImageMap[key] = FileImage(file);
      } catch (e) {
        debugPrint("Image cache failed for $key: $e");
      }
    }
  }

  Future<bool> joinChallenge(String? userid, String? challengeid) async {
    final challengeDetail = {
      '_id': challengeid,
      'joinedUserId': userid,
    };
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/challenges');
    String? userIdToken = await getAuthToken();
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
        body: jsonEncode(challengeDetail));
    if (response.statusCode == 200) {
      log('User data updated successfully');
      return true;
    } else {
      throw Exception('Failed to update user data: ${response.body}');
    }
  }

  Future<void> fetchStaffs() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/staffs/get');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body) as List;
        staffsData = res
            .where((item) => item['type'] == 1)
            .map((item) => Staffs.fromJson(item))
            .toList();
        athletesData = res
            .where((item) => item['type'] == 2)
            .map((item) => Staffs.fromJson(item))
            .toList();
        athletesData.add(
          Staffs(
            id: '',
            title: '',
            location: '',
            type: 2,
            bio: '',
            photo: '',
            link: '',
            facebook: '',
            linkedin: '',
            tiktok: '',
            twitter: '',
            instagram: '',
          ),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Challenges get featureChallenge => featureChallengeData;

  Future<void> fetchFeaturedChalleng() async {
    Uri url =
        Uri.parse('${AppConstants.serverUrl}/api/challenges/get-featured');
    String? userIdToken = await getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data != null) {
          featureChallengeData = Challenges.fromJson(data);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future<void> getChooseWorkoutData() async {
    Uri url = Uri.parse(
        '${AppConstants.serverUrl}/api/popupworkout/get_popupworkout');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data != null) {
          getChooseWorkoutModel = GetChooseWorkoutModel.fromJson(data);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to get choose workout data');
      }
    } catch (e) {
      throw Exception('Failed to get choose workout data');
    }
  }

  Future<void> getChooseEquipmentData() async {
    Uri url = Uri.parse(
        '${AppConstants.serverUrl}/api/popupequipment/get_popupequipment');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data != null) {
          getChooseEquipmentModel = GetChooseEquipmentModel.fromJson(data);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to get choose equipment data');
      }
    } catch (e) {
      throw Exception('Failed to get choose equipment data');
    }
  }

  Future<void> getFAQs() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/faqs');
    String? userIdToken = await getAuthToken();
    try {
      faqLoader = true;
      notifyListeners();
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null) {
          // faQsModel = FaQsModel.fromJson(data);
          faQsModel =
              List<FaQsModel>.from(data.map((x) => FaQsModel.fromJson(x)));
        }
        // faqLoader = false;
        notifyListeners();
      } else {
        faqLoader = false;
        notifyListeners();
        throw Exception('Failed to get FAQs data');
      }
    } catch (e) {
      faqLoader = false;
      notifyListeners();
      throw Exception('Failed to get FAQs data');
    }
  }

  updateFaqLoader(value) {
    faqLoader = value;
    notifyListeners();
  }

  List<Collections> get collections => collectionsData;

  Future<void> fetchFeaturedColllections() async {
    Uri url =
        Uri.parse('${AppConstants.serverUrl}/api/collections/get-featured');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['collections'] is List) {
          // Map the 'staffs' list to Staff objects
          collectionsData = (data['collections'] as List)
              .map((item) => Collections.fromJson(item))
              .toList();
          notifyListeners(); // Notify listeners to update the UI
        }
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Collections get oneCollection => collectionData;

  Future<void> fetchOneCollection(String collectionId) async {
    collectionData = Collections(
        id: "", title: "", description: "", photo: "", equipments: []);
    notifyListeners();
    Uri url = Uri.parse(
        '${AppConstants.serverUrl}/api/collections/get/$collectionId');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        collectionData = Collections.fromJson(data);
        notifyListeners(); // Notify listeners to update the UI
      } else {
        collectionData = Collections(
            id: "", title: "", description: "", photo: "", equipments: []);
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future<void> fetchAdminData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get');
    String? userIdToken = await getAuthToken();

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('exercises') &&
          responseData.containsKey('categories') &&
          responseData.containsKey('equipments')) {
        List<dynamic> exercisesData = responseData['exercises'];
        List<ExerciseLibrary> exerciseList = exercisesData.map((exerciseJson) {
          return ExerciseLibrary.fromJson(exerciseJson);
        }).toList();
        List<dynamic> categoriesData = responseData['categories'];
        List<CategoryTitle> categoryList = categoriesData.map((categoryJson) {
          return CategoryTitle.fromJson(categoryJson);
        }).toList();

        List<dynamic> equipmentsData = responseData['equipments'];
        List<EquipmentTitle> equipmentList =
            equipmentsData.map((equipmentJson) {
          return EquipmentTitle.fromJson(equipmentJson);
        }).toList();

        adminExercises = exerciseList;
        adminCategory = categoryList;
        adminEquipment = equipmentList;

        notifyListeners();
      } else {
        throw Exception(
            'Missing data in response (exercises, categories, or equipments)');
      }
    } else {
      throw Exception('Failed to load admin data');
    }
  }

  Future<void> fetchAdminEquipmentsData() async {
    Uri url = Uri.parse(
        '${AppConstants.serverUrl}/api/equipments/admin/get?perPage=100000');
    String? userIdToken = await getAuthToken();
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('equipments')) {
        List<dynamic> equipmentsData = responseData['equipments'];
        List<Equipment> equipmentList = equipmentsData.map((equipmentJson) {
          return Equipment.fromJson(equipmentJson);
        }).toList();

        adminEquipmentsData = equipmentList;

        notifyListeners();
      } else {
        throw Exception('Missing data in response (equipments)');
      }
    } else {
      throw Exception('Failed to load admin data');
    }
  }

  Future<void> fetchAdminBonusesData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/bonuses/admin/get');
    String? userIdToken = await getAuthToken();

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('bonuses')) {
        List<dynamic> bonusesData = responseData['bonuses'];
        List<Bonuses> bonusesList = bonusesData.map((bonusJson) {
          return Bonuses.fromJson(bonusJson);
        }).toList();

        adminBonusesData = bonusesList;

        notifyListeners();
      } else {
        throw Exception('Missing data in response (bonuses)');
      }
    } else {
      throw Exception('Failed to load admin data');
    }
  }

  Future fetchMonthWorkouts(int month) async {
    final Dio dio = Dio();
    final String url = '${AppConstants.serverUrl}/api/workouts/current';
    try {
      DateTime now = await NTP.now();

      final Map<String, String> queryParams = {
        'month': month.toString(),
        'equipment': '0',
        'split': '5',
        'date': "$now",
      };

      String? userIdToken = await getAuthToken();

      final response = await dio.post(
        url,
        data: FormData.fromMap(queryParams),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'AUTH_TOKEN': userIdToken,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        await getMonthInfoFromJson(responseData: response.data);
        notifyListeners();
      } else {
        await getMonthInfoFromJson();
      }
    } on DioException catch (e) {
      debugPrint(
          "Dio error in month view loading => ${e.response?.data ?? e.message}");
      await getMonthInfoFromJson();
    } catch (e) {
      debugPrint("General error in month view loading => $e");
      await getMonthInfoFromJson();
    }
  }

  Future<void> getMonthInfoFromJson(
      {Map<String, dynamic>? responseData}) async {
    try {
      if (responseData != null) {
        MonthDataModel monthDataModelSplit3 =
            MonthDataModel.fromJson(responseData);
        MonthDataModel monthDataModelSplit4 =
            MonthDataModel.fromJson(responseData);
        MonthDataModel monthDataModelSplit5 =
            MonthDataModel.fromJson(responseData);
        await monthProvider?.fetchMonthLocalData();

        List split3 = [
          "Day 1 Workout",
          "Rest Day 1",
          "Day 2 Workout",
          "Rest Day 2",
          "Day 3 Workout",
          "Rest Day 3",
          "Rest Day 4"
        ];

        List split4 = [
          "Day 1 Workout",
          "Day 2 Workout",
          "Rest Day 1",
          "Day 3 Workout",
          "Day 4 Workout",
          "Rest Day 2",
          "Rest Day 3"
        ];

        List split5 = [
          "Day 1 Workout",
          "Day 2 Workout",
          "Day 3 Workout",
          "Day 4 Workout",
          "Day 5 Workout",
          "Rest Day 1",
          "Rest Day 2"
        ];

        await preferences.putString(
            SharedPreference.monthId, "${monthDataModelSplit3.id}");
        monthDataModelSplit3.weeks?.forEach(
          (element) {
            element.dayList = split3;
            element.idList = [
              "${element.id} split3 Day 1 Workout",
              "${element.id} split3 Rest Day 1",
              "${element.id} split3 Day 2 Workout",
              "${element.id} split3 Rest Day 2",
              "${element.id} split3 Day 3 Workout",
              "${element.id} split3 Rest Day 3",
              "${element.id} split3 Rest Day 4",
            ];
            element.restDayList = [
              "Rest Day 1",
              "Rest Day 2",
              "Rest Day 3",
              "Rest Day 4"
            ];
            element.days
                ?.removeWhere((element) => !element.formats!.contains("3"));
            for (var i = 0; i < element.days!.length; i++) {
              element.days?[i].dayType = split3[i];
            }
          },
        );

        await preferences.putString(
            "${SplitType.split3}-${monthDataModelSplit3.id}",
            jsonEncode(monthDataModelSplit3));
        monthDataModelSplit4.weeks?.forEach(
          (element) {
            element.dayList = split4;
            element.idList = [
              "${element.id} split4 Day 1 Workout",
              "${element.id} split4 Day 2 Workout",
              "${element.id} split4 Rest Day 1",
              "${element.id} split4 Day 3 Workout",
              "${element.id} split4 Day 4 Workout",
              "${element.id} split4 Rest Day 2",
              "${element.id} split4 Rest Day 3",
            ];
            element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3"];
            element.days
                ?.removeWhere((element) => !element.formats!.contains("4"));
            for (var i = 0; i < element.days!.length; i++) {
              element.days?[i].dayType = split4[i];
            }
          },
        );
        await preferences.putString(
            "${SplitType.split4}-${monthDataModelSplit4.id}",
            jsonEncode(monthDataModelSplit4));
        monthDataModelSplit5.weeks?.forEach(
          (element) {
            element.dayList = split5;
            element.idList = [
              "${element.id} split5 Day 1 Workout",
              "${element.id} split5 Day 2 Workout",
              "${element.id} split5 Day 3 Workout",
              "${element.id} split5 Day 4 Workout",
              "${element.id} split5 Day 5 Workout",
              "${element.id} split5 Rest Day 1",
              "${element.id} split5 Rest Day 2",
            ];
            element.restDayList = ["Rest Day 1", "Rest Day 2"];
            element.days
                ?.removeWhere((element) => !element.formats!.contains("5"));
            for (var i = 0; i < element.days!.length; i++) {
              element.days?[i].dayType = split5[i];
            }
          },
        );
        await preferences.putString(
            "${SplitType.split5}-${monthDataModelSplit5.id}",
            jsonEncode(monthDataModelSplit5));

        final value = await DatabaseHelper().areAllTablesEmpty();

        if (value) {
          await fetchAndStoreDayData(monthDataModelSplit3);
          fetchAndStoreAllData(monthDataModelSplit3);
        }
      }
      await monthProvider?.fetchMonthLocalData();
      notifyListeners();
    } catch (e) {
      log("issue in month view loading=> $e");
    }
  }

  Future<void> fetchAndStoreDayData(MonthDataModel monthDataModelSplit3) async {
    try {
      final db = DatabaseHelper();

      /// Fetch month enrollment first
      final monthEnrollment = await ApiRepo.fetchMonthEnrollment();
      print('monthEnrollment==========>>>>>${jsonEncode(monthEnrollment)}');
      if (monthEnrollment.isNotEmpty) {
        for (var element in monthEnrollment) {
          final body = {
            "monthId": element.id ?? "",
            "monthStartDate": element.startDate.toString(),
            "monthEndDate": element.endDate.toString(),
          };
          await db.insertData(
              data: body, tableName: DatabaseHelper.monthHistory);
        }
      } else {
        MonthResponseModel? matchingElement =
            monthProvider?.monthLocalDataModel.firstWhere(
          (element) => element.monthId == monthDataModelSplit3.id,
          orElse: () => MonthResponseModel(),
        );

        final fallbackData = {
          "monthId": monthDataModelSplit3.id,
          "monthStartDate": monthDataModelSplit3.startDate.toString(),
          "monthEndDate": monthDataModelSplit3.endDate.toString()
        };

        if (matchingElement?.id == null) {
          await db.insertData(
              data: fallbackData, tableName: DatabaseHelper.monthHistory);
        }
      }

      final streakDataModelFuture = await ApiRepo.fetchStreakCount();
      final apiResults = await Future.wait([
        ApiRepo.fetchDayStatus(monthDataModelSplit3.id ?? ""),
      ]);

      final streakDataModel = await streakDataModelFuture;
      await preferences.putInt(
        SharedPreference.lastStreakCount,
        int.parse(streakDataModel?.count ?? "0"),
      );

      final dayStatus = apiResults[0];

      await Future.wait([
        // Insert Day Status
        ...dayStatus.map((e) {
          final body = {
            "title": e.title ?? "",
            "dataId": e.dataId ?? " ",
            "monthId": e.monthId ?? "",
            "weekId": e.weekId ?? "",
            "dayId": e.dayId ?? "",
            "split": e.split ?? "",
            "date": e.date ?? "",
            "status": e.status ?? "",
            "type": e.type ?? "",
            "startTime": e.startTime ?? "",
            "endTime": e.endTime ?? "",
            "completedExercise": e.completedExerciseCount ?? "",
            "totalWeight": e.totalWeight ?? "",
            "averageRIR": e.averageRIR ?? "",
          };
          return db.insertData(data: body, tableName: DatabaseHelper.dayStatus);
        }),
      ]);

      log('All data fetched and stored successfully at ${DateTime.now()}');
    } catch (e, stacktrace) {
      log('Error in fetchAndStoreAllData: $e\n$stacktrace');
    }
  }

  Future<void> fetchAndStoreAllData(MonthDataModel monthDataModelSplit3) async {
    final db = DatabaseHelper();

    try {
      // Fetch all APIs together
      final apiResults = await Future.wait([
        ApiRepo.fetchExerciseHistory(monthDataModelSplit3.id ?? ""),
        ApiRepo.fetchExerciseStatus(monthDataModelSplit3.id ?? ""),
        ApiRepo.fetchExerciseNotes(),
        ApiRepo.fetchExtraSet(monthDataModelSplit3.id ?? ""),
        ApiRepo.fetchRemovedExercise(monthDataModelSplit3.id ?? ""),
        ApiRepo.fetchExtraExercise(monthDataModelSplit3.id ?? ""),
        ApiRepo.fetchSwapExercise(monthDataModelSplit3.id ?? ""),
      ]);

      final exerciseHistory = apiResults[0] as List<ExerciseHistoryDataModel>;
      final exerciseStatus = apiResults[1] as List<ExerciseStatusDataModel>;
      final exerciseNotes = apiResults[2] as List<ExerciseNotesDataModel>;
      final extraSet = apiResults[3] as List<ExtraSetDataModel>;
      final removedExercise = apiResults[4] as List<RemovedExerciseDataModel>;
      final extraExercise = apiResults[5] as List<ExtraExerciseDataModel>;
      final swapExercise = apiResults[6] as List<SwapExerciseDataModel>;

      Future<void> safeInsert(
          Future<void> Function() action, String tag) async {
        try {
          await action();
        } catch (e, st) {
          log("❌ Insert failed [$tag]: $e\n$st");
        }
      }

      await Future.wait([
        ...exerciseHistory.map((e) => safeInsert(() async {
              final body = {
                "split": e.split ?? "",
                "dataId": e.dataId ?? "",
                "exerciseId": e.exerciseId ?? "",
                "extraId": e.extraId ?? "",
                "monthId": e.monthId ?? "",
                "weekId": e.weekId ?? "",
                "dayId": e.dayId ?? "",
                "sets": e.sets?.toString() ?? "",
                "reps": e.reps?.toString() ?? "",
                "weight": e.weight?.toString() ?? "",
                "rest": e.rest?.toString() ?? "",
                "load": e.load?.toString() ?? "",
                "type": e.type ?? "",
                "effort": e.effort?.toString() ?? "",
                "date": e.date?.toString() ?? "",
                "index": int.tryParse(e.index ?? "0") ?? 0,
                "subIndex": int.tryParse(e.subIndex ?? "0") ?? 0,
                "status": e.status ?? "",
                "totalSet": e.totalSet?.toString() ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.exerciseHistory);
            }, "ExerciseHistory")),
        ...exerciseStatus.map((e) => safeInsert(() async {
              final body = {
                "dataId": e.dataId ?? "",
                "exerciseId": e.exerciseId ?? "",
                "monthId": e.monthId ?? "",
                "weekId": e.weekId ?? "",
                "dayId": e.dayId ?? "",
                "split": e.split ?? "",
                "date": e.date ?? "",
                "status": e.status ?? "",
                "type": e.type ?? "",
                "totalWeight": e.totalWeight ?? "",
                "totalSet": e.totalSet ?? "",
                "totalRIR": e.totalRIR ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.exerciseStatus);
            }, "ExerciseStatus")),
        ...exerciseNotes.map((e) => safeInsert(() async {
              final body = {
                "exerciseId": e.exerciseId ?? "",
                "date": e.date ?? "",
                "note": e.note ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.exerciseNotes);
            }, "ExerciseNotes")),
        ...extraSet.map((e) => safeInsert(() async {
              final body = {
                "sets": int.tryParse(e.sets ?? "0") ?? 0,
                "reps": int.tryParse(e.reps ?? "0") ?? 0,
                "weight": int.tryParse(e.weight ?? "0") ?? 0,
                "rest": int.tryParse(e.rest ?? "0") ?? 0,
                "load": int.tryParse(e.load ?? "0") ?? 0,
                "type": int.tryParse(e.type ?? "0") ?? 0,
                "extraId": e.extraId ?? "",
                "date": e.date ?? "",
                "dataId": e.dataId ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.extraSetHistory);
            }, "ExtraSet")),
        ...removedExercise.map((e) => safeInsert(() async {
              final body = {
                "exerciseId": e.exerciseId ?? "",
                "dataId": e.dataId ?? "",
                "split": e.split ?? "",
                "monthId": e.monthId ?? "",
                "weekId": e.weekId ?? "",
                "dayId": e.dayId ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.removedExerciseHistory);
            }, "RemovedExercise")),
        ...extraExercise.map((e) => safeInsert(() async {
              final body = {
                "dataId": e.dataId ?? "",
                "split": e.split ?? "",
                "monthId": e.monthId ?? "",
                "weekId": e.weekId ?? "",
                "dayId": e.dayId ?? "",
                "date": e.date ?? "",
                "exerciseId": e.exerciseId ?? "",
                "exerciseJson": e.exerciseJson ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.extraExerciseHistory);
            }, "ExtraExercise")),
        ...swapExercise.map((e) => safeInsert(() async {
              final body = {
                "dataId": e.dataId ?? "",
                "split": e.split ?? "",
                "monthId": e.monthId ?? "",
                "weekId": e.weekId ?? "",
                "dayId": e.dayId ?? "",
                "date": e.date ?? "",
                "exerciseId": e.exerciseId ?? "",
                "exerciseJson": e.exerciseJson ?? "",
                "insertIndex": e.insertIndex ?? "",
              };
              await db.insertData(
                  data: body, tableName: DatabaseHelper.swapExerciseHistory);
            }, "SwapExercise")),
      ]);

      log('✅ All data fetched and stored successfully at ${DateTime.now()}');
    } catch (e, stacktrace) {
      log('🔥 Fatal error in fetchAndStoreAllData: $e\n$stacktrace');
    }
  }

  // Future<void> fetchAndStoreAllData(MonthDataModel monthDataModelSplit3) async {
  //   try {
  //     final db = DatabaseHelper();
  //
  //     final apiResults = await Future.wait([
  //       ApiRepo.fetchExerciseHistory(monthDataModelSplit3.id ?? ""),
  //       ApiRepo.fetchExerciseStatus(monthDataModelSplit3.id ?? ""),
  //       ApiRepo.fetchExerciseNotes(),
  //       ApiRepo.fetchExtraSet(monthDataModelSplit3.id ?? ""),
  //       ApiRepo.fetchRemovedExercise(monthDataModelSplit3.id ?? ""),
  //       ApiRepo.fetchExtraExercise(monthDataModelSplit3.id ?? ""),
  //       ApiRepo.fetchSwapExercise(monthDataModelSplit3.id ?? ""),
  //     ]);
  //
  //     final exerciseHistory = apiResults[0] as List<ExerciseHistoryDataModel>;
  //     final exerciseStatus = apiResults[1] as List<ExerciseStatusDataModel>;
  //     final exerciseNotes = apiResults[2] as List<ExerciseNotesDataModel>;
  //     final extraSet = apiResults[3] as List<ExtraSetDataModel>;
  //     final removedExercise = apiResults[4] as List<RemovedExerciseDataModel>;
  //     final extraExercise = apiResults[5] as List<ExtraExerciseDataModel>;
  //     final swapExercise = apiResults[6] as List<SwapExerciseDataModel>;
  //
  //     await Future.wait([
  //       // Insert Exercise History
  //       ...exerciseHistory.map((e) {
  //         final body = {
  //           "split": e.split ?? "",
  //           "dataId": e.dataId ?? "",
  //           "exerciseId": e.exerciseId ?? "",
  //           "extraId": e.extraId ?? "",
  //           "monthId": e.monthId ?? "",
  //           "weekId": e.weekId ?? "",
  //           "dayId": e.dayId ?? "",
  //           "sets": e.sets?.toString() ?? "",
  //           "reps": e.reps?.toString() ?? "",
  //           "weight": e.weight?.toString() ?? "",
  //           "rest": e.rest?.toString() ?? "",
  //           "load": e.load?.toString() ?? "",
  //           "type": e.type ?? "",
  //           "effort": e.effort?.toString() ?? "",
  //           "date": e.date?.toString() ?? "",
  //           "index": int.tryParse(e.index ?? "0") ?? 0,
  //           "subIndex": int.tryParse(e.subIndex ?? "0") ?? 0,
  //           "status": e.status ?? "",
  //           "totalSet": e.totalSet?.toString() ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.exerciseHistory);
  //       }),
  //
  //       // Insert Exercise Status
  //       ...exerciseStatus.map((e) {
  //         final body = {
  //           "dataId": e.dataId ?? "",
  //           "exerciseId": e.exerciseId ?? "",
  //           "monthId": e.monthId ?? "",
  //           "weekId": e.weekId ?? "",
  //           "dayId": e.dayId ?? "",
  //           "split": e.split ?? "",
  //           "date": e.date ?? "",
  //           "status": e.status ?? "",
  //           "type": e.type ?? "",
  //           "totalWeight": e.totalWeight ?? "",
  //           "totalSet": e.totalSet ?? "",
  //           "totalRIR": e.totalRIR ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.exerciseStatus);
  //       }),
  //
  //       // Insert Exercise Notes
  //       ...exerciseNotes.map((e) {
  //         final body = {
  //           "exerciseId": e.exerciseId ?? "",
  //           "date": e.date ?? "",
  //           "note": e.note ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.exerciseNotes);
  //       }),
  //
  //       // Insert Extra Set
  //       ...extraSet.map((e) {
  //         final body = {
  //           "sets": int.tryParse(e.sets ?? "0") ?? 0,
  //           "reps": int.tryParse(e.reps ?? "0") ?? 0,
  //           "weight": int.tryParse(e.weight ?? "0") ?? 0,
  //           "rest": int.tryParse(e.rest ?? "0") ?? 0,
  //           "load": int.tryParse(e.load ?? "0") ?? 0,
  //           "type": int.tryParse(e.type ?? "0") ?? 0,
  //           "extraId": e.extraId ?? "",
  //           "date": e.date ?? "",
  //           "dataId": e.dataId ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.extraSetHistory);
  //       }),
  //
  //       // Insert Removed Exercise
  //       ...removedExercise.map((e) {
  //         final body = {
  //           "exerciseId": e.exerciseId ?? "",
  //           "dataId": e.dataId ?? "",
  //           "split": e.split ?? "",
  //           "monthId": e.monthId ?? "",
  //           "weekId": e.weekId ?? "",
  //           "dayId": e.dayId ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.removedExerciseHistory);
  //       }),
  //
  //       // Insert Extra Exercise
  //       ...extraExercise.map((e) {
  //         final body = {
  //           "dataId": e.dataId ?? "",
  //           "split": e.split ?? "",
  //           "monthId": e.monthId ?? "",
  //           "weekId": e.weekId ?? "",
  //           "dayId": e.dayId ?? "",
  //           "date": e.date ?? "",
  //           "exerciseId": e.exerciseId ?? "",
  //           "exerciseJson": e.exerciseJson ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.extraExerciseHistory);
  //       }),
  //
  //       // Insert Swap Exercise
  //       ...swapExercise.map((e) {
  //         final body = {
  //           "dataId": e.dataId ?? "",
  //           "split": e.split ?? "",
  //           "monthId": e.monthId ?? "",
  //           "weekId": e.weekId ?? "",
  //           "dayId": e.dayId ?? "",
  //           "date": e.date ?? "",
  //           "exerciseId": e.exerciseId ?? "",
  //           "exerciseJson": e.exerciseJson ?? "",
  //           "insertIndex": e.insertIndex ?? "",
  //         };
  //         return db.insertData(
  //             data: body, tableName: DatabaseHelper.swapExerciseHistory);
  //       }),
  //     ]);
  //
  //     log('All data fetched and stored successfully at ${DateTime.now()}');
  //   } catch (e, stacktrace) {
  //     log('Error in fetchAndStoreAllData: $e\n$stacktrace');
  //   }
  // }

  Future<void> fetchCheckoutPoint() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/settings/');
    String? userIdToken = await getAuthToken();
    Dio dio = Dio();

    try {
      final response = await dio.get(
        url.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'AUTH_TOKEN': userIdToken,
          },
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        var responseData = data[0];

        if (equipmentCheckpoint == '' ||
            bonusCheckpoint == '' ||
            workoutCheckpoint == '') {
          equipmentCheckpoint = responseData["equipmentCheckpoint"];
          bonusCheckpoint = responseData["bonusCheckpoint"];
          workoutCheckpoint = responseData["workoutCheckpoint"];
        } else {
          DateTime currentEquipmentCheckpoint =
              DateTime.parse(equipmentCheckpoint);
          DateTime currentBonusCheckoutPoint = DateTime.parse(bonusCheckpoint);
          DateTime currentWorkoutCheckPoint = DateTime.parse(workoutCheckpoint);
          DateTime newEquipmentCheckpoint =
              DateTime.parse(responseData["equipmentCheckpoint"]);
          DateTime newBonusCheckpoint =
              DateTime.parse(responseData["bonusCheckpoint"]);
          DateTime newWorkoutCheckpoint =
              DateTime.parse(responseData["workoutCheckpoint"]);

          if (currentEquipmentCheckpoint.isBefore(newEquipmentCheckpoint)) {
            equipmentCheckpointState = true;
            equipmentCheckpoint = responseData["equipmentCheckpoint"];
          }
          if (currentBonusCheckoutPoint.isBefore(newBonusCheckpoint)) {
            bonusCheckpointState = true;
            bonusCheckpoint = responseData["bonusCheckpoint"];
          }
          if (currentWorkoutCheckPoint.isBefore(newWorkoutCheckpoint)) {
            workoutCheckpointState = true;
            workoutCheckpoint = responseData["workoutCheckpoint"];
          }
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future<void> fetchTutorialData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/tutorials/');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data != null) {
          tutorialData = Tutorials.fromJson(data);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future fetchCurrentEx(String id, String called) async {
    try {
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get/$id');

      url = Uri.http(url.authority, url.path);
      String? userIdToken = await getAuthToken();

      final response = await http.get(
        url,
        headers: <String, String>{
          'AUTH_TOKEN': userIdToken,
        },
      );

      if (response.statusCode == 200) {
        getExerciseFromJson(jsonDecode(response.body));
        notifyListeners();
      } else {
        throw Exception('Failed to load exercise info');
      }
    } catch (e) {
      log("fetchCurrentEx ERROR $e ");
    }
  }

  void getExerciseFromJson(responseData) {
    currentExerciseObj = Exercise(
        videoThumbnail: "",
        id: "",
        title: "",
        vimeoId: "",
        thumbnail: "",
        description: "",
        guide: "",
        relatedExercises: [],
        categories: [],
        usedEquipments: [],
        files: []);
    notifyListeners();
    if (responseData != null) {
      currentRelatedExercises.clear();
      List<Equipment> equipments = [];

      if (responseData["relatedExercises"] != null &&
          responseData["relatedExercises"].length > 0) {
        for (var singleItem in responseData["relatedExercises"]) {
          Exercise newExercise = Exercise(
              id: singleItem["id"] ?? "",
              title: singleItem["title"] ?? "",
              vimeoId: singleItem["vimeoId"] ?? "",
              thumbnail: singleItem["thumbnail"] ?? "",
              videoThumbnail: singleItem["videoThumbnail"] ?? "",
              description: singleItem["description"] ?? "",
              guide: singleItem["guide"] ?? "",
              relatedExercises: singleItem["relatedExercises"] ?? [],
              categories: singleItem["categories"] ?? [],
              usedEquipments: singleItem["usedEquipments"] ?? [],
              files: singleItem['files'] ?? []);

          currentRelatedExercises.add(newExercise);
        }
      }

      if (responseData["usedEquipments"] != null &&
          responseData["usedEquipments"].length > 0) {
        for (var singleItem in responseData["usedEquipments"]) {
          Equipment newEquipment = Equipment(
            id: singleItem["id"] ?? "",
            title: singleItem["title"] ?? "",
            thumbnail: singleItem["thumbnail"] ?? "",
            description: singleItem["description"] ?? "",
            link: singleItem["link"] ?? "",
            createdAt: singleItem["createdAt"] ?? "",
          );
          equipments.add(newEquipment);
        }
      }

      Exercise exerciseObj = Exercise(
          id: responseData["id"] ?? "",
          title: responseData["title"] ?? "",
          vimeoId: responseData["vimeoId"] ?? "",
          thumbnail: responseData["thumbnail"] ?? "",
          videoThumbnail: responseData["videoThumbnail"] ?? "",
          description: responseData["description"] ?? "",
          guide: responseData["guide"] ?? "",
          relatedExercises: currentRelatedExercises,
          categories: responseData["categories"] ?? [],
          usedEquipments: equipments,
          files: responseData['files'] ?? []);

      currentExerciseObj = exerciseObj;
    }

    notifyListeners();
  }

  bool storyLoader = false;
  Future<bool> addOwnSpotlight(
      String title, String description, File? imageFile,
      {bool isFromReport = false,
      String? osVersion,
      String? appVersion}) async {
    storyLoader = true;
    notifyListeners();
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/staffs/addOwnSpotsligt');

    String? userIdToken = await getAuthToken();

    try {
      http.MultipartRequest request = http.MultipartRequest("POST", url);
      request.fields['title'] = title;
      request.fields['description'] = description;

      if (isFromReport) {
        // request.fields['app_version'] = osVersion ?? "";
        // request.fields['device_version'] = appVersion ?? "";
        final version =
            "OS VERSION: ${"${osVersion ?? ""}, APP VERSION: ${(appVersion ?? "")}"}";

        log('version==========>>>>>$version');

        request.fields['description'] = "$description\n [$version]";
      } else {
        request.fields['description'] = description;
      }

      if (imageFile != null) {
        final stream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: basename(imageFile.path),
        );
        request.files.add(multipartFile);
      }
      request.headers
          .addAll({'AUTH_TOKEN': userIdToken, 'Accept': 'application/json'});
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = jsonDecode(responseBody);
        debugPrint('Spotlight added successfully: $decoded');
        return true;
      } else {
        debugPrint('Failed to add spotlight. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding spotlight: $e');
      return false;
    } finally {
      storyLoader = false;
      notifyListeners();
    }
  }
}
