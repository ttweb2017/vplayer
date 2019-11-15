import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:karaoke/song_row_item.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';
import 'search_bar.dart';
import 'styles.dart';

class SearchTab extends StatefulWidget {
  SearchTab({Key key, this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  _SearchTabState createState() {
    return _SearchTabState(cameras);
  }
}

class _SearchTabState extends State<SearchTab> {
  List<CameraDescription> cameras;
  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';

  _SearchTabState(this.cameras);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
    });
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppStateModel>(context);
    final results = model.searchSong(_terms);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Styles.scaffoldBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBox(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => SongRowItem(
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
    );
  }
}