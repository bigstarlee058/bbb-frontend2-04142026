import 'dart:convert';
// import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesManager {
  List<dynamic> notesData = [];

  Future<bool> notesDataExists()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('notes_data') == null || prefs.getString('notes_data')!.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> saveNotesData(List<dynamic> newNotes) async {
    notesData = newNotes;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notes_data', jsonEncode(newNotes));
  }

  Future<List> getNotesData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String notesDataString = pref.getString('notes_data')!;

    if (notesDataString.isNotEmpty) {
      notesData = jsonDecode(notesDataString) as List<dynamic>;
    }
    return notesData;
  }
}