import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/model/app_state_model.dart';
import 'package:karaoke/model/singer.dart';
import 'package:karaoke/song_row_item.dart';
import 'package:karaoke/song_row_item_with_tap.dart';
import 'package:karaoke/styles.dart';
import 'package:provider/provider.dart';

class SingerSongsScreen extends StatefulWidget {
  SingerSongsScreen({Key key, this.singer, this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;
  final Singer singer;

  @override
  _SingerSongsScreenState createState() {
    return _SingerSongsScreenState(singer, cameras);
  }
}

class _SingerSongsScreenState extends State<SingerSongsScreen> {
  List<CameraDescription> cameras;
  Singer singer;

  _SingerSongsScreenState(this.singer, this.cameras);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppStateModel>(context);
    final results = model.searchSongBySinger(singer);

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text(singer.name),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Styles.scaffoldBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => SongRowTapItem(
                    index: index,
                    song: results[index],
                    lastItem: index == results.length - 1,
                    cameras: cameras,
                  ),
                  itemCount: results.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}