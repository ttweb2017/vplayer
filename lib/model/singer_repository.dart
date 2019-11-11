import 'package:flutter/cupertino.dart';
import 'package:karaoke/Constants.dart';

import 'singer.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class SingersRepository {
  static const _allSingers = <Singer>[];

  static List<Singer> loadSingers(Category category) {
    if (category == Category.all) {
      return _allSingers;
    } else {
      return _allSingers.where((p) => p.category == category).toList();
    }
  }
}