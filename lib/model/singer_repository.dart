import 'singer.dart';

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