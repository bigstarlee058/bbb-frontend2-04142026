import 'package:bbb/middleware/api/api_service.dart';
import 'package:bbb/models/city_model.dart';
import 'package:bbb/models/country_model.dart';
import 'package:bbb/models/state_model.dart';
import 'package:flutter/cupertino.dart';

class LocationProvider extends ChangeNotifier {
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  TextEditingController selectedCityController = TextEditingController();
  // String token = '';
  // List<Country> country = [];
  // List<model.State> states = [];
  // List<City> cities = [];

  CountryModel? country;
  StatesModel? states;
  CityModel? cities;

  fillDetails(String country, String state, String city) async {
    selectedCountry = country;
    selectedState = state;
    selectedCity = city;
    selectedCityController.text = city;
    await setAndCallApi(co: country, st: state);
    notifyListeners();
  }

  onCountrySelect(String? newValue) {
    selectedCountry = newValue;
    selectedState = null;
    selectedCity = null;
    states = null;
    cities = null;
    notifyListeners();
    getState(newValue!);
  }

  onStateSelect(String? newValue) {
    selectedState = newValue;
    selectedCity = null;
    cities = null;
    notifyListeners();
    getCity(selectedCountry ?? "", newValue!);
  }

  onCitySelect(String? newValue) {
    selectedCity = newValue;
    notifyListeners();
  }

  Future<void> setAndCallApi({String? co, String? st}) async {
    await getCounties();
    await getState(co ?? "United States");
    await getCity(co ?? "United States", st ?? "Alaska");
  }

  Future<void> getCounties() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "/api/location/country");
    if (response != null) {
      country = CountryModel.fromJson(response);
    }
    notifyListeners();
  }

  Future<void> getState(String countryName) async {
    if (countryName.isEmpty) return;
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "/api/location/states/$countryName");
    if (response != null) {
      states = StatesModel.fromJson(response);
    }
    notifyListeners();
  }

  Future<void> getCity(String countryName, String stateName) async {
    if (countryName.isEmpty || stateName.isEmpty) return;
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "/api/location/cities/$countryName/$stateName");
    if (response != null) {
      cities = CityModel.fromJson(response);
    }
    notifyListeners();
  }
}
