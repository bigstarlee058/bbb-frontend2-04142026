import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ProfileBoardingScreen extends StatefulWidget {
  const ProfileBoardingScreen({super.key});

  @override
  State<ProfileBoardingScreen> createState() => _ProfileBoardingScreenState();
}

class _ProfileBoardingScreenState extends State<ProfileBoardingScreen> {
  int currentPage = 1;
  TextEditingController nameController = TextEditingController();
  PageController pageController = PageController();
  File? image;
  DateTime? selectedDate;
  String? selectedWeight;
  String? selectedGender;
  String? selectedHeight;
  final List<String> heightOptions = ['5\'0"', '5\'5"', '6\'0"', '6\'5"']; // Example heights
  final List<String> weightOptions = ['100 lbs', '110 lbs', '121 lbs', '130 lbs', '140 lbs'];
  final List<String> genderOptions = ['Female', 'Male', 'Other'];

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
                          height: media.height / 2,
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
                          height: media.height / 7.9,
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
                    child: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(minHeight: media.height * 0.72),
                          width: media.width,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(55),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(5),
                              vertical: ScreenUtil.verticalScale(2),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(4)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: media.height * 0.68,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)).copyWith(bottom: ScreenUtil.horizontalScale(7)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: ScreenUtil.horizontalScale(2),
                left: ScreenUtil.horizontalScale(2),
                bottom: ScreenUtil.verticalScale(1.5),
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
              text: "Next",
              textColor: Colors.white,
              color: AppColors.primaryColor,
              onPress: () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                );
                // currentPage = pageController.page!.toInt();
                setState(() {});
              },
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget page1() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: ScreenUtil.verticalScale(3.5)),
          Text(
            "Name",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(4),
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
          SizedBox(height: ScreenUtil.verticalScale(1.2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AppTextFormField(
              hintText: 'Your Name',
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
          SizedBox(height: ScreenUtil.verticalScale(3.5)),
          Text(
            "Details",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(4),
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
                "Add your details",
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
          SizedBox(height: ScreenUtil.verticalScale(1)),
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
              );
              if (pickedDate != null && pickedDate != selectedDate) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
          ),
          SizedBox(height: ScreenUtil.verticalScale(1)),
          _buildDropdownField(
            context: context,
            label: 'Height',
            value: selectedHeight,
            options: heightOptions,
            hint: '5\'5"',
            onChanged: (String? newValue) {
              setState(() {
                selectedHeight = newValue!;
              });
            },
          ),
          SizedBox(height: ScreenUtil.verticalScale(1)),
          _buildDropdownField(
            context: context,
            label: 'Weight',
            value: selectedWeight,
            options: weightOptions,
            hint: '100 lbs',
            onChanged: (String? newValue) {
              setState(() {
                selectedWeight = newValue!;
              });
            },
          ),
        ],
      );

  Widget page3() => Column(
        children: [
          SizedBox(height: ScreenUtil.verticalScale(3.5)),
          Center(
            child: Container(
              height: ScreenUtil.horizontalScale(23.5),
              width: ScreenUtil.horizontalScale(23.5),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .9),
                borderRadius: BorderRadius.all(
                  Radius.circular(ScreenUtil.horizontalScale(12.5)),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: ScreenUtil.horizontalScale(25),
                    width: ScreenUtil.horizontalScale(25),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.horizontalScale(12.5)),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtil.horizontalScale(12.5)),
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
                        radius: ScreenUtil.horizontalScale(3.5), // Adjust size as needed
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
          SizedBox(height: ScreenUtil.verticalScale(5)),
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
            margin: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
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
            margin: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
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
            margin: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
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
          ),
        ],
      );

  Widget _buildDropdownField(
      {required BuildContext context,
      required String label,
      required String? value,
      required List<String> options,
      required String hint,
      required ValueChanged<String?> onChanged}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(0.8)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.horizontalScale(1),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ScreenUtil.verticalScale(5),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20888888),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 1),
                  ),
                ],
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
                        child: Text(value),
                      ),
                    );
                  }).toList(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({required BuildContext context, required String label, required String value, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(0.8)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.horizontalScale(1),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ScreenUtil.verticalScale(5),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x20888888),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  // Center the text
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: (value == 'Select Birthday') ? FontWeight.normal : FontWeight.bold,
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
}
