import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import 'chewie_list_item.dart';

class VideoTab extends StatefulWidget {
  @override
  _VideoTabState createState() {
    return _VideoTabState();
  }
}

class _VideoTabState extends State<VideoTab> {
  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      child: ListView(
        children: <Widget>[
          ChewieListItem(
            videoPlayerController: VideoPlayerController.network(//asset
              'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            ),
            looping: true,
          ),
          ChewieListItem(
            videoPlayerController: VideoPlayerController.network(
              'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            ),
          ),
          ChewieListItem(
            // This URL doesn't exist - will display an error
            videoPlayerController: VideoPlayerController.network(
              'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/error.mp4',
            ),
          ),
        ],
      ),
    );
  }
}