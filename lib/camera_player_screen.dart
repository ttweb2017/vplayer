import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:karaoke/Constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key, @required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  _CameraScreenState createState() {
    return _CameraScreenState(cameras);
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return CupertinoIcons.switch_camera;
    case CameraLensDirection.front:
      return CupertinoIcons.switch_camera_solid;
    case CameraLensDirection.external:
      return CupertinoIcons.photo_camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');


class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;

  List<CameraDescription> cameras;

  _CameraScreenState(this.cameras);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(cameras.last);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(controller.value.isRecordingVideo){
      onStopButtonPressed();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      //key: _scaffoldKey,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: _videoCameraPreviewWidget(),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border.all(
                    color: controller != null && controller.value.isRecordingVideo
                        ? Color(0xFFFF0000)
                        : Color(0xFFC2C2C2),
                    width: 1.0,
                  ),
                ),
              ),
              Positioned.fill(
                top: height - 460.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child:  _recordControlWidget(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _videoCameraPreviewWidget() {
    return AspectRatio(
        aspectRatio: 1,
        child: CameraPreview(controller)
    );
  }

  /// Display the control button to record videos.
  Widget _recordControlWidget(){
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: width,
        height: 100,
        decoration: BoxDecoration(
            color: Color(0x40FFFFFF)
        ),
        padding: EdgeInsets.all(2.0),
        child: CupertinoButton(
          color: Color(0x000000),
          child: _cameraControlWidget(),
          pressedOpacity: 0.5,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : onStopButtonPressed,
        ),
      ),
    );
  }

  Widget _cameraControlWidget(){
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35.0),
          border: Border.all(
              color: controller != null && controller.value.isRecordingVideo
                  ? Color(0xFF00BFFF)
                  : Color(0xFFFFFFFF)
          ),
          color: controller != null && controller.value.isRecordingVideo
              ? Color(0xFFFF0000)
              : Color(0xFF00BFFF)
      ),
      child: Center(
        child: controller != null && controller.value.isRecordingVideo
            ? Icon(CupertinoIcons.share, size: 30.0, color: Color(0xFF00BFFF))
            : Icon(CupertinoIcons.video_camera, size: 30.0, color: Color(0xFFFFFFFF)),
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    /*_scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );*/
    print("SnackBar message::: " + message);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
      await controller.prepareForVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) {
        showInSnackBar('Saving video to $filePath');
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      GallerySaver.saveVideo(videoPath);
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    //final Directory extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir.path}' + Constants.SAVED_VIDEO_PATH;
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      print("FILE LOCATION: " + filePath);
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    //await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  /* Old Version
  @override
  Widget build(BuildContext context) {
    return Container(
      //key: _scaffoldKey,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF000000),
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Color(0xFFFF0000)
                      : Color(0xFFC2C2C2),
                  width: 1.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          _toggleAudioWidget(),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }*/

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
    /*if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }*/
  }

  /// Toggle recording audio
  Widget _toggleAudioWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: <Widget>[
          const Text('Enable Audio:'),
          CupertinoSwitch(
            value: enableAudio,
            onChanged: (bool value) {
              enableAudio = value;
              if (controller != null) {
                onNewCameraSelected(controller.description);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            videoController == null && imagePath == null
                ? Container()
                : SizedBox(
              child: (videoController == null)
                  ? Image.file(File(imagePath))
                  : Container(
                child: Center(
                  child: AspectRatio(
                      aspectRatio:
                      videoController.value.size != null
                          ? videoController.value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(videoController)),
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFFC0CB))),
              ),
              width: 64.0,
              height: 64.0,
            ),
          ],
        ),
      ),
    );
  }

  /// Display the control button to record videos.
  /*Widget _recordControlWidget(){
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: width,
        height: 100,
        decoration: BoxDecoration(
            color: Color(0x50FFFFFF)
        ),
        padding: EdgeInsets.all(2.0),
        child: CupertinoButton.filled(
          child: _cameraControlWidget(),
          borderRadius: BorderRadius.circular(36.0),
          pressedOpacity: 0.5,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : onStopButtonPressed,
        ),
      ),
    );
  }*/

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          width: width / 4,
          child: CupertinoButton.filled(
            child: const Icon(CupertinoIcons.video_camera),
            disabledColor: Color(0xFF00BFFF),
            onPressed: controller != null &&
                controller.value.isInitialized &&
                !controller.value.isRecordingVideo
                ? onVideoRecordButtonPressed
                : null,
          ),
        ),
        Container(
          width: width / 4,
          child: CupertinoButton.filled(
            child: controller != null && controller.value.isRecordingPaused
                ? Icon(CupertinoIcons.play_arrow)
                : Icon(CupertinoIcons.pause),
            disabledColor: Color(0xFF00BFFF),
            onPressed: controller != null &&
                controller.value.isInitialized &&
                controller.value.isRecordingVideo
                ? (controller != null && controller.value.isRecordingPaused
                ? onResumeButtonPressed
                : onPauseButtonPressed)
                : null,
          ),
        ),
        Container(
          width: width / 4,
          child: CupertinoButton.filled(
            child: const Icon(CupertinoIcons.settings_solid),
            disabledColor: Color(0xFFFF0000),
            onPressed: controller != null &&
                controller.value.isInitialized &&
                controller.value.isRecordingVideo
                ? onStopButtonPressed
                : null,
          ),
        ),
        Container(
          width: width / 4,
          child: CupertinoButton.filled(
            child: const Icon(CupertinoIcons.switch_camera_solid),
            disabledColor: Color(0xFF00BFFF),
            onPressed: controller != null &&
                controller.value.isInitialized &&
                !controller.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
            SizedBox(
            width: 90.0,
            child: CupertinoButton(
              child: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              onPressed: (){
                controller != null && controller.value.isRecordingVideo ? null : onNewCameraSelected(cameraDescription);
              }
            )/*RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),*/
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  /*void _recordVideo() async {
    ImagePicker.pickVideo(source: ImageSource.camera)
        .then((File recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        GallerySaver.saveVideo(recordedVideo.path).then((String path) {
          /*setState(() {
            secondButtonText = 'video saved!';
          });*/
          print("video saved");
        });
      }
    });
  }*/

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }
}