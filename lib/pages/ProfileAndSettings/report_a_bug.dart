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
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class ReportABugScreen extends StatefulWidget {
  const ReportABugScreen({super.key});

  @override
  State<ReportABugScreen> createState() => _ReportABugScreenState();
}

class _ReportABugScreenState extends State<ReportABugScreen> {
  File? image;
  final titleController = TextEditingController(text: "Report a Bug");
  final descriptionController = TextEditingController();
  DataProvider? dataProvider;

  String mobileVersion = "";
  String appVersion = "";

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        PackageInfo version = await getCurrentAppVersion();

        appVersion = version.version;

        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          mobileVersion =
              "Device: ${androidInfo.model}, Brand: ${androidInfo.brand}, Android Version: ${androidInfo.version.release}";
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          mobileVersion =
              "Device: ${iosInfo.utsname.machine}, System Name: ${iosInfo.systemName}, iOS Version: ${iosInfo.systemVersion}";
        }
      },
    );
    super.initState();
  }

  Future<PackageInfo> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            'Report a Bug',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: ScreenUtil.verticalScale(2.3),
            ),
          ),
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
              Consumer<DataProvider>(builder: (context, value, child) {
                return ButtonWidget(
                  text: "Submit",
                  textColor: Colors.white,
                  color: AppColors.primaryColor,
                  onPress: () async {
                    if (titleController.text.isEmpty &&
                        descriptionController.text.isEmpty) {
                      showBottomAlert(context, "Please enter details");
                    } else if (titleController.text.isEmpty) {
                      showBottomAlert(context, "Please enter title");
                    } else if (descriptionController.text.isEmpty) {
                      showBottomAlert(context, "Please enter description");
                    } else {
                      bool val = await value.addOwnSpotlight(
                        titleController.text.trim(),
                        descriptionController.text.trim(),
                        image,
                        isFromReport: true,
                        osVersion: mobileVersion,
                        appVersion: appVersion,
                      );
                      if (val == true) {
                        Fluttertoast.showToast(
                          msg: "Feedback submitted successfully!",
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
                          msg: "Failed to submit feedback, Please try again!",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: ScreenUtil.verticalScale(3)),
              Text(
                "Welcome to the Booty by Bret app beta! We'd love to get your feedback as we work through our first release and some initial bugs. If you notice anything off or not working (or if you have any feedback or suggestions whatsoever), feel free to message us.",
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.8),
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: ScreenUtil.verticalScale(3)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AppTextFormField(
                  maxLines: 8,
                  hintText: 'Enter details here...',
                  keyboardType: TextInputType.text,
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
              SizedBox(height: 20),
              if (image == null)
                TextButton(
                    onPressed: _pickAndUploadImage,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          size: ScreenUtil.verticalScale(2.5),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Attachment (Optional)",
                          style: TextStyle(
                            fontSize: ScreenUtil.verticalScale(1.8),
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Attachment",
                      style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(1.8),
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    SizedBox(height: 15),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil.horizontalScale(5)),
                      child: Container(
                        height: ScreenUtil.verticalScale(14),
                        width: ScreenUtil.verticalScale(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(ScreenUtil.horizontalScale(5)),
                          ),
                        ),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              SizedBox(height: ScreenUtil.verticalScale(3)),
            ],
          ),
        ),
      );
}
