import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bbb/models/tutorials.dart';
import 'package:http/http.dart' as http;
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoInitialiseProvider extends ChangeNotifier {}
