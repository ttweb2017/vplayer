import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/camera_player_screen.dart';
import 'package:karaoke/chewie_list_item.dart';
import 'package:karaoke/model/song.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  PlayVideo({Key key, @required this.song, @required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;
  final Song song;

  @override
  _PlayVideoState createState() {
    return _PlayVideoState(song, cameras);
  }
}

class _PlayVideoState extends State<PlayVideo> {
  List<CameraDescription> cameras;
  Song song;
  String _url = "https://voicetm.com/videos/e582ecdc-df1f-40dd-b222-2f67c1315a9a.SampleVideo_1280x720_2mb.mp4"; //full

  _PlayVideoState(this.song, this.cameras);

  /*_controller.addListener(() {
  if (_controller.value.hasError) {
  print(_controller.value.errorDescription);
  }
  if (_controller.value.initialized) {}
  if (_controller.value.isBuffering) {}
  });*/

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        //leading: Icon(CupertinoIcons.back),
        middle: Text(song.name),
      ),
      resizeToAvoidBottomInset: true,
      child: ListView(
        children: <Widget>[
          ChewieListItem(
            // This URL doesn't exist - will display an error
            videoPlayerController: VideoPlayerController.network(
              song.videoUrl,
            ),
            autoPlay: true,
            looping: true,
          ),
          Container(
            width: width,
            height: 300.0,
            child: CameraScreen(
              cameras: cameras,
            ),
          )
        ],
      ),
    );
  }
}