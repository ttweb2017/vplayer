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
  VideoPlayerController _videoPlayerController;
  List<CameraDescription> cameras;
  Future<void> _initializeVideoPlayerFuture;
  Song song;
  String _url = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"; //full

  _PlayVideoState(this.song, this.cameras);

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(
      song.fullVideoUrl,
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
    super.initState();
  }

  @override
  void dispose() {
   // _videoPlayerController.dispose();
    super.dispose();
  }

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
        middle: Text(song.name)
      ),
      resizeToAvoidBottomInset: true,
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot){
         return snapshot.connectionState == ConnectionState.done
             ? ListView(
                children: <Widget>[
                  ChewieListItem(
                    videoPlayerController: _videoPlayerController,
                    autoPlay: true,
                    looping: false,
                  ),
                  Container(
                    width: width,
                    height: height - 280.0,
                    child: CameraScreen(
                      cameras: cameras,
                    ),
                  )
                ])
             : Center(child: CupertinoActivityIndicator());
        },
      ),
    );

    /*return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(song.name),
      ),
      resizeToAvoidBottomInset: true,
      child: _videoPlayerController.value.initialized ? ListView(
        children: <Widget>[
          ChewieListItem(
            // This URL doesn't exist - will display an error
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: false,
          ),
          Container(
            width: width,
            height: height - 280.0,
            child: CameraScreen(
              cameras: cameras,
            ),
          )
        ],
      ) : Center(child: CupertinoActivityIndicator()),
    );*/
  }
}