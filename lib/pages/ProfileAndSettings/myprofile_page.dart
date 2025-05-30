///my...
import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
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
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

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
  double waistInCm = 31;
  double hipInCm = 30;
  double midThigh = 30;
  HeightUnit selectedHeightUnit = HeightUnit.cm;

  WaistUnit selectedWaistUnit = WaistUnit.inches;
  HipUnit selectedHipUnit = HipUnit.inches;
  bool canConvertUnit = true;
  bool showSeparationText = true;

  final List<String> genderOptions = ['Female', 'Male', 'Other'];
  final List<String> goalsOptions = ['Muscle Growth', 'Weight Gain', 'Strength & Performance'];
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
    // try {

    setState(() => loader = true);
    final userData1 = await userData!.fetchUserInfo();
    // userData['detail'] = jsonDecode( userData['detail']);

    if (!mounted) return;
    setState(() {
      _id = userData1['_id'];
      selectedName = userData1["name"];
      selectedDate = userData1["detail"]['dob'] == null ? null : DateTime.parse(userData1["detail"]['dob']);
      selectedWeight.text =
          userData1["detail"]["weight"] == null ? "0" : '${userData1["detail"]["weight"]}'; //'${userData['detail']['weight']}';
      selectedBodyFat.text =
          userData1["detail"]["bodyfat"] == null ? "0" : '${userData1["detail"]["bodyfat"]}'; //'${userData['detail']['weight']}';
      selectedHeight.text = userData1["detail"]["height"] == null || userData1["detail"]["height"].toString() == "0"
          ? "0"
          : '${userData1["detail"]["height"].toString()[0]}\'${userData1["detail"]["height"].toString()[1]}${userData1["detail"]["height"].toString().length > 2 ? userData1["detail"]["height"].toString()[2] : ""}"'; //'${userData['detail']['height']}\'0"';
      selectedMidThigh.text = userData1["detail"]["midthigh"] == null ? "0" : userData1["detail"]["midthigh"].toString();
      selectedHip.text = userData1["detail"]["hip"] == null ? "0" : userData1["detail"]["hip"].toString();
      selectedWaist.text = userData1["detail"]["waist"] == null ? "0" : userData1["detail"]["waist"].toString();

      heightInCm = userData1["detail"]["height"] == null || userData1["detail"]["height"].toString() == "0"
          ? 183
          : convertToInches(
              int.parse(userData1["detail"]["height"].toString()[0]),
              double.parse(
                  "${userData1["detail"]["height"].toString()[1]}${userData1["detail"]["height"].toString().length > 2 ? userData1["detail"]["height"].toString()[2] : ""}"));
      waistInCm = userData1["detail"]["waist"] == null || userData1["detail"]["waist"].toString() == "0"
          ? 31
          : convertToInches(
              int.parse(userData1["detail"]["waist"].toString()[0]),
              double.parse(
                  "${userData1["detail"]["waist"].toString()[1]}${userData1["detail"]["waist"].toString().length > 2 ? userData1["detail"]["waist"].toString()[2] : ""}"));
      // hipInCm = userData1["detail"]["hip"] == null
      //     ? 31
      //     : convertToInches(
      //         int.parse(userData1["detail"]["hip"].toString()[0]),
      //         double.parse(
      //             "${userData1["detail"]["hip"].toString()[1]}${userData1["detail"]["hip"].toString().length > 2 ? userData1["detail"]["hip"].toString()[2] : ""}"));
      // midThigh = userData1["detail"]["midthigh"] == null
      //     ? 31
      //     : convertToInches(
      //         int.parse(userData1["detail"]["midthigh"].toString()[0]),
      //         double.parse(
      //             "${userData1["detail"]["midthigh"].toString()[1]}${userData1["detail"]["midthigh"].toString().length > 2 ? userData1["detail"]["midthigh"].toString()[2] : ""}"));

      selectedLocation = userData1['detail']['location'] ?? "";
      _imageUrl = userData1['detail']['avatarUrl'] ?? "";
      selectedGender = genderOptions[userData1['detail']['sex'] == null
          ? 1
          : userData1['detail']['sex'] == true
              ? 1
              : 0];
      selectedGoal = userData1['detail']['mygoal'] ?? "";
      if (userData1['detail']['country'] == null || userData1['detail']['country'] == '') {
        locationProvider.setAndCallApi();
      } else {
        locationProvider.fillDetails(userData1['detail']['country'], userData1['detail']['state'] ?? "", userData1['detail']['city'] ?? "");
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
    setState(() {
      isLoading = true;
    });
    final userDetails = {
      // 'firstName': 'Nick',
      // 'lastName': 'Vlacic',
      'sex': genderOptions.indexOf(selectedGender!),
      'dob': selectedDate?.toIso8601String(),
      'weight': int.parse(selectedWeight.text.split(' ')[0]),
      'height': int.parse(selectedHeight.text.replaceAll('\'', '').replaceAll("\"", "")),
      'location': selectedLocation,
      'mygoal': selectedGoal,
      'avatarUrl': _imageUrl ?? '',
      'country': locationProvider.selectedCountry,
      'state': locationProvider.selectedState,
      'city': locationProvider.selectedCityController.text,
      'waist': int.parse(selectedWaist.text.replaceAll('\'', '').replaceAll("\"", "") ?? "0"),
      'hip': int.parse(selectedHip.text.replaceAll('\'', '').replaceAll("\"", "") ?? "0"),
      'midthigh': int.parse(selectedMidThigh.text.replaceAll('\'', '').replaceAll("\"", "") ?? "0"),
      'bodyfat': int.parse(selectedBodyFat.text.split(' ')[0]),
    };
    if (kDebugMode) {
      print('HERE IS USERDETAIL##, $userDetails');
    }

    if (_id != null) {
      await userData!.updateUserInfo(_id!, userDetails, image);

      ///

      Fluttertoast.showToast(
        msg: "Profile updated!",
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
    } else {
      if (kDebugMode) {
        print("Error: User ID is null");
      }
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
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
    waistInCm = 31;
    hipInCm = 30;
    midThigh = 30;
    selectedHeightUnit = HeightUnit.cm;
    selectedWaistUnit = WaistUnit.inches;
    selectedHipUnit = HipUnit.inches;
    canConvertUnit = true;
    showSeparationText = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        // Container(
                        //   height: media.height / 1,
                        //   width: media.width,
                        //   decoration: const BoxDecoration(
                        //     image: DecorationImage(
                        //       image: AssetImage('assets/img/back.jpg'),
                        //       fit: BoxFit.cover,
                        //       opacity: 1,
                        //     ),
                        //   ),
                        // ),
                        // ),
                        Utils.appImage(
                          media,
                          // dataProvider?.screenBackgroundResponse?.imageMyProfle ?? "",
                          dataProvider!.cachedImageMap["imageMyProfle"],

                          imageKey: "imageMyProfle",
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
                                      child: const CommonStreakWithNotification(routeString: '/exerciseLibrary'),
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
                                        builder: (context, userData, child) => userData.userName != ""
                                            ? ProfileImageWidget(
                                                avatarUrl:
                                                    userData.userData['detail'] != null && userData.userData['detail']['avatarUrl'] != ""
                                                        ? userData.userData['detail']['avatarUrl']
                                                        : "",
                                                name: userData.userName,
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
                                        builder: (context, userData, child) => userData.userName != ""
                                            ? Text(
                                                // 'Hi, Nick',
                                                userData.userName,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.horizontalScale(6),
                                                  fontWeight: FontWeight.bold,
                                                  height: 1,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.horizontalScale(0.7),
                                      ),
                                      Consumer<UserDataProvider>(
                                        builder: (context, userData, child) => userData.userName != ""
                                            ? Text(
                                                userData.userEmail,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.horizontalScale(3.5),
                                                  fontWeight: FontWeight.normal,
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
                  width: media.width,
                  constraints: BoxConstraints(minHeight: media.height - (media.height / 3)),
                  margin: EdgeInsets.only(top: media.height / 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                            _buildDropdownField(
                              context: context,
                              label: 'Gender',
                              value: selectedGender,
                              options: genderOptions,
                              hint: 'Female',
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
                              builder: (context, value, child) => Column(
                                children: [
                                  _buildDropdownField(
                                    context: context,
                                    label: 'Country',
                                    value: value.selectedCountry,
                                    options: value.country?.countries ?? [],
                                    hint: 'Country',
                                    onChanged: value.onCountrySelect,
                                  ),
                                  _buildDropdownField(
                                    context: context,
                                    label: 'State',
                                    value: value.selectedState,
                                    options: value.states?.states ?? [],
                                    hint: 'State',
                                    onChanged: value.onStateSelect,
                                  ),
                                  _buildTextField(
                                    context: context,
                                    label: 'City',
                                    value: value.selectedCityController,
                                    hint: 'City',
                                  ),
                                ],
                              ),
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

                            SizedBox(height: ScreenUtil.verticalScale(2)),
                            isLoading == true
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ))
                                : Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(9),
                                    ),
                                    child: ButtonWidget(
                                      text: "Save",
                                      textColor: Colors.white,
                                      onPress: _saveUserData,
                                      color: AppColors.primaryColor,
                                      isLoading: false,
                                    ),
                                  ),
                            SizedBox(height: ScreenUtil.verticalScale(3.2)),
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
                  color: Colors.grey.withValues(alpha: 0.052),
                  borderRadius: Utils.buttonRadius,
                ),
                child: Center(
                  // Center the text
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
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

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> options,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7.5), vertical: ScreenUtil.verticalScale(0.8)),
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

              // DropdownButton<String>(
              //   value: value,
              //   hint: Text(hint),
              //   isExpanded: true,
              //   alignment: Alignment.center, // Align the dropdown text to the center
              //   items: options.map((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Center(
              //         // Center the individual items in dropdown
              //         child: Text(value),
              //       ),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       value = newValue;
              //     });
              //   },
              //   underline: Container(),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required BuildContext context, required String label, required TextEditingController value, required String hint}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7.5), vertical: ScreenUtil.verticalScale(0.8)),
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
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(1)),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.052),
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
                  hintText: "City",
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

  Widget _numberPicker({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String suffix,
    required FocusNode focusNode,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(7.5),
        vertical: ScreenUtil.verticalScale(0.8),
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
          Container(
            width: ScreenUtil.horizontalScale(50.5),
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

  Widget _waistPicker({required BuildContext context, required String label, required TextEditingController value, required String hint}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7.5), vertical: ScreenUtil.verticalScale(0.8)),
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
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.052),
              borderRadius: Utils.buttonRadius,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  log('value.text==========>>>>>${value.text}');
                  final rawText = value.text; // e.g., '39"'
                  final cleanText = rawText.replaceAll(RegExp(r'[^0-9.]'), ''); // removes non-numeric characters
                  final parsedValue = double.tryParse(cleanText) ?? 0;
                  log('double.tryParse(value.text) ?? 0==========>>>>>${double.tryParse(value.text) ?? 0}');

                  await showCupertinoWaistPicker(
                    initialWaist: parsedValue,
                    context: context,
                    canConvertUnit: canConvertUnit,
                    onWaistChanged: (val) {
                      setState(() {
                        log('val==========>>>>>${val}');

                        value.text = '${val.toInt()}"';
                      });
                    },
                  );
                },
                child: Text(
                  value.text.isEmpty ? 'Waist' : value.text,
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

  Widget _heightPicker({required BuildContext context, required String label, required TextEditingController value, required String hint}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7.5), vertical: ScreenUtil.verticalScale(0.8)),
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

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();

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
}
