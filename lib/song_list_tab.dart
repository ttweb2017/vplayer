import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/song_row_item.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';

class SongListTab extends StatelessWidget {
  SongListTab({Key key, this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        final songs = model.getSongs();
        return CustomScrollView(
          semanticChildCount: songs.length,
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Songs'),
            ),
            SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index < songs.length) {
                      return SongRowItem(
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