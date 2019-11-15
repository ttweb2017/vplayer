import 'package:flutter/foundation.dart';
import 'package:karaoke/Constants.dart';
import 'package:karaoke/model/singer.dart';

class Song {
  const Song({
    @required this.singer,
    @required this.id,
    @required this.avatar,
    @required this.name,
    @required this.video,
  })  : assert(singer != null),
        assert(id != null),
        assert(name != null),
        assert(avatar != null);

  final int id;
  final Singer singer;
  final String avatar;
  final String name;
  final String video;

  String get assetName => Constants.VIDEO_PATH + '/$avatar';
  String get videoName => Constants.VIDEO_PATH + '/$video';
  String get videoUrl => Constants.VIDEO_URL + '/$video' + '/full';

  @override
  String toString() => '$name (id=$id)';

  factory Song.fromJson(Map<String, dynamic> json) {

    return Song(
      singer: Singer.fromJson(json['singer']),
      id: json['id'],
      avatar: json['image'],
      name: json['name'],
      video: json['video']
    );
  }
}