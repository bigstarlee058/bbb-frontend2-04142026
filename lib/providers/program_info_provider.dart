import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/program_info_model.dart';
import '../values/app_constants.dart';

class ProgramInfoProvider extends ChangeNotifier {
  ProgramInfoModel? programInfoModel;

  bool loading = false;

  final List<GlobalKey> tileKeys = [];

  Future<void> getProgramInfo() async {
    if (programInfoModel != null) {
      return;
    }

    try {
      loading = true;

      String token = await getAuthToken();

      String split = preferences.getString(SharedPreference.split) ?? "";
      String equipmentType =
          preferences.getString(SharedPreference.equipmentType) ?? "";
      final response = await http.get(
        Uri.parse('${AppConstants.serverUrl}/api/program-info').replace(
          queryParameters: {
            'split': split,
            'equipmentType': equipmentType,
          },
        ), // replace with actual endpoint
        headers: {"auth_token": token},
      );

      if (response.statusCode == 200) {
        debugPrint('success getProgramInfo');
        programInfoModel = programInfoModelFromJson(response.body);

        final phaseCount = programInfoModel?.sections.length ?? 0;
        for (int i = 0; i < phaseCount; i++) {
          tileKeys.add(GlobalKey());
        }
      } else {
        debugPrint('this is programInfo ${response.statusCode}');
      }
      loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('this is programInfo  $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
