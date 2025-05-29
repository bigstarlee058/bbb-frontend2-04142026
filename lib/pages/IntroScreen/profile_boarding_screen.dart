import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/pages/ProfileAndSettings/height_picker.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileBoardingScreen extends StatefulWidget {
  const ProfileBoardingScreen({super.key, required this.welcomeDescription, required this.welcomeImageUrl});
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
  final List<String> heightOptions = ['5\'0"', '5\'5"', '6\'0"', '6\'5"']; // Example heights
  final List<String> weightOptions = ['100 lbs', '110 lbs', '121 lbs', '130 lbs', '140 lbs'];
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
  Future<void> _saveUserData() async {
    setState(() {
      isLoading = true;
    });

    final userDetails = {
      'lastName': '',
      'firstName': nameController.text.toString(),
      'sex': genderOptions.indexOf(selectedGender!),
      'dob': selectedDate?.toIso8601String(),
      'weight': selectedWeight.text.isEmpty ? "" : int.parse(selectedWeight.text.split(' ')[0]),
      'height': selectedHeight.text.isEmpty ? "" : int.parse(selectedHeight.text.replaceAll('\'', '').replaceAll("\"", "")),
      'waist': selectedWaist.text.isEmpty ? "0" : int.parse(selectedWaist.text.replaceAll('\'', '').replaceAll("\"", "") ?? "0"),
      'hip': selectedHip.text.isEmpty ? "0" : int.parse(selectedHip.text.replaceAll('\'', '').replaceAll("\"", "") ?? "0"),
      'midthigh': selectedMidThigh.text.isEmpty ? "0" : int.parse(selectedMidThigh.text.replaceAll('\'', '').replaceAll("\"", "") ?? "0"),
      'bodyfat': selectedBodyFat.text.isEmpty ? "0" : int.parse(selectedBodyFat.text.split(' ')[0]),
    };
    if (kDebugMode) {
      print('HERE IS USERDETAIL##, $userDetails');
    }

    await userData.addUserInfo(userData.userId, userDetails, image);
    Fluttertoast.showToast(
      msg: "Profile saved!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP_RIGHT,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.primaryColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: media.height,
                          width: media.width,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/back.jpg'),
                              fit: BoxFit.cover,
                              opacity: 1,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 4,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10, bottom: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: ScreenUtil.verticalScale(1),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Welcome',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 7.99,
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
                Container(
                  margin: EdgeInsets.only(
                    top: media.height / 8,
                  ),
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Container(
                      constraints: BoxConstraints(minHeight: media.height - media.height / 8),
                      width: media.width,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(55),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(5),
                              vertical: ScreenUtil.verticalScale(2),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(4)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: media.height * 0.8,
                                  child: PageView.builder(
                                    onPageChanged: (value) {
                                      currentPage = value + 1;
                                      setState(() {});
                                    },
                                    controller: pageController,
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return index == 0
                                          ? page1()
                                          : index == 1
                                              ? page2(context)
                                              : page3();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: ScreenUtil.verticalScale(3.2),
                            right: ScreenUtil.horizontalScale(7),
                            left: ScreenUtil.horizontalScale(7),
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
                                      3,
                                      (index) => Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(right: index == 2 ? 0 : 5),
                                          height: 5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: currentPage > (index) ? AppColors.primaryColor : Colors.grey.withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(1)),
                                ButtonWidget(
                                  text: currentPage == 3 ? "Save" : "Next",
                                  textColor: Colors.white,
                                  color: AppColors.primaryColor,
                                  onPress: () async {
                                    /// 1

                                    if (currentPage == 1) {
                                      if (nameController.text.isEmpty) {
                                        showBottomAlert(context, 'Please enter name');
                                        return;
                                      } else {
                                        pageController.nextPage(
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.fastOutSlowIn,
                                        );
                                        setState(() {});
                                      }
                                    }

                                    /// 2

                                    if (currentPage == 2) {
                                      if (selectedGender == null ||
                                          selectedDate == null ||
                                          selectedHeight.text.isEmpty ||
                                          selectedWeight.text.isEmpty) {
                                        showBottomAlert(context, 'Please enter details');
                                        return;
                                      } else {
                                        pageController.nextPage(
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.fastOutSlowIn,
                                        );
                                        setState(() {});
                                      }
                                    }

                                    /// 3

                                    if (currentPage == 3) {
                                      if (image == null) {
                                        showBottomAlert(context, 'Please upload profile image');
                                        return;
                                      } else {
                                        if (nameController.text.isEmpty) {
                                          showBottomAlert(context, 'Please enter name');
                                          return;
                                        }
                                        if (selectedGender == null ||
                                            selectedDate == null ||
                                            selectedHeight.text.isEmpty ||
                                            selectedWeight.text.isEmpty) {
                                          showBottomAlert(context, 'Please enter details');
                                          return;
                                        }

                                        /// UPDATE DATA
                                        ///
                                        await _saveUserData().then(
                                          (value) async {
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
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
                                          },
                                        );
                                      }
                                    }
                                  },
                                  isLoading: isLoading,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget page1() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: ScreenUtil.verticalScale(1)),
          Text(
            "Name",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(4)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Enter your name",
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.8),
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AppTextFormField(
              hintText: 'First Name',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (value) {},
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
        children: [
          SizedBox(height: ScreenUtil.verticalScale(1)),
          Text(
            "Details",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(3)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Add your details",
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.8),
                height: 1,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(0.6)),
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
          _buildProfileField(
            context: context,
            label: 'Birthday',
            value: selectedDate != null ? DateFormat('MM/dd/yyyy').format(selectedDate!) : 'Select Birthday',
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(1998, 9, 21),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primaryColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null && pickedDate != selectedDate) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
          ),
          _heightPicker(
            context: context,
            label: 'Height',
            value: selectedHeight,
            hint: '6\'0"',
          ),
          _numberPicker(
            context: context,
            label: 'Weight',
            controller: selectedWeight,
            focusNode: _nodeText1,
            suffix: "lbs",
          ),
          _numberPicker(
            context: context,
            label: 'Waist',
            controller: selectedWaist,
            focusNode: _nodeText2,
            suffix: '"',
          ),
          _numberPicker(
            context: context,
            label: 'Hip',
            controller: selectedHip,
            focusNode: _nodeText3,
            suffix: '"',
          ),
          _numberPicker(
            context: context,
            label: 'Mid-Thigh',
            controller: selectedMidThigh,
            focusNode: _nodeText4,
            suffix: '"',
          ),
          _numberPicker(
            context: context,
            label: 'Body-Fat',
            controller: selectedBodyFat,
            focusNode: _nodeText5,
            suffix: "%", // hint: '81',
          ),
        ],
      );

  Widget page3() => Column(
        children: [
          SizedBox(height: ScreenUtil.verticalScale(1)),
          Text(
            "Profile",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(3),
              height: 1,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(4)),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Add your profile image",
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.8),
                height: 1,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
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
                      borderRadius: BorderRadius.circular(ScreenUtil.horizontalScale(32)),
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
                        radius: ScreenUtil.horizontalScale(4), // Adjust size as needed
                        backgroundColor: Colors.black.withValues(alpha: .7),
                        child: Center(
                          child: Icon(
                            Icons.edit,
                            size: ScreenUtil.horizontalScale(4), // Adjust size as needed
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
          /*SizedBox(height: ScreenUtil.verticalScale(5)),
          Text(
            "What’s Your Goal?",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(2.8),
              height: 1,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(4)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Select your goal",
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.8),
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil.verticalScale(1.2)),
          Container(
            margin: EdgeInsets.all(ScreenUtil.verticalScale(0.6)),
            padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyColor,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  radius: ScreenUtil.verticalScale(2),
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.verticalScale(2.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Muscle Growth",
                  style: TextStyle(
                    color: const Color(0xBB888888),
                    fontSize: ScreenUtil.verticalScale(1.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => updateSplitIndex(0),
                  child: Container(
                    height: ScreenUtil.verticalScale(4),
                    width: ScreenUtil.verticalScale(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goalIndex == 0 ? AppColors.primaryColor : Colors.transparent,
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.done,
                        size: ScreenUtil.verticalScale(2.5),
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: EdgeInsets.all(ScreenUtil.verticalScale(0.6)),
            padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyColor,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  radius: ScreenUtil.verticalScale(2),
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.verticalScale(2.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Weight Gain",
                  style: TextStyle(
                    color: const Color(0xBB888888),
                    fontSize: ScreenUtil.verticalScale(1.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => updateSplitIndex(1),
                  child: Container(
                    height: ScreenUtil.verticalScale(4),
                    width: ScreenUtil.verticalScale(4),
                    decoration: BoxDecoration(
                      color: goalIndex == 1 ? AppColors.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.done,
                        size: ScreenUtil.verticalScale(2.5),
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: EdgeInsets.all(ScreenUtil.verticalScale(0.6)),
            padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyColor,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  radius: ScreenUtil.verticalScale(2),
                  child: Text(
                    "3",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.verticalScale(2.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Strength & Performance",
                  style: TextStyle(
                    color: const Color(0xBB888888),
                    fontSize: ScreenUtil.verticalScale(1.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => updateSplitIndex(2),
                  child: Container(
                    height: ScreenUtil.verticalScale(4),
                    width: ScreenUtil.verticalScale(4),
                    decoration: BoxDecoration(
                      color: goalIndex == 2 ? AppColors.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.done,
                        size: ScreenUtil.verticalScale(2.5),
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),*/
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
              color: Colors.grey.withValues(alpha: 0.052),
              borderRadius: Utils.buttonRadius,
            ),
            child: Center(
              // Center the dropdown content
              child: DropdownButton<String>(
                value: value,
                dropdownColor: const Color.fromARGB(255, 252, 252, 252),
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
                          fontSize: ScreenUtil.verticalScale(1.95),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                style: TextStyle(
                  color: Colors.black,
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
                  color: Colors.grey.withValues(alpha: 0.052),
                  borderRadius: Utils.buttonRadius,
                ),
                child: Center(
                  // Center the text
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'Select Birthday' ? Colors.grey.shade700 : Colors.black,
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

  Widget _numberPicker({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String suffix,
    required FocusNode focusNode,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: ScreenUtil.verticalScale(0.6),
      ),
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
            height: ScreenUtil.verticalScale(6),
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(1)),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.052),
              borderRadius: Utils.buttonRadius,
            ),
            child: KeyboardActions(
              autoScroll: false,
              config: _buildConfig(context, focusNode),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(1.95),
                        color: Colors.black,
                      ),
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      textAlign: TextAlign.center,
                      focusNode: focusNode,
                      maxLength: 3,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "0",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: ScreenUtil.verticalScale(1.95),
                        ),
                        suffix: !focusNode.hasFocus && controller.text.isEmpty
                            ? SizedBox()
                            : Text(
                                suffix,
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(1.95),
                                  color: Colors.black,
                                ),
                              ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String newText = newValue.text;
                          if (newText.isNotEmpty) {
                            newText = newText.replaceFirst(RegExp(r'^0+'), '');
                          }
                          return TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(offset: newText.length),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context, FocusNode nodeText) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.white,
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: nodeText,
          displayArrows: false,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.primaryColor),
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  Widget _heightPicker({required BuildContext context, required String label, required TextEditingController value, required String hint}) {
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
              color: Colors.grey.withValues(alpha: 0.052),
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
                    color: value.text.isEmpty ? Colors.grey.shade700 : Colors.black,
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
