import 'package:answer_me/models/Category.dart';
import 'package:answer_me/models/QuestionTag.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:flutter/material.dart';
import 'package:answer_me/models/settings.dart';

class AppProvider with ChangeNotifier {
  Settings _settings;
  List<Category> _categories = [];
  List<QuestionTag> _tags = [];
  List<Question> _recentQuestions = [];
  List<Question> _mostAnsweredQuestions = [];
  List<Question> _mostVisitedQuestions = [];
  List<Question> _mostVotedQuestions = [];
  List<Question> _noAnswersQuestions = [];
  List<Question> _bookmarkQuestions = [];
  int _adClickCount = 0;
  bool _noBookmarks = false;

  AppProvider() {
    getCategories();
    getTags();
    getSettings();
  }

  Settings get settings {
    return _settings;
  }

  List<Category> get categories {
    return _categories;
  }

  List<QuestionTag> get tags {
    return _tags;
  }

  List<Question> get recentQuestions {
    return _recentQuestions;
  }

  List<Question> get mostAnsweredQuestions {
    return _mostAnsweredQuestions;
  }

  List<Question> get mostVisitedQuestions {
    return _mostVisitedQuestions;
  }

  List<Question> get mostVotedQuestions {
    return _mostVotedQuestions;
  }

  List<Question> get noAnswersQuestions {
    return _noAnswersQuestions;
  }

  List<Question> get bookmarkQuestions {
    return _bookmarkQuestions;
  }

  bool get noBookmarks {
    return _noBookmarks;
  }

  int get adClickCount {
    return _adClickCount;
  }

  Future<bool> setNoBookmarks(bool noBookmarks) async {
    _noBookmarks = noBookmarks;
    notifyListeners();
    return true;
  }

  Future<bool> setSetting(Settings settings) async {
    _settings = settings;
    notifyListeners();
    return true;
  }

  Future<void> incrementAdClickCount() async {
    _adClickCount++;
    notifyListeners();
  }

  Future<void> resetAdClickCount() async {
    _adClickCount = 0;
    notifyListeners();
  }

  Future getSettings() async {
    Settings settings = await ApiRepository.getSettings();
    if (settings != null) {
      _settings = settings;
    }
    notifyListeners();
  }

  Future<bool> setCategories(List<Category> categories) async {
    _categories = categories;
    notifyListeners();
    return true;
  }

  Future getCategories() async {
    List<Category> categories = await ApiRepository.getCategories();
    if (categories != null) {
      this._categories = categories;
      notifyListeners();
    }
  }

  Future getTags() async {
    List<QuestionTag> tags = await ApiRepository.getTags();
    if (tags != null) {
      this._tags = tags;
      notifyListeners();
    }
  }

  Future<bool> setRecentQuestions(List<Question> questions) async {
    this._recentQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setMostAnsweredQuestions(List<Question> questions) async {
    _mostAnsweredQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setMostVisitedQuestions(List<Question> questions) async {
    _mostVisitedQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setMostVotedQuestions(List<Question> questions) async {
    _mostVotedQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setNoAnswersQuestions(List<Question> questions) async {
    _noAnswersQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setBookmarkedQuestions(List<Question> questions) async {
    _bookmarkQuestions = questions;
    notifyListeners();
    return true;
  }

  clearBookmarkQuestions() {
    _bookmarkQuestions.clear();
    _bookmarkQuestions = [];
  }

  clearRecentQuestions() {
    _recentQuestions = [];
  }

  clearMostAnsweredQuestions() {
    _mostAnsweredQuestions = [];
  }

  clearMostVisitedQuestions() {
    _mostVisitedQuestions = [];
  }

  clearMostVotedQuestions() {
    _mostVotedQuestions = [];
  }

  clearNoAnswersQuestions() {
    _noAnswersQuestions = [];
  }

  clearAllQuestions() {
    clearRecentQuestions();
    clearMostAnsweredQuestions();
    clearMostVisitedQuestions();
    clearMostVotedQuestions();
    clearNoAnswersQuestions();
    notifyListeners();
  }

  notifyListeners();
}
