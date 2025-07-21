import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/profile_image_handler.dart';
import 'package:bbb/pages/ProfileAndSettings/height_picker.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/location_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'number_entry.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String? _imageUrl;
  String? selectedName = "";
  DateTime? selectedDate;
  TextEditingController selectedWeight = TextEditingController();
  TextEditingController selectedBodyFat = TextEditingController();
  String? selectedGender;
  TextEditingController selectedHeight = TextEditingController();
  TextEditingController selectedMidThigh = TextEditingController();
  TextEditingController selectedWaist = TextEditingController();
  TextEditingController selectedHip = TextEditingController();
  String? selectedLocation;
  String? selectedGoal;
  String? _id;
  DataProvider? dataProvider;

  UserDataProvider? userData;
  double heightInCm = 183;
  HeightUnit selectedHeightUnit = HeightUnit.cm;

  bool canConvertUnit = true;
  bool showSeparationText = true;

  final List<String> genderOptions = ['Female', 'Male', 'Other'];
  final List<String> goalsOptions = [
    'Muscle Growth',
    'Weight Gain',
    'Strength & Performance'
  ];
  late LocationProvider locationProvider; // Example locations
  late MainPageProvider mainPageProvider;

  @override
  void initState() {
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    locationProvider = Provider.of<LocationProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);
    _fetchUserData();
    super.initState();
  }

  File? image;

  bool loader = false;

  Future<void> _fetchUserData() async {
    setState(() => loader = true);
    final userData1 = await userData!.fetchUserInfo();
    if (!mounted) return;
    setState(() {
      final detail = userData1['detail'];
      _id = userData1['_id'] ?? userData1['id'];
      selectedName = userData1["name"];

      if (detail != null) {
        selectedDate = DateTime.tryParse(detail?['dob'] ?? '');

        if (detail?['weight'] != null && detail['weight'].toString() != "0") {
          selectedWeight.text = '${detail?['weight'] ?? 0}lbs';
        }

        if (detail['bodyfat'] != null &&
            detail['bodyfat'].toString() != "0" &&
            detail['bodyfat'].toString().isNotEmpty) {
          selectedBodyFat.text = '${detail?['bodyfat'] ?? 0}%';
        }
        final heightStr = (detail?['height'] ?? "0").toString();

        if (detail['height'] != null) {
          if (heightStr != "0") {
            selectedHeight.text = heightStr == "0"
                ? "0"
                : "${heightStr[0]}'${heightStr.length > 1 ? heightStr[1] : ""}${heightStr.length > 2 ? heightStr[2] : ""}\"";
          }
        }

        heightInCm = (heightStr == "0")
            ? 183
            : convertToInches(
                int.parse(heightStr[0]),
                double.parse(
                  "${heightStr.length > 1 ? heightStr[1] : "0"}${heightStr.length > 2 ? heightStr[2] : ""}",
                ),
              );
        if (detail['midthigh'] != null &&
            detail['midthigh'].toString() != "0" &&
            detail['midthigh'].toString().isNotEmpty) {
          selectedMidThigh.text = '${detail?['midthigh'] ?? 0}"';
        }
        if (detail['hip'] != null &&
            detail['hip'].toString() != "0" &&
            detail['hip'].toString().isNotEmpty) {
          selectedHip.text = '${detail?['hip'] ?? 0}"';
        }
        if (detail['waist'] != null &&
            detail['waist'].toString() != "0" &&
            detail['waist'].toString().isNotEmpty) {
          selectedWaist.text = '${detail?['waist'] ?? 0}"';
        }

        selectedLocation = detail?['location'] ?? "";
        _imageUrl = detail?['avatarUrl'] ?? "";

        final genderIndex = detail == null
            ? 0
            : detail['sex'] == null
                ? 1
                : detail['sex'] == true
                    ? 1
                    : 0;
        selectedGender = genderOptions[genderIndex];

        selectedGoal = detail?['mygoal'] ?? "";

        if ((detail?['country'] ?? '').isEmpty) {
          locationProvider.setAndCallApi();
        } else {
          locationProvider.fillDetails(
            detail?['country'],
            detail?['state'] ?? "",
            detail?['city'] ?? "",
          );
        }
      }
    });

    setState(() => loader = false);
  }

  double convertToInches(int feet, double inches) {
    if (inches > 11) {
      throw ArgumentError('Inches must be less than or equal to 11');
    }
    double inchesTotal = (feet * 12) + inches;
    return inchesTotal * 2.54;
  }

  bool isLoading = false;
  Future<void> _saveUserData() async {
    // setState(() {
    //   isLoading = true;
    // });

    final userDetails = {
      // 'firstName': 'Nick',
      // 'lastName': 'Vlacic',
      'sex':
          selectedGender != null ? genderOptions.indexOf(selectedGender!) : "",
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
      'location': selectedLocation,
      'mygoal': selectedGoal,
      'avatarUrl': _imageUrl ?? '',
      'country': locationProvider.selectedCountry,
      'state': locationProvider.selectedState,
      'city': locationProvider.selectedCityController.text,
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

    if (_id != null) {
      await userData!.updateUserInfo(_id!, userDetails, image);

      ///

      // Fluttertoast.showToast(
      //   msg: "Profile updated!",
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.TOP_RIGHT,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: AppColors.primaryColor,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );

      // setState(() {
      //   isLoading = false;
      // });
    } else {
      if (kDebugMode) {
        print("Error: User ID is null");
      }
      // setState(() {
      //   isLoading = false;
      // });
    }
    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  void dispose() {
    _saveUserData();
    _imageUrl = null;
    selectedName = "";
    selectedDate = null;
    selectedWeight.clear();
    selectedBodyFat.clear();
    selectedGender = null;
    selectedHeight.clear();
    selectedMidThigh.clear();
    selectedWaist.clear();
    selectedHip.clear();
    selectedLocation = null;
    selectedGoal = null;
    heightInCm = 183;

    selectedHeightUnit = HeightUnit.cm;

    canConvertUnit = true;
    showSeparationText = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        AppImage.imageMyProfle(
                            // media,
                            // image: dataProvider!.allImageList
                            //     .where((element) =>
                            //         element["key"] == "imageMyProfle")
                            //     .first["image"],
                            // // image: dataProvider!.cachedImageMap["imageMyProfle"],
                            // imageKey: "imageMyProfle",
                            ),
                        SizedBox(
                          height: media.height / 1.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1),
                                  surfaceTintColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  centerTitle: true,
                                  leading: BackArrowWidget(
                                    onPress: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  title: Text(
                                    'My Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(5.5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(
                                          routeString: '/exerciseLibrary'),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: ScreenUtil.horizontalScale(2),
                                      ),
                                      Consumer<UserDataProvider>(
                                        builder: (context, userData, child) =>
                                            userData.user["name"] != ""
                                                ? ProfileImageWidget(
                                                    avatarUrl: userData
                                                                        .userData[
                                                                    'detail'] !=
                                                                null &&
                                                            userData.userData[
                                                                        'detail']
                                                                    [
                                                                    'avatarUrl'] !=
                                                                null &&
                                                            userData.userData[
                                                                        'detail']
                                                                    [
                                                                    'avatarUrl'] !=
                                                                ""
                                                        ? userData.userData[
                                                                'detail']
                                                            ['avatarUrl']
                                                        : "",
                                                    name: userData.user["name"]
                                                        .toString()
                                                        .replaceAll(" ", ""),
                                                    callBack: (pickedImage) {
                                                      image = pickedImage!;
                                                      setState(() {});
                                                    },
                                                    showPickImageButton: true,
                                                  )
                                                : const SizedBox(),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.verticalScale(2.5),
                                      ),
                                      Consumer<UserDataProvider>(
                                        builder: (context, userData, child) =>
                                            userData.userName != ""
                                                ? Text(
                                                    // 'Hi, Nick',
                                                    userData.userName,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: ScreenUtil
                                                          .horizontalScale(6),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.horizontalScale(0.7),
                                      ),
                                      Consumer<UserDataProvider>(
                                        builder: (context, userData, child) =>
                                            userData.userName != ""
                                                ? Text(
                                                    userData.userEmail,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: ScreenUtil
                                                          .horizontalScale(3.5),
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      height: 1,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 2.998,
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
                Container(
                  width: media.width,
                  constraints: BoxConstraints(
                      minHeight: media.height - (media.height / 3)),
                  margin: EdgeInsets.only(top: media.height / 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                    ),
                  ),
                  child: loader
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileField(
                              context: context,
                              label: 'Birthday',
                              value: selectedDate != null
                                  ? DateFormat('MM/dd/yyyy')
                                      .format(selectedDate!)
                                  : 'Enter here',
                              onTap: () {
                                _showDatePicker(context);
                              },
                            ),
                            _buildDropdownField(
                              context: context,
                              label: 'Gender',
                              value: selectedGender,
                              options: genderOptions,
                              hint: 'Enter here',
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedGender = newValue!;
                                });
                              },
                            ),
                            // _buildDropdownField(
                            //   context: context,
                            //   label: 'My Goals',
                            //   value: selectedGoal,
                            //   options: goalsOptions,
                            //   hint: 'Goals',
                            //   onChanged: (String? newValue) {
                            //     setState(() {
                            //       selectedGoal = newValue!;
                            //     });
                            //   },
                            // ),
                            Consumer<LocationProvider>(
                              builder: (context, value, child) {
                                log(' value.selectedState==========>>>>>${value.selectedState}');
                                return Column(
                                  children: [
                                    _buildDropdownField(
                                      context: context,
                                      label: 'Country',
                                      value: value.selectedCountry,
                                      options: value.country?.countries ?? [],
                                      hint: 'Enter here',
                                      onChanged: value.onCountrySelect,
                                    ),
                                    _buildDropdownField(
                                      context: context,
                                      label: 'State',
                                      value: value.selectedState,
                                      options: value.states?.states ?? [],
                                      hint: 'Enter here',
                                      onChanged: value.onStateSelect,
                                    ),
                                    _buildTextField(
                                      context: context,
                                      label: 'City',
                                      value: value.selectedCityController,
                                      hint: 'Enter here',
                                    ),
                                  ],
                                );
                              },
                            ),
                            _heightPicker(
                              context: context,
                              label: 'Height',
                              value: selectedHeight,
                              hint: '6\'0"',
                            ),
                            NumberEntry(
                              label: 'Weight',
                              controller: selectedWeight,
                              focusNode: _nodeText1,
                              suffix: "lbs",
                            ),

                            NumberEntry(
                              label: 'Waist',
                              controller: selectedWaist,
                              focusNode: _nodeText2,
                              suffix: '"',
                            ),
                            NumberEntry(
                              label: 'Hip',
                              controller: selectedHip,
                              focusNode: _nodeText3,
                              suffix: '"',
                            ),

                            NumberEntry(
                              label: 'Mid-Thigh',
                              controller: selectedMidThigh,
                              focusNode: _nodeText4,
                              suffix: '"',
                            ),

                            NumberEntry(
                              label: 'Body-Fat',
                              controller: selectedBodyFat,
                              focusNode: _nodeText5,
                              suffix: "%", // hint: '81',
                            ),

                            SizedBox(height: ScreenUtil.verticalScale(2)),
                            // isLoading == true
                            //     ? const Center(
                            //         child: CircularProgressIndicator(
                            //         color: AppColors.primaryColor,
                            //       ))
                            //     : Container(
                            //         margin: EdgeInsets.symmetric(
                            //           horizontal: ScreenUtil.horizontalScale(9),
                            //         ),
                            //         child: ButtonWidget(
                            //           text: "Save",
                            //           textColor: Colors.white,
                            //           onPress: _saveUserData,
                            //           color: AppColors.primaryColor,
                            //           isLoading: false,
                            //         ),
                            //       ),
                            // SizedBox(height: ScreenUtil.verticalScale(3.2)),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Profile Field for Birthday and Other Text Inputs
  Widget _buildProfileField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil.horizontalScale(7.5),
        right: ScreenUtil.horizontalScale(7.5),
        bottom: ScreenUtil.verticalScale(0.8),
        top: ScreenUtil.verticalScale(3),
      ),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(34.5),
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
            width: ScreenUtil.horizontalScale(50.5),
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
                      color: value == 'Enter here'
                          ? Colors.grey.shade700
                          : Colors.black,
                      fontSize: ScreenUtil.verticalScale(1.95),
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> options,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil.horizontalScale(7.5),
          vertical: ScreenUtil.verticalScale(0.8)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(34.5),
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
            width: ScreenUtil.horizontalScale(50.5),
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
                // value: value,
                dropdownColor: Theme.of(context).cardColor,
                elevation: 12,
                hint: Text((value != null && value.isNotEmpty) ? value : hint),
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

  Widget _buildTextField(
      {required BuildContext context,
      required String label,
      required TextEditingController value,
      required String hint}) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil.horizontalScale(7.5),
          vertical: ScreenUtil.verticalScale(0.8)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(34.5),
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
            width: ScreenUtil.horizontalScale(50.5),
            height: ScreenUtil.verticalScale(6),
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(1)),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: Utils.buttonRadius,
            ),
            child: Center(
              child: TextField(
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.95),
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                controller: value,
                keyboardType: TextInputType.text,
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: ScreenUtil.verticalScale(1.95),
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          )
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
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil.horizontalScale(7.5),
          vertical: ScreenUtil.verticalScale(0.8)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: ScreenUtil.horizontalScale(34.5),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.95),
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
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
            child: Container(
              width: ScreenUtil.horizontalScale(50.5),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.horizontalScale(1),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: Utils.buttonRadius,
              ),
              child: Center(
                child: Text(
                  value.text.isEmpty ? 'Enter here' : value.text,
                  style: TextStyle(
                    color: value.text.isEmpty
                        ? Colors.grey.shade700
                        : Colors.black,
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
        color: AppColors.blackColor,
      ),
      dateOrder: DatePickerDateOrder.mdy,
      initialDateTime: selectedDate ?? DateTime(2000, 1, 1),
      maxDateTime: DateTime.now(),
      minDateTime: DateTime(1950, 1, 1),
      onSubmit: (dob) {
        selectedDate = dob;
        setState(() {});
      },
      backgroundColor: Theme.of(context).canvasColor,
      height: 320,
      displayCloseIcon: true,
      closeIconColor: Colors.black,
      buttonWidth: ScreenUtil.horizontalScale(73),
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
          "",
          style: TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: ScreenUtil.verticalScale(2),
          ),
        ),
      ),
    ).show(context);
  }

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();
}
