import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class AddMemberSpotlight extends StatefulWidget {
  const AddMemberSpotlight({super.key});

  @override
  State<AddMemberSpotlight> createState() => _AddMemberSpotlightState();
}

class _AddMemberSpotlightState extends State<AddMemberSpotlight> {
  File? image;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DataProvider? dataProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Scaffold(
          appBar: AppBar(
            leading: BackArrowWidget(onPress: () => Navigator.pop(context)),
            toolbarHeight: ScreenUtil.verticalScale(5.1),
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'Submit Your Story',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: ScreenUtil.verticalScale(2.3),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: Platform.isIOS
                  ? ScreenUtil.verticalScale(3.2)
                  : ScreenUtil.verticalScale(1.2),
              right: ScreenUtil.horizontalScale(7),
              left: ScreenUtil.horizontalScale(7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<DataProvider>(builder: (context, value, child) {
                  return Column(
                    children: [
                      ButtonWidget(
                        text: "Submit",
                        textColor: Colors.white,
                        color: AppColors.primaryColor,
                        onPress: () async {
                          if (image == null &&
                              titleController.text.isEmpty &&
                              descriptionController.text.isEmpty) {
                            showBottomAlert(context, "Please enter details");
                          } else if (image == null) {
                            showBottomAlert(context, "Please select image");
                          } else if (titleController.text.isEmpty) {
                            showBottomAlert(context, "Please enter title");
                          } else if (descriptionController.text.isEmpty) {
                            showBottomAlert(
                                context, "Please enter description");
                          } else {
                            bool val = await value.addOwnSpotlight(
                              titleController.text.trim(),
                              descriptionController.text.trim(),
                              image,
                            );
                            if (val == true) {
                              Fluttertoast.showToast(
                                msg: "Story submitted successfully!",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP_RIGHT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: AppColors.primaryColor,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(
                                msg:
                                    "Failed to add spotlight, Please try again!",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP_RIGHT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: AppColors.primaryColor,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                        },
                        isLoading: value.storyLoader,
                      ),
                      SizedBox(height: 12),
                      Text(
                        textAlign: TextAlign.center,
                        "By submitting your photos, you grant Booty by Bret LLC the rights outlined in Section 5.5 of our Terms of Use to use and promote these images across our platforms and marketing materials.",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontStyle: FontStyle.italic,
                            fontSize: ScreenUtil.verticalScale(1.2)),
                      )
                    ],
                  );
                }),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
            child: form(),
          ),
        ),
      ),
    );
  }

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

  Widget form() => Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: ScreenUtil.verticalScale(3)),
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Consumer<UserDataProvider>(
                  builder: (context, userData, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: ScreenUtil.horizontalScale(48),
                          width: ScreenUtil.horizontalScale(48),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil.horizontalScale(5)),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                ScreenUtil.horizontalScale(5)),
                            child: image != null
                                ? Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: ScreenUtil.horizontalScale(48),
                                    width: ScreenUtil.horizontalScale(48),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      // border:
                                      //     Border.all(color: AppColors.appGreyColor),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil.horizontalScale(5)),
                                      ),
                                    ),
                                    child: Builder(builder: (context) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                  ScreenUtil.verticalScale(
                                                      1.1)),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  shape: BoxShape.circle),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.grey.shade400,
                                                size:
                                                    ScreenUtil.verticalScale(3),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  ScreenUtil.verticalScale(1.3),
                                            ),
                                            Text(
                                              "Upload your photo",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: Colors.grey.shade400,
                                                fontWeight: FontWeight.w500,
                                                fontSize:
                                                    ScreenUtil.verticalScale(
                                                        1.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: ScreenUtil.verticalScale(4)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AppTextFormField(
                  hintText: 'Your Name',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    if (titleController.text.toString().trim().isEmpty) {
                      titleController.clear();
                      setState(() {});
                    }
                  },
                  controller: titleController,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AppTextFormField(
                  maxLines: 7,
                  hintText: 'Write your story here',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    if (descriptionController.text.toString().trim().isEmpty) {
                      descriptionController.clear();
                      setState(() {});
                    }
                  },
                  controller: descriptionController,
                ),
              ),
              SizedBox(height: ScreenUtil.verticalScale(3)),
            ],
          ),
        ),
      );
}
