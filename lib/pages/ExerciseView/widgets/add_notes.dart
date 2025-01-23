import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbb/components/app_alert_dialog.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_colors.dart';

class AddNoteBottomSheet extends StatefulWidget {
  @override
  _AddNoteBottomSheetState createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  TextEditingController _noteController = TextEditingController();
  UserDataProvider? userData;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Add a New Note text
              const Center(
                child: Text(
                  "Add a New Note",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Multiline Text Box
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Save Note Button
              ButtonWidget(
                text: "Save Note",
                textColor: Colors.white,
                onPress: () {
                  if (_noteController.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AppAlertDialog(
                          title: "",
                          description: "Please enter text in the input field.",
                        );
                      },
                    );
                  } else {
                    userData?.addNewNote(_noteController.text);
                    _noteController.clear();
                  }
                },
                color: AppColors.primaryColor,
                isLoading: false,
              ),
              const SizedBox(height: 20),

              _buildPreviouslyAddedNotes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviouslyAddedNotes() {
    return Consumer<UserDataProvider>(
      builder: (context, userData, child) => userData.notesData.isEmpty
          ? const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: Text("No notes added yet."),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Previously Added Notes:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 150, // You can adjust this height
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      itemCount: userData.notesData
                          .where((note) => note['exercise_id'].toString() == userData.currentExercise.id)
                          .length,
                      itemBuilder: (context, index) {
                        final note = userData.notesData
                            .where((note) => note['exercise_id'].toString() == userData.currentExercise.id)
                            .toList()[
                                userData.notesData
                                        .where((note) => note['exercise_id'].toString() == userData.currentExercise.id)
                                        .length -
                                    1 -
                                    index];
                        return _buildNoteRow(note["date"]!, note["content"]!);
                      },
                    ),
                  )
                ),
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
          // Date part
          Text(
            date,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),

          // Separator
          const Text('|'),
          const SizedBox(width: 10),

          // Note content part
          Expanded(
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
