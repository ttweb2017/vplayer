import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/camera_player_screen.dart';
import 'package:karaoke/chewie_list_item.dart';
import 'package:karaoke/model/song.dart';
import 'package:video_player/video_player.dart';

/*class PlayVideoTest extends StatefulWidget {
  PlayVideoTest({Key key, @required this.song, @required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;
  final Song song;

  @override
  _PlayVideoTestState createState() {
    return _PlayVideoTestState(song, cameras);
  }
}

class _PlayVideoTestState extends State<PlayVideoTest> {
  List<CameraDescription> cameras;
  Song song;
  String _url = "https://voicetm.com/videos/e582ecdc-df1f-40dd-b222-2f67c1315a9a.SampleVideo_1280x720_2mb.mp4"; //full

  _PlayVideoTestState(this.song, this.cameras);

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
}*/

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key, @required this.song, @required this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;
  final Song song;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(song, cameras);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  List<CameraDescription> cameras;
  Song song;
  _VideoPlayerScreenState(this.song, this.cameras);

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      song.fullVideoUrl
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);

    super.initState();

    _controller.play();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(song.name),
        ),
        resizeToAvoidBottomInset: true,
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CupertinoActivityIndicator());
          }
        },
      )
    );
  }
}