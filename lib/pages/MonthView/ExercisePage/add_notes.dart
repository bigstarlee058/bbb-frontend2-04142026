import 'dart:convert';
import 'dart:io';

import 'package:bbb/components/app_alert_dialog.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/exercise_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddNoteBottomSheet extends StatefulWidget {
  const AddNoteBottomSheet({super.key});

  @override
  State<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  MonthProvider? monthProvider;

  @override
  void initState() {
    super.initState();
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) async => await getNotesData());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<ExerciseNotesModel> dataList = [];
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: Platform.isAndroid ? true : false,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ScreenUtil.verticalScale(3)),
          topRight: Radius.circular(ScreenUtil.verticalScale(3)),
        ),
        child: Container(
          color: Theme.of(context).cardColor,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      height: 25,
                      width: 40,
                      child: Center(
                        child: GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Add a New Note text
                  Center(
                    child: Text(
                      "Journal & Reminders",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.labelLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Multiline Text Box
                  TextField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Enter here',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Save Note Button
                  ButtonWidget(
                    text: "Save",
                    textColor: Colors.white,
                    onPress: () {
                      if (_noteController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AppAlertDialog(
                              title: "",
                              description:
                                  "Please enter text in the input field.",
                            );
                          },
                        );
                      } else {
                        addNewNote();
                        _noteController.clear();
                      }
                    },
                    color: AppColors.primaryColor,
                    isLoading: false,
                  ),
                  const SizedBox(height: 15),

                  _buildPreviouslyAddedNotes(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviouslyAddedNotes() {
    return Consumer<UserDataProvider>(
      builder: (context, userData, child) => dataList.isEmpty
          ? Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Text(
                "No journal & reminders added yet.",
                style: TextStyle(
                  color: Theme.of(context).textTheme.labelLarge?.color,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Previously Added Entries:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 110,
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        final note = dataList[index];
                        return _buildNoteRow(
                            DateFormat("MM/dd/yyyy").format(
                                Utils.formattedDate(note.date.toString())),
                            note.note!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
    );
  }

  Widget _buildNoteRow(String date, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '|',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  addNewNote() async {
    String id = monthProvider!.isWarmup
        ? monthProvider?.warmUpModel?.id ?? ""
        : monthProvider!.isPumpDay && monthProvider!.isCircuit
            ? "${monthProvider!.exerciseDetailModel!.sId.toString()}-${monthProvider!.circuitIndex}"
            : monthProvider!.exerciseDetailModel!.sId.toString();
    final data = {
      "exerciseId": id.toString(),
      "date": "${DateTime.now().toUtc()}",
      "note": _noteController.text.trim(),
    };
    ApiRepo.addExerciseNotes(body: data);
    await DatabaseHelper()
        .insertData(data: data, tableName: DatabaseHelper.exerciseNotes);
    getNotesData();
  }

  getNotesData() async {
    String id = monthProvider!.isWarmup
        ? monthProvider?.warmUpModel?.id ?? ""
        : monthProvider!.isPumpDay && monthProvider!.isCircuit
            ? "${monthProvider!.exerciseDetailModel!.sId.toString()}-${monthProvider!.circuitIndex}"
            : monthProvider!.exerciseDetailModel!.sId.toString();

    final data = await DatabaseHelper().getDataFromTable(
        tableName: DatabaseHelper.exerciseNotes, id: id, where: "exerciseId");
    if (data.isNotEmpty) {
      dataList = List<ExerciseNotesModel>.from(json
          .decode(jsonEncode(data))
          .map((x) => ExerciseNotesModel.fromJson(x)));
    } else {
      dataList = [];
    }
    setState(() {});
  }
}
