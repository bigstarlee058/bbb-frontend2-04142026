import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/ProfileAndSettings/height_picker.dart';
import 'package:bbb/pages/ProfileAndSettings/number_entry.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileBoardingScreen extends StatefulWidget {
  const ProfileBoardingScreen(
      {super.key,
      required this.welcomeDescription,
      required this.welcomeImageUrl});
  final String welcomeDescription;
  final String welcomeImageUrl;
  @override
  State<ProfileBoardingScreen> createState() => _ProfileBoardingScreenState();
}

class _ProfileBoardingScreenState extends State<ProfileBoardingScreen> {
  late UserDataProvider userData;

  int currentPage = 1;
  TextEditingController nameController = TextEditingController();
  PageController pageController = PageController();
  File? image;
  DateTime? selectedDate;
  String? selectedGender;
  TextEditingController selectedWeight = TextEditingController();
  TextEditingController selectedBodyFat = TextEditingController();
  TextEditingController selectedHeight = TextEditingController();
  TextEditingController selectedMidThigh = TextEditingController();
  TextEditingController selectedWaist = TextEditingController();
  TextEditingController selectedHip = TextEditingController();
  final List<String> heightOptions = [
    '5\'0"',
    '5\'5"',
    '6\'0"',
    '6\'5"'
  ]; // Example heights
  final List<String> weightOptions = [
    '100 lbs',
    '110 lbs',
    '121 lbs',
    '130 lbs',
    '140 lbs'
  ];
  final List<String> genderOptions = ['Female', 'Male', 'Other'];
  double heightInCm = 183;
  HeightUnit selectedHeightUnit = HeightUnit.cm;
  bool canConvertUnit = true;
  bool showSeparationText = true;

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        image = File(file.path);
        setState(() {});
        String fileName = path.basename(file.path);
        log("FILE NAME $fileName");
      }
    } catch (e) {
      log("ERROR IN PICK IMAGE $e");
    }
  }

  int goalIndex = 0;

  updateSplitIndex(int index) {
    goalIndex = index;
    setState(() {});
  }

  bool isLoading = false;
  Future<void> _saveUserData({bool loader = false}) async {
    setState(() {
      isLoading = loader;
    });

    final userDetails = {
      'lastName': '',
      'firstName': nameController.text.trim().toString().isEmpty
          ? userData.user["name"] ?? ""
          : nameController.text.toString(),
      'sex': selectedGender != null
          ? genderOptions.indexOf(selectedGender!)
          : false,
      'dob': selectedDate != null ? selectedDate!.toIso8601String() : "",
      'weight': selectedWeight.text.replaceAll('lbs', "").isNotEmpty
          ? int.parse(selectedWeight.text.replaceAll('lbs', ""))
          : "",
      'height': selectedHeight.text
              .replaceAll('\'', '')
              .replaceAll("\"", "")
              .isNotEmpty
          ? int.parse(
              selectedHeight.text.replaceAll('\'', '').replaceAll("\"", ""))
          : "",
      'waist': selectedWaist.text
              .replaceAll('\'', '')
              .replaceAll("\"", "")
              .isNotEmpty
          ? int.parse(
              selectedWaist.text.replaceAll('\'', '').replaceAll("\"", ""))
          : "",
      'hip':
          selectedHip.text.replaceAll('\'', '').replaceAll("\"", "").isNotEmpty
              ? int.parse(selectedHip.text.replaceAll("\"", ""))
              : "",
      'midthigh': selectedMidThigh.text
              .replaceAll('\'', '')
              .replaceAll("\"", "")
              .isNotEmpty
          ? int.parse(
              selectedMidThigh.text.replaceAll('\'', '').replaceAll("\"", ""))
          : "",
      'bodyfat': selectedBodyFat.text.replaceAll('%', "").isNotEmpty
          ? int.parse(selectedBodyFat.text.replaceAll('%', ""))
          : "",
    };
    if (kDebugMode) {
      print('HERE IS USER DETAIL##, $userDetails');
    }

    await userData.addUserInfo(userData.userId, userDetails, image);
    // Fluttertoast.showToast(
    //   msg: "Profile saved!",
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.TOP_RIGHT,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: AppColors.primaryColor,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
    setState(() {
      isLoading = false;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    userData = Provider.of<UserDataProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => onInit(),
    );
    super.initState();
  }

  onInit() {
    if (userData.user != null) {
      nameController.text = userData.user["name"] ?? "";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "",
          style: TextStyle(
            color: Colors.black,
            fontSize: ScreenUtil.horizontalScale(5.5),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
              if (context.mounted) {
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      showWelcomeModal: !hasSeenWelcome,
                      welcomeDescription: widget.welcomeDescription,
                      welcomeImageUrl: widget.welcomeImageUrl,
                      isComeFromOnBoarding: true,
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: ScreenUtil.horizontalScale(2.5)),
              decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(100))),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                child: Icon(
                    size: ScreenUtil.verticalScale(2.5),
                    Icons.close,
                    color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 8)
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: ScreenUtil.verticalScale(3.2),
          right: ScreenUtil.horizontalScale(7),
          left: ScreenUtil.horizontalScale(7),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: ScreenUtil.horizontalScale(2),
                left: ScreenUtil.horizontalScale(2),
                bottom: ScreenUtil.verticalScale(1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: currentPage > (index)
                            ? AppColors.primaryColor
                            : Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil.verticalScale(1)),
            ButtonWidget(
              text: currentPage == 4 ? "Save & Proceed" : "Next",
              textColor: Colors.white,
              color: AppColors.primaryColor,
              onPress: () async {
                await preferences.setBool(SharedPreference.isFirstTime, false);

                if (currentPage == 1) {
                  if (nameController.text.isEmpty) {
                    showBottomAlert(
                        context, 'Please enter your name to get started!');
                    return;
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                    );
                    setState(() {});

                    await _saveUserData();
                  }
                } else if (currentPage == 2) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                  );
                  setState(() {});
                  await _saveUserData();
                } else if (currentPage == 3) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                  );
                  setState(() {});

                  await _saveUserData();
                } else if (currentPage == 4) {
                  await _saveUserData(loader: true).then(
                    (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool hasSeenWelcome =
                          prefs.getBool('hasSeenWelcome') ?? false;
                      if (context.mounted) {
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(
                              showWelcomeModal: !hasSeenWelcome,
                              welcomeDescription: widget.welcomeDescription,
                              welcomeImageUrl: widget.welcomeImageUrl,
                              isComeFromOnBoarding: true,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
              isLoading: isLoading,
            ),
            SizedBox(height: ScreenUtil.verticalScale(1)),
            currentPage == 1
                ? SizedBox()
                : TextButton(
                    onPressed: () async {
                      await preferences.setBool(
                          SharedPreference.isFirstTime, false);

                      if (currentPage == 2) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                        );
                        setState(() {});
                      } else if (currentPage == 3) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                        );
                        setState(() {});
                      } else if (currentPage == 4) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        bool hasSeenWelcome =
                            prefs.getBool('hasSeenWelcome') ?? false;
                        if (context.mounted) {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainPage(
                                showWelcomeModal: !hasSeenWelcome,
                                welcomeDescription: widget.welcomeDescription,
                                welcomeImageUrl: widget.welcomeImageUrl,
                                isComeFromOnBoarding: true,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(65, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.center),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(5)),
              child: Image.asset(
                "assets/img/logo.png",
                scale: 1.2,
              ),
            ),
            SizedBox(
              // color: Colors.red,
              height: media.height * 0.55,
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (value) {
                  currentPage = value + 1;
                  setState(() {});
                },
                controller: pageController,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(6))
                        .copyWith(bottom: ScreenUtil.verticalScale(6.5)),
                    child: index == 0
                        ? page1()
                        : index == 1
                            ? page2(context)
                            : index == 2
                                ? page3(context)
                                : page4(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget page1() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(3)),
          Text(
            "Welcome to the Booty By Bret app. Before we get started, we’re going to ask you a few questions to get to know you and customize your experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(2),
              height: 1.5,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(3)),
          Text(
            "Let's start with your name.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(2),
              height: 1.5,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AppTextFormField(
              hintText: 'First Name',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (nameController.text.toString().trim().isEmpty) {
                  nameController.clear();
                  setState(() {});
                }
              },
              controller: nameController,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(
                      const Size(48, 48),
                    ),
                  ),
                  icon: const Icon(
                    Icons.person,
                    color: Color(0XFFd9d9d9),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget page2(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tell us about you",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(2.5)),
          Text(
            "Some basic info to get us started.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(2),
              height: 1.5,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(3.5)),
          _buildDropdownField(
            context: context,
            label: 'Gender',
            value: selectedGender,
            options: genderOptions,
            hint: 'Male',
            onChanged: (String? newValue) {
              setState(() {
                selectedGender = newValue!;
              });
            },
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          _buildProfileField(
            context: context,
            label: 'Birthday',
            value: selectedDate != null
                ? DateFormat('MM/dd/yyyy').format(selectedDate!)
                : 'Select Birthday',
            onTap: () async {
              _showDatePicker(context);
            },
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          _heightPicker(
            context: context,
            label: 'Height',
            value: selectedHeight,
            hint: '6\'0"',
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          NumberEntry(
            zeroPadding: true,
            label: 'Weight',
            controller: selectedWeight,
            focusNode: _nodeText1,
            suffix: "lbs",
          ),
        ],
      );

  Widget page3(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Extra measurements",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(2.5)),
          Text(
            "For the real data freaks out there.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(2),
              height: 1.5,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(3.5)),
          NumberEntry(
            zeroPadding: true,
            label: 'Waist',
            controller: selectedWaist,
            focusNode: _nodeText2,
            suffix: '"',
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          NumberEntry(
            zeroPadding: true,
            label: 'Hip',
            controller: selectedHip,
            focusNode: _nodeText3,
            suffix: '"',
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          NumberEntry(
            zeroPadding: true,
            label: 'Mid-Thigh',
            controller: selectedMidThigh,
            focusNode: _nodeText4,
            suffix: '"',
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          NumberEntry(
            zeroPadding: true,
            label: 'Body-Fat',
            controller: selectedBodyFat,
            focusNode: _nodeText5,
            suffix: "%", // hint: '81',
          ),
        ],
      );
  Widget page4() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Your profile photo",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(3)),
          Text(
            "Click to upload a favorite photo of yourself.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(2),
              height: 1.5,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(4)),
          Center(
            child: Container(
              height: ScreenUtil.horizontalScale(32),
              width: ScreenUtil.horizontalScale(32),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .9),
                borderRadius: BorderRadius.all(
                  Radius.circular(ScreenUtil.horizontalScale(32)),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: ScreenUtil.horizontalScale(32),
                    width: ScreenUtil.horizontalScale(32),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.horizontalScale(32)),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil.horizontalScale(32)),
                      child: image != null
                          ? Image.file(
                              image!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                "B",
                                style: TextStyle(
                                  fontSize: ScreenUtil.horizontalScale(12),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: -(ScreenUtil.horizontalScale(3.35)),
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        _pickAndUploadImage();
                        // Handle camera icon action here
                      },
                      child: CircleAvatar(
                        radius: ScreenUtil.horizontalScale(
                            4), // Adjust size as needed
                        backgroundColor: Colors.black.withValues(alpha: .7),
                        child: Center(
                          child: Icon(
                            Icons.edit,
                            size: ScreenUtil.horizontalScale(
                                4), // Adjust size as needed
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> options,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0.6)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(32),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.95),
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: ScreenUtil.horizontalScale(50),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(1),
            ).copyWith(left: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: Utils.buttonRadius,
            ),
            child: Center(
              // Center the dropdown content
              child: DropdownButton<String>(
                value: value,
                dropdownColor: Theme.of(context).cardColor,
                elevation: 12,
                hint: Text(hint),
                isDense: true,
                isExpanded: true,
                alignment: Alignment.center,
                // Align the dropdown text to the center
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      // Center the individual items in dropdown

                      child: Text(
                        value,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: ScreenUtil.verticalScale(1.95),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: ScreenUtil.verticalScale(1.95),
                  fontWeight: FontWeight.normal,
                ),
                onChanged: onChanged,
                underline: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0.6)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(32),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.95),
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil.horizontalScale(50),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.horizontalScale(1),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: Utils.buttonRadius,
                ),
                child: Center(
                  // Center the text
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'Select Birthday'
                          ? Colors.grey.shade700
                          : Theme.of(context).textTheme.bodyLarge!.color!,
                      fontSize: ScreenUtil.verticalScale(1.95),
                      // fontWeight: (value == 'Select Birthday') ? FontWeight.normal : FontWeight.bold,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center, // Align the text at the center
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heightPicker(
      {required BuildContext context,
      required String label,
      required TextEditingController value,
      required String hint}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0.6)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(32),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.95),
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: ScreenUtil.horizontalScale(50),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(1),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: Utils.buttonRadius,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await showCupertinoHeightPicker(
                    context: context,
                    initialHeight: heightInCm,
                    initialSelectedHeightUnit: selectedHeightUnit,
                    canConvertUnit: canConvertUnit,
                    showSeparationText: showSeparationText,
                    onHeightChanged: (val) {
                      setState(() {
                        heightInCm = val;
                        int feet = (heightInCm / 2.54) ~/ 12;
                        int inches = ((heightInCm / 2.54) % 12).floor();
                        value.text = '$feet\'$inches"';
                      });
                    },
                  );
                },
                child: Text(
                  value.text.isEmpty ? 'Height' : value.text,
                  style: TextStyle(
                    color: value.text.isEmpty
                        ? Colors.grey.shade700
                        : Theme.of(context).textTheme.bodyLarge!.color!,
                    fontSize: ScreenUtil.verticalScale(1.95),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    return BottomPicker.date(
      pickerTextStyle: TextStyle(
        fontSize: ScreenUtil.verticalScale(1.8),
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodyLarge!.color!,
      ),
      dateOrder: DatePickerDateOrder.mdy,
      initialDateTime: DateTime(2000, 1, 1),
      maxDateTime: DateTime.now(),
      minDateTime: DateTime(1950, 1, 1),
      onSubmit: (dob) {
        selectedDate = dob;
        setState(() {});
      },
      backgroundColor: Theme.of(context).cardColor,
      height: 320,
      displayCloseIcon: true,
      closeIconColor: Theme.of(context).textTheme.bodyLarge!.color!,
      buttonWidth: ScreenUtil.horizontalScale(80),
      buttonContent: Center(
        child: Text(
          "Select",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: ScreenUtil.verticalScale(1.8),
          ),
        ),
      ),
      buttonPadding: ScreenUtil.verticalScale(1.3),
      buttonStyle: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(
          ScreenUtil.verticalScale(1.5),
        ),
      ),
      pickerTitle: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          "Select Date of Birth",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
            fontWeight: FontWeight.w600,
            fontSize: ScreenUtil.verticalScale(2),
          ),
        ),
      ),
    ).show(context);
  }
}

void showBottomAlert(BuildContext context, String msg) {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 20.0,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry); //In here I changed the code ?.

  // Remove the alert after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
