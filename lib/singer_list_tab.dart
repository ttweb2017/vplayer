import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/singer_row_item.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';

class SingerListTab extends StatelessWidget {
  SingerListTab({Key key, this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        model.checkSingers();
        final singers = model.getSingers();
        return CustomScrollView(
          semanticChildCount: singers.length,
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Singers'),
            ),
            SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index < singers.length) {
                      return SingerRowItem(
                        index: index,
                        singer: singers[index],
                        lastItem: index == singers.length - 1,
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