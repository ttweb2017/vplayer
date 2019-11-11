import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/camera_player_screen.dart';
import 'package:video_player/video_player.dart';

import 'chewie_list_item.dart';

class VideoTab extends StatefulWidget {
  VideoTab({Key key, @required this.cameras}) : super(key: key);
  List<CameraDescription> cameras;

  @override
  _VideoTabState createState() {
    return _VideoTabState(cameras);
  }
}

class _VideoTabState extends State<VideoTab> {
  List<CameraDescription> cameras;
  String _url = "https://voicetm.com/videos/e582ecdc-df1f-40dd-b222-2f67c1315a9a.SampleVideo_1280x720_2mb.mp4";//full

  _VideoTabState(this.cameras);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      child: ListView(
        children: <Widget>[
          //CameraScreen(cameras: cameras),
          /*ChewieListItem(
            videoPlayerController: VideoPlayerController.network(//asset
              _url,
            ),
            looping: true,
          ),
          ChewieListItem(
            videoPlayerController: VideoPlayerController.network(
              _url,
            ),
          ),*/
          ChewieListItem(
            // This URL doesn't exist - will display an error
            videoPlayerController: VideoPlayerController.network(
              _url,
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