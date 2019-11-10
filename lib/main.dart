import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:karaoke/camera_player_screen.dart';
import 'package:karaoke/search_tab.dart';
import 'package:karaoke/singer_list_tab.dart';
import 'package:karaoke/song_list_tab.dart';
import 'package:karaoke/video_tab.dart';
import 'package:provider/provider.dart';
import 'model/app_state_model.dart';

/*void main() {
  return runApp(
      ChangeNotifierProvider<AppStateModel>(
        builder: (context) => AppStateModel()..loadSingers(),
        child: KaraokeApp(),
      )
  );
}*/

List<CameraDescription> cameras;

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }

  runApp(
      ChangeNotifierProvider<AppStateModel>(
        builder: (context) => AppStateModel()..loadSingers(),
        child: KaraokeApp(),
      )
  );
}

class KaraokeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      title: 'Karaoke',
      home: KaraokePage(
          cameras: cameras,
          title: 'Karaoke Home Page'
      ),
    );
  }
}

class KaraokePage extends StatefulWidget {
  KaraokePage({Key key, @required this.cameras, this.title}) : super(key: key);
  final String title;
  final List<CameraDescription> cameras;

  @override
  _KaraokePageState createState() => _KaraokePageState(cameras);
}

class _KaraokePageState extends State<KaraokePage> {
  List<CameraDescription> cameras;

  _KaraokePageState(this.cameras);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            title: Text('Singers'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_note),
            title: Text('Songs'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.video_camera),
            title: Text('Video'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SingerListTab(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SearchTab(),
              );
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SongListTab(),
              );
            });
            break;
          case 3:
            returnValue = CupertinoTabView(builder: (context){
              return CupertinoPageScaffold(
                child: VideoTab(cameras: cameras),
              );
            });
            break;
        }
        return returnValue;
      },
    );
  }
}
