import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/Constants.dart';
import 'package:karaoke/song_row_item.dart';
import 'package:karaoke/song_row_item_with_tap.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';

class SongListTab extends StatelessWidget {
  SongListTab({Key key, @required this.cameras, @required this.isPopular}) : super(key: key);

  final List<CameraDescription> cameras;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {

    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        model.checkSongs();
        final songs = isPopular ? model.getPopularSongs() : model.getSongs();
        final String title = isPopular ? Constants.NAVIGATION_POPULAR : Constants.NAVIGATION_SONG;

        return CustomScrollView(
          semanticChildCount: songs.length,
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text(title),
            ),
            SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index < songs.length) {
                      return SongRowTapItem(
                        index: index,
                        song: songs[index],
                        lastItem: index == songs.length - 1,
                        cameras: cameras,
                      );
                    }
                    return null;
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }
}