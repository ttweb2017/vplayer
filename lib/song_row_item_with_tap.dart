import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/model/song.dart';
import 'package:karaoke/play_video.dart';

import 'styles.dart';

class SongRowTapItem extends StatelessWidget {
  const SongRowTapItem({
    this.index,
    this.song,
    this.lastItem,
    this.cameras
  });

  final List<CameraDescription> cameras;
  final Song song;
  final int index;
  final bool lastItem;

  @override
  Widget build(BuildContext context) {
    final row = GestureDetector(
      onTap: (){
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute<bool>(
            fullscreenDialog: true,
            builder: (BuildContext context) => PlayVideo(
                song: song,
                cameras: cameras
            ),
          ),
        );
      },
      child: SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.only(
          left: 16,
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                song.assetName,
                fit: BoxFit.cover,
                width: 56,
                height: 56,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      song.name,
                      style: Styles.singerRowItemName,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 8)),
                    Text(
                      '${song.singer.name}',
                      style: Styles.singerRowItemPrice,
                    )
                  ],
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                //final model = Provider.of<AppStateModel>(context);
                //model.playSong(song.id);

                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute<bool>(
                    fullscreenDialog: true,
                    builder: (BuildContext context) => PlayVideo(
                        song: song,
                        cameras: cameras
                    ),
                  ),
                );
              },
              child: const Icon(
                CupertinoIcons.play_arrow,
                semanticLabel: 'Play',
              ),
            ),
          ],
        ),
      )
    );

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        Padding(
          padding: const EdgeInsets.only(
            left: 100,
            right: 16,
          ),
          child: Container(
            height: 1,
            color: Styles.singerRowDivider,
          ),
        ),
      ],
    );
  }
}