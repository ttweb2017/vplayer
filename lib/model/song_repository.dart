import 'package:karaoke/model/singer.dart';
import 'package:karaoke/model/song.dart';

class SongsRepository {
  static const _allSingers = <Song>[];

  static List<Song> loadSingers(Singer singer) {
    if (singer == null) {
      return _allSingers;
    } else {
      return _allSingers.where((p) => p.singer == singer).toList();
    }
  }
}