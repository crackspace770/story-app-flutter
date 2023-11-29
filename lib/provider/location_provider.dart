import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/model/list_story.dart';
import '../data/response/story_response.dart';

enum ResultState {
  hasData,
  noData,
  loading,
  error,
}

class LocationProvider with ChangeNotifier {
  final Set<Marker> markers = {};
  String _currAddress = "Location Unknown";
  late ListStory _listStory;
  late ResultState _state;

  ResultState get state => _state;

  ListStory get listStory => _listStory;

  String? _selectedLocation;

  String? get selectedLocation => _selectedLocation;

  void setSelectedLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }




}