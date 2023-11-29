import 'package:flutter/material.dart';
import '../data/api/api_service.dart';
import '../data/model/list_story.dart';
import '../data/response/story_response.dart';

enum ResultState {
  initial,
  loading,
  noData,
  hasData,
  error,}

class StoryProvider extends ChangeNotifier {
  final ApiService apiService;

  StoryProvider({required this.apiService}) {
    _setControllerListener();
    fetchStory();
  }

  bool isLoading = false;

  final int _currentSize = 10;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isScrollLoading = false;

  late ResultState state;

  late StoryResponse _storiesResults;
  StoryResponse get storiesResults => _storiesResults;

  final List<ListStory> _listStory = [];
  List<ListStory> get listStory => _listStory;

  ScrollController get scrollController => _scrollController;

  bool get isScrollLoading => _isScrollLoading;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> fetchStory() async {
    try {
      if (_listStory.isEmpty) {
        state = ResultState.loading;
      } else {
        _isScrollLoading = true;
      }
      notifyListeners();

      _storiesResults = await apiService.getStoriesList(_currentPage, _currentSize);
      if (_storiesResults!.listStory!.isNotEmpty) {
        _listStory.addAll(_storiesResults?.listStory ?? []);
        state = ResultState.hasData;
      } else {
        if (_listStory.isEmpty) {
          state = ResultState.noData;
        } else {
          state = ResultState.hasData;
          _hasReachedMax = true;
        }
      }
      state = ResultState.hasData;

      if (_isScrollLoading) {
        _isScrollLoading = false;
      }

      notifyListeners();
    } catch (e) {
      isLoading = false;
      state = ResultState.error;
      notifyListeners();
      throw Exception('Error fetch list API : $e');
    }
  }


  void _setControllerListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        if (!_hasReachedMax) {
          _currentPage++;
          fetchStory();
        }
      }
    });
  }

  void resetPagination() {
    _currentPage = 1;
    _hasReachedMax = false;
    _listStory.clear();
  }


}